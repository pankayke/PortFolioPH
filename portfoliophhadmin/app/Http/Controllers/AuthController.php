<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Resources\ApiResponse;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

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
