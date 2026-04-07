<?php

namespace App\Services;

use App\Models\Job;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class JobService
{
    /**
     * Get all approved jobs with optional filters
     *
     * @param array $filters
     * @param int $perPage
     * @return LengthAwarePaginator
     */
    public function getApprovedJobs(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $query = Job::query()
            ->with('recruiter:id,name,email')
            ->where('status', 'approved');

        if (isset($filters['search'])) {
            $search = $filters['search'];
            $query->where('title', 'like', "%$search%")
                  ->orWhere('description', 'like', "%$search%");
        }

        if (isset($filters['location'])) {
            $query->where('location', $filters['location']);
        }

        return $query->paginate($perPage);
    }

    /**
     * Get single job by ID
     *
     * @param Job $job
     * @return Job
     */
    public function getJob(Job $job): Job
    {
        return $job->load('recruiter:id,name,email', 'applications');
    }

    /**
     * Create a new job
     *
     * @param User $recruiter
     * @param array $validated
     * @return Job
     */
    public function createJob(User $recruiter, array $validated): Job
    {
        $job = $recruiter->jobs()->create($validated);
        return $job->load('recruiter:id,name,email');
    }

    /**
     * Get jobs posted by a specific recruiter.
     *
     * @param User $recruiter
     * @param array $filters
     * @param int $perPage
     * @return LengthAwarePaginator
     */
    public function getRecruiterJobs(User $recruiter, array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $query = Job::query()
            ->where('recruiter_id', $recruiter->id)
            ->with('recruiter:id,name,email')
            ->latest();

        if (!empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (!empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%$search%")
                  ->orWhere('description', 'like', "%$search%");
            });
        }

        return $query->paginate($perPage);
    }

    /**
     * Update job
     *
     * @param Job $job
     * @param array $validated
     * @return Job
     */
    public function updateJob(Job $job, array $validated): Job
    {
        $job->update($validated);
        return $job->fresh();
    }

    /**
     * Delete job
     *
     * @param Job $job
     * @return bool
     */
    public function deleteJob(Job $job): bool
    {
        return $job->delete();
    }
}
