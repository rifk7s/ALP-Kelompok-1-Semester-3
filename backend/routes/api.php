<?php

// use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductImageController;

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
});

/*
    Profile Routes
*/
Route::patch('profile/update', [ProfileController::class, 'update']);
Route::get('profile/me', [ProfileController::class, 'userrn']);

/*
    Product Routes
*/
Route::apiResource('/products/product', ProductController::class);
Route::apiResource('/products/categories', CategoryController::class);
Route::apiResource('/products/product-images', ProductImageController::class);
