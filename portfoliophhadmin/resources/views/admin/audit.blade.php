@extends('layouts.app')

@section('content')
@include('admin.partials.command_center_styles')

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

            <div class="cc-elevated-card overflow-hidden">
                <div class="border-b border-slate-200 bg-slate-50/90 px-5 py-4 flex justify-between items-center">
                    <h3 class="text-base font-semibold text-slate-900">System Audit Log</h3>
                    <span class="text-xs text-slate-500">{{ $auditLogs->total() }} records</span>
                </div>
                <div class="divide-y divide-slate-100">
                    <table class="w-full text-left text-sm text-slate-600">
                        <thead class="bg-slate-50 text-xs uppercase text-slate-500">
                            <tr>
                                <th class="px-5 py-3 font-semibold">User</th>
                                <th class="px-5 py-3 font-semibold">Action</th>
                                <th class="px-5 py-3 font-semibold">Resource</th>
                                <th class="px-5 py-3 font-semibold">IP Address</th>
                                <th class="px-5 py-3 font-semibold text-right">Time</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            @forelse($auditLogs as $log)
                                <tr class="hover:bg-slate-50/50 transition-colors">
                                    <td class="px-5 py-3">
                                        @if($log->user)
                                            <span class="font-medium text-slate-900">{{ $log->user->name }}</span>
                                            <div class="text-xs text-slate-500">{{ $log->user->email }}</div>
                                        @else
                                            <span class="text-slate-400">System / Deleted</span>
                                        @endif
                                    </td>
                                    <td class="px-5 py-3">
                                        <span class="inline-flex items-center rounded-full px-2 py-1 text-xs font-medium 
                                            @if($log->action === 'created') bg-emerald-100 text-emerald-700
                                            @elseif($log->action === 'updated') bg-amber-100 text-amber-700
                                            @elseif($log->action === 'deleted') bg-red-100 text-red-700
                                            @else bg-slate-100 text-slate-700 @endif">
                                            {{ ucfirst($log->action) }}
                                        </span>
                                    </td>
                                    <td class="px-5 py-3 text-xs">
                                        <span class="font-medium">{{ class_basename($log->model_type) }}</span> #{{ $log->model_id }}
                                    </td>
                                    <td class="px-5 py-3 text-xs text-slate-500">
                                        {{ $log->ip_address ?? 'N/A' }}
                                    </td>
                                    <td class="px-5 py-3 text-right text-xs text-slate-500 whitespace-nowrap">
                                        {{ $log->created_at->format('M d, Y H:i') }}
                                        <div class="text-slate-400">{{ $log->created_at->diffForHumans() }}</div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="5" class="px-5 py-8 text-center text-sm text-slate-500">
                                        No audit records found.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
                @if($auditLogs->hasPages())
                    <div class="border-t border-slate-200 px-5 py-4">
                        {{ $auditLogs->links() }}
                    </div>
                @endif
            </div>
        </section>
    </div>
</div>
@endsection
