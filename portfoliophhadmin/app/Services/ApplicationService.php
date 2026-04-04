<?php

namespace App\Services;

use App\Models\Application;
use App\Models\Job;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

class ApplicationService
{
    /**
     * Get applications for user (job seeker sees own, recruiter sees for their jobs)
     *
     * @param User $user
     * @return LengthAwarePaginator
     */
    public function getApplications(User $user): LengthAwarePaginator
    {
        if ($user->role === 'job_seeker') {
            return $user->applications()
                ->with('job:id,title', 'job.recruiter:id,name,email')
                ->paginate(15);
        }

        // Recruiter sees applications for their jobs
        return Application::whereHas('job', function ($query) use ($user) {
            $query->where('recruiter_id', $user->id);
        })
            ->with('user:id,name,email', 'job:id,title')
            ->paginate(15);
    }

    /**
     * Get single application
     *
     * @param Application $application
     * @return Application
     */
    public function getApplication(Application $application): Application
    {
        return $application->load('user:id,name,email', 'job');
    }

    /**
     * Create new application
     *
     * @param User $user
     * @param array $validated
     * @return Application
     * @throws \Exception
     */
    public function createApplication(User $user, array $validated): Application
    {
        $job = Job::findOrFail($validated['job_id']);

        // Check if already applied
        $existing = Application::where('user_id', $user->id)
            ->where('job_id', $job->id)
            ->first();

        if ($existing) {
            throw new \Exception('You have already applied for this job', 409);
        }

        $application = $user->applications()->create($validated);
        
        // Refresh to ensure all fields including defaults are loaded
        return $application->fresh()->load('job:id,title');
    }

    /**
     * Update application status
     *
     * @param Application $application
     * @param array $validated
     * @return Application
     */
    public function updateApplicationStatus(Application $application, array $validated): Application
    {
        $application->update($validated);
        return $application->fresh();
    }
}
