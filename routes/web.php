<?php

use App\Models\ActivityLog;
use App\Models\Order;
use App\Models\ServiceCategory;
use App\Models\ServiceItem;
use App\Models\TechnicianProfile;
use App\Models\User;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    $stats = [
        'users_count' => User::count(),
        'technicians_count' => TechnicianProfile::where('is_verified', true)->count(),
        'categories_count' => ServiceCategory::count(),
        'services_count' => ServiceItem::count(),
        'orders_count' => Order::count(),
        'logs_count' => ActivityLog::count(),
    ];

    $recentLogs = ActivityLog::with('actor:id,name,role')->latest('id')->take(6)->get();
    $categories = ServiceCategory::with('items')->get();

    return view('welcome', compact('stats', 'recentLogs', 'categories'));
});
