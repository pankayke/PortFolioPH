<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ApiGuard
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): mixed
    {
        // Force API semantics so auth middleware returns JSON responses, not redirects.
        if ($request->is('api/*')) {
            $request->headers->set('Accept', 'application/json');
            $request->headers->set('X-Requested-With', 'XMLHttpRequest');

            // Resolve user from Sanctum for API route handling.
            $request->setUserResolver(function () {
                return auth('sanctum')->user();
            });
        }

        return $next($request);
    }
}
