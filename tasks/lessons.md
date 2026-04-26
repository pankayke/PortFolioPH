# Lessons Log (Mandatory)

> Log every correction, failed attempt, or preventable defect.

- Date: 2026-04-24
- Task/Jira: System Gap Recommendations Pass
- Mistake pattern (exact): Gap lists were documented, but the repo did not state the recommended execution order for closing them.
- Root cause: The analysis docs enumerated issues without turning them into a sequenced action plan.
- Prevention rules (min 3):
  1. Pair every gap list with an explicit priority order and rationale.
  2. Separate release blockers from growth features so planning cannot blur urgency.
  3. Keep roadmap docs aligned when a master analysis doc changes its recommendations.
- Validation on next similar task: Confirm the main scan summary and roadmap agree on the same priority order.
- Outcome: The system now has a clear recommended sequence for closing its gaps.

- Date: 2026-04-24
- Task/Jira: Theme Toggle Fix for Seeker and Recruiter
- Mistake pattern (exact): A role-specific dashboard wrapped itself in a forced light `Theme`, making global theme toggles appear broken.
- Root cause: Local visual customization overrode `MaterialApp.themeMode` instead of deriving from shared `Theme.of(context).colorScheme`.
- Prevention rules (min 3):
  1. Never hard-pin role dashboards to light/dark `ThemeData` when global theme mode is already managed centrally.
  2. For any role-specific shell, use `Theme.of(context)` tokens instead of hardcoded light colors for scaffold/app bar/navigation surfaces.
  3. Ensure each major role flow has an obvious theme toggle touchpoint and verify it updates the current screen immediately.
- Validation on next similar task: Run analyzer on affected role screens and perform role-by-role toggle smoke tests.
- Outcome: Theme toggle now works visibly in both seeker and recruiter dashboards.

- Date: 2026-04-24
- Task/Jira: Seeker Dashboard Job Filter Feature
- Mistake pattern (exact): The jobs tab exposed search but omitted practical filter controls even though provider query support already existed.
- Root cause: UI iteration progressed faster than feature parity checks against provider capabilities.
- Prevention rules (min 3):
  1. For each list screen, verify visible controls map to all high-value query parameters supported by the provider.
  2. Keep one unified query execution method so search and filters cannot diverge.
  3. Always include a one-tap clear-filters action once multiple filters are present.
- Validation on next similar task: Run analyzer on changed UI/provider files and execute full Flutter tests after adding new controls.
- Outcome: Jobs tab now supports fast employment and remote filtering with stable test coverage.

- Date: 2026-04-24
- Task/Jira: System + Codebase Hardening Sweep
- Mistake pattern (exact): Diagnostic scripts in repo root could execute mutating API flows without explicit safety gates, and one route check used a stale endpoint.
- Root cause: Internal tooling scripts evolved outside the stricter guardrails used in automated tests and route contracts.
- Prevention rules (min 3):
  1. All mutating diagnostic scripts must require an explicit runtime flag such as `--allow-mutations`.
  2. Diagnostic base URLs must be limited to localhost unless explicitly reviewed for another environment.
  3. Include route-contract verification in script updates whenever API routes change.
- Validation on next similar task: Run diagnostics with and without safety flags, confirm expected blocking behavior, and confirm script routes match `routes/api.php`.
- Outcome: Safer script execution defaults and corrected API route checks.

- Date: 2026-04-13
- Task/Jira: Repo Context + Optimization Pass
- Mistake pattern (exact): Several high-traffic pages were still loading broad relations or relying on random factory roles in tests.
- Root cause: View code and controller data shaping drifted slightly apart, and a test used the factory default role instead of an explicit job seeker.
- Prevention rules (min 3):
  1. Match eager-loaded columns to the exact fields rendered in the Blade template.
  2. Make role-sensitive API tests explicit instead of depending on factory defaults.
  3. Re-run the full suite after touching shared controllers, because unrelated-looking changes can expose latent test assumptions.
- Validation on next similar task: Confirm the rendered view still has all required fields and the suite stays green after the data-shape trim.
- Outcome: Dashboard and admin pages now fetch less data, and the application-create test is deterministic.

