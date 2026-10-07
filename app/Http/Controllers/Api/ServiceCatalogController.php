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
     * Create or update service item (Admin only).
     */
    public function storeServiceItem(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'service_category_id' => ['required', 'exists:service_categories,id'],
            'name' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string'],
            'estimated_minutes' => ['required', 'integer', 'min:15'],
            'base_price' => ['required', 'numeric', 'min:0'],
        ]);

        $item = ServiceItem::create([
            'service_category_id' => $validated['service_category_id'],
            'name' => $validated['name'],
            'slug' => Str::slug($validated['name']).'-'.Str::random(5),
            'description' => $validated['description'] ?? null,
            'estimated_minutes' => $validated['estimated_minutes'],
            'base_price' => $validated['base_price'],
            'is_active' => true,
        ]);

        ActivityLog::logEvent(
            eventName: 'service_catalog.modified',
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
     * Update service tariff (Admin only - 18 Mandatory Audit Events #13).
     */
    public function updateTariff(Request $request, int $id): JsonResponse
    {
        $item = ServiceItem::findOrFail($id);

        $validated = $request->validate([
            'base_price' => ['required', 'numeric', 'min:0'],
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
