<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Teknisi & Pengajuan Pendaftaran - Admin KlikKompor</title>
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
                <a href="{{ route('admin.technicians') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl bg-gradient-to-r from-orange-500 to-amber-500 text-white font-bold transition shadow-lg shadow-orange-500/25">
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
                    <span class="text-[10px] text-slate-400">Laravel v11 • Approval System</span>
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
                    <h1 class="text-xl font-extrabold text-slate-900">Manajemen Teknisi & Pendaftaran (Bagian B)</h1>
                    <p class="text-xs text-slate-500">Kelola akun teknisi, verifikasi pengajuan pendaftaran, dan kontrol status aktif</p>
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

            @if(session('success'))
                <div class="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-bold flex items-center gap-3 shadow-sm">
                    <i data-lucide="check-circle" class="w-5 h-5 text-emerald-600"></i>
                    <span>{{ session('success') }}</span>
                </div>
            @endif

            @if($errors->any())
                <div class="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-800 text-xs font-semibold space-y-1 shadow-sm">
                    <div class="font-bold flex items-center gap-2 text-sm text-rose-700">
                        <i data-lucide="alert-circle" class="w-4 h-4"></i> Terjadi kesalahan:
                    </div>
                    <ul class="list-disc pl-5">
                        @foreach($errors->all() as $err)
                            <li>{{ $err }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <!-- 4 Metric Cards -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm">
                    <p class="text-xs font-bold text-slate-500 uppercase">Total Pengguna</p>
                    <h3 class="text-3xl font-extrabold text-slate-900 mt-1">{{ number_format($stats['total_users']) }}</h3>
                    <span class="text-[10px] text-slate-400">Akun pelanggan terdaftar</span>
                </div>
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm">
                    <p class="text-xs font-bold text-emerald-600 uppercase">Teknisi Disetujui</p>
                    <h3 class="text-3xl font-extrabold text-emerald-700 mt-1">{{ number_format($stats['total_technicians']) }}</h3>
                    <span class="text-[10px] text-slate-400">Akun terverifikasi aktif</span>
                </div>
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm">
                    <p class="text-xs font-bold text-amber-600 uppercase">Pengajuan Pending</p>
                    <h3 class="text-3xl font-extrabold text-amber-700 mt-1">{{ number_format($stats['pending_technicians']) }}</h3>
                    <span class="text-[10px] text-slate-400">Menunggu persetujuan Admin</span>
                </div>
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm">
                    <p class="text-xs font-bold text-purple-600 uppercase">Layanan Selesai</p>
                    <h3 class="text-3xl font-extrabold text-purple-700 mt-1">{{ number_format($stats['completed_orders']) }}</h3>
                    <span class="text-[10px] text-slate-400">Total pekerjaan kompor selesai</span>
                </div>
            </div>

            <!-- Tab Buttons -->
            <div class="flex items-center gap-3 border-b border-slate-200 pb-3">
                <button onclick="switchTab('approved')" id="tabBtnApproved" class="px-5 py-2.5 rounded-xl font-bold text-xs transition flex items-center gap-2 bg-orange-500 text-white shadow-md shadow-orange-500/25">
                    <i data-lucide="check-circle-2" class="w-4 h-4"></i> Teknisi Aktif (Disetujui)
                    <span class="px-2 py-0.5 rounded-full text-[10px] bg-white/20 text-white font-extrabold">{{ $technicians->count() }}</span>
                </button>
                <button onclick="switchTab('pending')" id="tabBtnPending" class="px-5 py-2.5 rounded-xl font-bold text-xs transition flex items-center gap-2 bg-white text-slate-700 border border-slate-200 hover:bg-slate-50">
                    <i data-lucide="clock" class="w-4 h-4"></i> Pengajuan Pendaftaran
                    @if($pendingTechnicians->count() > 0)
                        <span class="px-2 py-0.5 rounded-full text-[10px] bg-amber-500 text-white font-extrabold animate-pulse">{{ $pendingTechnicians->count() }}</span>
                    @else
                        <span class="px-2 py-0.5 rounded-full text-[10px] bg-slate-200 text-slate-600 font-extrabold">0</span>
                    @endif
                </button>
            </div>

            <!-- TAB 1: Teknisi Aktif Section -->
            <div id="tabContentApproved" class="bg-white/90 backdrop-blur-md rounded-3xl border border-orange-100 shadow-sm p-8 space-y-6 hover:shadow-md transition">
                <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <h2 class="text-xl font-extrabold text-slate-900">Daftar Teknisi Terverifikasi</h2>
                        <p class="text-xs text-slate-500 mt-0.5">{{ $technicians->count() }} Teknisi Aktif & Siap Menerima Order</p>
                    </div>

                    <div class="flex items-center gap-4">
                        <button onclick="openAddModal()" class="px-5 py-2.5 rounded-xl bg-orange-500 hover:bg-orange-600 text-white font-bold text-xs flex items-center gap-2 shadow-md shadow-orange-500/25 transition">
                            <i data-lucide="plus" class="w-4 h-4"></i> Tambah Teknisi Langsung
                        </button>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs border-collapse">
                        <thead>
                            <tr class="bg-slate-800 text-white font-bold rounded-xl text-[11px] uppercase tracking-wider">
                                <th class="py-3.5 px-4 rounded-l-xl">No</th>
                                <th class="py-3.5 px-4">Nama Teknisi</th>
                                <th class="py-3.5 px-4">Kontak</th>
                                <th class="py-3.5 px-4">Alamat</th>
                                <th class="py-3.5 px-4">Keahlian</th>
                                <th class="py-3.5 px-4 text-center">Status Akun</th>
                                <th class="py-3.5 px-4 text-center">Order Selesai</th>
                                <th class="py-3.5 px-4 rounded-r-xl text-center">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 text-slate-700">
                            @forelse($technicians as $index => $tech)
                                <tr class="hover:bg-slate-50 transition">
                                    <td class="py-3.5 px-4 font-bold text-slate-900">{{ $index + 1 }}</td>
                                    <td class="py-3.5 px-4">
                                        <div class="font-bold text-slate-900">{{ $tech->name }}</div>
                                        <span class="text-[10px] text-emerald-600 font-semibold flex items-center gap-1">
                                            <i data-lucide="badge-check" class="w-3 h-3"></i> Terverifikasi
                                        </span>
                                    </td>
                                    <td class="py-3.5 px-4">
                                        <div class="text-blue-600 font-medium">{{ $tech->email }}</div>
                                        <div class="text-slate-500 text-[11px]">{{ $tech->phone }}</div>
                                    </td>
                                    <td class="py-3.5 px-4 text-slate-600 max-w-xs truncate">{{ $tech->address ?? '-' }}</td>
                                    <td class="py-3.5 px-4">
                                        @php
                                            $skills = is_array($tech->technicianProfile?->skills) ? $tech->technicianProfile->skills : [];
                                        @endphp
                                        <div class="flex flex-wrap gap-1">
                                            @foreach(array_slice($skills, 0, 2) as $sk)
                                                <span class="px-2 py-0.5 rounded bg-slate-100 text-[10px] font-semibold text-slate-700">{{ $sk }}</span>
                                            @endforeach
                                        </div>
                                    </td>
                                    <td class="py-3.5 px-4 text-center">
                                        @if($tech->is_active)
                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-700">AKTIF</span>
                                        @else
                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-rose-100 text-rose-700">NONAKTIF</span>
                                        @endif
                                    </td>
                                    <td class="py-3.5 px-4 font-bold text-slate-900 text-center">{{ $tech->technician_orders_count ?? 0 }}</td>
                                    <td class="py-3.5 px-4 text-center">
                                        <div class="flex items-center justify-center gap-2">
                                            <!-- Toggle Active -->
                                            <form method="POST" action="{{ route('admin.technicians.toggle_active', $tech->id) }}">
                                                @csrf
                                                <button type="submit" class="px-2.5 py-1 rounded-lg text-[10px] font-bold transition {{ $tech->is_active ? 'bg-amber-50 text-amber-700 hover:bg-amber-100' : 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100' }}">
                                                    {{ $tech->is_active ? 'Nonaktifkan' : 'Aktifkan' }}
                                                </button>
                                            </form>
                                            <!-- Hapus -->
                                            <form method="POST" action="{{ route('admin.technicians.destroy', $tech->id) }}" onsubmit="return confirm('Apakah Anda yakin ingin menghapus teknisi ini?');">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="p-1 rounded text-red-500 hover:bg-red-50 transition" title="Hapus Teknisi">
                                                    <i data-lucide="trash-2" class="w-4 h-4"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="py-8 text-center text-slate-400">Belum ada data teknisi yang disetujui.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 2: Pengajuan Pending Section -->
            <div id="tabContentPending" class="bg-white/90 backdrop-blur-md rounded-3xl border border-orange-100 shadow-sm p-8 space-y-6 hover:shadow-md transition hidden">
                <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <h2 class="text-xl font-extrabold text-slate-900">Pengajuan Pendaftaran Teknisi Baru</h2>
                        <p class="text-xs text-slate-500 mt-0.5">Tinjau kelengkapan berkas calon teknisi sebelum menyetujui atau menolak pendaftaran</p>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs border-collapse">
                        <thead>
                            <tr class="bg-amber-500 text-white font-bold rounded-xl text-[11px] uppercase tracking-wider">
                                <th class="py-3.5 px-4 rounded-l-xl">No</th>
                                <th class="py-3.5 px-4">Calon Teknisi</th>
                                <th class="py-3.5 px-4">Kontak</th>
                                <th class="py-3.5 px-4">Alamat & Pengalaman</th>
                                <th class="py-3.5 px-4">Keahlian & Sertifikat</th>
                                <th class="py-3.5 px-4">Waktu Daftar</th>
                                <th class="py-3.5 px-4 rounded-r-xl text-center">Keputusan Admin</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 text-slate-700">
                            @forelse($pendingTechnicians as $index => $pending)
                                <tr class="hover:bg-amber-50/20 transition">
                                    <td class="py-3.5 px-4 font-bold text-slate-900">{{ $index + 1 }}</td>
                                    <td class="py-3.5 px-4">
                                        <div class="font-bold text-slate-900">{{ $pending->name }}</div>
                                        <span class="text-[10px] text-amber-600 font-bold px-2 py-0.5 bg-amber-50 border border-amber-200 rounded-md inline-block mt-0.5">
                                            Menunggu Persetujuan
                                        </span>
                                    </td>
                                    <td class="py-3.5 px-4">
                                        <div class="text-blue-600 font-medium">{{ $pending->email }}</div>
                                        <div class="text-slate-500 text-[11px]">{{ $pending->phone }}</div>
                                    </td>
                                    <td class="py-3.5 px-4">
                                        <div class="text-slate-800 font-medium">{{ $pending->address ?? '-' }}</div>
                                        <div class="text-[10px] text-slate-400 mt-0.5 font-semibold">
                                            Pengalaman: {{ $pending->technicianProfile?->years_of_experience ?? 0 }} Tahun
                                        </div>
                                    </td>
                                    <td class="py-3.5 px-4">
                                        @php
                                            $skills = is_array($pending->technicianProfile?->skills) ? $pending->technicianProfile->skills : [];
                                        @endphp
                                        <div class="flex flex-wrap gap-1 mb-1">
                                            @foreach($skills as $sk)
                                                <span class="px-2 py-0.5 rounded bg-slate-100 text-[10px] font-semibold text-slate-700">{{ $sk }}</span>
                                            @endforeach
                                        </div>
                                        @if($pending->technicianProfile?->certificate_url)
                                            <a href="{{ $pending->technicianProfile->certificate_url }}" target="_blank" class="text-[10px] text-orange-600 font-bold underline flex items-center gap-1">
                                                <i data-lucide="file-text" class="w-3 h-3"></i> Lihat Berkas / Sertifikat
                                            </a>
                                        @endif
                                    </td>
                                    <td class="py-3.5 px-4 text-slate-500">
                                        {{ $pending->created_at->format('d/m/Y H:i') }}
                                    </td>
                                    <td class="py-3.5 px-4 text-center">
                                        <div class="flex items-center justify-center gap-2">
                                            <!-- Tombol Setujui -->
                                            <form method="POST" action="{{ route('admin.technicians.approve', $pending->id) }}" onsubmit="return confirm('Setujui pendaftaran teknisi {{ $pending->name }}?');">
                                                @csrf
                                                <button type="submit" class="px-3 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs flex items-center gap-1 shadow-sm transition">
                                                    <i data-lucide="check" class="w-3.5 h-3.5"></i> Setujui
                                                </button>
                                            </form>
                                            <!-- Tombol Tolak -->
                                            <button onclick="openRejectModal({{ $pending->id }}, '{{ addslashes($pending->name) }}')" class="px-3 py-1.5 rounded-lg bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 font-bold text-xs flex items-center gap-1 transition">
                                                <i data-lucide="x" class="w-3.5 h-3.5"></i> Tolak
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="7" class="py-8 text-center text-slate-400">Tidak ada pengajuan pendaftaran teknisi baru yang pending.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </main>

    <!-- Modal Tolak Pendaftaran -->
    <div id="rejectModal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-md w-full p-8 space-y-6 shadow-2xl relative animate-fade-in">
            <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                <div>
                    <h3 class="text-lg font-extrabold text-slate-900">Tolak Pendaftaran Teknisi</h3>
                    <p id="rejectTechName" class="text-xs text-slate-500 mt-0.5">Nama Calon Teknisi</p>
                </div>
                <button onclick="closeRejectModal()" class="text-slate-400 hover:text-black text-xl font-bold">&times;</button>
            </div>
            <form id="rejectForm" method="POST" action="" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Alasan Penolakan Pendaftaran *</label>
                    <textarea name="rejection_reason" required rows="3" placeholder="Contoh: Nomor telepon tidak dapat dihubungi atau sertifikat kompetensi tidak valid..." class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-rose-500"></textarea>
                    <span class="text-[10px] text-slate-400 block mt-1">Alasan ini akan dikirimkan kepada calon teknisi sebagai informasi.</span>
                </div>
                <div class="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                    <button type="button" onclick="closeRejectModal()" class="px-4 py-2.5 rounded-xl border border-slate-200 text-xs font-bold text-slate-600 hover:bg-slate-50">Batal</button>
                    <button type="submit" class="px-5 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold shadow-md shadow-rose-600/25">Tolak Pendaftaran</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Tambah Teknisi Langsung -->
    <div id="addModal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-md w-full p-8 space-y-6 shadow-2xl relative animate-fade-in">
            <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                <h3 class="text-lg font-extrabold text-slate-900">Tambah Teknisi Baru (Oleh Admin)</h3>
                <button onclick="closeAddModal()" class="text-slate-400 hover:text-black text-xl font-bold">&times;</button>
            </div>
            <form method="POST" action="{{ route('admin.technicians.store') }}" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Nama Lengkap Teknisi *</label>
                    <input type="text" name="name" required placeholder="Contoh: Setiawan Ade" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Email *</label>
                    <input type="email" name="email" required placeholder="ade123@gmail.com" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">No. Telepon (WhatsApp) *</label>
                    <input type="text" name="phone" required placeholder="081234567890" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Alamat Lengkap</label>
                    <input type="text" name="address" placeholder="Jl. Bunga No. 12" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Kata Sandi Akun *</label>
                    <input type="password" name="password" required placeholder="Minimal 6 karakter" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                </div>
                <div class="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                    <button type="button" onclick="closeAddModal()" class="px-4 py-2.5 rounded-xl border border-slate-200 text-xs font-bold text-slate-600 hover:bg-slate-50">Batal</button>
                    <button type="submit" class="px-5 py-2.5 rounded-xl bg-orange-500 hover:bg-orange-600 text-white text-xs font-bold shadow-md shadow-orange-500/25">Simpan Data</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        lucide.createIcons();

        function switchTab(tab) {
            const btnApproved = document.getElementById('tabBtnApproved');
            const btnPending = document.getElementById('tabBtnPending');
            const contentApproved = document.getElementById('tabContentApproved');
            const contentPending = document.getElementById('tabContentPending');

            if (tab === 'approved') {
                btnApproved.className = 'px-5 py-2.5 rounded-xl font-bold text-xs transition flex items-center gap-2 bg-orange-500 text-white shadow-md shadow-orange-500/25';
                btnPending.className = 'px-5 py-2.5 rounded-xl font-bold text-xs transition flex items-center gap-2 bg-white text-slate-700 border border-slate-200 hover:bg-slate-50';
                contentApproved.classList.remove('hidden');
                contentPending.classList.add('hidden');
            } else {
                btnPending.className = 'px-5 py-2.5 rounded-xl font-bold text-xs transition flex items-center gap-2 bg-amber-500 text-white shadow-md shadow-amber-500/25';
                btnApproved.className = 'px-5 py-2.5 rounded-xl font-bold text-xs transition flex items-center gap-2 bg-white text-slate-700 border border-slate-200 hover:bg-slate-50';
                contentPending.classList.remove('hidden');
                contentApproved.classList.add('hidden');
            }
        }

        function openAddModal() {
            document.getElementById('addModal').classList.remove('hidden');
        }

        function closeAddModal() {
            document.getElementById('addModal').classList.add('hidden');
        }

        function openRejectModal(techId, techName) {
            document.getElementById('rejectTechName').innerText = 'Calon Teknisi: ' + techName;
            document.getElementById('rejectForm').action = '/admin/technicians/' + techId + '/reject';
            document.getElementById('rejectModal').classList.remove('hidden');
        }

        function closeRejectModal() {
            document.getElementById('rejectModal').classList.add('hidden');
        }
    </script>
</body>
</html>
