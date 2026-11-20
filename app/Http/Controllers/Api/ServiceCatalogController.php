<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\ServiceCategory;
use App\Models\ServiceItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ServiceCatalogController extends Controller
{
    /**
     * Get all active categories with their services.
     */
    public function categories(): JsonResponse
    {
        $categories = ServiceCategory::with(['items' => function ($query) {
            $query->where('is_active', true)->orderBy('base_price', 'asc');
        }])
            ->where('is_active', true)
            ->orderBy('sort_order', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $categories,
        ]);
    }

    /**
     * Get all active service items (Fitur 5: Informasi Tarif Service).
     */
    public function services(Request $request): JsonResponse
    {
        $query = ServiceItem::with('category')->where('is_active', true);

        if ($request->has('category_id')) {
            $query->where('service_category_id', $request->query('category_id'));
        }

        if ($request->has('search')) {
            $search = $request->query('search');
            $query->where('name', 'like', "%{$search}%");
        }

        $services = $query->orderBy('base_price', 'asc')->get();

        return response()->json([
            'success' => true,
            'data' => $services,
        ]);
    }

    /**
     * Create service item (Admin only - F017).
     */
    public function storeServiceItem(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'service_category_id' => ['required', 'exists:service_categories,id'],
            'name' => ['required', 'string', 'max:150'],
            'description' => ['required', 'string'],
            'estimated_minutes' => ['nullable', 'integer', 'min:15'],
            'base_price' => ['required', 'numeric', 'min:1'],
            'image' => ['nullable', 'image', 'mimes:jpeg,png,jpg,webp', 'max:2048'],
        ]);

        $imageUrl = null;
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('services', 'public');
            $imageUrl = '/storage/'.$path;
        }

        $item = ServiceItem::create([
            'service_category_id' => $validated['service_category_id'],
            'name' => $validated['name'],
            'slug' => Str::slug($validated['name']).'-'.Str::random(5),
            'description' => $validated['description'],
            'image_url' => $imageUrl,
            'estimated_minutes' => $validated['estimated_minutes'] ?? 60,
            'base_price' => $validated['base_price'],
            'is_active' => true,
        ]);

        ActivityLog::logEvent(
            eventName: 'service_catalog.created',
            description: "Admin menambahkan layanan baru: {$item->name}",
            entity: $item,
            newValues: $item->toArray(),
            request: $request
        );

        return response()->json([
            'success' => true,
            'message' => 'Layanan berhasil ditambahkan.',
            'data' => $item->load('category'),
        ], 201);
    }

    /**
     * Update service item details (Admin only - F017).
     */
    public function updateServiceItem(Request $request, int $id): JsonResponse
    {
        $item = ServiceItem::findOrFail($id);

        $validated = $request->validate([
            'service_category_id' => ['sometimes', 'required', 'exists:service_categories,id'],
            'name' => ['sometimes', 'required', 'string', 'max:150'],
            'description' => ['sometimes', 'required', 'string'],
            'estimated_minutes' => ['nullable', 'integer', 'min:15'],
            'base_price' => ['sometimes', 'required', 'numeric', 'min:1'],
            'is_active' => ['nullable', 'boolean'],
            'image' => ['nullable', 'image', 'mimes:jpeg,png,jpg,webp', 'max:2048'],
        ]);

        $oldValues = $item->toArray();

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('services', 'public');
            $item->image_url = '/storage/'.$path;
        }

        if (isset($validated['name'])) {
            $item->name = $validated['name'];
        }
        if (isset($validated['description'])) {
            $item->description = $validated['description'];
        }
        if (isset($validated['service_category_id'])) {
            $item->service_category_id = $validated['service_category_id'];
        }
        if (isset($validated['estimated_minutes'])) {
            $item->estimated_minutes = $validated['estimated_minutes'];
        }
        if (isset($validated['base_price'])) {
            $item->base_price = $validated['base_price'];
        }
        if (isset($validated['is_active'])) {
            $item->is_active = (bool) $validated['is_active'];
        }

        $item->save();

        ActivityLog::logEvent(
            eventName: 'service_catalog.updated',
            description: "Admin memperbarui layanan: {$item->name}",
            entity: $item,
            oldValues: $oldValues,
            newValues: $item->toArray(),
            request: $request
        );

        return response()->json([
            'success' => true,
            'message' => 'Layanan berhasil diperbarui.',
            'data' => $item->load('category'),
        ]);
    }

    /**
     * Toggle active status of service (Admin only - F017).
     */
    public function toggleActive(Request $request, int $id): JsonResponse
    {
        $item = ServiceItem::findOrFail($id);
        $item->is_active = ! $item->is_active;
        $item->save();

        ActivityLog::logEvent(
            eventName: 'service_catalog.status_toggled',
            description: "Admin mengubah status aktif layanan {$item->name} menjadi: ".($item->is_active ? 'Aktif' : 'Nonaktif'),
            entity: $item,
            newValues: ['is_active' => $item->is_active],
            request: $request
        );

        return response()->json([
            'success' => true,
            'message' => 'Status layanan berhasil diubah.',
            'data' => $item,
        ]);
    }

    /**
     * Delete service item safely (Admin only - F017).
     */
    public function destroyServiceItem(Request $request, int $id): JsonResponse
    {
        $item = ServiceItem::findOrFail($id);

        // Periksa apakah layanan pernah digunakan dalam transaksi pesanan
        $isUsedInOrders = \App\Models\OrderItem::where('service_item_id', $id)->exists();

        if ($isUsedInOrders) {
            // Soft delete & nonaktifkan agar data transaksi lama tidak rusak
            $item->update(['is_active' => false]);
            $item->delete();

            ActivityLog::logEvent(
                eventName: 'service_catalog.soft_deleted',
                description: "Admin menonaktifkan & mengarsipkan (soft delete) layanan: {$item->name} karena memiliki riwayat transaksi.",
                entity: $item,
                request: $request
            );

            return response()->json([
                'success' => true,
                'message' => 'Layanan telah diarsipkan (soft delete) karena memiliki riwayat transaksi.',
            ]);
        }

        $item->forceDelete();

        ActivityLog::logEvent(
            eventName: 'service_catalog.deleted',
            description: "Admin menghapus layanan: {$item->name}",
            entity: $item,
            request: $request
        );

        return response()->json([
            'success' => true,
            'message' => 'Layanan berhasil dihapus permanen.',
        ]);
    }

    /**
     * Update service tariff (Admin only - 18 Mandatory Audit Events #13).
     */
    public function updateTariff(Request $request, int $id): JsonResponse
    {
        $item = ServiceItem::findOrFail($id);

        $validated = $request->validate([
            'base_price' => ['required', 'numeric', 'min:1'],
        ]);

        $oldPrice = $item->base_price;
        $item->update(['base_price' => $validated['base_price']]);

        ActivityLog::logEvent(
            eventName: 'service_tariff.updated',
            description: "Perubahan tarif untuk layanan: {$item->name} dari Rp ".number_format($oldPrice, 0, ',', '.').' ke Rp '.number_format($item->base_price, 0, ',', '.'),
            entity: $item,
            oldValues: ['base_price' => $oldPrice],
            newValues: ['base_price' => $item->base_price],
            request: $request
        );

        return response()->json([
            'success' => true,
            'message' => 'Tarif layanan berhasil diperbarui.',
            'data' => $item,
        ]);
    }
}
