<?php

namespace App\Http\Controllers;

use App\Http\Resources\ApiResponse;
use App\Models\Application;
use App\Models\Job;
use Carbon\CarbonInterface;
use Carbon\CarbonPeriod;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RecruiterDashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        abort_unless($user && $user->role === 'recruiter', 403, 'Forbidden');

        $jobsQuery = Job::query()->where('recruiter_id', $user->id);
        $applicationsQuery = Application::query()->whereHas('job', function ($query) use ($user) {
            $query->where('recruiter_id', $user->id);
        });

        $totalJobs = (int) (clone $jobsQuery)->count();
        $activeJobs = (int) (clone $jobsQuery)->where('status', 'approved')->count();
        $jobsWithApplicationCount = (int) (clone $jobsQuery)->whereHas('applications')->count();
        $totalApplications = (int) (clone $applicationsQuery)->count();
        $newApplicationsCount = (int) (clone $applicationsQuery)
            ->where('created_at', '>=', now()->subDay())
            ->count();

        $atsCounts = (clone $applicationsQuery)
            ->selectRaw("SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending")
            ->selectRaw("SUM(CASE WHEN status = 'reviewed' THEN 1 ELSE 0 END) as reviewed")
            ->selectRaw("SUM(CASE WHEN status = 'shortlisted' THEN 1 ELSE 0 END) as shortlisted")
            ->selectRaw("SUM(CASE WHEN status = 'accepted' THEN 1 ELSE 0 END) as accepted")
            ->selectRaw("SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected")
            ->first();

        $applicationStatsByDay = $this->build7DayApplicationSeries($applicationsQuery);

        $recentApplications = (clone $applicationsQuery)
            ->with([
                'job:id,title,status,recruiter_id',
                'user:id,name,email',
            ])
            ->latest()
            ->limit(5)
            ->get();

        $recentJobs = (clone $jobsQuery)
            ->withCount('applications')
            ->latest()
            ->limit(5)
            ->get();

        $topJobs = (clone $jobsQuery)
            ->withCount('applications')
            ->orderByDesc('applications_count')
            ->latest('updated_at')
            ->limit(3)
            ->get();

        return ApiResponse::success([
            'total_jobs' => $totalJobs,
            'active_jobs' => $activeJobs,
            'total_applications' => $totalApplications,
            'new_applications_count' => $newApplicationsCount,
            'jobs_with_application_count' => $jobsWithApplicationCount,
            'ats_summary' => [
                'pending' => (int) ($atsCounts->pending ?? 0),
                'reviewed' => (int) ($atsCounts->reviewed ?? 0),
                'shortlisted' => (int) ($atsCounts->shortlisted ?? 0),
                'accepted' => (int) ($atsCounts->accepted ?? 0),
                'rejected' => (int) ($atsCounts->rejected ?? 0),
            ],
            'application_stats_by_day' => $applicationStatsByDay,
            'top_jobs' => $topJobs,
            'recent_jobs' => $recentJobs,
            'recent_applications' => $recentApplications,
        ], 'Recruiter dashboard loaded successfully');
    }

    private function build7DayApplicationSeries($applicationsQuery): array
    {
        $startDate = now()->subDays(6)->startOfDay();
        $endDate = now()->endOfDay();

        $countsByDate = (clone $applicationsQuery)
            ->whereBetween('created_at', [$startDate, $endDate])
            ->selectRaw('DATE(created_at) as day, COUNT(*) as total')
            ->groupBy('day')
            ->pluck('total', 'day')
            ->all();

        return collect(CarbonPeriod::create($startDate, '1 day', now()->startOfDay()))
            ->map(function (CarbonInterface $date) use ($countsByDate) {
                $dateKey = $date->format('Y-m-d');

                return [
                    'date' => $dateKey,
                    'label' => $date->format('D'),
                    'count' => (int) ($countsByDate[$dateKey] ?? 0),
                ];
            })
            ->values()
            ->all();
    }
}
