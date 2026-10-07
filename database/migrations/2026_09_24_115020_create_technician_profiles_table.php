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
        Schema::create('technician_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->text('bio')->nullable();
            $table->unsignedInteger('years_of_experience')->default(0);
            $table->json('skills')->nullable(); // e.g. ["Kompor Gas Tanam", "Freestanding Cooker", "Ganti Pemantik", "Instalasi Pipa Gas"]
            $table->string('ktp_number', 30)->nullable();
            $table->string('certificate_url')->nullable();
            $table->boolean('is_verified')->default(false)->index();
            $table->timestamp('verified_at')->nullable();
            $table->foreignId('verified_by')->nullable()->constrained('users')->nullOnDelete();
            $table->boolean('is_available')->default(true)->index(); // Online / Offline toggle
            $table->decimal('current_latitude', 10, 7)->nullable();
            $table->decimal('current_longitude', 10, 7)->nullable();
            $table->timestamp('last_location_updated_at')->nullable();
            $table->decimal('rating_avg', 3, 2)->default(0.00);
            $table->unsignedInteger('reviews_count')->default(0);
            $table->unsignedInteger('jobs_completed_count')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('technician_profiles');
    }
};
