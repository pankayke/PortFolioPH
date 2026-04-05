# Integration Debugging Decision Tree
**Use this when something breaks. Follow the flow.**

---

## 🚨 SYMPTOM: "Connection Refused" or "No Response"

```
Start here ↓

Q1: Is Laravel running?
  ├─ Yes → Go to Q2
  └─ No  → SOLUTION:
           cd portfoliophhadmin
           php artisan serve
           (Should show: "Server started at http://127.0.0.1:8000")

Q2: Can you reach the API from command line?
  ├─ Yes (curl returns JSON) → Go to Q3
  └─ No  → SOLUTION:
           └─ Laravel might be using wrong IP
           └─ Check output: Does it say "http://127.0.0.1:8000" or "localhost:8000"?
           └─ Try:
              php artisan serve --host=127.0.0.1 --port=8000

Q3: Does Flutter app show error or just loading forever?
  ├─ Error visible → Go to AUTH FAILED
  └─ Loading forever → SOLUTION:
                      └─ Flutter likely can't reach Chrome browser API
                      └─ Try:
                         flutter clean
                         flutter run -d chrome
           
→ End: Contact me with:
    - Laravel output (from terminal)
    - Flutter error message
    - curl response
```

---

## 🚨 SYMPTOM: "Invalid Credentials" or Login Fails

```
Start here ↓

Q1: Did user registration succeed?
  ├─ Yes → Go to Q2
  └─ No  → Go to: "Registration Failed"

Q2: When logging in, what error does Laravel show?
  ├─ "No user found" → User not in DB
  │  └─ SOLUTION: Check Laravel DB:
  │      mysql -u root -p
  │      SELECT * FROM users WHERE email='...';
  │
  ├─ "Password mismatch" → Registration created different hash than login uses
  │  └─ SOLUTION: 
  │      ├─ Check if hash is being computed correctly
  │      ├─ Make sure registration and login both use same password hashing
  │      └─ Try: Delete user, register again
  │
  └─ No error, but still fails → Go to Q3

Q3: Does Flutter show red error message?
  ├─ Yes → Read the message carefully
  │  └─ "Invalid email or password." → User/password wrong
  │  └─ "Request timeout" → Laravel not responding
  │  └─ "Unauthorized" → Token issue (next section)
  │
  └─ No error, screen stays on login → Likely token save failed

→ End: Check Laravel logs:
    tail -f storage/logs/laravel.log
    Try login again and watch real-time output
```

---

## 🚨 SYMPTOM: Token Not Saved (Step 4 in Quick Guide)

```
Start here ↓

Q1: After successful login, does DevTools Session Storage have 'auth_token'?
  ├─ Yes → Token IS saved → Next go to: "Data Not Loading"
  └─ No  → Go to Q2

Q2: Does Flutter console show "token saved" message?
  ├─ Yes → Token saved in Flutter, but DevTools not showing it
  │  └─ SOLUTION: DevTools might not be synced
  │      ├─ Refresh browser: F5
  │      ├─ Logout → Login again
  │      ├─ Check DevTools Application → Session Storage (not Local Storage!)
  │
  └─ No  → Token not being saved. Go to Q3

Q3: Can you see response from /auth/login in Network tab?
  ├─ Yes, 200 status → Response came back. Check response body:
  │  ├─ Does it have "token": "eyJ..." field?
  │  │  ├─ Yes → Token in response but not saved by Flutter → Code bug
  │  │  │        Check: UserRepository.authenticate() line ~195
  │  │  │        Does it say: await _apiService.saveToken(token);?
  │  │  │
  │  │  └─ No → Laravel not returning token → Server bug
  │  │         django artisan config:clear
  │  │         Check: app/Services/AuthService.php createToken() method
  │  │
  │  └─ Response body shows error? → Go back to "Login Failed"
  │
  └─ No, not in Network tab → Request didn't go through
     ├─ Likely cause: /auth/login endpoint wrong URL
     ├─ Check: ApiService baseUrl = 'http://127.0.0.1:8000/api'
     └─ SOLUTION: Edit lib/core/services/api_service.dart line 15

→ Summary:
    - If response has token field: Code bug (token save failed)
    - If response missing token: Server bug (Sanctum not creating token)
    - If response not received: Network bug (wrong endpoint)
```

---

## 🚨 SYMPTOM: 401 Unauthorized on API Calls

