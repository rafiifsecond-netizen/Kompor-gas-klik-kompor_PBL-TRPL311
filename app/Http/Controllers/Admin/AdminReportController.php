<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Payment;
use App\Models\User;
use App\Models\TechnicianProfile;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AdminReportController extends Controller
{
    /**
     * Tampilan utama Laporan Keuangan & Operasional (F020).
     */
    public function index(Request $request)
    {
        $startDate = $request->filled('start_date')
            ? Carbon::parse($request->query('start_date'))->startOfDay()
            : now()->startOfMonth()->startOfDay();

        $endDate = $request->filled('end_date')
            ? Carbon::parse($request->query('end_date'))->endOfDay()
            : now()->endOfMonth()->endOfDay();

        $period = $request->query('period', 'daily'); // daily, weekly, monthly, yearly

        // 1. Total Transaksi Pembayaran dalam rentang tanggal
        $paymentsQuery = Payment::whereBetween('created_at', [$startDate, $endDate]);
        $totalTransactions = (clone $paymentsQuery)->count();

        // 2. Total Pendapatan Bersih: Hanya status PAID dikurangi REFUND
        $grossPaidRevenue = (clone $paymentsQuery)
            ->where('payment_status', Payment::STATUS_PAID)
            ->sum('amount');

        $refundedAmount = (clone $paymentsQuery)
            ->where('payment_status', Payment::STATUS_REFUNDED)
            ->sum('amount');

        $netRevenue = max(0, $grossPaidRevenue - $refundedAmount);

        // 3. Status Pesanan dalam rentang tanggal
        $ordersQuery = Order::whereBetween('created_at', [$startDate, $endDate]);
        $completedOrders = (clone $ordersQuery)->where('status', Order::STATUS_COMPLETED)->count();
        $cancelledOrders = (clone $ordersQuery)->where('status', Order::STATUS_CANCELLED)->count();

        // 4. Status Pembayaran
        $pendingPayments = (clone $paymentsQuery)
            ->whereIn('payment_status', [Payment::STATUS_PENDING, Payment::STATUS_AWAITING_VERIFICATION])
            ->count();
        $paidPayments = (clone $paymentsQuery)
            ->where('payment_status', Payment::STATUS_PAID)
            ->count();

        // 5. Kalkulasi Pertumbuhan Profit Dinamis (Vs Periode Sebelumnya)
        $diffDays = $startDate->diffInDays($endDate) + 1;
        $prevStartDate = (clone $startDate)->subDays($diffDays);
        $prevEndDate = (clone $startDate)->subSecond();

        $prevRevenue = Payment::whereBetween('created_at', [$prevStartDate, $prevEndDate])
            ->where('payment_status', Payment::STATUS_PAID)
            ->sum('amount');

        $profitGrowthPercentage = 0.0;
        if ($prevRevenue > 0) {
            $profitGrowthPercentage = round((($netRevenue - $prevRevenue) / $prevRevenue) * 100, 1);
        } elseif ($netRevenue > 0) {
            $profitGrowthPercentage = 100.0;
        }

        // 6. Data Grafik Chart.js Dinamis
        $chartData = $this->buildChartData($startDate, $endDate, $period);

        // 7. Riwayat Transaksi Terbaru dalam Rentang Tanggal
        $transactions = Payment::with(['order.customer', 'customer'])
            ->whereBetween('created_at', [$startDate, $endDate])
            ->latest()
            ->paginate(15)
            ->withQueryString();

        $stats = [
            'total_users' => User::where('role', 'customer')->count(),
            'total_technicians' => TechnicianProfile::count(),
            'total_transactions' => $totalTransactions,
            'completed_orders' => $completedOrders,
            'cancelled_orders' => $cancelledOrders,
            'pending_payments' => $pendingPayments,
            'paid_payments' => $paidPayments,
            'gross_revenue' => $grossPaidRevenue,
            'refunded_amount' => $refundedAmount,
            'net_revenue' => $netRevenue,
            'profit_growth' => $profitGrowthPercentage,
        ];

        return view('admin.reports', compact(
            'stats',
            'netRevenue',
            'chartData',
            'transactions',
            'startDate',
            'endDate',
            'period'
        ));
    }

    /**
     * Membangun data time-series dinamis untuk grafik Chart.js.
     */
    protected function buildChartData(Carbon $startDate, Carbon $endDate, string $period): array
    {
        $paidPayments = Payment::whereBetween('created_at', [$startDate, $endDate])
            ->where('payment_status', Payment::STATUS_PAID)
            ->get();

        $labels = [];
        $data = [];

        if ($period === 'monthly') {
            $cursor = (clone $startDate)->startOfMonth();
            while ($cursor <= $endDate) {
                $monthLabel = $cursor->translatedFormat('M Y');
                $labels[] = $monthLabel;
                $sum = $paidPayments->filter(function ($p) use ($cursor) {
                    return $p->created_at->format('Y-m') === $cursor->format('Y-m');
                })->sum('amount');
                $data[] = (int) $sum;
                $cursor->addMonth();
            }
        } elseif ($period === 'weekly') {
            $cursor = (clone $startDate)->startOfWeek();
            $weekNum = 1;
            while ($cursor <= $endDate) {
                $weekEnd = (clone $cursor)->endOfWeek();
                $labels[] = "Mgg {$weekNum} (" . $cursor->format('d/m') . ")";
                $sum = $paidPayments->filter(function ($p) use ($cursor, $weekEnd) {
                    return $p->created_at >= $cursor && $p->created_at <= $weekEnd;
                })->sum('amount');
                $data[] = (int) $sum;
                $cursor->addWeek();
                $weekNum++;
            }
        } elseif ($period === 'yearly') {
            $cursor = (clone $startDate)->startOfYear();
            while ($cursor <= $endDate) {
                $yearLabel = $cursor->format('Y');
                $labels[] = $yearLabel;
                $sum = $paidPayments->filter(function ($p) use ($cursor) {
                    return $p->created_at->format('Y') === $cursor->format('Y');
                })->sum('amount');
                $data[] = (int) $sum;
                $cursor->addYear();
            }
        } else {
            // Daily (default)
            $cursor = (clone $startDate)->copy();
            // Batasi maksimal 31 titik agar grafik rapi
            $stepDays = max(1, (int) ceil($startDate->diffInDays($endDate) / 30));
            while ($cursor <= $endDate) {
                $dayLabel = $cursor->format('d M');
                $labels[] = $dayLabel;
                $next = (clone $cursor)->addDays($stepDays);
                $sum = $paidPayments->filter(function ($p) use ($cursor, $next) {
                    return $p->created_at >= $cursor && $p->created_at < $next;
                })->sum('amount');
                $data[] = (int) $sum;
                $cursor->addDays($stepDays);
            }
        }

        return [
            'labels' => $labels,
            'data' => $data,
        ];
    }

    /**
     * Ekspor Laporan ke format CSV/Excel dengan mematuhi filter tanggal aktif (F020).
     */
    public function exportCsv(Request $request): StreamedResponse
    {
        $startDate = $request->filled('start_date')
            ? Carbon::parse($request->query('start_date'))->startOfDay()
            : now()->startOfMonth()->startOfDay();

        $endDate = $request->filled('end_date')
            ? Carbon::parse($request->query('end_date'))->endOfDay()
            : now()->endOfMonth()->endOfDay();

        $fileName = 'laporan-keuangan-' . $startDate->format('Ymd') . '-sd-' . $endDate->format('Ymd') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => "attachment; filename=\"{$fileName}\"",
        ];

        return response()->stream(function () use ($startDate, $endDate) {
            $handle = fopen('php://output', 'w');
            // Add UTF-8 BOM for Excel compatibility
            fprintf($handle, chr(0xEF).chr(0xBB).chr(0xBF));

            fputcsv($handle, [
                'ID Pembayaran',
                'No. Transaksi',
                'No. Pesanan',
                'Nama Pelanggan',
                'Metode Pembayaran',
                'Nominal (Rp)',
                'Status Pembayaran',
                'Waktu Transaksi',
                'Waktu Pelunasan',
            ]);

            $payments = Payment::with(['order', 'customer'])
                ->whereBetween('created_at', [$startDate, $endDate])
                ->latest()
                ->cursor();

            foreach ($payments as $payment) {
                fputcsv($handle, [
                    $payment->id,
                    $payment->payment_number ?? '-',
                    $payment->order?->order_number ?? '-',
                    $payment->customer?->name ?? ($payment->order?->customer_name ?? 'Pelanggan'),
                    strtoupper($payment->payment_method),
                    $payment->amount,
                    $payment->payment_status,
                    $payment->created_at->format('Y-m-d H:i:s'),
                    $payment->paid_at ? $payment->paid_at->format('Y-m-d H:i:s') : '-',
                ]);
            }

            fclose($handle);
        }, 200, $headers);
    }
}
