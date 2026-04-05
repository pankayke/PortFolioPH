<?php

namespace App\Http\Controllers;

use App\Http\Requests\CreateApplicationRequest;
use App\Http\Requests\UpdateApplicationStatusRequest;
use App\Http\Resources\ApiResponse;
use App\Models\Application;
use App\Services\ApplicationService;
use Illuminate\Http\JsonResponse;

class ApplicationController extends Controller
{
    public function __construct(private ApplicationService $applicationService) {}

    /**
     * Get applications (current user as job seeker, or for recruiter's jobs if recruiter)
     */
    public function index(): JsonResponse
    {
        $applications = $this->applicationService->getApplications(auth()->user());

        return ApiResponse::paginated($applications, 'Applications retrieved successfully', 200);
    }

    /**
     * Get single application
     */
    public function show(Application $application): JsonResponse
    {
        $this->authorize('view', $application);

        $appData = $this->applicationService->getApplication($application);

        return ApiResponse::success(
            $appData,
            'Application retrieved successfully',
            200
        );
    }

    /**
     * Create new application
     */
    public function store(CreateApplicationRequest $request): JsonResponse
    {
        try {
            $application = $this->applicationService->createApplication(
                auth()->user(),
                $request->validated()
            );

            return ApiResponse::success(
                $application,
                'Application submitted successfully',
                201
            );
        } catch (\Exception $e) {
            if ($e->getCode() === 409) {
                return ApiResponse::error($e->getMessage(), 409);
            }
            throw $e;
        }
    }

    /**
     * Update application status (recruiter only)
     */
    public function updateStatus(
        UpdateApplicationStatusRequest $request,
        Application $application
    ): JsonResponse {
        $this->authorize('updateStatus', $application);

        $updated = $this->applicationService->updateApplicationStatus(
            $application,
            $request->validated()
        );

        return ApiResponse::success(
            $updated,
            'Application status updated successfully',
            200
        );
    }
}
