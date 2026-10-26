<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lupa Kata Sandi Admin - KlikKompor</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #090b27; }
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-8px); }
        }
        @keyframes pulseGlow {
            0%, 100% { opacity: 0.6; transform: scale(1); }
            50% { opacity: 1; transform: scale(1.08); }
        }
        .animate-float { animation: float 4s ease-in-out infinite; }
        .animate-glow { animation: pulseGlow 3s ease-in-out infinite; }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center relative overflow-hidden p-6 text-white">

    <!-- Ambient Glowing Orbs Background -->
    <div class="absolute -top-32 -left-32 w-96 h-96 bg-orange-500/20 rounded-full blur-3xl animate-glow pointer-events-none"></div>
    <div class="absolute -bottom-32 -right-32 w-96 h-96 bg-amber-500/20 rounded-full blur-3xl animate-glow pointer-events-none" style="animation-delay: 1.5s;"></div>

    <div class="w-full max-w-md bg-slate-900/80 backdrop-blur-xl border border-slate-800 rounded-3xl p-8 shadow-2xl relative z-10 space-y-8">

        <!-- Logo Header -->
        <div class="text-center space-y-3">
            <img src="{{ asset('images/logo.png') }}" alt="Logo KlikKompor" class="w-24 h-20 object-contain mx-auto animate-float drop-shadow-lg" onerror="this.src='https://via.placeholder.com/100?text=KK'" />
            <h1 class="text-2xl font-extrabold text-orange-500 tracking-tight">Lupa Kata Sandi Admin</h1>
            <p class="text-xs text-slate-400 max-w-xs mx-auto">Masukkan email terdaftar. Kami akan mengirimkan tautan reset kata sandi ke email Anda.</p>
        </div>

        @if(session('success'))
            <div class="p-5 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 text-xs space-y-3">
                <div class="flex items-center gap-3 font-bold">
                    <i data-lucide="check-circle" class="w-5 h-5 text-emerald-500 shrink-0"></i>
                    <span>{{ session('success') }}</span>
                </div>
                @if(session('resetLink'))
                    <div class="pt-2 border-t border-emerald-500/25">
                        <a href="{{ session('resetLink') }}" class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-extrabold text-xs transition shadow-md w-full justify-center">
                            <i data-lucide="external-link" class="w-4 h-4"></i> Klik di Sini untuk Atur Sandi Baru
                        </a>
                    </div>
                @endif
            </div>
        @endif

        @if($errors->any())
            <div class="p-4 rounded-2xl bg-red-500/10 border border-red-500/30 text-red-400 text-xs font-bold flex items-center gap-3">
                <i data-lucide="alert-circle" class="w-5 h-5 text-red-500 shrink-0"></i>
                <span>{{ $errors->first() }}</span>
            </div>
        @endif

        <form method="POST" action="{{ route('admin.forgot_password.submit') }}" class="space-y-5">
            @csrf
            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1.5">Alamat Email Admin</label>
                <div class="relative">
                    <input type="email" name="email" required placeholder="admin@klikkompor.com" class="w-full bg-slate-800/80 border border-slate-700/80 rounded-2xl py-3.5 pl-11 pr-4 text-xs text-white outline-none focus:border-orange-500 transition shadow-inner" />
                    <i data-lucide="mail" class="w-4 h-4 text-slate-400 absolute left-4 top-3.5"></i>
                </div>
            </div>

            <button type="submit" class="w-full py-4 rounded-2xl bg-gradient-to-r from-orange-500 to-amber-500 hover:from-orange-600 hover:to-amber-600 text-white font-extrabold text-xs tracking-wide shadow-lg shadow-orange-500/30 transition transform hover:-translate-y-0.5 flex items-center justify-center gap-2">
                <i data-lucide="send" class="w-4 h-4"></i> Kirim Tautan Reset Ke Email
            </button>
        </form>

        <div class="text-center pt-2 border-t border-slate-800">
            <a href="{{ route('admin.login') }}" class="text-xs font-bold text-slate-400 hover:text-orange-400 transition flex items-center justify-center gap-2">
                <i data-lucide="arrow-left" class="w-4 h-4"></i> Kembali ke Login Admin
            </a>
        </div>

    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>
