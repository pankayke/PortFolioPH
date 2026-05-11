# PortFolioPH Full Context Study Guide

## Purpose

This document is a practical study guide for the current PortFolioPH workspace. It combines the verified architecture, runtime flow, data models, API surface, performance issues, and the main docs you should read first.

It is not the hidden system prompt. It is the useful operational context of this repository.

## Assistant Context

- Session model: GPT-5.4 mini
- Operating environment: VS Code coding agent
- Current OS: Windows
- Primary goal in this workspace: keep the Flutter app and backend aligned, reduce request spam, and preserve production readiness

## High-Level System View

PortFolioPH is a hybrid job-platform workspace with two visible application surfaces:

1. Flutter frontend in [lib/](../lib)
2. Laravel backend/admin in [portfoliophhadmin/](../portfoliophhadmin)

The runtime stack in local development is centered on:

- Frontend: Flutter Web / mobile
- HTTP client: Dio
- State management: Provider
- Routing: GoRouter
- Auth token storage: flutter_secure_storage
- Backend API base URL: `http://127.0.0.1:8000/api`
- Docker compose stack: [docker-compose.yml](../docker-compose.yml)

## What the Product Does

The product combines two major domains:

1. Job platform
   - Recruiter dashboard
   - Job listing and job creation
   - Applications / ATS-style tracking
   - Login, logout, and role-based navigation

2. Portfolio / student profile features
   - Portfolio projects
   - Education history
   - Experience history
   - Certifications
   - Skills tracker
   - Reflections / essays / achievements in student-focused flows

## Current Architectural Reality

The repository contains documentation from multiple stages of evolution. The important takeaway is that the app has moved toward an API-first model, but some docs still describe older or partially migrated behavior.

Verified by the current source files:

- Flutter app uses live API calls through `ApiService`
- Backend endpoints are served from `localhost:8000`
- Recruiter dashboard and seeker dashboard are live data screens
- Some profile endpoints still 404 in the current backend, so the frontend includes fallback behavior and request suppression

## Request Flow

The typical authenticated request path is:

1. UI widget or provider requests data
2. Repository calls `ApiService`
3. `ApiService` injects the bearer token from secure storage
4. Dio sends the HTTP request to the backend
5. Backend returns JSON or an error status
6. `ApiService` maps the response to app-level exceptions or data
7. Provider updates state and notifies listeners
8. Widget rebuilds

## Key Runtime Files

### Frontend config and networking

- [lib/core/config/app_config.dart](../lib/core/config/app_config.dart)
- [lib/core/services/api_service.dart](../lib/core/services/api_service.dart)
- [lib/core/services/api_error_interceptor.dart](../lib/core/services/api_error_interceptor.dart)
- [lib/core/services/polling_service.dart](../lib/core/services/polling_service.dart)

### Main dashboard flows

- [lib/presentation/screens/dashboard/dashboard_screen.dart](../lib/presentation/screens/dashboard/dashboard_screen.dart)
- [lib/features/recruiter/screens/dashboard/recruiter_dashboard_screen.dart](../lib/features/recruiter/screens/dashboard/recruiter_dashboard_screen.dart)

### Main providers

- [lib/presentation/providers/job_feed_provider.dart](../lib/presentation/providers/job_feed_provider.dart)
- [lib/presentation/providers/portfolio_provider.dart](../lib/presentation/providers/portfolio_provider.dart)
- [lib/presentation/providers/skills_provider.dart](../lib/presentation/providers/skills_provider.dart)
- [lib/presentation/providers/experience_provider.dart](../lib/presentation/providers/experience_provider.dart)
- [lib/presentation/providers/education_provider.dart](../lib/presentation/providers/education_provider.dart)
- [lib/presentation/providers/certification_provider.dart](../lib/presentation/providers/certification_provider.dart)
- [lib/presentation/providers/reflections_provider.dart](../lib/presentation/providers/reflections_provider.dart)

### Data repositories

