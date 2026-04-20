<?php

namespace App\Http\Controllers;

use App\Http\Requests\CreateApplicationRequest;
use App\Http\Requests\UpdateApplicationStatusRequest;
use App\Http\Resources\ApiResponse;
use App\Models\Application;
use App\Services\ApplicationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ApplicationController extends Controller
{
    public function __construct(private ApplicationService $applicationService) {}

    /**
     * Get applications (current user as job seeker, or for recruiter's jobs if recruiter)
     */
    public function index(Request $request): JsonResponse
    {
        $perPage = $this->resolvePerPage($request);
        $applications = $this->applicationService->getApplications($request->user(), $perPage);

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
        $user = $request->user();
        if ($user?->role !== 'job_seeker') {
            return ApiResponse::error('Only job seekers can apply for jobs.', 403);
        }

        try {
            $application = $this->applicationService->createApplication(
                $user,
                $request->validated()
            );

            $response = ApiResponse::success(
                $application,
                'Application submitted successfully',
                201
            );

            if (config('app.debug')) {
                $response->headers->set(
                    'X-Application-Debug',
                    sprintf(
                        'saved=1;application_id=%d;job_id=%d;user_id=%d;status=%s',
                        $application->id,
                        $application->job_id,
                        $application->user_id,
                        $application->status
                    )
                );
            }

            return $response;
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

    private function resolvePerPage(Request $request): int
    {
        $perPage = (int) $request->input('per_page', 15);

        return max(1, min(100, $perPage));
    }
}
