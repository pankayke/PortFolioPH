<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    /**
     * Register a new user
     *
     * @param array $validated
     * @return User
     */
    public function register(array $validated): User
    {
        return User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
        ]);
    }

    /**
     * Authenticate user with credentials
     *
     * @param array $credentials
     * @return User|null
     */
    public function authenticate(array $credentials): ?User
    {
        if (Auth::attempt($credentials)) {
            return Auth::user();
        }

        return null;
    }

    /**
     * Create API token for user
     *
     * @param User $user
     * @return string
     */
    public function createToken(User $user): string
    {
        return $user->createToken('api-token')->plainTextToken;
    }

    /**
     * Logout user
     *
     * @param User $user
     * @return void
     */
    public function logout(User $user): void
    {
        $user->tokens()->delete();
    }
}
