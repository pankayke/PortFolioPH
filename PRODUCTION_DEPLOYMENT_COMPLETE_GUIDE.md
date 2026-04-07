# PortfolioPH - PRODUCTION DEPLOYMENT CHECKLIST
## Complete Launch & Handover Guide

---

## 📋 PRE-DEPLOYMENT VALIDATION (LOCAL)

### 1. Code Quality & Security Audit
- [ ] **Remove all debug logging**
  ```bash
  flutter analyze
  dart analyze lib/
  ```
  - Verify: No debugPrint() calls in production code
  - All production-safe logging via AppLogger (automatically disabled in Flavor.production)

- [ ] **Check for hardcoded secrets**
  ```bash
  grep -r "localhost" lib/ --include="*.dart" | grep -v "main_development"
  grep -r "password" lib/ --include="*.dart" | grep -viE "(password_field|password.*validator)"
  grep -r "api_key" lib/ --include="*.dart"
  ```

- [ ] **Verify environment configuration**
  ```bash
  flutter run -t lib/main_production.dart --release  # Should use production API
  ```

- [ ] **Run all tests**
  ```bash
  flutter test
  ```

### 2. Flutter Build Validation
- [ ] **Test production build locally**
  ```bash
  # APK (Android)
  flutter build apk --flavor production -t lib/main_production.dart --release
  
  # IPA (iOS - requires macOS)
  flutter build ios --flavor production -t lib/main_production.dart --release
  
  # Web (if applicable)
  flutter build web --flavor production -t lib/main_production.dart --release
  ```

- [ ] **Verify APK size**
  - Target: < 50MB (before play store compression)
  - If over: Run `flutter clean && flutter pub get`

- [ ] **Test on multiple devices**
  - Min SDK version: 21 (Android), 12.0 (iOS)
  - Test network switching (WiFi ↔ Mobile Data)
  - Test app backgrounding and resuming

### 3. Laravel Backend Validation
- [ ] **Environment file configured**
  ```bash
  # .env should have:
  APP_ENV=production
  APP_DEBUG=false
  APP_URL=https://portfolioph.dev
  DATABASE_URL configured for prod database
  ```

- [ ] **Run migrations**
  ```bash
  php artisan migrate --force
  ```

- [ ] **Clear and cache config**
  ```bash
  php artisan config:cache
  php artisan route:cache
  php artisan view:cache
  ```

- [ ] **Test API endpoints**
  ```bash
  # Test profile endpoint
  curl -H "Authorization: Bearer TOKEN" https://api.portfolioph.dev/api/profile
  
  # Test file upload
  curl -X POST -F "avatar=@avatar.jpg" -H "Authorization: Bearer TOKEN" \
    https://api.portfolioph.dev/api/profile
  ```

- [ ] **Verify storage links**
  ```bash
  php artisan storage:link --force
  # Verify: /storage/app/public → /public/storage
  ```

---

## 🔧 FLUTTER PRODUCTION BUILD COMMANDS

### Android Production Build

#### APK (Direct Install)
```bash
# Build APK with production flavor
flutter build apk \
  --flavor production \
  -t lib/main_production.dart \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

# Output: build/app/outputs/flutter-app.apk
```

#### App Bundle (Google Play Store - RECOMMENDED)
```bash
# Build AAB for play store with obfuscation
flutter build appbundle \
  --flavor production \
  -t lib/main_production.dart \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

# Output: build/app/outputs/bundle/productionRelease/app-production-release.aab
```

**What the flags do:**
- `--obfuscate`: Minify and obfuscate Dart code (protects source code from reverse engineering)
- `--split-debug-info`: Separates debug symbols into build/symbols for crash reporting setup
- `--flavor production`: Uses Flavor.production config (AppConfig.isProduction = true)
- `--release`: Optimized build, enables optimizations

#### Sign APK/AAB
```bash
# Android: Use Google Play Signing (recommended) or sign locally:
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore ~/.android/release-key.jks \
  build/app/outputs/flutter-app.apk production-key-alias

zipalign -v 4 build/app/outputs/flutter-app.apk build/app/outputs/flutter-app-aligned.apk
```

### iOS Production Build (macOS Required)

