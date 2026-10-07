<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\Order;
use App\Models\TechnicianProfile;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    /**
     * Get aggregated metrics for Admin Dashboard (Fitur 14: Dashboard Admin).
     */
    public function dashboardStats(): JsonResponse
    {
        $totalOrders = Order::count();
        $completedOrders = Order::where('status', Order::STATUS_COMPLETED)->count();
        $inProgressOrders = Order::whereIn('status', [Order::STATUS_ACCEPTED, Order::STATUS_ON_THE_WAY, Order::STATUS_IN_PROGRESS])->count();
        $totalRevenue = Order::where('payment_status', 'paid')->sum('total_amount');

        $totalCustomers = User::where('role', 'customer')->count();
        $totalTechnicians = User::where('role', 'technician')->count();
        $verifiedTechnicians = TechnicianProfile::where('is_verified', true)->count();
        $pendingTechnicians = TechnicianProfile::where('is_verified', false)->count();

        $recentOrders = Order::with(['customer:id,name,phone', 'technician:id,name'])
            ->latest()
            ->take(5)
            ->get();

        $recentLogs = ActivityLog::with('actor:id,name,role')
            ->latest()
            ->take(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'metrics' => [
                    'total_orders' => $totalOrders,
                    'completed_orders' => $completedOrders,
                    'in_progress_orders' => $inProgressOrders,
                    'total_revenue' => (float) $totalRevenue,
                    'total_customers' => $totalCustomers,
                    'total_technicians' => $totalTechnicians,
                    'verified_technicians' => $verifiedTechnicians,
                    'pending_technicians' => $pendingTechnicians,
                ],
                'recent_orders' => $recentOrders,
                'recent_logs' => $recentLogs,
            ],
        ]);
    }

    /**
     * Get list of users with filtering.
     */
    public function users(Request $request): JsonResponse
    {
        $query = User::with('technicianProfile');

        if ($request->has('role')) {
            $query->where('role', $request->query('role'));
        }

        if ($request->has('search')) {
            $search = $request->query('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        $users = $query->latest()->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    /**
     * Admin verifies or revokes a technician (Audit Event #6: technician.verified).
     */
    public function verifyTechnician(Request $request, int $technicianId): JsonResponse
    {
        $admin = $request->user();
        $tech = User::where('role', 'technician')->findOrFail($technicianId);
        $profile = $tech->technicianProfile ?? TechnicianProfile::create(['user_id' => $tech->id]);

        $validated = $request->validate([
            'is_verified' => ['required', 'boolean'],
        ]);

        $oldStatus = $profile->is_verified;
        $profile->update([
            'is_verified' => $validated['is_verified'],
            'verified_at' => $validated['is_verified'] ? now() : null,
            'verified_by' => $validated['is_verified'] ? $admin->id : null,
        ]);

        ActivityLog::logEvent(
            eventName: 'technician.verified',
            description: "Admin {$admin->name} mengubah status verifikasi teknisi {$tech->name} menjadi: ".($validated['is_verified'] ? 'Terverifikasi' : 'Belum Terverifikasi'),
            entity: $profile,
            oldValues: ['is_verified' => $oldStatus],
            newValues: ['is_verified' => $validated['is_verified']],
            request: $request,
            actor: $admin
        );

        return response()->json([
            'success' => true,
            'message' => 'Status verifikasi teknisi berhasil diperbarui.',
            'data' => $profile->fresh(),
        ]);
    }

    /**
     * Modify user role (Audit Event #7: user.role.modified).
     */
    public function updateUserRole(Request $request, int $userId): JsonResponse
    {
        $admin = $request->user();
        $user = User::findOrFail($userId);

        $validated = $request->validate([
            'role' => ['required', 'string', 'in:customer,technician,admin'],
        ]);

        $oldRole = $user->role;
        $user->update(['role' => $validated['role']]);

        if ($validated['role'] === 'technician') {
            TechnicianProfile::firstOrCreate(
                ['user_id' => $user->id],
                [
                    'skills' => ['Kompor Gas Standar'],
                    'is_verified' => false,
                    'is_available' => true,
                ]
            );
        }

        ActivityLog::logEvent(
            eventName: 'user.role.modified',
            description: "Admin {$admin->name} mengubah role {$user->name} dari {$oldRole} menjadi {$validated['role']}",
            entity: $user,
            oldValues: ['role' => $oldRole],
            newValues: ['role' => $validated['role']],
            request: $request,
            actor: $admin
        );

        return response()->json([
            'success' => true,
            'message' => 'Peran pengguna berhasil diubah.',
            'data' => $user->fresh('technicianProfile'),
        ]);
    }

    /**
     * View audit activity logs (Fitur 14 & Matriks Keamanan).
     */
    public function activityLogs(Request $request): JsonResponse
    {
        $query = ActivityLog::with('actor:id,name,email,role');

        if ($request->has('event_name')) {
            $query->where('event_name', $request->query('event_name'));
        }

        if ($request->has('actor_role')) {
            $query->where('actor_role', $request->query('actor_role'));
        }

        $logs = $query->latest('id')->paginate(30);

        return response()->json([
            'success' => true,
            'data' => $logs,
        ]);
    }
}
