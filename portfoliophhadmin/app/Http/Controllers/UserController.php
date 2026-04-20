<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function show(User $user)
    {
        return response()->json($user->only(['id', 'name', 'email', 'role', 'created_at']));
    }

    public function search(Request $request)
    {
        $search = $request->input('q', '');

        $users = User::where('name', 'like', "%$search%")
            ->orWhere('email', 'like', "%$search%")
            ->select('id', 'name', 'email', 'role')
            ->limit(20)
            ->get();

        return response()->json($users);
    }

    public function hasRole(Request $request)
    {
        $role = $request->input('role', 'admin');
        $hasRole = $request->user()->role === $role;

        return response()->json(['has_role' => $hasRole]);
    }

    public function update(Request $request, User $user)
    {
        $this->authorize('update', $user);

        $validated = $request->validate([
            'name' => 'string|max:255',
            'email' => 'string|email|unique:users,email,'.$user->id,
        ]);

        $user->update($validated);

        return response()->json($user->only(['id', 'name', 'email', 'role']));
    }
}
