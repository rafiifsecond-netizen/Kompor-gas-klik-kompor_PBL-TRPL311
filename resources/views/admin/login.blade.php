<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - KlikKompor</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Inter', sans-serif; background: #ffffff; }
        @keyframes floatLogo {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-8px) rotate(1deg); }
        }
        @keyframes pulseGlow {
            0%, 100% { opacity: 0.4; transform: scale(1); }
            50% { opacity: 0.8; transform: scale(1.08); }
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .animate-float { animation: floatLogo 4s ease-in-out infinite; }
        .animate-glow { animation: pulseGlow 3s ease-in-out infinite; }
        .animate-fade { animation: fadeIn 0.6s ease-out forwards; }
        .input-glow:focus {
            box-shadow: 0 0 0 4px rgba(255, 128, 0, 0.15);
            transform: translateY(-2px);
        }
    </style>
</head>
<body class="h-screen w-screen overflow-hidden flex items-center justify-center bg-slate-50">

    <div class="relative w-full h-full flex flex-col md:flex-row overflow-hidden bg-white shadow-2xl">

        <!-- Left Side: Form Section (Animated Fade In) -->
        <div class="w-full md:w-1/2 h-full flex flex-col justify-center items-center px-8 md:px-16 lg:px-24 relative z-10 animate-fade">

            <div class="w-full max-w-md">
                <!-- Mobile Logo -->
                <div class="flex md:hidden justify-center mb-6">
                    <img src="{{ asset('images/logo.png') }}" alt="Logo" class="w-24 h-20 object-contain animate-float" onerror="this.src='https://via.placeholder.com/100?text=KK'" />
                </div>

                <div class="mb-8 text-center md:text-left">
                    <h1 class="text-3xl font-extrabold text-slate-900">Admin Portal</h1>
                    <p class="text-sm text-slate-500 mt-1">Masuk untuk mengelola sistem operasional KlikKompor.</p>
                </div>

                @if($errors->any())
                    <div class="mb-6 p-4 rounded-xl bg-red-50 border border-red-200 text-red-600 text-xs font-semibold flex items-center gap-3 animate-pulse">
                        <i data-lucide="alert-circle" class="w-5 h-5 shrink-0"></i>
                        <span>{{ $errors->first() }}</span>
                    </div>
                @endif

                <form method="POST" action="{{ route('admin.login.submit') }}" class="space-y-5">
                    @csrf

                    <!-- Email Input with Interactive Focus Animation -->
                    <div class="space-y-1.5">
                        <label class="text-xs font-bold text-slate-700 uppercase tracking-wider">Email Admin</label>
                        <div class="relative flex items-center">
                            <span class="absolute left-4 text-slate-400">
                                <i data-lucide="mail" class="w-5 h-5"></i>
                            </span>
                            <input type="email" name="email" required placeholder="admin@klikkompor.com"
                                class="w-full bg-slate-100/80 border border-slate-200 rounded-2xl py-4 pl-12 pr-4 text-sm font-medium text-slate-900 outline-none focus:border-[#ff8000] focus:bg-white input-glow transition-all duration-300" />
                        </div>
                    </div>

                    <!-- Password Input with Interactive Focus Animation -->
                    <div class="space-y-1.5">
                        <label class="text-xs font-bold text-slate-700 uppercase tracking-wider">Kata Sandi</label>
                        <div class="relative flex items-center">
                            <span class="absolute left-4 text-slate-400">
                                <i data-lucide="lock" class="w-5 h-5"></i>
                            </span>
                            <input type="password" name="password" required placeholder="••••••••"
                                class="w-full bg-slate-100/80 border border-slate-200 rounded-2xl py-4 pl-12 pr-4 text-sm font-medium text-slate-900 outline-none focus:border-[#ff8000] focus:bg-white input-glow transition-all duration-300" />
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit" class="w-full py-4 rounded-2xl bg-[#ff8000] hover:bg-[#e67300] text-white font-extrabold text-base shadow-lg shadow-orange-500/25 transition-all duration-300 transform active:scale-95 flex items-center justify-center gap-2">
                        <span>Masuk ke Dashboard</span>
                        <i data-lucide="arrow-right" class="w-5 h-5"></i>
                    </button>

                    <!-- Forgot Password Link -->
                    <div class="text-center pt-2">
                        <a href="#" onclick="alert('Silakan hubungi Super Admin untuk reset sandi.'); return false;" class="text-xs font-bold text-slate-500 hover:text-[#ff8000] transition">
                            Lupa Sandi?
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Right Side: Dark Sidebar (#090b27) with Floating Animated Logo & Glow -->
        <div class="hidden md:flex w-1/2 h-full bg-[#090b27] relative items-center justify-center overflow-hidden">
            <!-- Background Glowing Ambient Blobs -->
            <div class="absolute -top-20 -right-20 w-80 h-80 bg-orange-500/30 rounded-full blur-3xl animate-glow pointer-events-none"></div>
            <div class="absolute -bottom-20 -left-20 w-80 h-80 bg-indigo-500/20 rounded-full blur-3xl animate-glow pointer-events-none" style="animation-delay: 1.5s;"></div>

            <!-- Central Content Container -->
            <div class="relative z-10 text-center px-12">
                <!-- Floating Animated Logo -->
                <div class="inline-block p-6 rounded-3xl bg-white/5 backdrop-blur-xl border border-white/10 shadow-2xl mb-8 animate-float">
                    <img src="{{ asset('images/logo.png') }}" alt="Logo" class="w-48 h-40 object-contain drop-shadow-[0_10px_15px_rgba(255,128,0,0.3)]" onerror="this.src='https://via.placeholder.com/200?text=KlikKompor'" />
                </div>

                <h2 class="text-3xl font-extrabold text-white tracking-tight">KlikKompor Admin</h2>
                <p class="text-slate-400 text-sm mt-2 max-w-sm mx-auto">Platform manajemen layanan servis kompor gas terpadu, cepat, dan terpercaya.</p>

                <!-- Floating badge indicator -->
                <div class="inline-flex items-center gap-2 mt-8 px-4 py-2 rounded-full bg-white/10 backdrop-blur-md border border-white/10 text-xs font-semibold text-orange-400">
                    <span class="w-2 h-2 rounded-full bg-orange-500 animate-ping"></span>
                    <span>Sistem Aktif & Terenkripsi</span>
                </div>
            </div>
        </div>

    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>
