<?php

namespace App\Services;

use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthService
{
    /**
     * Register a new user
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
     */
    public function authenticate(array $credentials): ?User
    {
        $email = mb_strtolower(trim((string) ($credentials['email'] ?? '')));
        $password = (string) ($credentials['password'] ?? '');

        if ($email === '' || $password === '') {
            return null;
        }

        $user = User::whereRaw('LOWER(email) = ?', [$email])->first();
        if (! $user) {
            return null;
        }

        if (! Hash::check($password, $user->password)) {
            return null;
        }

        // Keep Laravel auth state aligned for downstream middleware/guards.
        Auth::login($user);

        return $user;
    }

    /**
     * Reset password by email.
     */
    public function resetPasswordByEmail(string $email, string $newPassword): bool
    {
        $user = User::whereRaw('LOWER(email) = ?', [mb_strtolower(trim($email))])->first();

        if (! $user) {
            return false;
        }

        $user->password = Hash::make($newPassword);
        $user->save();

        return true;
    }

    /**
     * Create a one-time reset token for a user email.
     * Token is stored as hash and expires after 60 minutes.
     */
    public function createPasswordResetToken(string $email): ?string
    {
        $normalizedEmail = mb_strtolower(trim($email));
        $user = User::whereRaw('LOWER(email) = ?', [$normalizedEmail])->first();

        if (! $user) {
            return null;
        }

        $plainToken = Str::random(64);

        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $normalizedEmail],
            [
                'token' => Hash::make($plainToken),
                'created_at' => Carbon::now(),
            ]
        );

        return $plainToken;
    }

    /**
     * Reset password using email + reset token.
     */
    public function resetPasswordWithToken(string $email, string $token, string $newPassword): bool
    {
        $normalizedEmail = mb_strtolower(trim($email));

        $user = User::whereRaw('LOWER(email) = ?', [$normalizedEmail])->first();
        if (! $user) {
            return false;
        }

        $record = DB::table('password_reset_tokens')
            ->where('email', $normalizedEmail)
            ->first();

        if (! $record || ! is_string($record->token)) {
            return false;
        }

        $createdAt = Carbon::parse($record->created_at);
        if ($createdAt->lt(Carbon::now()->subMinutes(60))) {
            DB::table('password_reset_tokens')->where('email', $normalizedEmail)->delete();

            return false;
        }

        if (! Hash::check($token, $record->token)) {
            return false;
        }

        $user->password = Hash::make($newPassword);
        $user->save();

        DB::table('password_reset_tokens')->where('email', $normalizedEmail)->delete();

        return true;
    }

    /**
     * Create API token for user
     */
    public function createToken(User $user): string
    {
        return $user->createToken('api-token')->plainTextToken;
    }

    /**
     * Logout user
     */
    public function logout(User $user): void
    {
        $user->tokens()->delete();
    }
}
