<?php

namespace App\Http\Controllers;

use App\Models\Application;
use App\Models\Job;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        $user = auth()->user();

        if ($user->role === 'admin') {
            return redirect()->route('admin.dashboard');
        }

        if ($user->role === 'recruiter') {
            $totalJobs = Job::where('recruiter_id', $user->id)->count();
            $openJobs = Job::where('recruiter_id', $user->id)->where('status', 'approved')->count();
            $totalApplications = Application::whereHas('job', function ($query) use ($user) {
                $query->where('recruiter_id', $user->id);
            })->count();
            $pendingApplications = Application::whereHas('job', function ($query) use ($user) {
                $query->where('recruiter_id', $user->id);
            })->where('status', 'pending')->count();

            $recentApplications = Application::whereHas('job', function ($query) use ($user) {
                $query->where('recruiter_id', $user->id);
            })
                ->with(['job', 'user'])
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
            $totalApplications = Application::where('user_id', $user->id)->count();
            $acceptedApplications = Application::where('user_id', $user->id)->where('status', 'accepted')->count();
            $underReview = Application::where('user_id', $user->id)
                ->whereIn('status', ['pending', 'reviewed'])
                ->count();
            $rejectedApplications = Application::where('user_id', $user->id)->where('status', 'rejected')->count();

            $recentApplications = Application::where('user_id', $user->id)
                ->with(['job', 'user'])
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
