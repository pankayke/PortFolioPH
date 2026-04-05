# Flutter + Laravel Integration Fix Guide
**Date:** April 5, 2026  
**Status:** Critical fixes applied - Ready for testing

---

## 📋 CRITICAL ISSUES FIXED

### ✅ Issue #1: Mock Data Fallback (REMOVED)
**Problem:** UserRepository.registerUser() silently fell back to mock data when backend failed  
**Fix Applied:** Removed `_generateMockUserId()` fallback - now throws exception on error
**Impact:** Dev will immediately see if backend is down instead of getting fake success

### ✅ Issue #2: Token Not Saved (FIXED)
**Problem:** After login, token was never saved to secure storage  
**Fix Applied:** UserRepository.authenticate() now explicitly calls `_apiService.saveToken(token)`
**Impact:** Subsequent API calls will now use the Sanctum token

### ✅ Issue #3: Response Format Mismatch (UNDERSTOOD)
**Problem:** Flutter expected different response structure than Laravel provided  
**Fix Applied:** Updated comments to reflect actual Laravel response format
```json
// Laravel Response (from ApiResponse class):
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {"id": 1, "name": "...", "email": "...", "role": "..."},
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
  },
  "errors": null
}

// ApiService extracts 'data' field, so Flutter receives:
{
  "user": {"id": 1, ...},
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### ✅ Issue #4: Auth Provider Not Using Token (VERIFIED)
**Status:** AuthProvider correctly calls AuthService → UserRepository → saves token
**Chain:** AuthProvider.login() → AuthService.login() → UserRepository.authenticate() → _apiService.saveToken()

---

## 🔧 HOW THE INTEGRATION WORKS NOW

### 1. User Registration Flow
```
RegisterScreen ["Create Account"]
    ↓
AuthProvider.register()
    ↓
AuthService.register()
    ↓
UserRepository.registerUser()
    ↓
_apiService.post('/auth/register', {name, email, password, role})
    ↓
Laravel: AuthController.register()
    ↓
ApiResponse.success({user: {...}, token: "..."})
    ↓
[CRITICAL] UserRepository extracts token & calls _apiService.saveToken(token)
    ↓
AuthProvider updates _currentUser = user
    ↓
GoRouter redirects to /dashboard
```

### 2. User Login Flow  
```
LoginScreen ["Log In"]
    ↓
AuthProvider.login(email, password)
    ↓
AuthService.login()
    ↓
UserRepository.authenticate()
    ↓
_apiService.post('/auth/login', {email, password})
    ↓
Laravel: AuthController.login()
    ↓
ApiResponse.success({user: {...}, token: "..."})
    ↓
[CRITICAL] UserRepository extracts token & saves it securely
    ↓
AuthProvider updates _currentUser
    ↓
GoRouter redirects to /dashboard
```

### 3. Sanctum Token Auto-Injection
```
Any API Call (login, get jobs, apply, etc.)
    ↓
_onRequest() interceptor fires
    ↓
Reads token from flutter_secure_storage
    ↓
Adds to all requests: Authorization: Bearer <token>
    ↓
ApiService.get/post/put/delete()
    ↓
Laravel middleware (auth:sanctum) verifies token
    ↓
Request succeeds with authenticated user context
```

### 4. 401 Handling (Session Expired)
```
API returns 401 Unauthorized
    ↓
_handleResponse() throws UnauthorizedException
    ↓
_onError() catches 401 → deletes token from storage
    ↓
UI should redirect to /login
    ↓
User sees: "Session expired. Please login again."
```

---

## ✅ TESTING CHECKLIST

### TIER 1: FOUNDATION (Test First)

#### T1-1: Backend is Running
```bash
# Terminal 1: Start Laravel server
cd portfoliophhadmin
php artisan serve
# ✅ Should show: "Laravel development server started at [http://127.0.0.1:8000]"
```

#### T1-2: API Health Check
```bash
# Terminal 2: Test API is responding
curl http://127.0.0.1:8000/api/health

# Expected response:
# {"status":"ok","timestamp":"2026-04-05T..."}
```

#### T1-3: Flutter App Connects
```bash
# Terminal 3: Start Flutter app
cd c:\Users\USER\portfolioph
flutter run -d chrome  # Or -d android

