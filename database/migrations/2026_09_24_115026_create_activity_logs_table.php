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
        Schema::create('activity_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('actor_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('actor_role', 20)->default('system')->index(); // customer, technician, admin, system
            $table->string('event_name', 100)->index(); // 18 mandatory audit events
            $table->text('description')->nullable();
            $table->string('entity_type', 60)->nullable()->index();
            $table->unsignedBigInteger('entity_id')->nullable()->index();
            $table->string('ip_address', 45);
            $table->text('user_agent')->nullable();
            $table->string('platform', 30)->default('api'); // ios, android, web_admin, api
            $table->json('old_values')->nullable();
            $table->json('new_values')->nullable();
            $table->string('status', 20)->default('success'); // success, failed
            $table->timestamp('created_at')->useCurrent()->index();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('activity_logs');
    }
};
