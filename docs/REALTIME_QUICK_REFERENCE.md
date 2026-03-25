# Laravel Reverb + Flutter WebSocket Integration - Quick Reference

## 🚀 Command Reference

### Laravel Setup Commands
```bash
# 1. Install Reverb
composer require laravel/reverb

# 2. Publish configuration
php artisan reverb:install

# 3. Run migrations (for status fields)
php artisan migrate --path=database/migrations/2024_XX_XX_add_approval_fields_to_portfolios.php

# 4. Create events (if not copying from guide)
php artisan make:event PortfolioApproved
php artisan make:event PortfolioRejected

# 5. Create channel auth controller
php artisan make:controller Auth/ChannelAuthController

# 6. Start Reverb server (development)
php artisan reverb:start --host=0.0.0.0 --port=8080

# 7. Run migrations
php artisan migrate

# 8. Queue jobs listener
php artisan queue:listen --connections=redis
```

### Flutter Setup Commands
```bash
# 1. Add packages
flutter pub add web_socket_channel json_serializable dio async

# 2. Generate serialization code
flutter pub run build_runner build

# 3. Clean & rebuild
flutter clean && flutter pub get && flutter pub run build_runner build

# 4. Test WebSocket on debug device
flutter run -d <device-id>
```

---

## 📋 Environment Variables Template

### Laravel (.env)
```env
# Reverb Configuration
BROADCAST_DRIVER=reverb

REVERB_APP_ID=portfolioph-reverb
REVERB_APP_KEY=your-random-app-key-min-32-chars
REVERB_APP_SECRET=your-random-app-secret-min-32-chars

# Public client connection (what Flutter uses)
REVERB_PUBLIC_HOST=reverb.api.portfolioph.ph
REVERB_PUBLIC_PORT=443
REVERB_PUBLIC_SCHEME=wss

# Server listening (internal)
REVERB_HOST=0.0.0.0
REVERB_PORT=8080
REVERB_SCHEME=ws

# Redis (for broadcasting queue)
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=null
REDIS_CACHE_DB=1
REDIS_QUEUE_DB=2

QUEUE_CONNECTION=redis

# Sanctum
SANCTUM_STATEFUL_DOMAINS=api.portfolioph.ph,reserv.api.portfolioph.ph
SANCTUM_DTOS_USER=App\Models\User
```

---

## 🔐 Security Checklist

