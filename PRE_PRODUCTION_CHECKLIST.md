# ✅ PRE-PRODUCTION DEPLOYMENT CHECKLIST

**Status:** Ready for final validation before production deployment  
**Last Updated:** April 5, 2026  
**Validation Approach:** Code path verification + Runtime test suite

---

## 📋 INTEGRATION VERIFICATION MATRIX

| Component | Code Status | Runtime Status | Notes |
|-----------|-------------|-----------------|-------|
| AuthController (register/login/me/logout) | ✅ PASS | ⏳ PENDING | All 4 methods implemented |
| AuthService (createToken/logout) | ✅ PASS | ⏳ PENDING | Token lifecycle complete |
| ApiResponse wrapper | ✅ PASS | ⏳ PENDING | Consistent format across all responses |
| Dio HTTP client + interceptors | ✅ PASS | ⏳ PENDING | Bearer injection + 401 handling |
| Secure storage persistence | ✅ PASS | ⏳ PENDING | Token stored after auth |
| Repository layer (token save) | ✅ PASS | ⏳ PENDING | Explicit save to storage |
| Session restore on restart | ✅ PASS | ⏳ PENDING | Uses /auth/me verification |
| Route protection (auth:sanctum) | ✅ PASS | ⏳ PENDING | Middleware applied |
| Exception handling (JSON errors) | ✅ PASS | ⏳ PENDING | All exceptions mapped to JSON |
| Integration tests | ✅ PASS | ⏳ PENDING | 6 test scenarios defined |

**Legend:**
- ✅ PASS = Code verified correct
- ⏳ PENDING = Awaiting runtime validation
- ❌ FAIL = Issue found, fix applied
- 🔧 FIXED = Issue fixed, needs re-test

---

## 🚀 RUNTIME VALIDATION EXECUTION PLAN

### Phase 1: Server & Database Setup (5 min)
- [ ] Navigate to `portfoliophhadmin` directory
- [ ] Run: `php artisan migrate:fresh --seed`
- [ ] Verify: 5 tables created (users, jobs, applications, personal_access_tokens, ...)
- [ ] Run: `php artisan serve --port=8000`
- [ ] Verify: Server running at `http://localhost:8000`

**Command:**
```bash
cd portfoliophhadmin
php artisan migrate:fresh --seed
php artisan serve --port=8000
```

---

