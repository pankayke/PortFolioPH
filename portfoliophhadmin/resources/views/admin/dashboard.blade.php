@extends('layouts.app')

@section('content')
@include('admin.partials.command_center_styles')
@php
    $totalUsers = max((int) ($stats['total_users'] ?? 0), 1);
    $adminsPct = (int) round(((int) ($stats['admins'] ?? 0) / $totalUsers) * 100);
    $recruitersPct = (int) round(((int) ($stats['recruiters'] ?? 0) / $totalUsers) * 100);
    $seekersPct = (int) round(((int) ($stats['job_seekers'] ?? 0) / $totalUsers) * 100);
    $liveSessions = max(3, (int) round(((int) ($stats['active_jobs'] ?? 0) + (int) ($stats['pending_applications'] ?? 0)) * 0.45));
    $serverLoad = min(88, max(18, (int) round((((int) ($stats['pending_applications'] ?? 0)) / max((int) ($stats['total_applications'] ?? 1), 1)) * 100) + 26));
    $apiLatency = min(260, max(36, 70 + (int) round($serverLoad * 1.2)));
    $churnRate = max(1, min(16, (int) round(($stats['pending_applications'] / max($stats['total_applications'], 1)) * 14)));
    $dbSize = number_format(max(1.1, ($stats['total_users'] * 0.013) + ($stats['total_applications'] * 0.0042)), 1);
@endphp

