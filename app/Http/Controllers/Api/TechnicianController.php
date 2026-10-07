<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TechnicianController extends Controller
{
    /**
     * Search and list technicians (Fitur 1: Pencarian Teknisi).
     */
    public function index(Request $request): JsonResponse
    {
        $query = User::query()
            ->where('role', 'technician')
            ->where('is_active', true)
            ->whereHas('technicianProfile', function ($q) {
                $q->where('is_verified', true);
            })
            ->with(['technicianProfile.services.serviceItem', 'reviewsReceived.customer']);

        // Filter by availability
        if ($request->has('available_only') && $request->boolean('available_only')) {
            $query->whereHas('technicianProfile', function ($q) {
                $q->where('is_available', true);
            });
        }

        // Filter by search keyword (name or skills)
        if ($request->has('search')) {
            $search = $request->query('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhereHas('technicianProfile', function ($tp) use ($search) {
                        $tp->where('bio', 'like', "%{$search}%")
                            ->orWhere('skills', 'like', "%{$search}%");
                    });
            });
        }

        // Filter by specific service item
        if ($request->has('service_id')) {
            $serviceId = $request->query('service_id');
            $query->whereHas('technicianProfile.services', function ($q) use ($serviceId) {
                $q->where('service_item_id', $serviceId)->where('is_offered', true);
            });
        }

        $technicians = $query->get();

        // Calculate proximity distance if customer coordinates provided
        if ($request->has('latitude') && $request->has('longitude')) {
            $custLat = (float) $request->query('latitude');
            $custLng = (float) $request->query('longitude');

            $technicians = $technicians->map(function ($tech) use ($custLat, $custLng) {
                $profile = $tech->technicianProfile;
                if ($profile && $profile->current_latitude && $profile->current_longitude) {
                    $tech->distance_km = round($this->calculateHaversineDistance(
                        $custLat,
                        $custLng,
                        $profile->current_latitude,
                        $profile->current_longitude
                    ), 1);
                } else {
                    $tech->distance_km = null;
                }

                return $tech;
            })->sortBy(function ($tech) {
                return $tech->distance_km ?? 999999;
            })->values();
        }

        return response()->json([
            'success' => true,
            'data' => $technicians,
        ]);
    }

    /**
     * Get detailed technician profile & reputation (Fitur 3: Profil dan Reputasi Teknisi).
     */
    public function show(int $id): JsonResponse
    {
        $technician = User::where('role', 'technician')
            ->where('id', $id)
            ->with([
                'technicianProfile.services.serviceItem.category',
                'reviewsReceived' => function ($q) {
                    $q->with('customer:id,name,avatar_url')->latest()->take(20);
                },
            ])
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => $technician,
        ]);
    }

    /**
     * Technician updates availability status (Online / Offline).
     */
    public function updateAvailability(Request $request): JsonResponse
    {
        $user = $request->user();

        if (! $user->isTechnician()) {
            return response()->json(['success' => false, 'message' => 'Hanya teknisi yang dapat mengubah ketersediaan.'], 403);
        }

        $validated = $request->validate([
            'is_available' => ['required', 'boolean'],
        ]);

        $user->technicianProfile()->update([
            'is_available' => $validated['is_available'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Status ketersediaan berhasil diubah.',
            'data' => [
                'is_available' => $validated['is_available'],
            ],
        ]);
    }

    /**
     * Technician updates GPS coordinates (Fitur 8: Lokasi dan Navigasi).
     */
    public function updateLocation(Request $request): JsonResponse
    {
        $user = $request->user();

        if (! $user->isTechnician()) {
            return response()->json(['success' => false, 'message' => 'Hanya teknisi yang dapat memperbarui lokasi.'], 403);
        }

        $validated = $request->validate([
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
        ]);

        $user->technicianProfile()->update([
            'current_latitude' => $validated['latitude'],
            'current_longitude' => $validated['longitude'],
            'last_location_updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Lokasi teknisi berhasil diperbarui.',
            'data' => [
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
                'updated_at' => now(),
            ],
        ]);
    }

    /**
     * Calculate distance between two lat/lng points using Haversine formula (km).
     */
    private function calculateHaversineDistance(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371; // km
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
            cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
            sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c;
    }
}
