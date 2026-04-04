@extends('layouts.app')

@section('content')
<div class="px-6 py-8">
    <!-- Page Header with Breadcrumbs -->
    <div class="mb-8">
        <!-- Breadcrumbs -->
        <div class="flex items-center text-sm mb-4">
            <a href="{{ route('dashboard') }}" class="text-gray-500 hover:text-gray-700">Dashboard</a>
            <span class="text-gray-400 mx-2">/</span>
            <span class="text-gray-900 font-medium">Admin</span>
        </div>
        
        <!-- Title Section -->
        <div>
            <h1 class="text-2xl font-bold text-gray-900">Admin Dashboard</h1>
            <p class="text-gray-600 mt-1">Platform-wide analytics and management overview</p>
        </div>
    </div>

    <!-- Key Metrics Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <!-- Total Users Card -->
        <div class="bg-white rounded-lg border border-gray-200 shadow hover:shadow-lg transition-shadow duration-200">
            <div class="p-6">
                <!-- Header with Icon -->
                <div class="flex items-center justify-between mb-4">
                    <div class="flex-1">
                        <p class="text-sm font-medium text-gray-600">Total Users</p>
                    </div>
                    <div class="w-12 h-12 bg-blue-50 rounded-lg flex items-center justify-center">
                        <i class="fas fa-users text-blue-600 text-lg"></i>
                    </div>
                </div>
                
                <!-- Main Metric -->
                <div class="mb-4">
                    <div class="text-3xl font-bold text-gray-900">{{ $stats['total_users'] }}</div>
                </div>
                
                <!-- Breakdown -->
                <div class="grid grid-cols-3 gap-2 pt-4 border-t border-gray-100">
                    <div>
                        <p class="text-xs text-gray-500">Admins</p>
                        <p class="text-sm font-semibold text-gray-900">{{ $stats['admins'] }}</p>
                    </div>
                    <div>
                        <p class="text-xs text-gray-500">Recruiters</p>
                        <p class="text-sm font-semibold text-gray-900">{{ $stats['recruiters'] }}</p>
                    </div>
                    <div>
                        <p class="text-xs text-gray-500">Seekers</p>
                        <p class="text-sm font-semibold text-gray-900">{{ $stats['job_seekers'] }}</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Total Jobs Card -->
        <div class="bg-white rounded-lg border border-gray-200 shadow hover:shadow-lg transition-shadow duration-200">
            <div class="p-6">
                <div class="flex items-center justify-between mb-4">
                    <div class="flex-1">
                        <p class="text-sm font-medium text-gray-600">Jobs Posted</p>
                    </div>
                    <div class="w-12 h-12 bg-emerald-50 rounded-lg flex items-center justify-center">
                        <i class="fas fa-briefcase text-emerald-600 text-lg"></i>
                    </div>
                </div>
                
                <div class="mb-4">
                    <div class="text-3xl font-bold text-gray-900">{{ $stats['total_jobs'] }}</div>
                </div>
                
                <div class="flex items-center justify-between pt-4 border-t border-gray-100">
                    <span class="text-xs text-gray-600">Active Right Now</span>
                    <span class="inline-flex items-center gap-1">
                        <span class="w-2 h-2 bg-emerald-500 rounded-full"></span>
                        <span class="text-sm font-semibold text-emerald-600">{{ $stats['active_jobs'] }}</span>
                    </span>
                </div>
            </div>
        </div>

        <!-- Total Applications Card -->
        <div class="bg-white rounded-lg border border-gray-200 shadow hover:shadow-lg transition-shadow duration-200">
            <div class="p-6">
                <div class="flex items-center justify-between mb-4">
                    <div class="flex-1">
                        <p class="text-sm font-medium text-gray-600">Applications</p>
                    </div>
                    <div class="w-12 h-12 bg-amber-50 rounded-lg flex items-center justify-center">
                        <i class="fas fa-file-alt text-amber-600 text-lg"></i>
                    </div>
                </div>
                
                <div class="mb-4">
                    <div class="text-3xl font-bold text-gray-900">{{ $stats['total_applications'] }}</div>
                </div>
                
                <div class="flex items-center justify-between pt-4 border-t border-gray-100">
                    <span class="text-xs text-gray-600">Pending Review</span>
                    <span class="inline-flex items-center gap-1">
                        <i class="fas fa-clock text-amber-500 text-xs"></i>
                        <span class="text-sm font-semibold text-amber-600">{{ $stats['pending_applications'] }}</span>
                    </span>
                </div>
            </div>
        </div>

        <!-- Quick Actions Card -->
        <div class="bg-white rounded-lg border border-gray-200 shadow hover:shadow-lg transition-shadow duration-200">
            <div class="p-6">
                <div class="flex items-center justify-between mb-4">
                    <div class="flex-1">
                        <p class="text-sm font-medium text-gray-600">Quick Actions</p>
                    </div>
                    <div class="w-12 h-12 bg-blue-50 rounded-lg flex items-center justify-center">
                        <i class="fas fa-zap text-blue-600 text-lg"></i>
                    </div>
                </div>
                
                <div class="space-y-2">
                    <a href="{{ route('admin.users.index') }}" class="flex items-center gap-2 px-3 py-2 bg-gray-50 hover:bg-blue-50 text-gray-700 hover:text-blue-600 rounded-md transition-colors duration-150 text-sm">
                        <i class="fas fa-users text-xs"></i>
                        <span>Manage Users</span>
                    </a>
                    <a href="{{ route('admin.jobs.index') }}" class="flex items-center gap-2 px-3 py-2 bg-gray-50 hover:bg-blue-50 text-gray-700 hover:text-blue-600 rounded-md transition-colors duration-150 text-sm">
                        <i class="fas fa-briefcase text-xs"></i>
                        <span>Review Jobs</span>
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Recent Activity Section -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Recent Users -->
        <div class="bg-white rounded-lg border border-gray-200 shadow overflow-hidden">
            <div class="px-6 py-5 border-b border-gray-100">
                <h3 class="text-base font-semibold text-gray-900">Recent Users</h3>
            </div>
            <div class="divide-y divide-gray-100">
                @forelse($recentUsers as $user)
                    <div class="px-6 py-4 hover:bg-gray-50 transition-colors duration-100">
                        <div class="flex items-start gap-3 mb-2">
                            <div class="w-8 h-8 bg-gradient-to-br from-blue-400 to-blue-600 rounded-full flex items-center justify-center flex-shrink-0">
                                <span class="text-xs font-semibold text-white">{{ substr($user->name, 0, 1) }}</span>
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="text-sm font-medium text-gray-900">{{ $user->name }}</p>
                                <p class="text-xs text-gray-500">{{ $user->email }}</p>
                            </div>
                        </div>
                        <div class="flex items-center justify-between mt-2">
                            <span class="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium
                                @if($user->role === 'admin') bg-red-50 text-red-700 border border-red-100
                                @elseif($user->role === 'recruiter') bg-blue-50 text-blue-700 border border-blue-100
                                @else bg-emerald-50 text-emerald-700 border border-emerald-100
                                @endif">
                                <i class="fas fa-circle text-xs"></i>
                                {{ ucfirst($user->role) }}
                            </span>
                            <a href="{{ route('admin.users.show', $user) }}" class="text-xs text-blue-600 hover:text-blue-700 font-medium">View</a>
                        </div>
                    </div>
                @empty
                    <div class="px-6 py-8 text-center">
                        <i class="fas fa-inbox text-gray-300 text-2xl mb-2"></i>
                        <p class="text-sm text-gray-500">No recent users</p>
                    </div>
                @endforelse
            </div>
        </div>

        <!-- Recent Jobs -->
        <div class="bg-white rounded-lg border border-gray-200 shadow overflow-hidden">
            <div class="px-6 py-5 border-b border-gray-100">
                <h3 class="text-base font-semibold text-gray-900">Recent Jobs</h3>
            </div>
            <div class="divide-y divide-gray-100">
                @forelse($recentJobs as $job)
                    <div class="px-6 py-4 hover:bg-gray-50 transition-colors duration-100">
                        <p class="text-sm font-medium text-gray-900 mb-1 truncate">{{ $job->title }}</p>
                        <p class="text-xs text-gray-500 mb-2">
                            <i class="fas fa-user-circle text-xs mr-1"></i>
                            {{ $job->recruiter->name ?? 'Unknown' }}
                        </p>
                        <div class="flex items-center justify-between">
                            <span class="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium
                                @if($job->status === 'open') bg-emerald-50 text-emerald-700 border border-emerald-100
                                @elseif($job->status === 'closed') bg-gray-50 text-gray-700 border border-gray-100
                                @else bg-red-50 text-red-700 border border-red-100
                                @endif">
                                <i class="fas fa-circle text-xs"></i>
                                {{ ucfirst($job->status) }}
                            </span>
                            <a href="{{ route('admin.jobs.show', $job) }}" class="text-xs text-blue-600 hover:text-blue-700 font-medium">Review</a>
                        </div>
                    </div>
                @empty
                    <div class="px-6 py-8 text-center">
                        <i class="fas fa-inbox text-gray-300 text-2xl mb-2"></i>
                        <p class="text-sm text-gray-500">No recent jobs</p>
                    </div>
                @endforelse
            </div>
        </div>

        <!-- Recent Applications -->
        <div class="bg-white rounded-lg border border-gray-200 shadow overflow-hidden">
            <div class="px-6 py-5 border-b border-gray-100">
                <h3 class="text-base font-semibold text-gray-900">Recent Applications</h3>
            </div>
            <div class="divide-y divide-gray-100">
                @forelse($recentApplications as $app)
                    <div class="px-6 py-4 hover:bg-gray-50 transition-colors duration-100">
                        <p class="text-sm font-medium text-gray-900 mb-1 truncate">{{ $app->job->title ?? 'N/A' }}</p>
                        <p class="text-xs text-gray-500 mb-2">{{ $app->user->name ?? 'Unknown' }}</p>
                        <span class="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium
                            @if($app->status === 'pending') bg-amber-50 text-amber-700 border border-amber-100
                            @elseif($app->status === 'accepted') bg-emerald-50 text-emerald-700 border border-emerald-100
                            @elseif($app->status === 'rejected') bg-red-50 text-red-700 border border-red-100
                            @elseif($app->status === 'shortlisted') bg-purple-50 text-purple-700 border border-purple-100
                            @else bg-gray-50 text-gray-700 border border-gray-100
                            @endif">
                            <i class="fas fa-circle text-xs"></i>
                            {{ ucfirst($app->status) }}
                        </span>
                    </div>
                @empty
                    <div class="px-6 py-8 text-center">
                        <i class="fas fa-inbox text-gray-300 text-2xl mb-2"></i>
                        <p class="text-sm text-gray-500">No recent applications</p>
                    </div>
                @endforelse
            </div>
        </div>
    </div>
</div>
@endsection
