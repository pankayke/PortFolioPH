<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RecruiterMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = auth()->user();

        if (! $user || $user->role !== 'recruiter') {
            return redirect()->route('dashboard')
                ->with('error', 'You do not have permission to access this resource.');
        }

        // Suspended recruiters are blocked immediately
        if ($user->active === false) {
            auth()->logout();

            return redirect()->route('login')
                ->with('error', 'Your account has been suspended. Please contact support.');
        }

        return $next($request);
    }
}
