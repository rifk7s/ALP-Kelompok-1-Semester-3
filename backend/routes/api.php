<?php

// use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ProductContributionController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductImageController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\ChatMessageController;
use App\Http\Controllers\ChatListController;
use App\Http\Controllers\PetaniDataController;
use App\Http\Controllers\HppPriceController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\NotificationController;

// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');

/*
    Authentication Routes
*/
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Protected routes (authentication required with Sanctum)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);
    Route::post('/chat/send', [ChatMessageController::class, 'sendMessage']);
    Route::post('/chat/notify', [ChatMessageController::class, 'notifyMessage']);
    Route::get('/chat/{chatId}', [ChatMessageController::class, 'getMessages']);
    Route::delete('/chat/{chatId}/message/{messageId}', [ChatMessageController::class, 'deleteMessage']);
    Route::get('/chat/list', [ChatListController::class, 'getChatList']);
    Route::post('/chat/create', [ChatListController::class, 'createChat']);
    Route::delete('/chat/{chatId}', [ChatListController::class, 'deleteChat']);
    
    /*
        Profile Routes
    */
    Route::patch('profile/update', [ProfileController::class, 'update']);
    Route::get('profile/me', [ProfileController::class, 'userrn']);

    /*
        Cart Routes
    */
    Route::get('cart', [CartController::class, 'index']);
    Route::post('cart', [CartController::class, 'store']);
    Route::put('cart/{cart}', [CartController::class, 'update']);
    Route::delete('cart/{cart}', [CartController::class, 'destroy']);
    Route::delete('cart', [CartController::class, 'clear']);

    /*
        Petani Data Routes (BUMDes only)
    */
    Route::apiResource('petani-data', PetaniDataController::class);
    Route::patch('petani-data/{petaniData}/toggle-active', [PetaniDataController::class, 'toggleActive']);

    /*
        Order Routes
    */
    Route::post('/checkout', [OrderController::class, 'checkout']);
    Route::get('/orders', [OrderController::class, 'index']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::get('/orders/{order}/status', [OrderController::class, 'checkStatus']);
    Route::post('/orders/{order}/cancel', [OrderController::class, 'cancel']);
    Route::post('/orders/{order}/complete', [OrderController::class, 'complete']);
    
    /*
        Payment proof upload
    */
    Route::post('/orders/{order}/payment-proof', [PaymentController::class, 'uploadProof']);

    /*
        Notification Routes
    */
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::post('/notifications/{notification}/mark-read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/mark-all-read', [NotificationController::class, 'markAllAsRead']);
});

/*
    BUMDes Info (for chat)
*/
Route::get('/bumdes', function () {
    $bumdes = \App\Models\User::where('role', 'bumdes')->first();
    if (!$bumdes) {
        return response()->json(['message' => 'BUMDes not found'], 404);
    }
    return response()->json([
        'id' => $bumdes->id,
        'name' => $bumdes->name,
        'phone' => $bumdes->phone,
    ]);
});

/*
    Product Routes
*/
Route::apiResource('/products/product', ProductController::class);
Route::apiResource('/products/categories', CategoryController::class);
Route::apiResource('/products/product-images', ProductImageController::class);
Route::apiResource('/products/contributions', ProductContributionController::class);
Route::apiResource('/products/hpp-prices', HppPriceController::class);

/*
    Admin Routes (BUMDes only)
*/
Route::middleware('auth:sanctum')->prefix('admin')->group(function () {
    Route::get('/orders', [AdminController::class, 'index']);
    Route::get('/orders/{order}', [AdminController::class, 'show']);
    Route::post('/orders/{order}/confirm-payment', [AdminController::class, 'confirmPayment']);
    Route::post('/orders/{order}/reject-payment', [AdminController::class, 'rejectPayment']);
    Route::post('/orders/{order}/mark-processing', [AdminController::class, 'markProcessing']);
    Route::post('/orders/{order}/mark-shipped', [AdminController::class, 'markShipped']);
    Route::post('/orders/{order}/mark-completed', [AdminController::class, 'markCompleted']);
});

// HPP Panel Routes for testing without auth
Route::apiResource('/prices', HppPriceController::class);
