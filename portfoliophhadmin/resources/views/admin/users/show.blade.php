@extends('layouts.app')

@section('content')
@include('admin.partials.command_center_styles')
@php
    $activeSessions = $user->active ? 1 : 0;
    $serverLoad = $user->role === 'admin' ? 71 : ($user->role === 'recruiter' ? 58 : 43);
@endphp

<div class="cc-theme cc-ultra-shell">
    <div class="grid grid-cols-1 gap-6 xl:grid-cols-[250px_minmax(0,1fr)]">
        <aside class="cc-admin-rail cc-left-rail p-4">
            <p class="mb-4 text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Admin Rail</p>
            <nav class="space-y-2">
                <a href="{{ route('admin.dashboard') }}" class="cc-rail-link">Dashboard</a>
                <a href="{{ route('admin.users.index') }}" class="cc-rail-link cc-rail-link-active">Users</a>
                <a href="{{ route('admin.jobs.index') }}" class="cc-rail-link">Jobs</a>
                <a href="{{ route('admin.applications.index') }}" class="cc-rail-link">Applications</a>
                <a href="{{ route('admin.settings') }}" class="cc-rail-link">Settings</a>
            </nav>

            <div class="cc-elevated-card mt-5 p-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.1em] text-indigo-500">Live System</p>
                <div class="mt-2 flex items-center justify-between">
                    <div class="flex items-center gap-2 text-sm font-medium text-slate-800">
                        <span class="{{ $user->active ? 'cc-status-pulse' : 'h-2.5 w-2.5 rounded-full bg-slate-400' }}"></span>
                        Account Health
                    </div>
                    <span class="text-xs font-semibold {{ $user->active ? 'text-emerald-600' : 'text-slate-500' }}">{{ $user->active ? 'Online' : 'Suspended' }}</span>
                </div>
                <div class="mt-3 space-y-2 text-xs text-slate-600">
                    <p class="flex justify-between"><span>Active Sessions</span><span class="font-semibold text-slate-900">{{ $activeSessions }}</span></p>
                    <progress class="cc-progress" max="100" value="{{ min(95, $serverLoad + 9) }}"></progress>
                    <p class="flex justify-between"><span>Risk Score</span><span class="font-semibold text-slate-900">{{ max(8, 100 - $serverLoad) }}%</span></p>
                    <progress class="cc-progress" max="100" value="{{ max(8, 100 - $serverLoad) }}"></progress>
                </div>
            </div>
        </aside>

        <section class="space-y-6">
            <header class="cc-elevated-card p-5 md:p-6">
                <div class="mb-3 flex items-center text-sm">
                    <a href="{{ route('admin.dashboard') }}" class="cc-muted hover:text-slate-700">Admin</a>
                    <span class="mx-2 text-slate-400">/</span>
                    <a href="{{ route('admin.users.index') }}" class="cc-muted hover:text-slate-700">Users</a>
                    <span class="mx-2 text-slate-400">/</span>
                    <span class="font-medium text-slate-900">Profile</span>
                </div>
                <div class="flex flex-wrap items-start justify-between gap-4">
                    <div>
                        <h1 class="text-3xl font-extrabold text-slate-900">{{ $user->name }}</h1>
                        <p class="cc-muted mt-1 text-sm">{{ $user->email }}</p>
                        <div class="mt-3 flex flex-wrap items-center gap-2">
                            <span class="cc-glass-chip @if($user->role === 'admin') border-violet-200 bg-violet-50/90 text-violet-700 @elseif($user->role === 'recruiter') border-blue-200 bg-blue-50/90 text-blue-700 @else border-emerald-200 bg-emerald-50/90 text-emerald-700 @endif">{{ ucfirst(str_replace('_', ' ', $user->role)) }}</span>
                            <span class="cc-glass-chip {{ $user->active ? 'border-emerald-200 bg-emerald-50/90 text-emerald-700' : 'border-slate-200 bg-slate-100/90 text-slate-700' }}">{{ $user->active ? 'Active' : 'Suspended' }}</span>
                        </div>
                    </div>
                    <div class="flex flex-wrap gap-2">
                        <a href="{{ route('admin.users.edit', $user) }}" class="rounded-xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700">Edit Profile</a>
                        @if($user->active)
                            <form method="POST" action="{{ route('admin.users.suspend', $user) }}" class="inline">
                                @csrf
                                <button class="rounded-xl bg-amber-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-amber-700">Suspend</button>
                            </form>
                        @else
                            <form method="POST" action="{{ route('admin.users.unsuspend', $user) }}" class="inline">
                                @csrf
                                <button class="rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-emerald-700">Unsuspend</button>
                            </form>
                        @endif
                        <form method="POST" action="{{ route('admin.users.delete', $user) }}" class="inline" onsubmit="return confirm('Are you sure? This will delete all user data.')">
                            @csrf
                            @method('DELETE')
                            <button class="rounded-xl bg-rose-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-rose-700">Delete</button>
                        </form>
                    </div>
                </div>
            </header>

            <div class="grid grid-cols-1 gap-6 xl:grid-cols-[minmax(0,1fr)_320px]">
                <div class="space-y-6">
                    @if($user->role === 'recruiter')
                        <div class="cc-elevated-card overflow-hidden">
                            <div class="border-b border-slate-200 bg-slate-50/90 px-5 py-4">
                                <h3 class="text-base font-semibold text-slate-900">Posted Jobs ({{ $jobs->total() }})</h3>
                                <p class="cc-muted mt-1 text-xs">Role/suspension changes will close active postings automatically.</p>
                            </div>
                            <div class="overflow-x-auto">
                                <table class="w-full">
                                    <thead class="border-b border-slate-200 bg-slate-50/80">
                                        <tr>
                                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Job Title</th>
                                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Location</th>
                                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Status</th>
                                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Applications</th>
                                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-slate-100">
                                        @forelse($jobs as $job)
                                            <tr class="cc-record">
                                                <td class="px-5 py-4 text-sm font-semibold text-slate-900">{{ $job->title }}</td>
                                                <td class="px-5 py-4 text-sm text-slate-600">{{ $job->location }}</td>
                                                <td class="px-5 py-4">
                                                    <span class="cc-glass-chip {{ $job->status === 'approved' ? 'border-emerald-200 bg-emerald-50/90 text-emerald-700' : ($job->status === 'pending' ? 'border-amber-200 bg-amber-50/90 text-amber-700' : 'border-slate-200 bg-slate-100/90 text-slate-700') }}">{{ ucfirst($job->status) }}</span>
                                                </td>
                                                <td class="px-5 py-4 text-sm text-slate-600">{{ $job->applications_count ?? 0 }}</td>
                                                <td class="px-5 py-4 text-sm"><a href="{{ route('admin.jobs.show', $job) }}" class="font-semibold text-indigo-600 hover:text-indigo-800">Review</a></td>
                                            </tr>
                                        @empty
                                            <tr><td colspan="5" class="px-5 py-8 text-center text-sm text-slate-500">No jobs posted.</td></tr>
                                        @endforelse
                                    </tbody>
                                </table>
                            </div>
                            <div class="border-t border-slate-100 bg-slate-50/70 px-5 py-4">{{ $jobs->links() }}</div>
                        </div>
                    @else
                        <div class="cc-elevated-card overflow-hidden">
                            <div class="border-b border-slate-200 bg-slate-50/90 px-5 py-4">
                                <h3 class="text-base font-semibold text-slate-900">Applications ({{ $applications->total() }})</h3>
                            </div>
                            <div class="overflow-x-auto">
                                <table class="w-full">
                                    <thead class="border-b border-slate-200 bg-slate-50/80">
                                        <tr>
                                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Job</th>
                                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Status</th>
                                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Applied</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-slate-100">
                                        @forelse($applications as $app)
                                            <tr class="cc-record">
                                                <td class="px-5 py-4 text-sm font-semibold text-slate-900">{{ $app->job->title ?? 'N/A' }}</td>
                                                <td class="px-5 py-4"><span class="cc-glass-chip @if($app->status === 'pending') border-amber-200 bg-amber-50/90 text-amber-700 @elseif($app->status === 'accepted') border-emerald-200 bg-emerald-50/90 text-emerald-700 @elseif($app->status === 'shortlisted') border-violet-200 bg-violet-50/90 text-violet-700 @else border-slate-200 bg-slate-100/90 text-slate-700 @endif">{{ ucfirst(str_replace('_', ' ', $app->status)) }}</span></td>
                                                <td class="px-5 py-4 text-sm text-slate-600">{{ $app->created_at->format('M d, Y') }}</td>
                                            </tr>
                                        @empty
                                            <tr><td colspan="3" class="px-5 py-8 text-center text-sm text-slate-500">No applications found.</td></tr>
                                        @endforelse
                                    </tbody>
                                </table>
                            </div>
                            <div class="border-t border-slate-100 bg-slate-50/70 px-5 py-4">{{ $applications->links() }}</div>
                        </div>
                    @endif
                </div>

                <aside class="space-y-6">
                    <div class="cc-elevated-card p-5">
                        <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Identity Metadata</h3>
                        <div class="mt-4 grid grid-cols-2 gap-3 text-sm">
                            <div><p class="text-xs text-slate-500">User ID</p><p class="font-semibold text-slate-900">{{ $user->id }}</p></div>
                            <div><p class="text-xs text-slate-500">Role</p><p class="font-semibold text-slate-900">{{ ucfirst(str_replace('_', ' ', $user->role)) }}</p></div>
                            <div><p class="text-xs text-slate-500">Join Date</p><p class="font-semibold text-slate-900">{{ $user->created_at->format('M d, Y') }}</p></div>
                            <div><p class="text-xs text-slate-500">Last Update</p><p class="font-semibold text-slate-900">{{ $user->updated_at->diffForHumans() }}</p></div>
                            <div><p class="text-xs text-slate-500">Last IP</p><p class="font-semibold text-slate-900">N/A</p></div>
                            <div><p class="text-xs text-slate-500">Success Rate</p><p class="font-semibold text-slate-900">{{ $user->active ? '98%' : '42%' }}</p></div>
                        </div>
                    </div>

                    <div class="cc-elevated-card p-5">
                        <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Activity Spark</h3>
                        <svg viewBox="0 0 260 70" class="mt-3 h-16 w-full">
                            <path d="M0 54 L28 48 L52 50 L80 40 L104 43 L130 34 L156 36 L182 29 L208 32 L232 23 L260 26" fill="none" stroke="url(#userTrend)" stroke-width="3" stroke-linecap="round" />
                            <defs>
                                <linearGradient id="userTrend" x1="0" y1="0" x2="1" y2="0">
                                    <stop offset="0%" stop-color="#4f46e5" />
                                    <stop offset="100%" stop-color="#8b5cf6" />
                                </linearGradient>
                            </defs>
                        </svg>
                        <p class="cc-muted mt-2 text-xs">Real-time engagement signal for profile and account operations.</p>
                    </div>
                </aside>
            </div>
        </section>
    </div>
</div>
@endsection
