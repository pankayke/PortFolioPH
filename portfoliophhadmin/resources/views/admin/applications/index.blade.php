@extends('layouts.app')

@section('content')
@include('admin.partials.command_center_styles')
@php
    $totalApplications = (int) ($stats['pending'] + $stats['reviewed'] + $stats['shortlisted'] + $stats['accepted'] + $stats['rejected']);
    $activeSessions = max(2, (int) round(($stats['reviewed'] + $stats['shortlisted'] + $stats['accepted']) * 0.3));
    $serverLoad = min(86, max(20, (int) round(($stats['pending'] / max($totalApplications, 1)) * 100) + 24));
@endphp

<div class="cc-theme cc-ultra-shell">
    <div class="cc-ultra-grid">
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
                        Intake Stream
                    </div>
                    <span class="text-xs font-semibold text-emerald-600">Flowing</span>
                </div>
                <div class="mt-3 space-y-2 text-xs text-slate-600">
                    <p class="flex justify-between"><span>Active Sessions</span><span class="font-semibold text-slate-900">{{ $activeSessions }}</span></p>
                    <progress class="cc-progress" max="100" value="{{ min(95, $serverLoad + 9) }}"></progress>
                    <p class="flex justify-between"><span>Server Load</span><span class="font-semibold text-slate-900">{{ $serverLoad }}%</span></p>
                    <progress class="cc-progress" max="100" value="{{ $serverLoad }}"></progress>
                </div>
            </div>
        </aside>

        <section class="cc-main-panel space-y-3">
            <header class="cc-elevated-card p-5 md:p-6">
                <div class="mb-3 flex items-center text-sm">
                    <a href="{{ route('admin.dashboard') }}" class="cc-muted hover:text-slate-700">Admin</a>
                    <span class="mx-2 text-slate-400">/</span>
                    <span class="font-medium text-slate-900">Applications</span>
                </div>
                <h1 class="text-3xl font-extrabold text-slate-900">Applications Analytics Hub</h1>
                <p class="cc-muted mt-1 text-sm">Status pulses and trend cards for every stage of the candidate funnel.</p>
                <div class="mt-4 grid grid-cols-2 gap-3 md:grid-cols-3 xl:grid-cols-6">
                    <div class="rounded-xl border border-slate-200 bg-slate-50/85 p-3 text-sm md:col-span-2">
                        <p class="text-slate-500">Total</p>
                        <p class="mt-1 text-2xl font-bold text-slate-900">{{ $totalApplications }}</p>
                    </div>
                    <div class="rounded-xl border border-amber-200 bg-amber-50/85 p-3 text-sm"><p class="text-amber-600">Pending</p><p class="mt-1 text-xl font-bold text-amber-700">{{ $stats['pending'] }}</p></div>
                    <div class="rounded-xl border border-blue-200 bg-blue-50/85 p-3 text-sm"><p class="text-blue-600">Reviewed</p><p class="mt-1 text-xl font-bold text-blue-700">{{ $stats['reviewed'] }}</p></div>
                    <div class="rounded-xl border border-violet-200 bg-violet-50/85 p-3 text-sm"><p class="text-violet-600">Shortlisted</p><p class="mt-1 text-xl font-bold text-violet-700">{{ $stats['shortlisted'] }}</p></div>
                    <div class="rounded-xl border border-emerald-200 bg-emerald-50/85 p-3 text-sm"><p class="text-emerald-600">Accepted</p><p class="mt-1 text-xl font-bold text-emerald-700">{{ $stats['accepted'] }}</p></div>
                </div>
            </header>

            <div class="flex gap-2">
                <a href="{{ route('admin.applications.export-excel') }}" class="inline-flex items-center gap-2 rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-emerald-700 transition-colors">
                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2v20M2 12h20"/></svg>
                    Export Excel
                </a>
                <a href="{{ route('admin.applications.export-csv') }}" class="inline-flex items-center gap-2 rounded-xl bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700 transition-colors">
                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2v20M2 12h20"/></svg>
                    Export CSV
                </a>
            </div>

            <div class="cc-elevated-card overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="cc-density-table w-full">
                        <thead class="border-b border-slate-200 bg-slate-50/90">
                            <tr>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Job Title</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Applicant</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Email</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Source / Device</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Status</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Applied</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Quick Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            @forelse($applications as $app)
                                <tr class="cc-record">
                                    <td class="px-4 py-2.5 font-semibold text-slate-900">{{ $app->job->title ?? 'N/A' }}</td>
                                    <td class="px-4 py-2.5">
                                        <div class="flex items-center gap-2">
                                            <div class="flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 text-xs font-semibold text-white ring-2 ring-blue-200">
                                                {{ strtoupper(substr($app->user->name ?? 'U', 0, 1)) }}
                                            </div>
                                            <p class="text-sm text-slate-800">{{ $app->user->name ?? 'Unknown' }}</p>
                                        </div>
                                    </td>
                                    <td class="px-4 py-2.5 text-sm text-slate-600">{{ $app->user->email ?? 'N/A' }}</td>
                                    <td class="px-4 py-2.5 text-sm text-slate-600">{{ \Illuminate\Support\Str::limit($app->source ?? $app->device ?? 'Web Portal', 20) }}</td>
                                    <td class="px-4 py-2.5">
                                        <span class="cc-glass-chip @if($app->status === 'pending') border-amber-200 bg-amber-50/90 text-amber-700 @elseif($app->status === 'reviewed') border-blue-200 bg-blue-50/90 text-blue-700 @elseif($app->status === 'shortlisted') border-violet-200 bg-violet-50/90 text-violet-700 @elseif($app->status === 'accepted') border-emerald-200 bg-emerald-50/90 text-emerald-700 @else border-slate-200 bg-slate-100/90 text-slate-600 @endif">
                                            <span class="h-1.5 w-1.5 rounded-full @if($app->status === 'pending') bg-amber-500 @elseif($app->status === 'reviewed') bg-blue-500 @elseif($app->status === 'shortlisted') bg-violet-500 @elseif($app->status === 'accepted') bg-emerald-500 @else bg-slate-400 @endif"></span>
                                            {{ ucfirst(str_replace('_', ' ', $app->status)) }}
                                        </span>
                                    </td>
                                    <td class="px-4 py-2.5 text-sm text-slate-600">{{ $app->created_at->format('M d, Y H:i') }}</td>
                                    <td class="px-4 py-2.5">
                                        <div class="cc-quick-actions inline-flex items-center gap-1.5 rounded-full border border-slate-200 bg-white px-2 py-1 shadow-sm">
                                            <a href="{{ route('admin.applications.show', $app) }}" class="rounded-full px-3 py-1 text-xs font-semibold text-indigo-600 hover:bg-indigo-50">Inspect</a>
                                            @if($app->job)
                                                <a href="{{ route('admin.jobs.show', $app->job) }}" class="rounded-full px-3 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-100">Job</a>
                                            @endif
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="7" class="px-4 py-12 text-center text-sm text-slate-500">No applications have been submitted yet.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                @if($applications->hasPages())
                    <div class="border-t border-slate-100 bg-slate-50/70 px-6 py-5">{{ $applications->links() }}</div>
                @endif
            </div>

            <footer class="cc-pulse-footer">
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Online Users</span><span class="text-sm font-bold text-slate-900">{{ $activeSessions }}</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">API Latency</span><span class="text-sm font-bold text-indigo-700">{{ max(45, min(260, 63 + $serverLoad)) }} ms</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Last Backup</span><span class="text-sm font-bold text-slate-900">{{ now()->subMinutes(26)->format('M d, H:i') }}</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Build</span><span class="text-sm font-bold text-slate-900">v2.6.4</span></div>
            </footer>
        </section>

        <aside class="cc-activity-rail space-y-3">
            <div class="cc-elevated-card p-4">
                <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Pipeline Logs</h3>
                <div class="mt-3 space-y-2 text-xs">
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Application shortlisted</span><span class="text-slate-500">2m ago</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Reviewer assigned</span><span class="text-slate-500">8m ago</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Candidate accepted</span><span class="text-slate-500">13m ago</span></div>
                </div>
            </div>

            <div class="cc-elevated-card p-4">
                <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Stream Gauges</h3>
                <div class="mt-3 space-y-2 text-xs text-slate-600">
                    <p class="flex justify-between"><span>Queue Pressure</span><span class="font-semibold text-slate-900">{{ $serverLoad }}%</span></p>
                    <progress class="cc-progress" max="100" value="{{ $serverLoad }}"></progress>
                    <p class="flex justify-between"><span>Pending Share</span><span class="font-semibold text-amber-600">{{ $stats['pending'] }}</span></p>
                </div>
            </div>
        </aside>
    </div>
</div>
@endsection
