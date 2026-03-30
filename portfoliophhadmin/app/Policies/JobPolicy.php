<?php

namespace App\Policies;

use App\Models\Job;
use App\Models\User;

class JobPolicy
{
    /**
     * Determine if the user can create a job.
     */
    public function create(User $user): bool
    {
        return $user->role === 'recruiter';
    }

    /**
     * Determine if the user can update the job.
     */
    public function update(User $user, Job $job): bool
    {
        return $user->id === $job->recruiter_id && $user->role === 'recruiter';
    }

    /**
     * Determine if the user can delete the job.
     */
    public function delete(User $user, Job $job): bool
    {
        return $user->id === $job->recruiter_id && $user->role === 'recruiter';
    }
}
