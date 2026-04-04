<?php

namespace App\Http\Middleware;

use App\Http\Resources\ApiResponse;
use Closure;
use Illuminate\Auth\Middleware\Authenticate as BaseAuthenticate;
use Illuminate\Http\Request;

class Authenticate extends BaseAuthenticate
{
    /**
     * Handle an unauthenticated user by throwing an exception for JSON requests.
     */
    protected function unauthenticated($request, array $guards)
    {
        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json(ApiResponse::unauthorized('Unauthenticated')->getData(true), 401);
        }

        parent::unauthenticated($request, $guards);
    }
}
