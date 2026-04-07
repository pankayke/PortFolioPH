# LARAVEL PROFILECONTROLLER - SECURITY AUDIT & RECOMMENDATIONS

## Current Implementation Analysis

**File:** `portfoliophhadmin/app/Http/Controllers/ProfileController.php`

### ✅ What's Already Secure

```php
// 1. Input validation on all fields
'resume' => 'mimes:pdf|max:5120',  // 5MB, PDF only
'avatar' => 'image|max:2048',      // 2MB, images only

// 2. File deletion before upload (prevents accumulation)
if ($user->avatar_path && Storage::disk('public')->exists($user->avatar_path)) {
    Storage::disk('public')->delete($user->avatar_path);
}

// 3. Multipart form-data support for file uploads
// Already using FormData correctly in Flutter
```

### ⚠️ CRITICAL SECURITY ISSUES

#### Issue #1: Resumes Stored in Public Directory
**Risk:** 🔴 **HIGH**
```php
// Current (UNSAFE):
$path = $request->file('resume')->store('resumes', 'public');
// Result: Files accessible at /storage/resumes/filename.pdf
// Anyone with URL can download ANY resume = data breach
```

**Solution:**
```php
// SAFE - Store in private storage:
$path = $request->file('resume')->store('resumes', 'private');
// OR move to storage/private/ outside web root

// Then serve via protected Laravel route:
Route::get('/profile/resume/download', [ProfileController::class, 'downloadResume']);

public function downloadResume(Request $request)  {
    $user = $request->user();
    if (!$user || !$user->resume_path) {
        abort(404);
    }
    
    return Storage::disk('private')->download(
        $user->resume_path,
        'resume_' . $user->id . '.pdf'
    );
}
```

#### Issue #2: No Authentication Rate Limiting on Profile Update
**Risk:** 🟡 **MEDIUM**
```php
// Current:
public function update(Request $request)  // Missing rate limiting
```

**Solution:**
```php
// In routes/api.php:
Route::middleware('auth:sanctum', 'throttle:10,1')->group(function () {
    Route::put('/profile', [ProfileController::class, 'update']);
});
//  Allows 10 requests per minute per user
```

#### Issue #3: No File Size Validation Before Storage
**Risk:** 🟡 **MEDIUM**
```php
// Current: Validates via Laravel, but no disk space check
'resume' => 'mimes:pdf|max:5120',
```

**Solution:**
```php
// Add disk space check:
public function update(Request $request)  {
    // ...validation...
    
    // Check disk space (need 10MB free minimum)
    $available = Storage::disk('private')->getDriver()->getAdapter()->getFilesystem()->getFreeSpace();
    if ($available < 10 * 1024 * 1024) {
        return response()->json([
            'success' => false,
            'message' => 'Server storage full'
        ], 507);  // Insufficient Storage
    }
    // ...rest of code...
}
```

---

## Recommended Security Hardening

### 1. Separate Private Storage

```bash
# On server, create private storage directory outside web root:
cd /var/www/portfolioph/portfoliophhadmin
mkdir -p ../storage_private/resumes
mkdir -p ../storage_private/avatars
sudo chown -R www-data:www-data ../storage_private
chmod -R 750 ../storage_private
```

### 2. Update Filesystems Configuration

```php
// config/filesystems.php
'disks' => [
    'public' => [
        'driver' => 'local',
        'root' => storage_path('app/public'),
        'url' => env('APP_URL').'/storage',
        'visibility' => 'public',
    ],
    'private' => [
        'driver' => 'local',
        'root' => storage_path('../../storage_private'),  // Outside web root
        'visibility' => 'private',
    ],
    // S3 recommended for production:
    's3' => [
        'driver' => 's3',
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION'),
        'bucket' => env('AWS_BUCKET'),
    ],
],
```

### 3. Update ProfileController with Security

