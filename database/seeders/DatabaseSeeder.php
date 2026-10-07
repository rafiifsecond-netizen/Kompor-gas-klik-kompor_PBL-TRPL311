<?php

namespace Database\Seeders;

use App\Models\ActivityLog;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Payment;
use App\Models\Review;
use App\Models\ServiceCategory;
use App\Models\ServiceItem;
use App\Models\TechnicianProfile;
use App\Models\TechnicianService;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Create Admin
        $admin = User::create([
            'name' => 'Admin KlikKompor',
            'email' => 'admin@klikkompor.com',
            'phone' => '081100000001',
            'role' => 'admin',
            'password' => Hash::make('password123'),
            'is_active' => true,
        ]);

        ActivityLog::logEvent(
            eventName: 'user.account.created',
            description: 'Inisialisasi akun Super Admin sistem',
            entity: $admin,
            actor: $admin
        );

        // 2. Create Service Categories & Items
        $cat1 = ServiceCategory::create([
            'name' => 'Kompor Gas Standar (1-2 Tungku)',
            'slug' => 'kompor-gas-standar',
            'description' => 'Perbaikan dan perawatan kompor gas portabel atau meja (Rinnai, Quantum, Miyako, dll)',
            'icon' => 'flame',
            'sort_order' => 1,
        ]);

        $item1_1 = ServiceItem::create([
            'service_category_id' => $cat1->id,
            'name' => 'Servis Ringan & Pembersihan Spuyer',
            'slug' => 'servis-ringan-pembersihan-spuyer',
            'description' => 'Membersihkan spuyer buntu, kalibrasi aliran gas, dan pembersihan kerak api merah.',
            'estimated_minutes' => 45,
            'base_price' => 75000,
        ]);

        $item1_2 = ServiceItem::create([
            'service_category_id' => $cat1->id,
            'name' => 'Ganti Pemantik Elektrik / Mekanik',
            'slug' => 'ganti-pemantik-mekanik',
            'description' => 'Penggantian modul pemantik atau knob mekanik yang patah/macet.',
            'estimated_minutes' => 60,
            'base_price' => 95000,
        ]);

        $cat2 = ServiceCategory::create([
            'name' => 'Kompor Tanam (Built-in Hob)',
            'slug' => 'kompor-tanam-builtin-hob',
            'description' => 'Servis kompor gas tanam premium (Modena, Electrolux, Ariston, Bosch, Teka)',
            'icon' => 'layout-grid',
            'sort_order' => 2,
        ]);

        $item2_1 = ServiceItem::create([
            'service_category_id' => $cat2->id,
            'name' => 'Servis Kompor Tanam (Api Merah / Mati)',
            'slug' => 'servis-kompor-tanam-api-merah',
            'description' => 'Pembersihan saluran udara, kalibrasi thermocouple pengaman gas, perbaikan burner api.',
            'estimated_minutes' => 75,
            'base_price' => 135000,
        ]);

        $item2_2 = ServiceItem::create([
            'service_category_id' => $cat2->id,
            'name' => 'Perbaikan Kebocoran Gas & Pipa Tanam',
            'slug' => 'perbaikan-kebocoran-gas-kompor-tanam',
            'description' => 'Pemeriksaan kebocoran dengan gas detector, penggantian seal gasket tahan panas, pengencangan clamp.',
            'estimated_minutes' => 90,
            'base_price' => 175000,
        ]);

        $cat3 = ServiceCategory::create([
            'name' => 'Freestanding Cooker (Kompor + Oven Gas)',
            'slug' => 'freestanding-cooker',
            'description' => 'Perawatan kompor berdiri dengan oven terintegrasi untuk dapur rumah & resto.',
            'icon' => 'server',
            'sort_order' => 3,
        ]);

        $item3_1 = ServiceItem::create([
            'service_category_id' => $cat3->id,
            'name' => 'Servis Total Tungku & Oven Gas',
            'slug' => 'servis-total-tungku-oven-gas',
            'description' => 'Servis api oven atas-bawah, pembersihan burner 4-5 tungku, cek sirkulasi pengapian.',
            'estimated_minutes' => 120,
            'base_price' => 250000,
        ]);

        // 3. Create Technicians
        $techUser1 = User::create([
            'name' => 'Agus Priyanto',
            'email' => 'agus.teknisi@klikkompor.com',
            'phone' => '081234567890',
            'role' => 'technician',
            'password' => Hash::make('password123'),
            'address' => 'Jl. Tebet Timur Dalam No. 14, Jakarta Selatan',
            'is_active' => true,
        ]);

        $techProfile1 = TechnicianProfile::create([
            'user_id' => $techUser1->id,
            'bio' => 'Spesialis kompor gas tanam Modena, Rinnai, dan Electrolux. Berpengalaman lebih dari 8 tahun.',
            'years_of_experience' => 8,
            'skills' => ['Kompor Gas Tanam', 'Freestanding Cooker', 'Ganti Pemantik', 'Uji Kebocoran Gas'],
            'ktp_number' => '3174012345670001',
            'is_verified' => true,
            'verified_at' => now(),
            'verified_by' => $admin->id,
            'is_available' => true,
            'current_latitude' => -6.2297280,
            'current_longitude' => 106.8558500,
            'last_location_updated_at' => now(),
            'rating_avg' => 4.90,
            'reviews_count' => 48,
            'jobs_completed_count' => 52,
        ]);

        // Link services to technician 1
        TechnicianService::create([
            'technician_profile_id' => $techProfile1->id,
            'service_item_id' => $item1_1->id,
            'custom_price' => 75000,
        ]);
        TechnicianService::create([
            'technician_profile_id' => $techProfile1->id,
            'service_item_id' => $item2_1->id,
            'custom_price' => 135000,
        ]);
        TechnicianService::create([
            'technician_profile_id' => $techProfile1->id,
            'service_item_id' => $item2_2->id,
            'custom_price' => 175000,
        ]);

        $techUser2 = User::create([
            'name' => 'Bambang Sugiarto',
            'email' => 'bambang.teknisi@klikkompor.com',
            'phone' => '081398765432',
            'role' => 'technician',
            'password' => Hash::make('password123'),
            'address' => 'Jl. Fatmawati Raya No. 45, Jakarta Selatan',
            'is_active' => true,
        ]);

        $techProfile2 = TechnicianProfile::create([
            'user_id' => $techUser2->id,
            'bio' => 'Teknisi handal untuk segala merk kompor gas standar dan freestanding cooker. Cepat dan bergaransi.',
            'years_of_experience' => 5,
            'skills' => ['Kompor Gas Standar', 'Pembersihan Spuyer', 'Freestanding Cooker'],
            'ktp_number' => '3174056789010002',
            'is_verified' => true,
            'verified_at' => now(),
            'verified_by' => $admin->id,
            'is_available' => true,
            'current_latitude' => -6.2905000,
            'current_longitude' => 106.7972000,
            'last_location_updated_at' => now(),
            'rating_avg' => 4.80,
            'reviews_count' => 32,
            'jobs_completed_count' => 35,
        ]);

        TechnicianService::create([
            'technician_profile_id' => $techProfile2->id,
            'service_item_id' => $item1_1->id,
            'custom_price' => 70000,
        ]);
        TechnicianService::create([
            'technician_profile_id' => $techProfile2->id,
            'service_item_id' => $item3_1->id,
            'custom_price' => 240000,
        ]);

        // 4. Create Customers
        $customer1 = User::create([
            'name' => 'Dewi Lestari',
            'email' => 'dewi@example.com',
            'phone' => '087812345678',
            'role' => 'customer',
            'password' => Hash::make('password123'),
            'address' => 'Apartemen Kalibata City Tower Kemuning Lt. 8, Jakarta Selatan',
            'is_active' => true,
        ]);

        $customer2 = User::create([
            'name' => 'Rian Hidayat',
            'email' => 'rian@example.com',
            'phone' => '085799887766',
            'role' => 'customer',
            'password' => Hash::make('password123'),
            'address' => 'Jl. Kemang Timur No. 21, Jakarta Selatan',
            'is_active' => true,
        ]);

        // 5. Create a sample completed order with review
        $order1 = Order::create([
            'order_number' => 'KP-'.date('Ymd').'-0001',
            'customer_id' => $customer1->id,
            'technician_id' => $techUser1->id,
            'status' => Order::STATUS_COMPLETED,
            'scheduled_at' => now()->subDays(1)->setTime(10, 0),
            'customer_name' => $customer1->name,
            'customer_phone' => $customer1->phone,
            'address' => $customer1->address,
            'latitude' => -6.2570000,
            'longitude' => 106.8540000,
            'stove_brand' => 'Modena',
            'stove_type' => 'Kompor Tanam 2 Tungku BH-1725',
            'problem_description' => 'Api sebelah kanan menyala merah dan pemantiknya mati.',
            'subtotal' => 135000,
            'transport_fee' => 20000,
            'discount' => 0,
            'total_amount' => 155000,
            'payment_method' => 'qris',
            'payment_status' => 'paid',
            'completed_at' => now()->subDays(1)->setTime(11, 30),
        ]);

        OrderItem::create([
            'order_id' => $order1->id,
            'service_item_id' => $item2_1->id,
            'service_name' => $item2_1->name,
            'unit_price' => 135000,
            'quantity' => 1,
            'total_price' => 135000,
        ]);

        Payment::create([
            'order_id' => $order1->id,
            'customer_id' => $customer1->id,
            'payment_number' => 'PAY-'.date('Ymd').'-0001',
            'payment_method' => 'qris',
            'amount' => 155000,
            'payment_status' => 'paid',
            'paid_at' => now()->subDays(1)->setTime(11, 35),
            'transaction_reference' => 'QRIS-'.Str::random(12),
        ]);

        Review::create([
            'order_id' => $order1->id,
            'customer_id' => $customer1->id,
            'technician_id' => $techUser1->id,
            'rating' => 5,
            'comment' => 'Pelayanan Pak Agus sangat memuaskan! Kompor tanam Modena saya yang tadinya apinya merah sekarang biru bersih kembali. Datang tepat waktu dan sopan.',
        ]);

        // Sample in-progress order
        $order2 = Order::create([
            'order_number' => 'KP-'.date('Ymd').'-0002',
            'customer_id' => $customer2->id,
            'technician_id' => $techUser2->id,
            'status' => Order::STATUS_ON_THE_WAY,
            'scheduled_at' => now()->addHours(2),
            'customer_name' => $customer2->name,
            'customer_phone' => $customer2->phone,
            'address' => $customer2->address,
            'latitude' => -6.2750000,
            'longitude' => 106.8150000,
            'stove_brand' => 'Rinnai',
            'stove_type' => 'Kompor 2 Tungku RI-522C',
            'problem_description' => 'Spuyer tersumbat sisa masakan dan knob putaran keras.',
            'subtotal' => 70000,
            'transport_fee' => 15000,
            'discount' => 0,
            'total_amount' => 85000,
            'payment_method' => 'cash',
            'payment_status' => 'unpaid',
        ]);

        OrderItem::create([
            'order_id' => $order2->id,
            'service_item_id' => $item1_1->id,
            'service_name' => $item1_1->name,
            'unit_price' => 70000,
            'quantity' => 1,
            'total_price' => 70000,
        ]);
    }
}
