# 🧪 PRODUCTION HARDENING – TESTING & DEPLOYMENT GUIDE

**Date:** April 5, 2026  
**Status:** Ready for Testing & Deployment

---

## 🚀 QUICK START (5 minutes)

### Prerequisites
```bash
# Ensure you have:
- Flutter SDK (3.10.7+)
- PHP 8.2+
- MySQL 8.0+
- Composer
- Node.js 16+ (for npm)
```

### Step 1: Setup Laravel Backend
```bash
cd portfoliophhadmin

# Install dependencies
composer install

# Setup environment
cp .env.example .env
php artisan key:generate

# Run migrations (including new indexes)
php artisan migrate --path=database/migrations/2026_04_05_000010_add_performance_indexes.php

# Start dev server
php artisan serve --port=8000
```

### Step 2: Setup Flutter App
```bash
cd ..

# Install dependencies
flutter pub get

# Build runner (for json_serializable)
flutter pub run build_runner build

# Run app
flutter run
```

---

## 🧪 PHASE 1: ERROR HANDLING TEST (10 minutes)

### Test 1: Invalid Email Registration
```
1. In app, go to Register screen
2. Enter email: "invalidemail" (no @)
3. Click Register
✅ Expected: Toast shows "Invalid email format"
```

### Test 2: Wrong Password Login
```
1. Register: email1@test.com, password: test123
2. Try login with: email1@test.com, password: wrongpass
✅ Expected: Toast shows "Invalid credentials"
```

### Test 3: Toggle Airport Mode (Network Error)
```
1. Turn on airplane mode on device
2. Try to load jobs
✅ Expected: Toast shows "Network error. Please check your internet."
```

### Test 4: 422 Validation Error
```
1. Login as recruiter
2. Try to create job with empty title
3. Click Create
✅ Expected: Toast shows specific field error
```

### Test 5: Session Expiry (401)
```
1. Open browser dev tools (or modify backend token expiry to 1 second)
2. Login
3. Wait 2 seconds
4. Try to load jobs
✅ Expected: Toast shows "Session expired" + auto-logout
```

### Test 6: Success Feedback
```
1. Login successfully
2. Click Apply to a job
✅ Expected: Green Toast shows "Application submitted successfully! ✅"
```

---

## 🧪 PHASE 2: PAGINATION TEST (15 minutes)

### Test 1: Pagination Response Format
```bash
# In terminal:
curl "http://localhost:8000/api/jobs?page=1&per_page=15" \
  -H "Authorization: Bearer YOUR_TOKEN"

✅ Expected response:
{
  "success": true,
  "message": "Jobs retrieved successfully",
  "data": [... 15 jobs ...],
  "pagination": {
    "current_page": 1,
    "total": XXX,
    "per_page": 15,
    "last_page": YYY
  }
}
```

### Test 2: Load First Page in App
```
1. Login
2. Navigate to Jobs tab
3. Wait for page to load
✅ Expected: 15 jobs appear (with skeleton loaders while loading)
```

### Test 3: Infinite Scroll
```
1. Loading jobs in app
2. Scroll down to bottom
3. Wait 2 seconds
✅ Expected: Next 15 jobs load and append to list (no flicker)
```

### Test 4: Pull to Refresh
```
1. Jobs loaded in app
2. Pull down to refresh
✅ Expected: Skeletons appear, list resets to page 1 with fresh data
```

### Test 5: Large Dataset
```
1. In backend, create 100+ test jobs:
   php artisan tinker
   > factory(App\Models\Job::class, 100)->create()
   
2. In app, scroll through all jobs
✅ Expected: No crashes (OutOfMemory), smooth scrolling
```

---

## 🧪 PHASE 3: AUTHORIZATION TEST (10 minutes)

### Test 1: Recruiter Permissions
```
1. Login as recruiter1
2. Create a job
3. Logout

4. Login as recruiter2
5. Try to EDIT recruiter1's job using:
   curl -X PUT "http://localhost:8000/api/jobs/1" \
     -H "Authorization: Bearer RECRUITER2_TOKEN" \
     -d '{"title": "Hacked"}'

✅ Expected: 403 response "You do not have permission"
```

### Test 2: Ownership Check (UI)
```
1. Login as recruiter1
2. Create Job A
3. Logout

4. Login as recruiter2
5. Navigate to jobs list
6. Find Job A and tap edit button
✅ Expected: 403 error Toast or button disabled
```

### Test 3: Applicant Permissions
```
1. Login as seeker1
2. Apply for Job X
3. Logout

4. Login as seeker2
5. Try to view seeker1's application:
   curl "http://localhost:8000/api/applications/SEEKER1_APP_ID" \
     -H "Authorization: Bearer SEEKER2_TOKEN"

✅ Expected: 403 response
```