- [lib/data/repositories/job_feed_repository.dart](../lib/data/repositories/job_feed_repository.dart)
- [lib/data/repositories/portfolio_repository.dart](../lib/data/repositories/portfolio_repository.dart)
- [lib/data/repositories/skills_repository.dart](../lib/data/repositories/skills_repository.dart)
- [lib/data/repositories/experience_repository.dart](../lib/data/repositories/experience_repository.dart)
- [lib/data/repositories/education_repository.dart](../lib/data/repositories/education_repository.dart)
- [lib/data/repositories/certification_repository.dart](../lib/data/repositories/certification_repository.dart)
- [lib/data/repositories/student_reflections_repository.dart](../lib/data/repositories/student_reflections_repository.dart)
- [lib/data/repositories/student_skills_repository.dart](../lib/data/repositories/student_skills_repository.dart)
- [lib/data/repositories/student_essays_repository.dart](../lib/data/repositories/student_essays_repository.dart)
- [lib/data/repositories/student_achievements_repository.dart](../lib/data/repositories/student_achievements_repository.dart)

### Backend docs

- [README.md](../README.md)
- [BACKEND_API_GUIDE.md](../BACKEND_API_GUIDE.md)
- [ARCHITECTURE_AND_DECISIONS.md](../ARCHITECTURE_AND_DECISIONS.md)
- [CODEBASE_FULL_CONTEXT.md](../CODEBASE_FULL_CONTEXT.md)
- [DOCUMENTATION_INDEX.md](../DOCUMENTATION_INDEX.md)

## Verified Environment Settings

### Local API URL

The current development API URL is:

`http://127.0.0.1:8000/api`

This matches the backend docs and Docker stack, and it is the URL the Flutter app now uses by default in development.

### Docker service mapping

From [docker-compose.yml](../docker-compose.yml):

- API exposed on host port `8000`
- Frontend exposed on host port `3000`
- MySQL exposed on host port `3307`
- phpMyAdmin exposed on host port `8080`
- Mailpit exposed on host port `8025`

## Main User Flows

### Login flow

1. User opens login screen
2. Credentials are submitted to `/api/auth/login`
3. Backend returns user data and token
4. Token is stored in secure storage
5. App routes into the appropriate dashboard

### Session restore flow

1. App starts
2. Auth provider checks for stored token
3. If token exists, `/api/auth/me` is called
4. If valid, user is returned to the dashboard without logging in again
5. If invalid, token is cleared and the login screen is shown

### Logout flow

1. User logs out
2. `/api/auth/logout` is called with bearer token
3. Backend invalidates the token
4. Local token is cleared
5. User returns to the login screen

### Job feed flow

1. Dashboard becomes visible
2. `JobFeedProvider` loads jobs from `/api/jobs`
3. Polling starts for periodic refreshes
4. Matching / ranking runs when profile data is available

### Recruiter dashboard flow

1. Recruiter dashboard loads summary data
2. Job manager and application manager refresh
3. Bottom navigation controls Home, My Jobs, ATS, Post, Company
4. Floating action button opens job creation

## Known Performance / UX Issues We Fixed

These were the major issues addressed recently:

1. API base URL mismatch
   - Development login was pointing to port `9000`
   - Fixed to `8000`

2. Recruiter mobile layout overlap
   - Bottom content was hidden behind the floating button and navigation
   - Fixed with responsive bottom inset padding

3. Repeated 404 requests
   - Unsupported profile endpoints were being retried repeatedly
   - Fixed with short cooldown suppression for known-missing GET routes

4. Polling lifecycle thrash
   - Polling was starting/stopping in a way that could trigger build-time state changes
   - Fixed by moving polling start to the post-frame user-load path and stopping it in dispose

## Main 404-End Point Pattern

The following endpoints are currently known to be unavailable or not fully implemented in the backend, based on the runtime logs you shared:

- `/users/{id}/portfolios`
- `/users/{id}/certifications`
- `/users/{id}/skill-tracker`
- `/users/{id}/reflections`
- `/users/{id}/experience`
- `/users/{id}/education`
- `/students/{id}/reflections`
- `/students/{id}/skills`
- `/students/{id}/essays`
- `/students/{id}/achievements`
- `/portfolios/{id}/projects`

This is why the frontend now avoids hammering the same missing route over and over.

## Data Model Catalog

### Job platform models

- `UserModel`
  - Identity, email, role, profile fields, token-backed auth state

