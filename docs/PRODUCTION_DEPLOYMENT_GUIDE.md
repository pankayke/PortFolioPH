# Production Deployment Guide - Laravel Reverb + Flutter Real-Time System

**Status:** Production-Ready  
**Date:** March 2026  
**Region:** Philippines 🇵🇭

---

## Table of Contents
1. Pre-Deployment Checklist
2. Infrastructure Setup
3. Laravel Backend Deployment
4. Reverb Server Configuration
5. Flutter App Configuration
6. DNS & SSL Configuration
7. Monitoring & Alerting
8. Rollback Procedures

---

## 1. PRE-DEPLOYMENT CHECKLIST

### Security
- [ ] Generate secure REVERB_APP_KEY (32+ chars, random)
- [ ] Generate secure REVERB_APP_SECRET (32+ chars, random)
- [ ] Enable HTTPS/WSS only (no HTTP/WS in production)
- [ ] Configure CORS to allow only your Flutter app domains
- [ ] Setup Sanctum token expiry (recommend 24 hours)
- [ ] Enable admin role verification on all approval endpoints
- [ ] Configure rate limiting (60 requests/min per admin)
- [ ] Setup firewall rules (allow 443, 8080 only from trusted IPs)
- [ ] Enable WAF (Web Application Firewall) if available
- [ ] Verify input validation on all endpoints

### Performance
- [ ] Database: Create indices on `portfolios(status)`, `job_postings(status)`
- [ ] Redis: Setup Redis cluster for Reverb broadcaster
- [ ] Cache: Configure Redis for session/cache
- [ ] Database: Setup read replicas for analytics queries
- [ ] CDN: Configure for static assets (images, CSS, JS)
- [ ] Compression: Enable gzip on API responses

### Monitoring
- [ ] Setup error tracking (Sentry, Rollbar, or Bugsnag)
- [ ] Configure logging: structured JSON logs → centralized system (ELK, Datadog)
- [ ] Setup APM (Application Performance Monitoring)
- [ ] Create dashboards for: WebSocket connections, approval latency, db query time
- [ ] Setup alerts: connection drops, high latency, approval failures

### Testing
- [ ] Load test: 1000+ concurrent WebSocket connections
- [ ] Stress test: 100 approvals/sec
- [ ] Failover test: Reverb server crash → recovery
- [ ] Network test: Simulate packet loss, latency
- [ ] Security test: SQL injection, XSS, unauthorized channel access

---

## 2. INFRASTRUCTURE SETUP

### Option A: AWS (Recommended for Philippines 🇵🇭)

#### 2.1 Create VPC & Subnets
```bash
# Using AWS CLI
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region ap-southeast-1

# Create public subnet
aws ec2 create-subnet --vpc-id vpc-xxxxx --cidr-block 10.0.1.0/24 \
  --availability-zone ap-southeast-1a

# Create private subnet (for database)
aws ec2 create-subnet --vpc-id vpc-xxxxx --cidr-block 10.0.2.0/24 \
  --availability-zone ap-southeast-1b
```

#### 2.2 RDS PostgreSQL Setup
```bash
# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier portfolioph-db \
  --db-instance-class db.t4g.medium \
  --engine postgres \
  --master-username postgres \
  --master-user-password '<strong-password>' \
  --allocated-storage 100 \
  --region ap-southeast-1 \
  --publicly-accessible false \
  --backup-retention-period 30 \
  --multi-az
```

#### 2.3 ElastiCache Redis
```bash
aws elasticache create-cache-cluster \
  --cache-cluster-id portfolioph-redis \
  --cache-node-type cache.t4g.medium \
  --engine redis \
  --num-cache-nodes 1 \
  --region ap-southeast-1
```

#### 2.4 EC2 for Laravel/Reverb
```bash
# Launch EC2 instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t4g.large \
  --key-name my-keypair \
  --subnet-id subnet-xxxxx \
  --security-group-ids sg-xxxxx \
  --region ap-southeast-1 \
  --num-instances 2  # For HA

# Create Launch Template for auto-scaling
aws ec2 create-launch-template \
  --launch-template-name portfolioph-api-template \
  --version-description "Latest" \
  --launch-template-data '{
    "ImageId":"ami-0c55b159cbfafe1f0",
    "InstanceType":"t4g.large",
    "KeyName":"my-keypair"
  }'

# Create Auto-Scaling Group
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name portfolioph-api-asg \
  --launch-template LaunchTemplateName=portfolioph-api-template \
  --min-size 2 \
  --max-size 10 \
  --region ap-southeast-1
```

