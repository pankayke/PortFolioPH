@extends('layouts.app')

@section('title', 'Dashboard')

@section('content')
<div class="-mx-4 min-h-screen bg-gray-50 px-4 py-6 sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
    <div class="mx-auto max-w-7xl space-y-4">
        <header class="rounded-xl border border-gray-200 bg-white shadow-sm">
            <div class="flex items-center justify-between px-4 py-4">
                <div>
                    <h1 class="text-xl font-semibold text-gray-900">
                        {{ auth()->user()->role === 'recruiter' ? 'Jobs & Opportunities' : 'Dashboard' }}
                    </h1>
                    <p class="mt-1 text-sm text-gray-500">Welcome back, {{ auth()->user()->name }}.</p>
                </div>
                <span class="inline-flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 bg-gray-50 text-gray-500">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 7.5A2.5 2.5 0 015.5 5h13A2.5 2.5 0 0121 7.5v9A2.5 2.5 0 0118.5 19h-13A2.5 2.5 0 013 16.5v-9z" />
                        <path stroke-linecap="round" stroke-linejoin="round" d="M7.5 9.5h9M7.5 13.5h5" />
                    </svg>
                </span>
            </div>
            <div class="border-t border-gray-200"></div>
        </header>

        @if(auth()->user()->role === 'recruiter')
            <section class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
                <p class="text-sm text-gray-500">Track your hiring pipeline at a glance.</p>
                <div class="mt-3 flex flex-wrap gap-2">
                    <span class="inline-flex items-center rounded-md bg-gray-100 px-2.5 py-1 text-xs font-medium text-gray-700">PortfolioPH Hiring Desk</span>
                    <span class="inline-flex items-center rounded-md bg-gray-100 px-2.5 py-1 text-xs font-medium text-gray-700">{{ $pendingApplications }} new applicants</span>
                    <span class="inline-flex items-center rounded-md bg-gray-100 px-2.5 py-1 text-xs font-medium text-gray-700">{{ $openJobs }} active jobs</span>
                </div>
            </section>

            <section class="grid grid-cols-2 gap-4">
                <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
                    <div class="mb-3 inline-flex h-8 w-8 items-center justify-center rounded-lg bg-blue-50 text-blue-600">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M4 7.5A2.5 2.5 0 016.5 5h11A2.5 2.5 0 0120 7.5v9A2.5 2.5 0 0117.5 19h-11A2.5 2.5 0 014 16.5v-9z" />
                        </svg>
                    </div>
                    <p class="text-2xl font-bold text-gray-900">{{ $totalJobs }}</p>
                    <p class="mt-1 text-sm text-gray-500">Total Jobs</p>
                </div>

                <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
                    <div class="mb-3 inline-flex h-8 w-8 items-center justify-center rounded-lg bg-green-50 text-green-600">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M5 12l4 4L19 7" />
                        </svg>
                    </div>
                    <p class="text-2xl font-bold text-gray-900">{{ $openJobs }}</p>
                    <p class="mt-1 text-sm text-gray-500">Active Jobs</p>
                </div>

                <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
                    <div class="mb-3 inline-flex h-8 w-8 items-center justify-center rounded-lg bg-blue-50 text-blue-600">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M7 8h10M7 12h10M7 16h6" />
                            <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 5h15A1.5 1.5 0 0121 6.5v11a1.5 1.5 0 01-1.5 1.5h-15A1.5 1.5 0 013 17.5v-11A1.5 1.5 0 014.5 5z" />
                        </svg>
                    </div>
                    <p class="text-2xl font-bold text-gray-900">{{ $totalApplications }}</p>
                    <p class="mt-1 text-sm text-gray-500">Total Applications</p>
                </div>

                <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
                    <div class="mb-3 inline-flex h-8 w-8 items-center justify-center rounded-lg bg-yellow-50 text-yellow-600">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l2.5 1.5" />
                            <circle cx="12" cy="12" r="8" />
                        </svg>
                    </div>
                    <p class="text-2xl font-bold text-gray-900">{{ $pendingApplications }}</p>
                    <p class="mt-1 text-sm text-gray-500">Pending Review</p>
                </div>
            </section>
        @else
            <section class="grid grid-cols-2 gap-4">
                <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
                    <p class="text-2xl font-bold text-gray-900">{{ $totalApplications }}</p>
                    <p class="mt-1 text-sm text-gray-500">Jobs Applied</p>
                </div>
                <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
                    <p class="text-2xl font-bold text-gray-900">{{ $acceptedApplications }}</p>
                    <p class="mt-1 text-sm text-gray-500">Accepted</p>
                </div>
                <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
                    <p class="text-2xl font-bold text-gray-900">{{ $underReview }}</p>
                    <p class="mt-1 text-sm text-gray-500">Under Review</p>
                </div>
                <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
                    <p class="text-2xl font-bold text-gray-900">{{ $rejectedApplications }}</p>
                    <p class="mt-1 text-sm text-gray-500">Rejected</p>
                </div>
            </section>
        @endif

        <div class="grid grid-cols-1 gap-4 lg:grid-cols-3">
            <section class="lg:col-span-2 rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
                <div class="flex items-center justify-between">
                    <h2 class="text-base font-semibold text-gray-900">
                        @if(auth()->user()->role === 'recruiter')
                            Recent Applications
                        @else
                            My Recent Applications
                        @endif
                    </h2>
                </div>
                <div class="mt-4 border-t border-gray-200"></div>

                @if($recentApplications->isEmpty())
                    <div class="py-10 text-center">
                        <p class="text-sm text-gray-500">No applications yet.</p>
                    </div>
                @else
                    <div class="mt-3 overflow-x-auto">
                        <table class="w-full">
                            <thead>
                                <tr class="border-b border-gray-200 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                                    @if(auth()->user()->role === 'recruiter')
                                        <th class="px-2 py-2">Job</th>
                                        <th class="px-2 py-2">Applicant</th>
                                    @else
                                        <th class="px-2 py-2">Job Title</th>
                                    @endif
                                    <th class="px-2 py-2">Status</th>
                                    <th class="px-2 py-2">Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($recentApplications as $application)
                                    <tr class="border-b border-gray-100 text-sm text-gray-700 hover:bg-gray-50">
                                        @if(auth()->user()->role === 'recruiter')
                                            <td class="px-2 py-3">{{ $application->job->title }}</td>
                                            <td class="px-2 py-3">{{ $application->user->name }}</td>
                                        @else
                                            <td class="px-2 py-3">{{ $application->job->title }}</td>
                                        @endif
                                        <td class="px-2 py-3">
                                            <span class="inline-flex rounded-md px-2 py-1 text-xs font-medium
                                                @if($application->status === 'accepted') bg-green-50 text-green-700
                                                @elseif($application->status === 'rejected') bg-red-50 text-red-700
                                                @elseif($application->status === 'shortlisted') bg-blue-50 text-blue-700
                                                @else bg-yellow-50 text-yellow-700
                                                @endif
                                            ">
                                                {{ ucfirst($application->status) }}
                                            </span>
                                        </td>
                                        <td class="px-2 py-3 text-gray-500">{{ $application->created_at->format('M d, Y') }}</td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @endif
            </section>

            <aside class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
                <h2 class="text-base font-semibold text-gray-900">Quick Actions</h2>
                <p class="mt-1 text-sm text-gray-500">Common recruiter tasks.</p>
                <div class="mt-4 border-t border-gray-200"></div>

                <div class="mt-4 space-y-2">
                    @if(auth()->user()->role === 'recruiter')
                        <a href="{{ route('jobs.create') }}" class="inline-flex w-full items-center justify-center rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-blue-700">+ Post Job</a>
                        <a href="{{ route('jobs.index') }}" class="inline-flex w-full items-center justify-center rounded-lg border border-gray-200 bg-white px-4 py-2.5 text-sm font-medium text-gray-700 transition hover:bg-gray-50">Manage Jobs</a>
                        <a href="{{ route('applications.index') }}" class="inline-flex w-full items-center justify-center rounded-lg border border-gray-200 bg-white px-4 py-2.5 text-sm font-medium text-gray-700 transition hover:bg-gray-50">View Applications</a>
                    @else
                        <a href="{{ route('jobs.list') }}" class="inline-flex w-full items-center justify-center rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-blue-700">Browse Jobs</a>
                        <a href="{{ route('my-applications') }}" class="inline-flex w-full items-center justify-center rounded-lg border border-gray-200 bg-white px-4 py-2.5 text-sm font-medium text-gray-700 transition hover:bg-gray-50">My Applications</a>
                    @endif
                </div>
            </aside>
        </div>
    </div>
</div>
@endsection
