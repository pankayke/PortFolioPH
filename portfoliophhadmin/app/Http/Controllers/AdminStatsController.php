<?php

namespace App\Http\Controllers;

use App\Http\Resources\ApiResponse;
use App\Models\Application;
use App\Models\Job;
use App\Models\User;
use Illuminate\Http\Request;

class AdminStatsController extends Controller
{
    public function index(Request $request)
    {
        abort_unless($request->user()?->role === 'admin', 403, 'Forbidden');

        $users = User::query()
            ->selectRaw('COUNT(*) as total')
            ->selectRaw("SUM(CASE WHEN role = 'admin' THEN 1 ELSE 0 END) as admins")
            ->selectRaw("SUM(CASE WHEN role = 'recruiter' THEN 1 ELSE 0 END) as recruiters")
            ->selectRaw("SUM(CASE WHEN role = 'job_seeker' THEN 1 ELSE 0 END) as job_seekers")
            ->first();

        $jobs = Job::query()
            ->selectRaw('COUNT(*) as total')
            ->selectRaw("SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved")
            ->selectRaw("SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending")
            ->selectRaw("SUM(CASE WHEN status = 'draft' THEN 1 ELSE 0 END) as draft")
            ->selectRaw("SUM(CASE WHEN status = 'closed' THEN 1 ELSE 0 END) as closed")
            ->first();

        $applications = Application::query()
            ->selectRaw('COUNT(*) as total')
            ->selectRaw("SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending")
            ->selectRaw("SUM(CASE WHEN status = 'reviewed' THEN 1 ELSE 0 END) as reviewed")
            ->selectRaw("SUM(CASE WHEN status = 'shortlisted' THEN 1 ELSE 0 END) as shortlisted")
            ->selectRaw("SUM(CASE WHEN status = 'accepted' THEN 1 ELSE 0 END) as accepted")
            ->selectRaw("SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected")
            ->first();

        return ApiResponse::success([
            'users' => [
                'total' => (int) ($users->total ?? 0),
                'admins' => (int) ($users->admins ?? 0),
                'recruiters' => (int) ($users->recruiters ?? 0),
                'job_seekers' => (int) ($users->job_seekers ?? 0),
            ],
            'jobs' => [
                'total' => (int) ($jobs->total ?? 0),
                'approved' => (int) ($jobs->approved ?? 0),
                'pending' => (int) ($jobs->pending ?? 0),
                'draft' => (int) ($jobs->draft ?? 0),
                'closed' => (int) ($jobs->closed ?? 0),
            ],
            'applications' => [
                'total' => (int) ($applications->total ?? 0),
                'pending' => (int) ($applications->pending ?? 0),
                'reviewed' => (int) ($applications->reviewed ?? 0),
                'shortlisted' => (int) ($applications->shortlisted ?? 0),
                'accepted' => (int) ($applications->accepted ?? 0),
                'rejected' => (int) ($applications->rejected ?? 0),
            ],
        ], 'Admin stats retrieved successfully');
    }
}
