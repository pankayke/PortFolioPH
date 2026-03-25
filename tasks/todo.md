# Task Plan Lock (Mandatory)

> Keep this file updated in real time for every non-trivial task.

## Current Task (Update)
- Jira/Issue: Full Rewrite Program (Expected Output Alignment) — Phase 1: Essays + Offline Portfolio Coverage
- Owner: GitHub Copilot + Mark
- Start: 2026-03-16
- Target Completion: 2026-03-16
- Risk Level (1-10): 6

## Atomic Plan (Update)
- [x] 1. Audit feature coverage against expected output statement
- [x] 2. Add missing Essays domain module (model + repository + provider)
- [x] 3. Wire Essays into local DB migration and app provider graph
- [x] 4. Integrate Essays in Resume & Portfolio UI and PDF export
- [x] 5. Extend admin monitoring metrics to include essays
- [x] 6. Re-run analyze/tests/build for proof-of-fix

## Evidence (Update)
- Gap identified: essays were not implemented in student portfolio scope.
- Added: `student_essay_model.dart`, `student_essays_repository.dart`, `student_essays_provider.dart`.
- DB migration: bumped `dbVersion` to 4 and added `essays` table + indexes in migration 4.
- Provider wiring: registered `StudentEssaysProvider` in `main.dart`.
- Resume integration: added Essays tab/counter, add/delete essay dialog flows, and FAB routing.
- PDF integration: `StudentPortfolioPdfGenerator` now includes an `Essays` section.
- Admin monitoring: dashboard now displays essay totals and per-student essay count.
- Static analysis: `flutter analyze` reports same 12 legacy info-level issues (no errors introduced).
- Automated tests: `flutter test` passed (`+1: All tests passed!`).
- Build validation: `flutter build apk --debug` succeeded and produced `build\\app\\outputs\\flutter-apk\\app-debug.apk`.

## Current Task (Update)
- Jira/Issue: Proposal Scope Alignment Delta (Roles/Access + Naming + Achievements Moderation)
- Owner: GitHub Copilot + Mark
- Start: 2026-03-16
- Target Completion: 2026-03-16
- Risk Level (1-10): 5

## Atomic Plan (Update)
- [x] 1. Re-audit externally modified files before new edits
- [x] 2. Align role checks to constants and proposal role semantics
- [x] 3. Align module naming to Resume/Portfolio wording
- [x] 4. Add missing achievement capability (delete flow from student UI)
- [x] 5. Re-run analyze/tests/build and verify no regressions

## Evidence (Update)
- External-edit safety: re-read `resume_screen.dart`, `admin_dashboard_screen.dart`, and `student_achievements_repository.dart` before patching.
- Role consistency: removed magic role literals in router/dashboard/profile and switched to `AppConstants` role constants; added `roleUser` constant.
- Naming alignment: bottom nav label changed from `Academic` to `Resume`; dashboard/resume wording updated to `Resume & Portfolio` phrasing.
- Capability addition: student achievements now support delete with confirmation in `resume_screen.dart`.
- Static analysis: `flutter analyze` returns the same 12 pre-existing info-level issues (no errors).
- Automated tests: `flutter test` passed (`All tests passed!`).
- Build validation: `flutter build apk --debug` succeeded and produced `build\\app\\outputs\\flutter-apk\\app-debug.apk`.

## Current Task (Update)
- Jira/Issue: Proposal Alignment (Offline Android Portfolio Scope: Achievements + Admin Monitoring)
- Owner: GitHub Copilot + Mark
- Start: 2026-03-15
- Target Completion: 2026-03-15
- Risk Level (1-10): 6

## Atomic Plan (Update)
- [x] 1. Map proposal scope against current codebase implementation
- [x] 2. Add achievements module (schema + model + repository + provider)
- [x] 3. Integrate achievements into resume tabs, add flow, and academic PDF export
- [x] 4. Upgrade admin dashboard to monitor student portfolio progress with search
- [x] 5. Run analyzer/tests/build and confirm no regression in changed files

## Evidence (Update)
- Database migration: bumped `dbVersion` to 3 and added `achievements` table/indexes in migration 3.
- New student achievement flow: add/list/provider/repository/model integrated into resume screen + root provider wiring.
- PDF export: achievements section now included in `StudentPortfolioPdfGenerator` output.
- Admin visibility: `admin_dashboard_screen.dart` now loads student rows and shows reflections/skills/achievements metrics with search + refresh.
- Static analysis: `flutter analyze` returns 12 info-level pre-existing issues (no errors).
- Automated tests: `flutter test` passed (`All tests passed!`).
- Build validation: `flutter build apk --debug` succeeded and produced `build\\app\\outputs\\flutter-apk\\app-debug.apk`.

## Current Task (Update)
- Jira/Issue: Student Academic Portfolio Sprint-2 Package (Reflections, Skills Tracker, GWA, Teacher Dashboard, Academic PDF)
- Owner: GitHub Copilot + Mark
- Start: 2026-03-15
- Target Completion: 2026-03-15
- Risk Level (1-10): 8

