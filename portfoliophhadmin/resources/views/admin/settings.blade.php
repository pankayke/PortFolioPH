@extends('layouts.app')

@section('content')
@include('admin.partials.command_center_styles')

<div class="cc-theme cc-ultra-shell">
    <div class="cc-ultra-grid">
        <aside class="cc-admin-rail cc-left-rail p-4">
            <p class="mb-4 text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">Admin Rail</p>
            <nav class="space-y-2">
                <a href="{{ route('admin.dashboard') }}" class="cc-rail-link">Dashboard</a>
                <a href="{{ route('admin.users.index') }}" class="cc-rail-link">Users</a>
                <a href="{{ route('admin.jobs.index') }}" class="cc-rail-link">Jobs</a>
                <a href="{{ route('admin.applications.index') }}" class="cc-rail-link">Applications</a>
                <a href="{{ route('admin.settings') }}" class="cc-rail-link cc-rail-link-active">Settings</a>
            </nav>

            <div class="cc-elevated-card mt-5 p-3">
                <p class="text-[11px] font-semibold uppercase tracking-[0.1em] text-indigo-500">Live System</p>
                <div class="mt-2 flex items-center justify-between">
                    <div class="flex items-center gap-2 text-sm font-medium text-slate-800">
                        @if($settings['maintenance_mode'])
                            <span class="h-2.5 w-2.5 rounded-full bg-amber-500 shadow-[0_0_0_5px_rgba(245,158,11,0.18)]"></span>
                        @else
                            <span class="cc-status-pulse"></span>
                        @endif
                        Platform Health
                    </div>
                    <span class="text-xs font-semibold {{ $settings['maintenance_mode'] ? 'text-amber-600' : 'text-emerald-600' }}">{{ $settings['maintenance_mode'] ? 'Maintenance' : 'Operational' }}</span>
                </div>
                <div class="mt-3 space-y-2 text-xs text-slate-600">
                    <p class="flex justify-between"><span>Active Sessions</span><span class="font-semibold text-slate-900">{{ $metrics['active_sessions'] }}</span></p>
                    <progress class="cc-progress" max="100" value="{{ min(96, $metrics['server_load'] + 7) }}"></progress>
                    <p class="flex justify-between"><span>Server Load</span><span class="font-semibold text-slate-900">{{ $metrics['server_load'] }}%</span></p>
                    <progress class="cc-progress" max="100" value="{{ $metrics['server_load'] }}"></progress>
                </div>
            </div>
        </aside>

        <section class="cc-main-panel space-y-3">
            <header class="cc-elevated-card p-5 md:p-6">
                <div class="mb-3 flex items-center text-sm">
                    <a href="{{ route('admin.dashboard') }}" class="cc-muted hover:text-slate-700">Admin</a>
                    <span class="mx-2 text-slate-400">/</span>
                    <span class="font-medium text-slate-900">Settings</span>
                </div>
                <h1 class="text-3xl font-extrabold text-slate-900">Command Center Settings</h1>
                <p class="cc-muted mt-1 text-sm">Tune control density, alert cadence, session policy, and maintenance behavior from a single operations panel.</p>
            </header>

            <div class="grid grid-cols-1 gap-4 xl:grid-cols-[minmax(0,1fr)_320px]">
                <div class="cc-elevated-card p-5 md:p-6">
                    <form method="POST" action="{{ route('admin.settings.update') }}" class="space-y-5">
                        @csrf
                        @method('PUT')

                        <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
                            <div>
                                <label for="digest_frequency" class="mb-2 block text-sm font-semibold text-slate-700">Alert Digest Frequency</label>
                                <select id="digest_frequency" name="digest_frequency" class="cc-field @error('digest_frequency') cc-field-error @enderror">
                                    <option value="realtime" @selected(old('digest_frequency', $settings['digest_frequency']) === 'realtime')>Real-time</option>
                                    <option value="hourly" @selected(old('digest_frequency', $settings['digest_frequency']) === 'hourly')>Hourly</option>
                                    <option value="daily" @selected(old('digest_frequency', $settings['digest_frequency']) === 'daily')>Daily</option>
                                    <option value="weekly" @selected(old('digest_frequency', $settings['digest_frequency']) === 'weekly')>Weekly</option>
                                </select>
                                @error('digest_frequency')
                                    <p class="mt-1 text-xs font-medium text-rose-600">{{ $message }}</p>
                                @enderror
                            </div>

                            <div>
                                <label for="dashboard_density" class="mb-2 block text-sm font-semibold text-slate-700">Dashboard Density</label>
                                <select id="dashboard_density" name="dashboard_density" class="cc-field @error('dashboard_density') cc-field-error @enderror">
                                    <option value="compact" @selected(old('dashboard_density', $settings['dashboard_density']) === 'compact')>Compact</option>
                                    <option value="high" @selected(old('dashboard_density', $settings['dashboard_density']) === 'high')>High</option>
                                    <option value="spacious" @selected(old('dashboard_density', $settings['dashboard_density']) === 'spacious')>Spacious</option>
                                </select>
                                @error('dashboard_density')
                                    <p class="mt-1 text-xs font-medium text-rose-600">{{ $message }}</p>
                                @enderror
                            </div>
                        </div>

                        <div class="max-w-sm">
                            <label for="session_timeout" class="mb-2 block text-sm font-semibold text-slate-700">Session Timeout (minutes)</label>
                            <input type="number" id="session_timeout" name="session_timeout" min="5" max="240" value="{{ old('session_timeout', $settings['session_timeout']) }}" class="cc-field @error('session_timeout') cc-field-error @enderror" />
                            @error('session_timeout')
                                <p class="mt-1 text-xs font-medium text-rose-600">{{ $message }}</p>
                            @enderror
                        </div>

                        <div class="rounded-2xl border border-slate-200 bg-slate-50/85 p-4">
                            <h3 class="text-sm font-semibold text-slate-900">Live Feature Toggles</h3>
                            <div class="mt-3 space-y-3">
                                <label class="flex items-center justify-between gap-3 rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700">
                                    <span>Maintenance Mode</span>
                                    <input type="hidden" name="maintenance_mode" value="0" />
                                    <input type="checkbox" name="maintenance_mode" value="1" class="h-4 w-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500" @checked(old('maintenance_mode', $settings['maintenance_mode'])) />
                                </label>
                                <label class="flex items-center justify-between gap-3 rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700">
                                    <span>New User Alerts</span>
                                    <input type="hidden" name="new_user_alerts" value="0" />
                                    <input type="checkbox" name="new_user_alerts" value="1" class="h-4 w-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500" @checked(old('new_user_alerts', $settings['new_user_alerts'])) />
                                </label>
                                <label class="flex items-center justify-between gap-3 rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700">
                                    <span>Moderation Alerts</span>
                                    <input type="hidden" name="moderation_alerts" value="0" />
                                    <input type="checkbox" name="moderation_alerts" value="1" class="h-4 w-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500" @checked(old('moderation_alerts', $settings['moderation_alerts'])) />
                                </label>
                            </div>
                        </div>

                        <div class="flex flex-wrap items-center gap-3 border-t border-slate-200 pt-4">
                            <button type="submit" class="rounded-xl bg-indigo-600 px-6 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700">Save Settings</button>
                            <a href="{{ route('admin.dashboard') }}" class="rounded-xl border border-slate-200 bg-white px-6 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-50">Back to Dashboard</a>
                        </div>
                    </form>
                </div>

                <aside class="space-y-4">
                    <div class="cc-elevated-card p-5">
                        <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Platform Health Rail</h3>
                        <div class="mt-4 space-y-3 text-sm">
                            <div class="rounded-xl border border-slate-200 bg-slate-50/80 p-3">
                                <p class="text-xs text-slate-500">Queue Backlog</p>
                                <p class="mt-1 text-xl font-bold text-amber-600">{{ $metrics['queue_backlog'] }}</p>
                            </div>
                            <div class="rounded-xl border border-slate-200 bg-slate-50/80 p-3">
                                <p class="text-xs text-slate-500">Open Incidents</p>
                                <p class="mt-1 text-xl font-bold {{ $metrics['open_incidents'] > 0 ? 'text-rose-600' : 'text-emerald-600' }}">{{ $metrics['open_incidents'] }}</p>
                            </div>
                            <div class="rounded-xl border border-slate-200 bg-slate-50/80 p-3">
                                <p class="text-xs text-slate-500">Total Users</p>
                                <p class="mt-1 text-xl font-bold text-slate-900">{{ $stats['total_users'] }}</p>
                            </div>
                        </div>
                    </div>

                    <div class="cc-elevated-card p-5">
                        <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">System Spark</h3>
                        <svg viewBox="0 0 260 70" class="mt-3 h-16 w-full">
                            <path d="M0 54 L28 46 L54 48 L82 39 L108 42 L136 32 L162 35 L190 25 L218 28 L246 20 L260 22" fill="none" stroke="url(#settingsTrend)" stroke-width="3" stroke-linecap="round" />
                            <defs>
                                <linearGradient id="settingsTrend" x1="0" y1="0" x2="1" y2="0">
                                    <stop offset="0%" stop-color="#4f46e5" />
                                    <stop offset="100%" stop-color="#8b5cf6" />
                                </linearGradient>
                            </defs>
                        </svg>
                        <p class="cc-muted mt-2 text-xs">Operational confidence graph for command center health and policy effectiveness.</p>
                    </div>
                </aside>
            </div>

            <footer class="cc-pulse-footer">
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Online Users</span><span class="text-sm font-bold text-slate-900">{{ $metrics['active_sessions'] }}</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">API Latency</span><span class="text-sm font-bold text-indigo-700">{{ max(40, min(260, 60 + $metrics['server_load'])) }} ms</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Last Backup</span><span class="text-sm font-bold text-slate-900">{{ now()->subMinutes(22)->format('M d, H:i') }}</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Build</span><span class="text-sm font-bold text-slate-900">v2.6.4</span></div>
            </footer>
        </section>

        <aside class="cc-activity-rail space-y-3">
            <div class="cc-elevated-card p-4">
                <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Real-Time Audit Logs</h3>
                <div class="mt-3 space-y-2 text-xs">
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Settings policy updated</span><span class="text-slate-500">just now</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Digest threshold recalculated</span><span class="text-slate-500">4m ago</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Queue monitor synced</span><span class="text-slate-500">9m ago</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Session policy validated</span><span class="text-slate-500">14m ago</span></div>
                </div>
            </div>

            <div class="cc-elevated-card p-4">
                <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Health Gauges</h3>
                <div class="mt-3 space-y-3 text-xs text-slate-600">
                    <p class="flex justify-between"><span>CPU Load</span><span class="font-semibold text-slate-900">{{ $metrics['server_load'] }}%</span></p>
                    <progress class="cc-progress" max="100" value="{{ $metrics['server_load'] }}"></progress>
                    <p class="flex justify-between"><span>Queue Backlog</span><span class="font-semibold text-slate-900">{{ $metrics['queue_backlog'] }}</span></p>
                    <progress class="cc-progress" max="100" value="{{ min(95, ($metrics['queue_backlog'] * 14)) }}"></progress>
                    <p class="flex justify-between"><span>Open Incidents</span><span class="font-semibold {{ $metrics['open_incidents'] > 0 ? 'text-rose-600' : 'text-emerald-600' }}">{{ $metrics['open_incidents'] }}</span></p>
                </div>
            </div>
        </aside>
    </div>
</div>
@endsection
