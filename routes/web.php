<?php

use App\Models\ActivityLog;
use App\Models\Order;
use App\Models\Payment;
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

    return view('admin.services', compact('stats', 'services'));
})->name('admin.services');

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

Route::post('/admin/logout', function (Request $request) {
    Auth::logout();
    $request->session()->invalidate();
    $request->session()->regenerateToken();
    return redirect()->route('admin.logout');
})->name('admin.logout');