### Test 4: Recruiter Can View Own Job Applications
```
1. Login as recruiter1
2. Create Job X
3. Logout

4. Login as seeker1, apply for Job X
5. Logout

6. Login as recruiter1
7. Navigate to "Submitted Applications" or call:
   curl "http://localhost:8000/api/applications?job_id=X" \
     -H "Authorization: Bearer RECRUITER1_TOKEN"

✅ Expected: 200 response with application details
```

---

## 🧪 PHASE 4: LOADING + EMPTY STATES TEST (10 minutes)

### Test 1: Skeleton Loaders
```
1. Restart app
2. Go to Jobs tab
✅ Expected: Animated skeleton cards appear while loading (2-3 seconds)
✅ Expected: Skeletons replace with real job cards
```

### Test 2: Empty State – No Jobs
```
1. In backend, delete all jobs:
   php artisan tinker
   > App\Models\Job::where('status', 'approved')->delete()
   
2. In app, refresh jobs
✅ Expected: Empty state shows
   - Icon (briefcase outline)
   - Message: "No Jobs Available"
   - Button:  "Refresh"
```

### Test 3: Empty State – No Applications
```
1. Login as new seeker user (no applications)
2. Navigate to "My Applications" tab
✅ Expected: Empty state with message and CTA
```

### Test 4: Loading State During Infinite Scroll
```
1. Scroll jobs list to bottom
2. New data loading
✅ Expected: Spinner appears at bottom (not skeleton)
✅ Expected: Spinner disappears when data arrives
```

---

## 🧪 PHASE 5: PERFORMANCE TEST (5 minutes)

### Test 1: Query Count
```bash
# Enable query logging in Laravel
# Edit .env: APP_DEBUG=true

# In backend logs, check queries for:
GET /api/jobs?page=1
GET /api/applications

✅ Expected: 1-2 queries (not 10+)
```

### Test 2: Response Time
```bash
# Test response times:
time curl "http://localhost:8000/api/jobs?page=1" \
  -H "Authorization: Bearer YOUR_TOKEN"

✅ Expected: < 100ms (should say "real 0.05-0.10s")
```

### Test 3: Large List Performance
```
1. Create 500+ jobs in database
2. In app, load jobs and scroll quickly
✅ Expected: Smooth scrolling (60 FPS), no jank
```

---

## 🧪 PHASE 6: VALIDATION TEST (5 minutes)

### Test 1: Required Field Validation
```bash
# Try to create job with empty fields:
curl -X POST "http://localhost:8000/api/jobs" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "",
    "description": ""
  }'

✅ Expected: 422 response
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "title": ["Job title is required"],
    "description": ["Job description is required"]
  }
}
```

### Test 2: Length Validation
```bash
# Title too short (< 5 chars):
curl -X POST "http://localhost:8000/api/jobs" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"title": "Dev"}'

✅ Expected: 422 response with "Title must be at least 5 characters"
```

### Test 3: Enum Validation
```bash
# Invalid job_type:
curl -X POST "http://localhost:8000/api/jobs" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"job_type": "invalid_type"}'

✅ Expected: 422 response with "Invalid job type"
```

### Test 4: Valid Data
```bash
# Create job with valid data:
curl -X POST "http://localhost:8000/api/jobs" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "title": "Senior Developer",
    "description": "Looking for experienced PHP developer",
    "location": "Manila",
    "salary_min": 50000,
    "salary_max": 100000,
    "job_type": "full_time"
  }'

✅ Expected: 201 response with created job
```

---

## 📊 FULL SYSTEM TEST (30 minutes)

### Scenario 1: Complete User Flow
```
1. [Recruiter] Register
2. [Recruiter] Complete profile
3. [Recruiter] Create 3 jobs
4. [Seeker] Register
5. [Seeker] Browse jobs
6. [Seeker] Apply to 2 jobs
7. [Recruiter] View pending applications
8. [Recruiter] Approve 1 application
9. [Seeker] Check application status
✅ Expected: All steps succeed with appropriate feedback Toasts
```

### Scenario 2: Error Recovery
```
1. Turn on airplane mode
2. Try to load jobs
3. ✅ See error Toast
4. Turn off airplane mode
5. Tap "Refresh" button
6. ✅ Jobs load successfully
```

### Scenario 3: Large Scale
```
1. Create 1000+ jobs in database
2. In app, load jobs
3. Scroll from page 1 to page 20
4. Apply to a job
5. Go back and scroll
✅ Expected: No crashes, smooth performance (< 100ms responses)
```

