# 🧪 RUNTIME VALIDATION CHECKLIST
**Purpose:** Verify integration works end-to-end  
**Duration:** ~15 minutes  
**Prerequisites:** Laravel running, Flutter app ready

---

## ✅ PRE-FLIGHT CHECKS

- [ ] Laravel server running: `cd portfoliophhadmin && php artisan serve`
- [ ] Flutter dependencies installed: `flutter pub get`
- [ ] Device/emulator available
- [ ] MySQL database ready (with test data or empty)

---

## 🔄 TEST 1: REGISTRATION FLOW (5 min)

### Actions
1. Run Flutter app
2. SplashScreen shows for 3 seconds
3. Navigate to Registration page
4. Enter valid credentials:
   - Name: `Test User ABC`
   - Email: `testuser+timestamp@test.com` (use current time to make unique)
   - Username: `testuser_abc`
   - Password: `TestPassword123!`
5. Click Register

### Expected Results
- [ ] Registration succeeds (no error)
- [ ] Dashboard shown immediately (not login screen)
- [ ] Token saved to secure storage (verified in code)
- [ ] User data visible in profile area

### Network Verification
- [ ] DevTools Network tab shows:
  - [ ] POST /api/auth/register
  - [ ] Response includes token
  - [ ] Headers contain no Authorization (not needed for register)

### Database Verification
```bash
php artisan tinker
>>> DB::table('users')->latest('id')->first()
# Should show newly registered user
```

---

## 🔄 TEST 2: JOB SUBMISSION (5 min)

### Setup
- [ ] User successfully registered and logged in
- [ ] Dashboard showing

### Actions
1. Navigate to Jobs or Create Job page
2. Create new job:
   - Title: `Flutter Developer Needed`
   - Description: `We need an experienced Flutter developer`
   - Location: `Remote`
   - Salary: `$50,000 - $80,000`
3. Click Submit/Create

### Expected Results
- [ ] Job created successfully (no error)
- [ ] Dashboard/jobs list shows new job
- [ ] Job is marked as from current user

### Network Verification
- [ ] DevTools Network tab shows:
  - [ ] POST /api/jobs
  - [ ] Request headers include: `Authorization: Bearer token...`
  - [ ] Response status: 201 Created
  - [ ] Response includes job ID

### Database Verification
```bash
php artisan tinker
>>> DB::table('jobs')->latest('id')->first()
# Should show newly created job
>>> DB::table('jobs')->where('title', 'Flutter Developer Needed')->first()
```

---

## 🔄 TEST 3: APPLICATION SUBMISSION (5 min)

### Setup
- [ ] User logged in
- [ ] Job visible in jobs list

### Actions
1. Navigate to view job details (from another job if needed)
2. Click "Apply" button
3. Fill application form (if any extra details)
4. Submit application

### Expected Results
- [ ] Application submitted successfully
- [ ] Confirmation message shown
- [ ] Application appears in "My Applications" or similar

### Network Verification
- [ ] DevTools Network tab shows:
  - [ ] POST /api/applications
  - [ ] Request headers include: `Authorization: Bearer token...`
  - [ ] Response status: 201 Created

### Database Verification
```bash
php artisan tinker
>>> DB::table('applications')->latest('id')->first()
```

---

## 🔄 TEST 4: SESSION RESTORE (5 min)

### Actions
1. App currently running with user logged in
2. **Force close the app:**
   - iOS/Android: Swipe up to close
   - Emulator: Close the window
3. Wait 5 seconds
4. **Reopen the app:**
   - Tap app icon again
   - OR press F5 in emulator

### Expected Results
- [ ] SplashScreen shows (animated loader)
- [ ] After 3 seconds, **Dashboard shown immediately**
- [ ] **NO login screen** (this is the critical test!)
- [ ] User profile shows correct name/email
- [ ] Previous data still visible (jobs, applications)

### Network Verification
- [ ] DevTools Network tab shows:
  - [ ] GET /api/auth/me (called on app startup)
  - [ ] Request headers include: `Authorization: Bearer token...`
  - [ ] Response: {success: true, data: {id, name, email, role}}

### Database Verification
```bash
php artisan tinker
>>> DB::table('personal_access_tokens')->where('tokenable_id', USER_ID)->count()
# Should show at least 1 active token
```

