<?php

use App\Http\Controllers\Api\AdditionalCostController;
use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\ServiceCatalogController;
use App\Http\Controllers\Api\TechnicianController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public Routes (Katalog Layanan & Pencarian Teknisi)
|--------------------------------------------------------------------------
*/
Route::prefix('v1')->group(function () {
    // Auth endpoints with throttle rate-limiting
    Route::post('/auth/register', [AuthController::class, 'register'])->middleware('throttle:10,1');
    Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:10,1');

    // Public catalog & technician discovery
    Route::get('/categories', [ServiceCatalogController::class, 'categories']);
    Route::get('/services', [ServiceCatalogController::class, 'services']);
    Route::get('/technicians', [TechnicianController::class, 'index']);
    Route::get('/technicians/{id}', [TechnicianController::class, 'show']);

    /*
    |--------------------------------------------------------------------------
    | Authenticated Routes (Bearer Sanctum Token Required)
    |--------------------------------------------------------------------------
    */
    Route::middleware('auth:sanctum')->group(function () {
        // User profile & session
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::put('/auth/profile', [AuthController::class, 'updateProfile']);
        Route::put('/auth/password', [AuthController::class, 'changePassword']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        // Saved Addresses (Customer Address Book)
        Route::get('/addresses', [AddressController::class, 'index']);
        Route::post('/addresses', [AddressController::class, 'store']);
        Route::put('/addresses/{id}', [AddressController::class, 'update']);
        Route::delete('/addresses/{id}', [AddressController::class, 'destroy']);
        Route::patch('/addresses/{id}/default', [AddressController::class, 'setDefault']);

        // In-App Notifications
        Route::get('/notifications', [NotificationController::class, 'index']);
        Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
        Route::patch('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
        Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);

        // Order Management (Role-aware filtering inside controller)
        Route::get('/orders', [OrderController::class, 'index']);
        Route::get('/orders/{id}', [OrderController::class, 'show']);
        Route::patch('/orders/{id}/status', [OrderController::class, 'updateStatus'])->middleware('role:technician,admin');
        Route::patch('/orders/{id}/reschedule', [OrderController::class, 'reschedule']);
        Route::post('/orders/{id}/pay', [OrderController::class, 'pay']);
        Route::post('/orders/{id}/review', [ReviewController::class, 'store']);

        // Order In-App Chat
        Route::get('/orders/{id}/chat', [ChatController::class, 'show']);
        Route::post('/orders/{id}/chat/messages', [ChatController::class, 'sendMessage']);
        Route::patch('/orders/{id}/chat/read', [ChatController::class, 'markAsRead']);

        // Additional Costs for Orders
        Route::get('/orders/{id}/additional-costs', [AdditionalCostController::class, 'index']);
        Route::post('/orders/{id}/additional-costs', [AdditionalCostController::class, 'store']);
        Route::patch('/orders/{id}/additional-costs/{costId}/approve', [AdditionalCostController::class, 'approve']);
        Route::patch('/orders/{id}/additional-costs/{costId}/reject', [AdditionalCostController::class, 'reject']);

        /*
        |--------------------------------------------------------------------------
        | Customer Only
        |--------------------------------------------------------------------------
        */
        Route::middleware('role:customer')->group(function () {
            Route::post('/orders', [OrderController::class, 'store']);
        });

        /*
        |--------------------------------------------------------------------------
        | Technician Only
        |--------------------------------------------------------------------------
        */
        Route::middleware('role:technician')->group(function () {
            Route::patch('/technician/availability', [TechnicianController::class, 'updateAvailability']);
            Route::patch('/technician/location', [TechnicianController::class, 'updateLocation']);
        });

        /*
        |--------------------------------------------------------------------------
        | Admin Only (Web Dashboard)
        |--------------------------------------------------------------------------
        */
        Route::middleware('role:admin')->prefix('admin')->group(function () {
            Route::get('/dashboard-stats', [AdminController::class, 'dashboardStats']);
            Route::get('/users', [AdminController::class, 'users']);
            Route::patch('/technicians/{id}/verify', [AdminController::class, 'verifyTechnician']);
            Route::patch('/users/{id}/role', [AdminController::class, 'updateUserRole']);
            Route::get('/activity-logs', [AdminController::class, 'activityLogs']);

            // Tariff & Catalog management
            Route::post('/services', [ServiceCatalogController::class, 'storeServiceItem']);
            Route::patch('/services/{id}/tariff', [ServiceCatalogController::class, 'updateTariff']);
        });
    });
});
