<?php

use App\Models\ActivityLog;
use App\Models\Notification;
use App\Models\Order;
use App\Models\Payment;
use App\Models\Review;
use App\Models\ServiceCategory;
use App\Models\ServiceItem;
use App\Models\TechnicianProfile;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    if (Auth::check() && Auth::user()->role === 'admin') {
        return redirect()->route('admin.dashboard');
    }
    return view('admin.login');
});

// Admin Web Login Routes
Route::get('/admin/login', function () {
    if (Auth::check() && Auth::user()->role === 'admin') {
        return redirect()->route('admin.dashboard');
    }
    return view('admin.login');
})->name('admin.login');

Route::post('/admin/login', function (Request $request) {
    $credentials = $request->validate([
        'email' => ['required', 'email'],
        'password' => ['required'],
    ]);

    $user = User::where('email', $credentials['email'])->first();

    if ($user && Hash::check($credentials['password'], $user->password)) {
        if ($user->role !== 'admin') {
            return back()->withErrors(['email' => 'Akses ditolak! Akun ini bukan akun Admin. Admin hanya dapat login melalui Web Admin.']);
        }
        if (!$user->is_active) {
            return back()->withErrors(['email' => 'Akun admin dinonaktifkan.']);
        }

        Auth::login($user);
        $request->session()->regenerate();

        return redirect()->route('admin.dashboard');
    }

    return back()->withErrors(['email' => 'Email atau kata sandi salah.']);
})->name('admin.login.submit');

// ── Admin Forgot & Reset Password Routes ────────────────────────────────────
Route::get('/admin/forgot-password', function () {
    return view('admin.forgot_password');
})->name('admin.forgot_password');

Route::post('/admin/forgot-password', function (Request $request) {
    $request->validate(['email' => 'required|email|exists:users,email']);
    $user = User::where('email', $request->email)->first();

    if ($user->role !== 'admin') {
        return back()->withErrors(['email' => 'Email ini bukan akun administrator.']);
    }

    $token = \Illuminate\Support\Str::random(60);
    $resetLink = route('admin.reset_password', ['token' => $token, 'email' => $user->email]);

    return back()
        ->with('success', 'Tautan pemulihan kata sandi telah dikirim ke email Anda!')
        ->with('resetLink', $resetLink);
})->name('admin.forgot_password.submit');

Route::get('/admin/reset-password/{token}', function ($token, Request $request) {
    return view('admin.reset_password', ['token' => $token, 'email' => $request->email]);
})->name('admin.reset_password');

Route::post('/admin/reset-password', function (Request $request) {
    $request->validate([
        'email' => 'required|email|exists:users,email',
        'password' => 'required|min:6|confirmed',
        'token' => 'required',
    ]);

    $user = User::where('email', $request->email)->first();
    if (!$user || $user->role !== 'admin') {
        return back()->withErrors(['email' => 'Akun admin tidak ditemukan.']);
    }

    $user->update([
        'password' => Hash::make($request->password),
    ]);

    return redirect()->route('admin.login')->with('success', 'Kata sandi berhasil diatur ulang! Silakan login.');
})->name('admin.reset_password.submit');

Route::get('/admin/dashboard', function () {
    $user = Auth::user();
    if (!$user || $user->role !== 'admin') {
        return redirect()->route('admin.login');
    }

    $stats = [
        'total_users' => User::where('role', 'customer')->count(),
        'total_technicians' => TechnicianProfile::count(),
        'today_orders' => Order::whereDate('created_at', today())->count(),
        'completed_orders' => Order::where('status', 'completed')->count(),
        'revenue' => Order::where('payment_status', 'paid')->sum('total_amount'),
    ];

    $statusCounts = [
        'pending' => Order::where('status', 'pending')->count(),
        'processing' => Order::whereIn('status', ['accepted', 'in_progress'])->count(),
        'on_the_way' => Order::where('status', 'on_the_way')->count(),
        'completed' => Order::where('status', 'completed')->count(),
        'cancelled' => Order::where('status', 'cancelled')->count(),
    ];

    $recentOrders = Order::with(['customer', 'technician'])->latest()->take(5)->get();
    $activeTechnicians = TechnicianProfile::with('user')->take(4)->get();

    $chartDays = [];
    $chartCounts = [];
    for ($i = 6; $i >= 0; $i--) {
        $date = now()->subDays($i);
        $chartDays[] = $date->format('d M');
        $chartCounts[] = Order::whereDate('created_at', $date->toDateString())->count();
    }

    return view('admin.dashboard', compact('stats', 'statusCounts', 'recentOrders', 'activeTechnicians', 'chartDays', 'chartCounts'));
})->name('admin.dashboard');