#### IPA (Direct Install / TestFlight)
```bash
# Build IPA for production
flutter build ios \
  --flavor production \
  -t lib/main_production.dart \
  --release \
  --obfuscate \
  --split-debug-info=build/app/symbols

# Output: build/ios/iphoneos/Runner.app
# Then archive and export via Xcode or:
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme production \
  -configuration Release \
  -archivePath build/ios/archive.xcarchive \
  archive

xcodebuild -exportArchive \
  -archivePath build/ios/archive.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/ios/ipa
```

### Web Production Build

```bash
# Build web for production
flutter build web \
  --flavor production \
  -t lib/main_production.dart \
  --release

# Output: build/web/

# Optimize for web:
gzip -9 build/web/main.dart.js
gzip -9 build/web/index.html
```

---

## 🛡️ FLUTTER SECURITY & OBFUSCATION SETUP

### 1. Enable Code Obfuscation

```yaml
# pubspec.yaml - already has dependencies:
flutter_secure_storage: ^9.2.2  # Secure token storage
crypto: ^3.0.5                   # Password hashing
```

### 2. Configure Proguard (Android)
Create `android/app/proguard-rules.pro`:
```proguard
# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dio
-keep class retrofit.** { *; }
-keep interface retrofit.** { *; }
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# JSON serialization (dart generated files)
-keep class **.*.g { *; }

# Keep custom exceptions
-keep class com.portfolioph.core.exceptions.** { *; }
```

### 3. Token & Secret Management

```dart
// Never store secrets in code. Use:

// 1. flutter_secure_storage for tokens
final token = await _secureStorage.read(key: 'auth_token');

// 2. Environment variables via AppConfig (build time)
static const String apiBaseUrl = 'https://api.portfolioph.dev/api';

// 3. Runtime environment (never print in production)
if (AppConfig.enableDebugLogs) {
  print(token);  // Only in development
}
```

### 4. Crash Reporting (Recommended)

```dart
// Install: sentry_flutter: ^7.0.0
// Initialize in main_production.dart:

import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://your-sentry-dsn@sentry.io/project-id';
      options.environment = 'production';
      options.tracesSampleRate = 0.1;  // 10% of transactions
    },
    appRunner: () => runApp(const App()),
  );
}
```

---

## 🚀 LARAVEL PRODUCTION DEPLOYMENT

### 1. Server Prerequisites
- Ubuntu 20.04 LTS or later
- PHP 8.1+
- MySQL 8.0+
- Nginx
- Let's Encrypt SSL certificate
- Redis (for caching/queues)

### 2. Environment Configuration

```bash
# SSH into server
ssh user@api.portfolioph.dev

# Clone repository
git clone https://github.com/pankayke/PortFolioPH.git portfolioph
cd portfolioph/portfoliophhadmin

# Copy environment file
cp .env.example .env

# Configure .env for production:
```

**.env Configuration:**
```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:GENERATE_WITH_php_artisan_key_generate
APP_URL=https://api.portfolioph.dev

DATABASE_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=portfolioph_prod
DB_USERNAME=portfolioph_user
DB_PASSWORD=STRONG_PASSWORD_HERE

SANCTUM_STATEFUL_DOMAINS=portfolioph.dev,api.portfolioph.dev
SESSION_DOMAIN=.portfolioph.dev

REQUIRE_EMAIL_VERIFICATION=true
QUEUE_CONNECTION=redis
CACHE_DRIVER=redis
SESSION_DRIVER=redis

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

LOG_CHANNEL=stack
LOG_LEVEL=warning

# File Storage
FILESYSTEM_DISK=public
AWS_URL=https://CDN_URL_IF_USING_S3

# Session timeout (in minutes)
SESSION_LIFETIME=1440
```

### 3. Application Setup

```bash
# Generate app key
php artisan key:generate

# Install dependencies
composer install --optimize-autoloader --no-dev

# Create storage link (CRITICAL for file downloads)
php artisan storage:link --force

# Run migrations
php artisan migrate --force

# Seed database (if applicable)
php artisan db:seed --class=ProductionSeeder
```

### 4. Optimization

```bash
# Cache everything
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Optimize autoloader
composer dump-autoload --optimize --no-scripts --no-dev

# Optional: Horizon (if using queues)
php artisan horizon:install
```

### 5. File Permissions

