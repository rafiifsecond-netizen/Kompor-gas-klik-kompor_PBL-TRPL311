<?php

namespace App\Services;

use App\Models\PlatformSetting;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class TravelFeeService
{
    /**
     * Calculate a road-distance estimate and the configured travel fee.
     *
     * Routing failures deliberately fall back to Haversine distance so an
     * order can still be priced, while the response records the estimate.
     */
    public function calculate(
        ?float $customerLatitude,
        ?float $customerLongitude,
        ?float $technicianLatitude,
        ?float $technicianLongitude
    ): array {
        $distanceKm = null;
        $durationMinutes = null;
        $source = 'unavailable';

        if ($this->validCoordinates($customerLatitude, $customerLongitude)
            && $this->validCoordinates($technicianLatitude, $technicianLongitude)) {
            $route = $this->route(
                (float) $customerLatitude,
                (float) $customerLongitude,
                (float) $technicianLatitude,
                (float) $technicianLongitude
            );

            if ($route !== null) {
                $distanceKm = $route['distance_km'];
                $durationMinutes = $route['duration_minutes'];
                $source = 'routing';
            } else {
                $distanceKm = $this->haversine(
                    (float) $customerLatitude,
                    (float) $customerLongitude,
                    (float) $technicianLatitude,
                    (float) $technicianLongitude
                );
                $source = 'haversine_fallback';
            }
        }

        $billableDistance = max(
            0,
            ($distanceKm ?? 0) - (float) PlatformSetting::get('travel_free_km', 2)
        );
        $roundingUnit = max(0.01, (float) PlatformSetting::get('travel_rounding_unit_km', 1));
        $roundingMode = (string) PlatformSetting::get('travel_rounding_mode', 'ceil');
        $roundedDistance = $this->roundDistance($billableDistance, $roundingUnit, $roundingMode);
        $baseFee = (int) PlatformSetting::get('travel_base_fee', 15000);
        $ratePerKm = (int) PlatformSetting::get('travel_rate_per_km', 0);

        return [
            'distance_km' => $distanceKm,
            'duration_minutes' => $durationMinutes,
            'billable_distance_km' => $roundedDistance,
            'fee' => max(0, $baseFee + (int) round($roundedDistance * $ratePerKm)),
            'source' => $source,
        ];
    }

    private function route(float $customerLatitude, float $customerLongitude, float $technicianLatitude, float $technicianLongitude): ?array
    {
        $baseUrl = rtrim((string) config('services.routing.osrm_url', ''), '/');
        if ($baseUrl === '') {
            return null;
        }

        try {
            $response = Http::timeout((int) config('services.routing.timeout', 5))
                ->get(sprintf(
                    '%s/%s,%s;%s,%s',
                    $baseUrl,
                    $technicianLongitude,
                    $technicianLatitude,
                    $customerLongitude,
                    $customerLatitude
                ), ['overview' => 'false']);

            if (! $response->successful() || $response->json('code') !== 'Ok') {
                return null;
            }

            $route = $response->json('routes.0');
            if (! is_array($route) || ! isset($route['distance'], $route['duration'])) {
                return null;
            }

            return [
                'distance_km' => round(((float) $route['distance']) / 1000, 3),
                'duration_minutes' => (int) ceil(((float) $route['duration']) / 60),
            ];
        } catch (\Throwable $exception) {
            Log::warning('Routing service unavailable; using Haversine fallback.', [
                'message' => $exception->getMessage(),
            ]);

            return null;
        }
    }

    private function validCoordinates(?float $latitude, ?float $longitude): bool
    {
        return $latitude !== null && $longitude !== null
            && $latitude >= -90 && $latitude <= 90
            && $longitude >= -180 && $longitude <= 180;
    }

    private function haversine(float $latitude1, float $longitude1, float $latitude2, float $longitude2): float
    {
        $deltaLatitude = deg2rad($latitude2 - $latitude1);
        $deltaLongitude = deg2rad($longitude2 - $longitude1);
        $a = sin($deltaLatitude / 2) ** 2
            + cos(deg2rad($latitude1)) * cos(deg2rad($latitude2)) * sin($deltaLongitude / 2) ** 2;

        return round(6371 * 2 * atan2(sqrt($a), sqrt(1 - $a)), 3);
    }

    private function roundDistance(float $distance, float $unit, string $mode): float
    {
        $scaled = $distance / $unit;
        $rounded = match (strtolower($mode)) {
            'floor' => floor($scaled),
            'round' => round($scaled),
            default => ceil($scaled),
        };

        return round($rounded * $unit, 3);
    }
}
