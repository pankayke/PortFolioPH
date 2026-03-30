@extends('layouts.app')

@section('title', 'Update Application Status')

@section('content')
<div class="mb-8">
    <a href="{{ route('applications.show', $application) }}" class="text-blue-600 hover:text-blue-700 font-medium mb-4 inline-block">
        <i class="fas fa-arrow-left mr-2"></i>Back to Application
    </a>
    <h1 class="text-4xl font-bold text-gray-900">
        <i class="fas fa-edit mr-3 text-blue-600"></i>Update Application Status
    </h1>
</div>

<div class="max-w-2xl mx-auto bg-white rounded-lg shadow p-8">
    <!-- Application Summary -->
    <div class="mb-8 pb-8 border-b border-gray-200">
        <div class="grid grid-cols-2 gap-4">
            <div>
                <p class="text-gray-600 text-sm">Job Title</p>
                <p class="text-lg font-semibold text-gray-900">{{ $application->job->title }}</p>
            </div>
            <div>
                <p class="text-gray-600 text-sm">Applicant</p>
                <p class="text-lg font-semibold text-gray-900">{{ $application->user->name }}</p>
            </div>
            <div>
                <p class="text-gray-600 text-sm">Applied On</p>
                <p class="text-lg font-semibold text-gray-900">{{ $application->created_at->format('M d, Y') }}</p>
            </div>
            <div>
                <p class="text-gray-600 text-sm">Current Status</p>
                <span class="inline-block px-3 py-1 rounded-full text-sm font-medium
                    @if($application->status === 'accepted') bg-green-100 text-green-800
                    @elseif($application->status === 'rejected') bg-red-100 text-red-800
                    @elseif($application->status === 'shortlisted') bg-blue-100 text-blue-800
                    @else bg-yellow-100 text-yellow-800
                    @endif
                ">
                    {{ ucfirst($application->status) }}
                </span>
            </div>
        </div>
    </div>

    <!-- Status Update Form -->
    <form method="POST" action="{{ route('applications.update-status', $application) }}">
        @csrf
        @method('PUT')

        <div class="mb-8">
            <label for="status" class="block text-gray-700 font-bold mb-3">New Status</label>
            <div class="space-y-3">
                <div class="flex items-center p-4 border border-gray-200 rounded-lg hover:bg-blue-50 cursor-pointer"
                    onclick="document.getElementById('status_pending').click()">
                    <input type="radio" id="status_pending" name="status" value="pending" {{ $application->status === 'pending' ? 'checked' : '' }}
                        class="w-4 h-4 text-blue-600">
                    <label for="status_pending" class="ml-3 cursor-pointer flex-1">
                        <p class="font-medium text-gray-900">Pending</p>
                        <p class="text-sm text-gray-600">Application is pending review</p>
                    </label>
                </div>

                <div class="flex items-center p-4 border border-gray-200 rounded-lg hover:bg-blue-50 cursor-pointer"
                    onclick="document.getElementById('status_reviewed').click()">
                    <input type="radio" id="status_reviewed" name="status" value="reviewed" {{ $application->status === 'reviewed' ? 'checked' : '' }}
                        class="w-4 h-4 text-blue-600">
                    <label for="status_reviewed" class="ml-3 cursor-pointer flex-1">
                        <p class="font-medium text-gray-900">Reviewed</p>
                        <p class="text-sm text-gray-600">You have reviewed the application</p>
                    </label>
                </div>

                <div class="flex items-center p-4 border border-blue-200 rounded-lg hover:bg-blue-50 cursor-pointer"
                    onclick="document.getElementById('status_shortlisted').click()">
                    <input type="radio" id="status_shortlisted" name="status" value="shortlisted" {{ $application->status === 'shortlisted' ? 'checked' : '' }}
                        class="w-4 h-4 text-blue-600">
                    <label for="status_shortlisted" class="ml-3 cursor-pointer flex-1">
                        <p class="font-medium text-gray-900">Shortlisted</p>
                        <p class="text-sm text-gray-600">Promising candidate - move to next round</p>
                    </label>
                </div>

                <div class="flex items-center p-4 border border-gray-200 rounded-lg hover:bg-green-50 cursor-pointer"
                    onclick="document.getElementById('status_accepted').click()">
                    <input type="radio" id="status_accepted" name="status" value="accepted" {{ $application->status === 'accepted' ? 'checked' : '' }}
                        class="w-4 h-4 text-blue-600">
                    <label for="status_accepted" class="ml-3 cursor-pointer flex-1">
                        <p class="font-medium text-gray-900">Accepted</p>
                        <p class="text-sm text-gray-600">Offer acceptance - hire this candidate</p>
                    </label>
                </div>

                <div class="flex items-center p-4 border border-gray-200 rounded-lg hover:bg-red-50 cursor-pointer"
                    onclick="document.getElementById('status_rejected').click()">
                    <input type="radio" id="status_rejected" name="status" value="rejected" {{ $application->status === 'rejected' ? 'checked' : '' }}
                        class="w-4 h-4 text-blue-600">
                    <label for="status_rejected" class="ml-3 cursor-pointer flex-1">
                        <p class="font-medium text-gray-900">Rejected</p>
                        <p class="text-sm text-gray-600">Candidate does not meet requirements</p>
                    </label>
                </div>
            </div>
        </div>

        <!-- Form Actions -->
        <div class="flex space-x-3">
            <button type="submit" class="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition">
                <i class="fas fa-save mr-2"></i>Update Status
            </button>
            <a href="{{ route('applications.show', $application) }}" class="flex-1 bg-gray-600 hover:bg-gray-700 text-white font-bold py-3 px-4 rounded-lg transition text-center">
                <i class="fas fa-times mr-2"></i>Cancel
            </a>
        </div>
    </form>
</div>
@endsection
