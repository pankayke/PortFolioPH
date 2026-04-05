# INTEGRATION TEST - QUICK START
**Read this first. Test in this order. No extra reading needed.**

---

## ⚡ STEP 1: START BACKENDS (2 minutes)

### Terminal A: Start Laravel API
```bash
cd c:\Users\USER\portfolioph\portfoliophhadmin
php artisan serve
```
**Wait for:** `Laravel development server started at http://127.0.0.1:8000`

### Terminal B: Verify API Responds
```bash
curl http://127.0.0.1:8000/api/health
```
**Should see:** `{"status":"ok","timestamp":"..."}`

---

## ⚡ STEP 2: START FLUTTER APP (2 minutes)

### Terminal C: Run Flutter
```bash
cd c:\Users\USER\portfolioph
flutter run -d chrome
```
**Wait for:** Browser opens, loading spinner stops

### Check Console C
```
[ApiService] Response 200 | /health
```
✅ **If visible:** API connection works  
❌ **If NOT visible or 500 error:** Check Terminal A (Laravel not running?)

---

## ⚡ STEP 3: TEST REGISTRATION (3 minutes)

### In Flutter App
1. Click "Create Account" (on login screen)
2. Fill form:
   - Username: `test_user_8421` (use current timestamp to make unique)
   - Email: `testuser_8421@test.com`
   - Password: `TestPassword123!`
   - Full Name: `Test User`
3. Click "Create Account"

### Watch Console C
Should see:
```
[ApiService] Response 201 | /auth/register
[UserRepository] Login successful - token saved
```

### Check Flutter App
✅ **Success:** Screen changes, maybe redirects to dashboard  
❌ **Error:** Red error message on screen

---

## ⚡ STEP 4: VERIFY TOKEN SAVED (1 minute)

### Open DevTools (Chrome)
Press `F12` → Application tab → Session Storage

Should see:
| Key | Value |
|-----|-------|
| `auth_token` | `eyJ0eXA...` (long string) |
| `auth_user` | (user data) |

✅ **Both keys present:** Token saved correctly  
❌ **Missing keys:** Token NOT saved (integration broken)

---

## ⚡ STEP 5: TEST LOGIN (2 minutes)

### Click Logout (if on Dashboard)
Go back to LoginScreen

### Login with test account
1. Email: `testuser_8421@test.com`
2. Password: `TestPassword123!`
3. Click "Log In"

### Watch Console C
```
[ApiService] Response 200 | /auth/login
[UserRepository] Login successful - token saved
```

### Check DevTools Network Tab
1. Press F12 → Network tab
2. Look for request to `127.0.0.1:8000/api/auth/login`
3. Click it → Headers → Scroll to Request Headers
4. **See `Authorization: Bearer eyJ0eXA...`?**

✅ **Yes:** Token injected automatically  
❌ **No:** Token NOT being added to requests (BROKEN)

---

## ⚡ STEP 6: TEST DATA (2 minutes)

### On DashboardScreen
1. Look for "Jobs" or "Browse Jobs" button
2. Click it
3. Wait for list to load

### Check Console C
```
[ApiService] Response 200 | /jobs
```

### Check Flutter App
✅ **Jobs list appears with real data:** System works  
❌ **Empty list:** No jobs in Laravel DB (not integration issue)  
❌ **Error message:** Integration broken

### Check Network Tab
1. Find request to `/jobs`
2. Verify **Request Headers have `Authorization: Bearer...`**

---

## 🎯 IF ALL TESTS PASS

✅ Registration works  
✅ Token saved automatically  
✅ Token injected in requests  
✅ Real data loads from backend  
✅ **SYSTEM IS ALIVE** 🚀

---

## ❌ IF ANY TEST FAILS

### Registration Failed (Step 3)
**Check Terminal A (Laravel):**
```
Look for error message like:
- "Column not found"
- "Duplicate entry"
- "SQLSTATE error"
```

**Fix:** 
- Run `php artisan migrate` to create tables
- Run `php artisan db:seed` to seed test data

---

### Token NOT Saved (Step 4)
**Check Console C for:**
```
[UserRepository] Registration failed: ...
```

**If you see this:** Token save failed → re-run Step 1-2 to restart everything

---

### Token NOT Injected (Step 5)
**Network tab shows NO `Authorization` header?**

**Check:**
1. Is ApiService initialized properly?
2. Is flutter_secure_storage working?

**Re-test:**
```bash
# In Flutter app, go to Settings (if available) and logout
# Then login again
# Check token in DevTools again
```

---

### Jobs List Empty or Error (Step 6)
**If you see error:**
```
401 Unauthorized
```
→ Token not being sent = Step 5 failed

**If list is empty but no error:**
```
# Add test jobs in Laravel
cd portfoliophhadmin
php artisan tinker
>>> \App\Models\Job::create(['title'=>'PHP Dev', 'recruiter_id'=>1, 'status'=>'open'])
```

---

## 🔥 NUCLEAR OPTION (If everything fails)

```bash
# Kill and restart everything

# Terminal A
cd portfoliophhadmin
php artisan migrate:fresh --seed
php artisan serve

# Terminal B
curl http://127.0.0.1:8000/api/health

# Terminal C
flutter clean
flutter pub get
flutter run -d chrome
```

---

## 📸 SCREENSHOT CHECKLIST

Take screenshots of:
1. ✅ Step 3: Success message after registration
2. ✅ Step 4: DevTools showing `auth_token` in Session Storage
3. ✅ Step 5: Network tab showing `Authorization: Bearer` header
4. ✅ Step 6: Jobs list populated with real data

**If all 4 screenshots pass:** System integration is **100% COMPLETE**

---

## ⏱️ TOTAL TIME: 15 minutes

If all steps pass in 15 minutes → **Integration is working**  
If any step fails → Fixed code is in place, debug using the GUIDE

**NOW GO TEST IT** 🚀
