@extends('layouts.app')

@section('title', isset($job) ? 'Edit Job' : 'Post New Job')

@section('content')
<div class="mb-8">
    <a href="{{ route('jobs.index') }}" class="text-blue-600 hover:text-blue-700 font-medium mb-4 inline-block">
        <i class="fas fa-arrow-left mr-2"></i>Back to Jobs
    </a>
    <h1 class="text-4xl font-bold text-gray-900">
        @if(isset($job))
            <i class="fas fa-edit mr-3 text-blue-600"></i>Edit Job
        @else
            <i class="fas fa-plus mr-3 text-blue-600"></i>Post New Job
        @endif
    </h1>
</div>

<div class="max-w-4xl mx-auto bg-white rounded-lg shadow p-8">
    <form method="POST" action="{{ isset($job) ? route('jobs.update', $job) : route('jobs.store') }}">
        @csrf
        @if(isset($job))
            @method('PUT')
        @endif

        <!-- Job Title -->
        <div class="mb-6">
            <label for="title" class="block text-gray-700 font-bold mb-2">Job Title</label>
            <input type="text" id="title" name="title" value="{{ old('title', $job->title ?? '') }}"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('title') border-red-500 @enderror"
                placeholder="e.g., Senior Software Engineer" required>
            @error('title')
                <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
            @enderror
        </div>

        <!-- Job Description -->
        <div class="mb-6">
            <label for="description" class="block text-gray-700 font-bold mb-2">Job Description</label>
            <textarea id="description" name="description" rows="8"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('description') border-red-500 @enderror"
                placeholder="Describe the job, responsibilities, and requirements..." required>{{ old('description', $job->description ?? '') }}</textarea>
            @error('description')
                <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
            @enderror
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <!-- Location -->
            <div>
                <label for="location" class="block text-gray-700 font-bold mb-2">Location</label>
                <input type="text" id="location" name="location" value="{{ old('location', $job->location ?? '') }}"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('location') border-red-500 @enderror"
                    placeholder="e.g., Manila, Philippines" required>
                @error('location')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Job Type -->
            <div>
                <label for="job_type" class="block text-gray-700 font-bold mb-2">Job Type</label>
                <select id="job_type" name="job_type"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('job_type') border-red-500 @enderror"
                    required>
                    <option value="">Select job type</option>
                    <option value="full_time" {{ old('job_type', $job->job_type ?? '') === 'full_time' ? 'selected' : '' }}>Full-Time</option>
                    <option value="part_time" {{ old('job_type', $job->job_type ?? '') === 'part_time' ? 'selected' : '' }}>Part-Time</option>
                    <option value="contract" {{ old('job_type', $job->job_type ?? '') === 'contract' ? 'selected' : '' }}>Contract</option>
                    <option value="freelance" {{ old('job_type', $job->job_type ?? '') === 'freelance' ? 'selected' : '' }}>Freelance</option>
                </select>
                @error('job_type')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <!-- Salary Min -->
            <div>
                <label for="salary_min" class="block text-gray-700 font-bold mb-2">Minimum Salary (₱)</label>
                <input type="number" id="salary_min" name="salary_min" value="{{ old('salary_min', $job->salary_min ?? '') }}"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('salary_min') border-red-500 @enderror"
                    placeholder="25000"
                    step="1000">
                @error('salary_min')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Salary Max -->
            <div>
                <label for="salary_max" class="block text-gray-700 font-bold mb-2">Maximum Salary (₱)</label>
                <input type="number" id="salary_max" name="salary_max" value="{{ old('salary_max', $job->salary_max ?? '') }}"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('salary_max') border-red-500 @enderror"
                    placeholder="100000"
                    step="1000">
                @error('salary_max')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Deadline -->
        <div class="mb-6">
            <label for="deadline" class="block text-gray-700 font-bold mb-2">Application Deadline</label>
            <input type="datetime-local" id="deadline" name="deadline" value="{{ old('deadline', $job->deadline ? $job->deadline->format('Y-m-d\TH:i') : '') }}"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('deadline') border-red-500 @enderror">
            @error('deadline')
                <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
            @enderror
        </div>

        <!-- Required Skills -->
        <div class="mb-6">
            <label for="required_skills" class="block text-gray-700 font-bold mb-2">Required Skills (comma-separated)</label>
            <textarea id="required_skills" name="required_skills" rows="3"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('required_skills') border-red-500 @enderror"
                placeholder="e.g., PHP, Laravel, MySQL, Vue.js">{{ old('required_skills', $job->required_skills ? implode(', ', $job->required_skills) : '') }}</textarea>
            @error('required_skills')
                <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
            @enderror
            <p class="text-gray-600 text-sm mt-1">Enter skills separated by commas</p>
        </div>

        <!-- Status (Edit only) -->
        @if(isset($job))
            <div class="mb-6">
                <label for="status" class="block text-gray-700 font-bold mb-2">Status</label>
                <select id="status" name="status"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('status') border-red-500 @enderror">
                    <option value="open" {{ $job->status === 'open' ? 'selected' : '' }}>Open</option>
                    <option value="closed" {{ $job->status === 'closed' ? 'selected' : '' }}>Closed</option>
                </select>
                @error('status')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>
        @endif

        <!-- Form Actions -->
        <div class="mt-8 flex space-x-3">
            <button type="submit" class="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition">
                <i class="fas fa-save mr-2"></i>{{ isset($job) ? 'Update Job' : 'Post Job' }}
            </button>
            <a href="{{ route('jobs.index') }}" class="flex-1 bg-gray-600 hover:bg-gray-700 text-white font-bold py-3 px-4 rounded-lg transition text-center">
                <i class="fas fa-times mr-2"></i>Cancel
            </a>
        </div>
    </form>
</div>
@endsection
