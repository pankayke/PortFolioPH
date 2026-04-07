<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Resources\ApiResponse;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function __construct(private AuthService $authService) {}

    /**
     * Register a new user
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = $this->authService->register($request->validated());
        $token = $this->authService->createToken($user);

        return ApiResponse::success(
            [
                'user' => $user->only(['id', 'name', 'email', 'role']),
                'token' => $token,
            ],
            'Registration successful',
            201
        );
    }

    /**
     * Login user
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $user = $this->authService->authenticate($request->validated());
        
        if (!$user) {
            return ApiResponse::error('Invalid credentials', 401);
        }

        $token = $this->authService->createToken($user);

        return ApiResponse::success(
            [
                'user' => $user->only(['id', 'name', 'email', 'role']),
                'token' => $token,
            ],
            'Login successful',
            200
        );
    }

    /**
     * Request a password reset token.
     */
    public function requestPasswordReset(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => ['required', 'email'],
        ]);

        if ($validator->fails()) {
            return ApiResponse::validationError($validator->errors()->toArray());
        }

        $email = $request->string('email')->toString();
        $token = $this->authService->createPasswordResetToken($email);

        if ($token === null) {
            // Avoid account enumeration.
            return ApiResponse::success(null, 'If the email exists, a reset token has been issued.', 200);
        }

        // TODO: Replace with email delivery in production.
        if (app()->environment(['local', 'development', 'testing'])) {
            return ApiResponse::success(
                ['reset_token' => $token],
                'Use this reset token to confirm password reset.',
                200
            );
        }

        return ApiResponse::success(null, 'If the email exists, a reset token has been issued.', 200);
    }

    /**
     * Confirm password reset using email + token + new password.
     */
    public function confirmPasswordReset(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => ['required', 'email'],
            'token' => ['required', 'string', 'min:32'],
            'new_password' => ['required', 'string', 'min:8'],
        ]);

        if ($validator->fails()) {
            return ApiResponse::validationError($validator->errors()->toArray());
        }

        $ok = $this->authService->resetPasswordWithToken(
            $request->string('email')->toString(),
            $request->string('token')->toString(),
            $request->string('new_password')->toString(),
        );

        if (!$ok) {
            return ApiResponse::error('Invalid or expired reset token.', 422);
        }

        return ApiResponse::success(null, 'Password reset successful', 200);
    }

    /**
     * Get current authenticated user (session restore)
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user) {
            return ApiResponse::error('Not authenticated', 401);
        }

        return ApiResponse::success(
            $user->only(['id', 'name', 'email', 'role']),
            'Current user',
            200
        );
    }

    /**
     * Logout user
     */
    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->user());

        return ApiResponse::success(
            null,
            'Logged out successfully',
            200
        );
    }
}
