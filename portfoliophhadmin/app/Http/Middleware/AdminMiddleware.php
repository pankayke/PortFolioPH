<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = auth()->user();

        if (!$user || $user->role !== 'admin') {
            return redirect('/')->with('error', 'Access denied. Admin privileges required.');
        }

        if ($user->active === false) {
            auth()->logout();
            return redirect('/login')->with('error', 'Your account has been suspended.');
        }

        return $next($request);
    }
}
