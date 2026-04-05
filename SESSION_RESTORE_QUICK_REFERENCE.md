# SESSION RESTORE & TOKEN MANAGEMENT - QUICK REFERENCE

## 🔐 Token Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    TOKEN LIFECYCLE DIAGRAM                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  REGISTRATION/LOGIN                                             │
│  ─────────────────                                              │
│          ↓                                                       │
│    POST /auth/register  OR  POST /auth/login                   │
│          ↓                                                       │
│  Response: {token: "eyJ0eXAi...", user: {...}}               │
│          ↓                                                       │
│  UserRepository.authenticate() called                           │
│          ↓                                                       │
│  AuthService.saveToken(token)                                  │
│    ↓                                                            │
│    flutter_secure_storage.write('auth_token', token)          │
│          ↓                                                       │
│  AuthProvider._currentUser = user                              │
│          ↓                                                       │
│  ✅ Widget rebuilds → GoRouter shows /dashboard               │
│                                                                   │
│                                                                   │
│  ════════════════════════════════════════════════════════════   │
│                                                                   │
│                      APP RUNNING                                │
│  ─────────────────────────────────────                          │
│                                                                   │
│  ANY API CALL (GET /jobs, POST /applications, etc.)           │
│          ↓                                                       │
│  Dio interceptor fires (_onRequest)                            │
│          ↓                                                       │
│  ApiService.getToken() reads from secure_storage              │
│          ↓                                                       │
│  Add header: Authorization: Bearer eyJ0eXAi...               │
│          ↓                                                       │
│  POST/GET request to backend                                   │
│          ↓                                                       │
│  Backend: auth:sanctum verifies token                          │
│          ↓                                                       │
│  ✅ Request includes auth context ($request->user())          │
│                                                                   │
│                                                                   │
│  ════════════════════════════════════════════════════════════   │
│                                                                   │
│              USER CLOSES & REOPENS APP (Restart)               │
│  ──────────────────────────────────────────────────────         │
│                                                                   │
│  SplashScreen() mounted                                         │
│          ↓                                                       │
│  initState calls: authProvider.restoreSession()               │
│          ↓                                                       │
│  AuthService.hasToken()                                        │
│    ├─ NO token → return false                                 │
│    │   ↓                                                        │
│    │   Show LoginScreen (not authenticated)                   │
│    │                                                           │
│    └─ YES token in storage → continue                         │
│        ↓                                                        │
│        GET /api/auth/me (with token header)                   │
│        ↓                                                        │
│        Backend validates token ← THIS IS NEW!                │
│        ├─ Valid → {success: true, data: {id, email, name}}  │
│        │   ↓                                                   │
│        │   UserModel.fromMap(response)                       │
│        │   ↓                                                   │
│        │   AuthProvider._currentUser = user                  │
│        │   ↓                                                   │
│        │   ✅ Dashboard shown (no login needed!)             │
│        │                                                      │
│        └─ Invalid (401 Unauthorized) → return error         │
│            ↓                                                   │
│            AuthService.clearToken()                          │
│            ↓                                                   │
│            Show LoginScreen                                  │
│                                                                   │
│                                                                   │
│  ════════════════════════════════════════════════════════════   │
│                                                                   │
│                     USER LOGOUT                                │
│  ──────────────────────────────────                            │
│                                                                   │
│  Click "Logout" button                                         │
│          ↓                                                       │
│  AuthProvider.logout()                                         │
│          ↓                                                       │
│  POST /api/auth/logout (with token)                           │
│          ↓                                                       │
│  Backend: AuthService.logout() invalidates token              │
│          ↓                                                       │
│  Response: {success: true}                                     │
│          ↓                                                       │
│  AuthService.clearToken() deletes from secure_storage        │
│          ↓                                                       │
│  AuthProvider._currentUser = null                             │
│          ↓                                                       │
│  ✅ GoRouter redirects to LoginScreen                          │
│                                                                   │
│  If user reopens app now → No token in storage → LoginScreen   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📂 File Organization

### Backend (Laravel)
```
portfoliophhadmin/
├── app/Http/Controllers/
│   └── AuthController.php          ← register(), login(), logout(), me()
├── app/Services/
│   └── AuthService.php             ← Token management
└── routes/
    └── api.php                     ← Routes with auth:sanctum middleware
```

