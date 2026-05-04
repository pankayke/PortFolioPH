<?php

namespace App\Services;

use App\Models\Job;
use App\Models\User;
use App\Notifications\JobPendingApprovalNotification;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class JobService
{
    /**
     * Get all approved jobs with optional filters
     */
    public function getApprovedJobs(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $query = Job::query()
            ->select([
                'id',
                'recruiter_id',
                'title',
                'description',
                'location',
                'salary_min',
                'salary_max',
                'job_type',
                'status',
                'required_skills',
                'deadline',
                'created_at',
                'updated_at',
            ])
            ->with('recruiter:id,name,email')
            ->withCount('applications')
            ->where('status', 'approved');

        if (! empty($filters['search'])) {
            $search = trim((string) $filters['search']);
            $query->where(function ($innerQuery) use ($search) {
                $innerQuery->where('title', 'like', "%$search%")
                    ->orWhere('description', 'like', "%$search%");
            });
        }

        if (! empty($filters['location'])) {
            $query->where('location', trim((string) $filters['location']));
        }

        return $query->paginate($perPage);
    }

    /**
     * Get single job by ID
     */
    public function getJob(Job $job): Job
    {
        return $job->load('recruiter:id,name,email')
            ->loadCount('applications');
    }

    /**
     * Create a new job
     */
    public function createJob(User $recruiter, array $validated): Job
    {
        return DB::transaction(function () use ($recruiter, $validated) {
            $job = $recruiter->jobs()->create([
                ...$validated,
                'status' => $validated['status'] ?? 'approved',
            ]);

            // Notify admins if the job is sent for review.
            if ($job->status === 'pending') {
                $admins = User::where('role', 'admin')->get();
                foreach ($admins as $admin) {
                    $admin->notify(new JobPendingApprovalNotification($job));
                }
            }

            return $job->load('recruiter:id,name,email');
        });
    }

    /**
     * Get jobs posted by a specific recruiter.
     */
    public function getRecruiterJobs(User $recruiter, array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $status = strtolower(trim((string) ($filters['status'] ?? '')));
        $search = trim((string) ($filters['search'] ?? ''));

        $query = Job::query()
            ->select([
                'id',
                'recruiter_id',
                'title',
                'description',
                'location',
                'salary_min',
                'salary_max',
                'job_type',
                'status',
                'required_skills',
                'deadline',
                'created_at',
                'updated_at',
            ])
            ->where('recruiter_id', $recruiter->id)
            ->with('recruiter:id,name,email')
            ->withCount('applications')
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
     */
    public function updateJob(Job $job, array $validated): Job
    {
        $job->update($validated);

        return $job->fresh();
    }

    /**
     * Delete job
     */
    public function deleteJob(Job $job): bool
    {
        return $job->delete();
    }
}
