<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\JobController;
use App\Http\Controllers\ApplicationController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ProfileController;
use App\Http\Middleware\Authenticate;

// ─── Rate Limiting Configuration ──────────────────────────────────────────────
// - auth: 5 attempts per minute (stricter for auth endpoints)
// - api: 60 requests per minute per user

// Public routes (rate limited)
Route::middleware('throttle:5,1')->prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/password-reset/request', [AuthController::class, 'requestPasswordReset']);
    Route::post('/password-reset/confirm', [AuthController::class, 'confirmPasswordReset']);
});

// Public job viewing routes (no auth required)
Route::middleware('throttle:30,1')->group(function () {
    Route::get('/jobs', [JobController::class, 'index']);
    Route::get('/jobs/{job}', [JobController::class, 'show']);
});

// Protected routes (standard rate limit)
Route::middleware([
    Authenticate::class . ':sanctum',
    'throttle:60,1',  // 60 requests per minute
])->group(function () {
    // Auth
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    
    // Profile
    Route::post('/profile/update', [ProfileController::class, 'update'])->middleware('throttle:5,1');
    Route::get('/profile', [ProfileController::class, 'show']);
    
    // Users
    Route::get('/users/{user}', [UserController::class, 'show']);
    Route::get('/users/search', [UserController::class, 'search']);
    Route::get('/users/role', [UserController::class, 'hasRole']);
    Route::put('/users/{user}', [UserController::class, 'update']);
    
    // Jobs (write operations only)
    Route::get('/jobs/mine', [JobController::class, 'mine']);
    Route::post('/jobs', [JobController::class, 'store'])->middleware('throttle:10,1');  // Stricter for writes
    Route::put('/jobs/{job}', [JobController::class, 'update'])->middleware('throttle:10,1');
    Route::delete('/jobs/{job}', [JobController::class, 'destroy'])->middleware('throttle:10,1');
    
    // Applications
    Route::post('/applications', [ApplicationController::class, 'store'])->middleware('throttle:10,1');
    Route::get('/applications', [ApplicationController::class, 'index']);
    Route::get('/applications/{application}', [ApplicationController::class, 'show']);
    Route::put('/applications/{application}/status', [ApplicationController::class, 'updateStatus'])->middleware('throttle:10,1');
});

// Health check (no rate limit)
Route::get('/health', function () {
    return response()->json(['status' => 'ok', 'timestamp' => now()]);
});
