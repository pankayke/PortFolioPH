@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="mb-8">
        <h1 class="text-4xl font-bold text-gray-900">Users Management</h1>
        <p class="text-gray-600 mt-2">Manage all platform users - recruiters and job seekers</p>
    </div>

    <!-- Filter/Search -->
    <div class="bg-white rounded-lg shadow p-4 mb-6">
        <form method="GET" class="flex gap-4">
            <input type="text" name="search" placeholder="Search users..." class="flex-1 px-3 py-2 border border-gray-300 rounded-lg">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                <i class="fas fa-search"></i> Search
            </button>
        </form>
    </div>

    <!-- Users Table -->
    <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Name</th>
                    <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Email</th>
                    <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Role</th>
                    <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Status</th>
                    <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Jobs/Apps</th>
                    <th class="px-6 py-3 text-left text-sm font-medium text-gray-900">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($users as $user)
                    <tr class="hover:bg-gray-50">
                        <td class="px-6 py-4 text-sm font-medium text-gray-900">{{ $user->name }}</td>
                        <td class="px-6 py-4 text-sm text-gray-600">{{ $user->email }}</td>
                        <td class="px-6 py-4 text-sm">
                            <span class="px-2 py-1 rounded-full text-xs font-medium @if($user->role === 'admin') bg-red-100 text-red-800 @elseif($user->role === 'recruiter') bg-blue-100 text-blue-800 @else bg-green-100 text-green-800 @endif">
                                {{ ucfirst($user->role) }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-sm">
                            @if($user->active)
                                <span class="text-green-600"><i class="fas fa-check-circle"></i> Active</span>
                            @else
                                <span class="text-red-600"><i class="fas fa-ban"></i> Suspended</span>
                            @endif
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-600">
                            @if($user->role === 'recruiter')
                                {{ $user->jobs->count() }} jobs
                            @else
                                {{ $user->applications->count() }} apps
                            @endif
                        </td>
                        <td class="px-6 py-4 text-sm">
                            <a href="{{ route('admin.users.show', $user) }}" class="text-blue-600 hover:underline">View</a>
                            <span class="text-gray-300 mx-1">/</span>
                            <a href="{{ route('admin.users.edit', $user) }}" class="text-blue-600 hover:underline">Edit</a>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="px-6 py-8 text-center text-gray-500">
                            No users found
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="mt-6">
        {{ $users->links() }}
    </div>
</div>
@endsection
