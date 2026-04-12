# PortFolioPH - Job Platform

**Unified Full-Stack Job Platform with Flutter Frontend + Node.js Backend**

## 🏗️ Architecture

```
portfolioph/
├── lib/                          # Flutter app (web & mobile)
│   ├── main.dart
│   ├── core/
│   │   ├── router/               # Navigation with auth guards
│   │   ├── services/             # API service with mock fallback
│   │   └── constants/            # App-wide constants
│   ├── data/
│   │   ├── repositories/         # User, Jobs, Applications
│   │   └── models/               # Data structures
│   ├── features/                 # Feature modules
│   ├── presentation/             # UI screens & widgets
│   └── services/
│
├── backend/                      # Node.js API Server
│   ├── api-server.cjs            # Main API server (port 8000)
│   ├── routes/                   # API route definitions
│   ├── database/                 # Schema migrations (template)
│   └── app/                      # Controllers template
│
└── docs/                         # Architecture & guides

```

## 🚀 Quick Start

### Prerequisites
- Flutter 3.10+
- Node.js 18+
- Chrome browser

### Running the Application

**Terminal 1: Start Backend API**
```bash
cd backend
node api-server.cjs
# ✅ API running on http://localhost:8000
```

**Terminal 2: Run Flutter App**
```bash
flutter run -d chrome
# ✅ App running on http://localhost:54725
```

**Access URLs**
- App: http://localhost:54725
- API: http://localhost:8000/api

## 📚 API Endpoints

### Authentication (Public)
- `POST /api/auth/register` - Register user
- `POST /api/auth/login` - Login user

### Jobs (Protected)
- `GET /api/jobs` - List all jobs
- `POST /api/jobs` - Create new job
- `GET /api/jobs/{id}` - Get job details
- `PUT /api/jobs/{id}` - Update job
- `DELETE /api/jobs/{id}` - Delete job

### Applications (Protected)
- `POST /api/applications` - Submit application
- `GET /api/applications` - List applications
- `PUT /api/applications/{id}/status` - Update status

### Users (Protected)
- `GET /api/users/{id}` - Get user
- `GET /api/users/search` - Search users

## 👥 User Roles

1. **Job Seeker** - Browse & apply for jobs, manage profile
2. **Recruiter** - Post jobs, review applications

## 🛠️ Technology Stack

- **Frontend**: Flutter, Provider (state management), Dio (HTTP), GoRouter
- **Backend**: Node.js, in-memory storage
- **Architecture**: Clean architecture, API-first, role-based UI
- **Auth**: Token-based (mock for development)

## 🔐 Features

✅ User registration with role selection
✅ Recruiter & Job Seeker dashboards
✅ Job posting & browsing
✅ Application tracking
✅ Admin panel
✅ Offline fallback with mock interceptor
✅ Secure token storage
✅ CORS-enabled API
✅ Hot reload development

## 📊 Testing

```bash
# Register new user
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@test.com","password":"pass123","role":"job_seeker"}'

# Check health
curl http://localhost:8000/api/health
```

## 🔄 Development Workflow

1. **Backend changes**: Edit `api-server.cjs`, restart server
2. **Frontend changes**: Edit Flutter files, hot reload with `r`
3. **Test**: Open http://localhost:54725 in Chrome
4. **Register**: Fill form → Select role → View dashboard

## 📈 Project Optimization

### Removed
- ✅ Duplicate admin directories
- ✅ Old backup folders
- ✅ Outdated documentation (cleaned from root)
- ✅ Redundant setup scripts

### Maintained
- ✅ Core Flutter app with all features
- ✅ Unified Node.js backend
- ✅ Essential documentation
- ✅ Configuration files

## 🚢 Deployment

### Production
- Build: `flutter build web --release`
- Deploy: Firebase Hosting, Vercel, or similar
- Backend: Convert to serverless (AWS Lambda, Google Cloud Functions)

## 📞 Quick Help

**Backend not starting?**
```bash
# Check if port 8000 is in use
lsof -i :8000  # Mac/Linux
netstat -ano | findstr :8000  # Windows
```

**App can't connect to API?**
- Verify backend is running on http://localhost:8000
- Check browser console for errors
- MockInterceptor provides fallback responses

**Need to restart everything?**
- Kill terminal processes (Ctrl+C)
- Start backend first, then flutter app

---

**Version**: 1.0.0 | **Status**: ✅ Production Ready | **Last Updated**: March 30, 2026
lib/
├── core/
│   ├── constants/       app_constants.dart
│   ├── router/          app_router.dart
│   ├── theme/           app_theme.dart
│   └── utils/           helpers.dart
├── data/
│   ├── datasources/
│   │   └── local/       database_service.dart
│   ├── models/          user, portfolio, project, skill,
│   │                    education, experience, certification,
│   │                    contact, theme_setting, app_setting
│   └── repositories/    one repo per model
└── presentation/
    ├── providers/        user, theme, navigation, portfolio
    ├── screens/
    │   ├── auth/         login, register
    │   ├── splash/       splash
    │   ├── dashboard/    (Sprint 3)
    │   ├── portfolio/    (Sprint 3)
    │   ├── resume/       (Sprint 4)
    │   ├── skills/       (Sprint 4)
    │   ├── profile/      (Sprint 5)
    │   └── main_scaffold.dart
    └── widgets/
        └── common/       placeholder_tab_body, loading, error
