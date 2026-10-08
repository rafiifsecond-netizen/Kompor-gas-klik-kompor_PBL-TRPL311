<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Ulasan - Admin KlikKompor</title>
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
                <a href="{{ route('admin.reviews') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl bg-gradient-to-r from-orange-500 to-amber-500 text-white font-bold transition shadow-lg shadow-orange-500/25">
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
            </div>
            <div class="flex items-center gap-8">
                <!-- Search -->
                <div class="relative w-96">
                    <input type="text" placeholder="Cari ulasan..." class="w-full bg-slate-100 border border-slate-200 rounded-full py-3 pl-5 pr-12 text-sm outline-none focus:border-orange-500 focus:bg-white transition shadow-sm" />
                    <i data-lucide="search" class="w-5 h-5 text-slate-400 absolute right-4 top-3.5"></i>
                </div>
                <!-- Notification Bell -->
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

        <!-- Body Content -->
        <div class="p-8 space-y-8 animate-fade-in relative z-10">

            @if(session('success'))
                <div class="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-bold flex items-center gap-3 shadow-sm">
                    <i data-lucide="check-circle" class="w-5 h-5 text-emerald-600"></i>
                    <span>{{ session('success') }}</span>
                </div>
            @endif

            <!-- Page Title -->
            <div>
                <h1 class="text-3xl font-extrabold text-slate-900">Ulasan & Rating Pelanggan</h1>
            </div>

            <!-- Top 4 Metric Cards -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <!-- Card 1 -->
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

                <!-- Card 2 -->
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

                <!-- Card 3 -->
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

                <!-- Card 4 -->
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

            <!-- Kelola Ulasan Section -->
            <div class="bg-white/90 backdrop-blur-md rounded-3xl border border-orange-100 shadow-sm p-8 space-y-6 hover:shadow-md transition">

                <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <h2 class="text-xl font-extrabold text-slate-900">Daftar Ulasan & Kepuasan Pelanggan</h2>
                        <p class="text-xs text-slate-500 mt-0.5">{{ $reviews->count() }} Ulasan Masuk</p>
                    </div>

                    <div class="flex items-center gap-4">
                        <!-- Search Bar -->
                        <div class="relative w-72">
                            <input type="text" placeholder="Cari ulasan..." class="w-full bg-slate-100 border border-slate-200 rounded-xl py-2.5 pl-4 pr-10 text-xs outline-none focus:border-orange-500 focus:bg-white transition" />
                            <i data-lucide="search" class="w-4 h-4 text-slate-400 absolute right-3.5 top-3 transition-all duration-300"></i>
                        </div>
                    </div>
                </div>

                <!-- Reviews Table -->
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm border-collapse">
                        <thead>
                            <tr class="bg-orange-500 text-white font-bold rounded-xl overflow-hidden text-xs">
                                <th class="py-4 px-6 rounded-l-xl">No</th>
                                <th class="py-4 px-6">Pelanggan</th>
                                <th class="py-4 px-6">Teknisi</th>
                                <th class="py-4 px-6">Rating</th>
                                <th class="py-4 px-6">Komentar / Ulasan</th>
                                <th class="py-4 px-6">Tanggal</th>
                                <th class="py-4 px-6 rounded-r-xl text-center">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 text-xs">
                            @forelse($reviews as $index => $review)
                                <tr class="hover:bg-slate-50 transition">
                                    <td class="py-4 px-6 font-bold text-slate-900">{{ $index + 1 }}</td>
                                    <td class="py-4 px-6 text-slate-900 font-bold">{{ $review->customer?->name ?? 'Pelanggan' }}</td>
                                    <td class="py-4 px-6 text-slate-800 font-semibold">{{ $review->technician?->name ?? 'Teknisi' }}</td>
                                    <td class="py-4 px-6">
                                        <div class="flex items-center gap-1 text-amber-500 font-bold">
                                            <i data-lucide="star" class="w-4 h-4 fill-amber-400"></i>
                                            <span>{{ $review->rating ?? 5 }}.0</span>
                                        </div>
                                    </td>
                                    <td class="py-4 px-6 text-slate-700 max-w-xs truncate">{{ $review->comment ?? 'Sangat memuaskan, kompor kembali normal!' }}</td>
                                    <td class="py-4 px-6 text-slate-600 font-medium">{{ $review->created_at->format('d/m/Y') }}</td>
                                    <td class="py-4 px-6 text-center">
                                        <form method="POST" action="{{ route('admin.reviews.destroy', $review->id) }}" onsubmit="return confirm('Apakah Anda yakin ingin menghapus ulasan ini?');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="text-red-500 hover:text-red-700 font-bold transition flex items-center justify-center gap-1 mx-auto">
                                                <i data-lucide="trash-2" class="w-4 h-4"></i> Hapus
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr class="hover:bg-slate-50">
                                    <td class="py-4 px-6 font-bold text-slate-900">1</td>
                                    <td class="py-4 px-6 text-slate-900 font-bold">Budi Santoso</td>
                                    <td class="py-4 px-6 text-slate-800 font-semibold">Setiawan Ade</td>
                                    <td class="py-4 px-6"><div class="flex items-center gap-1 text-amber-500 font-bold"><i data-lucide="star" class="w-4 h-4 fill-amber-400"></i> 5.0</div></td>
                                    <td class="py-4 px-6 text-slate-700">Pengerjaan cepat, ramah, dan api kompor kembali biru lancar!</td>
                                    <td class="py-4 px-6 text-slate-600 font-medium">06/10/2026</td>
                                    <td class="py-4 px-6 text-center">
                                        <button class="text-red-500 hover:text-red-700 font-bold transition flex items-center justify-center gap-1 mx-auto"><i data-lucide="trash-2" class="w-4 h-4"></i> Hapus</button>
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

        // Live Search & Icon Switch
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
        });
    </script>
</body>
</html>