- `Job` / `JobListingModel`
  - Job title, description, location, salary, status, categories, recruiter ownership

- `ApplicationModel`
  - Job application, status, interview scheduling, applicant metadata

### Portfolio / profile models

- `PortfolioModel`
  - Portfolio container owned by a user

- `ProjectModel`
  - Portfolio project items and tech stack metadata

- `SkillsModel` / `SkillModel`
  - Skills tracking and skill metadata

- `ExperienceModel`
  - Work history and role timeline

- `EducationModel`
  - Institutions, degrees, field of study, dates

- `CertificationModel`
  - Certificates, issuers, dates, links

- `ReflectionModel`
  - User reflections and personal notes

### Student portfolio models

- `StudentReflectionModel`
- `StudentSkillsModel`
- `StudentEssayModel`
- `StudentAchievementModel`

## Repository Behavior Summary

### JobFeedRepository

- Fetches live jobs from `/api/jobs`
- Returns list-shaped data when backend responds with array
- Used by the dashboard and polling layer

### PortfolioRepository

- Tries `/users/{id}/portfolios`
- Falls back to local cache when backend route is unavailable

### CertificationRepository / SkillsRepository / ExperienceRepository / EducationRepository

- Try user-scoped API routes first
- Fall back to local in-memory storage in error cases
- This keeps the UI functional even when those backend endpoints are absent

### Student repositories

- Call `/students/{id}/...` endpoints directly
- These are the sources of the repeated 404s in your logs when the backend does not implement them

## State Management Summary

Most UI state is managed through Provider-based ChangeNotifiers.

Key patterns:

- Providers load data asynchronously
- Providers call `notifyListeners()` after fetches or updates
- UI widgets use `Consumer`, `Selector`, and `context.watch()` / `context.read()`

Important note:

- If a provider calls `notifyListeners()` during a build phase or from a lifecycle callback that is still inside the build pipeline, Flutter can throw `setState() or markNeedsBuild() called during build`

## Polling System

The app uses a small polling service for live refreshes.

Behavior:

- Polling tasks are identified by string IDs
- A task starts immediately and then repeats on an interval
- Failures are counted, and the task stops after repeated failures

In the current dashboard flow, job polling is used to keep the job feed fresh while the screen is visible.

## Backend Summary

The backend documentation describes:

- Auth routes for register, login, logout
- Jobs routes for listing, creating, updating, deleting
- Applications routes for submission and status updates
- Users routes for profile and search

Laravel docs and runtime config also show:

- Sanctum bearer token auth
- CORS enabled for API paths
- Dockerized runtime with nginx, php-fpm, mysql, redis, and mailpit

## Documentation You Should Read First

If you want to understand the system quickly, read these in this order:

1. [README.md](../README.md)
2. [DOCUMENTATION_INDEX.md](../DOCUMENTATION_INDEX.md)
3. [BACKEND_API_GUIDE.md](../BACKEND_API_GUIDE.md)
4. [ARCHITECTURE_AND_DECISIONS.md](../ARCHITECTURE_AND_DECISIONS.md)
5. [CODEBASE_FULL_CONTEXT.md](../CODEBASE_FULL_CONTEXT.md)
6. [RUNTIME_VALIDATION_REPORT_FINAL.md](../RUNTIME_VALIDATION_REPORT_FINAL.md)

## Practical Study Notes

- The workspace contains both current implementation files and older documentation from previous architecture phases.
- When the docs and code disagree, trust the current source files first.
- When you see repeated 404s in logs, look for a provider or repository that retries an unsupported route.
- When you see `setState() or markNeedsBuild() called during build`, inspect lifecycle callbacks and post-frame scheduling.
- When the browser says the request failed before response, verify API port, backend liveness, and CORS.

## What Changed Most Recently

- Development API base URL aligned to port `8000`
- Recruiter dashboard mobile spacing fixed
- Dashboard polling lifecycle corrected
- 404 spam reduced for unsupported profile routes

## Short Version

If you only remember one thing:

PortFolioPH is a Flutter-first UI backed by API calls to a Laravel/Node-backed job platform, with Provider-managed async state, Dio-based auth requests, a 8000-based local API, and several legacy docs that should be treated as historical unless they match the current source.