---

## 🔧 TROUBLESHOOTING

### Issue: Skeleton loader stuck forever
**Solution:** Check if API is running
```bash
curl http://localhost:8000/api/health
# Should return: {"status": "ok"}
```

### Issue: 401 errors constantly
**Solution:** Restart Laravel and clear token cache
```bash
php artisan cache:clear
php artisan auth:clear-resets
```

### Issue: Pagination not working
**Solution:** Verify migration ran
```bash
php artisan migrate:status
# Check that 2026_04_05_000010_add_performance_indexes is marked "Ran"
```

### Issue: Toast not appearing
**Solution:** Verify ToastService is initialized
```dart
// In main.dart, check:
scaffoldMessengerKey: ToastService.scaffoldMessengerKey,
// is set on MaterialApp.router
```

### Issue: Empty states not showing
**Solution:** Check provider logic
```dart
// In provider, verify:
if (jobs.isEmpty && !isLoading) {
  // Show empty state
}
```

---

## 📝 TEST RESULTS TEMPLATE

Use this to track test results:

```
Date: __________
Tester: __________
Environment: [local / staging / production]

PHASE 1: ERROR HANDLING
  [ ] Test 1 - Invalid email: PASS / FAIL
  [ ] Test 2 - Wrong password: PASS / FAIL
  [ ] Test 3 - Network error: PASS / FAIL
  [ ] Test 4 - 422 validation: PASS / FAIL
  [ ] Test 5 - 401 auth: PASS / FAIL
  [ ] Test 6 - Success feedback: PASS / FAIL

PHASE 2: PAGINATION
  [ ] Test 1 - Response format: PASS / FAIL
  [ ] Test 2 - Load first page: PASS / FAIL
  [ ] Test 3 - Infinite scroll: PASS / FAIL
  [ ] Test 4 - Pull refresh: PASS / FAIL
  [ ] Test 5 - Large dataset: PASS / FAIL

PHASE 3: AUTHORIZATION
  [ ] Test 1 - Recruiter permissions: PASS / FAIL
  [ ] Test 2 - Ownership check UI: PASS / FAIL
  [ ] Test 3 - Applicant permissions: PASS / FAIL
  [ ] Test 4 - Recruiter view apps: PASS / FAIL

PHASE 4: LOADING + EMPTY STATES
  [ ] Test 1 - Skeleton loaders: PASS / FAIL
  [ ] Test 2 - Empty state no jobs: PASS / FAIL
  [ ] Test 3 - Empty state no apps: PASS / FAIL
  [ ] Test 4 - Spinner during scroll: PASS / FAIL

PHASE 5: PERFORMANCE
  [ ] Test 1 - Query count: PASS / FAIL
  [ ] Test 2 - Response time: PASS / FAIL
  [ ] Test 3 - Large list perf: PASS / FAIL

PHASE 6: VALIDATION
  [ ] Test 1 - Required fields: PASS / FAIL
  [ ] Test 2 - Length validation: PASS / FAIL
  [ ] Test 3 - Enum validation: PASS / FAIL
  [ ] Test 4 - Valid data: PASS / FAIL

OVERALL: [ ] READY FOR PRODUCTION
```

---

## 🚀 DEPLOYMENT CHECKLIST

### Pre-Deployment
- [ ] All tests passing
- [ ] Code reviewed
- [ ] Database migrations tested
- [ ] Environment variables set
- [ ] Logging enabled

### Deployment Steps
```bash
# 1. Push to git
git add .
git commit -m "feat: all 6 production hardening phases complete"
git push origin develop

# 2. Backup database
mysqldump -u root -p portfolio_ph > backup_$(date +%Y%m%d).sql

# 3. Pull latest code
git pull origin develop

# 4. Run migrations
php artisan migrate

# 5. Clear cache
php artisan cache:clear
php artisan config:cache

# 6. Restart services
systemctl restart php-fpm
systemctl restart nginx
# or for local dev:
# Just restart `php artisan serve`
```

### Post-Deployment
- [ ] Smoke test (register, login, create job)
- [ ] Monitor error logs for issues
- [ ] Check response times
- [ ] Verify pagination working
- [ ] Test error handling

---

## 📞 SUPPORT

If issues arise:
1. Check logs: `tail -f storage/logs/laravel.log`
2. Check Dart console for Flutter errors
3. Verify database connection
4. Check API endpoint responses with curl
5. Review CODEBASE_ANALYSIS_FULL.md for detailed architecture

---

**Generated:** April 5, 2026  
**Status:** ✅ Ready for Testing & Deployment
