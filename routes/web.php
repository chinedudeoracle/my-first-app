<?php

use Illuminate\Support\Facades\Route;
#use Laravel\Fortify\Features;
use App\Http\Controllers\TaskController;

Route::get('/health', function () {
    return 'OK';
});

Route::inertia('/', 'dashboard');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::inertia('dashboard', 'dashboard')->name('dashboard');

    Route::resource('tasks', TaskController::class);
});

require __DIR__.'/settings.php';
