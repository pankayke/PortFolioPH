# Task Plan Lock (Mandatory)

> Keep this file updated in real time for every non-trivial task.

## Current Task (Update)
- Jira/Issue: Recruiter ATS Polish Pass
- Owner: GitHub Copilot + Mark
- Start: 2026-04-13
- Target Completion: 2026-04-13
- Risk Level (1-10): 2

## Atomic Plan (Update)
- [x] 1. Add a richer candidate header card
- [x] 2. Improve ATS queue cards and empty state
- [x] 3. Validate the recruiter ATS screens with analyzer

## Evidence (Update)
- `CandidateProfileView` now has a stronger header card with summary pills and a clearer CV action.
- `ApplicantTrackingScreen` now has a richer queue header, better list cards, and a more deliberate empty state.
- Validation: `flutter analyze lib/features/recruiter/screens/ats/candidate_profile_view.dart lib/features/recruiter/screens/ats/applicant_tracking_screen.dart` passed with no issues.
- Status: Completed.

## Current Task (Update)
- Jira/Issue: Edit Profile + CV Upload Polish
- Owner: GitHub Copilot + Mark
- Start: 2026-04-13
- Target Completion: 2026-04-13
- Risk Level (1-10): 2

## Atomic Plan (Update)
- [x] 1. Rebuild edit profile with polished sections
- [x] 2. Restyle CV upload for lively mobile feedback
- [x] 3. Validate both screens with analyzer

## Evidence (Update)
- `EditProfileScreen` now has a branded header card, stronger section panels, and cleaner resume controls.
- `CVUploadScreen` now uses a glass-style upload card and works cleanly with the existing web-safe file flow.
- Validation: `flutter analyze lib/presentation/screens/profile/edit_profile_screen.dart lib/features/seeker/screens/profile/cv_upload_screen.dart` passed with no issues.
- Status: Completed.

## Current Task (Update)
- Jira/Issue: Profile UI Liveliness Pass
- Owner: GitHub Copilot + Mark
- Start: 2026-04-13
- Target Completion: 2026-04-13
- Risk Level (1-10): 2

## Atomic Plan (Update)
- [x] 1. Add a lively profile momentum card
- [x] 2. Restyle profile section cards for consistency
- [x] 3. Validate the modified profile screen with analyzer

## Evidence (Update)
- `ProfileScreen` now includes a profile pulse card with metric tiles and direct action buttons.
- `_SectionCard` now uses a glassier gradient treatment with a stronger header marker.
- Validation: `flutter analyze lib/presentation/screens/profile/profile_screen.dart` passed with no issues.
- Status: Completed.

## Current Task (Update)
- Jira/Issue: Dashboard UI Liveliness Pass
- Owner: GitHub Copilot + Mark
- Start: 2026-04-13
- Target Completion: 2026-04-13
- Risk Level (1-10): 2

## Atomic Plan (Update)
- [x] 1. Add a lively summary section to the seeker home dashboard
- [x] 2. Fill recruiter home/company whitespace with real cards and metrics
- [x] 3. Validate the edited Flutter files with analyzer

## Evidence (Update)
- `DashboardScreen` now includes a new momentum board with featured roles and live seeker stats.
- `RecruiterDashboardScreen` now includes a hiring pulse card and a richer company snapshot section.
- Validation: `flutter analyze lib/presentation/screens/dashboard/dashboard_screen.dart lib/features/recruiter/screens/dashboard/recruiter_dashboard_screen.dart` passed with no issues.
- Status: Completed.

## Current Task (Update)
- Jira/Issue: Public Job Detail Payload Optimization
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 2

## Atomic Plan (Update)
- [x] 1. Paginate recruiter applications in the public job detail controller
- [x] 2. Update the job detail view to consume the paginated collection
- [x] 3. Add regression coverage for the recruiter detail view
- [x] 4. Regenerate the QA DOCX source and validate the output

