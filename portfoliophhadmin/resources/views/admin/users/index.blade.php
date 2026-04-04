@extends('layouts.app')

@section('content')
<div class="px-6 py-8">
    <!-- Page Header -->
    <div class="mb-8">
        <!-- Breadcrumbs -->
        <div class="flex items-center text-sm mb-4">
            <a href="{{ route('admin.dashboard') }}" class="text-gray-500 hover:text-gray-700">Admin</a>
            <span class="text-gray-400 mx-2">/</span>
            <span class="text-gray-900 font-medium">Users</span>
        </div>
        
        <!-- Title -->
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-2xl font-bold text-gray-900">Users Management</h1>
                <p class="text-gray-600 mt-1">Manage all platform users - recruiters and job seekers</p>
            </div>
            <div class="text-sm text-gray-500">
                Users directory
            </div>
        </div>
    </div>

    <!-- Search & Filter Bar -->
    <div class="mb-6">
        <form method="GET" class="flex gap-3">
            <div class="flex-1 relative">
                <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 text-sm"></i>
                <input 
                    type="text" 
                    name="search" 
                    placeholder="Search by name or email..." 
                    value="{{ request('search') }}"
                    class="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm"
                >
            </div>
            <button type="submit" class="px-4 py-2.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors duration-150 text-sm font-medium">
                Search
            </button>
        </form>
    </div>

    <!-- Users Table Card -->
    <div class="bg-white rounded-lg border border-gray-200 shadow overflow-hidden">
        <!-- Table -->
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Name</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Email</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Role</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Status</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Activity</th>
                        <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    @forelse($users as $user)
                        <tr class="hover:bg-blue-50 transition-colors duration-100">
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 bg-gradient-to-br from-blue-400 to-blue-600 rounded-full flex items-center justify-center flex-shrink-0">
                                        <span class="text-xs font-semibold text-white">{{ substr($user->name, 0, 1) }}</span>
                                    </div>
                                    <p class="font-medium text-gray-900">{{ $user->name }}</p>
                                </div>
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-600">{{ $user->email }}</td>
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium
                                    @if($user->role === 'admin') bg-red-50 text-red-700 border border-red-100
                                    @elseif($user->role === 'recruiter') bg-blue-50 text-blue-700 border border-blue-100
                                    @else bg-emerald-50 text-emerald-700 border border-emerald-100
                                    @endif">
                                    <span class="w-1.5 h-1.5 rounded-full {{ $user->role === 'admin' ? 'bg-red-500' : ($user->role === 'recruiter' ? 'bg-blue-500' : 'bg-emerald-500') }}"></span>
                                    {{ ucfirst($user->role) }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                @if($user->active)
                                    <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700 border border-emerald-100">
                                        <span class="w-1.5 h-1.5 bg-emerald-500 rounded-full"></span>
                                        Active
                                    </span>
                                @else
                                    <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium bg-gray-50 text-gray-700 border border-gray-100">
                                        <span class="w-1.5 h-1.5 bg-gray-400 rounded-full"></span>
                                        Suspended
                                    </span>
                                @endif
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-2 text-sm text-gray-600">
                                    @if($user->role === 'recruiter')
                                        <i class="fas fa-briefcase text-blue-500"></i>
                                        <span>{{ $user->jobs->count() }} {{ Str::plural('job', $user->jobs->count()) }}</span>
                                    @else
                                        <i class="fas fa-file-alt text-purple-500"></i>
                                        <span>{{ $user->applications->count() }} {{ Str::plural('application', $user->applications->count()) }}</span>
                                    @endif
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-1">
                                    <a href="{{ route('admin.users.show', $user) }}" class="inline-flex items-center gap-1 px-2.5 py-1.5 text-blue-600 hover:bg-blue-50 rounded-md transition-colors duration-150 text-xs font-medium">
                                        View
                                    </a>
                                    <a href="{{ route('admin.users.edit', $user) }}" class="inline-flex items-center gap-1 px-2.5 py-1.5 text-gray-600 hover:bg-gray-100 rounded-md transition-colors duration-150 text-xs font-medium">
                                        Edit
                                    </a>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6">
                                <div class="px-6 py-12 text-center">
                                    <i class="fas fa-inbox text-gray-300 text-4xl mb-3 block"></i>
                                    <h3 class="text-gray-900 font-semibold mb-1">No users found</h3>
                                    <p class="text-gray-500 text-sm">Try adjusting your search filters.</p>
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        @if($users->hasPages())
            <div class="px-6 py-5 border-t border-gray-100 bg-gray-50">
                {{ $users->links() }}
            </div>
        @endif
    </div>
</div>
@endsection
