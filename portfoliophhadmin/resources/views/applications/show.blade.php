@extends('layouts.app')

@section('title', 'Application Details')

@section('content')
<div class="mb-8">
    <a href="{{ route('applications.index') }}" class="text-blue-600 hover:text-blue-700 font-medium mb-4 inline-block">
        <i class="fas fa-arrow-left mr-2"></i>Back to Applications
    </a>
    <h1 class="text-4xl font-bold text-gray-900">
        <i class="fas fa-file-alt mr-3 text-blue-600"></i>Application Details
    </h1>
</div>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- Main Content -->
    <div class="lg:col-span-2">
        <!-- Application Info -->
        <div class="bg-white rounded-lg shadow p-6 mb-6">
            <div class="flex justify-between items-start mb-6">
                <div>
                    <h2 class="text-2xl font-bold text-gray-900">{{ $application->job->title }}</h2>
                    <p class="text-gray-600 mt-1">
                        <i class="fas fa-map-marker-alt mr-2"></i>{{ $application->job->location }}
                    </p>
                </div>
                <span class="px-4 py-2 rounded-full text-sm font-medium
                    @if($application->status === 'accepted') bg-green-100 text-green-800
                    @elseif($application->status === 'rejected') bg-red-100 text-red-800
                    @elseif($application->status === 'shortlisted') bg-blue-100 text-blue-800
                    @else bg-yellow-100 text-yellow-800
                    @endif
                ">
                    {{ ucfirst($application->status) }}
                </span>
            </div>

            <div class="grid grid-cols-2 gap-4 py-4 border-y border-gray-200 mb-6">
                <div>
                    <p class="text-gray-600 text-sm">Applied On</p>
                    <p class="text-gray-900 font-medium">{{ $application->created_at->format('M d, Y \a\t H:i') }}</p>
                </div>
                <div>
                    <p class="text-gray-600 text-sm">Job Type</p>
                    <p class="text-gray-900 font-medium">{{ ucfirst(str_replace('_', ' ', $application->job->job_type)) }}</p>
                </div>
                <div>
                    <p class="text-gray-600 text-sm">Salary Range</p>
                    <p class="text-gray-900 font-medium">
                        @if($application->job->salary_min && $application->job->salary_max)
                            ₱{{ number_format($application->job->salary_min) }} - ₱{{ number_format($application->job->salary_max) }}
                        @else
                            Not specified
                        @endif
                    </p>
                </div>
                <div>
                    <p class="text-gray-600 text-sm">Application Deadline</p>
                    <p class="text-gray-900 font-medium">{{ $application->job->deadline ? $application->job->deadline->format('M d, Y') : 'No deadline' }}</p>
                </div>
            </div>

            @if($application->cover_letter)
                <div class="mb-6">
                    <h3 class="text-xl font-bold text-gray-900 mb-3">Cover Letter</h3>
                    <div class="bg-gray-50 p-4 rounded-lg border border-gray-200">
                        <p class="text-gray-700 whitespace-pre-wrap">{{ $application->cover_letter }}</p>
                    </div>
                </div>
            @endif

            <!-- Applicant Info (for recruiters) -->
            @if(auth()->user()->role === 'recruiter')
                <div class="mt-6 pt-6 border-t border-gray-200">
                    <h3 class="text-lg font-bold text-gray-900 mb-4">Applicant Information</h3>
                    <div class="bg-blue-50 p-4 rounded-lg border border-blue-200">
                        <p class="text-gray-900 font-semibold">{{ $application->user->name }}</p>
                        <p class="text-gray-600">{{ $application->user->email }}</p>
                        <p class="text-gray-600 text-sm mt-2">
                            <i class="fas fa-user-tag mr-2"></i>
                            @if($application->user->role === 'job_seeker')
                                Job Seeker
                            @else
                                Recruiter
                            @endif
                        </p>
                    </div>
                </div>
            @endif
        </div>

        <!-- Status Update (Recruiter Only) -->
        @if(auth()->user()->role === 'recruiter' && auth()->user()->id === $application->job->recruiter_id)
            <div class="bg-white rounded-lg shadow p-6">
                <h3 class="text-xl font-bold text-gray-900 mb-4">Update Application Status</h3>
                <form method="POST" action="{{ route('applications.update-status', $application) }}">
                    @csrf
                    @method('PUT')
                    <div class="mb-4">
                        <label for="status" class="block text-gray-700 font-medium mb-2">Status</label>
                        <select id="status" name="status" required
                            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600">
                            <option value="pending" {{ $application->status === 'pending' ? 'selected' : '' }}>Pending</option>
                            <option value="reviewed" {{ $application->status === 'reviewed' ? 'selected' : '' }}>Reviewed</option>
                            <option value="shortlisted" {{ $application->status === 'shortlisted' ? 'selected' : '' }}>Shortlisted</option>
                            <option value="accepted" {{ $application->status === 'accepted' ? 'selected' : '' }}>Accepted</option>
                            <option value="rejected" {{ $application->status === 'rejected' ? 'selected' : '' }}>Rejected</option>
                        </select>
                    </div>
                    <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition">
                        <i class="fas fa-save mr-2"></i>Update Status
                    </button>
                </form>
            </div>
        @endif
    </div>

    <!-- Sidebar -->
    <div>
        <!-- Job Summary -->
        <div class="bg-white rounded-lg shadow p-6 mb-6">
            <h3 class="text-lg font-bold text-gray-900 mb-4">Job Summary</h3>
            <div class="mb-4">
                <p class="text-gray-600 text-sm">Description</p>
                <p class="text-gray-900 line-clamp-3">{{ $application->job->description }}</p>
            </div>
            @if($application->job->required_skills)
                <div>
                    <p class="text-gray-600 text-sm mb-2">Required Skills</p>
                    <div class="flex flex-wrap gap-1">
                        @foreach($application->job->required_skills as $skill)
                            <span class="bg-blue-100 text-blue-700 px-2 py-1 rounded-full text-xs">{{ $skill }}</span>
                        @endforeach
                    </div>
                </div>
            @endif
            <a href="{{ route('jobs.show', $application->job) }}" class="mt-4 block w-full text-center bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition">
                <i class="fas fa-eye mr-2"></i>View Job Posting
            </a>
        </div>

        <!-- Applicant Card (if viewing as job seeker) -->
        @if(auth()->user()->role === 'job_seeker' && auth()->user()->id === $application->user_id)
            <div class="bg-white rounded-lg shadow p-6 mb-6">
                <h3 class="text-lg font-bold text-gray-900 mb-4">Your Information</h3>
                <div class="text-center">
                    <i class="fas fa-user-circle text-6xl text-gray-300 mb-3"></i>
                    <p class="text-lg font-semibold text-gray-900">{{ $application->user->name }}</p>
                    <p class="text-gray-600">{{ $application->user->email }}</p>
                </div>
            </div>
        @endif
    </div>
</div>
@endsection