# Watch console for:
# [ApiService] Response 200 | /health
```

---

### TIER 2: AUTH FLOW (Critical Path)

#### T2-1: Register New User
**Action:** In Flutter app, go to RegisterScreen
1. Username: `testuser_$(date +%s)` (make unique)
2. Email: `test_$(date +%s)@example.com`
3. Password: `Password123!`
4. Full Name: `Test User`
5. Tap "Create Account"

**Check Laravel Server Logs:**
```
[...] Processing POST /api/auth/register
[...] INSERT INTO users (username, email, password_hash, name, role)
[...] Response: 201 Created → {"success":true,"data":{"user":{...},"token":"..."}}
```

**Check Flutter Console:**
```
[ApiService] Response 201 | /auth/register
[UserRepository] Login successful - token saved
[AuthProvider] Registration completed
```

**Check Flutter UI:**
- ✅ RegisterScreen clears
- ✅ Load spinner appears briefly
- ✅ Redirect to ProfileSetupScreen (or DashboardScreen)
- ❌ ERROR: Stay on RegisterScreen with SnackBar = **REGISTRATION FAILED**

---

#### T2-2: Login with Registered User
**Action:** 
1. Go back to LoginScreen
2. Email: (same as registered above)
3. Password: (same as registered above)
4. Tap "Log In"

**Check Laravel Logs:**
```
[...] Processing POST /api/auth/login
[...] SELECT * FROM users WHERE email = ?
[...] Password verification ✓
[...] Response: 200 OK → {"success":true,"data":{"user":{...},"token":"..."}}
```

**Check Flutter Console:**
```
[ApiService] Response 200 | /auth/login
[UserRepository] Login successful - token saved
```

**Check Flutter Secure Storage:**
```bash
# After successful login, token SHOULD be saved
# Can verify in DevTools → Application → Session Storage
```

**Check Flutter UI:**
- ✅ LoginScreen clears
- ✅ DashboardScreen appears with real data

---

#### T2-3: Session Persistence
**Action:**
1. Logged in on DashboardScreen
2. Close Flutter app completely (or browser tab)
3. Reopen Flutter app

**Expected:**
- ✅ SplashScreen briefly shows
- ✅ DashboardScreen appears (not LoginScreen)
- Why? Token is still in secure storage

**Check Flutter Console:**
```
[SplashScreen] Checking session...
[AuthProvider] Session restored

 - currentUser is not null (from secure storage)
```

---

### TIER 3: DATA FLOWS

#### T3-1: Fetch Jobs (Real Data from DB)
**Action:**
1. Logged in on DashboardScreen
2. Navigate to Jobs screen
3. Wait for data to load

**Check Laravel DB:**
```bash
# In Laravel admin dashboard or MySQL client
SELECT * FROM jobs LIMIT 5;

# Should show jobs in database
```

**Check Dio Logs:**
```
[ApiService] Response 200 | /jobs
```

**Check Flutter UI:**
- ✅ Jobs list populated with real data from MySQL
- ❌ Empty list = **API call succeeded but no jobs in DB**
- ❌ Error = **API call failed - check error message**

---

#### T3-2: Apply for Job
**Action:**
1. On Jobs list, select a job
2. Tap "Apply"
3. Fill application form
4. Submit

**Check Laravel DB:**
```sql
SELECT * FROM applications WHERE user_id = ? ORDER BY created_at DESC LIMIT 1;
```

**Check Flutter UI:**
- ✅ Success message appears
- ✅ Application disappears from "Apply" list

---

#### T3-3: View My Applications
**Action:**
1. Navigate to "My Applications"
2. Verify applications listed

**Check Laravel Logs:**
```
[...] Processing GET /api/applications
[...] SELECT * FROM applications WHERE user_id = ? ...
[...] Response 200 OK
```

**Check Flutter UI:**
- ✅ Applications list shows recent applications
- ✅ Each has status badge (Pending, Accepted, Rejected)

---

## 🐛 DEBUGGING TOOLKIT

### Enable Debug Logging
Add to `lib/main.dart`:
```dart
import 'dart:developer' as developer;

void main() async {
  // ... existing code ...
  
  if (kDebugMode) {
    developer.log('🚀 PortFolioPH starting in debug mode');
    // Dio logs already enabled in ApiService
  }
  
  runApp(const App());
}
```

### Common Issues & Fixes

#### Issue: "Connection refused" on api call
```
Error: Failed to connect to 127.0.0.1:8000
```
**Fix:**
```bash
# Check Laravel is running
ps aux | grep "artisan serve"

# If not, start it:
cd portfoliophhadmin
php artisan serve
```

---

#### Issue: 401 Unauthorized on every request
```
[UserRepository] Login successful - token saved
[ApiService] Response 401 | /jobs
[ApiService] Token cleared - unauthorized
```
**Likely Causes:**
1. Laravel Sanctum tokens misconfigured
2. Token expiration/revocation on backend
3. Token header format incorrect

**Fix:**
```bash
# Check Sanctum is installed
composer show laravel/sanctum

