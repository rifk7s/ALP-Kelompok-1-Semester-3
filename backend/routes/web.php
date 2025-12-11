<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});
Route::get('/hpp', fn()=> view('hpppanel', ['title' => 'Admin HPP Panel']));
