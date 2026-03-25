# Real-Time Admin Approval System - Implementation Checklist

**Project:** PortFolioPH (Laravel + Flutter)  
**Objective:** Enable instant real-time reflection of admin approvals in Flutter user app  
**Status:** Step-by-step implementation guide  
**Estimated Time:** 2-3 days for solo developer  

---

## PHASE 1: Backend Setup (Laravel) - ~4-6 hours

### Day 1 Morning: Foundation
- [ ] **1.1** Execute: `composer require laravel/reverb`
- [ ] **1.2** Execute: `php artisan reverb:install`
- [ ] **1.3** Update `.env`:
  ```env
  BROADCAST_DRIVER=reverb
  REVERB_APP_ID=portfolioph-reverb
  REVERB_APP_KEY=<generate-32-char-random>
  REVERB_APP_SECRET=<generate-32-char-random>
  REVERB_PUBLIC_HOST=localhost
  REVERB_PUBLIC_PORT=8080
  REVERB_PUBLIC_SCHEME=ws
  ```
- [ ] **1.4** Execute: `php artisan tinker` → verify Reverb config loads
- [ ] **1.5** Test start: `php artisan reverb:start` (should show "Server started on 0.0.0.0:8080 📡")

### Database Migrations
- [ ] **1.6** Copy [migration file for portfolios](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-37-migrations) 
  - Create: `database/migrations/2024_XX_XX_add_approval_fields_to_portfolios.php`
- [ ] **1.7** Copy [migration file for job postings](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-37-migrations)
  - Create: `database/migrations/2024_XX_XX_add_approval_fields_to_job_postings.php`
- [ ] **1.8** Execute: `php artisan migrate`
- [ ] **1.9** Verify in DB: 
  ```bash
  # In Laravel Tinker
  >>> \App\Models\Portfolio::first()->getAttributes();
  # Should show: status, reviewed_by, reviewed_at, rejection_reason
  ```