- Date: 2026-04-11
- Task/Jira: Admin List Aggregate Count Cleanup
- Mistake pattern (exact): Admin list summary cards still derived counts from paginated collection slices instead of query aggregates.
- Root cause: The list pages were already optimized for eager loading, but the final metric derivation still used in-memory collection scans.
- Prevention rules (min 3):
  1. If the summary card is meant to represent the full filtered dataset, compute it with a query aggregate.
  2. Reserve collection scans for small, intentional page-only summaries.
  3. Re-run the test suite after replacing page metrics with aggregate queries, because the pagination shape can change subtly.
- Validation on next similar task: Confirm controller aggregates and view counts still match the rendered moderation cards.
- Outcome: Admin list pages now avoid in-memory summary counting as well.

- Date: 2026-04-11
- Task/Jira: Public Job Detail Payload Optimization
- Mistake pattern (exact): The recruiter-facing public job detail page relied on the model's full applications relation even though only a paginated slice and total count were displayed.
- Root cause: The controller passed a bare job model to the view, so the view fell back to lazy loading the entire hasMany relation.
- Prevention rules (min 3):
  1. When a page shows a subset of a large relation, pass a paginator instead of the raw relation.
  2. Keep count totals separate from row collections so the UI can show both without loading everything.
  3. Add a regression test that asserts the page is using the expected pagination shape.
- Validation on next similar task: Confirm the view consumes the paginator and that `total()` still matches the relation count.
- Outcome: Public recruiter job detail now avoids fetching unnecessary application rows.

## Entry Template
- Date:
- Task/Jira:
- Mistake pattern (exact):
- Root cause:
- Prevention rules (min 3):
  1. 
  2. 
  3. 
- Validation on next similar task:
- Outcome:

- Date: 2026-04-11
- Task/Jira: Audit Stream + Job Detail Payload Optimization
- Mistake pattern (exact): The audit page was calculating live metrics in Blade while its controller only passed raw collections, and the public job-detail API was hydrating a full applications relation that the consumers did not use.
- Root cause: View-layer logic drifted away from the controller contract, and the API response shape was carrying extra data without a consumer check.
- Prevention rules (min 3):
  1. Keep derived page metrics in controllers so templates remain display-only.
  2. Use `loadCount(...)` for summary-only relationship data.
  3. Check the actual downstream consumer before keeping a heavy relation in a read API.
- Validation on next similar task: Verify related entities are eager loaded only where the view needs them, and confirm API consumers still deserialize the trimmed payload.
- Outcome: Audit rendering is cheaper and the job detail endpoint sends less data.

---

- Date: 2026-04-11
- Task/Jira: QA Doc Sync for Latest API Safety Changes
- Mistake pattern (exact): QA source and generated DOCX can drift from recent code changes if updates are made only in the codebase.
- Root cause: Documentation treated as a one-off artifact instead of a living companion to code changes.
- Prevention rules (min 3):
  1. Update the DOCX source generator whenever endpoint behavior or guardrails change.
  2. Regenerate the artifact from source instead of editing the DOCX directly.
  3. Keep the latest test-case coverage aligned to actual regression targets such as pagination caps and route constraints.
- Validation on next similar task: Updated PFVT-059/060 to match the latest API safety changes and regenerated the document.
- Outcome: QA docs now track the code changes instead of lagging behind them.

- Date: 2026-04-11
- Task/Jira: API Route Safety + Pagination Guardrails + Composite Index Expansion
- Mistake pattern (exact): Parameterized API routes could shadow static endpoints (for example, `jobs/{job}` intercepting `jobs/mine`), and unbounded `per_page` could invite oversized list queries.
- Root cause: Route definition order + unconstrained model-binding segments + missing request guardrails on pagination inputs.
- Prevention rules (min 3):
  1. Add `whereNumber(...)` constraints to model-bound route segments when static sibling routes exist.
  2. Enforce strict `per_page` bounds at controller entry points for all paginated endpoints.
  3. Convert recurring filter-and-sort patterns into composite indexes that match where/order columns.
- Validation on next similar task: Added two per-page cap tests, fixed route constraints, validated full backend and Flutter suites, and dry-ran migration SQL.
- Outcome: Safer route resolution, bounded API payload size, and improved DB index coverage with regression safety.

