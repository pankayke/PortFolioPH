# 🎯 REAL RUNTIME TEST SCENARIOS - MANUAL EXECUTION GUIDE

**Purpose:** Execute these tests manually to verify the complete integration works end-to-end  
**Prerequisite:** Laravel server running on `localhost:8000` and Flutter app ready

---

## 📋 TEST SCENARIOS

### SCENARIO 1: COMPLETE REGISTRATION → LOGIN → DASHBOARD FLOW (15 min)

#### Test 1.1: User Registration
**Steps:**
1. Launch Flutter app
2. Navigate to Registration page
3. Enter:
   - Name: `Test User 2026`
   - Email: `testuser@test2026.com`
   - Password: `TestPass123!`
   - Username: `testuser2026`
4. Click Register

**Expected Results:**
- ✅ Registration succeeds (no error)
- ✅ Dashboard shown immediately (not login screen)
- ✅ User name visible in profile/header
- ✅ No login screen is shown

**Database Verification:**
```bash
sqlite3 database.sqlite
SELECT * FROM users WHERE email = 'testuser@test2026.com';
# Should return 1 row with user ID, email, name
```

**Network Verification (DevTools):**
```
POST /api/auth/register
Status: 201 Created
Response: {success: true, data: {user: {...}, token: "..."}}
```

---

#### Test 1.2: Token Persistence After Registration
**Steps:**
1. While logged in from Test 1.1
2. Open DevTools → Storage/Preferences
3. Check secure storage for token
4. Make any API call (e.g., view jobs)

**Expected Results:**
- ✅ Token visible in secure storage
- ✅ Network request includes `Authorization: Bearer <token>`
- ✅ No 401 errors

**Network Verification:**
```
GET /api/jobs
Headers include: Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
Status: 200 OK
Response: {success: true, data: [...]}
```

---

### SCENARIO 2: SESSION RESTORE ON APP RESTART (10 min) - CRITICAL

**Steps:**
1. User logged in from Scenario 1
2. Dashboard is showing
3. Force close the app:
   - **iOS:** Swipe up to close
   - **Android:** Swipe up or press home twice + close
   - **Emulator:** Alt+F4 or close window
4. Wait 2 seconds
5. Reopen the app (tap app icon)

**Expected Results:**
- ✅ SplashScreen shows for 3 seconds
- ✅ **NO login screen appears**
- ✅ Dashboard shown with user data
- ✅ Previous jobs/applications still visible
- ✅ User name still shown in profile area

**What's FAILING here (app restart shows login instead of dashboard):**
```
❌ Token not in secure storage
  → Check: Is token being saved?
  → Check: Is secure storage initialized?
  → Fix: Verify UserRepository.authenticate() calls saveToken()

❌ Session restore not called
  → Check: Is restoreSession() in SplashScreen?
  → Check: Is AuthProvider.restoreSession() implemented?
  → Fix: Ensure _init() in splash_screen calls restoreSession()

❌ GET /auth/me returns 401
  → Check: Token corrupted?
  → Check: Backend Sanctum middleware?
  → Fix: Verify token was actually saved
```

**Network Verification:**
```
On app startup:
GET /api/auth/me
Headers include: Authorization: Bearer <token>
Status: 200 OK
Response: {success: true, data: {id: 1, email: "testuser@test2026.com", role: "..."}}
```

---

### SCENARIO 3: LOGOUT AND LOGIN WITH NEW USER (10 min)

#### Test 3.1: Logout
**Steps:**
1. From dashboard (logged in)
2. Navigate to settings/profile
3. Click "Logout" button

**Expected Results:**
- ✅ Logout API called
- ✅ Redirected to Login screen
- ✅ Token cleared from storage

**Network Verification:**
```
POST /api/auth/logout
Headers include: Authorization: Bearer <token>
Status: 200 OK
Response: {success: true, data: null}
```

**Storage Verification:**
```
After logout, secure storage should NOT have token
Check: Flutter secure storage UI tools
Result: Token key should be empty or deleted
```

