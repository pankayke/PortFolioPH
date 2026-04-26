<?php

namespace App\Services;

use App\Models\Application;
use App\Models\Job;
use App\Models\User;
use App\Notifications\ApplicationStatusUpdatedNotification;
use App\Notifications\RecruiterNewApplicationNotification;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class ApplicationService
{
    /**
     * Get applications for user (job seeker sees own, recruiter sees for their jobs)
     */
    public function getApplications(User $user, int $perPage = 15): LengthAwarePaginator
    {
        if ($user->role === 'job_seeker') {
            return $user->applications()
                ->with('job:id,title,recruiter_id,status', 'job.recruiter:id,name,email')
                ->latest()
                ->paginate($perPage);
        }

        // Recruiter sees applications for their jobs
        return Application::whereHas('job', function ($query) use ($user) {
            $query->where('recruiter_id', $user->id);
        })
            ->with('user:id,name,email', 'job:id,title,recruiter_id,status')
            ->latest()
            ->paginate($perPage);
    }

    /**
     * Get single application
     */
    public function getApplication(Application $application): Application
    {
        return $application->load(
            'user:id,name,email',
            'job:id,title,recruiter_id,status',
            'job.recruiter:id,name,email'
        );
    }

    /**
     * Create new application
     *
     * @throws \Exception
     */
    public function createApplication(User $user, array $validated): Application
    {
        return DB::transaction(function () use ($user, $validated) {
            $job = Job::query()
                ->select('id')
                ->findOrFail($validated['job_id']);

            // Check if already applied
            $existing = Application::query()
                ->where('user_id', $user->id)
                ->where('job_id', $job->id)
                ->exists();

            if ($existing) {
                throw new \Exception('You have already applied for this job', 409);
            }

            $application = $user->applications()->create($validated);

            // Notify the recruiter
            if ($application->job->recruiter) {
                $application->job->recruiter->notify(new RecruiterNewApplicationNotification($application));
            }

            // Refresh to ensure all fields including defaults are loaded
            return $application->fresh()->load('job:id,title');
        });
    }

    /**
     * Update application status
     */
    public function updateApplicationStatus(Application $application, array $validated): Application
    {
        return DB::transaction(function () use ($application, $validated) {
            $previousStatus = $application->status;
            $application->update($validated);

            $application->loadMissing('user:id,name,email', 'job:id,title,recruiter_id', 'job.recruiter:id,name');

            $newStatus = (string) $application->status;
            if (
                $application->user !== null
                && $newStatus !== $previousStatus
                && in_array($newStatus, ['shortlisted', 'accepted', 'rejected'], true)
            ) {
                $application->user->notify(new ApplicationStatusUpdatedNotification($application));
            }

            return $application->load('job:id,title,recruiter_id', 'job.recruiter:id,name');
        });
    }
}