- Date: 2026-04-11
- Task/Jira: Admin Controller Query Efficiency Pass (N+1 + Redundant Loads)
- Mistake pattern (exact): Controller methods preloaded full relations and then re-queried paginated relations, while Blade tables used per-row relation counts.
- Root cause: Mixed use of `load(...)` and paginated relation queries without a strict data-shaping contract for views.
- Prevention rules (min 3):
  1. Never `load()` large hasMany relations if the same data will be fetched through pagination.
  2. Prefer `withCount(...)` for table counters instead of relation collection count calls inside loops.
  3. Constrain eager loads to only required columns for list/detail admin screens.
- Validation on next similar task: Applied to admin user/job detail/list flows and revalidated with full Laravel test suite.
- Outcome: Lower query load on admin pages with unchanged behavior and green regression tests.

- Date: 2026-04-11
- Task/Jira: Full Optimization Pass + 10-Page QA Test Case Document (DOCX)
- Mistake pattern (exact): Service-layer search query used ungrouped `orWhere`, which can silently widen result sets and bypass base constraints.
- Root cause: Query condition chaining without explicit grouping in mixed `where`/`orWhere` search logic.
- Prevention rules (min 3):
  1. Wrap search disjunctions in closure groups whenever base constraints (e.g., status) must always apply.
  2. Prefer aggregate count bundles in dashboard/controller metrics to reduce repeated queries.
  3. For large QA deliverables, generate documents from structured source data to keep formatting consistent and scalable.
- Validation on next similar task: Applied by patching grouped search and running full Laravel suite; generated `.docx` via scripted builder.
- Outcome: Query correctness improved, backend tests remained green, and requested QA artifact delivered in docx format.

- Date: 2026-04-11
- Task/Jira: Admin Users List Filter/Sort Regression Coverage
- Mistake pattern (exact): Users-list query behavior (role alias normalization, fallback sorting, suspended filter semantics) had no dedicated regression tests.
- Root cause: Prior admin tests prioritized route access and mutation flows over list query semantics.
- Prevention rules (min 3):
  1. Add explicit test cases for each supported filter and alias mapping in list endpoints.
  2. Add fallback-behavior tests for invalid query params (`sort_by`, `sort_dir`) to prevent unsafe regressions.
  3. Include at least one deterministic ordering assertion for list sorting logic.
- Validation on next similar task: Applied by adding five users-index tests and rerunning targeted/full suites.
- Outcome: Admin users list query logic is now regression-protected.

- Date: 2026-04-11
- Task/Jira: Admin Edge-Case Test Expansion (Settings + Role Transitions)
- Mistake pattern (exact): Key admin-side business rules (default settings and recruiter demotion side effects) lacked explicit regression tests despite being behavior-critical.
- Root cause: Initial controller coverage focused on happy paths and core route access first.
- Prevention rules (min 3):
  1. Add at least one invalid-payload test per settings/validation endpoint.
  2. Add business-rule side-effect assertions (status changes, cascade updates) for role transitions.
  3. Include default-state/session-fallback tests for configuration endpoints.
- Validation on next similar task: Applied by adding four edge-case tests and rerunning targeted/full Laravel suites.
- Outcome: Admin behavior has explicit regression protection for validation, defaults, and transition side effects.

- Date: 2026-04-11
- Task/Jira: AdminWebController Feature Test Coverage
- Mistake pattern (exact): Redirect assertions initially targeted undefined route aliases (`admin.users`, `admin.jobs`) that also existed in controller redirects.
- Root cause: Controller and tests assumed shorthand route names that were not declared in route definitions.
- Prevention rules (min 3):
  1. Use route-name constants or verify route names against `routes/web.php` before writing redirects/assertions.
  2. Add feature tests for admin web controllers to catch route wiring drift early.
  3. Treat test failures in route assertions as potential production redirect bugs, not test-only issues.
- Validation on next similar task: Applied by fixing controller redirects to `admin.users.index`/`admin.jobs.index` and rerunning full test suite.
- Outcome: Admin controller route flows are now explicitly covered and validated.

- Date: 2026-04-11
- Task/Jira: AdminWebController Query Optimization + Safety Hardening
- Mistake pattern (exact): Admin analytics and status cards were issuing multiple separate count queries per request.
- Root cause: Incremental feature additions favored straightforward per-metric counts over aggregate query composition.
- Prevention rules (min 3):
  1. Prefer aggregate `CASE WHEN` count bundles for dashboard/status-card metrics.
  2. Wrap manual cascade deletes in transactions to avoid partial-write states.
  3. Validate backend controller optimizations with both lint and full feature tests.