---

#### Test 3.2: Login with Different User
**Steps:**
1. On login screen (from Test 3.1)
2. Use existing user credentials:
   - Email: `test@test.com`
   - Password: `password`
3. Click Login

**Expected Results:**
- ✅ Login succeeds
- ✅ Dashboard shown
- ✅ Different user's data visible
- ✅ Token saved to storage

---

### SCENARIO 4: TOKEN EXPIRY AND FORCED LOGOUT (15 min)

**Steps:**
1. Login to app (Test 3.2)
2. On backend, manually delete/corrupt token:
```bash
sqlite3 database.sqlite
SELECT * FROM personal_access_tokens WHERE NAME = 'api-token';
DELETE FROM personal_access_tokens WHERE id = X;
```
3. In Flutter app, try to perform any action:
   - Load jobs
   - Submit application
   - Refresh dashboard
4. Observe app behavior

**Expected Results:**
- ✅ API call returns 401 Unauthorized
- ✅ Dio interceptor clears token
- ✅ App automatically redirects to login
- ✅ User sees login screen (not error crash)

**What's NOT working (app crashes instead of handling 401):**
```
❌ OnError interceptor not called
  → Check: Dio interceptor setup
  → Fix: Verify _onError() in ApiService

❌ Token not cleared on 401
  → Check: if (statusCode == 401) logic
  → Fix: Ensure _secureStorage.delete() called

❌ No redirect to login
  → Check: AuthProvider.logout() after 401
  → Fix: Global error handler needed
```

---

### SCENARIO 5: NETWORK ERROR GRACEFUL HANDLING (10 min)

**Steps:**
1. Logged in via Scenario 1
2. Turn off WiFi/mobile network
3. Try to perform action in app:
   - Load jobs
   - Submit application
   - Refresh
4. Observe error handling

