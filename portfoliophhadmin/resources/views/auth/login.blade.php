@extends('layouts.app')

@section('title', 'Login')

@section('content')
<div class="min-h-screen bg-gradient-to-br from-blue-600 to-blue-800 flex items-center justify-center px-4 py-12">
    <div class="bg-white rounded-lg shadow-xl p-8 w-full max-w-md">
        <div class="flex justify-center mb-8">
            <div class="flex items-center space-x-2">
                <i class="fas fa-briefcase text-blue-600 text-4xl"></i>
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">PortfolioPh</h1>
                    <p class="text-sm text-gray-600">Job Platform Admin</p>
                </div>
            </div>
        </div>

        <h2 class="text-3xl font-bold text-gray-900 mb-6 text-center">Welcome Back</h2>

        <form method="POST" action="{{ route('login') }}">
            @csrf

            <div class="mb-4">
                <label for="email" class="block text-gray-700 font-medium mb-2">Email Address</label>
                <input type="email" id="email" name="email" value="{{ old('email') }}" 
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('email') border-red-500 @enderror"
                    placeholder="your@email.com" required>
                @error('email')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <div class="mb-6">
                <label for="password" class="block text-gray-700 font-medium mb-2">Password</label>
                <input type="password" id="password" name="password" 
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 @error('password') border-red-500 @enderror"
                    placeholder="••••••••" required>
                @error('password')
                    <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                @enderror
            </div>

            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition">
                <i class="fas fa-sign-in-alt mr-2"></i>Login
            </button>
        </form>

        <div class="mt-6 text-center">
            <p class="text-gray-600">Don't have an account? <a href="{{ route('register') }}" class="text-blue-600 hover:underline font-medium">Register here</a></p>
        </div>

        <div class="mt-4 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <p class="text-sm text-blue-800"><strong>Demo Credentials:</strong></p>
            <p class="text-sm text-blue-800">Email: recruiter@example.com</p>
            <p class="text-sm text-blue-800">Password: password</p>
        </div>
    </div>
</div>
@endsection