// ── Profile Admin ────────────────────────────────────────────────────────────
Route::get('/admin/profile', function () {
    $user = Auth::user();
    if (!$user || $user->role !== 'admin') {
        return redirect()->route('admin.login');
    }
    return view('admin.profile');
})->name('admin.profile');

Route::post('/admin/profile', function (Request $request) {
    $user = Auth::user();
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users,email,'.$user->id,
        'phone' => 'required|string',
    ]);

    $user->update($validated);
    return back()->with('success', 'Profil administrator berhasil diperbarui.');
})->name('admin.profile.update');

Route::post('/admin/profile/password', function (Request $request) {
    $user = Auth::user();
    $validated = $request->validate([
        'current_password' => 'required',
        'password' => 'required|min:6|confirmed',
    ]);

    if (!Hash::check($validated['current_password'], $user->password)) {
        return back()->withErrors(['current_password' => 'Kata sandi saat ini salah.']);
    }

    $user->update(['password' => Hash::make($validated['password'])]);
    return back()->with('success', 'Kata sandi administrator berhasil diperbarui.');
})->name('admin.profile.password');

// ── Notifications Admin ──────────────────────────────────────────────────────
Route::get('/admin/notifications', function () {
    $user = Auth::user();
    if (!$user || $user->role !== 'admin') {
        return redirect()->route('admin.login');
    }

    $notifications = Notification::where('user_id', $user->id)
        ->whereNull('read_at')
        ->latest()
        ->get();

    return view('admin.notifications', compact('notifications'));
})->name('admin.notifications');

Route::post('/admin/notifications/read-all', function () {
    $user = Auth::user();
    Notification::where('user_id', $user->id)
        ->whereNull('read_at')
        ->update(['read_at' => now()]);

    return back()->with('success', 'Semua pemberitahuan telah dibaca.');
})->name('admin.notifications.readAll');

Route::post('/admin/notifications/{id}/read', function ($id) {
    $user = Auth::user();
    $notif = Notification::where('user_id', $user->id)->findOrFail($id);
    $notif->markAsRead();

    return back()->with('success', 'Pemberitahuan telah dibaca.');
})->name('admin.notifications.readSingle');

// ── Orders CRUD ─────────────────────────────────────────────────────────────
Route::get('/admin/orders', function () {
    $user = Auth::user();
    if (!$user || $user->role !== 'admin') {
        return redirect()->route('admin.login');
    }

    $stats = [
        'total_users' => User::where('role', 'customer')->count(),
        'total_technicians' => TechnicianProfile::count(),
        'today_orders' => Order::whereDate('created_at', today())->count(),
        'completed_orders' => Order::where('status', 'completed')->count(),
    ];

    $orders = Order::with(['customer', 'technician'])->latest()->get();

    return view('admin.orders', compact('stats', 'orders'));
})->name('admin.orders');

Route::delete('/admin/orders/{id}', function ($id) {
    Order::findOrFail($id)->delete();
    return back()->with('success', 'Pesanan berhasil dihapus.');
})->name('admin.orders.destroy');