```bash
# Set proper permissions
sudo chown -R www-data:www-data /var/www/portfolioph
sudo find /var/www/portfolioph -type d -exec chmod 755 {} \;
sudo find /var/www/portfolioph -type f -exec chmod 644 {} \;

# Storage & bootstrap writable
sudo chmod -R 775 storage bootstrap/cache
```

### 6. Nginx Configuration

Create `/etc/nginx/sites-available/api.portfolioph.dev`:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name api.portfolioph.dev;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.portfolioph.dev;
    
    # SSL Certificates (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/api.portfolioph.dev/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.portfolioph.dev/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    root /var/www/portfolioph/portfoliophhadmin/public;
    index index.php index.html;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'";
    
    # Gzip compression
    gzip on;
    gzip_types text/plain text/css text/xml application/json application/javascript;
    gzip_min_length 1024;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Restrict upload size
    client_max_body_size 10M;
    
    # Cache static files
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # Deny .env and other sensitive files
    location ~ /\. {
        deny all;
    }
    
    location ~ /storage {
        alias /var/www/portfolioph/portfoliophhadmin/storage/app/public;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/api.portfolioph.dev /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 7. SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Generate certificate
sudo certbot certonly --nginx -d api.portfolioph.dev

# Auto-renew (runs twice daily)
sudo certbot renew --dry-run
sudo systemctl enable certbot.timer
```

### 8. Deployment Script

Create `/var/www/portfolioph/deploy.sh`:

```bash
#!/bin/bash
cd /var/www/portfolioph/portfoliophhadmin

# Pull latest code
git pull origin main

# Install/update dependencies
composer install --optimize-autoloader --no-dev

# Clear caches
php artisan cache:clear
php artisan config:clear

# Run migrations
php artisan migrate --force

# Rebuild caches
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Restart queue workers
sudo systemctl restart portfolioph-horizon

echo "✅ Deployment complete!"
```

Make executable:
```bash
chmod +x /var/www/portfolioph/deploy.sh
```

### 9. Security Hardening

```bash
# Fail2Ban (prevent brute force)
sudo apt install fail2ban -y

# Create rule for Laravel:
sudo nano /etc/fail2ban/filter.d/laravel.conf
```

```ini
[Definition]
failregex = ^<HOST> -.*"POST /api/login.*" 401
            ^<HOST> -.*"POST /api/register.*" 422
ignoreregex =
```

```bash
# Test database connection
php artisan migrate --dry-run

# Check file permissions
find storage -type f -exec chmod 644 {} \;
find storage -type d -exec chmod 755 {} \;

# Enable rate limiting in routes/api.php
Route::middleware('throttle:60,1')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
});
```

---

## 📱 DATABASE BACKUP & RECOVERY

### Automated Daily Backups

```bash
# Create backup script
cat > /usr/local/bin/backup-portfolioph.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/backups/portfolioph"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
DB_NAME="portfolioph_prod"

mkdir -p $BACKUP_DIR

# Backup database
mysqldump -u${DB_USERNAME} -p${DB_PASSWORD} ${DB_NAME} | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Keep only last 30 days
find $BACKUP_DIR -name "db_*.sql.gz" -mtime +30 -delete

echo "Database backed up: $BACKUP_DIR/db_$DATE.sql.gz"
EOF

chmod +x /usr/local/bin/backup-portfolioph.sh

# Schedule daily at 2 AM
sudo crontab -e
# Add: 0 2 * * * /usr/local/bin/backup-portfolioph.sh
```

### Restore from Backup
```bash
gunzip < /backups/portfolioph/db_YYYY-MM-DD_HH-MM-SS.sql.gz | mysql -u${DB_USERNAME} -p${DB_PASSWORD} ${DB_NAME}
```

---

## ✅ POST-DEPLOYMENT VERIFICATION

### 1.  API Endpoints
```bash
# Health check
curl https://api.portfolioph.dev/api/health

# Test login
curl -X POST https://api.portfolioph.dev/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password"
  }'

# Test profile fetch (with auth token from above)
curl -H "Authorization: Bearer TOKEN" \
  https://api.portfolioph.dev/api/profile
```

### 2. File Upload Verification
```bash
# Upload avatar
curl -X POST -F "avatar=@avatar.jpg" \
  -H "Authorization: Bearer TOKEN" \
  https://api.portfolioph.dev/api/profile