#### 2.5 Load Balancer
```bash
# Create Application Load Balancer
aws elbv2 create-load-balancer \
  --name portfolioph-alb \
  --subnets subnet-xxxxx subnet-yyyyy \
  --security-groups sg-xxxxx \
  --region ap-southeast-1

# Create target group for API (port 8000)
aws elbv2 create-target-group \
  --name api-tg \
  --protocol HTTP \
  --port 8000 \
  --vpc-id vpc-xxxxx

# Create target group for Reverb (port 8080)
aws elbv2 create-target-group \
  --name reverb-tg \
  --protocol HTTP \
  --port 8080 \
  --vpc-id vpc-xxxxx
```

### Option B: Docker Compose + Linux VPS (Budget-Friendly)

#### 2.1 Acquire Linux VPS
- Provider: DigitalOcean, Linode, or AWS Lightsail
- OS: Ubuntu 22.04 LTS
- Specs: 4GB RAM, 2vCPU minimum
- SSH access enabled

#### 2.2 Initial Setup
```bash
# SSH into VPS
ssh -i key.pem ubuntu@<vps-ip>

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker --version && docker-compose --version

# Install SSL certificates (Let's Encrypt)
sudo apt install certbot python3-certbot-nginx -y
```

#### 2.3 Clone Repository
```bash
# Create deployment directory
mkdir -p /opt/portfolioph
cd /opt/portfolioph

# Clone backend
git clone https://github.com/pankayke/PortFolioPH-Admin.git .
git checkout main

# Create .env from template
cp .env.example .env
nano .env  # Edit with production values
```

#### 2.4 Create docker-compose.prod.yml
See **docker-compose-prod.yml** section below.

---

## 3. LARAVEL BACKEND DEPLOYMENT

### 3.1 Build & Optimize

```bash
# On your local machine or CI/CD pipeline

# 1. Install dependencies
composer install --no-dev --optimize-autoloader

# 2. Generate app key
php artisan key:generate

# 3. Cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 4. Optimize autoloader
composer dump-autoload --optimize

# 5. Compile JS/CSS (if applicable)
npm run build

# 6. Build Docker image
docker build -t portfolioph-api:latest .

# 7. Push to container registry
docker tag portfolioph-api:latest your-registry/portfolioph-api:latest
docker push your-registry/portfolioph-api:latest
```

### 3.2 Docker Build File

**File:** `Dockerfile` (production optimized)

```dockerfile
# Stage 1: Build
FROM php:8.2-fpm as builder

RUN apt-get update && apt-get install -y \
    git curl libpq-dev zip unzip \
    && docker-php-ext-install pdo pdo_pgsql

WORKDIR /app

# Copy composer files
COPY composer.json composer.lock ./

# Install dependencies
RUN curl -sS https://getcomposer.org/installer | php && \
    php composer.phar install --no-dev --optimize-autoloader && \
    rm composer.phar

# Stage 2: Runtime
FROM php:8.2-fpm

# Install production dependencies
RUN apt-get update && apt-get install -y \
    libpq5 redis-tools supervisor \
    && docker-php-ext-install pdo pdo_pgsql pcntl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy from builder
COPY --from=builder /app/vendor ./vendor

# Copy application
COPY . .

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Create non-root user
RUN useradd -m -u 1000 app && chown -R app:app /app
USER app

# Expose port
EXPOSE 8000 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
```

### 3.3 Initial Deployment Steps

```bash
# On VPS

# 1. Pull latest image
docker pull your-registry/portfolioph-api:latest

# 2. Run migrations (one-time)
docker run -it \
  --rm \
  --env-file /opt/portfolioph/.env \
  your-registry/portfolioph-api:latest \
  php artisan migrate --force

# 3. Seed admin users (if needed)
docker run -it \
  --rm \
  --env-file /opt/portfolioph/.env \
  your-registry/portfolioph-api:latest \
  php artisan db:seed --class=AdminUserSeeder

# 4. Start services
cd /opt/portfolioph
docker-compose -f docker-compose.prod.yml up -d

# 5. Verify services
docker-compose logs -f
```

---

## 4. REVERB SERVER CONFIGURATION

### 4.1 Production docker-compose.prod.yml

**File:** `docker-compose.prod.yml`

