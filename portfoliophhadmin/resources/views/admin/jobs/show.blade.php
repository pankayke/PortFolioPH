@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <!-- Job Header -->
    <div class="mb-8 flex justify-between items-start">
        <div>
            <h1 class="text-4xl font-bold text-gray-900">{{ $job->title }}</h1>
            <p class="text-gray-600 mt-2">Posted by {{ $job->recruiter->name }}</p>
            <div class="flex gap-2 mt-3">
                <span class="px-3 py-1 rounded-full text-sm font-medium @if($job->status === 'open') bg-green-100 text-green-800 @else bg-red-100 text-red-800 @endif">
                    {{ ucfirst($job->status) }}
                </span>
            </div>
        </div>

        <!-- Admin Actions -->
        <div class="flex gap-2">
            @if($job->status === 'open')
                <form method="POST" action="{{ route('admin.jobs.suspend', $job) }}" class="inline">
                    @csrf
                    <button class="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 flex items-center gap-2">
                        <i class="fas fa-ban"></i> Close Job
                    </button>
                </form>
            @else
                <form method="POST" action="{{ route('admin.jobs.approve', $job) }}" class="inline">
                    @csrf
                    <button class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 flex items-center gap-2">
                        <i class="fas fa-check"></i> Reopen Job
                    </button>
                </form>
            @endif
            <form method="POST" action="{{ route('admin.jobs.delete', $job) }}" class="inline" onclick="return confirm('This will delete the job and all applications.')">
                @csrf
                @method('DELETE')
                <button class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 flex items-center gap-2">
                    <i class="fas fa-trash"></i> Delete
                </button>
            </form>
        </div>
    </div>

    <div class="grid grid-cols-3 gap-6">
        <!-- Job Details -->
        <div class="col-span-2">
            <!-- Job Information -->
            <div class="bg-white rounded-lg shadow p-6 mb-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">Job Details</h3>
                
                <div class="space-y-4">
                    <div>
                        <p class="text-sm text-gray-600">Description</p>
                        <p class="text-gray-900 mt-1">{{ $job->description }}</p>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <p class="text-sm text-gray-600">Location</p>
                            <p class="text-gray-900 font-medium">{{ $job->location }}</p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-600">Job Type</p>
                            <p class="text-gray-900 font-medium">{{ ucfirst($job->job_type) }}</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <p class="text-sm text-gray-600">Salary Range</p>
                            <p class="text-gray-900 font-medium">{{number_format($job->salary_min)}} - {{ number_format($job->salary_max) }}</p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-600">Deadline</p>
                            <p class="text-gray-900 font-medium">{{ $job->deadline->format('M d, Y') }}</p>
                        </div>
                    </div>

                    <div>
                        <p class="text-sm text-gray-600">Required Skills</p>
                        <div class="flex gap-2 mt-2 flex-wrap">
                            @foreach(is_array($job->required_skills) ? $job->required_skills : explode(',', $job->required_skills) as $skill)
                                <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm">
                                    {{ trim($skill) }}
                                </span>
                            @endforeach
                        </div>
                    </div>
                </div>
            </div>

            <!-- Applications -->
            <div class="bg-white rounded-lg shadow overflow-hidden">
                <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
                    <h3 class="text-lg font-semibold text-gray-900">Applications ({{ $applications->total() }})</h3>
                </div>
                <table class="w-full">
                    <thead class="bg-gray-50 border-b border-gray-200">
                        <tr>
                            <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Applicant</th>
                            <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Status</th>
                            <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Applied</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @forelse($applications as $app)
                            <tr class="hover:bg-gray-50">
                                <td class="px-6 py-4 text-sm font-medium text-gray-900">{{ $app->user->name }}</td>
                                <td class="px-6 py-4 text-sm">
                                    <span class="px-2 py-1 rounded-full text-xs @if($app->status === 'pending') bg-yellow-100 text-yellow-800 @elseif($app->status === 'accepted') bg-green-100 text-green-800 @else bg-gray-100 text-gray-800 @endif">
                                        {{ ucfirst($app->status) }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-600">{{ $app->created_at->format('M d, Y') }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="3" class="px-6 py-8 text-center text-gray-500">No applications yet</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
                <div class="px-6 py-4 border-t border-gray-200">
                    {{ $applications->links() }}
                </div>
            </div>
        </div>

        <!-- Sidebar -->
        <div>
            <!-- Recruiter Info -->
            <div class="bg-white rounded-lg shadow p-6 mb-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">Posted By</h3>
                <div>
                    <p class="font-medium text-gray-900">{{ $job->recruiter->name }}</p>
                    <p class="text-sm text-gray-600">{{ $job->recruiter->email }}</p>
                    <a href="{{ route('admin.users.show', $job->recruiter) }}" class="text-blue-600 hover:underline text-sm mt-2 inline-block">
                        View Recruiter Profile
                    </a>
                </div>
            </div>

            <!-- Job Stats -->
            <div class="bg-white rounded-lg shadow p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">Statistics</h3>
                <div class="space-y-3">
                    <div>
                        <p class="text-sm text-gray-600">Total Applications</p>
                        <p class="text-2xl font-bold text-gray-900">{{ $applications->total() }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600">Posted On</p>
                        <p class="text-gray-900">{{ $job->created_at->format('M d, Y') }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
