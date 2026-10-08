<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin - KlikKompor</title>
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
    </style>
</head>
<body class="flex h-screen overflow-hidden bg-[#090b27]">

    <!-- Sidebar (Dark #090b27 with Gradient Glow) -->
    <aside class="w-68 bg-[#090b27] text-white flex flex-col justify-between hidden md:flex shrink-0 relative overflow-hidden border-r border-slate-800">
        <!-- Glow background accent -->
        <div class="absolute -top-24 -left-24 w-64 h-64 bg-orange-500/20 rounded-full blur-3xl animate-glow pointer-events-none"></div>

        <div class="relative z-10">
            <!-- Logo Brand (Enlarged) -->
            <div class="h-32 flex items-center px-6 gap-3">
                <img src="{{ asset('images/logo.png') }}" alt="Logo" class="w-20 h-16 object-contain animate-float drop-shadow-md" onerror="this.src='https://via.placeholder.com/80?text=KK'" />
                <span class="font-extrabold text-2xl text-orange-500 tracking-tight">KlikKompor</span>
            </div>

            <!-- Navigation Links -->
            <nav class="px-3 space-y-1.5">
                <a href="{{ route('admin.dashboard') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl bg-gradient-to-r from-orange-500 to-amber-500 text-white font-bold transition shadow-lg shadow-orange-500/25">
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
                <a href="{{ route('admin.reports') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="bar-chart-2" class="w-5 h-5"></i> Laporan
                </a>
                <a href="{{ route('admin.settings') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="settings" class="w-5 h-5"></i> Pengaturan
                </a>
            </nav>
        </div>

        <!-- Sidebar Bottom Info & Logout Button -->
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

        <!-- Top Header Bar (Generous Spacing & Un-cramped Notification Bell) -->
        <header class="h-28 border-b border-slate-200/80 flex items-center justify-between px-10 py-6 sticky top-0 bg-white/90 backdrop-blur-md z-20 shadow-sm">
            <div class="flex items-center gap-4">
                <button class="w-12 h-12 rounded-xl bg-slate-100 flex items-center justify-center text-slate-700 hover:text-black hover:bg-slate-200 transition shadow-sm transform hover:-translate-x-0.5">
                    <i data-lucide="arrow-left" class="w-6 h-6"></i>
                </button>
            </div>
            <div class="flex items-center gap-8">
                <!-- Search -->
                <div class="relative w-96">
                    <input type="text" placeholder="Cari pesanan, teknisi, pelanggan..." class="w-full bg-slate-100 border border-slate-200 rounded-full py-3 pl-5 pr-12 text-sm outline-none focus:border-orange-500 focus:bg-white transition shadow-sm" />
                    <i data-lucide="search" class="w-5 h-5 text-slate-400 absolute right-4 top-3.5"></i>
                </div>
                <!-- Notification Bell with Generous Spacing -->
                <button class="relative w-12 h-12 mx-2 rounded-2xl bg-slate-100/90 flex items-center justify-center text-slate-700 hover:bg-slate-200 transition shadow-sm hover:scale-105">
                    <i data-lucide="bell" class="w-6 h-6"></i>
                    <span class="absolute top-2.5 right-2.5 w-3 h-3 rounded-full bg-orange-500 animate-ping"></span>
                    <span class="absolute top-2.5 right-2.5 w-3 h-3 rounded-full bg-orange-500 border-2 border-white"></span>
                </button>
                <!-- Admin Profile Card -->
                <div class="flex items-center gap-3.5 bg-slate-50 border border-slate-200 rounded-2xl px-4 py-2.5 shadow-sm">
                    <div class="w-10 h-10 rounded-full bg-gradient-to-tr from-orange-500 to-amber-400 overflow-hidden flex items-center justify-center font-bold text-white shadow">
                        {{ strtoupper(substr(auth()->user()->name, 0, 2)) }}
                    </div>
                    <div>
                        <h4 class="text-xs font-bold text-slate-900">{{ auth()->user()->name }}</h4>
                        <span class="text-[10px] text-slate-500 font-medium">Administrator</span>
                    </div>
                </div>
            </div>
        </header>

        <!-- Body Dashboard -->
        <div class="p-8 space-y-8 animate-fade-in relative z-10">

            <!-- Greeting Banner with 3D feel -->
            <div class="relative bg-gradient-to-r from-[#090b27] to-[#1e1b4b] text-white p-8 rounded-3xl overflow-hidden shadow-xl">
                <div class="absolute -right-10 -bottom-10 w-64 h-64 bg-orange-500/30 rounded-full blur-3xl animate-glow"></div>
                <div class="relative z-10">
                    <span class="px-3 py-1 rounded-full text-xs font-bold bg-orange-500/30 text-orange-400 border border-orange-500/30">Panel Kontrol Aktif</span>
                    <h1 class="text-3xl font-extrabold mt-3">Halo, Admin</h1>
                    <p class="text-sm text-slate-300 mt-1">Selamat datang di dashboard KlikKompor. Berikut ringkasan aktivitas dan operasional hari ini.</p>
                </div>
            </div>

            <!-- Top 4 Metric Cards -->
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

            <!-- Middle Section: Continuously Live-Moving Charts -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

                <!-- Grafik Pesanan (Continuously Live Streaming Line Chart) -->
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm hover:shadow-md transition">
                    <div class="flex items-center justify-between mb-4">
                        <div>
                            <h3 class="font-bold text-slate-900 text-lg flex items-center gap-2">
                                Grafik Pesanan
                                <span class="w-2.5 h-2.5 rounded-full bg-orange-500 animate-ping"></span>
                            </h3>
                            <p class="text-xs text-slate-500">Jumlah Pesanan dalam 7 hari terakhir (Live Stream)</p>
                        </div>
                        <span class="text-xs border border-slate-200 px-3 py-1 rounded-lg text-orange-600 font-bold bg-orange-50 shadow-sm">Live Wave</span>
                    </div>
                    <div class="h-64">
                        <canvas id="orderChart"></canvas>
                    </div>
                </div>

                <!-- Status Pesanan (Continuously Rotating Donut Chart) -->
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm flex flex-col justify-between hover:shadow-md transition">
                    <div>
                        <h3 class="font-bold text-slate-900 text-lg flex items-center gap-2">
                            Status Pesanan
                            <span class="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-ping"></span>
                        </h3>
                        <p class="text-xs text-slate-500 mb-2">Persentase status layanan bergeser</p>
                    </div>
                    <div class="relative h-48 flex items-center justify-center">
                        <canvas id="statusChart"></canvas>
                        <div class="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                            <span class="text-xs text-slate-400 font-bold">Total</span>
                            <span class="text-2xl font-extrabold text-slate-900">{{ array_sum($statusCounts) }}</span>
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-2 mt-4 text-xs font-bold text-slate-700">
                        <div class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-amber-500 animate-pulse"></span> Menunggu ({{ $statusCounts['pending'] }})</div>
                        <div class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-blue-500 animate-pulse"></span> Diproses ({{ $statusCounts['processing'] }})</div>
                        <div class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-emerald-500 animate-pulse"></span> Perjalanan ({{ $statusCounts['on_the_way'] }})</div>
                        <div class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-purple-500 animate-pulse"></span> Selesai ({{ $statusCounts['completed'] }})</div>
                    </div>
                </div>

                <!-- Menu Cepat (Quick Actions) -->
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm flex flex-col justify-between hover:shadow-md transition">
                    <div>
                        <h3 class="font-bold text-slate-900 text-lg mb-1">Menu Cepat</h3>
                        <p class="text-xs text-slate-500 mb-4">Akses cepat operasional admin</p>
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div onclick="location.href='{{ route('admin.customers') }}'" class="p-4 rounded-2xl border border-slate-200 hover:border-orange-500 hover:bg-orange-50/50 cursor-pointer transition-all duration-300 transform hover:-translate-y-1 flex flex-col items-center text-center group">
                            <div class="w-12 h-12 rounded-2xl bg-orange-500 text-white flex items-center justify-center mb-2 shadow-md shadow-orange-500/30 group-hover:scale-110 transition-transform">
                                <i data-lucide="user-plus" class="w-6 h-6"></i>
                            </div>
                            <span class="text-xs font-bold text-slate-800 group-hover:text-orange-600">Tambah Pelanggan</span>
                        </div>
                        <div onclick="location.href='{{ route('admin.technicians') }}'" class="p-4 rounded-2xl border border-slate-200 hover:border-orange-500 hover:bg-orange-50/50 cursor-pointer transition-all duration-300 transform hover:-translate-y-1 flex flex-col items-center text-center group">
                            <div class="w-12 h-12 rounded-2xl bg-orange-500 text-white flex items-center justify-center mb-2 shadow-md shadow-orange-500/30 group-hover:scale-110 transition-transform">
                                <i data-lucide="wrench" class="w-6 h-6"></i>
                            </div>
                            <span class="text-xs font-bold text-slate-800 group-hover:text-orange-600">Tambah Teknisi</span>
                        </div>
                        <div onclick="location.href='{{ route('admin.services') }}'" class="p-4 rounded-2xl border border-slate-200 hover:border-orange-500 hover:bg-orange-50/50 cursor-pointer transition-all duration-300 transform hover:-translate-y-1 flex flex-col items-center text-center group">
                            <div class="w-12 h-12 rounded-2xl bg-orange-500 text-white flex items-center justify-center mb-2 shadow-md shadow-orange-500/30 group-hover:scale-110 transition-transform">
                                <i data-lucide="clipboard-plus" class="w-6 h-6"></i>
                            </div>
                            <span class="text-xs font-bold text-slate-800 group-hover:text-orange-600">Tambah Layanan</span>
                        </div>
                        <div onclick="location.href='{{ route('admin.settings') }}'" class="p-4 rounded-2xl border border-slate-200 hover:border-orange-500 hover:bg-orange-50/50 cursor-pointer transition-all duration-300 transform hover:-translate-y-1 flex flex-col items-center text-center group">
                            <div class="w-12 h-12 rounded-2xl bg-orange-500 text-white flex items-center justify-center mb-2 shadow-md shadow-orange-500/30 group-hover:scale-110 transition-transform">
                                <i data-lucide="tag" class="w-6 h-6"></i>
                            </div>
                            <span class="text-xs font-bold text-slate-800 group-hover:text-orange-600">Atur Tarif</span>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Bottom Section: Pesanan Terbaru, Teknisi Aktif, Laporan Layanan -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

                <!-- Pesanan Terbaru -->
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm hover:shadow-md transition">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="font-bold text-slate-900 text-lg">Pesanan Terbaru</h3>
                        <a href="#" class="text-xs text-sky-500 hover:underline font-bold">lihat semua</a>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-xs">
                            <thead>
                                <tr class="text-slate-400 border-b border-slate-200 font-semibold">
                                    <th class="pb-3">No. Pesanan</th>
                                    <th class="pb-3">Pelanggan</th>
                                    <th class="pb-3">Layanan</th>
                                    <th class="pb-3">Teknisi</th>
                                    <th class="pb-3">Status</th>
                                    <th class="pb-3">Waktu</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100">
                                @forelse($recentOrders as $order)
                                    <tr class="hover:bg-slate-50 transition">
                                        <td class="py-3.5 font-bold text-slate-900">{{ $order->order_number }}</td>
                                        <td class="py-3.5 text-slate-700 font-medium">{{ $order->customer_name ?? 'Pelanggan' }}</td>
                                        <td class="py-3.5 text-slate-600">{{ $order->stove_brand ?? 'Servis Kompor' }}</td>
                                        <td class="py-3.5 text-slate-700 font-medium">{{ $order->technician->name ?? 'Belum ada' }}</td>
                                        <td class="py-3.5">
                                            @php
                                                $stColor = match($order->status) {
                                                    'completed' => 'bg-purple-100 text-purple-700',
                                                    'on_the_way' => 'bg-emerald-100 text-emerald-700',
                                                    'in_progress', 'accepted' => 'bg-blue-100 text-blue-700',
                                                    'cancelled' => 'bg-red-100 text-red-700',
                                                    default => 'bg-amber-100 text-amber-700',
                                                };
                                            @endphp
                                            <span class="px-2.5 py-1 rounded-md font-bold text-[11px] {{ $stColor }}">
                                                {{ ucfirst(str_replace('_', ' ', $order->status)) }}
                                            </span>
                                        </td>
                                        <td class="py-3.5 text-slate-500 font-medium">{{ $order->created_at->format('H:i') }}</td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="6" class="py-6 text-center text-slate-400">Belum ada pesanan terbaru.</td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Teknisi Aktif -->
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm flex flex-col justify-between hover:shadow-md transition">
                    <div>
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-bold text-slate-900 text-lg">Teknisi Aktif</h3>
                            <a href="#" class="text-xs text-sky-500 hover:underline font-bold">lihat semua</a>
                        </div>
                        <div class="space-y-3">
                            @forelse($activeTechnicians as $tech)
                                <div class="flex items-center justify-between p-3.5 rounded-2xl border border-slate-200 bg-slate-50 hover:bg-slate-100/80 transition">
                                    <div class="flex items-center gap-3">
                                        <div class="w-11 h-11 rounded-full bg-orange-100 text-orange-600 font-bold flex items-center justify-center shadow-inner">
                                            {{ strtoupper(substr($tech->user->name ?? 'T', 0, 2)) }}
                                        </div>
                                        <div>
                                            <h4 class="text-sm font-bold text-slate-900">{{ $tech->user->name ?? 'Teknisi' }}</h4>
                                            <div class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                                                <span>⭐ {{ number_format($tech->rating_avg, 1) }} ({{ $tech->reviews_count }})</span>
                                                <span>•</span>
                                                <span>{{ $tech->jobs_completed_count }} layanan</span>
                                            </div>
                                        </div>
                                    </div>
                                    <span class="px-3 py-1 rounded-full text-xs font-bold {{ $tech->is_available ? 'bg-emerald-100 text-emerald-700 animate-pulse' : 'bg-slate-200 text-slate-600' }}">
                                        {{ $tech->is_available ? 'Online' : 'Offline' }}
                                    </span>
                                </div>
                            @empty
                                <div class="py-8 text-center text-slate-400 text-sm">Tidak ada teknisi aktif.</div>
                            @endforelse
                        </div>
                    </div>
                </div>

                <!-- Laporan Layanan -->
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm flex flex-col justify-between hover:shadow-md transition">
                    <div>
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-bold text-slate-900 text-lg">Laporan Layanan</h3>
                            <a href="#" class="text-xs text-sky-500 hover:underline font-bold">lihat semua</a>
                        </div>
                        <div class="space-y-3 text-sm">
                            <div class="flex items-center justify-between p-3.5 rounded-xl border border-slate-200 bg-slate-50">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-xl bg-orange-500 text-white flex items-center justify-center shadow">
                                        <i data-lucide="clipboard" class="w-4 h-4"></i>
                                    </div>
                                    <span class="font-bold text-slate-800 text-xs">Total Pesanan Hari Ini</span>
                                </div>
                                <span class="font-extrabold text-slate-900 text-sm">{{ $stats['today_orders'] }}</span>
                            </div>

                            <div class="flex items-center justify-between p-3.5 rounded-xl border border-slate-200 bg-slate-50">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-xl bg-emerald-500 text-white flex items-center justify-center shadow">
                                        <i data-lucide="check" class="w-4 h-4"></i>
                                    </div>
                                    <span class="font-bold text-slate-800 text-xs">Layanan Pesanan</span>
                                </div>
                                <span class="font-extrabold text-slate-900 text-sm">{{ $stats['completed_orders'] }}</span>
                            </div>

                            <div class="flex items-center justify-between p-3.5 rounded-xl border border-slate-200 bg-slate-50">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-xl bg-blue-500 text-white flex items-center justify-center shadow">
                                        <i data-lucide="clock" class="w-4 h-4"></i>
                                    </div>
                                    <span class="font-bold text-slate-800 text-xs">Dalam Proses</span>
                                </div>
                                <span class="font-extrabold text-slate-900 text-sm">{{ $statusCounts['processing'] + $statusCounts['on_the_way'] }}</span>
                            </div>

                            <div class="flex items-center justify-between p-3.5 rounded-xl border border-slate-200 bg-slate-50">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-xl bg-red-500 text-white flex items-center justify-center shadow">
                                        <i data-lucide="x" class="w-4 h-4"></i>
                                    </div>
                                    <span class="font-bold text-slate-800 text-xs">Dibatalkan</span>
                                </div>
                                <span class="font-extrabold text-slate-900 text-sm">{{ $statusCounts['cancelled'] }}</span>
                            </div>
                        </div>
                    </div>

                    <!-- Revenue Card Bottom -->
                    <div class="mt-4 p-4 rounded-2xl bg-gradient-to-br from-orange-50 to-amber-50 border border-orange-200/80 flex items-center justify-between shadow-sm">
                        <div>
                            <span class="text-[10px] font-bold text-orange-600 uppercase tracking-wider">Pendapatan Bulan Ini</span>
                            <h4 class="text-xl font-extrabold text-slate-900 mt-0.5">Rp {{ number_format($stats['revenue'], 0, ',', '.') }}</h4>
                            <span class="text-[10px] text-slate-500 font-medium">Dari Bulan Lalu</span>
                        </div>
                        <div class="text-right">
                            <span class="text-xs font-extrabold text-green-600 bg-green-100 px-2 py-1 rounded-lg flex items-center gap-0.5">
                                <i data-lucide="arrow-up" class="w-3 h-3"></i> +14%
                            </span>
                        </div>
                    </div>
                </div>

            </div>

        </div>
    </main>

    <script>
        lucide.createIcons();

        // Line Chart (Grafik Pesanan) with continuous live breathing simulation
        const ctxOrder = document.getElementById('orderChart').getContext('2d');
        const gradient = ctxOrder.createLinearGradient(0, 0, 0, 250);
        gradient.addColorStop(0, 'rgba(255, 128, 0, 0.35)');
        gradient.addColorStop(1, 'rgba(255, 128, 0, 0.0)');

        const baseChartData = {!! json_encode($chartCounts) !!};

        const orderChart = new Chart(ctxOrder, {
            type: 'line',
            data: {
                labels: {!! json_encode($chartDays) !!},
                datasets: [{
                    label: 'Pesanan',
                    data: [...baseChartData],
                    borderColor: '#ff8000',
                    backgroundColor: gradient,
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#ff8000',
                    pointRadius: 5,
                    pointHoverRadius: 8,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: {
                    duration: 2000,
                    easing: 'easeInOutQuart',
                },
                plugins: { legend: { display: false } },
                scales: {
                    y: { beginAtZero: true, grid: { color: '#f1f5f9' }, ticks: { font: { family: 'Inter', size: 11 } } },
                    x: { grid: { display: false }, ticks: { font: { family: 'Inter', size: 11 } } }
                }
            }
        });

        // Continuously animated live pulse effect on line chart points every 3 seconds
        let waveStep = 0;
        setInterval(() => {
            waveStep += 0.3;
            const datasets = orderChart.data.datasets[0].data;
            const lastIdx = datasets.length - 1;
            const baseVal = baseChartData[lastIdx];
            // Sine wave continuous live movement on the chart line itself
            datasets[lastIdx] = Math.max(1, Math.round(baseVal + Math.sin(waveStep) * 3));
            orderChart.update('none'); // smooth realtime streaming movement
        }, 1200);

        // Donut Chart (Status Pesanan) with continuous gentle rotation simulation
        const ctxStatus = document.getElementById('statusChart').getContext('2d');
        const statusChart = new Chart(ctxStatus, {
            type: 'doughnut',
            data: {
                labels: ['Menunggu', 'Diproses', 'Perjalanan', 'Selesai'],
                datasets: [{
                    data: [
                        {{ $statusCounts['pending'] }},
                        {{ $statusCounts['processing'] }},
                        {{ $statusCounts['on_the_way'] }},
                        {{ $statusCounts['completed'] }}
                    ],
                    backgroundColor: ['#f59e0b', '#3b82f6', '#10b981', '#a855f7'],
                    borderWidth: 0,
                    hoverOffset: 6,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: {
                    duration: 2000,
                    easing: 'easeInOutQuart',
                    animateRotate: true,
                    animateScale: true,
                },
                plugins: { legend: { display: false } },
                cutout: '75%',
            }
        });
    </script>
</body>
</html>