## Atomic Plan (Update)
- [x] 1. Audit active router/providers/models and identify resume-centric gaps
- [x] 2. Add student-specific reflections/skills model + repository + provider modules
- [x] 3. Implement academic widgets (section tabs + GWA tracker)
- [x] 4. Implement teacher/coordinator dashboard with class/section filter
- [x] 5. Refactor resume screen to student academic portfolio flow
- [x] 6. Add student academic portfolio PDF generator and export action
- [x] 7. Wire routes/providers and role-based navigation entries
- [x] 8. Run pub get + analyze + test + debug apk build validation

## Evidence (Update)
- Dependency sync: `flutter pub get` completed successfully.
- Static analysis: `flutter analyze` reports 12 infos (legacy/pre-existing in untouched files).
- Automated tests: `runTests` summary passed=1 failed=0.
- Build validation: `flutter build apk --debug` succeeded after one transient Gradle daemon crash retry.
- Manual flow coverage: Academic tabs (Reflections, Skills, Education, Experience, Certifications), GWA widget, PDF export action, teacher dashboard route, and role-gated navigation compile and are reachable.

## Current Task (Update)
- Jira/Issue: Sprint-2 Expansion Package (Resume Tabs, Reflections, Skills Tracker, Admin, Settings, PDF Export)
- Owner: GitHub Copilot + Mark
- Start: 2026-03-15
- Target Completion: 2026-03-15
- Risk Level (1-10): 7

## Atomic Plan (Update)
- [x] 1. Audit active DB, router, providers, and placeholder screens
- [x] 2. Add schema/version support for reflections, tracked skills, and role-based access
- [x] 3. Implement repositories/providers/models for new resume modules
- [x] 4. Replace wireframe dashboard and skills screens with functional UI
- [x] 5. Expand resume into tabbed builder with add flows and PDF export
- [x] 6. Add settings screen, admin route, and provider wiring
- [x] 7. Run analyze/tests and fix regressions found in changed files

## Evidence (Update)
- Static checks: `flutter analyze` rerun after changes.
- Result: no analyzer errors; remaining 12 analyzer infos are legacy/unrelated placeholders or pre-existing deprecations outside this change set.
- Automated tests: `flutter test` passes after stabilizing splash timer behavior in widget smoke test.
- Manual validation path: dashboard, skills tracker, resume tabs, settings screen, admin route guard, and PDF export button compile and are wired.

## Current Task (Update)
- Jira/Issue: UI/UX Theme Redesign Package (Modern M3 + Glass Nav + Sectioned Resume + Gallery + Stepper Forms)
- Owner: GitHub Copilot + Mark
- Start: 2026-03-15
- Target Completion: 2026-03-15
- Risk Level (1-10): 5

## Atomic Plan (Update)
- [x] 1. Redesign core theme and palette extension
- [x] 2. Redesign main scaffold navigation visuals
- [x] 3. Redesign resume page into sectioned layout with debounced search
- [x] 4. Redesign portfolio into modern gallery with loading skeletons
- [x] 5. Convert add/edit forms to stepper flow and verify analyzer

## Evidence (Update)
- Static checks: `flutter analyze` rerun after changes.
- Result: no new issues in modified redesign files; remaining infos/warnings are legacy in untouched files.
- Manual validation path: main scaffold nav, resume certification CRUD, portfolio gallery, and both add/edit form flows compile successfully.

## Current Task
- Jira/Issue: Roadmap Alignment (External Sheet) → PortfolioPH Sprint 4 Slice
- Owner: GitHub Copilot + Mark
- Start: 2026-03-15
- Target Completion: 2026-03-15
- Risk Level (1-10): 6

## Atomic Plan
- [x] 1. Define executable acceptance criteria
- [x] 2. Implement minimal change set
- [x] 3. Run lint/tests + manual validation
- [x] 4. Diff audit for regressions
- [x] 5. Final evidence summary

## Live Progress
- 0%: Not started
- 20% checkpoint: External roadmap ingested and reconciled with local app scope.
- 40% checkpoint: Certification module design finalized (provider + media + UI CRUD).
- 60% checkpoint: Code implemented and formatted.
- 80% checkpoint: Analyzer rerun and syntax/nullability issues fixed.
- 100% complete: Sprint 4 first slice (certifications + media upload) landed.

## Status Board
- ✅ Done: Certification provider, add/edit screen, resume tab upgrade, image storage service.
- ❌ Failed: None.
- 🚫 Blocked: Full external SmartDentQue roadmap cannot be applied 1:1 to PortfolioPH domain.

## Milestone Delta Notes
- Milestone 1: Shifted roadmap-following to repo-compatible implementation path.
- Milestone 2: Added certification CRUD with search/filter and persistent SQLite integration.
- Milestone 3: Added certificate media upload/replacement/removal with local storage lifecycle.

## Evidence
- Tests: `flutter analyze` (no new errors from changed files; existing legacy infos/warnings remain).
- Manual repro: Resume tab now lists certifications and supports add/edit/delete + image attach.
- Edge-case simulation: Cancel image selection, invalid URL, expiry-before-issue validation handled.
- Diff summary: Added certification module files and wired provider into app startup.

## Rollback Plan
- Snapshot/reference commit: Current develop HEAD prior to this change set.
- Revert strategy: Revert the certification module commits and restore `resume_screen.dart` placeholder variant.
