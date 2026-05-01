<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\TaskController;

Route::get('/health', function () {
    return 'OK';
});
/*
Route::get('/', function () {
    return inertia('dashboard');
})->name('home');
*/
Route::get('/', function () {
    return redirect('/tasks');
})->name('home');

/*
Route::middleware(['auth', 'verified'])->group(function () {
    Route::inertia('dashboard', 'dashboard')->name('dashboard');

    Route::resource('tasks', TaskController::class);
});
*/

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/dashboard', function () {
        return redirect('/tasks');
    })->name('dashboard');

    Route::resource('tasks', TaskController::class);
});

require __DIR__.'/settings.php';