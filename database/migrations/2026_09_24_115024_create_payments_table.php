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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->cascadeOnDelete();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->string('payment_number', 50)->unique();
            $table->string('payment_method', 30)->default('cash'); // cash, qris, transfer
            $table->decimal('amount', 12, 2);
            $table->string('payment_status', 30)->default('pending')->index(); // pending, paid, failed, refunded
            $table->timestamp('paid_at')->nullable();
            $table->string('proof_url')->nullable();
            $table->string('transaction_reference', 100)->nullable();
            $table->json('payload')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
