# PR: Optimize auth/job flows and harden runtime validation

## Title
Optimize auth/job flows and harden runtime validation

## Base/Head
- Base: main
- Head: develop

## Summary
This PR delivers security, performance, and stability improvements across Flutter mobile, core API client behavior, recruiter approval UI reuse, and Laravel password-reset delivery.

## What changed
- Removed demo credentials from mobile login UI.
- Added mobile auth session restoration and startup route initialization gating.
- Added jobs/detail caching controls with force-refresh support on retry/refresh paths.
- Refactored mobile service/repository request boilerplate for maintainability.
- Reworked core retry interceptor to reuse a dedicated Dio client (no per-retry client recreation).
- Implemented production password-reset token email dispatch in Laravel controller.
- Extracted shared recruiter approval detail row widget to remove duplicated UI logic.
- Hardened runtime validation script checks and added integration auth marker tests.

## Validation evidence
- flutter analyze mobile-jobs/lib: passed
- flutter analyze lib: passed
- php -l portfoliophhadmin/app/Http/Controllers/AuthController.php: passed
- pwsh -File RUNTIME_VALIDATION_TEST.ps1: 100% pass
- flutter test test/integration_auth_test.dart: passed
- Live API smoke test on local Laravel server:
  - health: 200
  - register: success
  - auth/me with bearer: success
  - password-reset request: success (+ reset_token in local env)
  - password-reset confirm: success
  - relogin with new password: success

## Risk and rollout notes
- Existing repository contains unrelated dirty files not part of this PR scope.
- Changes are isolated to auth/job flows, API service resilience, recruiter approval UI, and validation harness.
- No API contract-breaking changes introduced.
