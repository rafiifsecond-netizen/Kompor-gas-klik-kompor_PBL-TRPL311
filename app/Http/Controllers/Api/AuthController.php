<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\TechnicianProfile;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register a new user (Customer or Technician).
     */
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'max:20', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'role' => ['sometimes', 'string', Rule::in(['customer', 'technician'])],
            'address' => ['nullable', 'string'],
            // Specific for technician registration
            'bio' => ['nullable', 'string'],
            'years_of_experience' => ['nullable', 'integer', 'min:0'],
            'skills' => ['nullable', 'array'],
            'ktp_number' => ['nullable', 'string', 'max:30'],
        ]);

        $role = $validated['role'] ?? 'customer';

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'],
            'role' => $role,
            'address' => $validated['address'] ?? null,
            'password' => Hash::make($validated['password']),
            'is_active' => true,
        ]);

        if ($role === 'technician') {
            TechnicianProfile::create([
                'user_id' => $user->id,
                'bio' => $validated['bio'] ?? null,
                'years_of_experience' => $validated['years_of_experience'] ?? 0,
                'skills' => $validated['skills'] ?? ['Kompor Gas Standar'],
                'ktp_number' => $validated['ktp_number'] ?? null,
                'is_verified' => false,
                'is_available' => true,
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        ActivityLog::logEvent(
            eventName: 'user.account.created',
            description: "Registrasi akun baru sebagai {$role}",
            entity: $user,
            request: $request,
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil.',
            'data' => [
                'user' => $user->load('technicianProfile'),
                'token' => $token,
                'token_type' => 'Bearer',
            ],
        ], 201);
    }

    /**
     * Login for all roles (Customer, Technician, Admin).
     */
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'identifier' => ['required', 'string'], // email or phone
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $validated['identifier'])
            ->orWhere('phone', $validated['identifier'])
            ->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            ActivityLog::logEvent(
                eventName: 'auth.login.failed',
                description: 'Percobaan login gagal untuk identifier: '.self::maskIdentifier($validated['identifier']),
                status: 'failed',
                request: $request
            );

            throw ValidationException::withMessages([
                'identifier' => ['Email/Nomor telepon atau kata sandi tidak sesuai.'],
            ]);
        }

        if (! $user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Akun dinonaktifkan. Silakan hubungi admin.',
            ], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        ActivityLog::logEvent(
            eventName: 'auth.login.success',
            description: "Login berhasil sebagai {$user->role}",
            entity: $user,
            request: $request,
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'data' => [
                'user' => $user->load('technicianProfile'),
                'token' => $token,
                'token_type' => 'Bearer',
            ],
        ]);
    }

    /**
     * Get current user profile.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load('technicianProfile');

        return response()->json([
            'success' => true,
            'data' => $user,
        ]);
    }

    /**
     * Update current user profile.
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'phone' => ['sometimes', 'string', 'max:20', Rule::unique('users', 'phone')->ignore($user->id)],
            'avatar_url' => ['nullable', 'string'],
            'address' => ['nullable', 'string'],
            // Technician specific
            'bio' => ['nullable', 'string'],
            'years_of_experience' => ['nullable', 'integer', 'min:0'],
            'skills' => ['nullable', 'array'],
            'is_available' => ['sometimes', 'boolean'],
            'current_latitude' => ['nullable', 'numeric'],
            'current_longitude' => ['nullable', 'numeric'],
        ]);

        $oldValues = $user->only(['name', 'phone', 'avatar_url', 'address']);

        $user->update([
            'name' => $validated['name'] ?? $user->name,
            'phone' => $validated['phone'] ?? $user->phone,
            'avatar_url' => $validated['avatar_url'] ?? $user->avatar_url,
            'address' => $validated['address'] ?? $user->address,
        ]);

        if ($user->isTechnician() && $user->technicianProfile) {
            $techData = [];
            if (isset($validated['bio'])) {
                $techData['bio'] = $validated['bio'];
            }
            if (isset($validated['years_of_experience'])) {
                $techData['years_of_experience'] = $validated['years_of_experience'];
            }
            if (isset($validated['skills'])) {
                $techData['skills'] = $validated['skills'];
            }
            if (isset($validated['is_available'])) {
                $techData['is_available'] = $validated['is_available'];
            }
            if (isset($validated['current_latitude'])) {
                $techData['current_latitude'] = $validated['current_latitude'];
                $techData['current_longitude'] = $validated['current_longitude'] ?? $user->technicianProfile->current_longitude;
                $techData['last_location_updated_at'] = now();
            }

            if (! empty($techData)) {
                $user->technicianProfile->update($techData);
            }
        }

        ActivityLog::logEvent(
            eventName: 'user.profile.updated',
            description: 'Pembaruan data profil pengguna',
            entity: $user,
            oldValues: $oldValues,
            newValues: $user->only(['name', 'phone', 'avatar_url', 'address']),
            request: $request,
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui.',
            'data' => $user->fresh('technicianProfile'),
        ]);
    }

    /**
     * Change password.
     */
    public function changePassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'current_password' => ['required', 'string'],
            'new_password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $user = $request->user();

        if (! Hash::check($validated['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['Kata sandi saat ini tidak cocok.'],
            ]);
        }

        $user->update([
            'password' => Hash::make($validated['new_password']),
        ]);

        ActivityLog::logEvent(
            eventName: 'auth.password.changed',
            description: 'Penggantian kata sandi berhasil',
            entity: $user,
            request: $request,
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi berhasil diubah.',
        ]);
    }

    /**
     * Logout and invalidate token.
     */
    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();

        ActivityLog::logEvent(
            eventName: 'auth.logout',
            description: 'User logout dari sesi',
            entity: $user,
            request: $request,
            actor: $user
        );

        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil.',
        ]);
    }

    /**
     * Request password reset token / code for mobile user.
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'string', 'email'],
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Alamat email tidak terdaftar.',
            ], 422);
        }

        if ($user->role === 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Akun Admin hanya dapat mereset kata sandi melalui Web Admin.',
            ], 403);
        }

        // The token is sent through the configured mail channel and never returned
        // in an API response or persisted in plaintext.
        $token = str_pad((string) random_int(100000, 999999), 6, '0', STR_PAD_LEFT);

        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $user->email],
            [
                'token' => Hash::make($token),
                'created_at' => now(),
            ]
        );

        Mail::raw(
            "Kode verifikasi reset kata sandi Anda: {$token}\nKode berlaku selama satu jam.",
            function ($message) use ($user): void {
                $message->to($user->email)
                    ->subject('Kode reset kata sandi KlikKompor');
            }
        );

        ActivityLog::logEvent(
            eventName: 'auth.password.forgot',
            description: 'Permintaan reset kata sandi diajukan',
            entity: $user,
            request: $request
        );

        return response()->json([
            'success' => true,
            'message' => 'Jika akun dengan alamat tersebut tersedia, kode verifikasi telah dikirimkan melalui kanal pemulihan yang dikonfigurasi.',
        ]);
    }

    /**
     * Reset password using token / code.
     */
    public function resetPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'string', 'email', 'exists:users,email'],
            'token' => ['required', 'string'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (!$user || $user->role === 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Akun tidak valid untuk reset kata sandi.',
            ], 403);
        }

        $resetRecord = DB::table('password_reset_tokens')
            ->where('email', $validated['email'])
            ->first();

        if (!$resetRecord) {
            return response()->json([
                'success' => false,
                'message' => 'Permintaan reset kata sandi tidak ditemukan atau sudah kadaluarsa.',
            ], 422);
        }

        $expiresAt = \Illuminate\Support\Carbon::parse($resetRecord->created_at)
            ->addSeconds((int) config('auth.passwords.users.expire', 3600));

        if ($expiresAt->isPast()) {
            DB::table('password_reset_tokens')->where('email', $user->email)->delete();

            return response()->json([
                'success' => false,
                'message' => 'Kode reset kata sandi sudah kadaluarsa.',
            ], 422);
        }

        $tokenValid = Hash::check($validated['token'], $resetRecord->token);

        if (!$tokenValid) {
            return response()->json([
                'success' => false,
                'message' => 'Kode reset kata sandi tidak valid.',
            ], 422);
        }

        $user->update([
            'password' => Hash::make($validated['password']),
        ]);

        DB::table('password_reset_tokens')->where('email', $user->email)->delete();

        ActivityLog::logEvent(
            eventName: 'auth.password.reset',
            description: 'Reset kata sandi berhasil',
            entity: $user,
            request: $request,
            actor: $user
        );

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi berhasil diatur ulang. Silakan login kembali.',
        ]);
    }

    private static function maskIdentifier(string $identifier): string
    {
        $identifier = trim($identifier);

        if (filter_var($identifier, FILTER_VALIDATE_EMAIL)) {
            [$local, $domain] = explode('@', $identifier, 2);

            return substr($local, 0, 1).'***@'.$domain;
        }

        return strlen($identifier) <= 4
            ? '***'
            : substr($identifier, 0, 2).'***'.substr($identifier, -2);
    }
}
