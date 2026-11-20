<?php

use App\Models\PlatformSetting;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            if (! Schema::hasColumn('orders', 'technician_latitude')) {
                $table->decimal('technician_latitude', 10, 7)->nullable()->after('longitude');
            }
            if (! Schema::hasColumn('orders', 'technician_longitude')) {
                $table->decimal('technician_longitude', 10, 7)->nullable()->after('technician_latitude');
            }
            if (! Schema::hasColumn('orders', 'travel_distance_km')) {
                $table->decimal('travel_distance_km', 10, 3)->nullable()->after('transport_fee');
            }
            if (! Schema::hasColumn('orders', 'travel_duration_minutes')) {
                $table->unsignedInteger('travel_duration_minutes')->nullable()->after('travel_distance_km');
            }
            if (! Schema::hasColumn('orders', 'travel_fee_source')) {
                $table->string('travel_fee_source', 30)->nullable()->after('travel_duration_minutes');
            }
        });

        $settings = [
            ['travel_base_fee', '15000', 'Biaya dasar kunjungan'],
            ['travel_free_km', '2', 'Jarak perjalanan gratis dalam kilometer'],
            ['travel_rate_per_km', '0', 'Tarif per kilometer setelah jarak gratis'],
            ['travel_rounding_mode', 'ceil', 'Aturan pembulatan jarak (ceil, round, floor)'],
            ['travel_rounding_unit_km', '1', 'Satuan pembulatan jarak dalam kilometer'],
        ];

        foreach ($settings as [$key, $value, $description]) {
            PlatformSetting::set($key, $value, null, $description);
        }
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            foreach ([
                'technician_latitude',
                'technician_longitude',
                'travel_distance_km',
                'travel_duration_minutes',
                'travel_fee_source',
            ] as $column) {
                if (Schema::hasColumn('orders', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