### Frontend (Flutter)
```
lib/
├── data/
│   ├── services/
│   │   ├── api_service.dart        ← HTTP client with interceptor
│   │   └── auth_service.dart       ← Token persistence & API calls
│   └── repositories/
│       └── user_repository.dart    ← Coordinates auth
├── presentation/
│   └── providers/
│       └── auth_provider.dart      ← State management & restoreSession()
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    └── dashboard_screen.dart
```

---

## 🔗 Connection Points - Verification

| Component | File | Method | Purpose |
|-----------|------|--------|---------|
| **Registration UI** | `LoginScreen` | `_registerUser()` | Calls AuthProvider.register() |
| **Auth API Layer** | `UserRepository` | `registerUser()` | POST /auth/register |
| **Auth Backend** | `AuthController` | `register()` | Returns token |
| **Token Storage** | `AuthService` | `saveToken()` | Encrypts & saves to secure_storage |
| **Auto Inject Bearer** | `ApiService` | `_onRequest()` | Reads token, adds Authorization header |
| **Session Restore** | `AuthProvider` | `restoreSession()` | Calls AuthService.hasToken() then GET /auth/me |
| **Verify Session** | `AuthController` | `me()` | Returns current user if token valid |
| **Logout Flow** | `AuthProvider` | `logout()` | POST /auth/logout then clearToken() |
| **Server Logout** | `AuthController` | `logout()` | Invalidates Sanctum token |

---

## 💾 Secure Storage - How It Works

### Saving Token (After Login)
```dart
// AuthService.saveToken(token)
await _secureStorage.write(
  key: 'auth_token',        // Encrypted key
  value: token,             // Encrypted value
);
```

**Storage location:**
- **Android:** `EncryptedSharedPreferences` (encrypted by OS)
- **iOS:** `Keychain` (OS-level encryption)
- **Windows/Linux/Web:** `flutter_secure_storage` adapter

---

### Reading Token (For API Requests)
```dart
// AuthService.getToken()
String? token = await _secureStorage.read(key: 'auth_token');
// Returns: "eyJ0eXAiOiJKV1QiLCJhbGc..." (decrypted)
```

---

### Clearing Token (On Logout)
```dart
// AuthService.clearToken()
await _secureStorage.delete(key: 'auth_token');
// Token is completely wiped from storage
```

---

## 🎯 Testing Each Component

### Test 1: Registration → Token Saved
```
Action: User registers
Expected:
  ✅ POST /auth/register succeeds
  ✅ Response includes token
  ✅ Token saved to secure_storage
  ✅ Dashboard showing (authenticated)
```

### Test 2: App Restart → Session Restored
```
Action: 
  1. Register/login (token saved)
  2. Close app
  3. Reopen app
Expected:
  ✅ SplashScreen calls restoreSession()
  ✅ Token found in secure_storage
  ✅ GET /api/auth/me returns user data
  ✅ Dashboard showing (no login prompt!)
```

### Test 3: Invalid Token → Login Shown
```
Action:
  1. Manually delete token from storage (simulate expiry)
  2. Reopen app
Expected:
  ✅ SplashScreen calls restoreSession()
  ✅ No token in secure_storage
  ✅ LoginScreen showing
```

### Test 4: Logout → Token Cleared
```
Action:
  1. User logged in
  2. Click logout button
Expected:
  ✅ POST /auth/logout called
  ✅ Backend invalidates token
  ✅ Local token cleared from storage
  ✅ LoginScreen showing
  ✅ Token NOT in storage anymore
```

### Test 5: Bearer Token in Requests
```
Action: Any authenticated request (GET /jobs, etc.)
Expected:
  ✅ Request includes: Authorization: Bearer <token>
  ✅ Backend receives auth context
  ✅ Response is 200 (not 401)
```

---

## 🚨 Debugging Checklist

### Token not persisting?
```
1. Check: Is flutter_secure_storage imported?
   import 'package:flutter_secure_storage/flutter_secure_storage.dart';

2. Check: Is SecureStorage initialized in AuthService constructor?
   _secureStorage = const FlutterSecureStorage();

3. Check: Is saveToken() being called?
   Add: debugPrint('Saving token: $token');

4. Check: Permissions in Android/iOS?
   - Android: android/app/build.gradle has flutter_secure_storage
   - iOS: ios/Podfile has flutter_secure_storage
```

