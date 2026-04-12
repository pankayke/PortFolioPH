<?php

use App\Http\Controllers\AuthWebController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\JobWebController;
use App\Http\Controllers\ApplicationWebController;
use App\Http\Controllers\AdminWebController;
use Illuminate\Support\Facades\Route;

// Public routes - redirect to login
Route::get('/', function () {
    return redirect()->route('login');
});

// Authentication routes
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthWebController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthWebController::class, 'login']);
    
    Route::get('/register', [AuthWebController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthWebController::class, 'register']);
});

// Protected routes - require authentication
Route::middleware('auth')->group(function () {
    // Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    
    // Profile
    Route::get('/profile', [AuthWebController::class, 'profile'])->name('profile');
    Route::post('/profile', [AuthWebController::class, 'updateProfile'])->name('profile.update');
    
    // Logout
    Route::post('/logout', [AuthWebController::class, 'logout'])->name('logout');
    
    // Jobs - Important: non-parameterized routes before parameterized ones
    Route::get('/jobs/create', [JobWebController::class, 'create'])->name('jobs.create')->middleware('recruiter');
    Route::get('/jobs/list', [JobWebController::class, 'list'])->name('jobs.list');
    Route::get('/jobs', [JobWebController::class, 'index'])->name('jobs.index');
    Route::post('/jobs', [JobWebController::class, 'store'])->name('jobs.store')->middleware('recruiter');
    Route::get('/jobs/{job}', [JobWebController::class, 'show'])->name('jobs.show');
    
    Route::middleware('recruiter')->group(function () {
        Route::get('/jobs/{job}/edit', [JobWebController::class, 'edit'])->name('jobs.edit');
        Route::put('/jobs/{job}', [JobWebController::class, 'update'])->name('jobs.update');
        Route::delete('/jobs/{job}', [JobWebController::class, 'destroy'])->name('jobs.destroy');
        Route::post('/jobs/{job}/status', [JobWebController::class, 'updateStatus'])->name('jobs.update-status');
    });
    
    // Applications
    Route::get('/applications', [ApplicationWebController::class, 'index'])->name('applications.index');
    Route::get('/my-applications', [ApplicationWebController::class, 'myApplications'])->name('my-applications');
    Route::get('/applications/{application}', [ApplicationWebController::class, 'show'])->name('applications.show');
    Route::post('/applications', [ApplicationWebController::class, 'store'])->name('applications.store');
    
    Route::middleware('recruiter')->group(function () {
        Route::get('/applications/{application}/edit', [ApplicationWebController::class, 'edit'])->name('applications.edit');
        Route::put('/applications/{application}/status', [ApplicationWebController::class, 'updateStatus'])->name('applications.update-status');
    });
});

// Admin routes - require authentication and admin role
Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {
    // Dashboard
    Route::get('/dashboard', [AdminWebController::class, 'dashboard'])->name('dashboard');
    
    // Users Management
    Route::prefix('users')->name('users.')->group(function () {
        Route::get('/', [AdminWebController::class, 'users'])->name('index');
        Route::get('/{user}', [AdminWebController::class, 'showUser'])->name('show');
        Route::get('/{user}/edit', [AdminWebController::class, 'editUser'])->name('edit');
        Route::put('/{user}', [AdminWebController::class, 'updateUser'])->name('update');
        Route::post('/{user}/suspend', [AdminWebController::class, 'suspendUser'])->name('suspend');
        Route::post('/{user}/unsuspend', [AdminWebController::class, 'unsuspendUser'])->name('unsuspend');
        Route::delete('/{user}', [AdminWebController::class, 'deleteUser'])->name('delete');
        
        // Download CV for user
        Route::get('/{user}/download-cv', [AdminWebController::class, 'downloadCV'])->name('download-cv');
        
        // Export routes
        Route::get('/export/excel', [AdminWebController::class, 'exportUsers'])->name('export-excel');
        Route::get('/export/csv', [AdminWebController::class, 'exportUsersCSV'])->name('export-csv');
    });
    
    // Jobs Management
    Route::prefix('jobs')->name('jobs.')->group(function () {
        Route::get('/', [AdminWebController::class, 'jobs'])->name('index');
        Route::get('/{job}', [AdminWebController::class, 'showJob'])->name('show');
        Route::post('/{job}/suspend', [AdminWebController::class, 'suspendJob'])->name('suspend');
        Route::post('/{job}/approve', [AdminWebController::class, 'approveJob'])->name('approve');
        Route::delete('/{job}', [AdminWebController::class, 'deleteJob'])->name('delete');
        
        // Export routes
        Route::get('/export/excel', [AdminWebController::class, 'exportJobs'])->name('export-excel');
        Route::get('/export/csv', [AdminWebController::class, 'exportJobsCSV'])->name('export-csv');
    });
    
    // Applications Analytics
    Route::prefix('applications')->name('applications.')->group(function () {
        Route::get('/', [AdminWebController::class, 'applications'])->name('index');
        
        // Download CV for applicant
        Route::get('/{application}/download-cv', [AdminWebController::class, 'downloadApplicantCV'])->name('download-cv');
        
        // Export routes
        Route::get('/export/excel', [AdminWebController::class, 'exportApplications'])->name('export-excel');
        Route::get('/export/csv', [AdminWebController::class, 'exportApplicationsCSV'])->name('export-csv');
    });

    // Settings
    Route::get('/settings', [AdminWebController::class, 'settings'])->name('settings');
    Route::put('/settings', [AdminWebController::class, 'updateSettings'])->name('settings.update');
    
    // Audit Log
    Route::get('/audit', [AdminWebController::class, 'auditLog'])->name('audit');
});
