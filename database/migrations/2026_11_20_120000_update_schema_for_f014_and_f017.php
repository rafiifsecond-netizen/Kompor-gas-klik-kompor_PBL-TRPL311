<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            if (! Schema::hasColumn('orders', 'arrived_at')) {
                $table->timestamp('arrived_at')->nullable()->after('scheduled_at');
            }
            if (! Schema::hasColumn('orders', 'started_at')) {
                $table->timestamp('started_at')->nullable()->after('arrived_at');
            }
        });

        Schema::table('service_items', function (Blueprint $table) {
            if (! Schema::hasColumn('service_items', 'image_url')) {
                $table->string('image_url', 255)->nullable()->after('description');
            }
            if (! Schema::hasColumn('service_items', 'deleted_at')) {
                $table->softDeletes()->after('is_active');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            if (Schema::hasColumn('orders', 'arrived_at')) {
                $table->dropColumn('arrived_at');
            }
            if (Schema::hasColumn('orders', 'started_at')) {
                $table->dropColumn('started_at');
            }
        });

        Schema::table('service_items', function (Blueprint $table) {
            if (Schema::hasColumn('service_items', 'image_url')) {
                $table->dropColumn('image_url');
            }
            if (Schema::hasColumn('service_items', 'deleted_at')) {
                $table->dropSoftDeletes();
            }
        });
    }
};
