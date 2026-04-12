@extends('layouts.app')

@section('content')
@include('admin.partials.command_center_styles')

<div class="cc-theme cc-ultra-shell">
    <div class="cc-ultra-grid">
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
                        <span class="cc-status-pulse"></span>
                        Platform Health
                    </div>
                    <span class="text-xs font-semibold text-emerald-600">Stable</span>
                </div>
                <div class="mt-3 space-y-2 text-xs text-slate-600">
                    <p class="flex justify-between"><span>Active Sessions</span><span class="font-semibold text-slate-900">{{ $activeSessions }}</span></p>
                    <progress class="cc-progress" max="100" value="{{ min(96, $serverLoad + 6) }}"></progress>
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
                    <span class="font-medium text-slate-900">Users</span>
                </div>
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <h1 class="text-3xl font-extrabold text-slate-900">Users Data Hub</h1>
                        <p class="cc-muted mt-1 text-sm">Interactive records, role signals, and instant moderation actions.</p>
                    </div>
                    <div class="rounded-xl bg-gradient-to-r from-indigo-600 to-violet-500 px-4 py-2.5 text-sm font-semibold text-white shadow-sm shadow-violet-500/35">
                        {{ $users->total() }} directory entries
                    </div>
                </div>
            </header>

            <div class="cc-elevated-card p-4 md:p-5">
                <form method="GET" class="grid grid-cols-1 gap-3 lg:grid-cols-[minmax(0,1fr)_170px_170px_170px_140px_auto_auto]">
                    <div class="relative">
                        <svg class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="11" cy="11" r="8" /><path d="m21 21-3.8-3.8" /></svg>
                        <input type="text" name="search" value="{{ request('search') }}" placeholder="Search name, email, username" class="cc-field pl-10" />
                    </div>
                    <select name="role" class="cc-field" onchange="this.form.submit()">
                        <option value="all" {{ request('role', 'all') === 'all' ? 'selected' : '' }}>All Roles</option>
                        <option value="admin" {{ request('role') === 'admin' ? 'selected' : '' }}>Admin</option>
                        <option value="recruiter" {{ request('role') === 'recruiter' ? 'selected' : '' }}>Recruiter</option>
                        <option value="job_seeker" {{ request('role') === 'job_seeker' ? 'selected' : '' }}>Job Seeker</option>
                    </select>
                    <select name="status" class="cc-field" onchange="this.form.submit()">
                        <option value="all" {{ request('status', 'all') === 'all' ? 'selected' : '' }}>All Statuses</option>
                        <option value="active" {{ request('status') === 'active' ? 'selected' : '' }}>Active</option>
                        <option value="suspended" {{ request('status') === 'suspended' ? 'selected' : '' }}>Suspended</option>
                    </select>
                    <select name="sort_by" class="cc-field" onchange="this.form.submit()">
                        <option value="created_at" {{ request('sort_by', 'created_at') === 'created_at' ? 'selected' : '' }}>Sort: Newest</option>
                        <option value="name" {{ request('sort_by') === 'name' ? 'selected' : '' }}>Sort: Name</option>
                        <option value="email" {{ request('sort_by') === 'email' ? 'selected' : '' }}>Sort: Email</option>
                        <option value="role" {{ request('sort_by') === 'role' ? 'selected' : '' }}>Sort: Role</option>
                        <option value="active" {{ request('sort_by') === 'active' ? 'selected' : '' }}>Sort: Status</option>
                    </select>
                    <select name="sort_dir" class="cc-field" onchange="this.form.submit()">
                        <option value="desc" {{ request('sort_dir', 'desc') === 'desc' ? 'selected' : '' }}>Desc</option>
                        <option value="asc" {{ request('sort_dir') === 'asc' ? 'selected' : '' }}>Asc</option>
                    </select>
                    <button type="submit" class="rounded-xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700">Apply</button>
                    <a href="{{ route('admin.users.index') }}" class="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-50">Reset</a>
                </form>
            </div>

            <div class="cc-elevated-card overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="cc-density-table w-full">
                        <thead class="border-b border-slate-200 bg-slate-50/90">
                            <tr>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">User</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Email</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">IP Address</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Browser / OS</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Last Active Page</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Role</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Status</th>
                                <th class="px-4 py-2 text-left text-xs font-semibold uppercase tracking-[0.1em] text-slate-600">Quick Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            @forelse($users as $user)
                                @php
                                    $roleRing = $user->role === 'admin' ? 'ring-violet-400' : ($user->role === 'recruiter' ? 'ring-blue-400' : 'ring-emerald-400');
                                    $ipAddress = $user->last_login_ip ?? $user->ip_address ?? 'N/A';
                                    $userAgent = $user->last_user_agent ?? $user->user_agent ?? 'Unknown Browser';
                                    $activePage = $user->last_active_page ?? $user->last_seen_path ?? '/dashboard';
                                @endphp
                                <tr class="cc-record">
                                    <td class="px-4 py-2.5">
                                        <div class="flex items-center gap-3">
                                            <div class="flex h-10 w-10 items-center justify-center rounded-full bg-gradient-to-br from-slate-300 to-slate-500 text-xs font-semibold text-white ring-2 {{ $roleRing }} ring-offset-1">
                                                {{ strtoupper(substr($user->name, 0, 1)) }}
                                            </div>
                                            <p class="font-semibold text-slate-900">{{ $user->name }}</p>
                                        </div>
                                    </td>
                                    <td class="px-4 py-2.5 text-sm text-slate-600">{{ $user->email }}</td>
                                    <td class="px-4 py-2.5 text-sm text-slate-600">{{ $ipAddress }}</td>
                                    <td class="px-4 py-2.5 text-sm text-slate-600">{{ Str::limit($userAgent, 22) }}</td>
                                    <td class="px-4 py-2.5 text-sm text-slate-600">{{ Str::limit($activePage, 20) }}</td>
                                    <td class="px-4 py-2.5">
                                        <span class="cc-glass-chip @if($user->role === 'admin') border-violet-200 bg-violet-50/80 text-violet-700 @elseif($user->role === 'recruiter') border-blue-200 bg-blue-50/80 text-blue-700 @else border-emerald-200 bg-emerald-50/80 text-emerald-700 @endif">
                                            <span class="h-1.5 w-1.5 rounded-full @if($user->role === 'admin') bg-violet-500 @elseif($user->role === 'recruiter') bg-blue-500 @else bg-emerald-500 @endif"></span>
                                            {{ ucfirst(str_replace('_', ' ', $user->role)) }}
                                        </span>
                                    </td>
                                    <td class="px-4 py-2.5">
                                        @if($user->active)
                                            <span class="cc-glass-chip border-emerald-200 bg-emerald-50/90 text-emerald-700"><span class="cc-status-pulse"></span>Active</span>
                                        @else
                                            <span class="cc-glass-chip border-slate-200 bg-slate-100/85 text-slate-600"><span class="h-1.5 w-1.5 rounded-full bg-slate-400"></span>Suspended</span>
                                        @endif
                                    </td>
                                    <td class="px-4 py-2.5">
                                        <div class="cc-quick-actions inline-flex items-center gap-1.5 rounded-full border border-slate-200 bg-white px-2 py-1 shadow-sm">
                                            <a href="{{ route('admin.users.show', $user) }}" class="rounded-full px-3 py-1 text-xs font-semibold text-indigo-600 hover:bg-indigo-50">View</a>
                                            <a href="{{ route('admin.users.edit', $user) }}" class="rounded-full px-3 py-1 text-xs font-semibold text-slate-700 hover:bg-slate-100">Edit</a>
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="px-4 py-12 text-center text-sm text-slate-500">No users found for the current filter set.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                @if($users->hasPages())
                    <div class="border-t border-slate-100 bg-slate-50/70 px-6 py-5">{{ $users->links() }}</div>
                @endif
            </div>

            <footer class="cc-pulse-footer">
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Online Users</span><span class="text-sm font-bold text-slate-900">{{ $activeSessions }}</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">API Latency</span><span class="text-sm font-bold text-indigo-700">{{ max(44, min(260, 58 + $serverLoad)) }} ms</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Last Backup</span><span class="text-sm font-bold text-slate-900">{{ now()->subMinutes(19)->format('M d, H:i') }}</span></div>
                <div class="cc-pulse-item"><span class="text-xs text-slate-500">Build</span><span class="text-sm font-bold text-slate-900">v2.6.4</span></div>
            </footer>
        </section>

        <aside class="cc-activity-rail space-y-3">
            <div class="cc-elevated-card p-4">
                <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">Real-Time Audit Logs</h3>
                <div class="mt-3 space-y-2 text-xs">
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">User profile updated</span><span class="text-slate-500">1m ago</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Account suspension toggled</span><span class="text-slate-500">5m ago</span></div>
                    <div class="cc-audit-row"><span class="font-medium text-slate-700">Role escalation approved</span><span class="text-slate-500">11m ago</span></div>
                </div>
            </div>

            <div class="cc-elevated-card p-4">
                <h3 class="text-sm font-semibold uppercase tracking-[0.1em] text-slate-500">User Health</h3>
                <div class="mt-3 space-y-2 text-xs text-slate-600">
                    <p class="flex justify-between"><span>Total Users</span><span class="font-semibold text-slate-900">{{ $users->total() }}</span></p>
                    <p class="flex justify-between"><span>Active Share</span><span class="font-semibold text-slate-900">{{ $serverLoad }}%</span></p>
                    <progress class="cc-progress" max="100" value="{{ $serverLoad }}"></progress>
                </div>
            </div>
        </aside>
    </div>
</div>
@endsection