# Check database has tokens
SELECT * FROM personal_access_tokens;

# If empty, tokens not being created - check AuthService.createToken()
```

---

#### Issue: Registration succeeds but token not saved
```
[ApiService] Response 201 | /auth/register
[UserRepository] Registration successful - token saved ❌ NOT PRINTING
```
**Likely Cause:** Token not in response

**Fix:**
```bash
# Check Laravel response format
# Terminal 1:
curl -X POST http://127.0.0.1:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test",
    "email": "test@test.com",
    "password": "password",
    "role": "job_seeker"
  }' | jq .

# Should show:
# {
#   "success": true,
#   "message": "Registration successful",
#   "data": {
#     "user": {...},
#     "token": "eyJ0eXAiOiJKV1QiLC..."
#   },
#   "errors": null
# }
```

---

#### Issue: Data is empty after login
```
DashboardScreen → Jobs list is empty
But user IS authenticated (token is valid)
```
**Likely Cause:** No jobs in Laravel database

**Fix:**
```bash
# Check jobs exist in Laravel DB
mysql -u root -p portfolioph_db
SELECT COUNT(*) FROM jobs;

# If 0, run seeders:
php artisan db:seed --class=JobSeeder
php artisan db:seed --class=ApplicationSeeder

# Check jobs have correct status
SELECT id, title, status FROM jobs LIMIT 5;
```

---

### Network Inspection Checklist

In Flutter DevTools (Chrome):
1. **Network Tab:**
   - Should see requests to `127.0.0.1:8000/api/...`
   - Status should be 200, 201, or 401 (not 500)
   - Headers should include `Authorization: Bearer ...`

2. **Request Headers to Verify:**
   ```
   Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...  ← Token present?
   Content-Type: application/json                     ← Should be here
   ```

3. **Response Headers to Verify:**
   ```
   Content-Type: application/json
   X-Frame-Options: DENY
   ```

---

## 📝 ENDPOINT VERIFICATION

Test each endpoint manually to ensure backend is working:

### Public Endpoints (No Auth)
```bash
# Health check
curl http://127.0.0.1:8000/api/health

# Register
curl -X POST http://127.0.0.1:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","password":"password"}'

# Login  
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password"}'

# List jobs
curl http://127.0.0.1:8000/api/jobs
```

### Protected Endpoints (Require Token)
```bash
# Get current user
TOKEN="eyJ0eXAiOiJKV1QiLCJhbGc..."
curl -H "Authorization: Bearer $TOKEN" \
  http://127.0.0.1:8000/api/auth/me

# Get user applications
curl -H "Authorization: Bearer $TOKEN" \
  http://127.0.0.1:8000/api/applications

# Create application
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"job_id": 1}' \
  http://127.0.0.1:8000/api/applications
```

---

## 🎯 SUCCESS CRITERIA (Minimum Working Integration)

- [ ] Register new user → Success + redirects to dashboard
- [ ] Login with credentials → Success + token saved + redirects to dashboard  
- [ ] Refresh page → Still authenticated (session persisted)
- [ ] View jobs → Real jobs from Laravel DB displayed
- [ ] Apply to job → Application saved in Laravel DB
- [ ] Token automatically injected in all requests
- [ ] 401 response → User redirected to login
- [ ] Console shows NO exceptions (only debug logs)
- [ ] Network tab shows Bearer token in Authorization header

---

## 🚨 FINAL CHECKLIST BEFORE PRODUCTION

- [ ] Remove all `debugPrint()` statements that log sensitive data
- [ ] Set API baseUrl to production domain (not localhost)
- [ ] Verify `.env` file has correct database credentials
- [ ] Enable HTTPS on production API
- [ ] Set up CORS properly on Laravel (if frontend hosted separately)
- [ ] Test error scenarios:
  - [ ] Wrong password
  - [ ] Non-existent email
  - [ ] Network timeout
  - [ ] 500 server error
  - [ ] Expired token
- [ ] Run full end-to-end test:
  - Register → Login → Apply → Check DB → Logout → Login again

---

## 📞 If Integration Still Fails

**IMMEDIATELY CHECK:**

1. Is Laravel running?
   ```bash
   lsof -i :8000
   ```

2. Can you reach the API?
   ```bash
   curl http://127.0.0.1:8000/api/health
   ```

3. Are database tables created?
   ```bash
   php artisan migrate:status
   ```

4. Is Sanctum installed & configured?
   ```bash
   composer show laravel/sanctum
   grep -r "Laravel\\\Sanctum" config/
   ```

5. Check Laravel logs:
   ```bash
   tail -f storage/logs/laravel.log
   ```

If still stuck → **Save all console output + API response + Laravel logs in issue report**