```yaml
version: '3.8'

services:
  # Laravel API
  api:
    image: your-registry/portfolioph-api:latest
    container_name: portfolioph-api
    restart: always
    environment:
      APP_ENV: production
      APP_DEBUG: false
      DB_HOST: postgres
      DB_PORT: 5432
      DB_DATABASE: portfolioph
      DB_USERNAME: postgres
      DB_PASSWORD: ${DB_PASSWORD}
      BROADCAST_DRIVER: reverb
      REVERB_HOST: 0.0.0.0
      REVERB_PORT: 8080
      REVERB_PUBLIC_HOST: reverb.api.portfolioph.ph
      REVERB_PUBLIC_PORT: 443
      REVERB_PUBLIC_SCHEME: wss
      REVERB_APP_ID: ${REVERB_APP_ID}
      REVERB_APP_KEY: ${REVERB_APP_KEY}
      REVERB_APP_SECRET: ${REVERB_APP_SECRET}
      REDIS_HOST: redis
      REDIS_PORT: 6379
      QUEUE_CONNECTION: redis
      CACHE_DRIVER: redis
    ports:
      - "8000:8000"  # Internal, behind Nginx
      - "8080:8080"  # Reverb WebSocket
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./storage:/app/storage
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    networks:
      - portfolioph

  # Redis
  redis:
    image: redis:7-alpine
    container_name: portfolioph-redis
    restart: always
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - portfolioph

  # PostgreSQL
  postgres:
    image: postgres:15-alpine
    container_name: portfolioph-db
    restart: always
    environment:
      POSTGRES_DB: portfolioph
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    ports:
      - "5432:5432"  # Only for backups, keep internal
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./storage/backups:/backups
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - portfolioph

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: portfolioph-nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.prod.conf:/etc/nginx/nginx.conf:ro
      - ./ssl/certs:/etc/nginx/ssl:ro
      - ./public:/var/www/html:ro
    depends_on:
      - api
    networks:
      - portfolioph

  # Queue Worker (for broadcasting)
  queue:
    image: your-registry/portfolioph-api:latest
    container_name: portfolioph-queue
    restart: always
    environment:
      APP_ENV: production
      QUEUE_CONNECTION: redis
      # ... same as api service
    entrypoint: php artisan queue:listen --connections=redis --tries=3
    depends_on:
      - api
    networks:
      - portfolioph

  # Supervisor (for long-running processes)
  supervisor:
    image: your-registry/portfolioph-api:latest
    container_name: portfolioph-supervisor
    restart: always
    environment:
      # ... same as api service
    volumes:
      - ./supervisord.conf:/etc/supervisor/conf.d/supervisord.conf:ro
    entrypoint: /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
    networks:
      - portfolioph

volumes:
  postgres_data:
  redis_data:

networks:
  portfolioph:
    driver: bridge
```

### 4.2 Nginx Configuration

**File:** `nginx.prod.conf`

```nginx
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 4096;
    use epoll;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format combined_json
        '{'
            '"time_local":"$time_local",'
            '"remote_addr":"$remote_addr",'
            '"request":"$request",'
            '"status":$status,'
            '"upstream_time":$upstream_response_time,'
            '"request_time":$request_time'
        '}';

    access_log /var/log/nginx/access.log combined_json;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript \
               application/json application/javascript application/xml+rss;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=reverb_limit:10m rate=100r/s;

    # Upstream backends
    upstream api {
        least_conn;
        server api:8000 max_fails=3 fail_timeout=30s;
    }

    upstream reverb {
        least_conn;
        server api:8080 max_fails=3 fail_timeout=30s;
    }

    # Redirect HTTP to HTTPS
    server {
        listen 80 default_server;
        server_name _;
        return 301 https://$host$request_uri;
    }

    # HTTPS API Server
    server {
        listen 443 ssl http2;
        server_name api.portfolioph.ph *.api.portfolioph.ph;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Add HSTS header
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        client_max_body_size 50M;

        # API Endpoints
        location ~ ^/api/ {
            limit_req zone=api_limit burst=20 nodelay;

            proxy_pass http://api;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;

            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # Health check
        location /health {
            proxy_pass http://api;
            access_log off;
        }

        # Reverb WebSocket
        location ~ ^/app/(.*) {
            limit_req zone=reverb_limit burst=100 nodelay;

            proxy_pass http://reverb;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            # WebSocket timeouts
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
            proxy_connect_timeout 60s;

            # Disable buffering for WebSocket
            proxy_buffering off;
        }

        # Static assets
        location ~ ^/(images|assets|css|js)/ {
            proxy_pass http://api;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Default
        location / {
            proxy_pass http://api;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        error_page 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }

    # HTTPS Reverb Server (separate domain)
    server {
        listen 443 ssl http2;
        server_name reverb.api.portfolioph.ph;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            limit_req zone=reverb_limit burst=100 nodelay;
            proxy_pass http://reverb;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
            proxy_buffering off;
        }
    }
}
```

