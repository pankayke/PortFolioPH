<?php

namespace App\Http\Controllers;

use App\Models\Application;
use App\Models\Job;
use Illuminate\Http\Request;

class ApplicationWebController extends Controller
{
    public function index()
    {
        $user = auth()->user();

        if ($user->role === 'recruiter') {
            // Show applications for recruiter's jobs
            $applications = Application::whereHas('job', function ($query) use ($user) {
                $query->where('recruiter_id', $user->id);
            })
                ->with(['job', 'user'])
                ->when(request('status'), function ($query) {
                    $query->where('status', request('status'));
                })
                ->paginate(15);
        } else {
            // Show job seeker's applications
            $applications = Application::where('user_id', $user->id)
                ->with(['job', 'user'])
                ->when(request('status'), function ($query) {
                    $query->where('status', request('status'));
                })
                ->paginate(15);
        }

        return view('applications.index', compact('applications'));
    }

    public function show(Application $application)
    {
        $this->authorize('view', $application);

        return view('applications.show', compact('application'));
    }

    public function store(Request $request)
    {
        if (auth()->user()->role !== 'job_seeker') {
            return redirect()->back()
                ->with('error', 'Only job seekers can apply for jobs.');
        }

        $validated = $request->validate([
            'job_id' => 'required|exists:jobs,id',
            'cover_letter' => 'nullable|string|max:2000',
        ]);

        // Validate job is open for applications
        $job = Job::select('id', 'status')->findOrFail($validated['job_id']);
        if ($job->status !== 'approved') {
            return redirect()->back()
                ->with('error', 'This job is not open for applications.');
        }

        // Check if already applied
        $existing = Application::where('user_id', auth()->user()->id)
            ->where('job_id', $validated['job_id'])
            ->exists();

        if ($existing) {
            return redirect()->back()
                ->with('error', 'You have already applied for this job!');
        }

        $validated['user_id'] = auth()->user()->id;
        $application = Application::create($validated);

        $redirect = redirect()->route('jobs.show', $application->job_id)
            ->with('success', 'Application submitted successfully!');

        // Only expose debug data in debug mode
        if (config('app.debug')) {
            $redirect->with('application_debug', [
                'application_id' => $application->id,
                'job_id' => $application->job_id,
                'user_id' => $application->user_id,
                'status' => $application->status,
            ]);
        }

        return $redirect;
    }

    public function edit(Application $application)
    {
        $this->authorize('updateStatus', $application);

        return view('applications.edit', compact('application'));
    }

    public function updateStatus(Request $request, Application $application)
    {
        $this->authorize('updateStatus', $application);

        $validated = $request->validate([
            'status' => 'required|in:pending,reviewed,shortlisted,accepted,rejected',
        ]);

        $application->update($validated);

        return redirect()->route('applications.show', $application)
            ->with('success', 'Application status updated!');
    }

    public function bulkUpdateStatus(Request $request)
    {
        $request->validate([
            'application_ids' => 'required|array',
            'application_ids.*' => 'integer|exists:applications,id',
            'status' => 'required|in:pending,reviewed,shortlisted,accepted,rejected',
        ]);

        $status = $request->input('status');
        $applicationIds = $request->input('application_ids');

        $applications = Application::whereIn('id', $applicationIds)->get();
        $updatedCount = 0;

        foreach ($applications as $application) {
            if ($request->user()->can('updateStatus', $application)) {
                $application->update(['status' => $status]);
                $updatedCount++;
            }
        }

        return back()->with('success', "Successfully updated {$updatedCount} applications to {$status}.");
    }

    public function myApplications()
    {
        $applications = Application::where('user_id', auth()->user()->id)
            ->with(['job', 'user'])
            ->paginate(15);

        return view('applications.index', compact('applications'));
    }
}