```php
<?php
// profiles/ have been modified (see below)

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\RateLimiter;

class ProfileController extends Controller
{
    /**
     * Update user profile with file upload protection.
     * 
     * Rate limited to 10 requests/minute per user
     * Resumes stored in private storage (outside public root)
     */
    public function update(Request $request)
    {
        // Rate limiting
        $limiter = RateLimiter::for('profile-update', function (Request $request) {
            return Limit::perMinute(10)->by($request->user()->id);
        });
        
        if (! $limiter->allow()) {
            return response()->json([
                'success' => false,
                'message' => 'Too many profile updates. Please try again later.'
            ], 429);
        }

        $user = $request->user();
        if (!$user) {
            return response()->json(
                ['success' => false, 'message' => 'Unauthorized'],
                401
            );
        }

        // Validate input
        $validated = $request->validate([
            'name' => 'string|max:255',
            'email' => 'string|email|unique:users,email,' . $user->id,
            'bio' => 'string|max:1000',
            'location' => 'string|max:255',
            'phone_number' => 'string|max:20',
            'website_url' => 'string|url|max:255',
            'avatar' => 'image|max:2048', // 2MB
            'resume' => 'mimes:pdf|max:5120', // 5MB, PDF only
        ]);

        // Check disk space
        $available = Storage::disk('private')->getDriver()->getDriver()->getAdapter()->getFilesystem()->getFreeSpace();
        if ($available < 10 * 1024 * 1024) {
            return response()->json([
                'success' => false,
                'message' => 'Server storage full. Please contact support.'
            ], 507);
        }

        // Handle avatar upload (public disk for profile images)
        if ($request->hasFile('avatar')) {
            if ($user->avatar_path && Storage::disk('public')->exists($user->avatar_path)) {
                Storage::disk('public')->delete($user->avatar_path);
            }
            $path = $request->file('avatar')->store('avatars', 'public');
            $validated['avatar_path'] = $path;
        }

        // Handle resume upload (PRIVATE disk - protected)
        if ($request->hasFile('resume')) {
            if ($user->resume_path && Storage::disk('private')->exists($user->resume_path)) {
                Storage::disk('private')->delete($user->resume_path);
            }
            $path = $request->file('resume')->store('resumes', 'private');
            $validated['resume_path'] = $path;
            
            // Log resume upload for audit
            \Log::info('Resume uploaded', [
                'user_id' => $user->id,
                'file_size' => $request->file('resume')->getSize(),
                'timestamp' => now()
            ]);
        }

        // Update user
        $user->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'avatar_path' => $user->avatar_path,
                'resume_path' => $user->resume_path ? 'STORED_SECURELY' : null,
            ],
        ]);
    }

    /**
     * Download resume securely (authenticated + rate limited).
     * 
     * Only the user can download their own resume
     */
    public function downloadResume(Request $request)
    {
        $user = $request->user();
        if (!$user || !$user->resume_path) {
            abort(404);
        }

        // Check if user is accessing their own resume
        if ($user->id !== $request->input('user_id') && !$user->is_admin) {
            abort(403);  // Forbidden
        }

        return Storage::disk('private')->download(
            $user->resume_path,
            'resume_' . $user->name . '.pdf',
            ['Content-Type' => 'application/pdf']
        );
    }
}
```

### 4. Update Routes

```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    // Rate limited profile update
    Route::middleware('throttle:10,1')->put('/profile', [ProfileController::class, 'update']);
    
    // Rate limited resume download
    Route::middleware('throttle:30,1')->get('/profile/resume/download', [ProfileController::class, 'downloadResume']);
});
```

### 5. Update Flutter to Download Resumes Securely

```dart
// lib/core/services/api_service.dart
Future<void> downloadResume(int userId) async {
    try {
        final response = await _dio.get(
            '/profile/resume/download?user_id=$userId',
            options: Options(
                responseType: ResponseType.bytes,
                followRedirects: true,
                maxRedirects: 5,
            ),
        );
        
        if (response.statusCode == 200) {
            // Save to device or open
            final bytes = response.data as List<int>;
            // Use package:open_file to open PDF
            // Or save to Downloads via path_provider
        }
    } on DioException catch (e) {
        if (e.response?.statusCode == 403) {
            throw ForbiddenException('Cannot access this resume');
        } else if (e.response?.statusCode == 404) {
            throw NotFoundException('Resume not found');
        }
        rethrow;
    }
}
```

---

## Security Checklist

- [x] Input validation (already in place)
- [x] File type validation (already in place)
- [x] File size limits (already in place)
- [ ] **Private storage for resumes** ← ACTION REQUIRED
- [ ] **Rate limiting on profile updates** ← ACTION REQUIRED
- [ ] **Authenticated resume download route** ← ACTION REQUIRED
- [ ] **Disk space monitoring** ← ACTION REQUIRED
- [ ] **HTTPS enforcement** (server-level in Nginx)
- [ ] **CORS whitelist** (already in Sanctum config)
- [ ] **Audit logging for file uploads**

---

## Implementation Priority

**MUST DO (Security Critical):**
1. Move resumes to private storage
2. Create protected resume download route
3. Add rate limiting to profile update

**SHOULD DO (Performance/UX):**
4. Add disk space monitoring
5. Add audit logging

**NICE TO HAVE (Enhancement):**
6. Add virus scanning for uploaded files
7. Add CloudFlare/CDN for static file delivery

