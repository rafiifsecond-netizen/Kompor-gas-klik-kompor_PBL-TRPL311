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
        Schema::table('payments', function (Blueprint $table) {
            if (! Schema::hasColumn('payments', 'transaction_id')) {
                $table->string('transaction_id', 100)->nullable()->after('gateway_transaction_id');
            }
            if (! Schema::hasColumn('payments', 'payment_reference')) {
                $table->string('payment_reference', 100)->nullable()->after('payment_number');
            }
            if (! Schema::hasColumn('payments', 'payment_gateway')) {
                $table->string('payment_gateway', 50)->nullable()->after('gateway_provider');
            }
            if (! Schema::hasColumn('payments', 'expired_at')) {
                $table->timestamp('expired_at')->nullable()->after('expires_at');
            }
            if (! Schema::hasColumn('payments', 'gateway_response')) {
                $table->json('gateway_response')->nullable()->after('payload');
            }
            if (! Schema::hasColumn('payments', 'bank_name')) {
                $table->string('bank_name', 50)->nullable()->after('sender_bank_name');
            }
            if (! Schema::hasColumn('payments', 'va_number')) {
                $table->string('va_number', 50)->nullable()->after('bank_name');
            }
            if (! Schema::hasColumn('payments', 'biller_code')) {
                $table->string('biller_code', 20)->nullable()->after('va_number');
            }
            if (! Schema::hasColumn('payments', 'bill_key')) {
                $table->string('bill_key', 50)->nullable()->after('biller_code');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $cols = [
                'transaction_id',
                'payment_reference',
                'payment_gateway',
                'expired_at',
                'gateway_response',
                'bank_name',
                'va_number',
                'biller_code',
                'bill_key',
            ];
            foreach ($cols as $col) {
                if (Schema::hasColumn('payments', $col)) {
                    $table->dropColumn($col);
                }
            }
        });
    }
};