### Events & Broadcasting
- [ ] **1.10** Copy [PortfolioApproved event](REALTIME_ADMIN_APPROVAL_SYSTEM.md#file-appeventsportfolioapprovedphp)
  - Create: `app/Events/PortfolioApproved.php`
- [ ] **1.11** Copy [PortfolioRejected event](REALTIME_ADMIN_APPROVAL_SYSTEM.md#file-appeventsportfoliorejectedphp)
  - Create: `app/Events/PortfolioRejected.php`
- [ ] **1.12** Copy [JobPostingApproved event](REALTIME_ADMIN_APPROVAL_SYSTEM.md#file-appeventspostingapprovedphp)
  - Create: `app/Events/JobPostingApproved.php`
- [ ] **1.13** Update `routes/channels.php` with [channel auth logic](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-35-create-broadcasting-channels)
- [ ] **1.14** Test event dispatch in Tinker:
  ```bash
  >>> \App\Events\PortfolioApproved::dispatch(\App\Models\Portfolio::first());
  # Should broadcast to Reverb
  ```

### Models & Controller
- [ ] **1.15** Update `app/Models/Portfolio.php` with [approval fields](REALTIME_ADMIN_APPROVAL_SYSTEM.md#file-appmodelsportfoliophp)
- [ ] **1.16** Update `app/Models/JobPosting.php` with [approval fields](REALTIME_ADMIN_APPROVAL_SYSTEM.md#file-appmodelsjobpostingphp)
- [ ] **1.17** Create `app/Http/Controllers/Admin/PortfolioAuditController.php` [from guide](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-37-create-admin-approval-controller)
- [ ] **1.18** Update `routes/api.php` with [approval routes](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-38-routes)
- [ ] **1.19** Create `app/Http/Middleware/EnsureAdminRole.php` [from guide](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-39-middleware-admin-role-check)
- [ ] **1.20** Register middleware in `app/Http/Kernel.php`

### Authentication
- [ ] **1.21** Verify Sanctum installed: `composer show | grep sanctum`
- [ ] **1.22** If missing: `composer require laravel/sanctum && php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"`
- [ ] **1.23** Update login controller to return Sanctum token (see [Step 5.1](REALTIME_ADMIN_APPROVAL_SYSTEM.md#51-sanctum-authentication-token-laravel))

### Local Testing
- [ ] **1.24** Terminal 1: Start Reverb
  ```bash
  php artisan reverb:start --host=0.0.0.0 --port=8080
  ```
- [ ] **1.25** Terminal 2: Start API server
  ```bash
  php artisan serve
  ```
- [ ] **1.26** Terminal 3: Start Queue listener (for broadcasting)
  ```bash
  php artisan queue:listen
  ```
- [ ] **1.27** Test approval endpoint:
  ```bash
  curl -X POST http://localhost:8000/api/admin/portfolios/1/approve \
    -H "Authorization: Bearer <ADMIN_TOKEN>" \
    -H "Content-Type: application/json"
  ```
- [ ] **1.28** Verify Reverb receives event (check Terminal 1 logs)

---

## PHASE 2: Flutter Setup - ~4-6 hours

### Pubspec & Packages
- [ ] **2.1** Update `pubspec.yaml`:
  ```yaml
  dependencies:
    web_socket_channel: ^2.4.0
    json_serializable: ^6.7.0
    dio: ^5.3.1
  dev_dependencies:
    build_runner: ^2.4.6
  ```
- [ ] **2.2** Execute: `flutter pub get`
- [ ] **2.3** Generate serialization code: `flutter pub run build_runner build`

### Services
- [ ] **2.4** Create `lib/services/realtime_service.dart` [from guide](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-62-create-websocket-service)
  - Copy entire file (200 lines)
  - Update constants if needed: `_REVERB_HOST`, `_REVERB_PORT`, `_REVERB_SCHEME`
- [ ] **2.5** Create `lib/models/portfolio_event.dart` [from guide](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-63-create-portfolio-event-model)
- [ ] **2.6** Create `lib/services/notification_service.dart` [from guide](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-65-create-ui-notification-service)

### State Management
- [ ] **2.7** Update `lib/presentation/providers/portfolio_provider.dart` [from guide](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-64-update-portfolioprovider)
  - Add `RealtimeService` dependency
  - Add `_subscribeToPortfolioUpdates()` method
  - Add `_handlePortfolioEvent()` method
  - Add event listener setup

### UI Updates
- [ ] **2.8** Update `lib/presentation/screens/portfolio_detail_screen.dart` [from guide](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-66-update-ui-screen-portfoliodetailscreen)
  - Add `StreamSubscription` to listen for events
  - Add status badge widget
  - Add rejection reason display
  - Add notification handling

### Initialization
- [ ] **2.9** Update `lib/main.dart` to provide RealtimeService and PortfolioProvider [from guide](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-67-initialize-services-in-maindart)
- [ ] **2.10** Update `lib/presentation/providers/auth_provider.dart` [from guide](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-68-connect-on-login)
  - Connect to Reverb on login success
  - Disconnect on logout

### Testing
- [ ] **2.11** Build APK for testing: `flutter build apk --debug`
- [ ] **2.12** Install on device/emulator: `flutter install`
- [ ] **2.13** Run in debug: `flutter run -v`

---

## PHASE 3: Integration Testing - ~2-3 hours

### Manual E2E Test Flow
1. **Backend:** Start Reverb, API, Queue
2. **Backend:** Login admin, get token
3. **Flutter:** Login user, verify WebSocket connection shows
4. **Backend:** Approve portfolio via curl/API
5. **Flutter:** Verify status badge updates instantly
6. **Backend:** Reject portfolio with reason
7. **Flutter:** Verify rejection dialog shows

### Test Checklist
- [ ] **3.1** WebSocket connects on login
  - Check: `[Realtime] ✅ Connected to server` in Flutter logs
- [ ] **3.2** Channel subscribes correctly
  - Check: `[Realtime] 🔔 Subscribed to: portfolios.1` in Flutter logs
- [ ] **3.3** Event broadcasts instantly
  - Time: < 200ms from admin approval to Flutter receive
- [ ] **3.4** UI updates without page refresh
  - Status badge changes from "Pending" to "Approved"
  - Rejection reason displays in container
- [ ] **3.5** Reconnection works
  - Kill Reverb server, Flutter auto-reconnects after 3s
  - No app crash
- [ ] **3.6** Multiple portfolios work
  - Select portfolio 1 → see updates for portfolio 1
  - Switch to portfolio 2 → see updates for portfolio 2
  - No cross-portfolio notifications
- [ ] **3.7** Admin-only access works
  - Non-admin user tries to approve → 403 Unauthorized
  - Admin user approves → success

### Performance Testing
- [ ] **3.8** Measure WebSocket latency:
  ```dart
  final startTime = DateTime.now();
  // ... event received
  final latency = DateTime.now().difference(startTime);
  print('Event latency: ${latency.inMilliseconds}ms');
  // Expected: < 100ms locally
  ```
- [ ] **3.9** Test with 10+ concurrent subscriptions (10 different portfolios open)
- [ ] **3.10** Test rapid approvals (10 approvals/sec)

---

## PHASE 4: Security Hardening - ~1-2 hours

### Laravel
- [ ] **4.1** Add rate limiting to approval endpoints
  ```php
  Route::middleware(['throttle:60,1'])->group(function () {
    // approval routes
  });
  ```
- [ ] **4.2** Add input validation for rejection_reason
  ```php
  $validated = $request->validate([
    'rejection_reason' => 'required|string|max:1000',
  ]);
  ```
- [ ] **4.3** Add authorization check (admin role)
- [ ] **4.4** Create AuditLog model and migrations [from guide](REALTIME_ADMIN_APPROVAL_SYSTEM.md#72-audit-logging)
- [ ] **4.5** Log all admin actions

### Flutter
- [ ] **4.6** Remove debug logs in production build
  ```dart
  if (kDebugMode) {
    debugPrint('[Realtime] Connected');
  }
  ```
- [ ] **4.7** Validate token before connecting
- [ ] **4.8** Never store token in SharedPreferences unencrypted
  ```dart
  final secureStorage = FlutterSecureStorage();
  await secureStorage.write(key: 'auth_token', value: token);
  ```

---

## PHASE 5: Production Preparation - ~1-2 hours

### Environment Configuration
- [ ] **5.1** Create production `.env` file
- [ ] **5.2** Update Flutter config for production API endpoint
- [ ] **5.3** Generate secure REVERB_APP_KEY and REVERB_APP_SECRET
- [ ] **5.4** Configure Redis for production

### Documentation
- [ ] **5.5** Update README with setup instructions
- [ ] **5.6** Create runbook for ops team
- [ ] **5.7** Document troubleshooting steps

### Monitoring
- [ ] **5.8** Setup error tracking (Sentry)
- [ ] **5.9** Configure logging (structured JSON)
- [ ] **5.10** Setup alerts for WebSocket disconnections

---

## FILE CHECKLIST (Copy These from Guide)

### Laravel Files
- [ ] `app/Events/PortfolioApproved.php` ← [Link](REALTIME_ADMIN_APPROVAL_SYSTEM.md#file-appeventsportfolioapprovedphp)
- [ ] `app/Events/PortfolioRejected.php` ← [Link](REALTIME_ADMIN_APPROVAL_SYSTEM.md#file-appeventsportfoliorejectedphp)
- [ ] `app/Events/JobPostingApproved.php` ← [Link](REALTIME_ADMIN_APPROVAL_SYSTEM.md#file-appeventspostingapprovedphp)
- [ ] `app/Http/Controllers/Admin/PortfolioAuditController.php` ← [Link](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-37-create-admin-approval-controller)
- [ ] `app/Http/Middleware/EnsureAdminRole.php` ← [Link](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-39-middleware-admin-role-check)
- [ ] `database/migrations/2024_XX_XX_add_approval_fields_to_portfolios.php` ← [Link](REALTIME_ADMIN_APPROVAL_SYSTEM.md#migration-update-portfolios-table)
- [ ] `database/migrations/2024_XX_XX_add_approval_fields_to_job_postings.php` ← [Link](REALTIME_ADMIN_APPROVAL_SYSTEM.md#migration-update-job-postings-table)
- [ ] `routes/api.php` (add routes from guide)
- [ ] `routes/channels.php` (update with new channels)

### Flutter Files
- [ ] `lib/services/realtime_service.dart` ← [Link](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-62-create-websocket-service)
- [ ] `lib/models/portfolio_event.dart` ← [Link](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-63-create-portfolio-event-model)
- [ ] `lib/services/notification_service.dart` ← [Link](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-65-create-ui-notification-service)
- [ ] `lib/presentation/screens/portfolio_detail_screen.dart` ← [Link](REALTIME_ADMIN_APPROVAL_SYSTEM.md#step-66-update-ui-screen-portfoliodetailscreen)

### Updated Files
- [ ] `lib/main.dart` (update initialization section)
- [ ] `lib/presentation/providers/portfolio_provider.dart` (add event handling)
- [ ] `lib/presentation/providers/auth_provider.dart` (add connect/disconnect)
- [ ] `app/Models/Portfolio.php` (add approval fields)
- [ ] `app/Models/JobPosting.php` (add approval fields)
- [ ] `pubspec.yaml` (add packages)

---

## TROUBLESHOOTING QUICK LINKS

| Issue | Solution |
|-------|----------|
| WebSocket connection refused | [See guide section](REALTIME_QUICK_REFERENCE.md#issue-1-websocket-connection-refused) |
| Channel auth 403 | [See guide section](REALTIME_QUICK_REFERENCE.md#issue-2-channel-auth-403-forbidden) |
| Events not broadcasting | [See guide section](REALTIME_QUICK_REFERENCE.md#issue-3-events-not-broadcasting) |
| UI not updating | [See guide section](REALTIME_QUICK_REFERENCE.md#issue-4-provider-state-not-updating) |
| Token expired | [See guide section](REALTIME_QUICK_REFERENCE.md#issue-5-token-expired-mid-stream) |

---

## COMMIT STRATEGY

```bash
# Commit 1: Backend foundation
git add database/migrations routes/channels.php app/Events app/Http/Controllers/Admin app/Http/Middleware
git commit -m "feat(realtime): add Laravel Reverb and approval event infrastructure"

# Commit 2: Flutter services
git add lib/services lib/models
git commit -m "feat(realtime): add WebSocket service and event models"

# Commit 3: UI integration
git add lib/presentation/screens lib/presentation/providers
git commit -m "feat(realtime): integrate real-time approval notifications in UI"

# Commit 4: Security & hardening
git add app/Http/Middleware database/models docs
git commit -m "feat(realtime): add rate limiting, audit logging, and documentation"
```

---

## SUCCESS CRITERIA

✅ **Phase 1 Complete:**
- [x] Reverb running locally
- [x] Events broadcasting
- [x] Controller API working

✅ **Phase 2 Complete:**
- [x] Flutter connects to WebSocket
- [x] Subscribes to channels
- [x] Receives events in FlutterUI

✅ **Phase 3 Complete:**
- [x] E2E admin approval → user sees instantly
- [x] No page refresh needed
- [x] Latency < 200ms

✅ **Phase 4 Complete:**
- [x] Rate limiting enforced
- [x] Auth token validated
- [x] Audit logs recorded

✅ **Phase 5 Complete:**
- [x] Production .env configured
- [x] Error tracking enabled
- [x] Monitoring dashboards ready

---

## TIME BREAKDOWN

| Phase | Est. Time | Actual |
|-------|-----------|--------|
| 1. Backend Setup | 4-6h | ___ |
| 2. Flutter Setup | 4-6h | ___ |
| 3. Integration Testing | 2-3h | ___ |
| 4. Security Hardening | 1-2h | ___ |
| 5. Production Prep | 1-2h | ___ |
| **TOTAL** | **12-19h** | ___ |

**Recommended:** Spread across 2-3 days (avoid burnout)

---

## CONTACT & SUPPORT

**Need help?**
- Review [Full Implementation Guide](REALTIME_ADMIN_APPROVAL_SYSTEM.md)
- Check [Quick Reference](REALTIME_QUICK_REFERENCE.md)
- See [Deployment Guide](PRODUCTION_DEPLOYMENT_GUIDE.md)

**Questions?**
- DevOps Team: devops@portfolioph.ph
- Lead Dev: +63 906 123 4567
- Slack: #realtime-system

---

**Version:** 1.0 | **Date:** March 2026 | **Ready to Start? Let's Go! 🚀**
