<?php

namespace App\Http\Controllers;

use App\Models\Application;
use App\Models\Job;

class DashboardController extends Controller
{
    public function index()
    {
        $user = request()->user();

        if ($user->role === 'admin') {
            return redirect()->route('admin.dashboard');
        }

        if ($user->role === 'recruiter') {
            $jobCounts = Job::query()
                ->where('recruiter_id', $user->id)
                ->selectRaw('COUNT(*) as total_jobs')
                ->selectRaw("SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as open_jobs")
                ->first();

            $applicationCounts = Application::query()
                ->whereHas('job', function ($query) use ($user) {
                    $query->where('recruiter_id', $user->id);
                })
                ->selectRaw('COUNT(*) as total_applications')
                ->selectRaw("SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_applications")
                ->first();

            $totalJobs = (int) ($jobCounts->total_jobs ?? 0);
            $openJobs = (int) ($jobCounts->open_jobs ?? 0);
            $totalApplications = (int) ($applicationCounts->total_applications ?? 0);
            $pendingApplications = (int) ($applicationCounts->pending_applications ?? 0);

            $recentApplications = Application::whereHas('job', function ($query) use ($user) {
                $query->where('recruiter_id', $user->id);
            })
                ->with([
                    'job:id,title',
                    'user:id,name,email',
                ])
                ->latest()
                ->take(5)
                ->get();

            return view('dashboard.index', compact(
                'totalJobs',
                'openJobs',
                'totalApplications',
                'pendingApplications',
                'recentApplications'
            ));
        } else {
            $seekerCounts = Application::query()
                ->where('user_id', $user->id)
                ->selectRaw('COUNT(*) as total_applications')
                ->selectRaw("SUM(CASE WHEN status = 'accepted' THEN 1 ELSE 0 END) as accepted_applications")
                ->selectRaw("SUM(CASE WHEN status IN ('pending', 'reviewed') THEN 1 ELSE 0 END) as under_review")
                ->selectRaw("SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected_applications")
                ->first();

            $totalApplications = (int) ($seekerCounts->total_applications ?? 0);
            $acceptedApplications = (int) ($seekerCounts->accepted_applications ?? 0);
            $underReview = (int) ($seekerCounts->under_review ?? 0);
            $rejectedApplications = (int) ($seekerCounts->rejected_applications ?? 0);

            $recentApplications = Application::where('user_id', $user->id)
                ->with(['job:id,title'])
                ->latest()
                ->take(5)
                ->get();

            return view('dashboard.index', compact(
                'totalApplications',
                'acceptedApplications',
                'underReview',
                'rejectedApplications',
                'recentApplications'
            ));
        }
    }
}
