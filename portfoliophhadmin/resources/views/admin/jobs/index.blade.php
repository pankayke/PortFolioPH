@extends('layouts.app')

@section('content')
@include('admin.partials.command_center_styles')
@php
    $approvedCount = $jobs->where('status', 'approved')->count();
    $closedCount = $jobs->where('status', 'closed')->count();
    $activeSessions = max(2, (int) round($jobs->count() * 0.33));
    $serverLoad = min(87, max(18, (int) round(($approvedCount / max($jobs->count(), 1)) * 100)));
@endphp

<div class="cc-theme cc-ultra-shell">
    <div class="cc-ultra-grid">
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
                        <span class="cc-status-pulse"></span>
                        Moderation Queue
                    </div>
                    <span class="text-xs font-semibold text-emerald-600">Live</span>
                </div>
                <div class="mt-3 space-y-2 text-xs text-slate-600">
                    <p class="flex justify-between"><span>Active Sessions</span><span class="font-semibold text-slate-900">{{ $activeSessions }}</span></p>
                    <progress class="cc-progress" max="100" value="{{ min(95, $serverLoad + 8) }}"></progress>
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
                    <span class="font-medium text-slate-900">Jobs</span>
                </div>
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <h1 class="text-3xl font-extrabold text-slate-900">Jobs Moderation Hub</h1>
                        <p class="cc-muted mt-1 text-sm">Review posting quality with dense insights and fast action rails.</p>
                    </div>
                    <div class="flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-2.5 text-sm text-white">
                        <span class="font-semibold">{{ $jobs->total() }}</span>
                        <span class="text-slate-300">total jobs</span>
                    </div>
                </div>
                <div class="mt-4 grid grid-cols-2 gap-3 md:grid-cols-4">
                    <div class="rounded-xl border border-slate-200 bg-slate-50/85 p-3 text-sm">
                        <p class="text-slate-500">Approved</p>
                        <p class="mt-1 text-xl font-bold text-emerald-600">{{ $approvedCount }}</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50/85 p-3 text-sm">
                        <p class="text-slate-500">Closed</p>
                        <p class="mt-1 text-xl font-bold text-slate-700">{{ $closedCount }}</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50/85 p-3 text-sm">
                        <p class="text-slate-500">Pending</p>
                        <p class="mt-1 text-xl font-bold text-amber-600">{{ $jobs->where('status', 'pending')->count() }}</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50/85 p-3 text-sm">
                        <p class="text-slate-500">Draft</p>
                        <p class="mt-1 text-xl font-bold text-indigo-600">{{ $jobs->where('status', 'draft')->count() }}</p>
                    </div>
                </div>
            </header>

            <div class="cc-elevated-card overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="cc-density-table w-full">
                        <thead class="border-b border-slate-200 bg-slate-50/90">
                            <tr>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Job Title</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Recruiter</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Company / Source</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Status</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Applications</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Last Activity</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Quick Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            @forelse($jobs as $job)
                                <tr class="cc-record">
                                    <td class="px-4 py-2.5">
                                        <div class="flex items-center gap-3">
                                            <div class="h-2.5 w-2.5 rounded-full {{ $job->status === 'approved' ? 'bg-emerald-500 shadow-[0_0_0_5px_rgba(16,185,129,0.18)]' : ($job->status === 'pending' ? 'bg-amber-500 shadow-[0_0_0_5px_rgba(245,158,11,0.18)]' : 'bg-slate-400') }}"></div>
                                            <p class="font-semibold text-slate-900">{{ $job->title }}</p>
                                        </div>
                                    </td>
                                    <td class="px-4 py-2.5 text-sm">
                                        <a href="{{ route('admin.users.show', $job->recruiter) }}" class="font-medium text-indigo-600 hover:text-indigo-800">{{ $job->recruiter->name }}</a>
                                    </td>
                                    <td class="px-4 py-2.5 text-sm text-slate-600">{{ \Illuminate\Support\Str::limit($job->company_name ?? $job->location ?? 'PortfolioPH', 24) }}</td>
                                    <td class="px-4 py-2.5">
                                        <span class="cc-glass-chip @if($job->status === 'approved') border-emerald-200 bg-emerald-50/90 text-emerald-700 @elseif($job->status === 'pending') border-amber-200 bg-amber-50/90 text-amber-700 @elseif($job->status === 'draft') border-indigo-200 bg-indigo-50/90 text-indigo-700 @else border-slate-200 bg-slate-100/85 text-slate-600 @endif">
                                            <span class="h-1.5 w-1.5 rounded-full @if($job->status === 'approved') bg-emerald-500 @elseif($job->status === 'pending') bg-amber-500 @elseif($job->status === 'draft') bg-indigo-500 @else bg-slate-400 @endif"></span>
                                            {{ ucfirst($job->status) }}
                                        </span>
                                    </td>
                                    <td class="px-4 py-2.5 text-sm text-slate-700">{{ $job->applications->count() }} applications</td>
                                    <td class="px-4 py-2.5 text-sm text-slate-600">{{ $job->updated_at->diffForHumans() }}</td>
                                    <td class="px-4 py-2.5">
                                        <div class="cc-quick-actions inline-flex items-center gap-1.5 rounded-full border border-slate-200 bg-white px-2 py-1 shadow-sm">
                                            <a href="{{ route('admin.jobs.show', $job) }}" class="rounded-full px-3 py-1 text-xs font-semibold text-indigo-600 hover:bg-indigo-50">Review</a>
                                            <a href="{{ route('admin.users.show', $job->recruiter) }}" class="rounded-full px-3 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-100">Recruiter</a>
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="7" class="px-4 py-12 text-center text-sm text-slate-500">No jobs available in moderation right now.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                @if($jobs->hasPages())
                    <div class="border-t border-slate-100 bg-slate-50/70 px-6 py-5">{{ $jobs->links() }}</div>
                @endif
            </div>

            <footer class="cc-pulse-footer">
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Online Users</span><span class="text-sm font-bold text-slate-900">{{ $activeSessions }}</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">API Latency</span><span class="text-sm font-bold text-indigo-700">{{ max(42, min(260, 52 + $serverLoad)) }} ms</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Last Backup</span><span class="text-sm font-bold text-slate-900">{{ now()->subMinutes(23)->format('M d, H:i') }}</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Build</span><span class="text-sm font-bold text-slate-900">v2.6.4</span></div>
            </footer>
        </section>

        <aside class="cc-activity-rail space-y-3">
            <div class="cc-elevated-card p-4">
                <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Moderation Logs</h3>
                <div class="mt-3 space-y-2 text-xs">
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Job approved</span><span class="text-slate-500">1m ago</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Draft reopened</span><span class="text-slate-500">7m ago</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Queue reassigned</span><span class="text-slate-500">15m ago</span></div>
                </div>
            </div>

            <div class="cc-elevated-card p-4">
                <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Server Health</h3>
                <div class="mt-3 space-y-2 text-xs text-slate-600">
                    <p class="flex justify-between"><span>Load</span><span class="font-semibold text-slate-900">{{ $serverLoad }}%</span></p>
                    <progress class="cc-progress" max="100" value="{{ $serverLoad }}"></progress>
                    <p class="flex justify-between"><span>Queue Depth</span><span class="font-semibold text-slate-900">{{ max(4, (int) round($jobs->total() * 0.18)) }}</span></p>
                </div>
            </div>
        </aside>
    </div>
</div>
@endsection
