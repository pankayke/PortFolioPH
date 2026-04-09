<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title') - PortfolioPh Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .titan-admin-header {
            position: sticky;
            top: 0;
            z-index: 1000;
            border-bottom: 1px solid rgba(148, 163, 184, 0.28);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            background: linear-gradient(45deg, rgba(255, 255, 255, 0.9), rgba(245, 247, 255, 0.82));
            box-shadow: 0 18px 34px -30px rgba(79, 70, 229, 0.38);
        }

        .titan-status-dot {
            position: relative;
            width: 9px;
            height: 9px;
            border-radius: 9999px;
            background: #22c55e;
            box-shadow: 0 0 0 5px rgba(34, 197, 94, 0.14);
        }

        .titan-status-dot::after {
            content: '';
            position: absolute;
            inset: -7px;
            border: 2px solid rgba(34, 197, 94, 0.25);
            border-radius: 9999px;
            animation: titanPulse 1.8s ease-out infinite;
        }

        @keyframes titanPulse {
            0% {
                transform: scale(0.7);
                opacity: 0.9;
            }
            100% {
                transform: scale(1.35);
                opacity: 0;
            }
        }

        .titan-gradient-text {
            background: linear-gradient(45deg, #312e81, #6366f1 50%, #8b5cf6);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .titan-profile-card {
            border: 1px solid rgba(199, 210, 254, 0.75);
            background: rgba(255, 255, 255, 0.6);
            transition: box-shadow 0.2s ease, border-color 0.2s ease;
        }

        .titan-profile-card:hover {
            border-color: rgba(139, 92, 246, 0.45);
            box-shadow: 0 0 0 2px rgba(139, 92, 246, 0.1), 0 12px 24px -18px rgba(91, 33, 182, 0.35);
        }
    </style>
</head>
<body class="bg-slate-50">
    @if(auth()->check())
        <!-- Navigation -->
        @php
            $isAdmin = auth()->user()->role === 'admin';
            $routeName = (string) \Illuminate\Support\Facades\Route::currentRouteName();
            $crumb = 'Dashboard';
            if (str_contains($routeName, 'admin.users')) {
                $crumb = 'Users';
            } elseif (str_contains($routeName, 'admin.jobs')) {
                $crumb = 'Jobs';
            } elseif (str_contains($routeName, 'admin.applications')) {
                $crumb = 'Applications';
            } elseif (str_contains($routeName, 'admin.settings')) {
                $crumb = 'Settings';
            } elseif (str_contains($routeName, 'admin.audit')) {
                $crumb = 'Audit';
            }
        @endphp
        <nav class="titan-admin-header">
            <div class="w-full px-4 md:px-5">
                @if($isAdmin)
                    <div class="flex min-h-[82px] items-center gap-4">
                        <div class="flex min-w-0 items-center gap-3 md:w-[30%]">
                            <a href="{{ route('admin.dashboard') }}" class="flex items-center gap-2.5">
                                <span class="rounded-xl border border-indigo-100 bg-indigo-50 p-2 text-indigo-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="2" y="7" width="20" height="14" rx="2" /><path d="M16 3v4M8 3v4M2 11h20" /></svg>
                                </span>
                                <span class="text-xl font-extrabold tracking-tight titan-gradient-text">PortfolioPh</span>
                            </a>
                            <div class="hidden items-center gap-2 text-sm text-slate-500 md:flex">
                                <span>/</span>
                                <span class="font-semibold text-slate-700">Admin</span>
                                <span>/</span>
                                <span class="font-semibold text-slate-900">{{ $crumb }}</span>
                            </div>
                        </div>

                        <div class="hidden md:flex md:w-[40%] md:justify-center">
                            <label class="group flex w-full max-w-xl items-center gap-2 rounded-full border border-slate-200 bg-slate-100/85 px-4 py-2.5 transition-colors duration-150 hover:border-indigo-200 hover:bg-slate-50">
                                <svg class="h-4 w-4 text-slate-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="11" cy="11" r="8" /><path d="m21 21-3.8-3.8" /></svg>
                                <input type="search" placeholder="Search commands, users, jobs, settings..." class="w-full bg-transparent text-sm text-slate-700 outline-none placeholder:text-slate-500" />
                            </label>
                        </div>

                        <div class="ml-auto flex items-center gap-3 md:w-[30%] md:justify-end">
                            <div class="hidden items-center gap-2 rounded-full border border-emerald-100 bg-emerald-50/75 px-3 py-1.5 text-xs font-semibold text-emerald-700 lg:flex">
                                <span class="titan-status-dot"></span>
                                <span>System Online • 24ms Latency • {{ now()->format('h:i A') }}</span>
                            </div>

                            <div class="relative group">
                                <button class="titan-profile-card inline-flex items-center gap-2 rounded-full px-2 py-1.5 text-slate-700">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-indigo-500 to-violet-500 text-xs font-semibold text-white">{{ strtoupper(substr(auth()->user()->name, 0, 1)) }}</span>
                                    <span class="hidden text-sm font-semibold md:inline">{{ auth()->user()->name }}</span>
                                    <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="m6 9 6 6 6-6" /></svg>
                                </button>
                                <div class="absolute right-0 mt-2 w-48 rounded-xl border border-slate-200 bg-white p-1.5 shadow-xl opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-[130]">
                                    <a href="{{ route('profile') }}" class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-indigo-50">
                                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 21a8 8 0 1 0-16 0" /><circle cx="12" cy="7" r="4" /></svg>
                                        Profile
                                    </a>
                                    <form method="POST" action="{{ route('logout') }}" class="block">
                                        @csrf
                                        <button type="submit" class="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm text-slate-700 hover:bg-rose-50 hover:text-rose-700">
                                            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" /><path d="m16 17 5-5-5-5" /><path d="M21 12H9" /></svg>
                                            Logout
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                @else
                    <div class="flex min-h-[72px] items-center justify-between gap-4">
                        <div class="flex items-center">
                            <a href="{{ route('dashboard') }}" class="flex items-center space-x-2">
                                <span class="rounded-lg bg-indigo-50 p-2 text-indigo-600">
                                    <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="2" y="7" width="20" height="14" rx="2" /><path d="M16 3v4M8 3v4M2 11h20" /></svg>
                                </span>
                                <span class="text-xl font-bold tracking-tight text-slate-900">PortfolioPh</span>
                            </a>
                        </div>
                        <div class="flex items-center space-x-8">
                            <a href="{{ route('dashboard') }}" class="inline-flex items-center gap-2 text-sm font-semibold text-slate-700 hover:text-indigo-600">
                                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 13h8V3H3v10Zm10 8h8V11h-8v10Zm0-18v4h8V3h-8Zm-10 18h8v-4H3v4Z" /></svg>
                                Dashboard
                            </a>
                            @if(auth()->user()->role === 'recruiter')
                                <a href="{{ route('jobs.index') }}" class="inline-flex items-center gap-2 text-sm font-semibold text-slate-700 hover:text-indigo-600">
                                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M8 6h13M8 12h13M8 18h13" /><path d="M3 6h.01M3 12h.01M3 18h.01" /></svg>
                                    Jobs
                                </a>
                                <a href="{{ route('applications.index') }}" class="inline-flex items-center gap-2 text-sm font-semibold text-slate-700 hover:text-indigo-600">
                                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M14 2H6a2 2 0 0 0-2 2v16l4-3 4 3 4-3 4 3V8Z" /><path d="M14 2v6h6" /></svg>
                                    Applications
                                </a>
                            @else
                                <a href="{{ route('my-applications') }}" class="inline-flex items-center gap-2 text-sm font-semibold text-slate-700 hover:text-indigo-600">
                                    <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M14 2H6a2 2 0 0 0-2 2v16l4-3 4 3 4-3 4 3V8Z" /><path d="M14 2v6h6" /></svg>
                                    My Applications
                                </a>
                            @endif
                            <div class="relative group">
                                <button class="inline-flex items-center gap-2 text-slate-700 hover:text-indigo-600">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-indigo-500 to-violet-500 text-xs font-semibold text-white">{{ strtoupper(substr(auth()->user()->name, 0, 1)) }}</span>
                                    <span class="text-sm font-semibold">{{ auth()->user()->name }}</span>
                                    <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="m6 9 6 6 6-6" /></svg>
                                </button>
                                <div class="absolute right-0 mt-2 w-48 rounded-xl border border-slate-200 bg-white p-1.5 shadow-xl opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-[130]">
                                    <a href="{{ route('profile') }}" class="flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-indigo-50">
                                        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 21a8 8 0 1 0-16 0" /><circle cx="12" cy="7" r="4" /></svg>
                                        Profile
                                    </a>
                                    <form method="POST" action="{{ route('logout') }}" class="block">
                                        @csrf
                                        <button type="submit" class="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm text-slate-700 hover:bg-rose-50 hover:text-rose-700">
                                            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" /><path d="m16 17 5-5-5-5" /><path d="M21 12H9" /></svg>
                                            Logout
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                @endif
            </div>
        </nav>

        <!-- Main Content -->
        <main class="w-full px-3 py-4 md:px-4 lg:px-5">
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