# Verify file accessible
curl https://api.portfolioph.dev/storage/avatars/filename.jpg
```

### 3. SSL/TLS Verification
```bash
# Check certificate
openssl s_client -connect api.portfolioph.dev:443

# Verify expiry
ssl-cert-check -c /etc/letsencrypt/live/api.portfolioph.dev/cert.pem
```

### 4. Performance Testing
```bash
# Load test with Apache Bench
ab -n 1000 -c 100 https://api.portfolioph.dev/api/health

# Check response time
curl -w "@curl-format.txt" -o /dev/null -s https://api.portfolioph.dev/api/profile
```

---

## 🔐 SECURITY CHECKLIST - FINAL VERIFICATION

- [ ] **HTTPS only** - All traffic redirected from HTTP
- [ ] **HSTS enabled** - `add_header Strict-Transport-Security "max-age=31536000; includeSubDomains"`
- [ ] **No .env in public** - `.env` file outside web root
- [ ] **Database backups automated** - Cron job running daily
- [ ] **Debug mode OFF** - `APP_DEBUG=false`
- [ ] **CORS configured** - Only allowed domains in `SANCTUM_STATEFUL_DOMAINS`
- [ ] **Rate limiting** - Login/register endpoints throttled
- [ ] **File uploads secured** - Resumes stored outside public root OR served via protected route
- [ ] **Passwords hashed** - Using bcrypt (Laravel default)
- [ ] **Tokens encrypted** - Santum tokens in secure storage
- [ ] **Log files monitored** - Check `/var/log/nginx/error.log`
- [ ] **Firewall configured** - UFW with only 22, 80, 443 open
- [ ] **SSH hardened** - Key-based auth, fail2ban active
- [ ] **Database replicated** - Read replicas for scaling
- [ ] **CDN in place** - Static assets served from CloudFlare/AWS CloudFront

---

## 📞 TROUBLESHOOTING

### Flutter App Won't Connect to API
```dart
// Check if using correct AppConfig flavor:
// flutter run -t lib/main_production.dart --release

// Verify URL:
print(AppConfig.apiBaseUrl);  // Should be production domain

// Check network connectivity:
// Settings → Network & Internet → Airplane mode toggle
```

### Laravel Returns 401 Unauthorized
```bash
# Check token validity
php artisan tinker
>>> DB::table('personal_access_tokens')->latest()->first()

# Clear expired tokens
>>> DB::table('personal_access_tokens')->where('expires_at', '<', now())->delete()
```

### File Upload Fails
```bash
# Check storage permissions
ls -la /var/www/portfolioph/portfoliophhadmin/storage/app/

# Check Nginx upload limit (app/portfolio_hadmin/nginx.conf)
# Should have: client_max_body_size 10M;

#Verify storage link
php artisan storage:link --force
```

### High CPU/Memory Usage
```bash
# Check running processes
ps aux | grep php

# Restart PHP-FPM
sudo systemctl restart php8.1-fpm

# Check disk space
df -h

# Clear old logs
find /var/www/portfolioph/portfoliophhadmin/storage/logs -mtime +30 -delete
```

---

## 📊 MONITORING & ALERTING (Recommended)

```bash
# New Relic / Datadog integration
# Add to .env:
NEW_RELIC_LICENSE_KEY=your_key
DATADOG_API_KEY=your_key

# Or use free option: Uptime Kuma
# https://uptime.kuma.pet/

# Set uptime checks for:
# - https://api.portfolioph.dev/api/health
# - https://portfolioph.dev (web frontend)
```

---

## 🎯 LAUNCH TIMELINE

| Phase | Tasks | Timeline | Owner |
|-------|-------|----------|-------|
| Pre-Launch | Code audit, build testing, security review | Week -1 | Dev Lead |
| Deployment | Deploy Laravel, setup SSL/Nginx, deploy Flutter | Day 0 | DevOps |
| Verification | Test API endpoints, file uploads, SSL | Day 0 | QA |
| Monitor | Watch error logs, performance, uptime | Week +1 | Ops |
| Scale | Monitor metrics, optimize if needed | Week +2 | DevOps |

---

**✅ You are now production-ready!**

For continuous deployment, set up:
1. GitHub Actions → Deploy on push to main
2. Automated tests → Run before deployment
3. Monitoring → Sentry + New Relic + Uptime Kuma
4. Incident response → PagerDuty/Opsgenie

