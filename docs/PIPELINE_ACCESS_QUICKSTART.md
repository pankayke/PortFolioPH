# Pipeline Access Quickstart

This repository already has a CI/CD pipeline configured via GitHub Actions:

- CI: .github/workflows/ci.yml
- Deploy: .github/workflows/deploy.yml
- Rollback: .github/workflows/rollback.yml
- Runtime smoke tests: .github/workflows/runtime-smoke.yml

## 1. Access the Pipeline

1. Open your repository on GitHub.
2. Click the Actions tab.
3. Select one of these workflows:
- Full Codebase CI
- Deployment Pipeline
- Manual Rollback Pipeline
- Runtime Smoke Pipeline

Direct URLs (replace owner/repo if needed):
- https://github.com/pankayke/PortFolioPH/actions/workflows/ci.yml
- https://github.com/pankayke/PortFolioPH/actions/workflows/deploy.yml
- https://github.com/pankayke/PortFolioPH/actions/workflows/rollback.yml
- https://github.com/pankayke/PortFolioPH/actions/workflows/runtime-smoke.yml

## 2. How It Triggers

### Full Codebase CI

Runs on:
- Push to main/develop
- Pull request to main/develop
- Manual trigger (Run workflow)

What it checks:
- Docker compose validation
- Flutter format/analyze/test (root app)
- Flutter format/analyze/test (mobile-jobs module)
- Laravel quality gates (Pint + php artisan test)
- PowerShell script checks + Pester tests

### Deployment Pipeline

Runs on:
- Manual trigger (workflow_dispatch)
- Automatically after successful Full Codebase CI on develop (staging flow)

Supports:
- staging and production deployment targets
- optional migration run
- optional health check
- rollback snapshot before deploy

### Manual Rollback Pipeline

Runs on:
- Manual trigger only

Supports:
- rollback to latest backup or selected backup file
- optional post-rollback health check

## 3. Required Secrets and Environments

Create GitHub Environments:
- staging
- production

For each environment, add secrets:
- DEPLOY_HOST
- DEPLOY_USER
- DEPLOY_PATH
- DEPLOY_SSH_PRIVATE_KEY
- DEPLOY_HEALTHCHECK_URL

Optional smoke test secrets (if runtime smoke uses auth flow):
- SMOKE_BASE_URL
- ADMIN_SMOKE_EMAIL
- ADMIN_SMOKE_PASSWORD

Tip:
- Configure production environment with required reviewers.
- Restrict production deploys to main/tags.

## 4. Run It Manually

### Run CI now

1. Actions -> Full Codebase CI
2. Click Run workflow
3. Pick branch (usually develop)
4. Run workflow

### Run deployment now

1. Actions -> Deployment Pipeline
2. Click Run workflow
3. Set inputs:
- target_environment: staging or production
- deploy_ref: branch/tag/SHA (for example develop or main)
- run_migrations: true or false
- enforce_healthcheck: true or false
4. If production, set production_confirmation to DEPLOY_PRODUCTION
5. Run workflow

### Run rollback now

1. Actions -> Manual Rollback Pipeline
2. Click Run workflow
3. Set target_environment
4. Set backup_selector (latest or specific predeploy file)
5. Run workflow

## 5. Protect Merges with Pipeline Checks

Set branch protection for main and develop:
- Require pull request before merge
- Require status checks to pass
- Require conversation resolution

Recommended required checks:
- Full Codebase CI / Docker Compose Validation
- Full Codebase CI / PowerShell Script Quality Gates
- Full Codebase CI / Root App Quality Gates
- Full Codebase CI / Mobile Module Quality Gates
- Full Codebase CI / Laravel Backend Quality Gates

See also: .github/PIPELINE_PROTECTION_CHECKLIST.md

## 6. Troubleshooting

- Workflow not visible:
  - Check that Actions are enabled in repo settings.
  - Check that the workflow file is on the selected branch.

- Deployment fails at secrets step:
  - Confirm all required environment secrets are set for the selected environment.

- CI fails in Flutter format step:
  - Run locally:
    - dart format lib test
    - flutter analyze
    - flutter test

- CI fails in Laravel tests:
  - Run locally from portfoliophhadmin:
    - composer install
    - php artisan test

- Production deploy blocked:
  - Ensure production_confirmation is exactly DEPLOY_PRODUCTION.
  - Ensure deploy_ref is main or a tag.

## 7. Recommended Daily Flow

1. Push feature branch.
2. Open PR into develop.
3. Wait for Full Codebase CI to pass.
4. Merge PR.
5. Let staging deploy run automatically (or run manually if needed).
6. Validate with Runtime Smoke Pipeline.
7. Promote to production via manual Deployment Pipeline.
