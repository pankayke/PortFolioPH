@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <!-- User Header -->
    <div class="mb-8 flex justify-between items-start">
        <div>
            <h1 class="text-4xl font-bold text-gray-900">{{ $user->name }}</h1>
            <p class="text-gray-600 mt-2">{{ $user->email }}</p>
            <div class="flex gap-2 mt-3">
                <span class="px-3 py-1 rounded-full text-sm font-medium @if($user->role === 'admin') bg-red-100 text-red-800 @elseif($user->role === 'recruiter') bg-blue-100 text-blue-800 @else bg-green-100 text-green-800 @endif">
                    {{ ucfirst($user->role) }}
                </span>
                <span class="px-3 py-1 rounded-full text-sm font-medium @if($user->active) bg-green-100 text-green-800 @else bg-red-100 text-red-800 @endif">
                    {{ $user->active ? 'Active' : 'Suspended' }}
                </span>
            </div>
        </div>

        <!-- Admin Actions -->
        <div class="flex gap-2">
            <a href="{{ route('admin.users.edit', $user) }}" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 flex items-center gap-2">
                <i class="fas fa-edit"></i> Edit
            </a>
            @if($user->active)
                <form method="POST" action="{{ route('admin.users.suspend', $user) }}" class="inline">
                    @csrf
                    <button class="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 flex items-center gap-2">
                        <i class="fas fa-ban"></i> Suspend
                    </button>
                </form>
            @endif
            <form method="POST" action="{{ route('admin.users.delete', $user) }}" class="inline" onclick="return confirm('Are you sure? This will delete all user data.')">
                @csrf
                @method('DELETE')
                <button class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 flex items-center gap-2">
                    <i class="fas fa-trash"></i> Delete
                </button>
            </form>
        </div>
    </div>

    @if($user->role === 'recruiter')
        <!-- Recruiter: Job Management -->
        <div class="bg-white rounded-lg shadow overflow-hidden mb-8">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
                <h3 class="text-lg font-semibold text-gray-900">Posted Jobs ({{ $jobs->total() }})</h3>
                <p class="text-sm text-gray-600">When admin changes this recruiter's role or suspends their account, all jobs are automatically closed</p>
            </div>
            <table class="w-full">
                <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Job Title</th>
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Location</th>
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Status</th>
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Applications</th>
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @forelse($jobs as $job)
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 text-sm font-medium text-gray-900">{{ $job->title }}</td>
                            <td class="px-6 py-4 text-sm text-gray-600">{{ $job->location }}</td>
                            <td class="px-6 py-4 text-sm">
                                <span class="px-2 py-1 rounded-full text-xs @if($job->status === 'open') bg-green-100 text-green-800 @else bg-red-100 text-red-800 @endif">
                                    {{ ucfirst($job->status) }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-600">{{ $job->applications->count() }}</td>
                            <td class="px-6 py-4 text-sm">
                                <a href="{{ route('admin.jobs.show', $job) }}" class="text-blue-600 hover:underline">Review</a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="px-6 py-8 text-center text-gray-500">No jobs posted</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
            <div class="px-6 py-4 border-t border-gray-200">
                {{ $jobs->links() }}
            </div>
        </div>
    @else
        <!-- Job Seeker: Application Tracking -->
        <div class="bg-white rounded-lg shadow overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
                <h3 class="text-lg font-semibold text-gray-900">Applications ({{ $applications->total() }})</h3>
            </div>
            <table class="w-full">
                <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Job</th>
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Status</th>
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Applied</th>
                        <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    @forelse($applications as $app)
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 text-sm font-medium text-gray-900">{{ $app->job->title }}</td>
                            <td class="px-6 py-4 text-sm">
                                <span class="px-2 py-1 rounded-full text-xs @if($app->status === 'pending') bg-yellow-100 text-yellow-800 @elseif($app->status === 'accepted') bg-green-100 text-green-800 @else bg-gray-100 text-gray-800 @endif">
                                    {{ ucfirst($app->status) }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-600">{{ $app->created_at->format('M d, Y') }}</td>
                            <td class="px-6 py-4 text-sm">
                                <a href="#" class="text-blue-600 hover:underline">View</a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" class="px-6 py-8 text-center text-gray-500">No applications</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
            <div class="px-6 py-4 border-t border-gray-200">
                {{ $applications->links() }}
            </div>
        </div>
    @endif
</div>
@endsection
