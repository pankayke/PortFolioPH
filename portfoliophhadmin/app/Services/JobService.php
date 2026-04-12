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

        if (!empty($filters['search'])) {
            $search = trim((string) $filters['search']);
            $query->where(function ($innerQuery) use ($search) {
                $innerQuery->where('title', 'like', "%$search%")
                    ->orWhere('description', 'like', "%$search%");
            });
        }

        if (!empty($filters['location'])) {
            $query->where('location', trim((string) $filters['location']));
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
        return $job->load('recruiter:id,name,email')
            ->loadCount('applications');
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
        $status = strtolower(trim((string) ($filters['status'] ?? '')));
        $search = trim((string) ($filters['search'] ?? ''));

        $query = Job::query()
            ->where('recruiter_id', $recruiter->id)
            ->with('recruiter:id,name,email')
            ->latest();

        if ($status !== '' && in_array($status, ['draft', 'pending', 'approved', 'closed'], true)) {
            $query->where('status', $status);
        }

        if ($search !== '') {
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
