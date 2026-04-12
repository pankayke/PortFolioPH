<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\JobController;
use App\Http\Controllers\ApplicationController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\CVController;
use App\Services\ExportService;
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
    Route::get('/jobs/{job}', [JobController::class, 'show'])->whereNumber('job');
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
    
    // CV Downloads
    Route::get('/profile/cv', [CVController::class, 'downloadMine']);
    Route::get('/users/{user}/cv', [CVController::class, 'downloadUserCV'])->whereNumber('user');
    Route::get('/applications/{application}/cv', [CVController::class, 'downloadApplicantCV'])->whereNumber('application');
    
    // Users
    Route::get('/users/{user}', [UserController::class, 'show'])->whereNumber('user');
    Route::get('/users/search', [UserController::class, 'search']);
    Route::get('/users/role', [UserController::class, 'hasRole']);
    Route::put('/users/{user}', [UserController::class, 'update'])->whereNumber('user');
    
    // Jobs (write operations only)
    Route::get('/jobs/mine', [JobController::class, 'mine']);
    Route::post('/jobs', [JobController::class, 'store'])->middleware('throttle:10,1');  // Stricter for writes
    Route::put('/jobs/{job}', [JobController::class, 'update'])->whereNumber('job')->middleware('throttle:10,1');
    Route::delete('/jobs/{job}', [JobController::class, 'destroy'])->whereNumber('job')->middleware('throttle:10,1');
    
    // Applications
    Route::post('/applications', [ApplicationController::class, 'store'])->middleware('throttle:10,1');
    Route::get('/applications', [ApplicationController::class, 'index']);
    Route::get('/applications/{application}', [ApplicationController::class, 'show'])->whereNumber('application');
    Route::put('/applications/{application}/status', [ApplicationController::class, 'updateStatus'])->whereNumber('application')->middleware('throttle:10,1');

    // Admin exports (token auth + explicit role check)
    Route::prefix('admin')->group(function () {
        Route::get('/users/export/{format}', function (string $format, ExportService $exportService, Request $request) {
            abort_unless($request->user()?->role === 'admin', 403, 'Forbidden');
            abort_unless(in_array($format, ['xlsx', 'csv'], true), 404, 'Unsupported format');
            return $exportService->exportUsers($format);
        })->whereIn('format', ['xlsx', 'csv']);

        Route::get('/jobs/export/{format}', function (string $format, ExportService $exportService, Request $request) {
            abort_unless($request->user()?->role === 'admin', 403, 'Forbidden');
            abort_unless(in_array($format, ['xlsx', 'csv'], true), 404, 'Unsupported format');
            return $exportService->exportJobs($format);
        })->whereIn('format', ['xlsx', 'csv']);

        Route::get('/applications/export/{format}', function (string $format, ExportService $exportService, Request $request) {
            abort_unless($request->user()?->role === 'admin', 403, 'Forbidden');
            abort_unless(in_array($format, ['xlsx', 'csv'], true), 404, 'Unsupported format');
            return $exportService->exportApplications($format);
        })->whereIn('format', ['xlsx', 'csv']);
    });
});

// Health check (no rate limit)
Route::get('/health', function () {
    return response()->json(['status' => 'ok', 'timestamp' => now()]);
});
