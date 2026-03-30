@extends('layouts.app')

@section('title', 'My Profile')

@section('content')
<div class="mb-8">
    <h1 class="text-4xl font-bold text-gray-900">
        <i class="fas fa-user mr-3 text-blue-600"></i>My Profile
    </h1>
</div>

<div class="max-w-2xl mx-auto bg-white rounded-lg shadow p-8">
    <form method="POST" action="{{ route('profile.update') }}">
        @csrf

        <div class="mb-6">
            <label for="name" class="block text-gray-700 font-bold mb-2">Full Name</label>
            <input type="text" id="name" name="name" value="{{ old('name', auth()->user()->name) }}"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('name') border-red-500 @enderror"
                required>
            @error('name')
                <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
            @enderror
        </div>

        <div class="mb-6">
            <label for="email" class="block text-gray-700 font-bold mb-2">Email Address</label>
            <input type="email" id="email" name="email" value="{{ old('email', auth()->user()->email) }}"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('email') border-red-500 @enderror"
                required>
            @error('email')
                <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
            @enderror
        </div>

        <div class="mb-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <p class="text-gray-700">
                <strong>Account Type:</strong>
                <span class="inline-block px-3 py-1 rounded-full bg-blue-100 text-blue-800 text-sm font-medium">
                    @if(auth()->user()->role === 'recruiter')
                        Recruiter
                    @else
                        Job Seeker
                    @endif
                </span>
            </p>
        </div>

        <div class="flex space-x-3">
            <button type="submit" class="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition">
                <i class="fas fa-save mr-2"></i>Save Changes
            </button>
            <a href="{{ route('dashboard') }}" class="flex-1 bg-gray-600 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded-lg transition text-center">
                <i class="fas fa-times mr-2"></i>Cancel
            </a>
        </div>
    </form>
</div>
@endsection
