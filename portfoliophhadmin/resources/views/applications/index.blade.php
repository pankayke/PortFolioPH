@extends('layouts.app')

@section('title', 'Applications')

@section('content')
<div class="mb-8">
    <h1 class="text-4xl font-bold text-gray-900">
        <i class="fas fa-file-alt mr-3 text-blue-600"></i>Applications
    </h1>
    <p class="text-gray-600 mt-2">
        @if(auth()->user()->role === 'recruiter')
            Manage applications received for your posted jobs
        @else
            Track your job applications
        @endif
    </p>
</div>

@if(session('application_debug') && is_array(session('application_debug')))
    <div class="mb-6 rounded-lg border border-indigo-200 bg-indigo-50 p-4">
        <h2 class="text-sm font-semibold uppercase tracking-wide text-indigo-800">Application Debug (Latest Submit)</h2>
        <div class="mt-3 grid grid-cols-1 gap-2 text-sm text-indigo-900 sm:grid-cols-2 lg:grid-cols-3">
            <p><span class="font-medium">Application ID:</span> {{ session('application_debug.application_id') }}</p>
            <p><span class="font-medium">Job ID:</span> {{ session('application_debug.job_id') }}</p>
            <p><span class="font-medium">User ID:</span> {{ session('application_debug.user_id') }}</p>
            <p><span class="font-medium">Status:</span> {{ session('application_debug.status') }}</p>
            <p class="sm:col-span-2 lg:col-span-2"><span class="font-medium">Created At:</span> {{ session('application_debug.created_at') }}</p>
            <p><span class="font-medium">Saved:</span> yes</p>
        </div>
    </div>
@endif

<!-- Filters -->
<div class="mb-6 bg-white rounded-lg shadow p-4 flex flex-wrap gap-2 items-center">
    <form method="GET" action="{{ route('applications.index') }}" class="w-full flex flex-wrap gap-2">
        <select name="status" onchange="this.form.submit()" class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600">
            <option value="">All Status</option>
            <option value="pending" {{ request('status') === 'pending' ? 'selected' : '' }}>Pending</option>
            <option value="reviewed" {{ request('status') === 'reviewed' ? 'selected' : '' }}>Reviewed</option>
            <option value="shortlisted" {{ request('status') === 'shortlisted' ? 'selected' : '' }}>Shortlisted</option>
            <option value="accepted" {{ request('status') === 'accepted' ? 'selected' : '' }}>Accepted</option>
            <option value="rejected" {{ request('status') === 'rejected' ? 'selected' : '' }}>Rejected</option>
        </select>
    </form>
</div>

@if($applications->isEmpty())
    <div class="bg-white rounded-lg shadow p-12 text-center">
        <i class="fas fa-file-alt text-6xl text-gray-300 mb-4"></i>
        <p class="text-gray-500 text-lg">No applications found</p>
    </div>
@else
    <div class="bg-white rounded-lg shadow overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                        @if(auth()->user()->role === 'recruiter')
                            <th class="px-6 py-3 text-left text-sm font-medium text-gray-700">Job</th>
                            <th class="px-6 py-3 text-left text-sm font-medium text-gray-700">Applicant</th>
                        @else
                            <th class="px-6 py-3 text-left text-sm font-medium text-gray-700">Job Title</th>
                        @endif
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-700">Status</th>
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-700">Applied On</th>
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-700">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($applications as $application)
                        <tr class="border-b border-gray-200 hover:bg-gray-50 transition">
                            @if(auth()->user()->role === 'recruiter')
                                <td class="px-6 py-4 text-sm text-gray-900">
                                    <a href="{{ route('jobs.show', $application->job) }}" class="text-blue-600 hover:text-blue-700 font-medium">
                                        {{ $application->job->title }}
                                    </a>
                                </td>
                                <td class="px-6 py-4 text-sm">
                                    <div>
                                        <p class="font-medium text-gray-900">{{ $application->user->name }}</p>
                                        <p class="text-gray-600">{{ $application->user->email }}</p>
                                    </div>
                                </td>
                            @else
                                <td class="px-6 py-4 text-sm text-gray-900">
                                    <a href="{{ route('jobs.show', $application->job) }}" class="text-blue-600 hover:text-blue-700 font-medium">
                                        {{ $application->job->title }}
                                    </a>
                                </td>
                            @endif
                            <td class="px-6 py-4 text-sm">
                                <span class="px-3 py-1 rounded-full text-xs font-medium
                                    @if($application->status === 'accepted') bg-green-100 text-green-800
                                    @elseif($application->status === 'rejected') bg-red-100 text-red-800
                                    @elseif($application->status === 'shortlisted') bg-blue-100 text-blue-800
                                    @else bg-yellow-100 text-yellow-800
                                    @endif
                                ">
                                    {{ ucfirst($application->status) }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-600">
                                {{ $application->created_at->format('M d, Y') }}
                            </td>
                            <td class="px-6 py-4 text-sm space-x-2">
                                <a href="{{ route('applications.show', $application) }}" class="text-blue-600 hover:text-blue-700 font-medium">
                                    <i class="fas fa-eye mr-1"></i>View
                                </a>
                                @if(auth()->user()->role === 'recruiter')
                                    <a href="{{ route('applications.edit', $application) }}" class="text-gray-600 hover:text-gray-700 font-medium">
                                        <i class="fas fa-edit mr-1"></i>Update
                                    </a>
                                @endif
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    <!-- Pagination -->
    @if($applications->hasPages())
        <div class="mt-8">
            {{ $applications->links() }}
        </div>
    @endif
@endif
@endsection