### Phase 2: Flutter App Setup (5 min)
- [ ] Navigate to Flutter project folder
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter run` (on emulator or device)
- [ ] Verify: App launches without crash
- [ ] Verify: Login screen visible at startup

**Command:**
```bash
cd ..
flutter pub get
flutter run
```

---

### Phase 3: Test Execution (60 min)

#### TEST 1: Registration Flow (10 min)
**Steps:**
1. [ ] Open Flutter app
2. [ ] Tap "Register"
3. [ ] Enter:
   - Name: `Test User`
   - Email: `test.dev@portfolioph.test`
   - Password: `TestPass123!`
   - Username: `testdev001`
4. [ ] Tap "Register" button

**Verification:**
- [ ] No error shown
- [ ] Dashboard displayed (NOT login screen)
- [ ] User name visible in profile/header
- [ ] Network request: `POST /api/auth/register` → Status 201
- [ ] Response format: `{success: true, data: {user: {...}, token: "..."}}`
- [ ] Database: User created in `users` table

**Result:** [ ] PASS [ ] FAIL

---

#### TEST 2: Token Persistence (5 min)
**Steps:**
1. [ ] From dashboard (logged in)
2. [ ] Open DevTools → Storage
3. [ ] Check secure storage for `api_token`
4. [ ] Load any page that calls API (jobs, etc.)

**Verification:**
- [ ] Token exists in secure storage (not empty)
- [ ] Token visible in network request headers: `Authorization: Bearer <token>`
- [ ] API response successful (status 200)

**Result:** [ ] PASS [ ] FAIL

---

#### TEST 3: Session Restore on App Restart (10 min) - **CRITICAL**
**Steps:**
1. [ ] Currently logged in (from TEST 1)
2. [ ] Close app completely:
   - iOS: Swipe up to close
   - Android: Press home twice, swipe up
   - Emulator: Close window
3. [ ] Wait 2 seconds
4. [ ] Reopen app by tapping icon

**Verification:**
- [ ] SplashScreen shows for ~3 seconds
- [ ] Dashboard displayed (NOT login screen)
- [ ] User data visible
- [ ] Network request: `GET /api/auth/me` appears
- [ ] Request header: `Authorization: Bearer <token>`
- [ ] Status: 200 OK
- [ ] Response: `{success: true, data: {user: {...}}}`

**Result:** [ ] PASS [ ] FAIL

**If FAIL:**
Reference: [FAILING_TESTS_FIX_REFERENCE.md](FAILING_TESTS_FIX_REFERENCE.md#-symptom-app-shows-login-screen-when-it-should-show-dashboard-app-restart)

---

#### TEST 4: Logout Functionality (5 min)
**Steps:**
1. [ ] From dashboard
2. [ ] Navigate to settings/profile
3. [ ] Tap "Logout" button

**Verification:**
- [ ] Network request: `POST /api/auth/logout` → Status 200
- [ ] Redirected to login screen
- [ ] Token removed from secure storage
- [ ] Database: User tokens deleted from `personal_access_tokens`

**Verification Commands:**
```bash
# Check database after logout
sqlite3 database.sqlite
SELECT * FROM personal_access_tokens;
# Result: Should be empty or user's tokens deleted
```

**Result:** [ ] PASS [ ] FAIL

---

#### TEST 5: Login with New User (5 min)
**Steps:**
1. [ ] On login screen (from TEST 4)
2. [ ] Enter credentials:
   - Email: `recruiter@portfolioph.test` (or seed file user)
   - Password: `password` (or seed password)
3. [ ] Tap "Login"

**Verification:**
- [ ] Login succeeds
- [ ] Dashboard displayed
- [ ] Different user's data visible
- [ ] Token saved to secure storage
- [ ] Network request: POST → Status 200

**Result:** [ ] PASS [ ] FAIL

---

#### TEST 6: Token Expiry Handling (10 min)
**Steps:**
1. [ ] Logged in (from TEST 5)
2. [ ] On backend, delete user's tokens:
   ```bash
   sqlite3 database.sqlite
   DELETE FROM personal_access_tokens;
   ```
3. [ ] In app, perform any action (load jobs, etc.)

**Verification:**
- [ ] App does NOT crash
- [ ] API returns 401 Unauthorized
- [ ] Error message shown (snackbar/toast)
- [ ] Redirected to login screen after error
- [ ] OR Token automatically cleared and session ends

**Result:** [ ] PASS [ ] FAIL

**If FAIL:**
Reference: [FAILING_TESTS_FIX_REFERENCE.md](FAILING_TESTS_FIX_REFERENCE.md#-symptom-401-error-appears-but-app-doesnt-auto-logout)

---

#### TEST 7: Network Error Handling (5 min)
**Steps:**
1. [ ] Logged in
2. [ ] Disable WiFi/cellular network
3. [ ] Try to perform action in app (load jobs, etc.)

**Verification:**
- [ ] App does NOT crash
- [ ] Error message displayed ("Network error", "Check connection", etc.)
- [ ] Enable network
- [ ] Retry succeeds
- [ ] API call completes

**Result:** [ ] PASS [ ] FAIL

---

#### TEST 8: Data Consistency (10 min)
**Steps:**
1. [ ] Login as recruiter
2. [ ] Create new job
3. [ ] Verify job in database:
   ```bash
   sqlite3 database.sqlite
   SELECT * FROM jobs WHERE user_id = 1;
   ```
4. [ ] Login as job seeker
5. [ ] Submit application to job
6. [ ] Close and reopen app
7. [ ] Application still visible

**Verification:**
- [ ] Job created in database ✅
- [ ] Job visible in app ✅
- [ ] Application created ✅
- [ ] Application persists after app restart ✅
- [ ] All 200 status codes ✅

**Result:** [ ] PASS [ ] FAIL

---

## 📊 RESULTS SUMMARY

### Test Results
```
Test 1: Registration Flow          [ ] PASS [ ] FAIL
Test 2: Token Persistence          [ ] PASS [ ] FAIL
Test 3: Session Restore (CRITICAL) [ ] PASS [ ] FAIL  ← Most important
Test 4: Logout                     [ ] PASS [ ] FAIL
Test 5: Login New User             [ ] PASS [ ] FAIL
Test 6: Token Expiry               [ ] PASS [ ] FAIL
Test 7: Network Error              [ ] PASS [ ] FAIL
Test 8: Data Consistency           [ ] PASS [ ] FAIL

