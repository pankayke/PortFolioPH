# Release Notes - 2026-04-12

## Summary
This release completes the end-to-end seeker, recruiter, and admin workflows for CV handling and data export.

## Highlights
- Added seeker CV upload flow and CV download actions.
- Added seeker saved jobs screen and dashboard integrations.
- Added recruiter ATS actions for candidate notes, interview scheduling, shortlist, and reject.
- Added recruiter candidate CV download action.
- Added admin export actions for users, jobs, and applications (CSV/XLSX).

## Backend Changes
- Added export classes:
  - `portfoliophhadmin/app/Exports/UsersExport.php`
  - `portfoliophhadmin/app/Exports/JobsExport.php`
  - `portfoliophhadmin/app/Exports/ApplicationsExport.php`
- Added export service:
  - `portfoliophhadmin/app/Services/ExportService.php`
- Added CV controller:
  - `portfoliophhadmin/app/Http/Controllers/CVController.php`
- Added/updated routes:
  - `portfoliophhadmin/routes/api.php`
  - `portfoliophhadmin/routes/web.php`

## Frontend Changes
- Added reusable download service/provider/widgets:
  - `lib/core/services/file_download_service.dart`
  - `lib/presentation/providers/file_download_provider.dart`
  - `lib/presentation/widgets/file_download_widgets.dart`
- Added seeker screens:
  - `lib/features/seeker/screens/profile/cv_upload_screen.dart`
  - `lib/features/seeker/screens/jobs/saved_jobs_screen.dart`
- Updated flow screens:
  - `lib/features/seeker/screens/dashboard/seeker_dashboard_screen.dart`
  - `lib/features/recruiter/screens/ats/applicant_tracking_screen.dart`
  - `lib/features/recruiter/screens/ats/candidate_profile_view.dart`
  - `lib/presentation/screens/admin/filament_admin_screen.dart`

## Validation
- Backend test suite: 78 passing tests, 309 assertions.
- Flutter test suite: 41 passing tests.
- Analyzer checks on updated files: clean.

## Commits Included
- `c99bcf4` feat(backend): add CV downloads, admin exports, and endpoint coverage tests
- `be1e02b` feat(flutter): complete seeker/recruiter flows with CV, saved jobs, ATS actions, and downloads
- `d703431` docs: align API paths and add implementation handoff references

## Repository Cleanup
- Removed stale remote branch `copilot/fix-claude-sonnet-4-6-issue`.
- Local `main` and `develop` confirmed up to date with origin.
