<?php

namespace App\Policies;

use App\Models\Application;
use App\Models\User;

class ApplicationPolicy
{
    /**
     * Determine if the user can update the application status.
     * Only the recruiter who posted the job can update application status.
     */
    public function updateStatus(User $user, Application $application): bool
    {
        return $user->id === $application->job->recruiter_id;
    }

    /**
     * Determine if the user can view the application.
     */
    public function view(User $user, Application $application): bool
    {
        // Applicant can view their own application
        if ($user->id === $application->user_id) {
            return true;
        }

        // Recruiter can view applications for their jobs
        return $user->id === $application->job->recruiter_id;
    }
}
