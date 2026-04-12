@extends('layouts.app')

@section('title', $job->title)

@section('content')
<div class="mb-8">
    <a href="{{ route('jobs.index') }}" class="text-blue-600 hover:text-blue-700 font-medium mb-4 inline-block">
        <i class="fas fa-arrow-left mr-2"></i>Back to Jobs
    </a>
    <h1 class="text-4xl font-bold text-gray-900">{{ $job->title }}</h1>
    <p class="text-gray-600 mt-2">
        <i class="fas fa-user mr-2"></i>Posted by <strong>{{ $job->recruiter->name }}</strong>
    </p>
</div>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- Main Content -->
    <div class="lg:col-span-2">
        <div class="bg-white rounded-lg shadow p-6 mb-6">
            <div class="flex justify-between items-start mb-6">
                <div>
                    <h2 class="text-2xl font-bold text-gray-900">Job Details</h2>
                </div>
                <span class="px-4 py-2 rounded-full text-sm font-medium
                    @if($job->status === 'open') bg-green-100 text-green-800
                    @else bg-red-100 text-red-800
                    @endif
                ">
                    {{ ucfirst($job->status) }}
                </span>
            </div>

            <div class="prose max-w-none mb-8">
                <h3 class="text-xl font-bold text-gray-900 mb-3">Description</h3>
                <p class="text-gray-700 whitespace-pre-wrap">{{ $job->description }}</p>
            </div>

            <div class="grid grid-cols-2 gap-6 py-6 border-y border-gray-200 mb-6">
                <div>
                    <p class="text-gray-600 text-sm font-medium mb-1">Location</p>
                    <p class="text-gray-900 text-lg font-semibold">{{ $job->location }}</p>
                </div>
                <div>
                    <p class="text-gray-600 text-sm font-medium mb-1">Job Type</p>
                    <p class="text-gray-900 text-lg font-semibold">{{ ucfirst(str_replace('_', ' ', $job->job_type)) }}</p>
                </div>
                <div>
                    <p class="text-gray-600 text-sm font-medium mb-1">Salary Range</p>
                    <p class="text-gray-900 text-lg font-semibold">
                        @if($job->salary_min && $job->salary_max)
                            ₱{{ number_format($job->salary_min) }} - ₱{{ number_format($job->salary_max) }}
                        @else
                            Not specified
                        @endif
                    </p>
                </div>
                <div>
                    <p class="text-gray-600 text-sm font-medium mb-1">Deadline</p>
                    <p class="text-gray-900 text-lg font-semibold">{{ $job->deadline ? $job->deadline->format('M d, Y') : 'No deadline' }}</p>
                </div>
            </div>

            @if($job->required_skills)
                <div class="mb-6">
                    <h3 class="text-xl font-bold text-gray-900 mb-3">Required Skills</h3>
                    <div class="flex flex-wrap gap-2">
                        @foreach($job->required_skills as $skill)
                            <span class="bg-blue-100 text-blue-700 px-4 py-2 rounded-full text-sm font-medium">{{ $skill }}</span>
                        @endforeach
                    </div>
                </div>
            @endif

            @if(auth()->user()->role === 'recruiter' && auth()->user()->id === $job->recruiter_id)
                <div class="flex space-x-3 pt-6 border-t border-gray-200">
                    <a href="{{ route('jobs.edit', $job) }}" class="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition text-center">
                        <i class="fas fa-edit mr-2"></i>Edit Job
                    </a>
                    <form method="POST" action="{{ route('jobs.destroy', $job) }}" onsubmit="return confirm('Are you sure?')" class="flex-1">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="w-full bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded-lg transition">
                            <i class="fas fa-trash mr-2"></i>Delete Job
                        </button>
                    </form>
                </div>
            @endif
        </div>

        <!-- Applications Section -->
        @if(auth()->user()->role === 'recruiter' && auth()->user()->id === $job->recruiter_id)
            <div class="bg-white rounded-lg shadow p-6">
                <h2 class="text-2xl font-bold text-gray-900 mb-6">
                    <i class="fas fa-file-alt mr-2 text-blue-600"></i>Applications ({{ $applicationCount ?? $applications->total() }})
                </h2>

                @if($applications->isEmpty())
                    <p class="text-gray-500 text-center py-8">No applications yet</p>
                @else
                    <div class="space-y-4">
                        @foreach($applications as $application)
                            <div class="border border-gray-200 rounded-lg p-4 hover:bg-gray-50 transition">
                                <div class="flex justify-between items-start mb-2">
                                    <div>
                                        <h3 class="text-lg font-semibold text-gray-900">{{ $application->user->name }}</h3>
                                        <p class="text-gray-600 text-sm">{{ $application->user->email }}</p>
                                    </div>
                                    <span class="px-3 py-1 rounded-full text-xs font-medium
                                        @if($application->status === 'accepted') bg-green-100 text-green-800
                                        @elseif($application->status === 'rejected') bg-red-100 text-red-800
                                        @elseif($application->status === 'shortlisted') bg-blue-100 text-blue-800
                                        @else bg-yellow-100 text-yellow-800
                                        @endif
                                    ">
                                        {{ ucfirst($application->status) }}
                                    </span>
                                </div>
                                @if($application->cover_letter)
                                    <p class="text-gray-700 mb-3 line-clamp-2">{{ $application->cover_letter }}</p>
                                @endif
                                <div class="flex space-x-2">
                                    <a href="{{ route('applications.show', $application) }}" class="text-blue-600 hover:text-blue-700 font-medium text-sm">
                                        <i class="fas fa-eye mr-1"></i>View
                                    </a>
                                    <a href="{{ route('applications.edit', $application) }}" class="text-gray-600 hover:text-gray-700 font-medium text-sm">
                                        <i class="fas fa-edit mr-1"></i>Update Status
                                    </a>
                                </div>
                            </div>
                        @endforeach
                    </div>

                    <div class="mt-6">
                        {{ $applications->links() }}
                    </div>
                @endif
            </div>
        @else
            <!-- Job Seeker Apply Section -->
            @php
                $hasApplied = auth()->user()->applications()->where('job_id', $job->id)->exists();
            @endphp
            <div class="bg-white rounded-lg shadow p-6">
                @if($hasApplied)
                    <p class="text-green-600 font-medium">
                        <i class="fas fa-check-circle mr-2"></i>You have already applied for this job
                    </p>
                @else
                    <form method="POST" action="{{ route('applications.store') }}">
                        @csrf
                        <input type="hidden" name="job_id" value="{{ $job->id }}">
                        <div class="mb-4">
                            <label for="cover_letter" class="block text-gray-700 font-medium mb-2">Cover Letter</label>
                            <textarea id="cover_letter" name="cover_letter" rows="6"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600"
                                placeholder="Tell the recruiter why you're a great fit for this position..."></textarea>
                        </div>
                        <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition">
                            <i class="fas fa-paper-plane mr-2"></i>Submit Application
                        </button>
                    </form>
                @endif
            </div>
        @endif
    </div>

    <!-- Sidebar -->
    <div>
        <!-- Recruiter Info -->
        <div class="bg-white rounded-lg shadow p-6 mb-6">
            <h3 class="text-lg font-bold text-gray-900 mb-4">Posted By</h3>
            <div class="text-center">
                <i class="fas fa-user-circle text-6xl text-gray-300 mb-3"></i>
                <p class="text-lg font-semibold text-gray-900">{{ $job->recruiter->name }}</p>
                <p class="text-gray-600 text-sm">{{ $job->recruiter->email }}</p>
            </div>
        </div>

        <!-- Job Meta -->
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-bold text-gray-900 mb-4">Job Information</h3>
            <div class="space-y-4">
                <div>
                    <p class="text-gray-600 text-sm">Posted</p>
                    <p class="text-gray-900 font-medium">{{ $job->created_at->format('M d, Y') }}</p>
                </div>
                <div>
                    <p class="text-gray-600 text-sm">Applications</p>
                    <p class="text-gray-900 font-medium">{{ $applicationCount ?? $applications->total() }}</p>
                </div>
                @if(auth()->user()->role === 'recruiter' && auth()->user()->id === $job->recruiter_id)
                    <div>
                        <p class="text-gray-600 text-sm">Status</p>
                        <form method="POST" action="{{ route('jobs.update-status', $job) }}" class="mt-1">
                            @csrf
                            <select name="status" onchange="this.form.submit()" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600">
                                <option value="open" {{ $job->status === 'open' ? 'selected' : '' }}>Open</option>
                                <option value="closed" {{ $job->status === 'closed' ? 'selected' : '' }}>Closed</option>
                            </select>
                        </form>
                    </div>
                @endif
            </div>
        </div>
    </div>
</div>
@endsection
