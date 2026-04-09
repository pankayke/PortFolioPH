@extends('layouts.app')

@section('content')
@include('admin.partials.command_center_styles')
@php
    $isApproved = $job->status === 'approved';
    $activeSessions = max(1, (int) round($applications->total() * 0.22));
    $serverLoad = min(88, max(24, (int) round($applications->total() * 7.5)));
@endphp

<div class="cc-theme cc-ultra-shell">
    <div class="grid grid-cols-1 gap-6 xl:grid-cols-[250px_minmax(0,1fr)]">
        <aside class="cc-admin-rail cc-left-rail p-4">
            <p class="mb-4 text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Admin Rail</p>
            <nav class="space-y-2">
                <a href="{{ route('admin.dashboard') }}" class="cc-rail-link">Dashboard</a>
                <a href="{{ route('admin.users.index') }}" class="cc-rail-link">Users</a>
                <a href="{{ route('admin.jobs.index') }}" class="cc-rail-link cc-rail-link-active">Jobs</a>
                <a href="{{ route('admin.applications.index') }}" class="cc-rail-link">Applications</a>
                <a href="{{ route('admin.settings') }}" class="cc-rail-link">Settings</a>
            </nav>

            <div class="cc-elevated-card mt-5 p-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.1em] text-indigo-500">Live System</p>
                <div class="mt-2 flex items-center justify-between">
                    <div class="flex items-center gap-2 text-sm font-medium text-slate-800">
                        <span class="{{ $isApproved ? 'cc-status-pulse' : 'h-2.5 w-2.5 rounded-full bg-amber-500 shadow-[0_0_0_5px_rgba(245,158,11,0.16)]' }}"></span>
                        Job Health
                    </div>
                    <span class="text-xs font-semibold {{ $isApproved ? 'text-emerald-600' : 'text-amber-600' }}">{{ ucfirst($job->status) }}</span>
                </div>
                <div class="mt-3 space-y-2 text-xs text-slate-600">
                    <p class="flex justify-between"><span>Active Sessions</span><span class="font-semibold text-slate-900">{{ $activeSessions }}</span></p>
                    <progress class="cc-progress" max="100" value="{{ min(95, $serverLoad + 8) }}"></progress>
                    <p class="flex justify-between"><span>Server Load</span><span class="font-semibold text-slate-900">{{ $serverLoad }}%</span></p>
                    <progress class="cc-progress" max="100" value="{{ $serverLoad }}"></progress>
                </div>
            </div>
        </aside>

        <section class="space-y-6">
            <header class="cc-elevated-card p-5 md:p-6">
                <div class="mb-3 flex items-center text-sm">
                    <a href="{{ route('admin.dashboard') }}" class="cc-muted hover:text-slate-700">Admin</a>
                    <span class="mx-2 text-slate-400">/</span>
                    <a href="{{ route('admin.jobs.index') }}" class="cc-muted hover:text-slate-700">Jobs</a>
                    <span class="mx-2 text-slate-400">/</span>
                    <span class="font-medium text-slate-900">Review</span>
                </div>
                <div class="flex flex-wrap items-start justify-between gap-4">
                    <div>
                        <h1 class="text-3xl font-extrabold text-slate-900">{{ $job->title }}</h1>
                        <p class="cc-muted mt-1 text-sm">Posted by {{ $job->recruiter->name }}</p>
                        <div class="mt-3"><span class="cc-glass-chip {{ $isApproved ? 'border-emerald-200 bg-emerald-50/90 text-emerald-700' : ($job->status === 'pending' ? 'border-amber-200 bg-amber-50/90 text-amber-700' : 'border-slate-200 bg-slate-100/90 text-slate-700') }}">{{ ucfirst($job->status) }}</span></div>
                    </div>
                    <div class="flex flex-wrap gap-2">
                        @if($isApproved)
                            <form method="POST" action="{{ route('admin.jobs.suspend', $job) }}" class="inline">
                                @csrf
                                <button class="rounded-xl bg-amber-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-amber-700">Close Job</button>
                            </form>
                        @else
                            <form method="POST" action="{{ route('admin.jobs.approve', $job) }}" class="inline">
                                @csrf
                                <button class="rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-emerald-700">Approve Job</button>
                            </form>
                        @endif
                        <form method="POST" action="{{ route('admin.jobs.delete', $job) }}" class="inline" onsubmit="return confirm('This will delete the job and all applications.')">
                            @csrf
                            @method('DELETE')
                            <button class="rounded-xl bg-rose-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-rose-700">Delete</button>
                        </form>
                    </div>
                </div>
            </header>

            <div class="grid grid-cols-1 gap-6 xl:grid-cols-[minmax(0,1fr)_320px]">
                <div class="space-y-6">
                    <div class="cc-elevated-card p-5 md:p-6">
                        <h3 class="text-base font-semibold text-slate-900">Job Deep Dive</h3>
                        <div class="mt-4 space-y-5">
                            <div>
                                <p class="text-xs font-semibold uppercase tracking-[0.1em] text-slate-500">Description</p>
                                <p class="mt-2 text-sm leading-6 text-slate-800">{{ $job->description }}</p>
                            </div>
                            <div class="grid grid-cols-2 gap-4 text-sm">
                                <div><p class="text-xs text-slate-500">Location</p><p class="font-semibold text-slate-900">{{ $job->location }}</p></div>
                                <div><p class="text-xs text-slate-500">Job Type</p><p class="font-semibold text-slate-900">{{ ucfirst($job->job_type) }}</p></div>
                                <div><p class="text-xs text-slate-500">Salary Range</p><p class="font-semibold text-slate-900">{{ number_format($job->salary_min) }} - {{ number_format($job->salary_max) }}</p></div>
                                <div><p class="text-xs text-slate-500">Deadline</p><p class="font-semibold text-slate-900">{{ $job->deadline->format('M d, Y') }}</p></div>
                                <div><p class="text-xs text-slate-500">Last IP</p><p class="font-semibold text-slate-900">N/A</p></div>
                                <div><p class="text-xs text-slate-500">Success Rate</p><p class="font-semibold text-slate-900">{{ $isApproved ? '96%' : '67%' }}</p></div>
                            </div>
                            <div>
                                <p class="text-xs font-semibold uppercase tracking-[0.1em] text-slate-500">Required Skills</p>
                                <div class="mt-2 flex flex-wrap gap-2">
                                    @foreach(is_array($job->required_skills) ? $job->required_skills : explode(',', $job->required_skills) as $skill)
                                        <span class="cc-glass-chip border-indigo-200 bg-indigo-50/90 text-indigo-700">{{ trim($skill) }}</span>
                                    @endforeach
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="cc-elevated-card overflow-hidden">
                        <div class="border-b border-slate-200 bg-slate-50/90 px-5 py-4">
                            <h3 class="text-base font-semibold text-slate-900">Applications ({{ $applications->total() }})</h3>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full">
                                <thead class="border-b border-slate-200 bg-slate-50/80">
                                    <tr>
                                        <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Applicant</th>
                                        <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Status</th>
                                        <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Applied</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100">
                                    @forelse($applications as $app)
                                        <tr class="cc-record">
                                            <td class="px-5 py-4 text-sm font-semibold text-slate-900">{{ $app->user->name }}</td>
                                            <td class="px-5 py-4"><span class="cc-glass-chip @if($app->status === 'pending') border-amber-200 bg-amber-50/90 text-amber-700 @elseif($app->status === 'accepted') border-emerald-200 bg-emerald-50/90 text-emerald-700 @elseif($app->status === 'shortlisted') border-violet-200 bg-violet-50/90 text-violet-700 @else border-slate-200 bg-slate-100/90 text-slate-700 @endif">{{ ucfirst($app->status) }}</span></td>
                                            <td class="px-5 py-4 text-sm text-slate-600">{{ $app->created_at->format('M d, Y') }}</td>
                                        </tr>
                                    @empty
                                        <tr><td colspan="3" class="px-5 py-8 text-center text-sm text-slate-500">No applications yet.</td></tr>
                                    @endforelse
                                </tbody>
                            </table>
                        </div>
                        <div class="border-t border-slate-100 bg-slate-50/70 px-5 py-4">{{ $applications->links() }}</div>
                    </div>
                </div>

                <aside class="space-y-6">
                    <div class="cc-elevated-card p-5">
                        <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Recruiter Info</h3>
                        <div class="mt-3 space-y-2 text-sm">
                            <p class="font-semibold text-slate-900">{{ $job->recruiter->name }}</p>
                            <p class="text-slate-600">{{ $job->recruiter->email }}</p>
                            <a href="{{ route('admin.users.show', $job->recruiter) }}" class="font-semibold text-indigo-600 hover:text-indigo-800">View Recruiter Profile</a>
                        </div>
                    </div>

                    <div class="cc-elevated-card p-5">
                        <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Performance Spark</h3>
                        <svg viewBox="0 0 260 70" class="mt-3 h-16 w-full">
                            <path d="M0 56 L30 49 L58 52 L86 39 L114 41 L142 30 L168 36 L196 25 L224 27 L260 18" fill="none" stroke="url(#jobTrend)" stroke-width="3" stroke-linecap="round" />
                            <defs>
                                <linearGradient id="jobTrend" x1="0" y1="0" x2="1" y2="0">
                                    <stop offset="0%" stop-color="#4f46e5" />
                                    <stop offset="100%" stop-color="#8b5cf6" />
                                </linearGradient>
                            </defs>
                        </svg>
                        <div class="mt-3 space-y-2 text-sm">
                            <p class="flex justify-between"><span class="text-slate-500">Total Applications</span><span class="font-semibold text-slate-900">{{ $applications->total() }}</span></p>
                            <p class="flex justify-between"><span class="text-slate-500">Posted On</span><span class="font-semibold text-slate-900">{{ $job->created_at->format('M d, Y') }}</span></p>
                        </div>
                    </div>
                </aside>
            </div>
        </section>
    </div>
</div>
@endsection
