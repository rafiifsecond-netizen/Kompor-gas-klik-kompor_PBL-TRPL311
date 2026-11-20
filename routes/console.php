<?php

use App\Services\Payment\PaymentService;
use App\Services\Payment\WalletService;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Scheduled Job: Otomatis kedaluwarsa-kan pembayaran pending lewat tempo (QRIS 15m / Transfer 24j)
Schedule::call(function (PaymentService $paymentService) {
    $expiredCount = $paymentService->expirePendingPayments();
    if ($expiredCount > 0) {
        Log::info("Scheduler: {$expiredCount} pending payment(s) marked as expired.");
    }
})->everyFiveMinutes()->name('payments:expire-pending');

// Scheduled Job: Evaluasi batasan utang cash teknisi & suspensi jika lewat batas
Schedule::call(function (WalletService $walletService) {
    $walletService->evaluateAllTechniciansSuspension();
})->hourly()->name('technicians:evaluate-debt');