### 4.3 Reverb Configuration (.env)

```env
REVERB_APP_ID=portfolioph-prod
REVERB_APP_KEY=$(openssl rand -hex 16)
REVERB_APP_SECRET=$(openssl rand -hex 16)

# Running configuration
REVERB_HOST=0.0.0.0
REVERB_PORT=8080
REVERB_SCHEME=ws

# Public client connection
REVERB_PUBLIC_HOST=reverb.api.portfolioph.ph
REVERB_PUBLIC_PORT=443
REVERB_PUBLIC_SCHEME=wss

# Debug (disable in production)
REVERB_DEBUG=false

# Connection settings
REVERB_MAX_CONNECTIONS_PER_SECOND=100
REVERB_KEEPALIVE_INTERVAL=30
```

---

## 5. FLUTTER APP CONFIGURATION

### 5.1 Production Build

```bash
# Build APK for Android
flutter build apk --release

# Build App Bundle for Google Play
flutter build appbundle --release

# Build iOS app
flutter build ipa --release

# For web (if applicable)
flutter build web --release
```

### 5.2 Update API Endpoints

**File:** `lib/core/constants/app_constants.dart`

```dart
class AppConstants {
  // Production endpoints
  static const String baseUrl = 'https://api.portfolioph.ph';
  static const String reverbHost = 'reverb.api.portfolioph.ph';
  static const int reverbPort = 443;
  static const String reverbScheme = 'wss';

  // Feature flags
  static const bool enableDebugLogs = false;
  static const bool enablePerformanceMonitoring = true;
}
```

### 5.3 Production Signing (Android)

```bash
# Generate signing key
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias portfolioph

# Reference in build.gradle
android {
  signingConfigs {
    release {
      storeFile file("/Users/user/key.jks")
      storePassword System.getenv("KEYSTORE_PASSWORD")
      keyAlias System.getenv("KEY_ALIAS")
      keyPassword System.getenv("KEY_PASSWORD")
    }
  }
}
```

### 5.4 Firebase Crashlytics Setup (Optional)

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  runApp(const App());
}
```

---

## 6. DNS & SSL CONFIGURATION

### 6.1 DNS Records

```dns
# A records
api.portfolioph.ph       A  203.0.113.1  (ALB/Nginx IP)
reverb.api.portfolioph.ph A  203.0.113.1

# Optional: CNAME for CDN
cdn.portfolioph.ph       CNAME  d111111abcdef8.cloudfront.net
```

### 6.2 SSL Certificate Management

#### Using Let's Encrypt (Free)

```bash
# On VPS with Certbot
sudo certbot certonly --standalone -d api.portfolioph.ph -d reverb.api.portfolioph.ph

# Auto-renewal (runs daily)
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Check renewal
sudo certbot renew --dry-run
```

#### Using AWS Certificate Manager (if on AWS)

```bash
aws acm request-certificate \
  --domain-name api.portfolioph.ph \
  --subject-alternative-names reverb.api.portfolioph.ph \
  --validation-method DNS \
  --region ap-southeast-1
```

---

## 7. MONITORING & ALERTING

### 7.1 Structured Logging Setup (ELK Stack)

#### Filebeat Config (on Docker host)

**File:** `filebeat.yml`

```yaml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/lib/docker/containers/*/*/stdout

filebeat.autodiscover:
  providers:
    - type: docker
      hints.enabled: true

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  username: "elastic"
  password: "${ELASTIC_PASSWORD}"
```

### 7.2 Prometheus Metrics

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'laravel-api'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres_exporter:9187']
```

### 7.3 Grafana Dashboard

Key metrics to monitor:

1. **WebSocket Metrics**
   - Active connections (gauge)
   - Connection rate (per_second)
   - Disconnection rate (per_second)
   - Message throughput (messages/sec)

2. **API Performance**
   - Response time (p50, p95, p99)
   - Request rate
   - Error rate (4xx, 5xx)
   - Database query time

3. **Reverb Server**
   - CPU usage
   - Memory usage
   - Message backlog
   - Event latency

4. **Business Metrics**
   - Portfolio approvals/sec
   - Admin actions
   - Rejection rate
   - User engagement

### 7.4 Alert Rules

