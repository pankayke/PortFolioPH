# PortFolioPH

> **Offline-first Flutter Android portfolio builder for students.**
>
> Developer: Mark Leannie Gacutno | Sprint 1 – Week 1 | 32 hours

---

## Project Overview

PortFolioPH is a mobile application that allows students to create, manage, and showcase professional portfolios directly from their Android device – no internet required.

**Platform:** Android (API 26–34)  
**Architecture:** Clean Architecture + Provider + Singleton Services  
**State Management:** Provider (ChangeNotifier)  
**Database:** SQLite via sqflite (offline-first)  
**Routing:** GoRouter 14+  
**Theme:** Material 3, light + dark, brand primary `#0D47A1`

---

## Sprint 1 – Core Setup & Architecture ✅

### Completed Deliverables

| Story | Description | Status |
|-------|-------------|--------|
| STORY-001 | Flutter project init & package setup | ✅ |
| STORY-002 | Clean architecture folder scaffold | ✅ |
| STORY-003 | SQLite DatabaseService + 10-table schema | ✅ |
| STORY-004 | AppConstants & AppTheme (Material 3) | ✅ |
| STORY-005 | GoRouter with all named routes + auth guard | ✅ |
| STORY-006 | Bottom Navigation Scaffold + 5 placeholder tabs | ✅ |
| STORY-007 | Splash screen with DB init + session check | ✅ |
| STORY-008 | Android permissions in manifest | ✅ |
| STORY-009 | README + architecture diagram placeholder | ✅ |

### Sprint 1 App Flow

```
Launch → SplashScreen (DB open + 3s)
           ├── userId in SharedPrefs? ──YES──► /dashboard (MainScaffold)
           └── No                    ──────► /login (LoginScreen)
```

---

## Folder Structure

```
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
