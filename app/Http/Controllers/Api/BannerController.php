<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\Banner;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class BannerController extends Controller
{
    /**
     * Get active banners for mobile/public dashboard (Bagian A - F003).
     */
    public function index(Request $request): JsonResponse
    {
        $banners = Banner::active()->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar banner dashboard berhasil diambil.',
            'data' => $banners,
        ]);
    }

    /**
     * Get all banners for Admin with sorting & filtering.
     */
    public function adminIndex(Request $request): JsonResponse
    {
        $query = Banner::query();

        if ($request->has('is_active')) {
            $query->where('is_active', filter_var($request->query('is_active'), FILTER_VALIDATE_BOOLEAN));
        }

        $banners = $query->orderBy('sort_order', 'asc')
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $banners,
        ]);
    }

    /**
     * Store new banner (Admin only).
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string'],
            'image' => ['required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:3072'],
            'badge_text' => ['nullable', 'string', 'max:50'],
            'link_url' => ['nullable', 'string', 'max:255'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date', 'after_or_equal:start_date'],
        ]);

        $path = $request->file('image')->store('banners', 'public');
        $imageUrl = '/storage/'.$path;

        $banner = Banner::create([
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'image_url' => $imageUrl,
            'badge_text' => $validated['badge_text'] ?? null,
            'link_url' => $validated['link_url'] ?? null,
            'sort_order' => $validated['sort_order'] ?? 0,
            'is_active' => isset($validated['is_active']) ? (bool) $validated['is_active'] : true,
            'start_date' => $validated['start_date'] ?? null,
            'end_date' => $validated['end_date'] ?? null,
            'created_by' => $request->user()?->id,
        ]);

        ActivityLog::logEvent(
            eventName: 'banner.created',
            description: "Admin menambahkan banner dashboard: {$banner->title}",
            entity: $banner,
            newValues: $banner->toArray(),
            request: $request
        );

        return response()->json([
            'success' => true,
            'message' => 'Banner berhasil ditambahkan.',
            'data' => $banner,
        ], 201);
    }

    /**
     * Update banner details and optionally replace image (Admin only).
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $banner = Banner::findOrFail($id);

        $validated = $request->validate([
            'title' => ['sometimes', 'required', 'string', 'max:150'],
            'description' => ['nullable', 'string'],
            'image' => ['nullable', 'image', 'mimes:jpeg,png,jpg,webp', 'max:3072'],
            'badge_text' => ['nullable', 'string', 'max:50'],
            'link_url' => ['nullable', 'string', 'max:255'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date'],
        ]);

        $oldValues = $banner->toArray();

        // Check if new image is uploaded
        if ($request->hasFile('image')) {
            // Delete old file if stored in public storage
            self::deleteStorageFile($banner->image_url);

            $path = $request->file('image')->store('banners', 'public');
            $banner->image_url = '/storage/'.$path;
        }

        if (isset($validated['title'])) {
            $banner->title = $validated['title'];
        }
        if (array_key_exists('description', $validated)) {
            $banner->description = $validated['description'];
        }
        if (array_key_exists('badge_text', $validated)) {
            $banner->badge_text = $validated['badge_text'];
        }
        if (array_key_exists('link_url', $validated)) {
            $banner->link_url = $validated['link_url'];
        }
        if (isset($validated['sort_order'])) {
            $banner->sort_order = (int) $validated['sort_order'];
        }
        if (isset($validated['is_active'])) {
            $banner->is_active = (bool) $validated['is_active'];
        }
        if (array_key_exists('start_date', $validated)) {
            $banner->start_date = $validated['start_date'];
        }
        if (array_key_exists('end_date', $validated)) {
            $banner->end_date = $validated['end_date'];
        }

        $banner->save();

        ActivityLog::logEvent(
            eventName: 'banner.updated',
            description: "Admin memperbarui banner dashboard: {$banner->title}",
            entity: $banner,
            oldValues: $oldValues,
            newValues: $banner->toArray(),
            request: $request
        );

        return response()->json([
            'success' => true,
            'message' => 'Banner berhasil diperbarui.',
            'data' => $banner,
        ]);
    }

    /**
     * Toggle active/inactive status (Admin only).
     */
    public function toggleActive(Request $request, int $id): JsonResponse
    {
        $banner = Banner::findOrFail($id);
        $oldState = $banner->is_active;
        $banner->is_active = ! $oldState;
        $banner->save();

        ActivityLog::logEvent(
            eventName: 'banner.toggled',
            description: "Admin mengubah status banner {$banner->title} menjadi: ".($banner->is_active ? 'Aktif' : 'Nonaktif'),
            entity: $banner,
            oldValues: ['is_active' => $oldState],
            newValues: ['is_active' => $banner->is_active],
            request: $request
        );

        return response()->json([
            'success' => true,
            'message' => 'Status banner berhasil diubah.',
            'data' => $banner,
        ]);
    }

    /**
     * Delete banner and safe-remove image from storage (Admin only).
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $banner = Banner::findOrFail($id);

        self::deleteStorageFile($banner->image_url);

        ActivityLog::logEvent(
            eventName: 'banner.deleted',
            description: "Admin menghapus banner: {$banner->title}",
            entity: $banner,
            oldValues: $banner->toArray(),
            request: $request
        );

        $banner->delete();

        return response()->json([
            'success' => true,
            'message' => 'Banner berhasil dihapus.',
        ]);
    }

    /**
     * Helper to safely remove file from public storage disk.
     */
    public static function deleteStorageFile(?string $url): void
    {
        if (empty($url)) {
            return;
        }

        if (str_starts_with($url, '/storage/')) {
            $relative = str_replace('/storage/', '', $url);
            if (Storage::disk('public')->exists($relative)) {
                Storage::disk('public')->delete($relative);
            }
        }
    }
}
