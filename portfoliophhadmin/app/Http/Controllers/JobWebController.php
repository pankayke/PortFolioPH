<?php

namespace App\Http\Controllers;

use App\Models\Job;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class JobWebController extends Controller
{
    public function index()
    {
        $user = request()->user();

        if ($user->role === 'recruiter') {
            // Show recruiter's jobs
            $jobs = Job::where('recruiter_id', $user->id)
                ->paginate(12);
        } else {
            // Show all jobs for job seekers
            $jobs = Job::where('status', 'approved')
                ->with('recruiter:id,name,email')
                ->paginate(12);
        }

        return view('jobs.index', compact('jobs'));
    }

    public function show(Job $job)
    {
        $job->load('recruiter:id,name,email');

        $applications = $job->applications()
            ->with('user:id,name,email')
            ->latest()
            ->paginate(10);

        $applicationCount = (int) $applications->total();

        return view('jobs.show', compact('job', 'applications', 'applicationCount'));
    }

    public function create()
    {
        Gate::authorize('create', Job::class);

        return view('jobs.form');
    }

    public function store(Request $request)
    {
        Gate::authorize('create', Job::class);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'location' => 'required|string|max:255',
            'job_type' => 'required|in:full_time,part_time,contract,freelance',
            'salary_min' => 'nullable|numeric|min:0',
            'salary_max' => 'nullable|numeric|min:0',
            'deadline' => 'nullable|date|after:now',
            'required_skills' => 'nullable|string',
        ]);

        $validated['recruiter_id'] = request()->user()->id;
        $validated['required_skills'] = $validated['required_skills']
            ? array_map('trim', explode(',', $validated['required_skills']))
            : null;

        Job::create($validated);

        return redirect()->route('jobs.index')
            ->with('success', 'Job posted successfully!');
    }

    public function edit(Job $job)
    {
        Gate::authorize('update', $job);

        return view('jobs.form', compact('job'));
    }

    public function update(Request $request, Job $job)
    {
        Gate::authorize('update', $job);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'location' => 'required|string|max:255',
            'job_type' => 'required|in:full_time,part_time,contract,freelance',
            'salary_min' => 'nullable|numeric|min:0',
            'salary_max' => 'nullable|numeric|min:0',
            'deadline' => 'nullable|date|after:now',
            'required_skills' => 'nullable|string',
            'status' => 'required|in:approved,closed',
        ]);

        $validated['required_skills'] = $validated['required_skills']
            ? array_map('trim', explode(',', $validated['required_skills']))
            : null;

        $job->update($validated);

        return redirect()->route('jobs.show', $job)
            ->with('success', 'Job updated successfully!');
    }

    public function destroy(Job $job)
    {
        Gate::authorize('delete', $job);
        $job->delete();

        return redirect()->route('jobs.index')
            ->with('success', 'Job deleted successfully!');
    }

    public function updateStatus(Request $request, Job $job)
    {
        Gate::authorize('update', $job);

        $validated = $request->validate([
            'status' => 'required|in:approved,closed',
        ]);

        $job->update($validated);

        return redirect()->route('jobs.show', $job)
            ->with('success', 'Job status updated!');
    }

    public function list()
    {
        // For job seekers to browse all jobs
        $jobs = Job::where('status', 'approved')
            ->with('recruiter:id,name,email')
            ->paginate(12);

        return view('jobs.index', compact('jobs'));
    }
}
