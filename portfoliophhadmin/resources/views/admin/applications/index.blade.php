@extends('layouts.app')

@section('content')
<div class="px-6 py-8">
    <!-- Page Header -->
    <div class="mb-8">
        <!-- Breadcrumbs -->
        <div class="flex items-center text-sm mb-4">
            <a href="{{ route('admin.dashboard') }}" class="text-gray-500 hover:text-gray-700">Admin</a>
            <span class="text-gray-400 mx-2">/</span>
            <span class="text-gray-900 font-medium">Applications</span>
        </div>
        
        <!-- Title -->
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-2xl font-bold text-gray-900">Applications Analytics</h1>
                <p class="text-gray-600 mt-1">Monitor and manage all job applications</p>
            </div>
        </div>
    </div>

    <!-- Status Overview Cards -->
    <div class="grid grid-cols-2 md:grid-cols-5 gap-4 mb-8">
        <!-- Total -->
        <div class="bg-white rounded-lg border border-gray-200 shadow p-4">
            <p class="text-xs font-medium text-gray-600 mb-2">Total</p>
            <p class="text-2xl font-bold text-gray-900">
                {{ $stats['pending'] + $stats['reviewed'] + $stats['shortlisted'] + $stats['accepted'] + $stats['rejected'] }}
            </p>
        </div>

        <!-- Pending -->
        <div class="bg-white rounded-lg border border-amber-200 shadow p-4">
            <div class="flex items-center justify-between mb-2">
                <p class="text-xs font-medium text-amber-600">Pending</p>
                <div class="w-2 h-2 bg-amber-500 rounded-full"></div>
            </div>
            <p class="text-2xl font-bold text-amber-600">{{ $stats['pending'] }}</p>
        </div>

        <!-- Reviewed -->
        <div class="bg-white rounded-lg border border-blue-200 shadow p-4">
            <div class="flex items-center justify-between mb-2">
                <p class="text-xs font-medium text-blue-600">Reviewed</p>
                <div class="w-2 h-2 bg-blue-500 rounded-full"></div>
            </div>
            <p class="text-2xl font-bold text-blue-600">{{ $stats['reviewed'] }}</p>
        </div>

        <!-- Shortlisted -->
        <div class="bg-white rounded-lg border border-purple-200 shadow p-4">
            <div class="flex items-center justify-between mb-2">
                <p class="text-xs font-medium text-purple-600">Shortlisted</p>
                <div class="w-2 h-2 bg-purple-500 rounded-full"></div>
            </div>
            <p class="text-2xl font-bold text-purple-600">{{ $stats['shortlisted'] }}</p>
        </div>

        <!-- Accepted -->
        <div class="bg-white rounded-lg border border-emerald-200 shadow p-4">
            <div class="flex items-center justify-between mb-2">
                <p class="text-xs font-medium text-emerald-600">Accepted</p>
                <div class="w-2 h-2 bg-emerald-500 rounded-full"></div>
            </div>
            <p class="text-2xl font-bold text-emerald-600">{{ $stats['accepted'] }}</p>
        </div>
    </div>

    <!-- Applications Table Card -->
    <div class="bg-white rounded-lg border border-gray-200 shadow overflow-hidden">
        <!-- Table -->
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Job Title</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Applicant</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Email</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Status</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Applied</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    @forelse($applications as $app)
                        <tr class="hover:bg-blue-50 transition-colors duration-100">
                            <td class="px-6 py-4">
                                <p class="font-medium text-gray-900">{{ $app->job->title ?? 'N/A' }}</p>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-2">
                                    <div class="w-8 h-8 bg-gradient-to-br from-blue-400 to-blue-600 rounded-full flex items-center justify-center flex-shrink-0">
                                        <span class="text-xs font-semibold text-white">{{ substr($app->user->name ?? 'U', 0, 1) }}</span>
                                    </div>
                                    <p class="text-sm text-gray-900">{{ $app->user->name ?? 'Unknown' }}</p>
                                </div>
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-600">{{ $app->user->email ?? 'N/A' }}</td>
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium
                                    @if($app->status === 'pending') bg-amber-50 text-amber-700 border border-amber-100
                                    @elseif($app->status === 'reviewed') bg-blue-50 text-blue-700 border border-blue-100
                                    @elseif($app->status === 'shortlisted') bg-purple-50 text-purple-700 border border-purple-100
                                    @elseif($app->status === 'accepted') bg-emerald-50 text-emerald-700 border border-emerald-100
                                    @else bg-gray-50 text-gray-700 border border-gray-100
                                    @endif">
                                    <span class="w-1.5 h-1.5 rounded-full 
                                        @if($app->status === 'pending') bg-amber-500
                                        @elseif($app->status === 'reviewed') bg-blue-500
                                        @elseif($app->status === 'shortlisted') bg-purple-500
                                        @elseif($app->status === 'accepted') bg-emerald-500
                                        @else bg-gray-400
                                        @endif"></span>
                                    {{ ucfirst(str_replace('_', ' ', $app->status)) }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-600">
                                {{ $app->created_at->format('M d, Y') }}
                            </td>
                            <td class="px-6 py-4">
                                <a href="{{ route('admin.applications.index') }}" class="inline-flex items-center gap-1 px-3 py-2 text-blue-600 hover:bg-blue-50 rounded-md transition-colors duration-150 text-xs font-medium">
                                    <i class="fas fa-arrow-right text-xs"></i>
                                    View
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6">
                                <div class="px-6 py-12 text-center">
                                    <i class="fas fa-inbox text-gray-300 text-4xl mb-3 block"></i>
                                    <h3 class="text-gray-900 font-semibold mb-1">No applications yet</h3>
                                    <p class="text-gray-500 text-sm">Once users apply for jobs, they will appear here.</p>
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        @if($applications->hasPages())
            <div class="px-6 py-5 border-t border-gray-100 bg-gray-50">
                {{ $applications->links() }}
            </div>
        @endif
    </div>
</div>
@endsection
