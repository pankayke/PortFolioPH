<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title') - PortfolioPh Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50">
    @if(auth()->check())
        <!-- Navigation -->
        <nav class="bg-white shadow-sm border-b border-gray-200">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between h-16">
                    <div class="flex items-center">
                        <a href="{{ route('dashboard') }}" class="flex items-center space-x-2">
                            <i class="fas fa-briefcase text-blue-600 text-2xl"></i>
                            <span class="text-xl font-bold text-gray-900">PortfolioPh</span>
                        </a>
                    </div>
                    
                    <div class="flex items-center space-x-8">
                        <a href="{{ route('dashboard') }}" class="text-gray-700 hover:text-blue-600 font-medium">
                            <i class="fas fa-chart-line mr-2"></i>Dashboard
                        </a>
                        
                        @if(auth()->user()->role === 'admin')
                            <div class="relative group">
                                <button class="flex items-center space-x-1 text-gray-700 hover:text-blue-600 font-medium">
                                    <i class="fas fa-cog mr-2"></i>Admin
                                    <i class="fas fa-caret-down text-sm"></i>
                                </button>
                                <div class="absolute left-0 mt-2 w-48 bg-white rounded-lg shadow-xl opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-50">
                                    <a href="{{ route('admin.dashboard') }}" class="block px-4 py-2 text-gray-700 hover:bg-blue-50 border-b">
                                        <i class="fas fa-chart-bar mr-2"></i>Admin Dashboard
                                    </a>
                                    <a href="{{ route('admin.users.index') }}" class="block px-4 py-2 text-gray-700 hover:bg-blue-50 border-b">
                                        <i class="fas fa-users mr-2"></i>Manage Users
                                    </a>
                                    <a href="{{ route('admin.jobs.index') }}" class="block px-4 py-2 text-gray-700 hover:bg-blue-50 border-b">
                                        <i class="fas fa-briefcase mr-2"></i>Moderate Jobs
                                    </a>
                                    <a href="{{ route('admin.applications.index') }}" class="block px-4 py-2 text-gray-700 hover:bg-blue-50">
                                        <i class="fas fa-file-alt mr-2"></i>Applications
                                    </a>
                                </div>
                            </div>
                        @elseif(auth()->user()->role === 'recruiter')
                            <a href="{{ route('jobs.index') }}" class="text-gray-700 hover:text-blue-600 font-medium">
                                <i class="fas fa-list mr-2"></i>Jobs
                            </a>
                            <a href="{{ route('applications.index') }}" class="text-gray-700 hover:text-blue-600 font-medium">
                                <i class="fas fa-file-alt mr-2"></i>Applications
                            </a>
                        @else
                            <a href="{{ route('my-applications') }}" class="text-gray-700 hover:text-blue-600 font-medium">
                                <i class="fas fa-file-alt mr-2"></i>My Applications
                            </a>
                        @endif
                        
                        <div class="relative group">
                            <button class="flex items-center space-x-2 text-gray-700 hover:text-blue-600">
                                <i class="fas fa-user-circle text-2xl"></i>
                                <span class="font-medium">{{ auth()->user()->name }}</span>
                                <i class="fas fa-caret-down text-sm"></i>
                            </button>
                            <div class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-xl opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-50">
                                <a href="{{ route('profile') }}" class="block px-4 py-2 text-gray-700 hover:bg-blue-50">
                                    <i class="fas fa-user mr-2"></i>Profile
                                </a>
                                <form method="POST" action="{{ route('logout') }}" class="block">
                                    @csrf
                                    <button type="submit" class="w-full text-left px-4 py-2 text-gray-700 hover:bg-red-50">
                                        <i class="fas fa-sign-out-alt mr-2"></i>Logout
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Main Content -->
        <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
            @if($errors->any())
                <div class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded">
                    <ul class="list-disc list-inside">
                        @foreach($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            @if(session('success'))
                <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded">
                    {{ session('success') }}
                </div>
            @endif

            @yield('content')
        </main>
    @else
        @yield('content')
    @endif
</body>
</html>