## Evidence (Update)
- `JobWebController::show` now loads recruiter data minimally and paginates applications.
- `resources/views/jobs/show.blade.php` now renders the paginated applications collection.
- Added a feature test covering the recruiter web job detail page and applications total.
- Validation: `php artisan test` passed (73 tests, 295 assertions).
- Validation: regenerated [docs/PortFolioPH_10_Page_Test_Cases.docx](docs/PortFolioPH_10_Page_Test_Cases.docx) and confirmed 9 explicit page-break markers.

## Status
- Completed

## Current Task (Update)
- Jira/Issue: Admin List Aggregate Count Cleanup
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 1

## Atomic Plan (Update)
- [x] 1. Replace remaining collection-based summary counts with query aggregates
- [x] 2. Validate controller syntax and full Laravel suite

## Evidence (Update)
- `AdminWebController::users` now computes active and total counts with query aggregates instead of collection scans.
- `AdminWebController::jobs` now computes moderation summary counts with query aggregates instead of collection scans.
- Validation: `php artisan test` passed (73 tests, 295 assertions).

## Status
- Completed

## Current Task (Update)
- Jira/Issue: Audit Stream + Job Detail Payload Optimization
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 2

## Atomic Plan (Update)
- [x] 1. Move audit-page counters and relations into the controller
- [x] 2. Trim job-detail API to count applications instead of hydrating them
- [x] 3. Add regression coverage for audit and job detail payloads
- [x] 4. Regenerate the QA DOCX source and validate output structure

## Evidence (Update)
- `AdminWebController::auditLog` now eager loads job recruiter and application user/job relations, and computes `activeSessions`/`serverLoad` in the controller.
- `resources/views/admin/audit.blade.php` no longer performs inline count math.
- `JobService::getJob` now uses `loadCount('applications')` instead of loading the full `applications` relation.
- Added feature tests for the admin audit page and job detail API count payload.
- Validation: `php artisan test` passed (72 tests, 292 assertions).
- Validation: regenerated [docs/PortFolioPH_10_Page_Test_Cases.docx](docs/PortFolioPH_10_Page_Test_Cases.docx) and confirmed 9 explicit page-break markers.

## Status
- Completed

## Current Task (Update)
- Jira/Issue: QA Doc Sync for Latest API Safety Changes
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 1

## Atomic Plan (Update)
- [x] 1. Update the source doc generator with latest API safety scenarios
- [x] 2. Regenerate the DOCX artifact from the updated source
- [x] 3. Verify document structure and page-break layout

## Evidence (Update)
- Updated [scripts/generate_portfolioph_testcases_docx.py](scripts/generate_portfolioph_testcases_docx.py) so PFVT-059 through PFVT-061 cover the latest per-page guardrails, route-safety behavior, and audit-stream optimization.
- Regenerated [docs/PortFolioPH_10_Page_Test_Cases.docx](docs/PortFolioPH_10_Page_Test_Cases.docx) from the updated source.
- Validation: DOCX still contains 9 explicit page-break markers, preserving the 10-page section layout.

## Current Task (Update)
- Jira/Issue: API Route Safety + Pagination Guardrails + Composite Index Expansion
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 3

## Atomic Plan (Update)
- [x] 1. Enforce per-page bounds on high-traffic job listing APIs
- [x] 2. Fix parameterized route shadowing of static endpoints
- [x] 3. Add missing composite indexes for common filter + sort paths
- [x] 4. Validate with focused and full regression suites

## Evidence (Update)
- `JobController` now clamps `per_page` to 1..100 for both `/api/jobs` and `/api/jobs/mine`.
- Added route numeric constraints in `routes/api.php` to prevent static endpoint shadowing (`jobs/mine`, `users/search`, etc.).
- Added migration `2026_04_11_150000_add_composite_performance_indexes.php` with guarded composite indexes:
	- jobs: `(status, created_at)`, `(recruiter_id, status, created_at)`
	- applications: `(user_id, created_at)`, `(job_id, status, created_at)`
	- users: `(role, active, created_at)`
