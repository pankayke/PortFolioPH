<?php

namespace App\Http\Controllers;

use App\Models\Job;
use Illuminate\Http\Request;

class JobController extends Controller
{
    public function index(Request $request)
    {
        $query = Job::query();

        if ($request->has('search')) {
            $search = $request->input('search');
            $query->where('title', 'like', "%$search%")
                  ->orWhere('description', 'like', "%$search%");
        }

        if ($request->has('location')) {
            $query->where('location', $request->input('location'));
        }

        return response()->json(
            $query->with('recruiter:id,name,email')
                  ->paginate(15)
        );
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'location' => 'required|string|max:255',
            'salary_min' => 'nullable|numeric',
            'salary_max' => 'nullable|numeric',
            'job_type' => 'required|in:full_time,part_time,contract,freelance',
            'required_skills' => 'nullable|array',
            'required_skills.*' => 'string',
            'deadline' => 'nullable|date|after:now',
        ]);

        $job = $request->user()->jobs()->create($validated);

        return response()->json($job, 201);
    }

    public function show(Job $job)
    {
        return response()->json(
            $job->load('recruiter:id,name,email', 'applications')
        );
    }

    public function update(Request $request, Job $job)
    {
        $this->authorize('update', $job);

        $validated = $request->validate([
            'title' => 'string|max:255',
            'description' => 'string',
            'location' => 'string|max:255',
            'salary_min' => 'nullable|numeric',
            'salary_max' => 'nullable|numeric',
            'job_type' => 'in:full_time,part_time,contract,freelance',
            'required_skills' => 'nullable|array',
            'required_skills.*' => 'string',
            'status' => 'in:open,closed',
            'deadline' => 'nullable|date|after:now',
        ]);

        $job->update($validated);

        return response()->json($job);
    }

    public function destroy(Request $request, Job $job)
    {
        $this->authorize('delete', $job);

        $job->delete();

        return response()->json(['message' => 'Job deleted']);
    }
}
