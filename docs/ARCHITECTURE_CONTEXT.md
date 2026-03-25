# PortFolioPH Architecture Context

## Scope
PortFolioPH is an offline-first Flutter client (`portfolioph`) paired with a Laravel 12 backend/admin (`portfolioph_admin`).

- Flutter: Provider + GoRouter + SQLite (`sqflite`) + SharedPreferences
- Laravel: Sanctum auth, service/repository layering, MySQL, Dockerized runtime

## Stabilization Roadmap
1. **Phase 0 – Immediate Fixes**
   - Resolve Flutter compile/analyzer blockers
   - Harden Docker images and runtime posture
2. **Phase 1 – Quality Gate**
   - Enforce clean analyzer/lint/build
3. **Phase 2 – Testing Ramp-Up**
   - Add meaningful PHPUnit + Flutter widget/integration tests
4. **Phase 3 – Security & Hardening**
   - Runtime hardening, production settings, rate limits
5. **Phase 4 – Production Readiness**
   - Hybrid offline sync strategy + CI/CD + monitoring

## Phase 0 Delivered (2026-03-25)

### Flutter compile blocker fixes
Updated:
- `lib/core/constants/app_constants.dart`
- `lib/presentation/screens/auth/login_screen_new.dart`
- `lib/presentation/screens/auth/register_screen_new.dart`
- `lib/presentation/widgets/glass/glass_button.dart`
- `lib/presentation/widgets/glass/glass_input_field.dart`

Changes:
- Added missing shared text tokens:
  - `AppConstants.textPrimary`
  - `AppConstants.textSecondary`
- Replaced unsupported `Color.withLightness(...)` calls with compatible interpolation:
  - `Color.lerp(AppConstants.primaryColor, Colors.white, 0.22)!`

Result:
- Workspace diagnostics for `portfolioph` report no compile errors on changed files.

### Docker hardening changes
Updated:
- `portfolioph_admin/Dockerfile`
- `portfolioph/Dockerfile`
- `portfolioph/docker-compose.yml`
- `portfolioph/nginx.conf`
- `OneDrive/Desktop/laundry_shop/Dockerfile`

Changes (high level):
- Moved admin PHP image to Alpine and split runtime/build deps for extension builds
- Added package upgrades and cleanup of temporary build dependencies
- Set non-root runtime for Flutter web nginx image (`USER nginx`)
- Moved Flutter nginx listen/compose mapping to port `8080` for non-root serving
- Updated `laundry_shop` multi-stage image tags + package upgrade step

## Verification Evidence
- Flutter focused test: `test/widget_test.dart` → passed (1/1)
- Diagnostics:
  - `portfolioph` changed Flutter files: no compile errors
  - Docker scanners still report upstream base-image CVEs (see "Known Risks")

## Known Risks / Remaining Work
- Base-image vulnerability findings remain for Node/Composer/PHP/Nginx/Debian images.
- Some are inherited from upstream images and cannot be fully eliminated without:
  - digest pinning + regular rebuild cadence,
  - narrower runtime images,
  - optional migration to distroless or Chainguard-style images where compatible,
  - CI vulnerability budget + fail thresholds.

## Next Suggested Steps
- Phase 1: run full lint/analyzer/build gates in both repositories and clear warning debt in active files.
- Phase 2: add first meaningful test slices:
  - Laravel: auth/register/login + portfolio API feature tests
  - Flutter: auth flow and dashboard smoke + provider unit tests