// ── Customers CRUD ──────────────────────────────────────────────────────────
Route::get('/admin/customers', function () {
    $user = Auth::user();
    if (!$user || $user->role !== 'admin') {
        return redirect()->route('admin.login');
    }

    $stats = [
        'total_users' => User::where('role', 'customer')->count(),
        'total_technicians' => TechnicianProfile::count(),
        'today_orders' => Order::whereDate('created_at', today())->count(),
        'completed_orders' => Order::where('status', 'completed')->count(),
    ];

    $customers = User::where('role', 'customer')->withCount('customerOrders')->latest()->get();

    return view('admin.customers', compact('stats', 'customers'));
})->name('admin.customers');

Route::post('/admin/customers', function (Request $request) {
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users,email',
        'phone' => 'required|string',
        'address' => 'nullable|string',
        'password' => 'required|min:6',
    ]);

    User::create([
        'name' => $validated['name'],
        'email' => $validated['email'],
        'phone' => $validated['phone'],
        'address' => $validated['address'] ?? 'Jl. Bunga',
        'password' => Hash::make($validated['password']),
        'role' => 'customer',
        'is_active' => true,
    ]);

    return back()->with('success', 'Pelanggan baru berhasil ditambahkan.');
})->name('admin.customers.store');

Route::delete('/admin/customers/{id}', function ($id) {
    User::findOrFail($id)->delete();
    return back()->with('success', 'Pelanggan berhasil dihapus.');
})->name('admin.customers.destroy');

// ── Technicians CRUD ────────────────────────────────────────────────────────
Route::get('/admin/technicians', function () {
    $user = Auth::user();
    if (!$user || $user->role !== 'admin') {
        return redirect()->route('admin.login');
    }

    $stats = [
        'total_users' => User::where('role', 'customer')->count(),
        'total_technicians' => TechnicianProfile::count(),
        'today_orders' => Order::whereDate('created_at', today())->count(),
        'completed_orders' => Order::where('status', 'completed')->count(),
    ];

    $technicians = User::where('role', 'technician')->withCount('technicianOrders')->latest()->get();

    return view('admin.technicians', compact('stats', 'technicians'));
})->name('admin.technicians');

Route::post('/admin/technicians', function (Request $request) {
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users,email',
        'phone' => 'required|string',
        'address' => 'nullable|string',
        'password' => 'required|min:6',
    ]);

    $user = User::create([
        'name' => $validated['name'],
        'email' => $validated['email'],
        'phone' => $validated['phone'],
        'address' => $validated['address'] ?? 'Jl. Bunga',
        'password' => Hash::make($validated['password']),
        'role' => 'technician',
        'is_active' => true,
    ]);

    TechnicianProfile::create([
        'user_id' => $user->id,
        'is_verified' => true,
        'is_available' => true,
        'rating_avg' => 5.0,
    ]);

    return back()->with('success', 'Teknisi baru berhasil ditambahkan.');
})->name('admin.technicians.store');

Route::delete('/admin/technicians/{id}', function ($id) {
    User::findOrFail($id)->delete();
    return back()->with('success', 'Teknisi berhasil dihapus.');
})->name('admin.technicians.destroy');

// ── Services CRUD ───────────────────────────────────────────────────────────
Route::get('/admin/services', function () {
    $user = Auth::user();
    if (!$user || $user->role !== 'admin') {
        return redirect()->route('admin.login');
    }

    $stats = [
        'total_users' => User::where('role', 'customer')->count(),
        'total_technicians' => TechnicianProfile::count(),
        'today_orders' => Order::whereDate('created_at', today())->count(),
        'completed_orders' => Order::where('status', 'completed')->count(),
    ];

    $services = ServiceItem::with('category')->latest()->get();
    $categories = ServiceCategory::all();

    return view('admin.services', compact('stats', 'services', 'categories'));
})->name('admin.services');

Route::post('/admin/services', function (Request $request) {
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'description' => 'required|string',
        'base_price' => 'required|numeric',
        'service_category_id' => 'nullable|exists:service_categories,id',
    ]);

    $category = ServiceCategory::firstOrCreate(['name' => 'Service Kompor Gas'], ['slug' => 'service-kompor-gas']);

    ServiceItem::create([
        'service_category_id' => $validated['service_category_id'] ?? $category->id,
        'name' => $validated['name'],
        'slug' => \Illuminate\Support\Str::slug($validated['name']),
        'description' => $validated['description'],
        'base_price' => $validated['base_price'],
        'is_active' => true,
    ]);

    return back()->with('success', 'Layanan baru berhasil ditambahkan.');
})->name('admin.services.store');

