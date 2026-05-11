<?php

namespace App\Http\Controllers;

use App\Http\Resources\ApiResponse;
use App\Models\SavedJob;
use Illuminate\Http\Request;

class SavedJobController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'job_seeker') {
            return ApiResponse::error('Only job seekers can view saved jobs.', 403);
        }

        $savedJobs = SavedJob::with('job.recruiter')
            ->where('user_id', $user->id)
            ->latest()
            ->paginate(15);

        return ApiResponse::paginated($savedJobs, 'Saved jobs retrieved successfully', 200);
    }

    public function store(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'job_seeker') {
            return ApiResponse::error('Only job seekers can save jobs.', 403);
        }

        $request->validate([
            'job_id' => 'required|exists:jobs,id',
        ]);

        $jobId = $request->input('job_id');

        $exists = SavedJob::where('user_id', $user->id)->where('job_id', $jobId)->exists();
        if ($exists) {
            return ApiResponse::error('Job already saved.', 409);
        }

        $savedJob = SavedJob::create([
            'user_id' => $user->id,
            'job_id' => $jobId,
        ]);

        return ApiResponse::success($savedJob, 'Job saved successfully', 201);
    }

    public function destroy(Request $request, $id)
    {
        $user = $request->user();

        if ($user->role !== 'job_seeker') {
            return ApiResponse::error('Only job seekers can unsave jobs.', 403);
        }

        $savedJob = SavedJob::where('user_id', $user->id)->where('job_id', $id)->first();

        if (! $savedJob) {
            return ApiResponse::error('Saved job not found.', 404);
        }

        $savedJob->delete();

        return ApiResponse::success(null, 'Job unsaved successfully', 200);
    }
}
