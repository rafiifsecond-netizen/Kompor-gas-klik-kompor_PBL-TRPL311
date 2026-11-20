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
