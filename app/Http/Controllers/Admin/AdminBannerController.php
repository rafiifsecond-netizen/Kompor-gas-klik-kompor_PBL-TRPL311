<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Controller;
use App\Models\Banner;
use App\Models\Order;
use App\Models\TechnicianProfile;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminBannerController extends Controller
{
    /**
     * Display Dashboard Management page (Web Admin - Bagian A).
     */
    public function index(Request $request): View
    {
        $banners = Banner::orderBy('sort_order', 'asc')
            ->orderBy('created_at', 'desc')
            ->paginate(12);

        $stats = [
            'total_users' => User::where('role', 'customer')->count(),
            'total_technicians' => TechnicianProfile::count(),
            'today_orders' => Order::whereDate('created_at', today())->count(),
            'completed_orders' => Order::where('status', Order::STATUS_COMPLETED)->count(),
            'total_banners' => Banner::count(),
            'active_banners' => Banner::where('is_active', true)->count(),
        ];

        return view('admin.dashboard_management', compact('banners', 'stats'));
    }

    /**
     * Store new banner from Web Admin form.
     */
    public function store(Request $request): RedirectResponse
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
            'end_date' => ['nullable', 'date'],
        ]);

        $path = $request->file('image')->store('banners', 'public');
        $imageUrl = '/storage/'.$path;

        Banner::create([
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'image_url' => $imageUrl,
            'badge_text' => $validated['badge_text'] ?? null,
            'link_url' => $validated['link_url'] ?? null,
            'sort_order' => $validated['sort_order'] ?? 0,
            'is_active' => $request->has('is_active'),
            'start_date' => $validated['start_date'] ?? null,
            'end_date' => $validated['end_date'] ?? null,
            'created_by' => auth()->id(),
        ]);

        return redirect()->route('admin.dashboard_management')
            ->with('success', 'Banner dashboard berhasil ditambahkan.');
    }

    /**
     * Update banner details from Web Admin modal.
     */
    public function update(Request $request, int $id): RedirectResponse
    {
        $banner = Banner::findOrFail($id);

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string'],
            'image' => ['nullable', 'image', 'mimes:jpeg,png,jpg,webp', 'max:3072'],
            'badge_text' => ['nullable', 'string', 'max:50'],
            'link_url' => ['nullable', 'string', 'max:255'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date'],
        ]);

        if ($request->hasFile('image')) {
            BannerController::deleteStorageFile($banner->image_url);
            $path = $request->file('image')->store('banners', 'public');
            $banner->image_url = '/storage/'.$path;
        }

        $banner->title = $validated['title'];
        $banner->description = $validated['description'] ?? null;
        $banner->badge_text = $validated['badge_text'] ?? null;
        $banner->link_url = $validated['link_url'] ?? null;
        $banner->sort_order = $validated['sort_order'] ?? 0;
        $banner->is_active = $request->has('is_active');
        $banner->start_date = $validated['start_date'] ?? null;
        $banner->end_date = $validated['end_date'] ?? null;
        $banner->save();

        return redirect()->route('admin.dashboard_management')
            ->with('success', 'Banner dashboard berhasil diperbarui.');
    }

    /**
     * Toggle active/inactive state of a banner.
     */
    public function toggleActive(int $id): RedirectResponse
    {
        $banner = Banner::findOrFail($id);
        $banner->is_active = ! $banner->is_active;
        $banner->save();

        $statusStr = $banner->is_active ? 'diaktifkan' : 'dinonaktifkan';

        return redirect()->route('admin.dashboard_management')
            ->with('success', "Banner '{$banner->title}' berhasil {$statusStr}.");
    }

    /**
     * Delete banner and safe cleanup image file.
     */
    public function destroy(int $id): RedirectResponse
    {
        $banner = Banner::findOrFail($id);
        BannerController::deleteStorageFile($banner->image_url);
        $banner->delete();

        return redirect()->route('admin.dashboard_management')
            ->with('success', 'Banner dashboard berhasil dihapus.');
    }
}
