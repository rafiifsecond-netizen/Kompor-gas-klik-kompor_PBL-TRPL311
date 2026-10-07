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
        Schema::create('service_categories', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100);
            $table->string('slug', 100)->unique();
            $table->text('description')->nullable();
            $table->string('icon', 100)->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('service_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_category_id')->constrained()->cascadeOnDelete();
            $table->string('name', 150);
            $table->string('slug', 150)->unique();
            $table->text('description')->nullable();
            $table->unsignedInteger('estimated_minutes')->default(60);
            $table->decimal('base_price', 12, 2)->default(0); // Acuan tarif dari admin
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();
        });

        Schema::create('technician_services', function (Blueprint $table) {
            $table->id();
            $table->foreignId('technician_profile_id')->constrained()->cascadeOnDelete();
            $table->foreignId('service_item_id')->constrained()->cascadeOnDelete();
            $table->decimal('custom_price', 12, 2)->nullable();
            $table->boolean('is_offered')->default(true);
            $table->timestamps();

            $table->unique(['technician_profile_id', 'service_item_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('technician_services');
        Schema::dropIfExists('service_items');
        Schema::dropIfExists('service_categories');
    }
};
