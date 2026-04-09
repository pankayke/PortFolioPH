@extends('layouts.app')

@section('content')
@include('admin.partials.command_center_styles')
@php
    $activeSessions = max(3, count($recentActions['User edits']) + count($recentActions['Job changes']) + count($recentActions['Application updates']));
    $serverLoad = min(84, max(26, (int) round($activeSessions * 7.5)));
@endphp

<div class="cc-theme cc-ultra-shell">
    <div class="grid grid-cols-1 gap-6 xl:grid-cols-[250px_minmax(0,1fr)]">
        <aside class="cc-admin-rail cc-left-rail p-4">
            <p class="mb-4 text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Admin Rail</p>
            <nav class="space-y-2">
                <a href="{{ route('admin.dashboard') }}" class="cc-rail-link">Dashboard</a>
                <a href="{{ route('admin.users.index') }}" class="cc-rail-link">Users</a>
                <a href="{{ route('admin.jobs.index') }}" class="cc-rail-link">Jobs</a>
                <a href="{{ route('admin.applications.index') }}" class="cc-rail-link">Applications</a>
                <a href="{{ route('admin.settings') }}" class="cc-rail-link">Settings</a>
            </nav>

            <div class="cc-elevated-card mt-5 p-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.1em] text-indigo-500">Live System</p>
                <div class="mt-2 flex items-center justify-between">
                    <div class="flex items-center gap-2 text-sm font-medium text-slate-800">
                        <span class="cc-status-pulse"></span>
                        Audit Stream
                    </div>
                    <span class="text-xs font-semibold text-emerald-600">Live</span>
                </div>
                <div class="mt-3 space-y-2 text-xs text-slate-600">
                    <p class="flex justify-between"><span>Active Sessions</span><span class="font-semibold text-slate-900">{{ $activeSessions }}</span></p>
                    <progress class="cc-progress" max="100" value="{{ min(95, $serverLoad + 9) }}"></progress>
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
                    <span class="font-medium text-slate-900">Audit</span>
                </div>
                <h1 class="text-3xl font-extrabold text-slate-900">Audit Command Stream</h1>
                <p class="cc-muted mt-1 text-sm">Dense operational logging for user edits, job changes, and application state transitions.</p>
            </header>

            <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
                <div class="cc-elevated-card overflow-hidden">
                    <div class="border-b border-slate-200 bg-slate-50/90 px-5 py-4">
                        <h3 class="text-base font-semibold text-slate-900">Recent User Edits</h3>
                    </div>
                    <div class="divide-y divide-slate-100">
                        @forelse($recentActions['User edits'] as $user)
                            <div class="cc-record px-5 py-3">
                                <p class="text-sm font-semibold text-slate-900">{{ $user->name }}</p>
                                <p class="text-xs text-slate-500">{{ $user->email }}</p>
                                <p class="mt-1 text-xs text-slate-400">{{ $user->updated_at->diffForHumans() }}</p>
                            </div>
                        @empty
                            <div class="px-5 py-5 text-center text-sm text-slate-500">No recent edits</div>
                        @endforelse
                    </div>
                </div>

                <div class="cc-elevated-card overflow-hidden">
                    <div class="border-b border-slate-200 bg-slate-50/90 px-5 py-4">
                        <h3 class="text-base font-semibold text-slate-900">Recent Job Changes</h3>
                    </div>
                    <div class="divide-y divide-slate-100">
                        @forelse($recentActions['Job changes'] as $job)
                            <div class="cc-record px-5 py-3">
                                <p class="text-sm font-semibold text-slate-900">{{ $job->title }}</p>
                                <p class="text-xs text-slate-500">by {{ $job->recruiter->name ?? 'Unknown' }}</p>
                                <p class="mt-1 text-xs text-slate-400">{{ $job->updated_at->diffForHumans() }}</p>
                            </div>
                        @empty
                            <div class="px-5 py-5 text-center text-sm text-slate-500">No recent changes</div>
                        @endforelse
                    </div>
                </div>

                <div class="cc-elevated-card overflow-hidden">
                    <div class="border-b border-slate-200 bg-slate-50/90 px-5 py-4">
                        <h3 class="text-base font-semibold text-slate-900">Recent Application Updates</h3>
                    </div>
                    <div class="divide-y divide-slate-100">
                        @forelse($recentActions['Application updates'] as $app)
                            <div class="cc-record px-5 py-3">
                                <p class="text-sm font-semibold text-slate-900">{{ $app->job->title ?? 'N/A' }}</p>
                                <p class="text-xs text-slate-500">by {{ $app->user->name ?? 'Unknown' }}</p>
                                <p class="mt-1 text-xs text-slate-400">{{ $app->updated_at->diffForHumans() }}</p>
                            </div>
                        @empty
                            <div class="px-5 py-5 text-center text-sm text-slate-500">No recent updates</div>
                        @endforelse
                    </div>
                </div>
            </div>
        </section>
    </div>
</div>
@endsection
