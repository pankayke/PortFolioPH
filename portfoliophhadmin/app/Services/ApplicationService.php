<?php

namespace App\Services;

use App\Models\Application;
use App\Models\Job;
use App\Models\User;
use App\Notifications\ApplicationStatusUpdatedNotification;
use Illuminate\Pagination\LengthAwarePaginator;

class ApplicationService
{
    /**
     * Get applications for user (job seeker sees own, recruiter sees for their jobs)
     */
    public function getApplications(User $user, int $perPage = 15): LengthAwarePaginator
    {
        if ($user->role === 'job_seeker') {
            return $user->applications()
                ->with('job:id,title', 'job.recruiter:id,name,email')
                ->latest()
                ->paginate($perPage);
        }

        // Recruiter sees applications for their jobs
        return Application::whereHas('job', function ($query) use ($user) {
            $query->where('recruiter_id', $user->id);
        })
            ->with('user:id,name,email', 'job:id,title')
            ->latest()
            ->paginate($perPage);
    }

    /**
     * Get single application
     */
    public function getApplication(Application $application): Application
    {
        return $application->load('user:id,name,email', 'job');
    }

    /**
     * Create new application
     *
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
     */
    public function updateApplicationStatus(Application $application, array $validated): Application
    {
        $previousStatus = $application->status;
        $application->update($validated);

        $application->loadMissing('user:id,name,email', 'job:id,title,recruiter_id', 'job.recruiter:id,name');

        $newStatus = (string) $application->status;
        if (
            $application->user !== null
            && $newStatus !== $previousStatus
            && in_array($newStatus, ['accepted', 'rejected'], true)
        ) {
            $application->user->notify(new ApplicationStatusUpdatedNotification($application));
        }

        return $application->fresh()->load('job:id,title', 'job.recruiter:id,name');
    }
}
