# Backend Setup & API Documentation

## Quick Start

### Start the API Server

```bash
cd backend
node api-server.cjs
```

✅ Should output:
```
✅ Job Platform API running on http://localhost:8000
📝 API endpoints ready at :8000/api
```

## API Endpoints

### AUTH - Public Routes

#### Register User
```
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "job_seeker"  // or "recruiter"
}

Response (201):
{
  "user": { "id": 1, "name": "John Doe", "email": "john@example.com", "role": "job_seeker" },
  "token": "abc123def456..."
}
```

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}

Response (200):
{
  "user": { "id": 1, "name": "John Doe", "email": "john@example.com", "role": "job_seeker" },
  "token": "abc123def456..."
}
```

### JOBS - Protected Routes

#### List All Jobs
```
GET /api/jobs
Authorization: Bearer {token}

Response (200):
{
  "data": [
    { "id": 1, "title": "Senior Developer", "description": "...", "location": "Remote", "job_type": "full_time" },
    ...
  ],
  "current_page": 1
}
```

#### Create Job (Recruiters Only)
```
POST /api/jobs
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Senior Developer",
  "description": "We are looking for...",
  "location": "San Francisco, CA",
  "salary_min": 100000,
  "salary_max": 150000,
  "job_type": "full_time"
}

Response (201):
{ "id": 1, "title": "Senior Developer", ... }
```

#### Get Job Details
```
GET /api/jobs/1
Authorization: Bearer {token}

Response: { "id": 1, "title": "Senior Developer", ... }
```

### APPLICATIONS - Protected Routes

#### Submit Application
```
POST /api/applications
Authorization: Bearer {token}
Content-Type: application/json

{
  "job_id": 1,
  "cover_letter": "I am interested in this position because..."
}

Response (201):
{ "id": 1, "job_id": 1, "user_id": 2, "status": "pending", ... }
```

#### List Applications
```
GET /api/applications
Authorization: Bearer {token}

Response (200):
{
  "data": [
    { "id": 1, "job_id": 1, "user_id": 2, "status": "pending", ... },
    ...
  ],
  "current_page": 1
}
```

### USERS - Protected Routes

#### Get User Profile
```
GET /api/users/1
Authorization: Bearer {token}

Response (200):
{ "id": 1, "name": "John Doe", "email": "john@example.com", "role": "job_seeker" }
```

#### Search Users
```
GET /api/users/search
Authorization: Bearer {token}

Response (200):
[
  { "id": 1, "name": "John Doe", "email": "john@example.com", "role": "job_seeker" },
  ...
]
```

### HEALTH - Public Route

#### Check API Status
```
GET /api/health

Response (200):
{ "status": "ok", "message": "Job Platform API running" }
```

## Testing with cURL

### 1. Register a User
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Johnson",
    "email": "alice@example.com",
    "password": "secure123",
    "role": "job_seeker"
  }'
```

**Save the token from response** → `{token}`

### 2. Create a Job (As Recruiter)
```bash
curl -X POST http://localhost:8000/api/jobs \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Junior Developer",
    "description": "Help us build amazing features",
    "location": "New York, NY",
    "job_type": "full_time"
  }'
```

### 3. List Jobs
```bash
curl -X GET http://localhost:8000/api/jobs \
  -H "Authorization: Bearer {token}"
```

### 4. Apply for Job
```bash
curl -X POST http://localhost:8000/api/applications \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": 1,
    "cover_letter": "I am very interested in this role!"
  }'
```

### 5. Check Health
```bash
curl http://localhost:8000/api/health
```

## Database Schema (Reference)

The backend uses in-memory storage for development. Here's the schema structure:

### Users Table
```
id (int, PK)
name (string)
email (string, unique)
password (hashed)
role (enum: job_seeker, recruiter, admin)
created_at (timestamp)
```

### Jobs Table
```
id (int, PK)
recruiter_id (int, FK → users)
title (string)
description (text)
location (string)
salary_min (decimal)
salary_max (decimal)
job_type (enum: full_time, part_time, contract, freelance)
status (enum: open, closed)
created_at (timestamp)
updated_at (timestamp)
```

### Applications Table
```
id (int, PK)
user_id (int, FK → users)
job_id (int, FK → jobs)
cover_letter (text)
status (enum: pending, reviewed, shortlisted, rejected, accepted)
created_at (timestamp)
updated_at (timestamp)
unique(user_id, job_id)  -- Prevent duplicate applications
```

## Error Responses

All errors follow this format:

```json
{
  "message": "Error description",
  "error": true
}
```

### Common Errors

| Status | Message | Cause |
|--------|---------|-------|
| 400 | Missing required fields | Incomplete request body |
| 401 | Invalid credentials | Wrong email/password |
| 404 | User not found | Invalid user ID |
| 409 | Email already exists | Duplicate registration |
| 409 | Already applied to this job | Duplicate application |

##  Integration with Flutter App

The Flutter app is configured to use this API:

```dart
// In lib/core/services/api_service.dart
static const String baseUrl = 'http://localhost:8000/api';
```

The app automatically:
- Stores tokens in secure storage
- Includes tokens in all protected requests
- Falls back to mock data if API is unavailable
- Handles CORS automatically

## Production Considerations

### Before Deploying:
1. Switch from in-memory storage to persistent database (PostgreSQL/MySQL)
2. Add input validation & sanitization
3. Implement rate limiting
4. Add logging & monitoring
5. Use environment variables for configuration
6. Enable HTTPS
7. Add authentication refresh tokens
8. Implementpagination properly
9. Handle errors consistently
10. Add API versioning

### Environment Variables (Recommended):
```bash
API_PORT=8000
DB_HOST=localhost
DB_USER=portfolio
DB_PASSWORD=secure_password
DB_NAME=job_platform
NODE_ENV=development
```

---

**Last Updated**: March 30, 2026
