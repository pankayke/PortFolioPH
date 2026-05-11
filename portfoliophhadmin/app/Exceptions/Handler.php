<?php

namespace App\Exceptions;

use App\Http\Resources\ApiResponse;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Throwable;

class Handler extends ExceptionHandler
{
    /**
     * The list of the inputs that are never flashed to the session on validation exceptions.
     *
     * @var array<int, string>
     */
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    /**
     * Register the exception handling callbacks for the application.
     */
    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            //
        });
    }

    /**
     * Render the exception into an HTTP response.
     */
    public function render($request, Throwable $exception)
    {
        // JSON API requests
        if ($request->expectsJson()) {
            return $this->renderJson($request, $exception);
        }

        return parent::render($request, $exception);
    }

    /**
     * Render exception as JSON
     */
    protected function renderJson($request, Throwable $exception)
    {
        // Validation errors (422)
        if ($exception instanceof ValidationException) {
            return ApiResponse::validationError(
                $exception->errors(),
                422
            );
        }

        // Model not found (404)
        if ($exception instanceof ModelNotFoundException) {
            return ApiResponse::notFound('Resource');
        }

        // Not found (404)
        if ($exception instanceof NotFoundHttpException) {
            return ApiResponse::notFound('Endpoint');
        }

        // Authentication failed (401)
        if ($exception instanceof AuthenticationException) {
            return ApiResponse::unauthorized('Unauthenticated');
        }

        // Authorization failed (403)
        if ($exception instanceof AuthorizationException) {
            return ApiResponse::forbidden('Unauthorized');
        }

        // Rate limited (429)
        if ($exception->getCode() === 429) {
            return ApiResponse::error(
                'Too many requests. Please try again later.',
                429
            );
        }

        // Server error (500)
        return ApiResponse::error(
            'Internal server error',
            500
        );
    }
}
