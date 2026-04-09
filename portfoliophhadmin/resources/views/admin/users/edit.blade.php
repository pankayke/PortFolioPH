@extends('layouts.app')

@section('content')
@include('admin.partials.command_center_styles')
@php
    $activeSessions = $user->active ? 1 : 0;
    $serverLoad = $user->role === 'admin' ? 74 : ($user->role === 'recruiter' ? 61 : 45);
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
                        Edit Session
                    </div>
                    <span class="text-xs font-semibold {{ $user->active ? 'text-emerald-600' : 'text-slate-500' }}">{{ $user->active ? 'Active' : 'Paused' }}</span>
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
                    <a href="{{ route('admin.users.index') }}" class="cc-muted hover:text-slate-700">Users</a>
                    <span class="mx-2 text-slate-400">/</span>
                    <span class="font-medium text-slate-900">Edit</span>
                </div>
                <h1 class="text-3xl font-extrabold text-slate-900">Edit User Profile</h1>
                <p class="cc-muted mt-1 text-sm">Action layer with focused fields, dense metadata, and inline validation feedback.</p>
            </header>

            <div class="cc-elevated-card p-5 md:p-6">
                <form method="POST" action="{{ route('admin.users.update', $user) }}" class="space-y-5">
                    @csrf
                    @method('PUT')

                    <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
                        <div>
                            <label for="name" class="mb-2 block text-sm font-semibold text-slate-700">Name</label>
                            <div class="relative">
                                <input type="text" id="name" name="name" value="{{ old('name', $user->name) }}" class="cc-field pr-10 @error('name') cc-field-error @enderror" />
                                <svg class="cc-inline-icon absolute right-3 top-1/2 -translate-y-1/2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 5v14M5 12h14" /></svg>
                            </div>
                            @error('name')
                                <p class="mt-1 text-xs font-medium text-rose-600">{{ $message }}</p>
                            @enderror
                        </div>

                        <div>
                            <label for="email" class="mb-2 block text-sm font-semibold text-slate-700">Email</label>
                            <div class="relative">
                                <input type="email" id="email" name="email" value="{{ old('email', $user->email) }}" class="cc-field pr-10 @error('email') cc-field-error @enderror" />
                                <svg class="cc-inline-icon absolute right-3 top-1/2 -translate-y-1/2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 6h16v12H4z" /><path d="m4 8 8 6 8-6" /></svg>
                            </div>
                            @error('email')
                                <p class="mt-1 text-xs font-medium text-rose-600">{{ $message }}</p>
                            @enderror
                        </div>
                    </div>

                    <div>
                        <label for="role" class="mb-2 block text-sm font-semibold text-slate-700">Role</label>
                        <div class="relative max-w-xl">
                            <select id="role" name="role" class="cc-field pr-10 @error('role') cc-field-error @enderror">
                                <option value="admin" @selected(old('role', $user->role) === 'admin')>Admin (Platform Management)</option>
                                <option value="recruiter" @selected(old('role', $user->role) === 'recruiter')>Recruiter (Post Jobs)</option>
                                <option value="job_seeker" @selected(old('role', $user->role) === 'job_seeker')>Job Seeker (Apply for Jobs)</option>
                            </select>
                            <svg class="cc-inline-icon absolute right-3 top-1/2 -translate-y-1/2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="m6 9 6 6 6-6" /></svg>
                        </div>
                        @error('role')
                            <p class="mt-1 text-xs font-medium text-rose-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="rounded-2xl border border-indigo-100 bg-indigo-50/80 p-4 text-sm text-slate-700">
                        <p class="font-semibold text-indigo-700">Role Management Notes</p>
                        <ul class="mt-2 list-disc space-y-1 pl-5 text-sm">
                            <li>Changing Recruiter to Job Seeker closes recruiter jobs automatically.</li>
                            <li>Admin has full command access to moderation tools.</li>
                            <li>Recruiters can post and manage openings.</li>
                            <li>Job Seekers can apply and track applications.</li>
                        </ul>
                    </div>

                    <div class="rounded-2xl border border-slate-200 bg-slate-50/85 p-4 text-sm text-slate-700">
                        <p><span class="font-semibold">Current Status:</span> <span class="cc-glass-chip ml-2 {{ $user->active ? 'border-emerald-200 bg-emerald-50/90 text-emerald-700' : 'border-slate-200 bg-slate-100/90 text-slate-700' }}">{{ $user->active ? 'Active' : 'Suspended' }}</span></p>
                        <p class="mt-2 text-xs text-slate-500">Use the suspend action on this user profile to change account availability.</p>
                    </div>

                    <div class="flex flex-wrap items-center gap-3 border-t border-slate-200 pt-4">
                        <button type="submit" class="rounded-xl bg-indigo-600 px-6 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700">Save Changes</button>
                        <a href="{{ route('admin.users.show', $user) }}" class="rounded-xl border border-slate-200 bg-white px-6 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-50">Cancel</a>
                    </div>
                </form>
            </div>
        </section>
    </div>
</div>
@endsection