- Added tests in `JobControllerTest` for per-page cap behavior on public jobs and recruiter mine endpoints.
- Validation: full `php artisan test` passed (70 tests, 284 assertions).
- Validation: `php artisan migrate --pretend` confirms SQL for new indexes.
- Validation: root `flutter analyze` clean and root `flutter test` all passed.

## Current Task (Update)
- Jira/Issue: Admin Controller Query Efficiency Pass (N+1 + Redundant Loads)
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 2

## Atomic Plan (Update)
- [x] 1. Remove redundant relation preloads before paginated queries
- [x] 2. Replace row-level relation count calls with `withCount` in admin job/user views
- [x] 3. Normalize recruiter job filters in service layer
- [x] 4. Re-run full Laravel suite

## Evidence (Update)
- `AdminWebController::showUser` now paginates `jobs` with `withCount('applications')` and `applications` with eager-loaded job title.
- `AdminWebController::jobs` now uses `withCount('applications')` + constrained recruiter eager load.
- `AdminWebController::showJob` now eager loads recruiter minimally and paginates applications with eager-loaded applicant info.
- `resources/views/admin/jobs/index.blade.php` now uses `applications_count` (precomputed) instead of per-row relation counting.
- `resources/views/admin/users/show.blade.php` recruiter jobs table now uses `applications_count`.
- `JobService::getRecruiterJobs` now trims/normalizes filter values and whitelists status filter values.
- Validation: `php -l app/Http/Controllers/AdminWebController.php` clean.
- Validation: `php -l app/Services/JobService.php` clean.
- Validation: full `php artisan test` passed (68 tests, 280 assertions).

## Current Task (Update)
- Jira/Issue: Full Optimization Pass + 10-Page QA Test Case Document (DOCX)
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 4

## Atomic Plan (Update)
- [x] 1. Continue backend optimization in high-impact query paths
- [x] 2. Keep regression safety through full Laravel test suite
- [x] 3. Generate 10-page test-case document in requested tabular format (.docx)

## Evidence (Update)
- Optimized `DashboardController` recruiter/seeker counters to use aggregate queries instead of repeated count calls.
- Corrected `JobService::getApprovedJobs` search grouping so `orWhere` cannot bypass approved status filtering.
- Validation: full `php artisan test` passed after optimization changes (68 tests).
- Generated document: `docs/PortFolioPH_10_Page_Test_Cases.docx`.
- Document built with 10 module sections and page breaks between sections to match 10-page structure request.

## Current Task (Update)
- Jira/Issue: Admin Users List Filter/Sort Regression Coverage
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 2

## Atomic Plan (Update)
- [x] 1. Add users-list search/role/status filter assertions
- [x] 2. Add active-sort and invalid-sort fallback assertions
- [x] 3. Re-run targeted and full Laravel test suites

## Evidence (Update)
- Extended `portfoliophhadmin/tests/Feature/AdminWebControllerTest.php` with 5 users-index tests.
- Added coverage for multi-term search across name/email/username.
- Added coverage for role alias normalization (`job seeker` → `job_seeker`).
- Added coverage for suspended-only filter behavior.
- Added coverage for active sort prioritization and invalid sort fallback to `created_at desc`.
- Validation: `php artisan test --filter=AdminWebControllerTest` passed (18 tests).
- Validation: full `php artisan test` passed (68 tests, 280 assertions).

## Current Task (Update)
- Jira/Issue: Admin Edge-Case Test Expansion (Settings + Role Transitions)
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 2

## Atomic Plan (Update)
- [x] 1. Add invalid settings payload validation coverage
- [x] 2. Add settings default-session coverage
- [x] 3. Add invalid role update and recruiter demotion side-effect coverage
- [x] 4. Re-run targeted and full Laravel tests

## Evidence (Update)
- Extended `portfoliophhadmin/tests/Feature/AdminWebControllerTest.php` with 4 new edge-case tests.
- Added validation-failure assertions for settings update payload constraints.
- Added default settings assertions when no admin settings are stored in session.
- Added invalid role update validation test.
- Added recruiter-to-job-seeker demotion test asserting job closure and application status neutralization to `reviewed`.
- Validation: `php artisan test --filter=AdminWebControllerTest` passed (13 tests).
- Validation: full `php artisan test` passed (63 tests, 270 assertions).

