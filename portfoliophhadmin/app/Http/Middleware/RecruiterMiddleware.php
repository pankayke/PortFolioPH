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
        if (auth()->check() && auth()->user()->role === 'recruiter') {
            return $next($request);
        }

        return redirect()->route('dashboard')
            ->with('error', 'You do not have permission to access this resource.');
    }
}