- Validation on next similar task: Applied by consolidating count queries and adding transactions in AdminWebController, then running `php artisan test`.
- Outcome: Fewer DB round-trips in admin pages with unchanged test behavior.

- Date: 2026-04-11
- Task/Jira: RadioListTile Deprecation Cleanup (RadioGroup Migration)
- Mistake pattern (exact): Initial RadioGroup migration used a nullable callback assignment pattern that violated the framework's non-null callback type contract.
- Root cause: Assumed nullable callback parity with old `RadioListTile.onChanged` behavior.
- Prevention rules (min 3):
  1. Check exact callback signatures when migrating from deprecated to replacement widgets.
  2. Keep disabled-state checks inside callback bodies when the new API requires non-null callbacks.
  3. Run analyzer immediately after framework migration edits before test execution.
- Validation on next similar task: Applied by switching to non-null callback with in-body guards, then rerunning analyze/tests.
- Outcome: Deprecation suppressions removed and both analyzer/tests are green.

- Date: 2026-04-11
- Task/Jira: Repository Compatibility Cleanup + ApiService Smoke Test
- Mistake pattern (exact): Seed-account creation path used `UserModel.passwordHash` through a legacy compatibility insert path, risking hashed-password registration payloads.
- Root cause: Legacy compatibility wrapper masked password semantics after moving to API-only registration.
- Prevention rules (min 3):
  1. Avoid generic compatibility wrappers for auth-sensitive flows; keep plain vs hashed password semantics explicit.
  2. Require explicit `plainPassword` in registration helper methods and call sites.
  3. Add a small smoke test for shared auth/API primitives after refactoring repository contracts.
- Validation on next similar task: Applied by removing insert wrapper, updating caller signatures, and adding ApiService token lifecycle smoke test.
- Outcome: Cleaner repository contract with explicit registration semantics and green validation across both Flutter apps.

- Date: 2026-04-11
- Task/Jira: Codebase Scan and API Service Optimization
- Mistake pattern (exact): Used `const Options(...)` in Dio request code where the package version only supports a non-const constructor.
- Root cause: Assumed constructor constness during a small refactor without checking the installed API surface.
- Prevention rules (min 3):
  1. Check the exact package API when introducing `const` in third-party types.
  2. Re-run analyzer immediately after refactors that touch framework or package constructors.
  3. Prefer small validation loops for maintainability-only changes, even when behavior should not change.
- Validation on next similar task: Applied by removing `const` and re-running root analyzer and tests.
- Outcome: Refactor kept, compile issue resolved, validation returned clean.

## Weekly Metrics
- Week of:
- Mistake rate (%):
- Plan accuracy (%):
- Avg bug fix time:
- Elegance self-score (/10):
- Actions if mistake rate >5%:
  - Pause new tasks
  - Review lessons
  - Self-quiz until >=90% on prevention rules

---

- Date: 2026-03-15
- Task/Jira: Roadmap Alignment Sprint 4 (Certifications Module)
- Mistake pattern (exact): Bracket mismatch in `resume_screen.dart` row children caused parser errors during analyze.
- Root cause: Fast UI composition edit without a final structural scan around closing delimiters.
- Prevention rules (min 3):
  1. After any large widget-tree edit, run formatter immediately and inspect the modified region once.
  2. Keep each UI block change small (one widget section per patch) to reduce delimiter mistakes.
  3. Run analyzer after each file-level change, not only after a multi-file batch.
- Validation on next similar task: Applied — syntax issue fixed and analyzer rerun clean for edited files.
- Outcome: No remaining errors in changed certification/resume files.

- Date: 2026-03-15
- Task/Jira: UI/UX Theme Redesign Package
- Mistake pattern (exact): Introduced deprecated `withOpacity()` usage in newly edited theme/screens.
- Root cause: Reused older Flutter styling habits during rapid UI styling pass.
- Prevention rules (min 3):
  1. Prefer `withValues(alpha: ...)` for color alpha changes in new code.
  2. Run analyzer immediately after any visual/theming patch.
  3. Fix introduced warnings in changed files before moving to next feature.
- Validation on next similar task: Applied within this task; deprecated calls replaced in modified files.
- Outcome: Redesign files are analyzer-clean.

