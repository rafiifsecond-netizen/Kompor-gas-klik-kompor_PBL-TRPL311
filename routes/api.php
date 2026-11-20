<?php

use App\Http\Controllers\Admin\AdminPaymentController;
use App\Http\Controllers\Api\AdditionalCostController;
use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\PromoController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\ServiceCatalogController;
use App\Http\Controllers\Api\TechnicianController;
use App\Http\Controllers\Api\WalletController;
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
    Route::post('/auth/forgot-password', [AuthController::class, 'forgotPassword'])->middleware('throttle:10,1');
    Route::post('/auth/reset-password', [AuthController::class, 'resetPassword'])->middleware('throttle:10,1');

    // Public catalog & technician discovery
    Route::get('/categories', [ServiceCatalogController::class, 'categories']);
    Route::get('/services', [ServiceCatalogController::class, 'services']);
    Route::get('/services/{id}', [ServiceCatalogController::class, 'showServiceItem']);
    Route::get('/technicians', [TechnicianController::class, 'index']);
    Route::get('/technicians/{id}', [TechnicianController::class, 'show']);

    // Public promo list, dashboard banners & payment webhook
    Route::get('/promos', [PromoController::class, 'index']);
    Route::get('/dashboard/banners', [BannerController::class, 'index']);
    Route::post('/payments/webhook', [PaymentController::class, 'webhook']);

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
        Route::get('/technician/registration-status', [TechnicianController::class, 'registrationStatus']);
        Route::get('/travel-estimate', [OrderController::class, 'travelEstimate']);

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
        Route::patch('/orders/{id}/cancel', [OrderController::class, 'cancel']);
        Route::patch('/orders/{id}/services', [OrderController::class, 'updateServices'])->middleware('role:technician,admin');
        Route::patch('/orders/{id}/status', [OrderController::class, 'updateStatus'])->middleware('role:technician,admin');
        Route::patch('/orders/{id}/reschedule', [OrderController::class, 'reschedule']);
        Route::post('/orders/{id}/pay', [OrderController::class, 'pay']);
        Route::post('/orders/{id}/review', [ReviewController::class, 'store']);

        // Final Payment Specification Endpoints
        Route::post('/payments/checkout', [PaymentController::class, 'checkout']);
        Route::get('/payments/{id}/status', [PaymentController::class, 'status']);
        Route::post('/payments/{id}/upload-proof', [PaymentController::class, 'uploadProof']);
        Route::post('/payments/{id}/retry', [PaymentController::class, 'retry']);
        Route::post('/promos/validate', [PromoController::class, 'validateCode']);

        // Order In-App Chat
        Route::get('/chats', [ChatController::class, 'index']);
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
            Route::post('/payments/{id}/confirm-cash', [PaymentController::class, 'confirmCash']);
            Route::get('/wallet', [WalletController::class, 'getWallet']);
            Route::post('/wallet/payout', [WalletController::class, 'requestPayout']);
            Route::get('/wallet/transactions', [WalletController::class, 'getTransactions']);
        });

        /*
        |--------------------------------------------------------------------------
        | Admin Only (Web Dashboard & Management)
        |--------------------------------------------------------------------------
        */
        Route::middleware('role:admin')->prefix('admin')->group(function () {
            Route::get('/dashboard-stats', [AdminController::class, 'dashboardStats']);
            Route::get('/users', [AdminController::class, 'users']);
            Route::patch('/technicians/{id}/verify', [AdminController::class, 'verifyTechnician']);
            Route::patch('/users/{id}/role', [AdminController::class, 'updateUserRole']);
            Route::get('/activity-logs', [AdminController::class, 'activityLogs']);

            // Tariff & Catalog management (F017)
            Route::post('/services', [ServiceCatalogController::class, 'storeServiceItem']);
            Route::put('/services/{id}', [ServiceCatalogController::class, 'updateServiceItem']);
            Route::patch('/services/{id}/toggle-active', [ServiceCatalogController::class, 'toggleActive']);
            Route::delete('/services/{id}', [ServiceCatalogController::class, 'destroyServiceItem']);
            Route::patch('/services/{id}/tariff', [ServiceCatalogController::class, 'updateTariff']);

            // Promo Management CRUD
            Route::get('/promos', [PromoController::class, 'adminIndex']);
            Route::post('/promos', [PromoController::class, 'adminStore']);
            Route::put('/promos/{id}', [PromoController::class, 'adminUpdate']);
            Route::delete('/promos/{id}', [PromoController::class, 'adminDestroy']);

            // Payment & Financial Management
            Route::get('/payments', [AdminPaymentController::class, 'index']);
            Route::get('/payments/{id}/proof-url', [AdminPaymentController::class, 'getProofSignedUrl']);
            Route::post('/payments/{id}/verify-transfer', [AdminPaymentController::class, 'verifyTransfer']);
            Route::post('/payments/{id}/verify-cash', [AdminPaymentController::class, 'verifyCash']);
            Route::post('/payments/{id}/refund', [AdminPaymentController::class, 'refund']);
            Route::get('/payments/flagged-refunds', [AdminPaymentController::class, 'flaggedRefunds']);
            Route::get('/payments/export', [AdminPaymentController::class, 'exportCsv']);
            Route::post('/payouts/{id}/approve', [AdminPaymentController::class, 'approvePayout']);
            Route::post('/payouts/{id}/reject', [AdminPaymentController::class, 'rejectPayout']);
            Route::post('/settings', [AdminPaymentController::class, 'updateSetting']);

            // Dashboard Management - Banners (Bagian A)
            Route::get('/banners', [BannerController::class, 'adminIndex']);
            Route::post('/banners', [BannerController::class, 'store']);
            Route::put('/banners/{id}', [BannerController::class, 'update']);
            Route::patch('/banners/{id}/toggle-active', [BannerController::class, 'toggleActive']);
            Route::delete('/banners/{id}', [BannerController::class, 'destroy']);

            // Technician Approval & Management (Bagian B)
            Route::get('/technicians/pending', [AdminController::class, 'pendingTechnicians']);
            Route::post('/technicians/{id}/approve', [AdminController::class, 'approveTechnicianRegistration']);
            Route::post('/technicians/{id}/reject', [AdminController::class, 'rejectTechnicianRegistration']);
            Route::patch('/technicians/{id}/toggle-active', [AdminController::class, 'toggleTechnicianActive']);
        });
    });
});