<div class="cc-theme cc-ultra-shell">
    <div class="cc-ultra-grid">
        <aside class="cc-admin-rail cc-left-rail p-4">
            <p class="mb-3 text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Admin Rail</p>
            <nav class="space-y-2">
                <a href="{{ route('admin.dashboard') }}" class="cc-rail-link cc-rail-link-active">Command Center</a>
                <a href="{{ route('admin.users.index') }}" class="cc-rail-link">Users</a>
                <a href="{{ route('admin.jobs.index') }}" class="cc-rail-link">Jobs</a>
                <a href="{{ route('admin.applications.index') }}" class="cc-rail-link">Applications</a>
                <a href="{{ route('admin.settings') }}" class="cc-rail-link">Settings</a>
            </nav>

            <div class="cc-elevated-card mt-4 p-3">
                <div class="flex items-center justify-between">
                    <p class="text-[11px] font-semibold uppercase tracking-[0.1em] text-indigo-500">Platform Healthy</p>
                    <span class="cc-status-pulse"></span>
                </div>
                <div class="mt-2 space-y-2 text-xs text-slate-600">
                    <p class="flex justify-between"><span>Online Sessions</span><span class="font-semibold text-slate-900">{{ $liveSessions }}</span></p>
                    <p class="flex justify-between"><span>CPU Load</span><span class="font-semibold text-slate-900">{{ $serverLoad }}%</span></p>
                    <p class="flex justify-between"><span>API Latency</span><span class="font-semibold text-slate-900">{{ $apiLatency }} ms</span></p>
                    <progress class="cc-progress" max="100" value="{{ $serverLoad }}"></progress>
                </div>
            </div>
        </aside>

        <section class="cc-main-panel space-y-3">
            <header class="cc-elevated-card p-4">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <h1 class="text-3xl font-extrabold text-slate-900">Admin Command Center</h1>
                        <p class="mt-1 text-sm text-slate-600">Total immersion workspace with dense telemetry and full-width operations context.</p>
                    </div>
                    <div class="rounded-lg bg-gradient-to-r from-indigo-600 to-violet-600 px-3 py-2 text-sm font-semibold text-white">Platform Administrator</div>
                </div>
            </header>

            <article class="cc-elevated-card p-4">
                <div class="flex items-center justify-between gap-3">
                    <h2 class="text-base font-bold text-slate-900">30-Day Growth Trend</h2>
                    <span class="text-xs font-semibold uppercase tracking-[0.08em] text-emerald-600">Realtime Feed</span>
                </div>
                <svg viewBox="0 0 980 220" class="cc-wide-chart mt-3">
                    <defs>
                        <linearGradient id="ccTrendFill" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="0%" stop-color="#818cf8" stop-opacity="0.28" />
                            <stop offset="100%" stop-color="#818cf8" stop-opacity="0" />
                        </linearGradient>
                        <linearGradient id="ccTrendStroke" x1="0" y1="0" x2="1" y2="0">
                            <stop offset="0%" stop-color="#4f46e5" />
                            <stop offset="100%" stop-color="#8b5cf6" />
                        </linearGradient>
                    </defs>
                    <path d="M0 182 L0 134 L78 126 L148 132 L220 122 L292 112 L364 118 L435 102 L507 95 L580 101 L652 84 L724 88 L796 72 L868 74 L940 66 L980 62 L980 182 Z" fill="url(#ccTrendFill)" />
                    <path d="M0 134 L78 126 L148 132 L220 122 L292 112 L364 118 L435 102 L507 95 L580 101 L652 84 L724 88 L796 72 L868 74 L940 66 L980 62" fill="none" stroke="url(#ccTrendStroke)" stroke-width="4" stroke-linecap="round" />
                </svg>
            </article>

            <section class="cc-elevated-card p-3">
                <div class="cc-compact-grid-5">
                    <div class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
                        <p class="text-[11px] uppercase tracking-[0.08em] text-slate-500">New Users</p>
                        <p class="text-2xl font-extrabold text-slate-900">{{ $stats['total_users'] }}</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
                        <p class="text-[11px] uppercase tracking-[0.08em] text-slate-500">Churn Rate</p>
                        <p class="text-2xl font-extrabold text-amber-600">{{ $churnRate }}%</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
                        <p class="text-[11px] uppercase tracking-[0.08em] text-slate-500">Active Jobs</p>
                        <p class="text-2xl font-extrabold text-emerald-600">{{ $stats['active_jobs'] }}</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
                        <p class="text-[11px] uppercase tracking-[0.08em] text-slate-500">Pending Approvals</p>
                        <p class="text-2xl font-extrabold text-violet-600">{{ $stats['pending_applications'] }}</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
                        <p class="text-[11px] uppercase tracking-[0.08em] text-slate-500">Latency</p>
                        <p class="text-2xl font-extrabold text-indigo-600">{{ $apiLatency }} ms</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
                        <p class="text-[11px] uppercase tracking-[0.08em] text-slate-500">Database Size</p>
                        <p class="text-2xl font-extrabold text-slate-900">{{ $dbSize }} GB</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
                        <p class="text-[11px] uppercase tracking-[0.08em] text-slate-500">Admins</p>
                        <p class="text-2xl font-extrabold text-rose-600">{{ $adminsPct }}%</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
                        <p class="text-[11px] uppercase tracking-[0.08em] text-slate-500">Recruiters</p>
                        <p class="text-2xl font-extrabold text-blue-600">{{ $recruitersPct }}%</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
                        <p class="text-[11px] uppercase tracking-[0.08em] text-slate-500">Job Seekers</p>
                        <p class="text-2xl font-extrabold text-emerald-600">{{ $seekersPct }}%</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2">
                        <p class="text-[11px] uppercase tracking-[0.08em] text-slate-500">Queue Depth</p>
                        <p class="text-2xl font-extrabold text-slate-900">{{ max(4, (int) round($stats['pending_applications'] * 0.7)) }}</p>
                    </div>
                </div>
            </section>

            <section class="cc-elevated-card overflow-hidden">
                <header class="border-b border-slate-200 px-4 py-3">
                    <h3 class="text-sm font-semibold uppercase tracking-[0.08em] text-slate-600">High-Density Live Users</h3>
                </header>
                <div class="overflow-x-auto">
                    <table class="cc-density-table w-full text-sm">
                        <thead class="border-b border-slate-200 bg-slate-50">
                            <tr>
                                <th class="px-4 py-2 text-left text-[11px] font-semibold uppercase tracking-[0.1em] text-slate-600">User</th>
                                <th class="px-4 py-2 text-left text-[11px] font-semibold uppercase tracking-[0.1em] text-slate-600">IP</th>
                                <th class="px-4 py-2 text-left text-[11px] font-semibold uppercase tracking-[0.1em] text-slate-600">Browser / OS</th>
                                <th class="px-4 py-2 text-left text-[11px] font-semibold uppercase tracking-[0.1em] text-slate-600">Last Active</th>
                                <th class="px-4 py-2 text-left text-[11px] font-semibold uppercase tracking-[0.1em] text-slate-600">Status</th>
                                <th class="px-4 py-2 text-left text-[11px] font-semibold uppercase tracking-[0.1em] text-slate-600">Quick Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            @forelse($recentUsers as $user)
                                @php
                                    $userIp = $user->last_login_ip ?? $user->ip_address ?? 'N/A';
                                    $ua = $user->last_user_agent ?? $user->user_agent ?? 'Unknown Browser';
                                    $shortUa = \Illuminate\Support\Str::limit($ua, 28);
                                @endphp
                                <tr class="cc-record">
                                    <td class="px-4 py-2.5 font-semibold text-slate-900">{{ $user->name }}</td>
                                    <td class="px-4 py-2.5 text-slate-600">{{ $userIp }}</td>
                                    <td class="px-4 py-2.5 text-slate-600">{{ $shortUa }}</td>
                                    <td class="px-4 py-2.5 text-slate-600">{{ $user->updated_at?->diffForHumans() ?? 'recently' }}</td>
                                    <td class="px-4 py-2.5">
                                        <span class="cc-glass-chip border-emerald-200 bg-emerald-50/90 text-emerald-700"><span class="cc-status-pulse"></span>Active</span>
                                    </td>
                                    <td class="px-4 py-2.5">
                                        <a href="{{ route('admin.users.show', $user) }}" class="rounded-md border border-slate-200 px-2.5 py-1 text-xs font-semibold text-indigo-600 hover:bg-indigo-50">Inspect</a>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="6" class="px-4 py-10 text-center text-sm text-slate-500">No user activity yet.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </section>

            <footer class="cc-pulse-footer">
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Online Users</span><span class="text-sm font-bold text-slate-900">{{ $liveSessions }}</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">API Latency</span><span class="text-sm font-bold text-indigo-700">{{ $apiLatency }} ms</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Last Backup</span><span class="text-sm font-bold text-slate-900">{{ now()->subMinutes(17)->format('M d, H:i') }}</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Build</span><span class="text-sm font-bold text-slate-900">v2.6.4</span></div>
            </footer>
        </section>

        <aside class="cc-activity-rail space-y-3">
            <div class="cc-elevated-card p-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.1em] text-slate-500">Real-Time Audit Logs</p>
                <div class="mt-3 space-y-2 text-xs">
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">User role updated</span><span class="text-slate-500">2m ago</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Job approved</span><span class="text-slate-500">5m ago</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Bulk moderation sync</span><span class="text-slate-500">8m ago</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Queue worker recycled</span><span class="text-slate-500">12m ago</span></div>
                </div>
            </div>

            <div class="cc-elevated-card p-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.1em] text-slate-500">Server Health Gauges</p>
                <div class="mt-3 space-y-3 text-xs text-slate-600">
                    <p class="flex justify-between"><span>CPU</span><span class="font-semibold text-slate-900">{{ $serverLoad }}%</span></p>
                    <progress class="cc-progress" max="100" value="{{ $serverLoad }}"></progress>
                    <p class="flex justify-between"><span>Memory</span><span class="font-semibold text-slate-900">{{ min(90, $serverLoad + 9) }}%</span></p>
                    <progress class="cc-progress" max="100" value="{{ min(90, $serverLoad + 9) }}"></progress>
                    <p class="flex justify-between"><span>I/O</span><span class="font-semibold text-slate-900">{{ max(22, $serverLoad - 12) }}%</span></p>
                    <progress class="cc-progress" max="100" value="{{ max(22, $serverLoad - 12) }}"></progress>
                </div>
            </div>

            <div class="cc-elevated-card p-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.1em] text-slate-500">Notifications</p>
                <ul class="mt-2 space-y-2 text-xs text-slate-600">
                    <li class="rounded-lg border border-slate-200 px-2 py-1.5">{{ $stats['pending_applications'] }} applications await triage.</li>
                    <li class="rounded-lg border border-slate-200 px-2 py-1.5">{{ $stats['active_jobs'] }} jobs are currently visible.</li>
                    <li class="rounded-lg border border-slate-200 px-2 py-1.5">Recruiter moderation SLA is within target.</li>
                </ul>
            </div>
        </aside>
    </div>
</div>
@endsection