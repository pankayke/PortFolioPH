@extends('layouts.app')

@section('title', 'Dashboard')

@section('content')
<div class="mb-8">
    <h1 class="text-4xl font-bold text-gray-900">
        <i class="fas fa-chart-line mr-3 text-blue-600"></i>Dashboard
    </h1>
    <p class="text-gray-600 mt-2">Welcome back, {{ auth()->user()->name }}!</p>
</div>

<!-- Statistics -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    @if(auth()->user()->role === 'recruiter')
        <div class="bg-white rounded-lg shadow p-6 border-l-4 border-blue-600">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm font-medium">Total Jobs Posted</p>
                    <p class="text-3xl font-bold text-gray-900">{{ $totalJobs }}</p>
                </div>
                <i class="fas fa-briefcase text-4xl text-blue-100"></i>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6 border-l-4 border-green-600">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm font-medium">Open Jobs</p>
                    <p class="text-3xl font-bold text-gray-900">{{ $openJobs }}</p>
                </div>
                <i class="fas fa-unlock text-4xl text-green-100"></i>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6 border-l-4 border-yellow-600">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm font-medium">Total Applications</p>
                    <p class="text-3xl font-bold text-gray-900">{{ $totalApplications }}</p>
                </div>
                <i class="fas fa-file-alt text-4xl text-yellow-100"></i>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6 border-l-4 border-purple-600">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm font-medium">Pending Review</p>
                    <p class="text-3xl font-bold text-gray-900">{{ $pendingApplications }}</p>
                </div>
                <i class="fas fa-clock text-4xl text-purple-100"></i>
            </div>
        </div>
    @else
        <div class="bg-white rounded-lg shadow p-6 border-l-4 border-blue-600">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm font-medium">Jobs Applied</p>
                    <p class="text-3xl font-bold text-gray-900">{{ $totalApplications }}</p>
                </div>
                <i class="fas fa-file-alt text-4xl text-blue-100"></i>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6 border-l-4 border-green-600">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm font-medium">Accepted</p>
                    <p class="text-3xl font-bold text-gray-900">{{ $acceptedApplications }}</p>
                </div>
                <i class="fas fa-check-circle text-4xl text-green-100"></i>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6 border-l-4 border-yellow-600">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm font-medium">Under Review</p>
                    <p class="text-3xl font-bold text-gray-900">{{ $underReview }}</p>
                </div>
                <i class="fas fa-hourglass-half text-4xl text-yellow-100"></i>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6 border-l-4 border-red-600">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-gray-600 text-sm font-medium">Rejected</p>
                    <p class="text-3xl font-bold text-gray-900">{{ $rejectedApplications }}</p>
                </div>
                <i class="fas fa-times-circle text-4xl text-red-100"></i>
            </div>
        </div>
    @endif
</div>

<!-- Quick Actions & Recent Activity -->
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <div class="lg:col-span-2">
        <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-2xl font-bold text-gray-900 mb-6">
                <i class="fas fa-list mr-2 text-blue-600"></i>
                @if(auth()->user()->role === 'recruiter')
                    Recent Applications
                @else
                    My Recent Applications
                @endif
            </h2>

            @if($recentApplications->isEmpty())
                <p class="text-gray-500 text-center py-8">No applications yet</p>
            @else
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50 border-b border-gray-200">
                            <tr>
                                @if(auth()->user()->role === 'recruiter')
                                    <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">Job</th>
                                    <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">Applicant</th>
                                @else
                                    <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">Job Title</th>
                                @endif
                                <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">Status</th>
                                <th class="px-4 py-2 text-left text-sm font-medium text-gray-700">Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($recentApplications as $application)
                                <tr class="border-b border-gray-200 hover:bg-gray-50">
                                    @if(auth()->user()->role === 'recruiter')
                                        <td class="px-4 py-3 text-sm text-gray-900">{{ $application->job->title }}</td>
                                        <td class="px-4 py-3 text-sm text-gray-900">{{ $application->user->name }}</td>
                                    @else
                                        <td class="px-4 py-3 text-sm text-gray-900">{{ $application->job->title }}</td>
                                    @endif
                                    <td class="px-4 py-3 text-sm">
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
                                    <td class="px-4 py-3 text-sm text-gray-600">{{ $application->created_at->format('M d, Y') }}</td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @endif
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-2xl font-bold text-gray-900 mb-6">
            <i class="fas fa-lightning-bolt mr-2 text-yellow-600"></i>Quick Actions
        </h2>

        <div class="space-y-3">
            @if(auth()->user()->role === 'recruiter')
                <a href="{{ route('jobs.create') }}" class="block w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition text-center">
                    <i class="fas fa-plus mr-2"></i>Post New Job
                </a>
                <a href="{{ route('jobs.index') }}" class="block w-full bg-gray-600 hover:bg-gray-700 text-white font-medium py-3 px-4 rounded-lg transition text-center">
                    <i class="fas fa-list mr-2"></i>View All Jobs
                </a>
                <a href="{{ route('applications.index') }}" class="block w-full bg-green-600 hover:bg-green-700 text-white font-medium py-3 px-4 rounded-lg transition text-center">
                    <i class="fas fa-file-alt mr-2"></i>View Applications
                </a>
            @else
                <a href="{{ route('jobs.list') }}" class="block w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition text-center">
                    <i class="fas fa-search mr-2"></i>Browse Jobs
                </a>
                <a href="{{ route('my-applications') }}" class="block w-full bg-gray-600 hover:bg-gray-700 text-white font-medium py-3 px-4 rounded-lg transition text-center">
                    <i class="fas fa-file-alt mr-2"></i>My Applications
                </a>
            @endif
        </div>
    </div>
</div>
@endsection
