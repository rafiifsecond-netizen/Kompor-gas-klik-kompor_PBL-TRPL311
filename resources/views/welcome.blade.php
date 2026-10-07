<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KlikKompor — Platform Layanan Service Kompor Gas Terpercaya</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        brand: {
                            50: '#fff7ed',
                            100: '#ffedd5',
                            500: '#f97316',
                            600: '#ea580c',
                            700: '#c2410c',
                            900: '#7c2d12',
                        },
                        navy: {
                            800: '#0f172a',
                            900: '#090d16',
                            950: '#04070d',
                        }
                    },
                    fontFamily: {
                        sans: ['"Plus Jakarta Sans"', 'sans-serif'],
                    }
                }
            }
        }
    </script>
    <style>
        .gradient-fire {
            background: linear-gradient(135deg, #f97316 0%, #ef4444 50%, #b91c1c 100%);
        }
        .glass-card {
            background: rgba(15, 23, 42, 0.75);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.08);
        }
    </style>
</head>
<body class="bg-navy-950 text-slate-100 font-sans min-h-screen selection:bg-orange-500 selection:text-white">
    <!-- Navbar -->
    <header class="border-b border-slate-800/80 sticky top-0 z-50 bg-navy-950/80 backdrop-blur-md">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <div class="w-11 h-11 rounded-xl gradient-fire flex items-center justify-center shadow-lg shadow-orange-500/25">
                    <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z" />
                    </svg>
                </div>
                <div>
                    <h1 class="text-2xl font-extrabold tracking-tight text-white flex items-center gap-2">
                        Klik<span class="text-orange-500">Kompor</span>
                        <span class="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-orange-500/10 text-orange-400 border border-orange-500/20">API v1 Ready</span>
                    </h1>
                    <p class="text-xs text-slate-400">On-Demand Gas Stove Repair & Maintenance Platform</p>
                </div>
            </div>

            <div class="flex items-center gap-3">
                <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                    <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                    Backend Online (Laravel 12 / PHP 8.4)
                </span>
                <a href="#endpoints" class="text-xs font-semibold px-4 py-2 rounded-lg bg-orange-500 hover:bg-orange-600 text-white transition shadow-sm">
                    Dokumentasi API
                </a>
            </div>
        </div>
    </header>

    <!-- Hero Section -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 space-y-12">
        <section class="relative overflow-hidden rounded-3xl p-8 sm:p-12 glass-card border border-slate-800">
            <div class="absolute -right-20 -top-20 w-80 h-80 bg-orange-500/10 rounded-full blur-3xl pointer-events-none"></div>
            <div class="max-w-3xl space-y-4">
                <div class="inline-block px-3 py-1 rounded-lg bg-slate-800/80 border border-slate-700 text-xs font-medium text-orange-400">
                    Arsitektur Berorientasi Microservices & Mobile Ready
                </div>
                <h2 class="text-3xl sm:text-5xl font-extrabold text-white tracking-tight leading-tight">
                    Sistem Backend & REST API <span class="text-transparent bg-clip-text gradient-fire">KlikKompor</span> Telah Aktif.
                </h2>
                <p class="text-slate-300 text-sm sm:text-base leading-relaxed">
                    Sistem dirancang khusus menghubungkan <strong>Pelanggan</strong> dan <strong>Teknisi</strong> melalui aplikasi mobile Flutter (iOS & Android) dengan kendali penuh melalui <strong>Web Dashboard Admin</strong>.
                </p>
            </div>

            <!-- Stats Bar -->
            <div class="grid grid-cols-2 md:grid-cols-6 gap-4 mt-8 pt-8 border-t border-slate-800/80">
                <div class="p-4 rounded-2xl bg-slate-900/60 border border-slate-800">
                    <div class="text-2xl font-bold text-white">{{ $stats['users_count'] }}</div>
                    <div class="text-xs text-slate-400 mt-1">Total Pengguna</div>
                </div>
                <div class="p-4 rounded-2xl bg-slate-900/60 border border-slate-800">
                    <div class="text-2xl font-bold text-orange-400">{{ $stats['technicians_count'] }}</div>
                    <div class="text-xs text-slate-400 mt-1">Teknisi Verified</div>
                </div>
                <div class="p-4 rounded-2xl bg-slate-900/60 border border-slate-800">
                    <div class="text-2xl font-bold text-white">{{ $stats['categories_count'] }}</div>
                    <div class="text-xs text-slate-400 mt-1">Kategori Kompor</div>
                </div>
                <div class="p-4 rounded-2xl bg-slate-900/60 border border-slate-800">
                    <div class="text-2xl font-bold text-white">{{ $stats['services_count'] }}</div>
                    <div class="text-xs text-slate-400 mt-1">Layanan & Tarif</div>
                </div>
                <div class="p-4 rounded-2xl bg-slate-900/60 border border-slate-800">
                    <div class="text-2xl font-bold text-emerald-400">{{ $stats['orders_count'] }}</div>
                    <div class="text-xs text-slate-400 mt-1">Pesanan Servis</div>
                </div>
                <div class="p-4 rounded-2xl bg-slate-900/60 border border-slate-800">
                    <div class="text-2xl font-bold text-sky-400">{{ $stats['logs_count'] }}</div>
                    <div class="text-xs text-slate-400 mt-1">Audit Logs Dicatat</div>
                </div>
            </div>
        </section>

        <!-- 3 Actors & Platform Matrix -->
        <section class="space-y-6">
            <div class="flex items-center justify-between">
                <div>
                    <h3 class="text-xl font-bold text-white">3 Aktor & Alur Akses Sistem</h3>
                    <p class="text-xs text-slate-400">Pembagian fungsi dan hak akses sesuai matriks perancangan</p>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <!-- Customer Card -->
                <div class="p-6 rounded-2xl glass-card space-y-4 border-t-4 border-t-sky-500">
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-bold uppercase tracking-wider text-sky-400">Role: Customer</span>
                        <span class="text-xs bg-slate-800 px-2 py-0.5 rounded text-slate-300">iOS & Android</span>
                    </div>
                    <h4 class="text-lg font-bold text-white">Pelanggan</h4>
                    <ul class="text-xs text-slate-300 space-y-2">
                        <li class="flex items-center gap-2">✓ Cari teknisi terdekat berdasarkan GPS</li>
                        <li class="flex items-center gap-2">✓ Estimasi tarif otomatis & pilih jadwal</li>
                        <li class="flex items-center gap-2">✓ Lacak status teknisi menuju lokasi</li>
                        <li class="flex items-center gap-2">✓ Pembayaran & beri rating bintang 1-5</li>
                    </ul>
                    <div class="p-3 bg-slate-900/80 rounded-xl text-xs space-y-1 border border-slate-800">
                        <div class="text-slate-400 font-mono">Demo: dewi@example.com</div>
                        <div class="text-slate-500 font-mono">Pass: password123</div>
                    </div>
                </div>

                <!-- Technician Card -->
                <div class="p-6 rounded-2xl glass-card space-y-4 border-t-4 border-t-orange-500">
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-bold uppercase tracking-wider text-orange-400">Role: Technician</span>
                        <span class="text-xs bg-slate-800 px-2 py-0.5 rounded text-slate-300">iOS & Android</span>
                    </div>
                    <h4 class="text-lg font-bold text-white">Teknisi</h4>
                    <ul class="text-xs text-slate-300 space-y-2">
                        <li class="flex items-center gap-2">✓ Atur ketersediaan (Online / Offline)</li>
                        <li class="flex items-center gap-2">✓ Terima / tolak order & lihat rute GPS</li>
                        <li class="flex items-center gap-2">✓ Update status: Menuju Lokasi → Dikerjakan → Selesai</li>
                        <li class="flex items-center gap-2">✓ Portofolio keahlian, rating & ulasan</li>
                    </ul>
                    <div class="p-3 bg-slate-900/80 rounded-xl text-xs space-y-1 border border-slate-800">
                        <div class="text-slate-400 font-mono">Demo: agus.teknisi@klikkompor.com</div>
                        <div class="text-slate-500 font-mono">Pass: password123</div>
                    </div>
                </div>

                <!-- Admin Card -->
                <div class="p-6 rounded-2xl glass-card space-y-4 border-t-4 border-t-purple-500">
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-bold uppercase tracking-wider text-purple-400">Role: Admin</span>
                        <span class="text-xs bg-slate-800 px-2 py-0.5 rounded text-slate-300">Web Dashboard</span>
                    </div>
                    <h4 class="text-lg font-bold text-white">Admin / Pengelola</h4>
                    <ul class="text-xs text-slate-300 space-y-2">
                        <li class="flex items-center gap-2">✓ Verifikasi dokumen & sertifikat teknisi</li>
                        <li class="flex items-center gap-2">✓ Atur katalog kategori & acuan tarif layanan</li>
                        <li class="flex items-center gap-2">✓ Pengawasan transaksi & laporan omzet</li>
                        <li class="flex items-center gap-2">✓ Audit trail (18 aktivitas wajib tercatat)</li>
                    </ul>
                    <div class="p-3 bg-slate-900/80 rounded-xl text-xs space-y-1 border border-slate-800">
                        <div class="text-slate-400 font-mono">Demo: admin@klikkompor.com</div>
                        <div class="text-slate-500 font-mono">Pass: password123</div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Quick API Testing Links -->
        <section id="endpoints" class="space-y-6">
            <div class="flex items-center justify-between">
                <div>
                    <h3 class="text-xl font-bold text-white">Uji Coba Langsung Endpoint API</h3>
                    <p class="text-xs text-slate-400">Klik tautan di bawah untuk melihat output JSON riil</p>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <a href="{{ url('/api/v1/categories') }}" target="_blank" class="p-4 rounded-xl glass-card hover:border-orange-500/50 transition flex items-center justify-between group">
                    <div class="flex items-center gap-3">
                        <span class="px-2.5 py-1 rounded-md text-xs font-mono font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">GET</span>
                        <div>
                            <div class="text-sm font-semibold text-white group-hover:text-orange-400 transition font-mono">/api/v1/categories</div>
                            <div class="text-xs text-slate-400">Daftar kategori kompor & tarif dasar layanan</div>
                        </div>
                    </div>
                    <span class="text-xs text-slate-500 group-hover:text-slate-300">Buka JSON ↗</span>
                </a>

                <a href="{{ url('/api/v1/technicians') }}" target="_blank" class="p-4 rounded-xl glass-card hover:border-orange-500/50 transition flex items-center justify-between group">
                    <div class="flex items-center gap-3">
                        <span class="px-2.5 py-1 rounded-md text-xs font-mono font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">GET</span>
                        <div>
                            <div class="text-sm font-semibold text-white group-hover:text-orange-400 transition font-mono">/api/v1/technicians</div>
                            <div class="text-xs text-slate-400">Daftar teknisi verified beserta rating & keahlian</div>
                        </div>
                    </div>
                    <span class="text-xs text-slate-500 group-hover:text-slate-300">Buka JSON ↗</span>
                </a>

                <a href="{{ url('/api/v1/services') }}" target="_blank" class="p-4 rounded-xl glass-card hover:border-orange-500/50 transition flex items-center justify-between group">
                    <div class="flex items-center gap-3">
                        <span class="px-2.5 py-1 rounded-md text-xs font-mono font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">GET</span>
                        <div>
                            <div class="text-sm font-semibold text-white group-hover:text-orange-400 transition font-mono">/api/v1/services</div>
                            <div class="text-xs text-slate-400">Daftar tarif acuan service kompor gas</div>
                        </div>
                    </div>
                    <span class="text-xs text-slate-500 group-hover:text-slate-300">Buka JSON ↗</span>
                </a>

                <div class="p-4 rounded-xl glass-card flex items-center justify-between">
                    <div class="flex items-center gap-3">
                        <span class="px-2.5 py-1 rounded-md text-xs font-mono font-bold bg-blue-500/10 text-blue-400 border border-blue-500/20">POST</span>
                        <div>
                            <div class="text-sm font-semibold text-white font-mono">/api/v1/auth/login</div>
                            <div class="text-xs text-slate-400">Autentikasi Bearer Token Sanctum</div>
                        </div>
                    </div>
                    <span class="text-xs text-slate-400">Via Mobile / Postman</span>
                </div>
            </div>
        </section>

        <!-- Audit Activity Trail Live -->
        <section class="space-y-4">
            <h3 class="text-xl font-bold text-white">Log Aktivitas & Audit Keamanan Real-time</h3>
            <p class="text-xs text-slate-400">Mencatat 18 aktivitas wajib sistem sesuai matriks tata kelola keamanan</p>

            <div class="glass-card rounded-2xl overflow-hidden border border-slate-800">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs">
                        <thead class="bg-slate-900/90 text-slate-400 uppercase tracking-wider border-b border-slate-800">
                            <tr>
                                <th class="p-3.5">Waktu</th>
                                <th class="p-3.5">Event</th>
                                <th class="p-3.5">Aktor</th>
                                <th class="p-3.5">Peran</th>
                                <th class="p-3.5">Deskripsi</th>
                                <th class="p-3.5">Platform</th>
                                <th class="p-3.5">Status</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-800/60 font-mono">
                            @forelse($recentLogs as $log)
                            <tr class="hover:bg-slate-900/40 transition">
                                <td class="p-3.5 text-slate-400">{{ $log->created_at->format('Y-m-d H:i:s') }}</td>
                                <td class="p-3.5 text-orange-400 font-semibold">{{ $log->event_name }}</td>
                                <td class="p-3.5 text-white">{{ $log->actor?->name ?? 'System' }}</td>
                                <td class="p-3.5">
                                    <span class="px-2 py-0.5 rounded text-[10px] uppercase font-bold
                                        @if($log->actor_role === 'admin') bg-purple-500/20 text-purple-400
                                        @elseif($log->actor_role === 'technician') bg-orange-500/20 text-orange-400
                                        @else bg-sky-500/20 text-sky-400 @endif">
                                        {{ $log->actor_role }}
                                    </span>
                                </td>
                                <td class="p-3.5 text-slate-300 font-sans">{{ $log->description }}</td>
                                <td class="p-3.5 text-slate-400">{{ $log->platform }}</td>
                                <td class="p-3.5">
                                    <span class="px-2 py-0.5 rounded text-[10px] bg-emerald-500/20 text-emerald-400 font-bold">
                                        {{ $log->status }}
                                    </span>
                                </td>
                            </tr>
                            @empty
                            <tr>
                                <td colspan="7" class="p-6 text-center text-slate-500">Belum ada riwayat aktivitas.</td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </main>

    <footer class="mt-20 border-t border-slate-800/80 py-8 bg-navy-950">
        <div class="max-w-7xl mx-auto px-4 text-center text-xs text-slate-500">
            &copy; 2026 KlikKompor &bull; Dikembangkan dengan Laravel 12 & PostgreSQL/MySQL &bull; Solusi Layanan Kompor Gas Terpercaya
        </div>
    </footer>
</body>
</html>
