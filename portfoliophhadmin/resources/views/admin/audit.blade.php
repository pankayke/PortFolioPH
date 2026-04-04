@extends('layouts.app')

@section('content')
<div class="container mx-auto px-4 py-8">
    <div class="mb-8">
        <h1 class="text-4xl font-bold text-gray-900">Audit Log</h1>
        <p class="text-gray-600 mt-2">Track recent platform activities and changes</p>
    </div>

    <!-- Activity Sections -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- User Edits -->
        <div class="bg-white rounded-lg shadow overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
                <h3 class="text-lg font-semibold text-gray-900">Recent User Edits</h3>
            </div>
            <div class="divide-y">
                @forelse($recentActions['User edits'] as $user)
                    <div class="px-6 py-3 hover:bg-gray-50">
                        <p class="text-sm font-medium text-gray-900">{{ $user->name }}</p>
                        <p class="text-xs text-gray-500">{{ $user->email }}</p>
                        <p class="text-xs text-gray-400 mt-1">
                            <i class="fas fa-clock"></i> {{ $user->updated_at->diffForHumans() }}
                        </p>
                    </div>
                @empty
                    <div class="px-6 py-4 text-center text-gray-500 text-sm">
                        No recent edits
                    </div>
                @endforelse
            </div>
        </div>

        <!-- Job Changes -->
        <div class="bg-white rounded-lg shadow overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
                <h3 class="text-lg font-semibold text-gray-900">Recent Job Changes</h3>
            </div>
            <div class="divide-y">
                @forelse($recentActions['Job changes'] as $job)
                    <div class="px-6 py-3 hover:bg-gray-50">
                        <p class="text-sm font-medium text-gray-900">{{ $job->title }}</p>
                        <p class="text-xs text-gray-500">by {{ $job->recruiter->name ?? 'Unknown' }}</p>
                        <p class="text-xs text-gray-400 mt-1">
                            <i class="fas fa-clock"></i> {{ $job->updated_at->diffForHumans() }}
                        </p>
                    </div>
                @empty
                    <div class="px-6 py-4 text-center text-gray-500 text-sm">
                        No recent changes
                    </div>
                @endforelse
            </div>
        </div>

        <!-- Application Updates -->
        <div class="bg-white rounded-lg shadow overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
                <h3 class="text-lg font-semibold text-gray-900">Recent Application Updates</h3>
            </div>
            <div class="divide-y">
                @forelse($recentActions['Application updates'] as $app)
                    <div class="px-6 py-3 hover:bg-gray-50">
                        <p class="text-sm font-medium text-gray-900">{{ $app->job->title ?? 'N/A' }}</p>
                        <p class="text-xs text-gray-500">by {{ $app->user->name ?? 'Unknown' }}</p>
                        <p class="text-xs text-gray-400 mt-1">
                            <i class="fas fa-clock"></i> {{ $app->updated_at->diffForHumans() }}
                        </p>
                    </div>
                @empty
                    <div class="px-6 py-4 text-center text-gray-500 text-sm">
                        No recent updates
                    </div>
                @endforelse
            </div>
        </div>
    </div>
</div>
@endsection
