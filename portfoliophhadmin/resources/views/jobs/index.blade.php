@extends('layouts.app')

@section('title', 'Jobs')

@section('content')
<div class="flex justify-between items-center mb-8">
    <h1 class="text-4xl font-bold text-gray-900">
        <i class="fas fa-briefcase mr-3 text-blue-600"></i>
        @if(auth()->user()->role === 'recruiter')
            My Jobs
        @else
            Browse Jobs
        @endif
    </h1>
    @if(auth()->user()->role === 'recruiter')
        <a href="{{ route('jobs.create') }}" class="bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-6 rounded-lg transition">
            <i class="fas fa-plus mr-2"></i>Post New Job
        </a>
    @endif
</div>

@if($jobs->isEmpty())
    <div class="bg-white rounded-lg shadow p-12 text-center">
        <i class="fas fa-briefcase text-6xl text-gray-300 mb-4"></i>
        <p class="text-gray-500 text-lg">No jobs found</p>
    </div>
@else
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        @foreach($jobs as $job)
            <div class="bg-white rounded-lg shadow hover:shadow-lg transition overflow-hidden">
                <div class="p-6">
                    <div class="flex justify-between items-start mb-4">
                        <div>
                            <h3 class="text-xl font-bold text-gray-900">{{ $job->title }}</h3>
                            <p class="text-gray-600 text-sm">
                                <i class="fas fa-user mr-2"></i>{{ $job->recruiter->name }}
                            </p>
                        </div>
                        <span class="px-3 py-1 rounded-full text-xs font-medium
                            @if($job->status === 'open') bg-green-100 text-green-800
                            @else bg-red-100 text-red-800
                            @endif
                        ">
                            {{ ucfirst($job->status) }}
                        </span>
                    </div>

                    <p class="text-gray-700 mb-4 line-clamp-2">{{ $job->description }}</p>

                    <div class="grid grid-cols-2 gap-4 mb-4 py-4 border-y border-gray-200">
                        <div>
                            <p class="text-gray-600 text-sm">Location</p>
                            <p class="text-gray-900 font-medium">{{ $job->location }}</p>
                        </div>
                        <div>
                            <p class="text-gray-600 text-sm">Job Type</p>
                            <p class="text-gray-900 font-medium">{{ ucfirst(str_replace('_', ' ', $job->job_type)) }}</p>
                        </div>
                        <div>
                            <p class="text-gray-600 text-sm">Salary</p>
                            <p class="text-gray-900 font-medium">
                                @if($job->salary_min && $job->salary_max)
                                    ₱{{ number_format($job->salary_min) }} - ₱{{ number_format($job->salary_max) }}
                                @else
                                    Not specified
                                @endif
                            </p>
                        </div>
                        <div>
                            <p class="text-gray-600 text-sm">Deadline</p>
                            <p class="text-gray-900 font-medium">{{ $job->deadline ? $job->deadline->format('M d, Y') : 'No deadline' }}</p>
                        </div>
                    </div>

                    @if($job->required_skills)
                        <div class="mb-4">
                            <p class="text-gray-600 text-sm mb-2">Required Skills</p>
                            <div class="flex flex-wrap gap-2">
                                @foreach($job->required_skills as $skill)
                                    <span class="bg-blue-100 text-blue-700 px-3 py-1 rounded-full text-xs">{{ $skill }}</span>
                                @endforeach
                            </div>
                        </div>
                    @endif

                    <div class="flex space-x-2">
                        <a href="{{ route('jobs.show', $job) }}" class="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition text-center">
                            <i class="fas fa-eye mr-2"></i>View Details
                        </a>
                        @if(auth()->user()->role === 'recruiter' && auth()->user()->id === $job->recruiter_id)
                            <a href="{{ route('jobs.edit', $job) }}" class="flex-1 bg-gray-600 hover:bg-gray-700 text-white font-medium py-2 px-4 rounded-lg transition text-center">
                                <i class="fas fa-edit mr-2"></i>Edit
                            </a>
                            <form method="POST" action="{{ route('jobs.destroy', $job) }}" onsubmit="return confirm('Are you sure?')" class="flex-1">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="w-full bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded-lg transition">
                                    <i class="fas fa-trash mr-2"></i>Delete
                                </button>
                            </form>
                        @endif
                    </div>
                </div>
            </div>
        @endforeach
    </div>

    <!-- Pagination -->
    @if($jobs->hasPages())
        <div class="mt-8">
            {{ $jobs->links() }}
        </div>
    @endif
@endif
@endsection
