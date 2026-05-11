<?php

namespace App\Providers;

use App\Models\Application;
use App\Models\Job;
use App\Policies\ApplicationPolicy;
use App\Policies\JobPolicy;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Register authorization policies
        $this->registerPolicies();
    }

    /**
     * Register authorization policies for models.
     */
    protected function registerPolicies(): void
    {
        // Job policy: Controls who can update/delete jobs
        // Only the recruiter who created the job can modify it
        Gate::policy(Job::class, JobPolicy::class);

        // Application policy: Controls who can update application status
        // Only the recruiter who posted the job can update application status
        // Applicant and recruiter can view applications
        Gate::policy(Application::class, ApplicationPolicy::class);
    }
}
