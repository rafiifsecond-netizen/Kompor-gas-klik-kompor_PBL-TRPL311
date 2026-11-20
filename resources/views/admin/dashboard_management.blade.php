<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pengaturan Dashboard - Admin KlikKompor</title>
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
                <a href="{{ route('admin.reviews') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="message-square" class="w-5 h-5"></i> Ulasan
                </a>
                <a href="{{ route('admin.reports') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl text-white/70 hover:bg-white/10 hover:text-white font-bold transition">
                    <i data-lucide="bar-chart-2" class="w-5 h-5"></i> Laporan
                </a>
                <a href="{{ route('admin.dashboard_management') }}" class="flex items-center gap-4 px-5 py-3.5 rounded-xl bg-gradient-to-r from-orange-500 to-amber-500 text-white font-bold transition shadow-lg shadow-orange-500/25">
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
                    <span class="text-[10px] text-slate-400">Laravel v11 • Storage Aktif</span>
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
                    <h1 class="text-xl font-extrabold text-slate-900">Pengaturan Dashboard & Banner</h1>
                    <p class="text-xs text-slate-500">Kelola gambar banner promosi dan pengumuman aplikasi pelanggan</p>
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
                        <i data-lucide="alert-circle" class="w-4 h-4"></i> Gagal menyimpan banner:
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
                    <p class="text-xs font-bold text-slate-500 uppercase">Total Banner</p>
                    <h3 class="text-3xl font-extrabold text-slate-900 mt-1">{{ number_format($stats['total_banners']) }}</h3>
                    <span class="text-[10px] text-slate-400">Tersimpan di sistem</span>
                </div>
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm">
                    <p class="text-xs font-bold text-emerald-600 uppercase">Banner Aktif</p>
                    <h3 class="text-3xl font-extrabold text-emerald-700 mt-1">{{ number_format($stats['active_banners']) }}</h3>
                    <span class="text-[10px] text-slate-400">Tampil di aplikasi Flutter</span>
                </div>
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm">
                    <p class="text-xs font-bold text-slate-500 uppercase">Total Pelanggan</p>
                    <h3 class="text-3xl font-extrabold text-slate-900 mt-1">{{ number_format($stats['total_users']) }}</h3>
                    <span class="text-[10px] text-slate-400">Target promosi banner</span>
                </div>
                <div class="bg-white/90 backdrop-blur-md p-6 rounded-2xl border border-orange-100 shadow-sm">
                    <p class="text-xs font-bold text-purple-600 uppercase">Layanan Selesai</p>
                    <h3 class="text-3xl font-extrabold text-purple-700 mt-1">{{ number_format($stats['completed_orders']) }}</h3>
                    <span class="text-[10px] text-slate-400">Performa transaksi</span>
                </div>
            </div>

            <!-- Banner List Card -->
            <div class="bg-white/90 backdrop-blur-md rounded-3xl border border-orange-100 shadow-sm p-8 space-y-6 hover:shadow-md transition">
                <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <h2 class="text-xl font-extrabold text-slate-900">Daftar Banner Dashboard</h2>
                        <p class="text-xs text-slate-500 mt-0.5">Kelola banner carousel, atur urutan dan tanggal tayang</p>
                    </div>

                    <div class="flex items-center gap-3">
                        <button onclick="openAddModal()" class="px-5 py-2.5 rounded-xl bg-orange-500 hover:bg-orange-600 text-white font-bold text-xs flex items-center gap-2 shadow-md shadow-orange-500/25 transition">
                            <i data-lucide="plus" class="w-4 h-4"></i> Tambah Banner Baru
                        </button>
                    </div>
                </div>

                <!-- Banners Grid -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    @forelse($banners as $banner)
                        <div class="bg-slate-50/70 border border-slate-200 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition flex flex-col justify-between">
                            <div>
                                <!-- Image Preview -->
                                <div class="relative h-44 w-full bg-slate-900 overflow-hidden group">
                                    <img src="{{ $banner->formatted_image_url }}" alt="{{ $banner->title }}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" onerror="this.src='https://via.placeholder.com/600x300?text=Banner+KlikKompor'">
                                    @if($banner->badge_text)
                                        <span class="absolute top-3 left-3 px-3 py-1 rounded-full text-[10px] font-extrabold bg-orange-500 text-white uppercase shadow">
                                            {{ $banner->badge_text }}
                                        </span>
                                    @endif
                                    <span class="absolute top-3 right-3 px-2.5 py-0.5 rounded-md text-[10px] font-bold {{ $banner->is_active ? 'bg-emerald-500 text-white' : 'bg-slate-600 text-white' }} shadow">
                                        {{ $banner->is_active ? 'AKTIF' : 'NONAKTIF' }}
                                    </span>
                                </div>

                                <!-- Content Info -->
                                <div class="p-5 space-y-2">
                                    <div class="flex items-center justify-between">
                                        <h3 class="font-extrabold text-slate-900 text-sm line-clamp-1">{{ $banner->title }}</h3>
                                        <span class="text-[10px] font-mono px-2 py-0.5 bg-slate-200 text-slate-700 rounded font-bold">Urutan: {{ $banner->sort_order }}</span>
                                    </div>
                                    <p class="text-xs text-slate-500 line-clamp-2">{{ $banner->description ?? 'Tidak ada deskripsi.' }}</p>
                                    
                                    @if($banner->link_url)
                                        <div class="text-[10px] text-blue-600 truncate font-medium flex items-center gap-1">
                                            <i data-lucide="link" class="w-3 h-3"></i> {{ $banner->link_url }}
                                        </div>
                                    @endif

                                    <div class="text-[10px] text-slate-400 pt-2 border-t border-slate-200/60 flex items-center justify-between">
                                        <span>Mulai: {{ $banner->start_date ? $banner->start_date->format('d/m/Y') : 'Selamanya' }}</span>
                                        <span>Sampai: {{ $banner->end_date ? $banner->end_date->format('d/m/Y') : 'Selamanya' }}</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Actions Footer -->
                            <div class="p-4 bg-white border-t border-slate-200/60 flex items-center justify-between gap-2">
                                <form method="POST" action="{{ route('admin.banners.toggle_active', $banner->id) }}">
                                    @csrf
                                    <button type="submit" class="px-3 py-1.5 rounded-lg text-xs font-bold transition flex items-center gap-1.5 {{ $banner->is_active ? 'bg-amber-50 text-amber-700 hover:bg-amber-100' : 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100' }}">
                                        <i data-lucide="{{ $banner->is_active ? 'eye-off' : 'eye' }}" class="w-3.5 h-3.5"></i>
                                        {{ $banner->is_active ? 'Nonaktifkan' : 'Aktifkan' }}
                                    </button>
                                </form>

                                <div class="flex items-center gap-1.5">
                                    <button onclick='openEditModal(@json($banner))' class="px-3 py-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold text-xs flex items-center gap-1 transition">
                                        <i data-lucide="edit-3" class="w-3.5 h-3.5"></i> Edit
                                    </button>
                                    <form method="POST" action="{{ route('admin.banners.destroy', $banner->id) }}" onsubmit="return confirm('Hapus banner ini beserta file fotonya?');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="p-1.5 rounded-lg text-rose-500 hover:bg-rose-50 transition">
                                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    @empty
                        <div class="col-span-full py-12 text-center text-slate-400 bg-slate-50 rounded-2xl border border-dashed border-slate-200">
                            <i data-lucide="image" class="w-12 h-12 mx-auto text-slate-300 mb-2"></i>
                            <p class="font-bold text-slate-600">Belum ada banner dashboard</p>
                            <p class="text-xs text-slate-400 mt-1">Klik tombol "Tambah Banner Baru" untuk mengunggah gambar promosi.</p>
                        </div>
                    @endforelse
                </div>

                <!-- Pagination -->
                <div class="pt-4 border-t border-slate-100">
                    {{ $banners->links() }}
                </div>
            </div>

        </div>
    </main>

    <!-- Modal Tambah Banner -->
    <div id="addModal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-lg w-full p-8 space-y-6 shadow-2xl relative animate-fade-in max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                <h3 class="text-lg font-extrabold text-slate-900">Tambah Banner Dashboard Baru</h3>
                <button onclick="closeAddModal()" class="text-slate-400 hover:text-black text-xl font-bold">&times;</button>
            </div>
            <form method="POST" action="{{ route('admin.banners.store') }}" enctype="multipart/form-data" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Judul Banner *</label>
                    <input type="text" name="title" required placeholder="Contoh: Promo Servis Kompor Awal Bulan" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Deskripsi Singkat</label>
                    <textarea name="description" rows="2" placeholder="Contoh: Dapatkan diskon 20% untuk setiap servis kompor 2 tungku..." class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2 text-xs outline-none focus:border-orange-500"></textarea>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Badge Text (Label)</label>
                        <input type="text" name="badge_text" placeholder="Contoh: PROMO, INFO, DISKON" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Urutan Tampilan</label>
                        <input type="number" name="sort_order" value="0" min="0" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Tautan / Link Promosi (Opsional)</label>
                    <input type="text" name="link_url" placeholder="https://klikkompor.com/promo atau /services/1" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Tanggal Mulai Tayang</label>
                        <input type="date" name="start_date" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2 text-xs outline-none focus:border-orange-500" />
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Tanggal Berakhir</label>
                        <input type="date" name="end_date" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2 text-xs outline-none focus:border-orange-500" />
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Unggah Gambar Banner (JPG, PNG, WebP maks 3MB) *</label>
                    <input type="file" name="image" required accept="image/*" onchange="previewAddImage(this)" class="w-full text-xs text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-bold file:bg-orange-50 file:text-orange-600 hover:file:bg-orange-100" />
                    <div id="addPreviewWrapper" class="mt-3 hidden">
                        <span class="text-[10px] font-bold text-slate-400 block mb-1">Pratinjau Gambar:</span>
                        <img id="addPreviewImg" src="" alt="Preview" class="h-32 w-full object-cover rounded-xl border border-slate-200 shadow-sm" />
                    </div>
                </div>
                <div class="flex items-center gap-2 pt-2">
                    <input type="checkbox" name="is_active" id="add_is_active" value="1" checked class="w-4 h-4 text-orange-500 rounded border-slate-300 focus:ring-orange-500" />
                    <label for="add_is_active" class="text-xs font-semibold text-slate-700">Aktifkan dan tampilkan banner di dashboard langsung</label>
                </div>
                <div class="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                    <button type="button" onclick="closeAddModal()" class="px-4 py-2.5 rounded-xl border border-slate-200 text-xs font-bold text-slate-600 hover:bg-slate-50">Batal</button>
                    <button type="submit" class="px-5 py-2.5 rounded-xl bg-orange-500 hover:bg-orange-600 text-white text-xs font-bold shadow-md shadow-orange-500/25">Simpan Banner</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Edit Banner -->
    <div id="editModal" class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-lg w-full p-8 space-y-6 shadow-2xl relative animate-fade-in max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                <h3 class="text-lg font-extrabold text-slate-900">Edit Banner Dashboard</h3>
                <button onclick="closeEditModal()" class="text-slate-400 hover:text-black text-xl font-bold">&times;</button>
            </div>
            <form id="editBannerForm" method="POST" action="" enctype="multipart/form-data" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Judul Banner *</label>
                    <input type="text" id="edit_title" name="title" required class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Deskripsi Singkat</label>
                    <textarea id="edit_description" name="description" rows="2" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2 text-xs outline-none focus:border-orange-500"></textarea>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Badge Text (Label)</label>
                        <input type="text" id="edit_badge_text" name="badge_text" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Urutan Tampilan</label>
                        <input type="number" id="edit_sort_order" name="sort_order" min="0" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Tautan / Link Promosi</label>
                    <input type="text" id="edit_link_url" name="link_url" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs outline-none focus:border-orange-500" />
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Tanggal Mulai Tayang</label>
                        <input type="date" id="edit_start_date" name="start_date" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2 text-xs outline-none focus:border-orange-500" />
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Tanggal Berakhir</label>
                        <input type="date" id="edit_end_date" name="end_date" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2 text-xs outline-none focus:border-orange-500" />
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Ganti Gambar Banner (Biarkan kosong jika tidak diganti)</label>
                    <input type="file" name="image" accept="image/*" onchange="previewEditImage(this)" class="w-full text-xs text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-bold file:bg-orange-50 file:text-orange-600 hover:file:bg-orange-100" />
                    <div id="editPreviewWrapper" class="mt-3">
                        <span class="text-[10px] font-bold text-slate-400 block mb-1">Pratinjau Gambar Saat Ini / Baru:</span>
                        <img id="editPreviewImg" src="" alt="Preview" class="h-32 w-full object-cover rounded-xl border border-slate-200 shadow-sm" />
                    </div>
                </div>
                <div class="flex items-center gap-2 pt-2">
                    <input type="checkbox" name="is_active" id="edit_is_active" value="1" class="w-4 h-4 text-orange-500 rounded border-slate-300 focus:ring-orange-500" />
                    <label for="edit_is_active" class="text-xs font-semibold text-slate-700">Aktifkan dan tampilkan banner di dashboard</label>
                </div>
                <div class="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                    <button type="button" onclick="closeEditModal()" class="px-4 py-2.5 rounded-xl border border-slate-200 text-xs font-bold text-slate-600 hover:bg-slate-50">Batal</button>
                    <button type="submit" class="px-5 py-2.5 rounded-xl bg-orange-500 hover:bg-orange-600 text-white text-xs font-bold shadow-md shadow-orange-500/25">Simpan Perubahan</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        lucide.createIcons();

        function openAddModal() {
            document.getElementById('addModal').classList.remove('hidden');
        }

        function closeAddModal() {
            document.getElementById('addModal').classList.add('hidden');
        }

        function previewAddImage(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    document.getElementById('addPreviewImg').src = e.target.result;
                    document.getElementById('addPreviewWrapper').classList.remove('hidden');
                }
                reader.readAsDataURL(input.files[0]);
            }
        }

        function openEditModal(banner) {
            const form = document.getElementById('editBannerForm');
            form.action = `/admin/banners/${banner.id}/update`;

            document.getElementById('edit_title').value = banner.title || '';
            document.getElementById('edit_description').value = banner.description || '';
            document.getElementById('edit_badge_text').value = banner.badge_text || '';
            document.getElementById('edit_sort_order').value = banner.sort_order ?? 0;
            document.getElementById('edit_link_url').value = banner.link_url || '';
            document.getElementById('edit_is_active').checked = Boolean(banner.is_active);

            if (banner.start_date) {
                document.getElementById('edit_start_date').value = banner.start_date.substring(0, 10);
            } else {
                document.getElementById('edit_start_date').value = '';
            }

            if (banner.end_date) {
                document.getElementById('edit_end_date').value = banner.end_date.substring(0, 10);
            } else {
                document.getElementById('edit_end_date').value = '';
            }

            document.getElementById('editPreviewImg').src = banner.formatted_image_url || banner.image_url;
            document.getElementById('editModal').classList.remove('hidden');
        }

        function closeEditModal() {
            document.getElementById('editModal').classList.add('hidden');
        }

        function previewEditImage(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    document.getElementById('editPreviewImg').src = e.target.result;
                }
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>
</body>
</html>