```yaml
# alerts.yml
groups:
  - name: portfolioph
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 1m
        annotations:
          summary: "High error rate detected"

      - alert: WebSocketConnectionDrop
        expr: rate(reverb_connections_total[5m]) < 10
        for: 2m
        annotations:
          summary: "WebSocket connections dropping"

      - alert: DatabaseDown
        expr: pg_up == 0
        for: 1m
        annotations:
          summary: "PostgreSQL database unreachable"

      - alert: RedisDown
        expr: redis_up == 0
        for: 1m
        annotations:
          summary: "Redis cache unavailable"

      - alert: HighLatency
        expr: http_request_duration_seconds_p99 > 5
        for: 5m
        annotations:
          summary: "API latency exceeding 5 seconds"
```

### 7.5 Slack Integration

```bash
# In your alert handler
curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK/URL \
  -H 'Content-Type: application/json' \
  -d '{
    "text": "🚨 Alert: PortFolioPH API - High Error Rate (5% threshold)",
    "blocks": [{
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*PortFolioPH Production Alert*\nError Rate: 5.2%\n<https://grafana.portfolioph.ph/d/dashboard |View Dashboard>"
      }
    }]
  }'
```

---

## 8. ROLLBACK PROCEDURES

### 8.1 Laravel Code Rollback

```bash
# Keep last 5 versions in production

# Current version
docker tag your-registry/portfolioph-api:v1.2.3 current

# Previous version
docker tag your-registry/portfolioph-api:v1.2.2 previous

# Rollback command
cd /opt/portfolioph
docker-compose -f docker-compose.prod.yml pull your-registry/portfolioph-api:v1.2.2
docker-compose -f docker-compose.prod.yml up -d api

# Run migrations in reverse (if needed)
docker-compose exec api php artisan migrate:rollback

# Verify health
curl https://api.portfolioph.ph/health
```

### 8.2 Database Rollback

```bash
# Take backup before migration
pg_dump portfolioph > backup_$(date +%s).sql

# Rollback migration
docker-compose exec api php artisan migrate:rollback --step=1

# If critical, restore from backup
psql portfolioph < backup_1234567890.sql
```

### 8.3 Reverb Rollback

```bash
# Reverb server hangs or crashes?

# Step 1: Check logs
docker-compose logs -f api | grep -i reverb

# Step 2: Restart Reverb
docker-compose restart api

# Step 3: Check WebSocket connectivity
docker-compose exec api php artisan tinker
>>> echo \Laravel\Reverb\Facades\Reverb::getConnectionCount();

# Step 4: If still broken, restart all services
docker-compose down
docker-compose up -d
```

### 8.4 Emergency Procedures

#### If API is completely down:

```bash
# 1. Verify infrastructure
ping <vps-ip>
docker ps -a

# 2. Check disk space
df -h /

# 3. Check memory
free -h

# 4. Rebuild services
docker-compose -f docker-compose.prod.yml up --force-recreate -d

# 5. Verify databases
docker-compose exec postgres pg_isready
docker-compose exec redis redis-cli ping

# 6. If databases corrupted, restore from backup
# Contact DevOps team
```

#### If Reverb WebSocket fails:

```bash
# Flutter app can still use API fallback
# Enable polling in PortfolioProvider

# Or update Flutter to use http endpoint temporarily:
class PortfolioProvider {
  Future<void> _startPollingFallback() {
    // Every 30 seconds, call GET /api/portfolio/{id}
  }
}

# Users will see a UI banner:
# "⚠️ Real-time sync temporarily unavailable. Refreshing status manually..."
```

---

## DEPLOYMENT CHECKLIST

Final before going live:

- [ ] SSL certificates installed and validated
- [ ] DNS records pointing to load balancer
- [ ] All environment variables set correctly
- [ ] Database backups configured (daily, retention: 30 days)
- [ ] Monitoring dashboards created and alerted to Slack/PagerDuty
- [ ] Rate limiting tested (60 requests/min per admin)
- [ ] WebSocket load tested (1000+ concurrent connections)
- [ ] Failover tested (one server down → traffic redirects)
- [ ] Security scanned (SQL injection, XSS, etc.)
- [ ] Performance benchmarked:
  - API response time < 200ms (p95)
  - WebSocket message latency < 100ms
  - Throughput: 100+ approvals/sec
- [ ] Documentation updated for ops team
- [ ] Runbooks created for on-call engineers
- [ ] Firebase Crashlytics configured (optional)
- [ ] Datadog/New Relic APM enabled (optional)
- [ ] Rollback procedures tested

---

**Deployment Date:** _______________  
**Deployed By:** _______________  
**Approved By:** _______________

---

**Support & Contact:**
- DevOps: devops@portfolioph.ph
- On-Call Eng: +63 906 123 4567
- Status Page: status.portfolioph.ph

**Last Updated:** March 2026  
**Version:** 1.0 Production