---

## 🔄 TEST 5: LOGOUT FLOW (3 min)

### Actions
1. User currently logged in on dashboard
2. Navigate to user menu/settings
3. Click "Logout"

### Expected Results
- [ ] Logout completes without error
- [ ] Redirected to Login screen
- [ ] Cannot access dashboard (navigating back shows login)

### Network Verification
- [ ] DevTools Network tab shows:
  - [ ] POST /api/auth/logout
  - [ ] Request headers include: `Authorization: Bearer token...`
  - [ ] Response: {success: true}

### Secure Storage Verification
```bash
# Token should be gone from secure storage
# (Can't easily check from backend, but should fail on next restart test)
```

### Additional Check
- [ ] Try to manually navigate to /dashboard
- [ ] Login screen shown (not dashboard)

---

## 🔄 TEST 6: TOKEN EXPIRY SIMULATION (3 min)

### Setup
- [ ] User logged in
- [ ] Know the current token (from Network tab)

### Actions
1. Get current running user ID from Network response of /auth/me
2. Delete token from database:
```bash
php artisan tinker
>>> DB::table('personal_access_tokens')->where('tokenable_id', USER_ID)->delete()
```
3. In Flutter app, try to navigate or refresh a page that requires auth
4. Expected: API call fails with 401

### Expected Results
- [ ] Network request returns 401 Unauthorized
- [ ] App automatically logs out user
- [ ] Redirected to Login screen
- [ ] Cannot access protected pages

---

## 🔄 TEST 7: INVALID TOKEN HANDLING (2 min)

### Actions
1. Get the stored token value (if you can access it from console)
2. Manually corrupt it:
```bash
php artisan tinker
>>> $token = DB::table('personal_access_tokens')->latest()->first();
>>> DB::table('personal_access_tokens')->where('id', $token->id)->update(['token' => 'invalid']);
```
3. In app, close and reopen

### Expected Results
- [ ] Restart attempt loads SplashScreen
- [ ] GET /api/auth/me fails with 401
- [ ] Token automatically cleared from secure storage
- [ ] Login screen shown

---

## 📊 RESULTS SUMMARY

After completing all tests, check off completion:

| Test | PASS | FAIL | Notes |
|------|------|------|-------|
| 1. Registration | [ ] | [ ] | |
| 2. Job Submission | [ ] | [ ] | |
| 3. Application Submit | [ ] | [ ] | |
| 4. Session Restore | [ ] | [ ] | **CRITICAL TEST** |
| 5. Logout | [ ] | [ ] | |
| 6. Token Expiry | [ ] | [ ] | |
| 7. Invalid Token | [ ] | [ ] | |

---

## 🔍 DEBUGGING NOTES

### If Test Fails: Registration
- Check: Laravel API responsive?
- Check: Correct API base URL in Flutter?
- Check: CORS enabled in Laravel?
- Check: Network error or validation error?

### If Test Fails: Bearer Token Not Sent
```dart
// Add debug print in ApiService._onRequest
debugPrint('Headers: ${options.headers}');
debugPrint('Token: ${await _secureStorage.read(key: tokenKey)}');
```

### If Test Fails: Session Restore
```dart
// Add debug print in AuthProvider.restoreSession
debugPrint('Has token: $hasToken');
debugPrint('User after restore: $_currentUser');
```

### If Test Fails: /auth/me Returns 401
```bash
# Verify token in database
php artisan tinker
>>> DB::table('personal_access_tokens')->where('name', 'api-token')->latest()->first()
# Check if token actually exists and where tokenable_id matches current user
```

---

## ✅ SUCCESS CRITERIA - ALL 7 TESTS PASS

Once all tests pass with ✅:
- ✅ Flutter + Laravel integration **100% WORKING**
- ✅ Token properly saved and used
- ✅ Session restore via /auth/me **CONFIRMED**
- ✅ Logout invalidates token **CONFIRMED**
- ✅ Data persists **CONFIRMED**
- ✅ Ready for production deployment

---

**Time to Complete:** ~30 minutes including notes  
**Effort:** Low (mostly clicking through UI)  
**Impact:** HIGH (proves entire integration)

Execute these tests before deploying to production.
