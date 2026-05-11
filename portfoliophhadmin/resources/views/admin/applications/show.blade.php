@extends('layouts.app')

@section('content')
@include('admin.partials.command_center_styles')
@php
    $statusStyles = [
        'pending' => 'border-amber-200 bg-amber-50/90 text-amber-700',
        'reviewed' => 'border-blue-200 bg-blue-50/90 text-blue-700',
        'shortlisted' => 'border-violet-200 bg-violet-50/90 text-violet-700',
        'accepted' => 'border-emerald-200 bg-emerald-50/90 text-emerald-700',
        'rejected' => 'border-rose-200 bg-rose-50/90 text-rose-700',
    ];
    $statusClass = $statusStyles[$application->status] ?? 'border-slate-200 bg-slate-100/90 text-slate-700';
@endphp

<div class="cc-theme cc-ultra-shell">
    <div class="grid grid-cols-1 gap-6 xl:grid-cols-[250px_minmax(0,1fr)]">
        <aside class="cc-admin-rail cc-left-rail p-4">
            <p class="mb-4 text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Admin Rail</p>
            <nav class="space-y-2">
                <a href="{{ route('admin.dashboard') }}" class="cc-rail-link">Dashboard</a>
                <a href="{{ route('admin.users.index') }}" class="cc-rail-link">Users</a>
                <a href="{{ route('admin.jobs.index') }}" class="cc-rail-link">Jobs</a>
                <a href="{{ route('admin.applications.index') }}" class="cc-rail-link cc-rail-link-active">Applications</a>
                <a href="{{ route('admin.settings') }}" class="cc-rail-link">Settings</a>
            </nav>

            <div class="cc-elevated-card mt-5 p-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.1em] text-indigo-500">Live System</p>
                <div class="mt-2 flex items-center justify-between">
                    <div class="flex items-center gap-2 text-sm font-medium text-slate-800">
                        <span class="cc-status-pulse"></span>
                        Review Lane
                    </div>
                    <span class="text-xs font-semibold text-emerald-600">Open</span>
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
                    <a href="{{ route('admin.applications.index') }}" class="cc-muted hover:text-slate-700">Applications</a>
                    <span class="mx-2 text-slate-400">/</span>
                    <span class="font-medium text-slate-900">Inspect</span>
                </div>

                <div class="flex flex-wrap items-start justify-between gap-4">
                    <div>
                        <h1 class="text-3xl font-extrabold text-slate-900">{{ $application->job->title ?? 'Application Review' }}</h1>
                        <p class="cc-muted mt-1 text-sm">Submitted by {{ $application->user->name ?? 'Unknown Applicant' }}</p>
                        <div class="mt-3 flex flex-wrap gap-2">
                            <span class="cc-glass-chip {{ $statusClass }}">{{ ucfirst(str_replace('_', ' ', $application->status)) }}</span>
                            <span class="cc-glass-chip border-slate-200 bg-slate-50/90 text-slate-700">Applied {{ $application->created_at->format('M d, Y H:i') }}</span>
                            @if($application->job?->location)
                                <span class="cc-glass-chip border-slate-200 bg-slate-50/90 text-slate-700">{{ $application->job->location }}</span>
                            @endif
                        </div>
                    </div>

                    <div class="flex flex-wrap gap-2">
                        @if($application->user?->resume_path)
                            <a href="{{ route('admin.applications.download-cv', $application) }}" class="rounded-xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700">Download CV</a>
                        @endif
                        @if($application->job)
                            <a href="{{ route('admin.jobs.show', $application->job) }}" class="rounded-xl bg-slate-700 px-4 py-2.5 text-sm font-semibold text-white hover:bg-slate-800">Review Job</a>
                        @endif
                    </div>
                </div>
            </header>

            <div class="grid grid-cols-1 gap-6 xl:grid-cols-[minmax(0,1fr)_320px]">
                <div class="space-y-6">
                    <div class="cc-elevated-card p-5 md:p-6">
                        <h3 class="text-base font-semibold text-slate-900">Application Details</h3>
                        <div class="mt-4 grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div>
                                <p class="text-xs font-semibold uppercase tracking-[0.1em] text-slate-500">Applicant</p>
                                <p class="mt-2 text-sm font-semibold text-slate-900">{{ $application->user->name ?? 'Unknown' }}</p>
                                <p class="text-sm text-slate-600">{{ $application->user->email ?? 'N/A' }}</p>
                            </div>
                            <div>
                                <p class="text-xs font-semibold uppercase tracking-[0.1em] text-slate-500">Job</p>
                                <p class="mt-2 text-sm font-semibold text-slate-900">{{ $application->job->title ?? 'N/A' }}</p>
                                @if($application->job)
                                    <a href="{{ route('admin.jobs.show', $application->job) }}" class="text-sm font-semibold text-indigo-600 hover:text-indigo-800">Open job review</a>
                                @endif
                            </div>
                            <div>
                                <p class="text-xs font-semibold uppercase tracking-[0.1em] text-slate-500">Source</p>
                                <p class="mt-2 text-sm font-semibold text-slate-900">{{ \Illuminate\Support\Str::limit($application->source ?? $application->device ?? 'Web Portal', 40) }}</p>
                            </div>
                            <div>
                                <p class="text-xs font-semibold uppercase tracking-[0.1em] text-slate-500">Submission Date</p>
                                <p class="mt-2 text-sm font-semibold text-slate-900">{{ $application->created_at->format('M d, Y H:i') }}</p>
                            </div>
                        </div>
                    </div>

                    <div class="cc-elevated-card p-5 md:p-6">
                        <h3 class="text-base font-semibold text-slate-900">Cover Letter</h3>
                        <div class="mt-4 rounded-xl border border-slate-200 bg-slate-50/80 p-4 text-sm leading-6 text-slate-700">
                            {{ $application->cover_letter ?: 'No cover letter was provided.' }}
                        </div>
                    </div>
                </div>

                <aside class="space-y-6">
                    <div class="cc-elevated-card p-5">
                        <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Applicant Card</h3>
                        <div class="mt-4 space-y-2 text-sm">
                            <p class="font-semibold text-slate-900">{{ $application->user->name ?? 'Unknown Applicant' }}</p>
                            <p class="text-slate-600">{{ $application->user->email ?? 'N/A' }}</p>
                            @if($application->user)
                                <a href="{{ route('admin.users.show', $application->user) }}" class="font-semibold text-indigo-600 hover:text-indigo-800">Open user profile</a>
                            @endif
                        </div>
                    </div>

                    <div class="cc-elevated-card p-5">
                        <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Job Card</h3>
                        <div class="mt-4 space-y-2 text-sm">
                            <p class="font-semibold text-slate-900">{{ $application->job->title ?? 'N/A' }}</p>
                            <p class="text-slate-600">{{ $application->job->location ?? 'No location listed' }}</p>
                            @if($application->job)
                                <a href="{{ route('admin.jobs.show', $application->job) }}" class="font-semibold text-indigo-600 hover:text-indigo-800">Open job profile</a>
                            @endif
                        </div>
                    </div>
                </aside>
            </div>
        </section>
    </div>
</div>
@endsection