## Current Task (Update)
- Jira/Issue: AdminWebController Feature Test Coverage
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 3

## Atomic Plan (Update)
- [x] 1. Add dedicated feature tests for admin web controller routes/flows
- [x] 2. Fix route-name mismatches revealed by tests
- [x] 3. Re-run targeted and full Laravel test suites

## Evidence (Update)
- Added `portfoliophhadmin/tests/Feature/AdminWebControllerTest.php` with 9 passing tests.
- Covered auth boundary, non-admin access denial, dashboard payload, user suspend/unsuspend, user delete cascade behavior, job approve/suspend/delete, settings update session persistence, and applications stats payload.
- Fixed invalid redirect route names in `AdminWebController` from `admin.users`/`admin.jobs` to `admin.users.index`/`admin.jobs.index`.
- Validation: `php artisan test --filter=AdminWebControllerTest` passed; full `php artisan test` passed (59 tests).

## Current Task (Update)
- Jira/Issue: AdminWebController Query Optimization + Safety Hardening
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 3

## Atomic Plan (Update)
- [x] 1. Consolidate repeated dashboard/application count queries
- [x] 2. Add transaction safety for destructive deletes
- [x] 3. Validate with PHP lint + Laravel tests + Flutter analyze

## Evidence (Update)
- Admin dashboard/user/job/application aggregate counts now use consolidated SQL aggregates.
- User and job deletion flows now execute in DB transactions.
- Validation: `php -l app/Http/Controllers/AdminWebController.php` clean.
- Validation: `php artisan test` passed (50 tests, 214 assertions).
- Validation: root `flutter analyze` clean.

## Current Task (Update)
- Jira/Issue: RadioListTile Deprecation Cleanup (RadioGroup Migration)
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 2

## Atomic Plan (Update)
- [x] 1. Remove deprecated-member ignore directives
- [x] 2. Migrate deprecated RadioListTile APIs to RadioGroup
- [x] 3. Run analyzer and tests for proof-of-fix

## Evidence (Update)
- Removed file-level ignore directives from settings and resume export screens.
- Migrated deprecated `RadioListTile` `groupValue`/`onChanged` usage to `RadioGroup` in both screens.
- Root validation: `flutter analyze` clean and `flutter test` all passed.

## Current Task (Update)
- Jira/Issue: Repository Compatibility Cleanup + ApiService Smoke Test
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 3

## Atomic Plan (Update)
- [x] 1. Remove stale repository compatibility path
- [x] 2. Fix seed-account registration password flow
- [x] 3. Add shared ApiService smoke test
- [x] 4. Re-run root and nested app validation

## Evidence (Update)
- Removed deprecated shim file: `lib/data/services/api_service.dart`.
- Removed legacy `insert(UserModel)` compatibility wrapper in user repository.
- Updated `createIfMissingByEmail` to require explicit `plainPassword` for API registration.
- Updated seed-account callers in auth service to pass plain passwords explicitly.
- Added test: `test/core/services/api_service_smoke_test.dart` covering save/get/has/clear token lifecycle.
- Validation: root `flutter analyze` clean, root `flutter test` all passed; nested `mobile-jobs` analyze and tests both passed.

## Current Task (Update)
- Jira/Issue: Codebase Scan and API Service Optimization
- Owner: GitHub Copilot + Mark
- Start: 2026-04-11
- Target Completion: 2026-04-11
- Risk Level (1-10): 2

## Atomic Plan (Update)
- [x] 1. Scan analyzer and tests across both Flutter apps
- [x] 2. Remove safe duplication in the shared API service
- [x] 3. Re-run validation and confirm no regressions

## Evidence (Update)
- Root app analyzer: clean.
- Root app tests: all passed.
- Nested mobile-jobs analyzer: clean.
- API service refactor: request wrappers consolidated into one helper; unused `userKey` removed.
- Validation fix: reverted unsupported `const` usage on Dio `Options`.

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
