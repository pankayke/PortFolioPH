<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    /**
     * Update user profile with support for file uploads (multipart).
     *
     * Supports partial updates – only provided fields are updated.
     *
     * Request body (FormData):
     *   - name: string (optional)
     *   - email: string|email|unique:users (optional)
     *   - bio: string (optional)
     *   - location: string (optional)
     *   - phone_number: string (optional)
     *   - website_url: string|url (optional)
     *   - avatar: file (optional, image, max 2MB)
     *   - resume: file (optional, PDF, max 5MB)
     *
     * Response: 200 OK with updated user object
     *   {
     *     "success": true,
     *     "data": { id, name, email, bio, location, phone_number, website_url, avatar_path, ... },
     *     "errors": null
     *   }
     *
     * Validation errors: 422 Unprocessable Entity
     *   {
     *     "success": false,
     *     "message": "Validation failed",
     *     "errors": { "field": ["error message"] }
     *   }
     */
    public function update(Request $request)
    {
        // Get authenticated user
        $user = $request->user();
        if (! $user) {
            return response()->json(
                ['success' => false, 'message' => 'Unauthorized'],
                401
            );
        }

        // Validate input
        $validated = $request->validate([
            'name' => 'string|max:255',
            'email' => 'string|email|unique:users,email,'.$user->id,
            'bio' => 'string|max:1000',
            'location' => 'string|max:255',
            'phone_number' => 'string|max:20',
            'website_url' => 'string|url|max:255',
            'avatar' => 'image|max:2048', // 2MB max
            'resume' => 'mimes:pdf|max:5120', // 5MB max
        ]);

        // Handle avatar upload
        if ($request->hasFile('avatar')) {
            // Delete old avatar if exists
            if ($user->avatar_path && Storage::disk('public')->exists($user->avatar_path)) {
                Storage::disk('public')->delete($user->avatar_path);
            }

            // Store new avatar
            $path = $request->file('avatar')->store('avatars', 'public');
            $validated['avatar_path'] = $path;
        }

        // Handle resume upload
        if ($request->hasFile('resume')) {
            // Delete old resume if exists
            if ($user->resume_path && Storage::disk('public')->exists($user->resume_path)) {
                Storage::disk('public')->delete($user->resume_path);
            }

            // Store new resume
            $path = $request->file('resume')->store('resumes', 'public');
            $validated['resume_path'] = $path;
        }

        // Update user with validated data (only provided fields)
        $user->update($validated);

        // Return updated user
        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'username' => $user->username,
                'role' => $user->role,
                'bio' => $user->bio,
                'location' => $user->location,
                'phone_number' => $user->phone_number,
                'website_url' => $user->website_url,
                'avatar_path' => $user->avatar_path,
                'resume_path' => $user->resume_path,
                'created_at' => $user->created_at,
                'updated_at' => $user->updated_at,
            ],
            'errors' => null,
        ], 200);
    }

    /**
     * Get current authenticated user's profile.
     *
     * Response: 200 OK
     *   {
     *     "success": true,
     *     "data": { id, name, email, ... },
     *     "errors": null
     *   }
     */
    public function show(Request $request)
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(
                ['success' => false, 'message' => 'Unauthorized'],
                401
            );
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'username' => $user->username,
                'role' => $user->role,
                'bio' => $user->bio,
                'location' => $user->location,
                'phone_number' => $user->phone_number,
                'website_url' => $user->website_url,
                'avatar_path' => $user->avatar_path,
                'resume_path' => $user->resume_path,
                'created_at' => $user->created_at,
                'updated_at' => $user->updated_at,
            ],
            'errors' => null,
        ], 200);
    }
}
