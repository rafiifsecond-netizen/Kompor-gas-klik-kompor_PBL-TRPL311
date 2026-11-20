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
        $driver = DB::getDriverName();

        // 1. users: Tambah is_suspended_from_orders
        if (!Schema::hasColumn('users', 'is_suspended_from_orders')) {
            Schema::table('users', function (Blueprint $table) {
                $table->boolean('is_suspended_from_orders')->default(false)->after('is_active')->index();
            });
        }

        // 2. platform_settings
        if (!Schema::hasTable('platform_settings')) {
            Schema::create('platform_settings', function (Blueprint $table) {
                $table->id();
                $table->string('key', 50)->unique();
                $table->text('value');
                $table->string('description', 255)->nullable();
                $table->foreignId('updated_by')->nullable()->constrained('users')->nullOnDelete();
                $table->timestamps();
            });

            // Seed initial settings
            $now = now();
            DB::table('platform_settings')->insert([
                [
                    'key' => 'platform_commission_percent',
                    'value' => '5.00',
                    'description' => 'Persentase komisi platform dari subtotal jasa setelah diskon',
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'key' => 'rounding_mode',
                    'value' => 'round',
                    'description' => 'Mode pembulatan komisi (round, floor, ceil)',
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'key' => 'rounding_unit',
                    'value' => '1',
                    'description' => 'Satuan pembulatan rupiah terdekat (1 atau 100)',
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'key' => 'qris_expiry_minutes',
                    'value' => '15',
                    'description' => 'Durasi kedaluwarsa QRIS Midtrans dalam menit',
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'key' => 'manual_transfer_expiry_hours',
                    'value' => '24',
                    'description' => 'Batas waktu pelanggan mengunggah bukti transfer manual dalam jam',
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'key' => 'min_payout_amount',
                    'value' => '50000',
                    'description' => 'Batas minimum pengajuan penarikan saldo dompet teknisi',
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
                [
                    'key' => 'max_cash_debt_limit',
                    'value' => '200000',
                    'description' => 'Batas toleransi utang komisi cash sebelum teknisi disuspend',
                    'created_at' => $now,
                    'updated_at' => $now,
                ],
            ]);
        }

        // 3. promos
        if (!Schema::hasTable('promos')) {
            Schema::create('promos', function (Blueprint $table) {
                $table->id();
                $table->string('code', 30)->unique();
                $table->string('name', 100);
                $table->text('description')->nullable();
                $table->enum('type', ['percentage', 'fixed']);
                $table->unsignedBigInteger('discount_amount');
                $table->unsignedBigInteger('max_discount')->nullable();
                $table->unsignedBigInteger('min_order_amount')->default(0);
                $table->dateTime('start_date');
                $table->dateTime('end_date');
                $table->unsignedInteger('total_quota')->default(0);
                $table->unsignedInteger('quota_per_user')->default(1);
                $table->json('applicable_payment_methods')->nullable();
                $table->boolean('is_active')->default(true);
                $table->timestamps();

                $table->index(['code', 'is_active']);
            });
        }

        // 4. promo_usages
        if (!Schema::hasTable('promo_usages')) {
            Schema::create('promo_usages', function (Blueprint $table) {
                $table->id();
                $table->foreignId('promo_id')->constrained('promos')->restrictOnDelete();
                $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
                $table->foreignId('order_id')->unique()->constrained('orders')->cascadeOnDelete();
                $table->unsignedBigInteger('discount_applied');
                $table->enum('status', ['reserved', 'used', 'released'])->default('reserved');
                $table->dateTime('reserved_at');
                $table->dateTime('used_at')->nullable();
                $table->dateTime('released_at')->nullable();
                $table->timestamps();

                $table->index(['promo_id', 'user_id', 'status']);
            });
        }

        // 5. payments: ALTER inkremental & Backfill
        if ($driver === 'sqlite') {
            DB::statement('DROP VIEW IF EXISTS v_payment_operational');
        }

        Schema::table('payments', function (Blueprint $table) {
            if (!Schema::hasColumn('payments', 'idempotency_key')) {
                $table->string('idempotency_key', 100)->nullable()->unique()->after('payment_number');
            }
            if (!Schema::hasColumn('payments', 'gateway_provider')) {
                $table->string('gateway_provider', 30)->nullable()->after('payment_status');
            }
            if (!Schema::hasColumn('payments', 'gateway_order_id')) {
                $table->string('gateway_order_id', 100)->nullable()->unique()->after('gateway_provider');
            }
            if (!Schema::hasColumn('payments', 'gateway_transaction_id')) {
                $table->string('gateway_transaction_id', 100)->nullable()->after('gateway_order_id');
            }
            if (!Schema::hasColumn('payments', 'qris_qr_string')) {
                $table->text('qris_qr_string')->nullable()->after('gateway_transaction_id');
            }
            if (!Schema::hasColumn('payments', 'qris_qr_url')) {
                $table->text('qris_qr_url')->nullable()->after('qris_qr_string');
            }
            if (!Schema::hasColumn('payments', 'sender_bank_name')) {
                $table->string('sender_bank_name', 50)->nullable()->after('qris_qr_url');
            }
            if (!Schema::hasColumn('payments', 'sender_account_name')) {
                $table->string('sender_account_name', 150)->nullable()->after('sender_bank_name');
            }
            if (!Schema::hasColumn('payments', 'proof_uploaded_at')) {
                $table->dateTime('proof_uploaded_at')->nullable()->after('proof_url');
            }
            if (!Schema::hasColumn('payments', 'expires_at')) {
                $table->dateTime('expires_at')->nullable()->after('proof_uploaded_at');
            }
            if (!Schema::hasColumn('payments', 'verified_by')) {
                $table->foreignId('verified_by')->nullable()->constrained('users')->nullOnDelete()->after('paid_at');
            }
            if (!Schema::hasColumn('payments', 'verified_at')) {
                $table->dateTime('verified_at')->nullable()->after('verified_by');
            }
            if (!Schema::hasColumn('payments', 'rejection_reason')) {
                $table->text('rejection_reason')->nullable()->after('verified_at');
            }
        });

        if ($driver === 'sqlite') {
            DB::statement(<<<SQL
                CREATE VIEW IF NOT EXISTS v_payment_operational AS
                SELECT
                    p.id,
                    p.order_id,
                    p.customer_id,
                    p.payment_number,
                    p.payment_method,
                    p.amount,
                    p.payment_status,
                    p.paid_at,
                    p.created_at,
                    p.updated_at
                FROM payments p
            SQL);
        }

        // Backfill data payments yang sudah ada sebelum kolom expires_at dijadikan NOT NULL
        $nowStr = now()->toDateTimeString();
        DB::statement("UPDATE payments SET expires_at = COALESCE(paid_at, created_at, '{$nowStr}') WHERE expires_at IS NULL");
        DB::statement("UPDATE payments SET gateway_provider = payment_method WHERE gateway_provider IS NULL");

        // MySQL-specific: generated column untuk mengunci MAKS 1 ATTEMPT AKTIF per order
        if ($driver === 'mysql' || $driver === 'mariadb') {
            $hasVirtual = DB::select("SHOW COLUMNS FROM `payments` LIKE 'active_order_attempt'");
            if (empty($hasVirtual)) {
                DB::statement("ALTER TABLE `payments` ADD `active_order_attempt` BIGINT UNSIGNED GENERATED ALWAYS AS (CASE WHEN `payment_status` IN ('pending', 'awaiting_verification', 'paid') THEN `order_id` ELSE NULL END) VIRTUAL");
                DB::statement("ALTER TABLE `payments` ADD UNIQUE INDEX `uq_active_order_attempt` (`active_order_attempt`)");
            }
        }

        // 6. commission_records
        if (!Schema::hasTable('commission_records')) {
            Schema::create('commission_records', function (Blueprint $table) {
                $table->id();
                $table->foreignId('order_id')->unique()->constrained('orders')->cascadeOnDelete();
                $table->foreignId('technician_id')->constrained('users')->cascadeOnDelete();
                $table->foreignId('payment_id')->nullable()->constrained('payments')->nullOnDelete();
                $table->unsignedBigInteger('service_subtotal');
                $table->unsignedBigInteger('transport_fee');
                $table->unsignedBigInteger('discount_amount')->default(0);
                $table->unsignedBigInteger('final_order_amount');
                $table->decimal('commission_percentage', 5, 2);
                $table->unsignedBigInteger('commission_amount');
                $table->unsignedBigInteger('platform_subsidy')->default(0);
                $table->unsignedBigInteger('technician_net_income');
                $table->string('payment_method', 30);
                $table->enum('settlement_direction', [
                    'technician_pays_platform',
                    'platform_pays_technician',
                    'none',
                ]);
                $table->unsignedBigInteger('settlement_amount')->default(0);
                $table->enum('settlement_status', ['settled', 'unsettled', 'waived'])->default('settled');
                $table->string('rounding_mode_snapshot', 10);
                $table->unsignedInteger('rounding_unit_snapshot');
                $table->dateTime('settled_at')->nullable();
                $table->foreignId('settled_by')->nullable()->constrained('users')->nullOnDelete();
                $table->text('notes')->nullable();
                $table->timestamps();

                $table->index(['technician_id', 'settlement_status']);
            });
        }

        // 7. technician_wallets & wallet_transactions
        if (!Schema::hasTable('technician_wallets')) {
            Schema::create('technician_wallets', function (Blueprint $table) {
                $table->id();
                $table->foreignId('technician_id')->unique()->constrained('users')->cascadeOnDelete();
                $table->bigInteger('balance')->default(0);
                $table->unsignedBigInteger('pending_balance')->default(0);
                $table->string('bank_name', 50)->nullable();
                $table->string('bank_account_number', 50)->nullable();
                $table->string('bank_account_holder', 150)->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('wallet_transactions')) {
            Schema::create('wallet_transactions', function (Blueprint $table) {
                $table->id();
                $table->foreignId('wallet_id')->constrained('technician_wallets')->cascadeOnDelete();
                $table->string('transaction_number', 60)->unique();
                $table->enum('type', ['credit', 'debit']);
                $table->unsignedBigInteger('amount');
                $table->bigInteger('balance_before');
                $table->bigInteger('balance_after');
                $table->string('reference_type', 50);
                $table->unsignedBigInteger('reference_id')->nullable();
                $table->string('description', 255);
                $table->timestamp('created_at')->useCurrent();

                $table->index(['wallet_id', 'created_at']);
            });
        }

        // 8. payout_requests
        if (!Schema::hasTable('payout_requests')) {
            Schema::create('payout_requests', function (Blueprint $table) {
                $table->id();
                $table->foreignId('technician_id')->constrained('users')->cascadeOnDelete();
                $table->string('payout_number', 50)->unique();
                $table->unsignedBigInteger('amount');
                $table->string('bank_name', 50);
                $table->string('account_number', 50);
                $table->string('account_holder', 150);
                $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
                $table->string('transfer_proof_url', 255)->nullable();
                $table->foreignId('processed_by')->nullable()->constrained('users')->nullOnDelete();
                $table->dateTime('processed_at')->nullable();
                $table->text('admin_notes')->nullable();
                $table->timestamps();

                $table->index(['technician_id', 'status']);
            });
        }

        // 9. webhook_events
        if (!Schema::hasTable('webhook_events')) {
            Schema::create('webhook_events', function (Blueprint $table) {
                $table->id();
                $table->foreignId('payment_id')->nullable()->constrained('payments')->nullOnDelete();
                $table->string('gateway_order_id', 100);
                $table->string('gateway_transaction_id', 100);
                $table->string('transaction_status', 50);
                $table->json('payload');
                $table->timestamp('processed_at')->useCurrent();

                $table->unique(['gateway_transaction_id', 'transaction_status'], 'uq_webhook_tx_status');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $driver = DB::getDriverName();

        Schema::dropIfExists('webhook_events');
        Schema::dropIfExists('payout_requests');
        Schema::dropIfExists('wallet_transactions');
        Schema::dropIfExists('technician_wallets');
        Schema::dropIfExists('commission_records');

        if (($driver === 'mysql' || $driver === 'mariadb') && Schema::hasColumn('payments', 'active_order_attempt')) {
            DB::statement("ALTER TABLE `payments` DROP INDEX `uq_active_order_attempt`");
            DB::statement("ALTER TABLE `payments` DROP COLUMN `active_order_attempt`");
        }

        Schema::table('payments', function (Blueprint $table) {
            $cols = [
                'idempotency_key', 'gateway_provider', 'gateway_order_id',
                'gateway_transaction_id', 'qris_qr_string', 'qris_qr_url',
                'sender_bank_name', 'sender_account_name', 'proof_uploaded_at',
                'expires_at', 'verified_by', 'verified_at', 'rejection_reason'
            ];
            foreach ($cols as $col) {
                if (Schema::hasColumn('payments', $col)) {
                    $table->dropColumn($col);
                }
            }
        });

        Schema::dropIfExists('promo_usages');
        Schema::dropIfExists('promos');
        Schema::dropIfExists('platform_settings');

        if (Schema::hasColumn('users', 'is_suspended_from_orders')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn('is_suspended_from_orders');
            });
        }
    }
};
