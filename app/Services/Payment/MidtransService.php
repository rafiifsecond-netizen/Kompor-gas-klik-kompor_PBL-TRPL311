<?php

namespace App\Services\Payment;

use Exception;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MidtransService
{
    protected string $serverKey;

    protected string $clientKey;

    protected bool $isProduction;

    protected string $baseUrl;

    public function __construct()
    {
        $this->serverKey = config('services.midtrans.server_key', '');
        $this->clientKey = config('services.midtrans.client_key', '');
        $this->isProduction = (bool) config('services.midtrans.is_production', false);
        $this->baseUrl = $this->isProduction
            ? 'https://api.midtrans.com'
            : 'https://api.sandbox.midtrans.com';
    }

    /**
     * Hitung signature SHA-512 Midtrans webhook.
     * Raw string: order_id + status_code + gross_amount + ServerKey
     * Menggunakan hash_equals untuk timing-attack resistance.
     */
    public function verifyWebhookSignature(
        string $orderId,
        string $statusCode,
        string $grossAmount,
        string $signatureKey
    ): bool {
        if (empty($this->serverKey) || empty($signatureKey)) {
            return false;
        }

        $expectedSignature = hash('sha512', $orderId.$statusCode.$grossAmount.$this->serverKey);

        return hash_equals($expectedSignature, $signatureKey);
    }

    /**
     * Charge QRIS via Midtrans Core API.
     * Mengirimkan parameter custom_expiry (expiry_duration & unit minute).
     */
    public function chargeQris(
        string $gatewayOrderId,
        int $grossAmount,
        int $expiryMinutes = 15
    ): array {
        $endpoint = "{$this->baseUrl}/v2/charge";

        $payload = [
            'payment_type' => 'qris',
            'transaction_details' => [
                'order_id' => $gatewayOrderId,
                'gross_amount' => $grossAmount,
            ],
            'qris' => [
                'acquirer' => 'gopay',
            ],
            'custom_expiry' => [
                'expiry_duration' => $expiryMinutes,
                'unit' => 'minute',
            ],
        ];

        // Jika server key belum diset (misal di local/mock test), berikan respons simulasi
        if (empty($this->serverKey)) {
            Log::warning("Midtrans server key is empty. Generating mock QRIS response for {$gatewayOrderId}.");

            return [
                'status_code' => '201',
                'status_message' => 'Success, QRIS transaction is created (MOCK)',
                'transaction_id' => 'mock-tx-'.bin2hex(random_bytes(8)),
                'order_id' => $gatewayOrderId,
                'gross_amount' => (string) $grossAmount,
                'payment_type' => 'qris',
                'transaction_time' => now()->toDateTimeString(),
                'transaction_status' => 'pending',
                'actions' => [
                    [
                        'name' => 'generate-qr-code',
                        'method' => 'GET',
                        'url' => "https://api.sandbox.midtrans.com/v2/qris/mock-tx-{$gatewayOrderId}/qr-code",
                    ],
                ],
                'qr_string' => '00020101021226670016ID.CO.MIDTRANS.WWW01189360091800000000005204581253033605802ID5909KLIKKOMPOR6007JAKARTA61051234062070703A016304MOCK',
            ];
        }

        $response = Http::withBasicAuth($this->serverKey, '')
            ->acceptJson()
            ->asJson()
            ->post($endpoint, $payload);

        if (! $response->successful()) {
            Log::error("Midtrans QRIS Charge failed for {$gatewayOrderId}", [
                'status' => $response->status(),
                'body' => $response->json(),
            ]);
            throw new Exception('Gagal membuat transaksi QRIS Midtrans: '.($response->json('status_message') ?? 'HTTP '.$response->status()));
        }

        $data = $response->json();

        // Extract QR string & QR URL dari actions
        $qrString = $data['qr_string'] ?? null;
        $qrUrl = null;

        if (isset($data['actions']) && is_array($data['actions'])) {
            foreach ($data['actions'] as $action) {
                if (($action['name'] ?? '') === 'generate-qr-code') {
                    $qrUrl = $action['url'] ?? null;
                    break;
                }
            }
        }

        $data['extracted_qr_string'] = $qrString;
        $data['extracted_qr_url'] = $qrUrl;

        return $data;
    }

    /**
     * Charge Bank Transfer (Virtual Account) via Midtrans Core API.
     * Mendukung: bca, bni, bri, mandiri (echannel), permata.
     */
    public function chargeBankTransfer(
        string $bank,
        string $gatewayOrderId,
        int $grossAmount,
        int $expiryHours = 24
    ): array {
        $bankCode = strtolower(trim($bank));
        $endpoint = "{$this->baseUrl}/v2/charge";

        // Susun payload sesuai spesifikasi bank Midtrans
        $payload = [
            'transaction_details' => [
                'order_id' => $gatewayOrderId,
                'gross_amount' => $grossAmount,
            ],
            'custom_expiry' => [
                'expiry_duration' => $expiryHours,
                'unit' => 'hour',
            ],
        ];

        if ($bankCode === 'mandiri') {
            $payload['payment_type'] = 'echannel';
            $payload['echannel'] = [
                'bill_info1' => 'Pembayaran Servis',
                'bill_info2' => 'KlikKompor',
            ];
        } elseif ($bankCode === 'permata') {
            $payload['payment_type'] = 'permata';
        } else {
            // bca, bni, bri (default: bca)
            $selectedBank = in_array($bankCode, ['bca', 'bni', 'bri'], true) ? $bankCode : 'bca';
            $payload['payment_type'] = 'bank_transfer';
            $payload['bank_transfer'] = [
                'bank' => $selectedBank,
            ];
        }

        // Mock fallback jika server key belum dikonfigurasi (testing / local sandbox)
        if (empty($this->serverKey)) {
            Log::warning("Midtrans server key is empty. Generating mock Bank Transfer response for {$gatewayOrderId} ({$bankCode}).");

            $mockVa = match ($bankCode) {
                'mandiri' => null,
                'bni' => '988'.substr(crc32($gatewayOrderId), 0, 8).'1234',
                'bri' => '0341'.substr(crc32($gatewayOrderId), 0, 8).'5678',
                'permata' => '8528'.substr(crc32($gatewayOrderId), 0, 8).'9012',
                default => '8040'.substr(crc32($gatewayOrderId), 0, 8).'9012',
            };

            return [
                'status_code' => '201',
                'status_message' => 'Success, Bank Transfer transaction is created (MOCK)',
                'transaction_id' => 'mock-va-'.bin2hex(random_bytes(8)),
                'order_id' => $gatewayOrderId,
                'gross_amount' => (string) $grossAmount,
                'payment_type' => $payload['payment_type'],
                'transaction_time' => now()->toDateTimeString(),
                'transaction_status' => 'pending',
                'va_numbers' => $mockVa ? [['bank' => $bankCode, 'va_number' => $mockVa]] : [],
                'permata_va_number' => $bankCode === 'permata' ? $mockVa : null,
                'biller_code' => $bankCode === 'mandiri' ? '70012' : null,
                'bill_key' => $bankCode === 'mandiri' ? '99'.substr(crc32($gatewayOrderId), 0, 8) : null,
                'extracted_va_number' => $mockVa ?? ($bankCode === 'mandiri' ? '70012-99'.substr(crc32($gatewayOrderId), 0, 8) : null),
                'bank' => $bankCode,
            ];
        }

        $response = Http::withBasicAuth($this->serverKey, '')
            ->acceptJson()
            ->asJson()
            ->post($endpoint, $payload);

        if (! $response->successful()) {
            Log::error("Midtrans Bank Transfer Charge failed for {$gatewayOrderId}", [
                'status' => $response->status(),
                'body' => $response->json(),
            ]);
            throw new Exception('Gagal membuat transaksi Bank Transfer Midtrans: '.($response->json('status_message') ?? 'HTTP '.$response->status()));
        }

        $data = $response->json();

        // Ekstraksi VA Number sesuai response Midtrans
        $extractedVa = null;
        if (! empty($data['va_numbers'][0]['va_number'])) {
            $extractedVa = $data['va_numbers'][0]['va_number'];
        } elseif (! empty($data['permata_va_number'])) {
            $extractedVa = $data['permata_va_number'];
        } elseif (! empty($data['bill_key'])) {
            $extractedVa = ($data['biller_code'] ?? '70012').' - '.$data['bill_key'];
        }

        $data['extracted_va_number'] = $extractedVa;
        $data['bank'] = $bankCode;

        return $data;
    }

    /**
     * Batalkan transaksi Midtrans via Core API (/v2/{order_id}/cancel).
     * Digunakan saat user retry pembayaran agar attempt lama tidak bisa dibayar ganda.
     */
    public function cancelTransaction(string $gatewayOrderId): array
    {
        if (empty($this->serverKey)) {
            return [
                'status_code' => '200',
                'status_message' => 'Success, transaction is canceled (MOCK)',
                'order_id' => $gatewayOrderId,
                'transaction_status' => 'cancel',
            ];
        }

        $endpoint = "{$this->baseUrl}/v2/{$gatewayOrderId}/cancel";

        $response = Http::withBasicAuth($this->serverKey, '')
            ->acceptJson()
            ->post($endpoint);

        return $response->json() ?? [];
    }

    /**
     * Cek status transaksi via Midtrans Core API (/v2/{order_id}/status).
     */
    public function checkStatus(string $gatewayOrderId): array
    {
        if (empty($this->serverKey)) {
            return [
                'status_code' => '200',
                'order_id' => $gatewayOrderId,
                'transaction_status' => 'pending',
            ];
        }

        $endpoint = "{$this->baseUrl}/v2/{$gatewayOrderId}/status";

        $response = Http::withBasicAuth($this->serverKey, '')
            ->acceptJson()
            ->get($endpoint);

        return $response->json() ?? [];
    }
}
