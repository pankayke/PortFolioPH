<?php

namespace App\Http\Resources;

use Illuminate\Http\JsonResponse;

class ApiResponse
{
    /**
     * Success response format
     *
     * @param mixed $data
     * @param string $message
     * @param int $statusCode
     * @return JsonResponse
     */
    public static function success(
        $data = null,
        string $message = 'Success',
        int $statusCode = 200
    ): JsonResponse {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
            'errors' => null,
        ], $statusCode);
    }

    /**
     * Error response format
     *
     * @param string $message
     * @param int $statusCode
     * @param array|null $errors
     * @return JsonResponse
     */
    public static function error(
        string $message = 'Error',
        int $statusCode = 400,
        ?array $errors = null
    ): JsonResponse {
        return response()->json([
            'success' => false,
            'message' => $message,
            'data' => null,
            'errors' => $errors,
        ], $statusCode);
    }

    /**
     * Validation error response
     *
     * @param array $errors
     * @param int $statusCode
     * @return JsonResponse
     */
    public static function validationError(
        array $errors,
        int $statusCode = 422
    ): JsonResponse {
        return self::error(
            'Validation failed',
            $statusCode,
            $errors
        );
    }

    /**
     * Not found response
     *
     * @param string $resource
     * @return JsonResponse
     */
    public static function notFound(string $resource = 'Resource'): JsonResponse
    {
        return self::error("{$resource} not found", 404);
    }

    /**
     * Unauthorized response
     *
     * @param string $message
     * @return JsonResponse
     */
    public static function unauthorized(string $message = 'Unauthorized'): JsonResponse
    {
        return self::error($message, 401);
    }

    /**
     * Forbidden response
     *
     * @param string $message
     * @return JsonResponse
     */
    public static function forbidden(string $message = 'Forbidden'): JsonResponse
    {
        return self::error($message, 403);
    }

    /**
     * Paginated response
     *
     * @param mixed $paginator
     * @param string $message
     * @param int $statusCode
     * @return JsonResponse
     */
    public static function paginated(
        $paginator,
        string $message = 'Success',
        int $statusCode = 200
    ): JsonResponse {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $paginator->items(),
            'pagination' => [
                'current_page' => $paginator->currentPage(),
                'total' => $paginator->total(),
                'per_page' => $paginator->perPage(),
                'last_page' => $paginator->lastPage(),
            ],
            'errors' => null,
        ], $statusCode);
    }
}