### Before Production
- [ ] Generate strong REVERB_APP_KEY and REVERB_APP_SECRET
- [ ] Enable HTTPS (wss://) for WebSocket
- [ ] Implement rate limiting (throttle:30,1)
- [ ] Validate all input (rejection_reason <= 1000 chars)
- [ ] Test channel authorization (owner + admin check)
- [ ] Verify Sanctum token validation
- [ ] Enable CORS only for API domain
- [ ] Setup audit logging
- [ ] Configure Firebase FCM for notifications
- [ ] Test admin revoke permission mid-stream

### Files to Review
- [ ] config/broadcasting.php (verify admin-only channels)
- [ ] routes/channels.php (authorization callbacks)
- [ ] app/Http/Controllers/Admin/PortfolioAuditController.php (authorization checks)
- [ ] app/Http/Middleware/EnsureAdminRole.php (role validation)
- [ ] database/migrations/* (index creation)

---

## 📦 Docker Compose Example

### For Local Development
```yaml
version: '3.8'

services:
  # Laravel API + Reverb
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: portfolioph-api
    environment:
      - BROADCAST_DRIVER=reverb
      - REVERB_HOST=0.0.0.0
      - REVERB_PORT=8080
      - REDIS_HOST=redis
    ports:
      - "8000:8000"  # API
      - "8080:8080"  # Reverb WebSocket
    depends_on:
      - redis
      - postgres
    volumes:
      - .:/app
    command: php artisan serve --host=0.0.0.0 --port=8000

  # Redis (for broadcasting)
  redis:
    image: redis:7-alpine
    container_name: portfolioph-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  # PostgreSQL (optional)
  postgres:
    image: postgres:15-alpine
    container_name: portfolioph-db
    environment:
      - POSTGRES_DB=portfolioph
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  redis_data:
  postgres_data:
```

### Start Services
```bash
docker-compose up -d

# Check logs
docker-compose logs -f api

# Run migrations inside container
docker-compose exec api php artisan migrate

# Test Reverb
docker-compose exec api php artisan tinker
>>> PortfolioApproved::dispatch(Portfolio::find(1));
```

---

## 🧪 Testing Endpoints

### 1. Get Auth Token (Flutter)
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password"
  }'

# Response:
# {
#   "token": "1|abc123xyz...",
#   "user": {...}
# }
```

### 2. Test Channel Authorization
```bash
# This header simulates Flutter's Bearer token
curl -X POST http://localhost:8000/broadcasting/auth \
  -H "Authorization: Bearer 1|abc123xyz..." \
  -H "Content-Type: application/json" \
  -d '{
    "channel_name": "portfolios.1"
  }'
```

### 3. Approve Portfolio (Trigger Event)
```bash
curl -X POST http://localhost:8000/api/admin/portfolios/1/approve \
  -H "Authorization: Bearer <ADMIN_TOKEN>" \
  -H "Content-Type: application/json"

# Response:
# {
#   "message": "✅ Portfolio approved and user notified",
#   "data": {
#     "id": 1,
#     "status": "approved",
#     "reviewed_by": 5,
#     "reviewed_at": "2026-03-21T10:30:00Z"
#   }
# }
```

### 4. Reject Portfolio
```bash
curl -X POST http://localhost:8000/api/admin/portfolios/1/reject \
  -H "Authorization: Bearer <ADMIN_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "rejection_reason": "Portfolio title is missing. Please add a descriptive title."
  }'
```

---

## 🐛 Common Issues & Fixes

### Issue 1: WebSocket Connection Refused
**Symptom:** Flutter shows `[Realtime] ❌ Connection failed`

**Fixes:**
```dart
// 1. Check Reverb is running
// Terminal: php artisan reverb:start

// 2. Verify correct host/port in Flutter
static const String _REVERB_HOST = 'reverb.api.portfolioph.ph';
static const int _REVERB_PORT = 443;

// 3. Check CORS
// Laravel routes/api.php should allow your Flutter app

// 4. Enable debug in Flutter
// Add: debugPrint('[Realtime] Attempting connection to...')
```

### Issue 2: Channel Auth 403 Forbidden
**Symptom:** Server says `not authorized for this private channel`

**Fixes:**
```php
// routes/channels.php
Broadcast::channel('portfolios.{portfolio_id}', function ($user, $portfolio_id) {
    // Debug logs
    \Log::info("Auth check for user {$user->id} on portfolio {$portfolio_id}");
    
    try {
        $portfolio = Portfolio::find($portfolio_id);
        if (!$portfolio) {
            \Log::warning("Portfolio {$portfolio_id} not found");
            return false;
        }
        
        $authorized = $user->id === $portfolio->user_id || $user->role === 'admin';
        \Log::info("Authorization result: $authorized");
        
        return $authorized;
    } catch (\Exception $e) {
        \Log::error("Channel auth exception: {$e->getMessage()}");
        return false;
    }
});
```

### Issue 3: Events Not Broadcasting
**Symptom:** No messages received in Flutter

**Fixes:**
```php
// 1. Verify Queue is running
// Terminal: php artisan queue:listen

// 2. Check event broadcast fields
class PortfolioApproved implements ShouldBroadcast {
    public function broadcastAs(): string {
        return 'portfolio.approved'; // ← Must match Flutter listener
    }
}

// 3. Test manually
php artisan tinker
>>> event(new \App\Events\PortfolioApproved(\App\Models\Portfolio::find(1)));
```

### Issue 4: Provider State Not Updating
**Symptom:** Flutter UI doesn't refresh when event received

**Fixes:**
```dart
// 1. Verify notifyListeners() called
_handlePortfolioEvent(event) {
    _selectedPortfolio = _selectedPortfolio!.copyWith(status: event.status);
    notifyListeners(); // ← Must call this
}

// 2. Check Consumer widget is wrapped correctly
Consumer<PortfolioProvider>(
  builder: (context, provider, _) {
    // This rebuilds on notifyListeners()
  }
)

// 3. Verify event data structure
debugPrint('Event data: ${event.toString()}');
```

### Issue 5: Token Expired Mid-Stream
**Symptom:** WebSocket disconnects after 24 hours

**Implementation:**
```dart
void _setupRealtimeListener() {
  _realtimeService.events.listen(
    (event) {
      if (event['event'] == 'pusher:error' && 
          event['data']['message'].contains('unauthorized')) {
        // Token expired, refresh
        _refreshToken();
      }
    },
  );
}

Future<void> _refreshToken() async {
  final newToken = await _apiService.refreshToken();
  await _realtimeService.reconnect();
}
```

---

## 📊 Monitoring & Logs

### Check Reverb Health
```bash
# Inside container
docker-compose exec api php artisan tinker

>>> \Laravel\Reverb\Facades\Reverb::getChannelCount();
>>> \Laravel\Reverb\Facades\Reverb::getConnectionCount();
```

### View Recent Events
```php
// In Laravel tinker
>>> \App\Models\AuditLog::latest()->take(10)->get(['admin_id', 'action', 'entity_type', 'created_at']);
```

### Flutter Debug Output
```dart
// Enable comprehensive logging
void _setupRealtimeListener() {
  _realtimeService.events.listen(
    (event) {
      debugPrint('[Realtime Event] Type: ${event['event']}');
      debugPrint('[Realtime Event] Data: ${jsonEncode(event)}');
    },
    onError: (e) => debugPrint('[Realtime Error] $e'),
  );
}
```

---

## 📱 Bilingual Support Example

### Flutter Localization (Philippine Context 🇵🇭)
```dart
// lib/l10n/app_en.arb
{
  "portfolioApprovedTitle": "✅ Portfolio Approved!",
  "portfolioApprovedMsg": "Your portfolio is now live. Share with employers!",
  "portfolioRejectedTitle": "❌ Portfolio Needs Review",
  "portfolioRejectedMsg": "Please check the feedback below.",
  "feedbackFromAdmin": "Feedback from admin:",
  "resubmitPortfolio": "Resubmit Portfolio",
  "connecting": "🔗 Connecting..."
}

// lib/l10n/app_tl.arb
{
  "portfolioApprovedTitle": "✅ Ang Portfolio Mo ay Naaprove na!",
  "portfolioApprovedMsg": "Ang iyong portfolio ay live na. Ibahagi sa mga employer!",
  "portfolioRejectedTitle": "❌ Ang Portfolio Mo ay Kailangang Suriin",
  "portfolioRejectedMsg": "Mangyaring basahin ang feedback sa ibaba.",
  "feedbackFromAdmin": "Feedback mula sa admin:",
  "resubmitPortfolio": "I-resubmit ang Portfolio",
  "connecting": "🔗 Nag-coconnect..."
}
```

### Usage in UI
```dart
_notificationService.showApprovalSnackBar(
  context,
  title: AppLocalizations.of(context)!.portfolioApprovedTitle,
  message: AppLocalizations.of(context)!.portfolioApprovedMsg,
  isApproved: true,
);
```

---

## 🎯 Performance Tips

1. **Subscribe to specific portfolios only** (not all)
2. **Unsubscribe when leaving screen** (prevent memory leak)
3. **Use `where()` to filter events** (reduce processing)
4. **Implement exponential backoff** for reconnects
5. **Cache portfolio list in SQLite** (reduce API calls)
6. **Batch updates if many portfolios approved simultaneously**
7. **Use Redis Adapter for Reverb** (don't use in-process queue in production)

---

## 🔗 Useful Links

- [Laravel Reverb Docs](https://laravel.com/docs/11.x/reverb)
- [Laravel Broadcasting](https://laravel.com/docs/11.x/broadcasting)
- [Sanctum Documentation](https://laravel.com/docs/11.x/sanctum)
- [web_socket_channel package](https://pub.dev/packages/web_socket_channel)
- [Flutter State Management Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt)

---

**Last Updated:** March 2026  
**Maintainer:** PortFolioPH Dev Team 🇵🇭
