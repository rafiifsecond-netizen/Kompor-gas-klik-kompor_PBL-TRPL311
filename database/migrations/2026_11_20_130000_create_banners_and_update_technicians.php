<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Create banners table
        if (! Schema::hasTable('banners')) {
            Schema::create('banners', function (Blueprint $table) {
                $table->id();
                $table->string('title', 150);
                $table->text('description')->nullable();
                $table->string('image_url', 255);
                $table->string('link_url', 255)->nullable();
                $table->string('badge_text', 50)->nullable();
                $table->integer('sort_order')->default(0);
                $table->boolean('is_active')->default(true);
                $table->dateTime('start_date')->nullable();
                $table->dateTime('end_date')->nullable();
                $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
                $table->timestamps();
            });
        }

        // 2. Add status & rejection_reason to technician_profiles
        if (Schema::hasTable('technician_profiles')) {
            Schema::table('technician_profiles', function (Blueprint $table) {
                if (! Schema::hasColumn('technician_profiles', 'status')) {
                    $table->string('status', 20)->default('pending')->after('is_verified');
                }
                if (! Schema::hasColumn('technician_profiles', 'rejection_reason')) {
                    $table->text('rejection_reason')->nullable()->after('status');
                }
            });

            // Synchronize status for existing records: verified technicians are approved
            DB::table('technician_profiles')
                ->where('is_verified', true)
                ->update(['status' => 'approved']);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('banners');

        if (Schema::hasTable('technician_profiles')) {
            Schema::table('technician_profiles', function (Blueprint $table) {
                if (Schema::hasColumn('technician_profiles', 'rejection_reason')) {
                    $table->dropColumn('rejection_reason');
                }
                if (Schema::hasColumn('technician_profiles', 'status')) {
                    $table->dropColumn('status');
                }
            });
        }
    }
};
