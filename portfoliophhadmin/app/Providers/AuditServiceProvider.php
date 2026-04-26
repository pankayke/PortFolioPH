<?php

namespace App\Providers;

use App\Models\Application;
use App\Models\Job;
use App\Models\Setting;
use App\Models\User;
use App\Observers\AuditObserver;
use Illuminate\Support\ServiceProvider;

class AuditServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        User::observe(AuditObserver::class);
        Job::observe(AuditObserver::class);
        Application::observe(AuditObserver::class);
        Setting::observe(AuditObserver::class);
    }
}
