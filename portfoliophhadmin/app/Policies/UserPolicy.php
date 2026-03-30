<?php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    /**
     * Only admins can view users
     */
    public function viewAny(User $user): bool
    {
        return $user->role === 'admin';
    }

    /**
     * Only admins can view a specific user
     */
    public function view(User $user, User $target): bool
    {
        return $user->role === 'admin';
    }

    /**
     * Only admins can edit users
     */
    public function update(User $user, User $target): bool
    {
        return $user->role === 'admin';
    }

    /**
     * Only admins can delete users
     */
    public function delete(User $user, User $target): bool
    {
        return $user->role === 'admin';
    }

    /**
     * Only admins can suspend users
     */
    public function suspend(User $user, User $target): bool
    {
        return $user->role === 'admin';
    }
}
