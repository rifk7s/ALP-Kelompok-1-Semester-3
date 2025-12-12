<?php

use Illuminate\Support\Facades\Route;

// Route::get('/', function () {
//     return view('workSelection');
// });
// Route::get('/hpp', fn()=> view('hppPanel', ['title' => 'Admin HPP Panel']));
// Route::get('/payment', fn()=> view('paymentPanel', ['title' => 'Admin Payment Panel']));

Route::get('/', function () {
    return view('adminLogin');
});

Route::get('/admin', function () {
    return view('dashboard');
});

Route::get('/admin/payments', function () {
    return view('paymentPanel', ['title' => 'Admin Payment Panel']);
});

Route::get('/admin/hpp', function () {
    return view('hppPanel', ['title' => 'Admin HPP Panel']);
});