```

---

## Database Schema (10 Tables)

| # | Table | Purpose |
|---|-------|---------|
| 1 | `users` | Auth + profile |
| 2 | `portfolios` | Portfolio metadata |
| 3 | `projects` | Portfolio projects |
| 4 | `skills` | Skills with proficiency |
| 5 | `education` | Academic history |
| 6 | `work_experience` | Job history |
| 7 | `certifications` | Certificates + credentials |
| 8 | `contacts` | Social / contact links |
| 9 | `theme_settings` | Per-user theme preference |
| 10 | `app_settings` | Key-value settings store |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on Android device / emulator
flutter run

# Build release APK
flutter build apk --release
```

---

## Architecture Diagram

> 📐 *Sprint 1 placeholder – full diagram will be added in Sprint 9 Documentation sprint.*

```
┌──────────────────────────────────────┐
│            Presentation              │
│  Screens ◄── Providers ◄── Repos    │
└──────────────┬───────────────────────┘
               │
┌──────────────▼───────────────────────┐
│               Data                   │
│  Repositories ──► DatabaseService   │
│                   (SQLite / sqflite) │
└──────────────────────────────────────┘
```

---

## Branching Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Stable releases (tagged APKs) |
| `develop` | Integration branch |
| `feature/*` | Feature branches per story |
| `bugfix/*` | Bug fixes |

---

## Engineering Execution Standard (Mandatory)

These rules are mandatory for all contributors in this repository.

### 1) Workflow Orchestration
- Plan mode is required for any task beyond one atomic step, all architecture decisions, or confidence below 90%.
- If execution deviates >5% from plan, stop immediately, re-plan within 2 minutes, and get explicit approval before resuming.
- Define executable acceptance specs before implementation (example: widget state + expected visual/result proof).
- Verification, edge-case simulation, and post-change audits are part of plan mode, not optional.

### 2) Subtask / Subagent Discipline
- Parallelize independent research, alternatives, and validation tracks.
- For complexity >7/10, evaluate at least two implementation options before selecting final approach.
- Keep each parallel track scoped to one objective and consolidate with a single synthesis step.

### 3) Continuous Improvement
- Any correction or defect must be logged in `tasks/lessons.md` with:
    - Mistake pattern
    - Root cause
    - Prevention rule(s)
- Track weekly quality metrics and review lessons before starting high-risk tasks.

### 4) Verification Bar (Zero Tolerance)
- Never mark work complete without evidence:
    - tests passing,
    - manual repro/validation,
    - edge-case checks,
    - diff review for regressions.
- Final self-check: "Would this be mergeable by a senior/L6 reviewer?" If no, iterate.

### 5) Elegance Enforcement
- For non-trivial changes, pause and evaluate cleaner alternatives before coding.
- Reject hacky/non-idiomatic solutions; rewrite when maintainability is compromised.
- Prefer minimal viable change (target: ≤3 files / ≤50 LOC) unless justified.

### 6) Autonomous Bug Eradication
- On bug reports: reproduce, isolate, fix, verify, and ship with evidence chain.
- Proactively scan for similar bug patterns in nearby modules and fix preventively when safe.

### 7) Failure Recovery
- Three consecutive plan failures triggers full reset: fresh plan + explicit sync before continuing.
- Revert if regression is detected post-change.

### 8) Task Management Requirements
- Keep live checklist in `tasks/todo.md` with status markers (`✅`, `❌`, `🚫 Blocked`).
- Checkpoint verification every ~20% of task progress.
- Add milestone deltas (what changed + measurable impact).

### 9) Core Principles
- Simplicity first, root-cause fixes only, surgical scope control, no side-effect ripple.
- Metrics targets:
    - plan accuracy >95%
    - mistake rate <2%
    - strong maintainability/elegance score (8/10+ self-review)

---

## Sprint Roadmap

| Sprint | Focus | Status |
|--------|-------|--------|
| 1 | Core Setup & Architecture | ✅ Complete |
| 2 | Authentication (Login / Register) | 🔜 |
| 3 | Portfolio & Projects CRUD | 🔜 |
| 4 | Resume (Education / Experience / Certs) | 🔜 |
| 5 | Skills Management | 🔜 |
| 6 | Profile & Settings | 🔜 |
| 7 | Export & Sharing | 🔜 |
| 8 | Polish, Testing & Release | 🔜 |

---

*PortFolioPH – Build your portfolio, own your future.*


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