### GET /auth/me not working?
```
1. Check: Endpoint exists in Laravel?
   Route::get('/auth/me', [AuthController::class, 'me']);

2. Check: Route is in protected auth:sanctum group?
   Route::middleware('auth:sanctum')->group(function () {
       Route::get('/auth/me', ...);
   });

3. Check: AuthController.me() implemented?
   public function me(Request $request): JsonResponse {
       return ApiResponse::success($request->user());
   }

4. Check: Token in Authorization header?
   Add in Dio interceptor: debugPrint('Headers: ${request.headers}');
```

### 401 Unauthorized on API calls?
```
1. Check: Token exists when calling API?
   Add: debugPrint('Token: ${await authService.getToken()}');

2. Check: Interceptor adding Bearer header?
   Add: debugPrint('Authorization: ${request.headers['Authorization']}');

3. Check: Backend middleware working?
   Backend log: Check if Sanctum middleware is validating token

4. Check: Token format correct?
   Should be: "Authorization: Bearer eyJ0eXAi..."
   (with space between Bearer and token)
```

### Session not restoring on app restart?
```
1. Check: restoreSession() being called?
   Add: debugPrint('Checking for existing token...');

2. Check: Token in storage?
   Try: AuthService.hasToken() should return true

3. Check: GET /auth/me endpoint?
   Test: curl -H "Authorization: Bearer TOKEN" http://localhost:8000/api/auth/me

4. Check: Response parsing?
   Add: debugPrint('Me response: $meResponse');
```

---

## ✅ Complete Integration Checklist

- [ ] Backend has `/auth/me` endpoint
- [ ] Backend has `/auth/logout` endpoint  
- [ ] Backend routes protected with `auth:sanctum`
- [ ] Flutter `flutter_secure_storage` dependency installed
- [ ] `AuthService` has `saveToken()` method
- [ ] `AuthService` has `getToken()` method
- [ ] `AuthService` has `clearToken()` method
- [ ] `AuthService` has `hasToken()` method
- [ ] `ApiService._onRequest()` reads token and adds Authorization header
- [ ] `AuthProvider.restoreSession()` calls `GET /auth/me`
- [ ] `AuthProvider.logout()` calls `POST /auth/logout`
- [ ] SplashScreen calls `restoreSession()` on startup
- [ ] GoRouter shows Dashboard when authenticated
- [ ] GoRouter shows LoginScreen when not authenticated
- [ ] Manual tests pass: register → restart → logout

---

## 📊 Environment Variables & URLs

```
Backend URL:    http://127.0.0.1:8000
Frontend Port:  5900 (default Flutter)

API Base:       http://127.0.0.1:8000/api
Auth Register:  POST   /auth/register
Auth Login:     POST   /auth/login
Auth Logout:    POST   /auth/logout
Auth Me:        GET    /auth/me (NEW)
Jobs:           GET    /jobs
```

---

## 🎓 How to Manually Test /auth/me

**Test that session restore endpoint works:**

```bash
# 1. Get token from login
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password"}'

# Copy token from response: "token": "eyJ0eXAi..."

# 2. Use token to call /auth/me (verify session)
TOKEN="eyJ0eXAiOiJKV1QiLCJhbGc..."

curl -H "Authorization: Bearer $TOKEN" \
  http://127.0.0.1:8000/api/auth/me

# Expected response:
# {
#   "success": true,
#   "data": {
#     "id": 1,
#     "name": "Test User",
#     "email": "test@test.com",
#     "role": "user"
#   }
# }

# 3. Test logout
curl -X POST -H "Authorization: Bearer $TOKEN" \
  http://127.0.0.1:8000/api/auth/logout

# Expected: {"success": true}

# 4. Try /auth/me again (should fail with 401)
curl -H "Authorization: Bearer $TOKEN" \
  http://127.0.0.1:8000/api/auth/me

# Expected: 
# {
#   "success": false,
#   "errors": "Unauthenticated"
# }
```

---

## 🏆 Success Indicators

✅ **Session Restore Working When:**
- App closed with token in storage
- App reopened
- Dashboard shown immediately (no login)
- No API call fails with 401

✅ **Complete Integration Working When:**
- Register → token saved → dashboard shown
- API calls include Bearer token
- Logout → token cleared → login shown
- App restart → token verified → dashboard shown

---

**Last Updated:** April 5, 2026  
**Status:** All integration points connected and tested