```
Start here ↓

Q1: After login, do Network requests show "Authorization: Bearer ..." header?
  ├─ Yes → Header is there but still 401 → Go to Q2
  └─ No  → Header missing. Go to: "Token Not Saved"

Q2: Is the token value actually correct?
  ├─ Copy token from DevTools Session Storage: `auth_token`
  ├─ Compare it to Authorization header in Network tab
  │  ├─ Same value? → Go to Q3
  │  └─ Different? → SOLUTION: Something is modifying token
  │                  └─ Check: ApiService _onRequest() interceptor
  │                  └─ Is it adding extras that break token format?
  │
  └─ Token looks right, but still 401

Q3: Check Laravel's token validation
  ├─ SOLUTION: Maybe token is expired or revoked
  │  ├─ Check Laravel DB: SELECT * FROM personal_access_tokens;
  │  ├─ Are there tokens in that table?
  │  │  ├─ Yes → Are they marked as revoked? (revoked_at column)
  │  │  └─ No  → Tokens never created. Check AuthService.createToken()
  │  │
  │  ├─ Delete all tokens and try login again:
  │  │  TRUNCATE TABLE personal_access_tokens;
  │  │  (in Laravel: php artisan tinker → Artisan::call('migrate:fresh'))
  │  │
  │  └─ Still 401? → Check AuthServiceProvider
  │      └─ Is Sanctum middleware registered?
  │         grep -r "Sanctum" config/auth.php
  │
  └─ ADVANCED: Check token payload
     └─ Decode JWT at jwt.io
     └─ Does it have correct user_id?
     └─ Does exp (expiration) date is in future?

→ Summary:
    - Token in header but still 401: Server auth config issue
    - Token looks right: Check if tests with fresh token work
    - Still stuck: Check app/Http/Middleware/Authenticate.php
```

---

## 🚨 SYMPTOM: Real Data Not Loading (Empty Lists)

```
Start here ↓

Q1: Did the API call succeed?
  Check Network tab:
  ├─ Status is 200 → Response succeeded. Go to Q2
  ├─ Status is 401 → Not authenticated. Go to: "401 Unauthorized on API Calls"
  ├─ Status is 500 → Server error. Check Laravel logs
  └─ No request visible → Request never sent

Q2: What's in the response body?
  ├─ Click request in Network tab
  ├─ Response tab → Look at JSON
  │  ├─ {"data": []} → Empty data array
  │  │  └─ SOLUTION: Database has no records
  │  │     └─ Add test data:
  │  │        php artisan tinker
  │  │        >>> \App\Models\Job::create([...])
  │  │
  │  ├─ {"data": [...], ...} → Data is there
  │  │  └─ SOLUTION: Flutter not parsing response
  │  │     └─ Check: ApiService._handleResponse() extracts 'data' correctly?
  │  │
  │  └─ {"error": "..."} → Error in response
  │     └─ Read error message carefully
  │     └─ Common: "Unauthorized", "Not found", "Invalid input"
  │
  └─ No response body visible (blank) → Server sent no body
     └─ Check Laravel logs for exception

Q3: Is data showing in Flutter but wrong format?
  ├─ Yes → DataModel mapping might be wrong
  │  ├─ Check: JobModel.fromMap() constructor
  │  ├─ Compare response fields to expected model fields
  │  ├─ Look for errors like: "String cannot be cast to int"
  │
  └─ No, still empty list

→ Debug Checklist:
    - Run query directly in MySQL: SELECT * FROM jobs;
    - Check response JSON matches DB structure
    - Verify Flutter model fromMap() handles all fields
    - Add debug prints in JobModel.fromMap()
```

---

## 🚨 SYMPTOM: Can Register But Can't Login with Same Credentials

