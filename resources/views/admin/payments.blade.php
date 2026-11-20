<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Pembayaran - Admin KlikKompor</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
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
    </style>
</head>
<body class="flex h-screen overflow-hidden bg-[#090b27]">

    <!-- Sidebar (Dark #090b27 with Active Pembayaran) -->
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
                <a href="{{ route('admin.payments') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl bg-gradient-to-r from-orange-500 to-amber-500 text-white font-bold transition shadow-lg shadow-orange-500/25">
                    <i data-lucide="credit-card" class="w-5 h-5"></i> Pembayaran
                </a>
                <a href="{{ route('admin.reviews') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="message-square" class="w-5 h-5"></i> Ulasan
                </a>
                <a href="{{ route('admin.reports') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="bar-chart-2" class="w-5 h-5"></i> Laporan
                </a>
                <a href="{{ route('admin.dashboard_management') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="image" class="w-5 h-5"></i> Banner Dashboard
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
                    <span class="text-[10px] text-slate-400">Laravel v12 • PHP 8.4</span>
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

    <!-- Main Content Area with Orange Highlight Ambient Background -->
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
            </div>
            <div class="flex items-center gap-8">
                <!-- Search -->
                <div class="relative w-96">
                    <input type="text" placeholder="Cari transaksi pembayaran..." class="w-full bg-slate-100 border border-slate-200 rounded-full py-3 pl-5 pr-12 text-sm outline-none focus:border-orange-500 focus:bg-white transition shadow-sm" />
                    <i data-lucide="search" class="w-5 h-5 text-slate-400 absolute right-4 top-3.5"></i>
                </div>
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

            <!-- Page Title -->
            <div>
                <h1 class="text-3xl font-extrabold text-slate-900">Pembayaran</h1>
            </div>

            <!-- Top 4 Metric Cards with Exact Dashboard Structure & Animations -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">

                <!-- Card 1: Total Pengguna -->
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 relative overflow-hidden group">
                    <div class="absolute top-0 right-0 w-24 h-24 bg-orange-500/5 rounded-bl-full group-hover:scale-125 transition-transform"></div>
                    <div class="relative z-10 flex items-center justify-between">
                        <div>
                            <p class="text-xs font-bold text-slate-500 uppercase tracking-wide">Total pengguna</p>
                            <h3 class="text-3xl font-extrabold text-slate-900 mt-1">{{ number_format($stats['total_users']) }}</h3>
                            <div class="flex items-center gap-1 mt-2 text-xs text-green-600 font-bold bg-green-50 px-2 py-0.5 rounded-md w-fit">
                                <i data-lucide="arrow-up" class="w-3 h-3"></i> +12% <span class="text-slate-500 font-normal">Dari Bulan Lalu</span>
                            </div>
                        </div>
                        <div class="w-14 h-14 rounded-2xl bg-orange-100 text-orange-600 flex items-center justify-center shadow-inner group-hover:rotate-6 transition-transform">
                            <i data-lucide="users" class="w-7 h-7"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 2: Total Teknisi -->
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 relative overflow-hidden group">
                    <div class="absolute top-0 right-0 w-24 h-24 bg-orange-500/5 rounded-bl-full group-hover:scale-125 transition-transform"></div>
                    <div class="relative z-10 flex items-center justify-between">
                        <div>
                            <p class="text-xs font-bold text-slate-500 uppercase tracking-wide">Total Teknisi</p>
                            <h3 class="text-3xl font-extrabold text-slate-900 mt-1">{{ number_format($stats['total_technicians']) }}</h3>
                            <div class="flex items-center gap-1 mt-2 text-xs text-green-600 font-bold bg-green-50 px-2 py-0.5 rounded-md w-fit">
                                <i data-lucide="arrow-up" class="w-3 h-3"></i> +5% <span class="text-slate-500 font-normal">Dari Bulan Lalu</span>
                            </div>
                        </div>
                        <div class="w-14 h-14 rounded-2xl bg-orange-100 text-orange-600 flex items-center justify-center shadow-inner group-hover:rotate-6 transition-transform">
                            <i data-lucide="wrench" class="w-7 h-7"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 3: Pesanan Hari Ini -->
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 relative overflow-hidden group">
                    <div class="absolute top-0 right-0 w-24 h-24 bg-orange-500/5 rounded-bl-full group-hover:scale-125 transition-transform"></div>
                    <div class="relative z-10 flex items-center justify-between">
                        <div>
                            <p class="text-xs font-bold text-slate-500 uppercase tracking-wide">Pesanan Hari Ini</p>
                            <h3 class="text-3xl font-extrabold text-slate-900 mt-1">{{ number_format($stats['today_orders']) }}</h3>
                            <div class="flex items-center gap-1 mt-2 text-xs text-green-600 font-bold bg-green-50 px-2 py-0.5 rounded-md w-fit">
                                <i data-lucide="arrow-up" class="w-3 h-3"></i> +18% <span class="text-slate-500 font-normal">Dari Bulan Lalu</span>
                            </div>
                        </div>
                        <div class="w-14 h-14 rounded-2xl bg-orange-100 text-orange-600 flex items-center justify-center shadow-inner group-hover:rotate-6 transition-transform">
                            <i data-lucide="clipboard" class="w-7 h-7"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 4: Layanan Selesai -->
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 relative overflow-hidden group">
                    <div class="absolute top-0 right-0 w-24 h-24 bg-purple-500/5 rounded-bl-full group-hover:scale-125 transition-transform"></div>
                    <div class="relative z-10 flex items-center justify-between">
                        <div>
                            <p class="text-xs font-bold text-slate-500 uppercase tracking-wide">Layanan Selesai</p>
                            <h3 class="text-3xl font-extrabold text-slate-900 mt-1">{{ number_format($stats['completed_orders']) }}</h3>
                            <div class="flex items-center gap-1 mt-2 text-xs text-green-600 font-bold bg-green-50 px-2 py-0.5 rounded-md w-fit">
                                <i data-lucide="arrow-up" class="w-3 h-3"></i> +28% <span class="text-slate-500 font-normal">Dari Bulan Lalu</span>
                            </div>
                        </div>
                        <div class="w-14 h-14 rounded-2xl bg-purple-100 text-purple-600 flex items-center justify-center shadow-inner group-hover:rotate-6 transition-transform">
                            <i data-lucide="check-circle" class="w-7 h-7"></i>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Kelola Pembayaran Section -->
            <div class="bg-white/90 backdrop-blur-md rounded-3xl border border-orange-100 shadow-sm p-8 space-y-6 hover:shadow-md transition">

                <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <h2 class="text-xl font-extrabold text-slate-900">Daftar Transaksi Pembayaran</h2>
                        <p class="text-xs text-slate-500 mt-0.5">{{ $payments->count() }} Transaksi Tercatat</p>
                    </div>

                    <div class="flex items-center gap-4">
                        <!-- Search Bar with Enter Icon Switch -->
                        <div class="relative w-72">
                            <input type="text" placeholder="Cari transaksi..." class="w-full bg-slate-100 border border-slate-200 rounded-xl py-2.5 pl-4 pr-10 text-xs outline-none focus:border-orange-500 focus:bg-white transition" />
                            <i data-lucide="search" class="w-4 h-4 text-slate-400 absolute right-3.5 top-3 transition-all duration-300"></i>
                        </div>
                    </div>
                </div>

                <!-- Payments Table -->
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm border-collapse">
                        <thead>
                            <tr class="bg-orange-500 text-white font-bold rounded-xl overflow-hidden text-xs">
                                <th class="py-4 px-6 rounded-l-xl">No. Transaksi</th>
                                <th class="py-4 px-6">No. Pesanan</th>
                                <th class="py-4 px-6">Pelanggan</th>
                                <th class="py-4 px-6">Metode</th>
                                <th class="py-4 px-6">Nominal</th>
                                <th class="py-4 px-6">Status</th>
                                <th class="py-4 px-6">Waktu Transaksi</th>
                                <th class="py-4 px-6 rounded-r-xl text-center">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 text-xs">
                            @forelse($payments as $index => $payment)
                                <tr class="hover:bg-slate-50 transition">
                                    <td class="py-4 px-6 font-bold text-slate-900">{{ $payment->payment_number ?? '-' }}</td>
                                    <td class="py-4 px-6 text-slate-700 font-semibold">{{ $payment->order?->order_number ?? '-' }}</td>
                                    <td class="py-4 px-6 text-slate-900 font-bold">{{ $payment->customer?->name ?? $payment->order?->customer_name ?? 'Pelanggan' }}</td>
                                    <td class="py-4 px-6 text-slate-800 font-semibold uppercase">
                                        @php
                                            $methodLabel = match($payment->payment_method) {
                                                'cash' => 'Tunai (COD)',
                                                'transfer' => 'Virtual Account (' . strtoupper($payment->bank_name ?? 'Bank') . ')',
                                                'qris' => 'QRIS Dinamis',
                                                default => strtoupper($payment->payment_method ?? 'Tunai'),
                                            };
                                        @endphp
                                        {{ $methodLabel }}
                                    </td>
                                    <td class="py-4 px-6 text-slate-900 font-bold">Rp {{ number_format($payment->amount ?? 0, 0, ',', '.') }}</td>
                                    <td class="py-4 px-6">
                                        @php
                                            $statusBadge = match($payment->payment_status) {
                                                'paid' => ['bg' => 'bg-emerald-500', 'text' => 'Lunas'],
                                                'pending' => ['bg' => 'bg-amber-500', 'text' => 'Menunggu Pembayaran'],
                                                'awaiting_verification' => ['bg' => 'bg-blue-500', 'text' => 'Menunggu Verifikasi'],
                                                'expired' => ['bg' => 'bg-slate-500', 'text' => 'Kedaluwarsa'],
                                                'failed' => ['bg' => 'bg-rose-500', 'text' => 'Gagal'],
                                                'refunded' => ['bg' => 'bg-purple-500', 'text' => 'Di-refund'],
                                                'cancelled' => ['bg' => 'bg-zinc-400', 'text' => 'Dibatalkan'],
                                                default => ['bg' => 'bg-slate-400', 'text' => ucfirst($payment->payment_status)],
                                            };
                                        @endphp
                                        <span class="px-2.5 py-1 rounded-full text-[11px] font-bold text-white {{ $statusBadge['bg'] }}">
                                            {{ $statusBadge['text'] }}
                                        </span>
                                    </td>
                                    <td class="py-4 px-6 text-slate-600 font-medium">
                                        <div>{{ $payment->created_at->format('d/m/Y H:i') }}</div>
                                        @if($payment->paid_at)
                                            <div class="text-[10px] text-emerald-600 font-semibold">Lunas: {{ $payment->paid_at->format('d/m/Y H:i') }}</div>
                                        @endif
                                    </td>
                                    <td class="py-4 px-6 text-center">
                                        <div class="flex items-center justify-center gap-1.5 flex-wrap">
                                            @if($payment->payment_method === 'transfer' && $payment->proof_url)
                                                <a href="{{ route('admin.payments.proof', $payment->id) }}" target="_blank" class="px-2.5 py-1 rounded bg-blue-100 text-blue-700 hover:bg-blue-200 font-bold text-[11px] transition" title="Lihat Bukti Transfer">
                                                    Lihat Bukti
                                                </a>
                                            @endif
                                            @if($payment->payment_method === 'transfer' && $payment->payment_status === 'awaiting_verification')
                                                <button onclick="openVerifyTransferModal({{ $payment->id }}, '{{ $payment->payment_number }}')" class="px-2.5 py-1 rounded bg-emerald-500 text-white hover:bg-emerald-600 font-bold text-[11px] transition">
                                                    Verifikasi
                                                </button>
                                            @elseif($payment->payment_method === 'cash' && $payment->payment_status !== 'paid')
                                                <button onclick="openVerifyCashModal({{ $payment->id }}, '{{ $payment->payment_number }}')" class="px-2.5 py-1 rounded bg-amber-500 text-white hover:bg-amber-600 font-bold text-[11px] transition">
                                                    Verifikasi Tunai
                                                </button>
                                            @elseif($payment->payment_status === 'paid')
                                                <button onclick="openRefundModal({{ $payment->id }}, '{{ $payment->payment_number }}')" class="px-2.5 py-1 rounded bg-red-100 text-red-600 hover:bg-red-200 font-bold text-[11px] transition">
                                                    Refund
                                                </button>
                                            @endif
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="py-8 text-center text-slate-500 font-medium">
                                        Tidak ada data transaksi pembayaran yang ditemukan.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

            </div>

        </div>
    </main>

    <script>
        lucide.createIcons();

    <!-- Modal Verifikasi Tunai -->
    <div id="modalVerifyCash" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-md w-full p-6 space-y-4 shadow-xl">
            <h3 class="text-lg font-extrabold text-slate-900">Verifikasi Pembayaran Tunai</h3>
            <p class="text-xs text-slate-600">Pastikan uang tunai telah diterima secara sah oleh teknisi atau disetorkan ke kasir.</p>
            <input type="hidden" id="cashPaymentId">
            <div>
                <label class="block text-xs font-semibold text-slate-700 mb-1">Catatan Tambahan (Opsional)</label>
                <textarea id="cashNotes" rows="2" class="w-full text-xs border border-slate-200 rounded-xl p-2.5 focus:outline-none focus:border-orange-500" placeholder="Contoh: Diterima langsung di kantor kasir..."></textarea>
            </div>
            <div class="flex justify-end gap-2 pt-2">
                <button onclick="closeModal('modalVerifyCash')" class="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100">Batal</button>
                <button onclick="submitVerifyCash(false)" class="px-4 py-2 rounded-xl text-xs font-bold bg-rose-100 text-rose-600 hover:bg-rose-200">Tolak</button>
                <button onclick="submitVerifyCash(true)" class="px-4 py-2 rounded-xl text-xs font-bold bg-emerald-500 text-white hover:bg-emerald-600">Setujui Tunai</button>
            </div>
        </div>
    </div>

    <!-- Modal Verifikasi Transfer -->
    <div id="modalVerifyTransfer" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-md w-full p-6 space-y-4 shadow-xl">
            <h3 class="text-lg font-extrabold text-slate-900">Verifikasi Bukti Transfer</h3>
            <input type="hidden" id="transferPaymentId">
            <div>
                <label class="block text-xs font-semibold text-slate-700 mb-1">Alasan Penolakan (Wajib jika ditolak)</label>
                <textarea id="transferRejectionReason" rows="2" class="w-full text-xs border border-slate-200 rounded-xl p-2.5 focus:outline-none focus:border-orange-500" placeholder="Contoh: Bukti transfer buram atau nominal tidak sesuai..."></textarea>
            </div>
            <div class="flex justify-end gap-2 pt-2">
                <button onclick="closeModal('modalVerifyTransfer')" class="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100">Batal</button>
                <button onclick="submitVerifyTransfer(false)" class="px-4 py-2 rounded-xl text-xs font-bold bg-rose-100 text-rose-600 hover:bg-rose-200">Tolak Bukti</button>
                <button onclick="submitVerifyTransfer(true)" class="px-4 py-2 rounded-xl text-xs font-bold bg-emerald-500 text-white hover:bg-emerald-600">Setujui Transfer</button>
            </div>
        </div>
    </div>

    <!-- Modal Refund -->
    <div id="modalRefund" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-md w-full p-6 space-y-4 shadow-xl">
            <h3 class="text-lg font-extrabold text-slate-900">Refund Transaksi Pembayaran</h3>
            <input type="hidden" id="refundPaymentId">
            <div>
                <label class="block text-xs font-semibold text-slate-700 mb-1">Alasan Pengembalian Dana (Refund)</label>
                <textarea id="refundReason" rows="2" class="w-full text-xs border border-slate-200 rounded-xl p-2.5 focus:outline-none focus:border-orange-500" placeholder="Contoh: Permintaan pembatalan order oleh pelanggan..."></textarea>
            </div>
            <div class="flex justify-end gap-2 pt-2">
                <button onclick="closeModal('modalRefund')" class="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100">Batal</button>
                <button onclick="submitRefund()" class="px-4 py-2 rounded-xl text-xs font-bold bg-rose-600 text-white hover:bg-rose-700">Proses Refund</button>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();

        function closeModal(id) {
            document.getElementById(id).classList.add('hidden');
        }

        function openVerifyCashModal(id, payNum) {
            document.getElementById('cashPaymentId').value = id;
            document.getElementById('cashNotes').value = '';
            document.getElementById('modalVerifyCash').classList.remove('hidden');
        }

        function openVerifyTransferModal(id, payNum) {
            document.getElementById('transferPaymentId').value = id;
            document.getElementById('transferRejectionReason').value = '';
            document.getElementById('modalVerifyTransfer').classList.remove('hidden');
        }

        function openRefundModal(id, payNum) {
            document.getElementById('refundPaymentId').value = id;
            document.getElementById('refundReason').value = '';
            document.getElementById('modalRefund').classList.remove('hidden');
        }

        async function submitVerifyCash(approved) {
            const id = document.getElementById('cashPaymentId').value;
            const notes = document.getElementById('cashNotes').value;
            try {
                const res = await fetch(`/admin/payments/${id}/verify-cash`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({ approved, notes })
                });
                const data = await res.json();
                if (data.success) {
                    alert(data.message);
                    window.location.reload();
                } else {
                    alert('Gagal: ' + (data.message || 'Terjadi kesalahan.'));
                }
            } catch (e) {
                alert('Koneksi bermasalah: ' + e.message);
            }
        }

        async function submitVerifyTransfer(approved) {
            const id = document.getElementById('transferPaymentId').value;
            const rejectionReason = document.getElementById('transferRejectionReason').value;
            if (!approved && !rejectionReason.trim()) {
                alert('Harap isi alasan penolakan bukti transfer!');
                return;
            }
            try {
                const res = await fetch(`/admin/payments/${id}/verify-transfer`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({ approved, rejection_reason: rejectionReason })
                });
                const data = await res.json();
                if (data.success) {
                    alert(data.message);
                    window.location.reload();
                } else {
                    alert('Gagal: ' + (data.message || 'Terjadi kesalahan.'));
                }
            } catch (e) {
                alert('Koneksi bermasalah: ' + e.message);
            }
        }

        async function submitRefund() {
            const id = document.getElementById('refundPaymentId').value;
            const reason = document.getElementById('refundReason').value;
            if (!reason.trim()) {
                alert('Harap isi alasan pengembalian dana (refund)!');
                return;
            }
            try {
                const res = await fetch(`/api/v1/payments/${id}/refund`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({ reason })
                });
                const data = await res.json();
                if (data.success) {
                    alert('Refund berhasil diproses.');
                    window.location.reload();
                } else {
                    alert('Gagal refund: ' + (data.message || 'Terjadi kesalahan.'));
                }
            } catch (e) {
                alert('Koneksi bermasalah: ' + e.message);
            }
        }

        // Interactive Live Search & Search Icon Switch to Enter Icon
        document.querySelectorAll('input[type="text"]').forEach(input => {
            const iconContainer = input.parentElement.querySelector('i');

            input.addEventListener('focus', () => {
                if(iconContainer) {
                    iconContainer.setAttribute('data-lucide', 'corner-down-left');
                    lucide.createIcons();
                }
            });

            input.addEventListener('blur', () => {
                if(iconContainer && input.value === '') {
                    iconContainer.setAttribute('data-lucide', 'search');
                    lucide.createIcons();
                }
            });

            input.addEventListener('input', (e) => {
                const query = e.target.value.toLowerCase();
                const container = input.closest('.bg-white\\/90, .bg-white');
                if(container) {
                    const table = container.querySelector('tbody');
                    if(table) {
                        const rows = table.querySelectorAll('tr');
                        rows.forEach(row => {
                            const text = row.textContent.toLowerCase();
                            row.style.display = text.includes(query) ? '' : 'none';
                        });
                    }
                }
            });

            input.addEventListener('keypress', (e) => {
                if(e.key === 'Enter') {
                    e.preventDefault();
                    alert('Pencarian untuk: "' + input.value + '" dijalankan.');
                }
            });
        });

        // Printer action
        document.querySelectorAll('button[title="Cetak Resi"]').forEach(btn => {
            btn.addEventListener('click', () => {
                alert('Resi transaksi pembayaran sedang dicetak...');
            });
        });

        // Delete action
        document.querySelectorAll('button[title="Hapus"]').forEach(btn => {
            btn.addEventListener('click', () => {
                if(confirm('Apakah Anda yakin ingin menghapus data pembayaran ini?')) {
                    alert('Data pembayaran berhasil dihapus.');
                    btn.closest('tr').remove();
                }
            });
        });
    </script>
</body>
</html>