- Date: 2026-03-15
- Task/Jira: Sprint-2 Expansion Package
- Mistake pattern (exact): Widget smoke test failed because SplashScreen left a pending timer alive when the test tore down.
- Root cause: Test asserted initial mount but did not advance fake time to let startup timers and async init finish.
- Prevention rules (min 3):
  1. When a startup screen uses timers or delayed navigation, advance fake time in widget tests before teardown.
  2. Re-run automated tests after route/init changes even when the app builds cleanly.
  3. Treat pending timers in tests as lifecycle coverage gaps, not flaky noise.
- Validation on next similar task: Applied by pumping an additional 4 seconds in `test/widget_test.dart`.
- Outcome: `flutter test` passes again.

- Date: 2026-03-15
- Task/Jira: Student Academic Portfolio Sprint-2 Package
- Mistake pattern (exact): Incorrect Dart interpolation string in `auth_service.dart` (`'seed_$role_failed'`) caused a compile error.
- Root cause: Forgot to wrap interpolated value with braces when combining with a suffix.
- Prevention rules (min 3):
  1. For interpolations with suffixes/prefixes, always use `${...}` form.
  2. Run `get_errors` immediately after editing service/constants code.
  3. Add a quick scan for interpolation tokens before running analyzer/build.
- Validation on next similar task: Applied immediately by changing to `'seed_${role}_failed'` and rechecking errors.
- Outcome: Compile errors resolved; no remaining errors in workspace diagnostics.

- Date: 2026-03-15
- Task/Jira: Student Academic Portfolio Sprint-2 Package
- Mistake pattern (exact): First `flutter build apk --debug` failed due to a transient Gradle daemon crash.
- Root cause: Gradle daemon instability on the host environment, not source-level compile issues.
- Prevention rules (min 3):
  1. Retry failed Gradle builds once before assuming source regression.
  2. Capture daemon log pointer in notes for postmortem traceability.
  3. Report both first-failure and retry-success outcomes in evidence.
- Validation on next similar task: Applied; second build attempt succeeded and produced debug APK.
- Outcome: Build validation completed successfully with transparent incident reporting.

- Date: 2026-03-15
- Task/Jira: Proposal Alignment (Achievements + Admin Monitoring)
- Mistake pattern (exact): Relied on generic unit-test runner output first, which returned no executed Flutter tests.
- Root cause: Tooling mismatch for Flutter widget/integration test discovery in this workspace.
- Prevention rules (min 3):
  1. When test output is ambiguous (0 passed / 0 failed), immediately run `flutter test` for authoritative Flutter results.
  2. Record both attempted and authoritative validation paths in evidence.
  3. Treat zero-test output as a signal to verify test runner compatibility before closing a task.
- Validation on next similar task: Applied immediately by running `flutter test` after ambiguous output.
- Outcome: Confirmed regression-safe state with `All tests passed!`.

- Date: 2026-03-16
- Task/Jira: Proposal Scope Alignment Delta (Roles/Naming/Achievements)
- Mistake pattern (exact): Risk of overwriting collaborator/tool edits when continuing work on previously changed files.
- Root cause: Continuing implementation without first reconciling latest external edits can introduce accidental regressions.
- Prevention rules (min 3):
  1. Re-read externally changed files in full before applying new patches.
  2. Keep deltas focused and minimal when touching files with recent outside modifications.
  3. Run analyzer + tests + build immediately after reconciliation edits.
- Validation on next similar task: Applied by re-reading `resume_screen.dart`, `admin_dashboard_screen.dart`, and `student_achievements_repository.dart` before patching.
- Outcome: Changes applied safely with no diagnostics errors and successful test/build verification.

- Date: 2026-03-16
- Task/Jira: Full Rewrite Program — Phase 1 (Essays Module)
- Mistake pattern (exact): Initial attempt used `Consumer7`, which is not provided by `provider` package and caused compile failure.
- Root cause: Assumed higher-arity consumer widget existed instead of composing with available `Consumer` variants.
- Prevention rules (min 3):
  1. Verify widget/library API limits before increasing generic arity in state-consumer widgets.
  2. Prefer `context.watch<T>()` inside an existing consumer builder when exceeding supported arity.
  3. Run analyzer immediately after state-management wiring changes before proceeding to more edits.
- Validation on next similar task: Applied immediately by replacing `Consumer7` with `Consumer6` + `context.watch<StudentEssaysProvider>()`.
- Outcome: Compile issue resolved; tests and APK build passed.