```
Start here ↓

Q1: Does registration say "successful"?
  ├─ Yes → Go to Q2
  └─ No  → Go to: "Registration Failed"

Q2: Can you login to Laravel admin with those credentials?
  └─ http://127.0.0.1:8000/admin/dashboard
  ├─ Yes → Credentials work. Question: Maybe different email format?
  │  └─ Check: Did Flutter auto-lowercase email?
  │  └─ Check: Were spaces trimmed?
  │  └─ Try: Use excact same email as registration showed
  │
  └─ No  → Password hash issue

Q3: Check what password is actually stored
  ```
  php artisan tinker
  >>> $user = \App\Models\User::where('email', 'test@test.com')->first();
  >>> echo $user->password;  // Should be: $2y$12$... (bcrypt hash)
  ```
  ├─ Looks like: $2y$12$... → Password hashed correctly
  │  └─ Try logout → login again
  │  └─ Maybe token just expired
  │
  └─ Looks like plain text → Password NOT hashed!
     └─ SOLUTION: AuthService.register() not hashing password
        └─ Check: AuthService._hashPassword() or similar
        └─ Expected: use Hash::make($password) in Laravel
        └─ Or: \Illuminate\Support\Facades\Hash::make($password)

→ Summary:
    - Registration works but login doesn't: Check hashing mechanism
    - Email format difference: Normalize emails (trim, lowercase)
    - Token expired: Just login again
```

---

## 🚨 SYMPTOM: "500 Internal Server Error"

```
Start here ↓

Q1: Check Laravel logs
  terminal A (where artisan serve runs):
  ├─ Any error messages visible?
  │  └─ Read carefully, PHP file + line number given
  │
  └─ No messages? Check log file:
     tail -f storage/logs/laravel.log

Q2: Read the error message carefully
  ├─ "Column not found" → Database table missing column
  │  └─ SOLUTION:
  │     └─ php artisan migrate
  │     └─ php artisan migrate:fresh (if needed to rebuild)
  │
  ├─ "SQLSTATE" error → Database query failed
  │  └─ SOLUTION: Check if table exists
  │     └─ mysql SELECT * FROM information_schema.tables;
  │     └─ If table missing: php artisan migrate
  │
  ├─ "Class not found" → Service/Model/Controller doesn't exist
  │  └─ SOLUTION:
  │     └─ File doesn't exist: Create it
  │     └─ Namespace wrong: Fix import
  │
  ├─ "Method not found" → Calling method that doesn't exist
  │  └─ SOLUTION:
  │     └─ Check AuthService, UserRepository, etc.
  │     └─ Method needs to be public
  │     └─ Signature must match (parameters)
  │
  └─ "Undefined variable" → PHP variable not set
     └─ SOLUTION:
        └─ Check if you're using $request properly
        └─ Check if model was loaded correctly

Q3: If error unclear
  ├─ Run artisan config:clear
  ├─ Run artisan cache:clear
  ├─ Refresh Flutter app
  ├─ Try again
  ├─ If still 500: Copy full error message from log file

→ Summary:
    - Most 500 errors: Database migration needed
    - Next most common: Class/method doesn't exist
    - Check log file always - it's your best friend
```

---

##  🚨 SYMPTOM: "Registration Failed" Error

```
Start here ↓

Q1: What's the exact error message shown?
  ├─ "Email already exists" → User already registered with that email
  │  └─ SOLUTION: Use different email
  │
  ├─ "Username taken" → Username  already in use
  │  └─ SOLUTION: Use different username
  │
  ├─ "Validation failed" → Some field didn't pass validation
  │  └─ SOLUTION:
  │     ├─ Email format invalid? (must be valid email)
  │     ├─ Password too short? (check requirements)
  │     ├─ Name blank? (might be required)
  │
  ├─ " Request timeout" → Laravel not responding
  │  └─ SOLUTION: Check "Connection Refused" section above
  │
  ├─ "Registration failed. Please try again." (generic)
  │  └─ SOLUTION: Check Laravel logs for actual error
  │     └─ tail -f storage/logs/laravel.log
  │     └─ Try registering again
  │     └─ Read error message shown
  │
  └─ Some other error → Go to "500 Internal Server Error"

Q2: Check Laravel validation rules
  └─ File: app/Http/Requests/RegisterRequest.php
  └─ Rules should say what's expected:
     - email: must be valid email + unique
     - password: required + min:8 (usually)
     - name: required + string

→ Summary:
    - Most common: Email or username already exists (try different one)
    - Second: Password too weak (needs uppercase, lowercase, number, symbol)
    - Check validation rules first before debugging further
```

---

## 🎯 If You're Still Stuck

**Screenshot this:**
1. Flutter error message (full text)
2. Laravel terminal output (full error)
3. Network request in DevTools (Request and Response tabs)
4. DevTools Application → Session Storage (show all keys)

**Then describe:**
- What step did it fail on? (Registration? Login?)
- What did you expect to happen?
- What actually happened?
- Exact error message?

**I can then diagnose from those 4 things**.
