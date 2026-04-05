<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreJobRequest;
use App\Http\Requests\UpdateJobRequest;
use App\Http\Resources\ApiResponse;
use App\Models\Job;
use App\Services\JobService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class JobController extends Controller
{
    public function __construct(private JobService $jobService) {}

    /**
     * Get all approved jobs with optional filters
     */
    public function index(Request $request): JsonResponse
    {
        $filters = $request->only(['search', 'location']);
        $perPage = $request->input('per_page', 15);
        $jobs = $this->jobService->getApprovedJobs($filters, $perPage);

        return ApiResponse::paginated($jobs, 'Jobs retrieved successfully', 200);
    }

    /**
     * Create a new job (recruiter only)
     */
    public function store(StoreJobRequest $request): JsonResponse
    {
        $job = $this->jobService->createJob(auth()->user(), $request->validated());

        return ApiResponse::success(
            $job,
            'Job created successfully',
            201
        );
    }

    /**
     * Get single job details
     */
    public function show(Job $job): JsonResponse
    {
        $jobData = $this->jobService->getJob($job);

        return ApiResponse::success(
            $jobData,
            'Job retrieved successfully',
            200
        );
    }

    /**
     * Update job (recruiter who owns it)
     */
    public function update(UpdateJobRequest $request, Job $job): JsonResponse
    {
        $this->authorize('update', $job);

        $updated = $this->jobService->updateJob($job, $request->validated());

        return ApiResponse::success(
            $updated,
            'Job updated successfully',
            200
        );
    }

    /**
     * Delete job
     */
    public function destroy(Job $job): JsonResponse
    {
        $this->authorize('delete', $job);
        $this->jobService->deleteJob($job);

        return ApiResponse::success(
            null,
            'Job deleted successfully',
            200
        );
    }
}