**Expected Results:**
- ✅ No crash (app doesn't hang/force close)
- ✅ Error message shown to user
- ✅ Retry button or option presented
- ✅ Turn network back on
- ✅ Retry succeeds

**What's NOT working (app crashes on network error):**
```
❌ No error handling UI
  → Fix: Wrap API calls in try/catch
  → Fix: Show snackbar/dialog on error

❌ App hangs
  → Check: Request timeout configured?
  → Fix: Set timeout in Dio BaseOptions
```

---

### SCENARIO 6: DATA PERSISTENCE TEST (10 min)

**Steps:**
1. Login (Scenario 1 or 3.2)
2. On backend, create multiple jobs:
```bash
sqlite3 database.sqlite
INSERT INTO jobs (title, description, user_id, created_at) 
VALUES ('Dev Job 1', 'Flutter needed', 1, datetime('now'));
INSERT INTO jobs (title, description, user_id, created_at) 
VALUES ('Dev Job 2', 'Laravel needed', 1, datetime('now'));
```
3. In Flutter, load jobs page
4. Verify jobs are visible
5. Submit application to one job
6. Close and reopen app
7. Verify application still there

**Expected Results:**
- ✅ Jobs visible in list immediately
- ✅ Application submits without error
- ✅ Application visible after restart
- ✅ Data persists in database

**Database Verification:**
```bash
sqlite3 database.sqlite
SELECT * FROM jobs WHERE user_id = 1;
SELECT * FROM applications WHERE user_id = X;
```

---

### SCENARIO 7: API ERROR RESPONSES (10 min)

#### Test 7.1: Invalid Credentials
**Steps:**
1. On login screen
2. Enter email and wrong password
3. Click Login

**Expected Results:**
- ✅ Error message shown: "Invalid email or password"
- ✅ Not crashed
- ✅ Can retry with correct credentials

**Network Verification:**
```
POST /api/auth/login
Status: 401 Unauthorized
Response: {success: false, message: "Invalid credentials", errors: null}
```

---

#### Test 7.2: Validation Error
**Steps:**
1. On registration screen
2. Leave email field empty
3. Click Register

**Expected Results:**
- ✅ Validation error shown: "Email is required"
- ✅ Not crashed
- ✅ Fields highlighted

**Network Verification:**
```
POST /api/auth/register
Status: 422 Unprocessable Entity
Response: {success: false, message: "Validation failed", errors: {email: ["required"]}}
```

---

## 📊 TEST RESULTS TEMPLATE

Copy this and fill in as you test:

```
RUNTIME TEST EXECUTION LOG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Date: ___________
Tester: ___________
Environment: Android / iOS (circle one)

SCENARIO 1: Registration → Login → Dashboard
  Test 1.1: User Registration
    Status:     [ ] PASS  [ ] FAIL
    Notes: _________________________
  
  Test 1.2: Token Persistence
    Status:     [ ] PASS  [ ] FAIL
    Notes: _________________________

SCENARIO 2: Session Restore (APP RESTART) - CRITICAL
  Expected: Dashboard shown, NO login screen
  Status:   [ ] PASS  [ ] FAIL  
  Notes: _________________________
  
SCENARIO 3: Logout and Login
  Status:   [ ] PASS  [ ] FAIL
  Notes: _________________________

SCENARIO 4: Token Expiry Handling
  Status:   [ ] PASS  [ ] FAIL
  Notes: _________________________

SCENARIO 5: Network Error Handling
  Status:   [ ] PASS  [ ] FAIL
  Notes: _________________________

SCENARIO 6: Data Persistence
  Status:   [ ] PASS  [ ] FAIL
  Notes: _________________________

SCENARIO 7: API Error Responses
  Status:   [ ] PASS  [ ] FAIL
  Notes: _________________________

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OVERALL RESULT: [ ] ALL PASS [ ] 1+ FAILURE

Critical Failures (app breaking): ___________
Minor Issues (UX only): ___________

Approval: ___________
```

---

## 🔧 DEBUGGING TOOLS

### Check Token in Secure Storage
```dart
// Add to any screen
final token = await _apiService.getToken();
debugPrint('Stored token: ${token?.substring(0, 20)}...');
debugPrint('Token empty: ${token == null || token.isEmpty}');
```

### Check Network Requests
**DevTools Network Tab:**
1. Open DevTools in browser (if running web)
2. Go to Network tab
3. Look for `/api/auth/me` calls
4. Check request headers for `Authorization: Bearer`
5. Check response for 200 (success) or 401 (token invalid)

### Check Database
```bash
# Navigate to backend
cd portfoliophhadmin

# Open SQLite
sqlite3 database.sqlite

# Check users
SELECT id, email, created_at FROM users LIMIT 5;

# Check tokens
SELECT id, tokenable_id, name FROM personal_access_tokens LIMIT 5;

# Check jobs
SELECT id, title, user_id FROM jobs LIMIT 5;

# Check applications
SELECT id, job_id, user_id FROM applications LIMIT 5;
```

### Verify Token Format
```
Valid token format: eyJ0eXAiOiJKV1QiLCJhbGc...
Location: Secure storage (not SharedPreferences!)
Lifetime: Set in Laravel .env: SANCTUM_EXPIRATION
```

---

## ✅ SUCCESS CRITERIA - ALL TESTS PASS

When all scenarios pass:
- ✅ Registration works → token saved
- ✅ Session restore works → no login on restart
- ✅ Logout works → token invalidated
- ✅ Token expiry detected → auto logout
- ✅ Network errors handled → no crashes
- ✅ Data persists → MySQL works
- ✅ Error responses handled → UI shows messages

**Then:** System is PRODUCTION READY ✅

---

## ⏱️ TOTAL TEST TIME: ~90 minutes

- Scenario 1: 15 min
- Scenario 2: 10 min (CRITICAL)
- Scenario 3: 10 min
- Scenario 4: 15 min
- Scenario 5: 10 min
- Scenario 6: 10 min
- Scenario 7: 10 min

---

**Generated:** April 5, 2026  
**Status:** Ready for manual runtime validation
