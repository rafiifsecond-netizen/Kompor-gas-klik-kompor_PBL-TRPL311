<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\TechnicianProfile;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
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
                description: 'Percobaan login gagal untuk identifier: '.$validated['identifier'],
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
}
