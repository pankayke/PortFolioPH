# 🎯 Job Platform System - Master Implementation Guide
**Status:** Production-Ready Architecture  
**Date:** March 28, 2026  
**Tech Stack:** Flutter + Laravel 11 + Filament Admin

---

## 📋 Table of Contents
1. [System Architecture](#architecture)
2. [Database Design](#database)
3. [API Specification](#api)
4. [Implementation Phases](#phases)
5. [Setup Instructions](#setup)
6. [Testing & Validation](#testing)

---

## <a name="architecture"></a>🏗️ System Architecture

### High-Level Overview
```
┌─────────────────────────────────────────────────────────────┐
│                    USER LAYER (Flutter)                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Job Seeker   │  │  Recruiter   │  │  Admin       │      │
│  │ - Browse     │  │  - Post Jobs │  │  - Approve  │      │
│  │ - Apply      │  │  - Edit      │  │  - Manage   │      │
│  │ - Track      │  │  - View Apps │  │             │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                           │                                  │
│                    ┌──────┴──────┐                           │
│                    │  ApiService  │                          │
│                    │  + Auth      │                          │
│                    └──────┬───────┘                          │
└─────────────────────────┼──────────────────────────────────┘
                          │
                 HTTP/REST │ Bearer Token
                          │
┌─────────────────────────┴──────────────────────────────────┐
│                   BACKEND (Laravel 11)                       │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐ │
│  │ Auth Service   │  │ Job Service    │  │ Admin        │ │
│  │ + Sanctum      │  │ + Validation   │  │ Service      │ │
│  │ + Tokens       │  │ + Rules        │  │              │ │
│  └────────────────┘  └────────────────┘  └──────────────┘ │
│                                                             │
│  ┌────────────────────────────────────────────────────────┐│
│  │              MySQL Database                            ││
│  │  ┌─────────┬─────────┬──────────┬─────────────────┐   ││
│  │  │ users   │ jobs    │ apps     │ admin_approvals │   ││
│  │  └─────────┴─────────┴──────────┴─────────────────┘   ││
│  └────────────────────────────────────────────────────────┘│
│                                                             │
└────────────────────────────────────────────────────────────┘
                         │
       ┌─────────────────┴─────────────────┐
       │                                   │
┌──────┴──────────────┐         ┌──────────┴──────────┐
│  Admin Panel         │         │  Mobile API         │
│  (Filament)          │         │  JSON Responses     │
│  - Dashboard         │         │                     │
│  - Resources         │         │  Fast & Scalable    │
│  - Approvals         │         │                     │
└──────────────────────┘         └─────────────────────┘
```

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter 3.10+ | Cross-platform mobile app |
| **State Mgmt** | Provider | Simple, proven state management |
| **Routing** | GoRouter | Type-safe navigation |
| **Local DB** | SQLite | Offline caching |
| **Backend** | Laravel 11 | RESTful API server |
| **Auth** | Sanctum | Token-based API auth |
| **Database** | MySQL 8+ | Persistent data storage |
| **Admin** | Filament | Rapid admin UI scaffolding |

---

## <a name="database"></a>💾 Database Design

### Entity Relationship Diagram
```
users (1) ──┬──────── (M) jobs
            │
            ├──────── (M) applications
            │
            └──────── (M) admin_logs

jobs (1) ────────────────── (M) applications

applications: tracks user ─ job ─ status
```

### Complete Schema

#### 1. Users Table
```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('job_seeker', 'recruiter', 'admin') NOT NULL DEFAULT 'job_seeker',
    is_approved BOOLEAN DEFAULT FALSE COMMENT 'Admin approval flag',
    company_name VARCHAR(255) NULLABLE COMMENT 'For recruiters',
    company_website VARCHAR(255) NULLABLE,
    phone VARCHAR(20) NULLABLE,
    bio TEXT NULLABLE,
    profile_image_url VARCHAR(500) NULLABLE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_is_approved (is_approved),
    INDEX idx_created_at (created_at)
);
```

#### 2. Jobs Table
```sql
CREATE TABLE jobs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    recruiter_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description LONGTEXT NOT NULL,
    requirements LONGTEXT NULLABLE,
    salary_min DECIMAL(10, 2) NULLABLE,
    salary_max DECIMAL(10, 2) NULLABLE,
    salary_currency VARCHAR(3) DEFAULT 'USD',
    job_type ENUM('full_time', 'part_time', 'contract', 'temp') DEFAULT 'full_time',
    location VARCHAR(255) NULLABLE,
    remote_work ENUM('on_site', 'hybrid', 'remote') DEFAULT 'on_site',
    status ENUM('pending', 'approved', 'rejected', 'closed') DEFAULT 'pending',
    rejection_reason TEXT NULLABLE,
    approved_at TIMESTAMP NULL,
    approved_by BIGINT NULL COMMENT 'Admin user ID who approved',
    views_count INT DEFAULT 0,
    applications_count INT DEFAULT 0,
    deadline_at TIMESTAMP NULLABLE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete',
    
    FOREIGN KEY (recruiter_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_recruiter_id (recruiter_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_approved_at (approved_at)
);
```

#### 3. Applications Table
```sql
CREATE TABLE applications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    job_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    status ENUM('pending', 'accepted', 'rejected', 'withdrawn') DEFAULT 'pending',
    cover_letter TEXT NULLABLE,
    resume_url VARCHAR(500) NULLABLE,
    rejection_reason TEXT NULLABLE,
    reviewed_at TIMESTAMP NULL,
    reviewed_by BIGINT NULL COMMENT 'Admin reviewer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY unique_application (job_id, user_id) COMMENT 'Prevent duplicate applications',
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);
```

#### 4. Admin Logs Table (Optional, for auditing)
```sql
CREATE TABLE admin_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    admin_id BIGINT NOT NULL,
    action VARCHAR(100) NOT NULL COMMENT 'approve_user, reject_job, etc',
    model_type VARCHAR(50) NOT NULL COMMENT 'User, Job, Application',
    model_id BIGINT NOT NULL,
    old_data JSON NULLABLE,
    new_data JSON NULLABLE,
    reason TEXT NULLABLE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_admin_id (admin_id),
    INDEX idx_created_at (created_at)
);
```

---

## <a name="api"></a>🔌 API Specification

### Authentication Endpoints

#### Register
```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "role": "recruiter" | "job_seeker"
}

Response 201:
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "recruiter",
    "is_approved": false
  },
  "token": "1|abc123..."
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123!"
}

Response 200:
{
  "user": { ... },
  "token": "1|abc123..."
}
```

#### Logout
```http
POST /api/auth/logout
Authorization: Bearer {token}

Response 200:
{ "message": "Logged out successfully" }
```

### Jobs Endpoints

#### List All Jobs (Public)
```http
GET /api/jobs?page=1&per_page=10&search=developer&location=remote

Response 200:
{
  "data": [
    {
      "id": 1,
      "title": "Senior Flutter Developer",
      "description": "...",
      "salary_min": 60000,
      "salary_max": 100000,
      "location": "San Francisco, CA",
      "remote_work": "hybrid",
      "job_type": "full_time",
      "recruiter": {
        "id": 5,
        "name": "Tech Corp",
        "company_name": "Tech Corp Inc"
      },
      "applications_count": 12,
      "created_at": "2026-03-25T10:00:00Z"
    }
  ],
  "pagination": {
    "total": 150,
    "per_page": 10,
    "current_page": 1,
    "last_page": 15
  }
}
```

#### Create Job (Recruiter Only)
```http
POST /api/jobs
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Senior Flutter Developer",
  "description": "Looking for...",
  "requirements": "5+ years...",
  "salary_min": 60000,
  "salary_max": 100000,
  "job_type": "full_time",
  "location": "San Francisco, CA",
  "remote_work": "hybrid",
  "deadline_at": "2026-04-25T23:59:59Z"
}

Response 201:
{
  "id": 1,
  "title": "Senior Flutter Developer",
  "status": "pending",
  "message": "Job created successfully. Awaiting admin approval."
}
```

#### Get Job Details
```http
GET /api/jobs/{id}
Authorization: Bearer {token} (optional for job seekers)

Response 200:
{
  "id": 1,
  "title": "Senior Flutter Developer",
  "description": "...",
  "recruiter": { ... },
  "applicants_count": 12,
  "user_applied": true | false,
  "application_id": 5 (if applied),
  "application_status": "pending" | "accepted" | "rejected"
}
```

#### Update Job (Recruiter, own job only)
```http
PUT /api/jobs/{id}
Authorization: Bearer {token}
Content-Type: application/json

{ "title": "...", "description": "..." }

Response 200: Updated job object
```

#### Delete Job (Recruiter, own job only / Admin)
```http
DELETE /api/jobs/{id}
Authorization: Bearer {token}

Response 204: No Content
```

### Applications Endpoints

#### Apply for Job
```http
POST /api/jobs/{jobId}/apply
Authorization: Bearer {token}
Content-Type: application/json

{
  "cover_letter": "I am interested in...",
  "resume_url": "https://cdn.example.com/resume.pdf"
}

Response 201:
{
  "id": 10,
  "job_id": 1,
  "status": "pending",
  "message": "Application submitted successfully"
}
```

#### Get My Applications
```http
GET /api/my-applications?status=pending,accepted
Authorization: Bearer {token}

Response 200:
{
  "data": [
    {
      "id": 10,
      "job": { ... },
      "status": "pending",
      "created_at": "2026-03-25T10:00:00Z"
    }
  ]
}
```

#### Get Job Applicants (Recruiter/Admin)
```http
GET /api/jobs/{id}/applicants
Authorization: Bearer {token}

Response 200:
{
  "data": [
    {
      "id": 10,
      "user": { name: "Jane" },
      "status": "pending",
      "cover_letter": "...",
      "resume_url": "..."
    }
  ]
}
```

### Admin Endpoints

#### Approve User (for recruiter role)
```http
POST /api/admin/users/{userId}/approve
Authorization: Bearer {token} (admin only)
Content-Type: application/json

{
  "reason": "Company verified"
}

Response 200:
{
  "user": {
    "id": 2,
    "is_approved": true
  }
}
```

#### Reject User
```http
POST /api/admin/users/{userId}/reject
Authorization: Bearer {token} (admin only)

{
  "reason": "Failed verification"
}

Response 200:
```

#### Approve Job
```http
POST /api/admin/jobs/{jobId}/approve
Authorization: Bearer {token} (admin only)

Response 200:
{
  "job": {
    "id": 1,
    "status": "approved",
    "approved_at": "2026-03-28T10:00:00Z"
  }
}
```

#### Reject Job
```http
POST /api/admin/jobs/{jobId}/reject
Authorization: Bearer {token} (admin only)

{
  "reason": "Violates posting policy"
}

Response 200:
```

#### List Pending Items
```http
GET /api/admin/pending-users
GET /api/admin/pending-jobs
Authorization: Bearer {token} (admin only)

Response 200: Array of pending items
```

---

## <a name="phases"></a>📅 Implementation Phases

### Phase 0: Foundation (Week 1-2)
**Goal:** API core + Flutter connection working

**Tasks:**
- [ ] Laravel: Database migrations
- [ ] Laravel: User model, auth controller
- [ ] Laravel: Sanctum setup
- [ ] Flutter: ApiService with auth interceptor
- [ ] Flutter: Auth models + serialization
- [ ] Database seeding for testing

**Deliverable:** Authentication flow works end-to-end

---

### Phase 1: Core Features (Week 2-3)
**Goal:** Jobs + Applications working

**Tasks:**
- [ ] Laravel: Job CRUD endpoints
- [ ] Laravel: Application endpoints
- [ ] Laravel: Admin approval endpoints
- [ ] Flutter: Job feed screen
- [ ] Flutter: Job details + apply
- [ ] Flutter: Recruiter dashboard (post job)

**Deliverable:** Recruiters can post, job seekers can apply

---

### Phase 2: Admin Panel (Week 3-4)
**Goal:** Admin can manage system

**Tasks:**
- [ ] Filament: User resource (approve/reject)
- [ ] Filament: Job resource (approve/reject)
- [ ] Filament: Application resource
- [ ] Filament: Dashboard/stats
- [ ] Admin access control

**Deliverable:** Full admin workflow

---

### Phase 3: Polish (Week 4-5)
**Goal:** Production-ready

**Tasks:**
- [ ] Input validation + error handling
- [ ] Unit tests (Laravel)
- [ ] Integration tests (Flutter)
- [ ] Performance optimization
- [ ] Documentation

**Deliverable:** Production deployment

---

## <a name="setup"></a>🚀 Setup Instructions

### Prerequisites
- PHP 8.2+
- Laravel 11
- Node.js 18+
- Flutter 3.10+
- MySQL 8+
- Docker (optional, recommended)

### Step 1: Laravel Backend Setup

**1a. Create Laravel project**
```bash
composer create-project laravel/laravel job-platform-api
cd job-platform-api
```

**1b. Install dependencies**
```bash
composer require laravel/sanctum
composer require filament/filament
```

**1c. Setup database**
```bash
cp .env.example .env
php artisan key:generate

# Configure MySQL in .env
DB_DATABASE=job_platform
DB_USERNAME=root
DB_PASSWORD=
```

**1d. Create database**
```bash
mysql -u root
CREATE DATABASE job_platform DEFAULT CHARSET=utf8mb4;
EXIT;

php artisan migrate
php artisan tinker
```

**1e. Seed admin user**
```bash
php artisan tinker
> User::create(['name' => 'Admin', 'email' => 'admin@example.com', 'password' => Hash::make('password'), 'role' => 'admin', 'is_approved' => true])
```

### Step 2: Flutter App Setup

**2a. Create Flutter project**
```bash
flutter create job_platform_app
cd job_platform_app

# Add dependencies to pubspec.yaml
# (See PHASE_0_FLUTTER_SETUP.md for full list)
```

**2b. Configure API base URL**
```dart
// lib/core/config/environment.dart
const String API_BASE_URL = 'http://192.168.1.x:8000'; // dev
// const String API_BASE_URL = 'https://api.jobplatform.com'; // prod
```

**2c. Run app**
```bash
flutter pub get
flutter run
```

### Step 3: Filament Admin Setup

```bash
cd job-platform-api

# Publish Filament
php artisan filament:install --panels

# Create admin panel
php artisan make:filament-panel admin
```

---

## <a name="testing"></a>🧪 Testing & Validation

### 1. Authentication Flow
- [ ] Register as recruiter → can see "Pending Approval"
- [ ] Register as job seeker → can browse jobs
- [ ] Login with email/password → get token
- [ ] Token works in Authorization header
- [ ] Invalid token → 401

### 2. Job Seeker Flow
- [ ] Can view job list (GET /api/jobs)
- [ ] Can apply to job (POST /api/apply)
- [ ] Can see my applications
- [ ] Cannot create jobs

### 3. Recruiter Flow
- [ ] Cannot post jobs until admin approves
- [ ] Post job (admin approval required)
- [ ] Can see applicants
- [ ] Can edit/delete own jobs
- [ ] Cannot delete other recruiters' jobs

### 4. Admin Flow
- [ ] See pending recruiters in admin panel
- [ ] Approve recruiter → they can post jobs
- [ ] See pending jobs
- [ ] Approve job → visible in job feed
- [ ] Reject job → recruiter sees reason

### 5. Error Handling
- [ ] Invalid email format → 422
- [ ] Duplicate email → 422
- [ ] Missing required fields → 422
- [ ] Unauthorized request → 401
- [ ] Resource not found → 404

---

## 📚 Reference Files

All implementation files are provided in separate documents:

1. **[PHASE_0_LARAVEL_BACKEND.md](PHASE_0_LARAVEL_BACKEND.md)** — All Laravel code
2. **[PHASE_0_FLUTTER_SETUP.md](PHASE_0_FLUTTER_SETUP.md)** — Flutter implementation
3. **[PHASE_1_FILAMENT_ADMIN.md](PHASE_1_FILAMENT_ADMIN.md)** — Admin panel setup
4. **[DATABASE_MIGRATIONS.sql](DATABASE_MIGRATIONS.sql)** — SQL migrations

---

## 🎯 Success Criteria Checklist

### Minimum Viable Product (MVP)
- [x] Database schema designed
- [x] API specification defined
- [ ] Laravel backend implemented (Phase 0)
- [ ] Flutter app implemented (Phase 0)
- [ ] Authentication working end-to-end
- [ ] Recruiters can post jobs
- [ ] Job seekers can apply
- [ ] Admin can approve/reject

### Production Ready
- [ ] All error cases handled
- [ ] Input validation on all endpoints
- [ ] API rate limiting
- [ ] Unit tests (>80% coverage)
- [ ] Integration tests
- [ ] Deployment documentation
- [ ] Database backups configured
- [ ] Monitoring/logging setup

---

## ⚠️ Engineering Notes

### Best Practices Applied
1. **Separation of Concerns:** Each layer (DB, API, UI) is independent
2. **Validation:** All inputs validated at API layer
3. **Authentication:** Sanctum for token-based auth (stateless)
4. **Authorization:** Role-based access control (RBAC)
5. **Error Handling:** Consistent error codes + messages
6. **Database:** Foreign keys + indexes for performance
7. **Code Organization:** Models → Services → Controllers
8. **Testing:** Unit + integration tests before production

### Security Considerations
1. **Password Hashing:** Use bcrypt (Laravel default)
2. **Tokens:** Store securely in Flutter (use secure storage)
3. **HTTPS:** Always in production
4. **CORS:** Configure for Flutter domain
5. **Rate Limiting:** Implement on /login, /register
6. **SQL Injection:** Use Eloquent (parameterized queries)
7. **Input Validation:** Strict schema validation

---

**Next Steps:**
1. Review this Master Guide
2. Follow Phase 0 implementation documents
3. Test each endpoint with Postman/Insomnia
4. Deploy locally first

