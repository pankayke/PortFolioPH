# ⚕️ CRITICAL PRODUCTION CHECKLIST
**Before deploying to production, verify these items:**

---

## 🔐 SECURITY

- [ ] **API Base URL uses HTTPS** (not HTTP in production)
  - Current: `http://localhost:8000/api` (development)
  - Production: `https://api.portfolioph.com/api`
  - File: `lib/core/services/api_service.dart` line 10

- [ ] **CORS configured correctly** in Laravel
  - Check: `config/cors.php`
  - Verify: `CORS_ALLOWED_ORIGINS` includes Flutter domain

- [ ] **Sanctum token expiry configured**
  - Check: Laravel .env `SANCTUM_EXPIRATION`
  - Default: 525600 minutes (1 year) - might be too long
  - Recommend: 7 days for better security

- [ ] **Secure storage working on all platforms**
  - [ ] iOS Keychain configured
  - [ ] Android Keychain working
  - [ ] Windows/Linux fallback secure storage

- [ ] **HTTPS certificate valid**
  - [ ] No self-signed certs in production
  - [ ] Certificate properly installed

---

## 🔑 TOKEN MANAGEMENT

- [ ] **Token properly saved after registration**
  - Code verified: YES ✅
  - IMPORTANT: Test with real user to ensure saved

- [ ] **Token properly saved after login**
  - Code verified: YES ✅
  - IMPORTANT: Test with real user

- [ ] **/auth/me endpoint responds correctly**
  - Code verified: YES ✅
  - Test: See RUNTIME_VALIDATION_CHECKLIST.md

- [ ] **Token invalidated on logout**
  - Code verified: YES ✅ ($user->tokens()->delete())
  - Test: See RUNTIME_VALIDATION_CHECKLIST.md

- [ ] **Token cleared on 401**
  - Code verified: YES ✅
  - Behavior: Automatic (no manual action)

---

## 🚀 DEPLOYMENT SPECIFICS

### Laravel (.env production)
```bash
# App
APP_ENV=production
APP_DEBUG=false  # CRITICAL: Must be false in production

# Database
DB_CONNECTION=mysql
DB_HOST=production-db.example.com
DB_DATABASE=portfolioph_prod
DB_USERNAME=db_user
DB_PASSWORD=secure_password

# Sanctum
SANCTUM_EXPIRATION=10080  # 7 days in minutes
SANCTUM_STATEFUL_DOMAINS=app.portfolioph.com,www.portfolioph.com

# CORS
CORS_ALLOWED_ORIGINS=https://app.portfolioph.com,https://www.portfolioph.com
```

### Flutter (main.dart production)
```dart
// In production build:
// flutter build apk --release
// flutter build ios --release

// Verify:
// - No debugPrint() statements active
// - No console logs
// - Error handling in place
```

---

## 🧪 PRE-DEPLOYMENT TESTS

### Unit Tests
- [ ] `flutter test` passes
- [ ] No error output
- [ ] All test suites complete

### Integration Tests
- [ ] Run in RUNTIME_VALIDATION_CHECKLIST.md
- [ ] All 7 tests pass
- [ ] Database integrity verified

### Load Testing
- [ ] Test with multiple concurrent users
- [ ] Token generation under load
- [ ] No memory leaks

### Security Testing
- [ ] Cross-site scripting (XSS) protected
- [ ] SQL injection prevented (via Eloquent)
- [ ] Token hijacking prevented (HTTPS only)

---

## 📊 MONITORING & LOGGING

### Laravel
- [ ] Error logging configured
- [ ] RequestLog middleware added to track API calls
- [ ] Monitor 401 errors (indicate possible attacks or token issues)

### Flutter
- [ ] Crash reporting configured
- [ ] User analytics enabled
- [ ] Error reporting (Sentry, Firebase, etc.)

### Database
- [ ] Backup scheduled (daily minimum)
- [ ] Connection pooling configured
- [ ] Slow query logging enabled

---

## 🔄 ROLLBACK PLAN

### If bugs found after deployment:

1. **Auth broken** (users can't login)
   - Rollback Laravel to previous version
   - Rollback Flutter on app store

2. **Token not being saved**
   - Check Flutter secure storage logs
   - Verify database connection

3. **401 errors on all requests**
   - Check Sanctum middleware
   - Verify CORS settings
   - Check token in database

4. **Session restore failing**
   - /auth/me endpoint issue
   - Token expiry too short
   - Database connection problem

---

## 📝 CHECKLIST BEFORE GO-LIVE

- [ ] All unit tests passing
- [ ] All integration tests passing (see RUNTIME_VALIDATION_CHECKLIST.md)
- [ ] HTTPS configured and tested
- [ ] Database backups working
- [ ] Error logging enabled
- [ ] User documentation updated
- [ ] Support team trained
- [ ] 24/7 monitoring active

---

## 🚨 CRITICAL ITEMS (DO NOT SKIP)

| Item | Status | Owner | Deadline |
|------|--------|-------|----------|
| HTTPS enabled | [ ] | DevOps | Day 0 |
| Sanctum configured | [ ] | Backend | Day 0 |
| /auth/me tested | [ ] | QA | Day -1 |
| Token secure storage verified | [ ] | Mobile | Day -1 |
| Database backups automated | [ ] | DevOps | Day -1 |
| Monitoring alerts configured | [ ] | DevOps | Day -1 |
| Rollback plan ready | [ ] | All | Day 0 |

---

## 🎯 SIGN-OFF TEMPLATE

**Integration Validation Complete:**
- [ ] Code audit passed
- [ ] Runtime tests passed
- [ ] Security verified
- [ ] Documentation complete

**Approved for production deployment:**

Name: ________________________  
Date: ________________________  
Signature: ________________________

---

**Last Updated:** April 5, 2026  
**Status:** READY FOR PRODUCTION REVIEW
