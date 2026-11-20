<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laporan Keuangan & Operasional - Admin KlikKompor</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f8fafc; }
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-6px); }
        }
        @keyframes pulseGlow {
            0%, 100% { opacity: 0.6; transform: scale(1); }
            50% { opacity: 1; transform: scale(1.05); }
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .animate-float { animation: float 4s ease-in-out infinite; }
        .animate-glow { animation: pulseGlow 3s ease-in-out infinite; }
        .animate-fade-in { animation: fadeIn 0.5s ease-out forwards; }

        @media print {
            aside, header, .no-print, .filter-box { display: none !important; }
            body, main { background: white !important; color: black !important; height: auto !important; overflow: visible !important; }
            main { border-radius: 0 !important; box-shadow: none !important; }
        }
    </style>
</head>
<body class="flex h-screen overflow-hidden bg-[#090b27]">

    <!-- Sidebar -->
    <aside class="w-68 bg-[#090b27] text-white flex flex-col justify-between hidden md:flex shrink-0 relative overflow-hidden border-r border-slate-800">
        <div class="absolute -top-24 -left-24 w-64 h-64 bg-orange-500/20 rounded-full blur-3xl animate-glow pointer-events-none"></div>

        <div class="relative z-10">
            <!-- Logo Brand -->
            <div class="h-32 flex items-center px-6 gap-3">
                <img src="{{ asset('images/logo.png') }}" alt="Logo" class="w-20 h-16 object-contain animate-float drop-shadow-md" onerror="this.src='https://via.placeholder.com/80?text=KK'" />
                <span class="font-extrabold text-2xl text-orange-500 tracking-tight">KlikKompor</span>
            </div>

            <!-- Navigation Links -->
            <nav class="px-3 space-y-1.5">
                <a href="{{ route('admin.dashboard') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="layout-dashboard" class="w-5 h-5"></i> Dashboard
                </a>
                <a href="{{ route('admin.orders') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="clipboard-list" class="w-5 h-5"></i> Pesanan
                </a>
                <a href="{{ route('admin.customers') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="users" class="w-5 h-5"></i> Pelanggan
                </a>
                <a href="{{ route('admin.technicians') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="wrench" class="w-5 h-5"></i> Teknisi
                </a>
                <a href="{{ route('admin.services') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="briefcase" class="w-5 h-5"></i> Layanan
                </a>
                <a href="{{ route('admin.payments') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="credit-card" class="w-5 h-5"></i> Pembayaran
                </a>
                <a href="{{ route('admin.reviews') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="message-square" class="w-5 h-5"></i> Ulasan
                </a>
                <a href="{{ route('admin.reports') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl bg-gradient-to-r from-orange-500 to-amber-500 text-white font-bold transition shadow-lg shadow-orange-500/25">
                    <i data-lucide="bar-chart-2" class="w-5 h-5"></i> Laporan
                </a>
                <a href="{{ route('admin.settings') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="settings" class="w-5 h-5"></i> Pengaturan
                </a>
            </nav>
        </div>

        <!-- Sidebar Bottom -->
        <div class="p-4 mb-4 relative z-10 space-y-3">
            <div class="p-3.5 rounded-2xl bg-slate-800/60 border border-slate-700/60 text-xs text-slate-300 flex items-center gap-3 shadow-inner">
                <div class="w-3 h-3 rounded-full bg-emerald-500 animate-ping shrink-0"></div>
                <div>
                    <span class="font-bold block text-white text-xs">Server Online</span>
                    <span class="text-[10px] text-slate-400">Laravel v11 • MySQL</span>
                </div>
            </div>
            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit" class="w-full flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-red-500/20 hover:text-red-400 font-bold transition">
                    <i data-lucide="log-out" class="w-5 h-5"></i> Keluar
                </button>
            </form>
        </div>
    </aside>

    <!-- Main Content Area -->
    <main class="flex-1 flex flex-col h-screen overflow-y-auto bg-gradient-to-br from-slate-50 via-orange-50/40 to-amber-50/20 rounded-tl-3xl shadow-2xl relative">

        <!-- Subtle Ambient Floating Glow Orbs in Background -->
        <div class="absolute top-10 right-20 w-96 h-96 bg-orange-500/10 rounded-full blur-3xl animate-glow pointer-events-none"></div>
        <div class="absolute top-96 left-20 w-96 h-96 bg-amber-500/10 rounded-full blur-3xl animate-glow pointer-events-none" style="animation-delay: 1.5s;"></div>

        <!-- Top Header Bar -->
        <header class="h-28 border-b border-slate-200/80 flex items-center justify-between px-10 py-6 sticky top-0 bg-white/90 backdrop-blur-md z-20 shadow-sm">
            <div class="flex items-center gap-4">
                <a href="{{ route('admin.dashboard') }}" class="w-12 h-12 rounded-xl bg-slate-100 flex items-center justify-center text-slate-700 hover:text-black hover:bg-slate-200 transition shadow-sm transform hover:-translate-x-0.5">
                    <i data-lucide="arrow-left" class="w-6 h-6"></i>
                </a>
                <div>
                    <h1 class="text-xl font-extrabold text-slate-900">Laporan & Rekapitulasi (F020)</h1>
                    <p class="text-xs text-slate-500">Data analitik real-time dari database transaksi KlikKompor</p>
                </div>
            </div>
            <div class="flex items-center gap-8">
                <!-- Notification Bell -->
                @php
                    $unreadCount = \App\Models\Notification::where('user_id', auth()->id())->whereNull('read_at')->count();
                @endphp
                <a href="{{ route('admin.notifications') }}" class="relative w-12 h-12 mx-2 rounded-2xl bg-slate-100/90 flex items-center justify-center text-slate-700 hover:bg-slate-200 transition shadow-sm hover:scale-105">
                    <i data-lucide="bell" class="w-6 h-6"></i>
                    @if($unreadCount > 0)
                        <span class="absolute top-2.5 right-2.5 w-3 h-3 rounded-full bg-orange-500 animate-ping"></span>
                        <span class="absolute top-2.5 right-2.5 w-3 h-3 rounded-full bg-orange-500 border-2 border-white"></span>
                    @endif
                </a>
                <!-- Admin Profile Card -->
                <a href="{{ route('admin.profile') }}" class="flex items-center gap-3.5 bg-slate-50 border border-slate-200 rounded-2xl px-4 py-2.5 shadow-sm hover:border-orange-300 hover:bg-orange-50/50 transition">
                    <div class="w-10 h-10 rounded-full bg-gradient-to-tr from-orange-500 to-amber-400 overflow-hidden flex items-center justify-center font-bold text-white shadow">
                        {{ strtoupper(substr(auth()->user()->name, 0, 2)) }}
                    </div>
                    <div>
                        <h4 class="text-xs font-bold text-slate-900">{{ auth()->user()->name }}</h4>
                        <span class="text-[10px] text-slate-500 font-medium">Administrator</span>
                    </div>
                </a>
            </div>
        </header>

        <!-- Body Content -->
        <div class="p-8 space-y-8 animate-fade-in relative z-10">

            <!-- Filter & Action Controls -->
            <div class="bg-white/90 backdrop-blur-md p-6 rounded-3xl border border-orange-100 shadow-sm flex flex-col lg:flex-row lg:items-center justify-between gap-4 filter-box">
                <form method="GET" action="{{ route('admin.reports') }}" class="flex flex-wrap items-center gap-3">
                    <div>
                        <label class="block text-[11px] font-bold text-slate-500 uppercase mb-1">Mulai</label>
                        <input type="date" name="start_date" value="{{ $startDate->format('Y-m-d') }}" class="px-3.5 py-2 rounded-xl border border-slate-200 text-xs font-semibold text-slate-700 focus:outline-none focus:border-orange-500 focus:ring-1 focus:ring-orange-500 bg-white">
                    </div>
                    <div>
                        <label class="block text-[11px] font-bold text-slate-500 uppercase mb-1">Sampai</label>
                        <input type="date" name="end_date" value="{{ $endDate->format('Y-m-d') }}" class="px-3.5 py-2 rounded-xl border border-slate-200 text-xs font-semibold text-slate-700 focus:outline-none focus:border-orange-500 focus:ring-1 focus:ring-orange-500 bg-white">
                    </div>
                    <div>
                        <label class="block text-[11px] font-bold text-slate-500 uppercase mb-1">Periode Grafik</label>
                        <select name="period" class="px-3.5 py-2 rounded-xl border border-slate-200 text-xs font-semibold text-slate-700 focus:outline-none focus:border-orange-500 focus:ring-1 focus:ring-orange-500 bg-white">
                            <option value="daily" {{ $period === 'daily' ? 'selected' : '' }}>Harian</option>
                            <option value="weekly" {{ $period === 'weekly' ? 'selected' : '' }}>Mingguan</option>
                            <option value="monthly" {{ $period === 'monthly' ? 'selected' : '' }}>Bulanan</option>
                            <option value="yearly" {{ $period === 'yearly' ? 'selected' : '' }}>Tahunan</option>
                        </select>
                    </div>
                    <div class="flex items-end gap-2 pt-4">
                        <button type="submit" class="px-4 py-2.5 rounded-xl bg-orange-500 hover:bg-orange-600 text-white font-bold text-xs flex items-center gap-1.5 shadow-sm transition">
                            <i data-lucide="filter" class="w-3.5 h-3.5"></i> Filter
                        </button>
                        <a href="{{ route('admin.reports') }}" class="px-3 py-2.5 rounded-xl border border-slate-200 hover:bg-slate-100 text-slate-600 font-semibold text-xs transition">
                            Reset
                        </a>
                    </div>
                </form>

                <div class="flex items-center gap-2.5 no-print self-end lg:self-center">
                    <a href="{{ route('admin.reports.export', request()->all()) }}" class="px-4 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs flex items-center gap-2 shadow-sm transition">
                        <i data-lucide="download" class="w-4 h-4"></i> Ekspor CSV
                    </a>
                    <button onclick="window.print()" class="px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-900 text-white font-bold text-xs flex items-center gap-2 shadow-sm transition">
                        <i data-lucide="printer" class="w-4 h-4"></i> Cetak / PDF
                    </button>
                </div>
            </div>

            <!-- Revenue Banner with Dynamic Data -->
            <div class="bg-gradient-to-r from-[#090b27] to-[#1e1b4b] text-white p-8 rounded-3xl overflow-hidden shadow-xl relative">
                <div class="absolute -right-10 -bottom-10 w-64 h-64 bg-orange-500/30 rounded-full blur-3xl animate-glow"></div>
                <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
                    <div>
                        <div class="flex items-center gap-2.5">
                            <span class="px-3 py-1 rounded-full text-xs font-bold bg-orange-500/30 text-orange-400 border border-orange-500/30">Total Pendapatan Bersih</span>
                            @if($stats['profit_growth'] >= 0)
                                <span class="px-2.5 py-0.5 rounded-md text-xs font-bold bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 flex items-center gap-1">
                                    <i data-lucide="trending-up" class="w-3 h-3"></i> +{{ $stats['profit_growth'] }}% vs periode sebelumnya
                                </span>
                            @else
                                <span class="px-2.5 py-0.5 rounded-md text-xs font-bold bg-rose-500/20 text-rose-400 border border-rose-500/30 flex items-center gap-1">
                                    <i data-lucide="trending-down" class="w-3 h-3"></i> {{ $stats['profit_growth'] }}% vs periode sebelumnya
                                </span>
                            @endif
                        </div>
                        <h2 class="text-4xl font-extrabold mt-3">Rp {{ number_format($netRevenue, 0, ',', '.') }}</h2>
                        <p class="text-xs text-slate-300 mt-1">
                            Akumulasi pembayaran berstatus LUNAS (Bruto: Rp {{ number_format($stats['gross_revenue'], 0, ',', '.') }}) dikurangi Refund (Rp {{ number_format($stats['refunded_amount'], 0, ',', '.') }}).
                        </p>
                    </div>
                    <div class="flex flex-wrap gap-3">
                        <div class="bg-white/10 backdrop-blur-md px-5 py-3.5 rounded-2xl border border-white/10">
                            <span class="text-[11px] text-slate-300 block">Pesanan Selesai</span>
                            <span class="text-xl font-bold text-white">{{ number_format($stats['completed_orders']) }} Order</span>
                        </div>
                        <div class="bg-white/10 backdrop-blur-md px-5 py-3.5 rounded-2xl border border-white/10">
                            <span class="text-[11px] text-slate-300 block">Total Transaksi</span>
                            <span class="text-xl font-bold text-white">{{ number_format($stats['total_transactions']) }} Trx</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 6 Summary Metric Cards -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-4">
                <div class="bg-white/90 backdrop-blur-md p-5 rounded-2xl border border-orange-100 shadow-sm">
                    <span class="text-[11px] font-bold text-slate-500 block uppercase">Total Transaksi</span>
                    <h3 class="text-2xl font-extrabold text-slate-900 mt-1">{{ number_format($stats['total_transactions']) }}</h3>
                    <span class="text-[10px] text-slate-400">Dalam periode filter</span>
                </div>
                <div class="bg-white/90 backdrop-blur-md p-5 rounded-2xl border border-orange-100 shadow-sm">
                    <span class="text-[11px] font-bold text-emerald-600 block uppercase">Pendapatan Bersih</span>
                    <h3 class="text-lg font-extrabold text-emerald-700 mt-1">Rp {{ number_format($stats['net_revenue'], 0, ',', '.') }}</h3>
                    <span class="text-[10px] text-slate-400">Lunas - Refund</span>
                </div>
                <div class="bg-white/90 backdrop-blur-md p-5 rounded-2xl border border-orange-100 shadow-sm">
                    <span class="text-[11px] font-bold text-blue-600 block uppercase">Pesanan Selesai</span>
                    <h3 class="text-2xl font-extrabold text-blue-700 mt-1">{{ number_format($stats['completed_orders']) }}</h3>
                    <span class="text-[10px] text-slate-400">Status Completed</span>
                </div>
                <div class="bg-white/90 backdrop-blur-md p-5 rounded-2xl border border-orange-100 shadow-sm">
                    <span class="text-[11px] font-bold text-rose-600 block uppercase">Pesanan Dibatalkan</span>
                    <h3 class="text-2xl font-extrabold text-rose-700 mt-1">{{ number_format($stats['cancelled_orders']) }}</h3>
                    <span class="text-[10px] text-slate-400">Status Cancelled</span>
                </div>
                <div class="bg-white/90 backdrop-blur-md p-5 rounded-2xl border border-orange-100 shadow-sm">
                    <span class="text-[11px] font-bold text-amber-600 block uppercase">Pembayaran Pending</span>
                    <h3 class="text-2xl font-extrabold text-amber-700 mt-1">{{ number_format($stats['pending_payments']) }}</h3>
                    <span class="text-[10px] text-slate-400">Menunggu / Verifikasi</span>
                </div>
                <div class="bg-white/90 backdrop-blur-md p-5 rounded-2xl border border-orange-100 shadow-sm">
                    <span class="text-[11px] font-bold text-teal-600 block uppercase">Pembayaran Berhasil</span>
                    <h3 class="text-2xl font-extrabold text-teal-700 mt-1">{{ number_format($stats['paid_payments']) }}</h3>
                    <span class="text-[10px] text-slate-400">Status Paid</span>
                </div>
            </div>

            <!-- Revenue Trend Dynamic Chart -->
            <div class="bg-white/90 backdrop-blur-md p-6 rounded-3xl border border-orange-100 shadow-sm">
                <div class="flex items-center justify-between mb-4">
                    <div>
                        <h3 class="font-bold text-slate-900 text-lg">Grafik Tren Pendapatan Servis Kompor</h3>
                        <p class="text-xs text-slate-500">
                            Periode: <span class="font-bold text-orange-600 uppercase">{{ $period }}</span> ({{ $startDate->format('d M Y') }} - {{ $endDate->format('d M Y') }})
                        </p>
                    </div>
                    <span class="text-xs border border-slate-200 px-3 py-1 rounded-lg {{ $stats['profit_growth'] >= 0 ? 'text-emerald-600 bg-emerald-50' : 'text-rose-600 bg-rose-50' }} font-bold">
                        {{ $stats['profit_growth'] >= 0 ? '+' : '' }}{{ $stats['profit_growth'] }}% Profit Growth
                    </span>
                </div>
                <div class="h-72">
                    <canvas id="reportChart"></canvas>
                </div>
            </div>

            <!-- Transactions Detail Table -->
            <div class="bg-white/90 backdrop-blur-md p-6 rounded-3xl border border-orange-100 shadow-sm space-y-4">
                <div class="flex items-center justify-between">
                    <div>
                        <h3 class="font-bold text-slate-900 text-lg">Riwayat Transaksi Pembayaran</h3>
                        <p class="text-xs text-slate-500">Daftar transaksi aktual dalam rentang waktu yang dipilih</p>
                    </div>
                    <span class="text-xs font-semibold text-slate-500">{{ $transactions->total() }} Transaksi ditemukan</span>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs">
                        <thead>
                            <tr class="border-b border-slate-200 text-slate-500 uppercase font-bold bg-slate-50/50">
                                <th class="py-3 px-4">No. Transaksi</th>
                                <th class="py-3 px-4">No. Pesanan</th>
                                <th class="py-3 px-4">Pelanggan</th>
                                <th class="py-3 px-4">Metode</th>
                                <th class="py-3 px-4">Nominal</th>
                                <th class="py-3 px-4">Status</th>
                                <th class="py-3 px-4">Waktu Buat</th>
                                <th class="py-3 px-4">Waktu Lunas</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 font-medium text-slate-700">
                            @forelse($transactions as $trx)
                                <tr class="hover:bg-orange-50/30 transition">
                                    <td class="py-3 px-4 font-mono font-bold text-slate-900">
                                        {{ $trx->payment_number ?? ('TRX-' . $trx->id) }}
                                    </td>
                                    <td class="py-3 px-4">
                                        {{ $trx->order?->order_number ?? '-' }}
                                    </td>
                                    <td class="py-3 px-4">
                                        {{ $trx->customer?->name ?? ($trx->order?->customer_name ?? 'Pelanggan') }}
                                    </td>
                                    <td class="py-3 px-4 uppercase font-semibold">
                                        {{ $trx->payment_method }}
                                    </td>
                                    <td class="py-3 px-4 font-bold text-slate-900">
                                        Rp {{ number_format($trx->amount, 0, ',', '.') }}
                                    </td>
                                    <td class="py-3 px-4">
                                        @if($trx->payment_status === 'paid')
                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-700">LUNAS</span>
                                        @elseif(in_array($trx->payment_status, ['pending', 'awaiting_verification']))
                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-amber-100 text-amber-700">MENUNGGU</span>
                                        @elseif($trx->payment_status === 'refunded')
                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-purple-100 text-purple-700">REFUND</span>
                                        @else
                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-rose-100 text-rose-700">{{ strtoupper($trx->payment_status) }}</span>
                                        @endif
                                    </td>
                                    <td class="py-3 px-4 text-slate-500">
                                        {{ $trx->created_at->format('d/m/Y H:i') }}
                                    </td>
                                    <td class="py-3 px-4 text-slate-500">
                                        {{ $trx->paid_at ? $trx->paid_at->format('d/m/Y H:i') : '-' }}
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="text-center py-8 text-slate-400">
                                        Tidak ada data transaksi pembayaran pada rentang tanggal ini.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <div class="pt-4 border-t border-slate-100">
                    {{ $transactions->links() }}
                </div>
            </div>

        </div>
    </main>

    <script>
        lucide.createIcons();

        const chartLabels = @json($chartData['labels']);
        const chartData = @json($chartData['data']);

        const ctx = document.getElementById('reportChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: chartLabels,
                datasets: [{
                    label: 'Pendapatan Bersih (Rp)',
                    data: chartData,
                    backgroundColor: '#ff8000',
                    hoverBackgroundColor: '#ea580c',
                    borderRadius: 8,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                let val = context.parsed.y || 0;
                                return 'Pendapatan: Rp ' + val.toLocaleString('id-ID');
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return 'Rp ' + (value / 1000).toLocaleString('id-ID') + 'k';
                            }
                        }
                    },
                    x: { grid: { display: false } }
                }
            }
        });
    </script>
</body>
</html>
