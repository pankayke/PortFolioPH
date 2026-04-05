<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Auth\Middleware\Authenticate;

class ApiGuard
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): mixed
    {
        // For API routes, ensure we don't go through Session-based authentication
        if ($request->is('api/*')) {
            // Set the expectsJson to true so middleware knows this is an API request
            $request->setUserResolver(function () use ($request) {
                return auth('sanctum')->user();
            });
        }

        return $next($request);
    }
}
