@extends('layouts.app')

@section('content')
<div class="px-6 py-8">
    <!-- Page Header -->
    <div class="mb-8">
        <!-- Breadcrumbs -->
        <div class="flex items-center text-sm mb-4">
            <a href="{{ route('admin.dashboard') }}" class="text-gray-500 hover:text-gray-700">Admin</a>
            <span class="text-gray-400 mx-2">/</span>
            <span class="text-gray-900 font-medium">Jobs Moderation</span>
        </div>
        
        <!-- Title -->
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-2xl font-bold text-gray-900">Jobs Moderation</h1>
                <p class="text-gray-600 mt-1">Review and manage all job postings</p>
            </div>
            <div class="text-sm text-gray-500">
                {{ $jobs->total() }} total jobs
            </div>
        </div>
    </div>

    <!-- Jobs Table Card -->
    <div class="bg-white rounded-lg border border-gray-200 shadow overflow-hidden">
        <!-- Table -->
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Job Title</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Recruiter</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Status</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Applications</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Posted</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    @forelse($jobs as $job)
                        <tr class="hover:bg-blue-50 transition-colors duration-100">
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div class="w-2 h-2 {{ $job->status === 'open' ? 'bg-emerald-500' : 'bg-gray-300' }} rounded-full"></div>
                                    <p class="font-medium text-gray-900">{{ $job->title }}</p>
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <a href="{{ route('admin.users.show', $job->recruiter) }}" class="text-blue-600 hover:text-blue-700 text-sm font-medium">
                                    {{ $job->recruiter->name }}
                                </a>
                            </td>
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium
                                    @if($job->status === 'open') bg-emerald-50 text-emerald-700 border border-emerald-100
                                    @else bg-gray-50 text-gray-700 border border-gray-100
                                    @endif">
                                    <span class="w-1.5 h-1.5 rounded-full {{ $job->status === 'open' ? 'bg-emerald-500' : 'bg-gray-400' }}"></span>
                                    {{ ucfirst($job->status) }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-2">
                                    <span class="text-sm font-medium text-gray-900">{{ $job->applications->count() }}</span>
                                    <span class="text-xs text-gray-500">applications</span>
                                </div>
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-600">
                                {{ $job->created_at->format('M d, Y') }}
                            </td>
                            <td class="px-6 py-4">
                                <a href="{{ route('admin.jobs.show', $job) }}" class="inline-flex items-center gap-2 px-3 py-2 text-blue-600 hover:bg-blue-50 rounded-md transition-colors duration-150 text-sm font-medium">
                                    <i class="fas fa-arrow-right text-xs"></i>
                                    Review
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6">
                                <div class="px-6 py-12 text-center">
                                    <i class="fas fa-inbox text-gray-300 text-4xl mb-3 block"></i>
                                    <h3 class="text-gray-900 font-semibold mb-1">No jobs found</h3>
                                    <p class="text-gray-500 text-sm">There are no job postings to moderate at this time.</p>
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        @if($jobs->hasPages())
            <div class="px-6 py-5 border-t border-gray-100 bg-gray-50">
                {{ $jobs->links() }}
            </div>
        @endif
    </div>
</div>
@endsection
