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
            'active_jobs' => Job::where('status', 'approved')->count(),
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
        $search = trim((string) $request->input('search', ''));
        $role = strtolower(trim((string) $request->input('role', 'all')));
        $status = strtolower(trim((string) $request->input('status', 'all')));
        $sortBy = strtolower(trim((string) $request->input('sort_by', 'created_at')));
        $sortDir = strtolower(trim((string) $request->input('sort_dir', 'desc')));

        if (in_array($role, ['job seeker', 'job-seeker'], true)) {
            $role = 'job_seeker';
        }

        $allowedSorts = ['created_at', 'name', 'email', 'role', 'active'];
        if (!in_array($sortBy, $allowedSorts, true)) {
            $sortBy = 'created_at';
        }

        if (!in_array($sortDir, ['asc', 'desc'], true)) {
            $sortDir = 'desc';
        }

        $users = User::query()
            ->when($search !== '', function ($query) use ($search) {
                $terms = preg_split('/\s+/', $search, -1, PREG_SPLIT_NO_EMPTY) ?: [];

                foreach ($terms as $term) {
                    $query->where(function ($innerQuery) use ($term) {
                        $innerQuery->where('name', 'like', "%{$term}%")
                            ->orWhere('email', 'like', "%{$term}%")
                            ->orWhere('username', 'like', "%{$term}%");
                    });
                }
            })
            ->when($role !== '' && $role !== 'all', function ($query) use ($role) {
                if ($role === 'job_seeker') {
                    $query->whereIn('role', ['job_seeker', 'job seeker', 'job-seeker']);
                    return;
                }

                $query->where('role', $role);
            })
            ->when($status !== '' && $status !== 'all', function ($query) use ($status) {
                if ($status === 'active') {
                    $query->where('active', 1);
                    return;
                }

                if ($status === 'suspended') {
                    $query->where(function ($statusQuery) {
                        $statusQuery->where('active', 0)->orWhereNull('active');
                    });
                }
            })
            ->withCount(['jobs', 'applications'])
            ->when($sortBy === 'active', function ($query) use ($sortDir) {
                $query->orderByRaw("COALESCE(active, 0) {$sortDir}")
                    ->orderBy('created_at', 'desc');
            }, function ($query) use ($sortBy, $sortDir) {
                $query->orderBy($sortBy, $sortDir);
            })
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

    // Users Management: Unsuspend user (reactivate account)
    public function unsuspendUser(User $user)
    {
        $user->update(['active' => true]);

        return redirect()->route('admin.users.show', $user)->with('success', 'User unsuspended and account reactivated successfully.');
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
        $job->update(['status' => 'approved']);
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

    // Settings: Command center configuration panel
    public function settings(Request $request)
    {
        $stats = [
            'total_users' => User::count(),
        ];

        $settings = [
            'maintenance_mode' => (bool) $request->session()->get('admin_settings.maintenance_mode', false),
            'new_user_alerts' => (bool) $request->session()->get('admin_settings.new_user_alerts', true),
            'moderation_alerts' => (bool) $request->session()->get('admin_settings.moderation_alerts', true),
            'digest_frequency' => (string) $request->session()->get('admin_settings.digest_frequency', 'daily'),
            'dashboard_density' => (string) $request->session()->get('admin_settings.dashboard_density', 'high'),
            'session_timeout' => (int) $request->session()->get('admin_settings.session_timeout', 30),
        ];

        $metrics = [
            'active_sessions' => max(3, Application::where('status', 'pending')->count()),
            'server_load' => min(90, max(18, Job::where('status', 'approved')->count() * 8)),
            'queue_backlog' => Application::where('status', 'pending')->count(),
            'open_incidents' => Job::where('status', 'pending')->count(),
        ];

        return view('admin.settings', compact('settings', 'metrics', 'stats'));
    }

    // Settings: Store command center preferences
    public function updateSettings(Request $request)
    {
        $validated = $request->validate([
            'maintenance_mode' => 'nullable|boolean',
            'new_user_alerts' => 'nullable|boolean',
            'moderation_alerts' => 'nullable|boolean',
            'digest_frequency' => 'required|in:realtime,hourly,daily,weekly',
            'dashboard_density' => 'required|in:compact,high,spacious',
            'session_timeout' => 'required|integer|min:5|max:240',
        ]);

        $request->session()->put('admin_settings', [
            'maintenance_mode' => (bool) ($validated['maintenance_mode'] ?? false),
            'new_user_alerts' => (bool) ($validated['new_user_alerts'] ?? false),
            'moderation_alerts' => (bool) ($validated['moderation_alerts'] ?? false),
            'digest_frequency' => $validated['digest_frequency'],
            'dashboard_density' => $validated['dashboard_density'],
            'session_timeout' => (int) $validated['session_timeout'],
        ]);

        return redirect()->route('admin.settings')->with('success', 'Admin command center settings updated.');
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
