<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Job;
use App\Models\Application;
use Illuminate\Http\Request;

class AdminWebController extends Controller
{
    // Dashboard: Platform-wide analytics
    public function dashboard()
    {
        $stats = [
            'total_users' => User::count(),
            'admins' => User::where('role', 'admin')->count(),
            'recruiters' => User::where('role', 'recruiter')->count(),
            'job_seekers' => User::where('role', 'job_seeker')->count(),
            'total_jobs' => Job::count(),
            'active_jobs' => Job::where('status', 'open')->count(),
            'total_applications' => Application::count(),
            'pending_applications' => Application::where('status', 'pending')->count(),
        ];

        $recentUsers = User::latest()->limit(10)->get();
        $recentJobs = Job::with('recruiter')->latest()->limit(10)->get();
        $recentApplications = Application::with(['job', 'user'])->latest()->limit(10)->get();

        return view('admin.dashboard', compact('stats', 'recentUsers', 'recentJobs', 'recentApplications'));
    }

    // Users Management: List all users
    public function users(Request $request)
    {
        $users = User::query()
            ->when($request->filled('search'), function ($query) use ($request) {
                $search = trim((string) $request->input('search'));

                $query->where(function ($innerQuery) use ($search) {
                    $innerQuery->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%");
                });
            })
            ->when($request->filled('role'), function ($query) use ($request) {
                $query->where('role', $request->input('role'));
            })
            ->when($request->filled('status'), function ($query) use ($request) {
                $isActive = $request->input('status') === 'active';
                $query->where('active', $isActive);
            })
            ->withCount(['jobs', 'applications'])
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return view('admin.users.index', compact('users'));
    }

    // Users Management: Show user detail
    public function showUser(User $user)
    {
        $user->load(['jobs', 'applications']);
        $jobs = $user->jobs()->paginate(10);
        $applications = $user->applications()->paginate(10);
        return view('admin.users.show', compact('user', 'jobs', 'applications'));
    }

    // Users Management: Edit user
    public function editUser(User $user)
    {
        return view('admin.users.edit', compact('user'));
    }

    // Users Management: Update user (real-time reflection)
    public function updateUser(Request $request, User $user)
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'email' => 'required|email|unique:users,email,' . $user->id,
            'role' => 'required|in:admin,recruiter,job_seeker',
        ]);

        $oldRole = $user->role;
        $user->update($validated);

        // Real-time reflection: If changing recruiter to job_seeker, suspend their jobs
        if ($oldRole === 'recruiter' && $validated['role'] === 'job_seeker') {
            $user->jobs()->update(['status' => 'closed']);
        }

        // If demoting admin or recruiter, notify affected applications
        if (in_array($oldRole, ['admin', 'recruiter']) && $validated['role'] !== 'admin') {
            Application::whereHas('job', function ($q) use ($user) {
                $q->where('recruiter_id', $user->id);
            })->update(['status' => 'reviewed']); // Neutral status
        }

        return redirect()->route('admin.users.show', $user)->with('success', 'User updated successfully. Changes reflected immediately.');
    }

    // Users Management: Suspend user (disable their account)
    public function suspendUser(User $user)
    {
        $user->update(['active' => false]);

        // Real-time reflection: Close all their jobs
        if ($user->role === 'recruiter') {
            $user->jobs()->update(['status' => 'closed']);
        }

        return redirect()->route('admin.users.show', $user)->with('success', 'User suspended. All their jobs are now closed.');
    }

    // Users Management: Delete user (hard delete with cascades)
    public function deleteUser(User $user)
    {
        $userName = $user->name;
        
        // Cascade delete: Remove applications, then jobs, then user
        $user->applications()->delete();
        $user->jobs()->delete();
        $user->delete();

        return redirect()->route('admin.users')->with('success', "User '{$userName}' and all related data deleted.");
    }

    // Jobs Management: List all jobs
    public function jobs()
    {
        $jobs = Job::with('recruiter')->paginate(20);
        return view('admin.jobs.index', compact('jobs'));
    }

    // Jobs Management: Show job detail
    public function showJob(Job $job)
    {
        $job->load(['recruiter', 'applications']);
        $applications = $job->applications()->paginate(15);
        return view('admin.jobs.show', compact('job', 'applications'));
    }

    // Jobs Management: Suspend/close job (reflects on recruiter's view)
    public function suspendJob(Job $job)
    {
        $job->update(['status' => 'closed']);
        return redirect()->route('admin.jobs.show', $job)->with('success', 'Job closed. Recruiter can no longer accept applications.');
    }

    // Jobs Management: Delete job (with cascading)
    public function deleteJob(Job $job)
    {
        $jobTitle = $job->title;
        
        // Cascade delete: Remove applications first, then job
        $job->applications()->delete();
        $job->delete();

        return redirect()->route('admin.jobs')->with('success', "Job '{$jobTitle}' and all applications removed.");
    }

    // Jobs Management: Approve/activate job (reflects on recruiter's view)
    public function approveJob(Job $job)
    {
        $job->update(['status' => 'open']);
        return redirect()->route('admin.jobs.show', $job)->with('success', 'Job approved and now visible to job seekers.');
    }

    // Applications Analytics: View all applications
    public function applications()
    {
        $applications = Application::with(['job', 'user'])->paginate(20);
        $stats = [
            'pending' => Application::where('status', 'pending')->count(),
            'reviewed' => Application::where('status', 'reviewed')->count(),
            'shortlisted' => Application::where('status', 'shortlisted')->count(),
            'accepted' => Application::where('status', 'accepted')->count(),
            'rejected' => Application::where('status', 'rejected')->count(),
        ];
        return view('admin.applications.index', compact('applications', 'stats'));
    }

    // Audit Log: View admin actions (optional - can expand later)
    public function auditLog()
    {
        // This can be expanded with actual audit table
        // For now, shows activity via timestamps
        $recentActions = [
            'User edits' => User::latest()->limit(5)->get(),
            'Job changes' => Job::latest()->limit(5)->get(),
            'Application updates' => Application::latest()->limit(5)->get(),
        ];
        return view('admin.audit', compact('recentActions'));
    }
}
