<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class EnsureJsonResponseStructure
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): mixed
    {
        $response = $next($request);

        // If it's a JSON response without 'success' field, add it
        if ($response instanceof JsonResponse && $response->getStatusCode() >= 400) {
            $data = $response->getData(true);
            
            if (!isset($data['success'])) {
                // This is likely an error response without our structure
                $message = $data['message'] ?? 'Error';
                $errors = null;
                
                // Preserve any error details
                if (isset($data['errors'])) {
                    $errors = $data['errors'];
                }
                
                $newData = [
                    'success' => false,
                    'message' => $message,
                    'data' => null,
                    'errors' => $errors,
                ];
                
                $response->setData($newData);
            }
        }

        return $response;
    }
}
