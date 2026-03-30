@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <!-- Admin Header -->
    <div class="mb-8">
        <h1 class="text-4xl font-bold text-gray-900 mb-2">Admin Dashboard</h1>
        <p class="text-gray-600">Platform-wide analytics and management</p>
    </div>

    <!-- Statistics Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <!-- Users Stats -->
        <div class="bg-white rounded-lg shadow p-6">
            <div class="text-gray-600 text-sm font-medium">Total Users</div>
            <div class="text-3xl font-bold text-gray-900 mt-2">{{ $stats['total_users'] }}</div>
            <div class="text-xs text-gray-500 mt-2">
                <span class="badge badge-primary">{{ $stats['admins'] }} admins</span>
                <span class="badge badge-info">{{ $stats['recruiters'] }} recruiters</span>
                <span class="badge badge-success">{{ $stats['job_seekers'] }} seekers</span>
            </div>
        </div>

        <!-- Jobs Stats -->
        <div class="bg-white rounded-lg shadow p-6">
            <div class="text-gray-600 text-sm font-medium">Jobs Posted</div>
            <div class="text-3xl font-bold text-gray-900 mt-2">{{ $stats['total_jobs'] }}</div>
            <div class="text-xs text-green-600 mt-2">
                <i class="fas fa-check-circle"></i> {{ $stats['active_jobs'] }} active
            </div>
        </div>

        <!-- Applications Stats -->
        <div class="bg-white rounded-lg shadow p-6">
            <div class="text-gray-600 text-sm font-medium">Applications</div>
            <div class="text-3xl font-bold text-gray-900 mt-2">{{ $stats['total_applications'] }}</div>
            <div class="text-xs text-yellow-600 mt-2">
                <i class="fas fa-hourglass-half"></i> {{ $stats['pending_applications'] }} pending
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="bg-white rounded-lg shadow p-6">
            <div class="text-gray-600 text-sm font-medium">Quick Actions</div>
            <div class="flex gap-2 mt-4">
                <a href="{{ route('admin.users') }}" class="text-blue-600 hover:underline text-xs">Manage Users</a>
                <a href="{{ route('admin.jobs') }}" class="text-blue-600 hover:underline text-xs">Review Jobs</a>
            </div>
        </div>
    </div>

    <!-- Recent Activity Section -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Recent Users -->
        <div class="bg-white rounded-lg shadow">
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-semibold text-gray-900">Recent Users</h3>
            </div>
            <div class="divide-y">
                @foreach($recentUsers as $user)
                    <div class="px-6 py-3 hover:bg-gray-50">
                        <div class="flex justify-between items-center">
                            <div>
                                <p class="text-sm font-medium text-gray-900">{{ $user->name }}</p>
                                <p class="text-xs text-gray-500">{{ $user->email }}</p>
                            </div>
                            <span class="text-xs px-2 py-1 rounded-full @if($user->role === 'admin') bg-red-100 text-red-800 @elseif($user->role === 'recruiter') bg-blue-100 text-blue-800 @else bg-green-100 text-green-800 @endif">
                                {{ ucfirst($user->role) }}
                            </span>
                        </div>
                        <a href="{{ route('admin.users.show', $user) }}" class="text-xs text-blue-600 hover:underline mt-1 inline-block">View</a>
                    </div>
                @endforeach
            </div>
        </div>

        <!-- Recent Jobs -->
        <div class="bg-white rounded-lg shadow">
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-semibold text-gray-900">Recent Jobs</h3>
            </div>
            <div class="divide-y">
                @foreach($recentJobs as $job)
                    <div class="px-6 py-3 hover:bg-gray-50">
                        <p class="text-sm font-medium text-gray-900">{{ $job->title }}</p>
                        <p class="text-xs text-gray-500">by {{ $job->recruiter->name ?? 'Unknown' }}</p>
                        <div class="flex justify-between items-center mt-1">
                            <span class="text-xs @if($job->status === 'open') text-green-600 @else text-red-600 @endif">
                                {{ ucfirst($job->status) }}
                            </span>
                            <a href="{{ route('admin.jobs.show', $job) }}" class="text-xs text-blue-600 hover:underline">Review</a>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>

        <!-- Recent Applications -->
        <div class="bg-white rounded-lg shadow">
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-semibold text-gray-900">Recent Applications</h3>
            </div>
            <div class="divide-y">
                @foreach($recentApplications as $app)
                    <div class="px-6 py-3 hover:bg-gray-50">
                        <p class="text-sm font-medium text-gray-900">{{ $app->job->title ?? 'N/A' }}</p>
                        <p class="text-xs text-gray-500">{{ $app->user->name ?? 'Unknown' }}</p>
                        <span class="text-xs px-2 py-1 rounded-full @if($app->status === 'pending') bg-yellow-100 text-yellow-800 @elseif($app->status === 'accepted') bg-green-100 text-green-800 @else bg-gray-100 text-gray-800 @endif mt-1 inline-block">
                            {{ ucfirst($app->status) }}
                        </span>
                    </div>
                @endforeach
            </div>
        </div>
    </div>
</div>
@endsection
