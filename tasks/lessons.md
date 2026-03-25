# Lessons Log (Mandatory)

> Log every correction, failed attempt, or preventable defect.

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

---

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