Route::delete('/admin/services/{id}', function ($id) {
    ServiceItem::findOrFail($id)->delete();
    return back()->with('success', 'Layanan berhasil dihapus.');
})->name('admin.services.destroy');

// ── Payments CRUD ───────────────────────────────────────────────────────────
Route::get('/admin/payments', function () {
    $user = Auth::user();
    if (!$user || $user->role !== 'admin') {
        return redirect()->route('admin.login');
    }

    $stats = [
        'total_users' => User::where('role', 'customer')->count(),
        'total_technicians' => TechnicianProfile::count(),
        'today_orders' => Order::whereDate('created_at', today())->count(),
        'completed_orders' => Order::where('status', 'completed')->count(),
    ];

    $payments = Payment::with(['order.customer', 'customer'])->latest()->get();

    return view('admin.payments', compact('stats', 'payments'));
})->name('admin.payments');

Route::delete('/admin/payments/{id}', function ($id) {
    Payment::findOrFail($id)->delete();
    return back()->with('success', 'Transaksi pembayaran berhasil dihapus.');
})->name('admin.payments.destroy');

// ── Reviews ─────────────────────────────────────────────────────────────────
Route::get('/admin/reviews', function () {
    $user = Auth::user();
    if (!$user || $user->role !== 'admin') {
        return redirect()->route('admin.login');
    }

    $stats = [
        'total_users' => User::where('role', 'customer')->count(),
        'total_technicians' => TechnicianProfile::count(),
        'today_orders' => Order::whereDate('created_at', today())->count(),
        'completed_orders' => Order::where('status', 'completed')->count(),
    ];

    $reviews = Review::with(['customer', 'technician'])->latest()->get();

    return view('admin.reviews', compact('stats', 'reviews'));
})->name('admin.reviews');

Route::delete('/admin/reviews/{id}', function ($id) {
    Review::findOrFail($id)->delete();
    return back()->with('success', 'Ulasan berhasil dihapus.');
})->name('admin.reviews.destroy');

// ── Reports ─────────────────────────────────────────────────────────────────
Route::get('/admin/reports', function () {
    $user = Auth::user();
    if (!$user || $user->role !== 'admin') {
        return redirect()->route('admin.login');
    }

    $stats = [
        'total_users' => User::where('role', 'customer')->count(),
        'total_technicians' => TechnicianProfile::count(),
        'today_orders' => Order::whereDate('created_at', today())->count(),
        'completed_orders' => Order::where('status', 'completed')->count(),
    ];

    $revenue = Order::where('payment_status', 'paid')->sum('total_amount');

    return view('admin.reports', compact('stats', 'revenue'));
})->name('admin.reports');

// ── Settings ────────────────────────────────────────────────────────────────
Route::get('/admin/settings', function () {
    $user = Auth::user();
    if (!$user || $user->role !== 'admin') {
        return redirect()->route('admin.login');
    }

    $stats = [
        'total_users' => User::where('role', 'customer')->count(),
        'total_technicians' => TechnicianProfile::count(),
        'today_orders' => Order::whereDate('created_at', today())->count(),
        'completed_orders' => Order::where('status', 'completed')->count(),
    ];

    return view('admin.settings', compact('stats'));
})->name('admin.settings');

Route::post('/admin/settings', function (Request $request) {
    return back()->with('success', 'Pengaturan sistem & tarif berhasil diperbarui.');
})->name('admin.settings.update');

Route::post('/admin/logout', function (Request $request) {
    Auth::logout();
    $request->session()->invalidate();
    $request->session()->regenerateToken();
    return redirect()->route('admin.login');
})->name('admin.logout');
