<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.',
            ], 401);
        }

        if ($user->is_active === false || $user->is_active === 0) {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda dinonaktifkan. Silakan hubungi admin.',
            ], 403);
        }

        if (! empty($roles) && ! in_array($user->role, $roles, true)) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden. Access restricted to roles: '.implode(', ', $roles),
            ], 403);
        }

        // Bagian B: Proteksi akses fitur teknisi hanya untuk teknisi yang sudah disetujui
        if (in_array('technician', $roles, true) && $user->role === 'technician') {
            $profile = $user->technicianProfile()->first();
            if ($profile) {
                if ($profile->status === 'rejected') {
                    return response()->json([
                        'success' => false,
                        'message' => 'Pendaftaran akun teknisi Anda ditolak oleh Admin.',
                        'registration_status' => 'rejected',
                        'rejection_reason' => $profile->rejection_reason,
                    ], 403);
                }

                if ($profile->status === 'pending' && ! $profile->is_verified && ! $profile->is_available) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Akun teknisi Anda belum disetujui atau dinonaktifkan oleh Admin.',
                        'registration_status' => 'pending',
                        'rejection_reason' => $profile->rejection_reason,
                    ], 403);
                }
            }
        }

        return $next($request);
    }
}
