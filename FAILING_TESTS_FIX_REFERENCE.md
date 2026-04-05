# 🔴 FAILING TESTS → EXACT CODE FIXES REFERENCE

**Purpose:** When a test fails, use this guide to find the exact code issue and fix

---

## ❌ SYMPTOM: Login succeeds but app crashes on next action

**Root Cause Chain to Check:**

### Check 1: Token Not Returned from API
**File:** [portfoliophhadmin/app/Http/Controllers/AuthController.php](portfoliophhadmin/app/Http/Controllers/AuthController.php#L38)

```php
// WRONG - Token not returned
public function login(Request $request): JsonResponse {
    $user = User::where('email', $request->email)->first();
    if (!Hash::check($request->password, $user->password)) {
        return ApiResponse::error('Invalid credentials', 401);
    }
    return ApiResponse::success($user, 'Login successful');  // ❌ No token!
}

// CORRECT - Token returned
public function login(Request $request): JsonResponse {
    $user = User::where('email', $request->email)->first();
    if (!Hash::check($request->password, $user->password)) {
        return ApiResponse::error('Invalid credentials', 401);
    }
    $token = $this->authService->createToken($user);  // ✅ Get token
    return ApiResponse::success([  // ✅ Return both
        'user' => $user,
        'token' => $token
    ], 'Login successful');
}
```

**Test:** 
```bash
POST /api/auth/login
# Response should have: {success: true, data: {user: {...}, token: "..."}}
```

---

### Check 2: Token Not Saved in Flutter
**File:** [lib/data/repositories/user_repository.dart](lib/data/repositories/user_repository.dart#L45)

```dart
// WRONG - Token not saved
Future<void> authenticate(String email, String password) async {
    final response = await _apiService.post('/auth/login', data: {...});
    final token = response['token'];  // ❌ Not used!
    return response['user'];
}

// CORRECT - Token explicitly saved
Future<void> authenticate(String email, String password) async {
    final response = await _apiService.post('/auth/login', data: {...});
    final token = response['token'];
    if (token != null && token.isNotEmpty) {
        await _apiService.saveToken(token);  // ✅ EXPLICIT save
    }
    return response['user'];
}
```

**Debug Check:**
```dart
// In login_page.dart or auth_provider.dart
final token = await _apiService.getToken();
print('Token after login: $token');
// Should NOT be null
```

---

### Check 3: Next Request Missing Bearer Token
**File:** [lib/core/services/api_service.dart](lib/core/services/api_service.dart#L62)

```dart
// WRONG - No Bearer injection
Future<Response> _onRequest(RequestOptions options) async {
    // ❌ Token not added
    return options;
}

// CORRECT - Bearer token injected
Future<Response> _onRequest(RequestOptions options) async {
    const tokenKey = 'api_token';
    final token = await _secureStorage.read(key: tokenKey);
    if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';  // ✅ Injected
    }
    return options;
}
```

**Network Verification:**
```
POST /api/jobs (or any protected endpoint)
Headers: Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
# Should be present in all requests after login
```

---

## ❌ SYMPTOM: App shows login screen when it should show dashboard (app restart)

**Root Cause:** Session restore not working

### Check 1: No Auth State Restored on Startup
**File:** [lib/presentation/screens/splash/splash_screen.dart](lib/presentation/screens/splash/splash_screen.dart#L45)

```dart
// WRONG - Auth state never checked
class SplashScreen extends StatefulWidget {
    @override
    State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
    void _init() {
        Future.delayed(Duration(seconds: 3), () {
            if (!mounted) return;
            Navigator.of(context).pushReplacementNamed('/login');  // ❌ Always shows login
        });
    }
}

// CORRECT - Auth state restored
class _SplashScreenState extends State<SplashScreen> {
    void _init() async {
        await Future.delayed(Duration(seconds: 3));
        if (!mounted) return;
        
        final authProvider = context.read<AuthProvider>();
        final isLoggedIn = await authProvider.restoreSession();  // ✅ Check session
        
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(
            isLoggedIn ? '/dashboard' : '/login'
        );
    }
}
```

**Test:** Print debug info
```dart
void _init() async {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.restoreSession();
    print('App restart - Session restored: $isLoggedIn');  // Should print true
}
```

---

### Check 2: restoreSession() Always Returns False
**File:** [lib/presentation/providers/auth_provider.dart](lib/presentation/providers/auth_provider.dart#L85)

```dart
// WRONG - Always returns false
Future<bool> restoreSession() async {
    return false;  // ❌ Session never restored
}

// CORRECT - Checks for token and verifies
Future<bool> restoreSession() async {
    final hasToken = await _authService.hasToken();
    if (!hasToken) return false;
    
    try {
        final user = await _authService.getCurrentUser();  // Calls /auth/me
        if (user != null) {
            _currentUser = user;  // ✅ Restore user state
            return true;
        }
    } catch (e) {
        print('Session restore failed: $e');
    }
    return false;
}
```

**Test:** Check if /auth/me is called
```
On app startup, network tab should show:
GET /api/auth/me
Status: 200 OK (if token valid)
Response: {success: true, data: {id: ..., email: ..., role: ...}}
```

---

### Check 3: Backend /auth/me Not Working
**File:** [portfoliophhadmin/app/Http/Controllers/AuthController.php](portfoliophhadmin/app/Http/Controllers/AuthController.php#L58)

```php
// WRONG - No middleware, always returns null
public function me(Request $request): JsonResponse {
    return ApiResponse::success(null, 'Current user');  // ❌ Always null
}

// CORRECT - Protected by auth:sanctum
public function me(Request $request): JsonResponse {
    $user = $request->user();  // ✅ From auth:sanctum middleware
    if (!$user) {
        return ApiResponse::error('Not authenticated', 401);
    }
    return ApiResponse::success(
        $user->only(['id', 'email', 'name', 'role']),
        'Current user retrieved'
    );
}

// In routes/api.php:
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);  // ✅ Protected
});
```

**Test:**
```bash
# Without token - should fail
curl http://localhost:8000/api/auth/me
# Status: 401 Unauthorized

# With token - should succeed
curl -H "Authorization: Bearer TOKEN" http://localhost:8000/api/auth/me
# Status: 200 OK, Response: {success: true, data: {user...}}
```

---

## ❌ SYMPTOM: 401 error appears but app doesn't auto-logout

**Root Cause:** 401 error not handled

### Check 1: No 401 Handler in Dio
**File:** [lib/core/services/api_service.dart](lib/core/services/api_service.dart#L85)

```dart
// WRONG - 401 not handled
void _onError(DioException error, ErrorInterceptorHandler handler) {
    handler.next(error);  // ❌ Error not handled
}

// CORRECT - 401 clears token
void _onError(DioException error, ErrorInterceptorHandler handler) {
    if (error.response?.statusCode == 401) {
        _secureStorage.delete(key: tokenKey);  // ✅ Clear token
        // Navigator to login can happen here or in app level error handler
    }
    handler.next(error);
}
```

---

### Check 2: App Level 401 Not Handled
**Best practice:** Global error handler in main MaterialApp

```dart
// main.dart - Add to MaterialApp
MaterialApp(
    home: _ErrorBoundary(
        child: MyApp(),
    ),
)

class _ErrorBoundary extends StatefulWidget {
    final Widget child;
    const _ErrorBoundary({required this.child});
    
    @override
    State<_ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
    @override
    void initState() {
        super.initState();
        Dio.instance.interceptors.add(
            InterceptorsWrapper(
                onError: (error, handler) {
                    if (error.response?.statusCode == 401) {
                        // Clear auth and navigate to login
                        context.read<AuthProvider>().logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false,
                        );
                    }
                    return handler.next(error);
                },
            ),
        );
    }
    
    @override
    Widget build(BuildContext context) => child;
}
```

---

## ❌ SYMPTOM: Logout button doesn't work (token still valid after logout)

**Root Cause:** Backend not invalidating token

### Check 1: Logout Not Deleting Tokens
**File:** [portfoliophhadmin/app/Services/AuthService.php](portfoliophhadmin/app/Services/AuthService.php#L35)

```php
// WRONG - Token still valid
public function logout(User $user): void {
    // ❌ Nothing done
}

// CORRECT - All tokens deleted
public function logout(User $user): void {
    $user->tokens()->delete();  // ✅ Sanctum tokens deleted
}
```

**Test:**
```bash
# 1. Get token
POST /api/auth/login
Response: {token: "TOKEN123"}

# 2. Verify token works
GET /api/auth/me
Authorization: Bearer TOKEN123
Status: 200 OK

# 3. Logout
POST /api/auth/logout
Authorization: Bearer TOKEN123
Status: 200 OK

# 4. Verify token no longer works
GET /api/auth/me
Authorization: Bearer TOKEN123
Status: 401 Unauthorized  # ✅ Should fail now
```

**Database Check:**
```bash
# Before logout:
sqlite3 database.sqlite
SELECT * FROM personal_access_tokens;
# Shows entries for user

# After logout:
SELECT * FROM personal_access_tokens;
# Should be empty or have user's tokens deleted
```

---

### Check 2: Flutter Not Clearing Local Token
**File:** [lib/presentation/providers/auth_provider.dart](lib/presentation/providers/auth_provider.dart#L105)

```dart
// WRONG - Token not cleared
Future<void> logout() async {
    _currentUser = null;
    // ❌ Token still in storage
}

// CORRECT - Token cleared
Future<void> logout() async {
    try {
        await _authService.logout();  // Calls API logout
    } catch (e) {
        print('Logout API failed: $e');
    }
    await _authService.clearToken();  // ✅ Clear from storage
    _currentUser = null;
    notifyListeners();
}
```

---

## ❌ SYMPTOM: Network error causes app crash instead of error message

**Root Cause:** No error handling in UI

### Check 1: No Try-Catch Around API Calls
**File:** [lib/presentation/screens/login/login_screen.dart](lib/presentation/screens/login/login_screen.dart#L60) (example)

```dart
// WRONG - No error handling
void _handleLogin() async {
    await authProvider.login(email, password);  // ❌ Crash if network error
    Navigator.of(context).pushReplacementNamed('/dashboard');
}

// CORRECT - Error caught and shown
void _handleLogin() async {
    try {
        await authProvider.login(email, password);
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/dashboard');
    } on DioException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.message}')),
        );
    } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unexpected error: $e')),
        );
    }
}
```

---

### Check 2: API Service Not Throwing Proper Errors
**File:** [lib/core/services/api_service.dart](lib/core/services/api_service.dart#L110)

```dart
// WRONG - Errors swallowed
Future<dynamic> post(String endpoint, {required dynamic data}) async {
    try {
        return await _dio.post(endpoint, data: data);
    } catch (e) {
        return null;  // ❌ Error hidden, returns null
    }
}

// CORRECT - Errors propagated
Future<dynamic> post(String endpoint, {required dynamic data}) async {
    try {
        final response = await _dio.post(endpoint, data: data);
        return response.data['data'];  // Extract 'data' field
    } on DioException {
        rethrow;  // ✅ Let caller handle
    }
}
```

---

## ❌ SYMPTOM: GET /auth/me returns 404 even with valid token

**Root Cause:** Route not defined

### Check 1: Route Not Protected by Middleware
**File:** [portfoliophhadmin/routes/api.php](portfoliophhadmin/routes/api.php#L X)

```php
// WRONG - No middleware
Route::get('/auth/me', [AuthController::class, 'me']);  // ❌ Accessible without auth

// CORRECT - Protected by auth:sanctum
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);  // ✅ Requires token
});
```

**Test:**
```bash
# Check Laravel routes
cd portfoliophhadmin
php artisan route:list | grep 'auth/me'

# Should show: GET /auth/me ... auth:sanctum ... AuthController@me
```

---

## ✅ VERIFICATION CHECKLIST

After applying fixes, verify each one:

- [ ] Token returned from `/auth/login`
- [ ] Token saved in secure storage after auth
- [ ] Bearer token in all subsequent requests
- [ ] `/auth/me` returns current user with 200 status
- [ ] Session restores on app restart
- [ ] `/auth/logout` returns 200
- [ ] Token deleted from database after logout
- [ ] 401 errors clear local token
- [ ] Network errors show UI message, not crash
- [ ] Route protection working (401 on missing token)

---

**Generated:** April 5, 2026  
**Status:** Deploy these fixes when tests fail