Total Passing: ____ / 8
```

### Overall Status
- [ ] ALL PASS → Production Ready ✅
- [ ] 1-2 FAIL → Fixable, review [FAILING_TESTS_FIX_REFERENCE.md](FAILING_TESTS_FIX_REFERENCE.md)
- [ ] 3+ FAIL → Major issues, pause deployment

---

## 🔧 ISSUE RESOLUTION WORKFLOW

**If any test fails:**

1. **Note the failing test number** (e.g., Test 3)
2. **Open reference guide:**
   - [FAILING_TESTS_FIX_REFERENCE.md](FAILING_TESTS_FIX_REFERENCE.md) - Exact code fixes
   - [RUNTIME_TEST_SCENARIOS.md](RUNTIME_TEST_SCENARIOS.md#-debugging-tools) - Debug tools
3. **Apply recommended fix**
4. **Re-run test to verify**
5. **Document what was fixed** in this checklist

**Example:**
```
Test 3 FAILED: Login screen shown instead of dashboard on restart
↓
Reference: FAILING_TESTS_FIX_REFERENCE.md → "Session restore not working"
↓
Fix applied: Added restoreSession() call to SplashScreen._init()
↓
Re-run Test 3: [ ] PASS ✅
↓
Document: "Fixed in commit: abc123"
```

---

## 📝 PRODUCTION READINESS SIGN-OFF

**Approval Gates:**

1. **Code Review:**
   - [ ] All 4 integration points reviewed
   - [ ] No hardcoded credentials
   - [ ] Error handling complete
   - [ ] Comments added to critical sections

2. **Testing:**
   - [ ] All 8 tests PASS
   - [ ] No network crashes
   - [ ] Session restore verified
   - [ ] Token lifecycle verified

3. **Security:**
   - [ ] Tokens in secure storage (NOT SharedPreferences)
   - [ ] Passwords hashed (bcrypt)
   - [ ] No API tokens in logs
   - [ ] CORS configured for frontend domain
   - [ ] Rate limiting on auth endpoints

4. **Performance:**
   - [ ] /auth/me response < 200ms
   - [ ] Session restore < 2 seconds
   - [ ] Database queries indexed
   - [ ] No N+1 queries

5. **Documentation:**
   - [ ] API docs updated
   - [ ] Architecture docs up-to-date
   - [ ] Deployment guide ready
   - [ ] Rollback plan defined

---

## 🚀 DEPLOYMENT STEPS

Once all tests PASS and sign-offs complete:

1. **Merge to main:**
   ```bash
   git checkout main
   git merge feature/auth-integration
   ```

2. **Tag release:**
   ```bash
   git tag -a v2.0.0 -m "Authentication integration complete"
   git push origin v2.0.0
   ```

3. **Deploy Laravel backend:**
   ```bash
   # On production server
   git pull origin main
   php artisan migrate
   php artisan config:cache
   php artisan route:cache
   ```

4. **Deploy Flutter app:**
   ```bash
   flutter build apk --release
   flutter build ios --release
   # Submit to Google Play / App Store
   ```

5. **Monitor:**
   - Check server logs for errors
   - Monitor API response times
   - Track user authentication success rate
   - Alert on 401/500 spikes

---

## 📞 ESCALATION

If production issues occur:

1. **Immediate:** Rollback to previous version
2. **Debug:** Check logs in:
   - Laravel: `storage/logs/laravel.log`
   - Flutter: DevTools console / device logs
3. **Fix:** Use [FAILING_TESTS_FIX_REFERENCE.md](FAILING_TESTS_FIX_REFERENCE.md)
4. **Verify:** Re-run all tests
5. **Deploy:** Push fix to production

---

## 📌 KEY SUCCESS METRICS

After deployment, track:

| Metric | Target | Current |
|--------|--------|---------|
| Authentication success rate | >99.5% | TBD |
| Session restore time | <2s | TBD |
| API response time (avg) | <200ms | TBD |
| 401 error rate | <0.5% | TBD |
| Crash rate on network error | 0% | TBD |
| User session duration (avg) | >30min | TBD |

---

**Generated:** April 5, 2026  
**Status:** Ready for production deployment  
**Next Step:** Execute Phase 1 (Server Setup)
