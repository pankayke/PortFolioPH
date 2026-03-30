<?php

namespace App\Http\Controllers;

use App\Models\Application;
use App\Models\Job;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

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
        $validated = $request->validate([
            'job_id' => 'required|exists:jobs,id',
            'cover_letter' => 'nullable|string',
        ]);

        // Check if already applied
        $existing = Application::where('user_id', auth()->user()->id)
            ->where('job_id', $validated['job_id'])
            ->first();

        if ($existing) {
            return redirect()->back()
                ->with('error', 'You have already applied for this job!');
        }

        $validated['user_id'] = auth()->user()->id;

        Application::create($validated);

        return redirect()->route('my-applications')
            ->with('success', 'Application submitted successfully!');
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

    public function myApplications()
    {
        $applications = Application::where('user_id', auth()->user()->id)
            ->with(['job', 'user'])
            ->paginate(15);

        return view('applications.index', compact('applications'));
    }
}
