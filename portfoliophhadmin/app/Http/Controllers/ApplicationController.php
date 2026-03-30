<?php

namespace App\Http\Controllers;

use App\Models\Application;
use App\Models\Job;
use Illuminate\Http\Request;

class ApplicationController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'job_seeker') {
            $applications = $user->applications()->with('job:id,title')->paginate(15);
        } else {
            // Recruiter sees applications for their jobs
            $applications = Application::whereHas('job', function ($query) use ($user) {
                $query->where('recruiter_id', $user->id);
            })->with('user:id,name,email', 'job:id,title')->paginate(15);
        }

        return response()->json($applications);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'job_id' => 'required|exists:jobs,id',
            'cover_letter' => 'nullable|string|max:5000',
        ]);

        // Check if already applied
        $existing = Application::where('job_id', $validated['job_id'])
            ->where('user_id', $request->user()->id)
            ->first();

        if ($existing) {
            return response()->json(['message' => 'Already applied to this job'], 409);
        }

        $application = $request->user()->applications()->create($validated);

        return response()->json($application->load('job:id,title'), 201);
    }

    public function show(Application $application)
    {
        $this->authorize('view', $application);

        return response()->json(
            $application->load('user:id,name,email', 'job')
        );
    }

    public function updateStatus(Request $request, Application $application)
    {
        $this->authorize('update', $application);

        $validated = $request->validate([
            'status' => 'required|in:pending,reviewed,shortlisted,rejected,accepted',
        ]);

        $application->update($validated);

        return response()->json($application);
    }
}
