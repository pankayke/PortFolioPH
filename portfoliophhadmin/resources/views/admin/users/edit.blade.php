@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8 max-w-2xl">
    <div class="mb-8">
        <h1 class="text-4xl font-bold text-gray-900">Edit User</h1>
        <p class="text-gray-600 mt-2">Update user information and role. Changes reflect immediately.</p>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <form method="POST" action="{{ route('admin.users.update', $user) }}">
            @csrf
            @method('PUT')

            <!-- Name Field -->
            <div class="mb-6">
                <label for="name" class="block text-gray-700 font-medium mb-2">Name</label>
                <input type="text" id="name" name="name" value="{{ old('name', $user->name) }}" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent @error('name') border-red-500 @enderror">
                @error('name')
                    <p class="text-red-600 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Email Field -->
            <div class="mb-6">
                <label for="email" class="block text-gray-700 font-medium mb-2">Email</label>
                <input type="email" id="email" name="email" value="{{ old('email', $user->email) }}" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent @error('email') border-red-500 @enderror">
                @error('email')
                    <p class="text-red-600 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Role Selection -->
            <div class="mb-6">
                <label for="role" class="block text-gray-700 font-medium mb-2">Role</label>
                <select id="role" name="role" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent @error('role') border-red-500 @enderror">
                    <option value="admin" @selected(old('role', $user->role) === 'admin')>Admin (Platform Management)</option>
                    <option value="recruiter" @selected(old('role', $user->role) === 'recruiter')>Recruiter (Post Jobs)</option>
                    <option value="job_seeker" @selected(old('role', $user->role) === 'job_seeker')>Job Seeker (Apply for Jobs)</option>
                </select>
                @error('role')
                    <p class="text-red-600 text-sm mt-1">{{ $message }}</p>
                @enderror

                <!-- Role Explanation -->
                <div class="mt-3 p-3 bg-blue-50 border border-blue-200 rounded-lg text-sm text-gray-700">
                    <p><strong>Note:</strong></p>
                    <ul class="list-disc list-inside mt-2 space-y-1">
                        <li>Changing from Recruiter → Job Seeker will automatically close all their jobs</li>
                        <li>Admin has full platform access</li>
                        <li>Recruiters can post and manage jobs</li>
                        <li>Job Seekers can apply for jobs</li>
                    </ul>
                </div>
            </div>

            <!-- Current Status -->
            <div class="mb-6 p-4 bg-gray-50 rounded-lg">
                <p class="text-sm text-gray-600">
                    <strong>Current Status:</strong>
                    <span class="ml-2 px-2 py-1 rounded-full @if($user->active) bg-green-100 text-green-800 @else bg-red-100 text-red-800 @endif">
                        {{ $user->active ? 'Active' : 'Suspended' }}
                    </span>
                </p>
                <p class="text-sm text-gray-600 mt-2">
                    Use the Suspend button on the user's detail page to change account status.
                </p>
            </div>

            <!-- Buttons -->
            <div class="flex gap-3">
                <button type="submit" class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 flex items-center gap-2">
                    <i class="fas fa-save"></i> Save Changes
                </button>
                <a href="{{ route('admin.users.show', $user) }}" class="px-6 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700">
                    Cancel
                </a>
            </div>
        </form>
    </div>
</div>
@endsection
