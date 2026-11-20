<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\Notification;
use App\Models\TechnicianProfile;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class AdminTechnicianApprovalController extends Controller
{
    /**
     * Approve technician registration (Bagian B - Web Admin).
     */
    public function approve(Request $request, int $id): RedirectResponse
    {
        $admin = $request->user();
        $user = User::where('role', 'technician')->findOrFail($id);
        $profile = $user->technicianProfile ?? TechnicianProfile::create(['user_id' => $user->id]);

        // Idempotency check: don't double approve
        if ($profile->status === TechnicianProfile::STATUS_APPROVED && $profile->is_verified) {
            return redirect()->route('admin.technicians')
                ->with('success', "Teknisi {$user->name} sudah disetujui sebelumnya.");
        }

        $oldValues = $profile->toArray();

        $profile->update([
            'status' => TechnicianProfile::STATUS_APPROVED,
            'is_verified' => true,
            'verified_at' => now(),
            'verified_by' => $admin->id,
            'is_available' => true,
            'rejection_reason' => null,
        ]);

        $user->update(['is_active' => true]);

        // Send in-app notification to technician
        Notification::create([
            'user_id' => $user->id,
            'title' => 'Pendaftaran Akun Teknisi Disetujui!',
            'message' => 'Selamat, pendaftaran akun teknisi Anda telah disetujui oleh Admin. Anda kini dapat menerima pesanan servis kompor gas.',
            'type' => 'account_approved',
            'data' => [
                'technician_id' => $user->id,
                'status' => 'approved',
            ],
        ]);

        ActivityLog::logEvent(
            eventName: 'technician.registration.approved',
            description: "Admin {$admin->name} menyetujui pendaftaran teknisi {$user->name}",
            entity: $profile,
            oldValues: $oldValues,
            newValues: $profile->toArray(),
            request: $request,
            actor: $admin
        );

        return redirect()->route('admin.technicians')
            ->with('success', "Pendaftaran teknisi {$user->name} berhasil disetujui.");
    }

    /**
     * Reject technician registration with reason (Bagian B - Web Admin).
     */
    public function reject(Request $request, int $id): RedirectResponse
    {
        $admin = $request->user();
        $user = User::where('role', 'technician')->findOrFail($id);
        $profile = $user->technicianProfile ?? TechnicianProfile::create(['user_id' => $user->id]);

        $validated = $request->validate([
            'rejection_reason' => ['required', 'string', 'max:500'],
        ]);

        $oldValues = $profile->toArray();

        $profile->update([
            'status' => TechnicianProfile::STATUS_REJECTED,
            'is_verified' => false,
            'rejection_reason' => $validated['rejection_reason'],
            'verified_by' => $admin->id,
            'verified_at' => now(),
        ]);

        // Send in-app notification to technician
        Notification::create([
            'user_id' => $user->id,
            'title' => 'Pendaftaran Akun Teknisi Ditolak',
            'message' => "Mohon maaf, pendaftaran akun teknisi Anda belum dapat disetujui. Alasan: {$validated['rejection_reason']}",
            'type' => 'account_rejected',
            'data' => [
                'technician_id' => $user->id,
                'status' => 'rejected',
                'rejection_reason' => $validated['rejection_reason'],
            ],
        ]);

        ActivityLog::logEvent(
            eventName: 'technician.registration.rejected',
            description: "Admin {$admin->name} menolak pendaftaran teknisi {$user->name} dengan alasan: {$validated['rejection_reason']}",
            entity: $profile,
            oldValues: $oldValues,
            newValues: $profile->toArray(),
            request: $request,
            actor: $admin
        );

        return redirect()->route('admin.technicians')
            ->with('success', "Pendaftaran teknisi {$user->name} telah ditolak.");
    }

    /**
     * Toggle technician active/inactive state.
     */
    public function toggleActive(Request $request, int $id): RedirectResponse
    {
        $admin = $request->user();
        $user = User::where('role', 'technician')->findOrFail($id);
        $oldState = $user->is_active;

        $user->is_active = ! $oldState;
        $user->save();

        ActivityLog::logEvent(
            eventName: 'technician.toggled_active',
            description: "Admin {$admin->name} mengubah status aktif teknisi {$user->name} menjadi: ".($user->is_active ? 'Aktif' : 'Nonaktif'),
            entity: $user,
            oldValues: ['is_active' => $oldState],
            newValues: ['is_active' => $user->is_active],
            request: $request,
            actor: $admin
        );

        $statusStr = $user->is_active ? 'diaktifkan' : 'dinonaktifkan';

        return redirect()->route('admin.technicians')
            ->with('success', "Akun teknisi {$user->name} berhasil {$statusStr}.");
    }
}
