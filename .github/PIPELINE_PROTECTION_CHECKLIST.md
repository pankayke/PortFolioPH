# Pipeline Protection Checklist

Use this checklist in GitHub repository settings to enforce production-grade CI/CD protections.

## Branch Protection

Configure branch protection for `main` and `develop`.

- Require pull request before merging
- Require approvals (recommended: at least 1 for develop, at least 2 for main)
- Dismiss stale approvals when new commits are pushed
- Require status checks to pass before merging
- Require conversation resolution before merging
- Restrict force pushes and branch deletion

Recommended required checks:

- Full Codebase CI / Docker Compose Validation
- Full Codebase CI / PowerShell Script Quality Gates
- Full Codebase CI / Root App Quality Gates
- Full Codebase CI / Mobile Module Quality Gates
- Full Codebase CI / Laravel Backend Quality Gates

## Environment Protection Rules

Create/verify environment rules in `Settings -> Environments`.

### staging

- Optional required reviewers
- Environment secrets configured:
  - `DEPLOY_HOST`
  - `DEPLOY_USER`
  - `DEPLOY_PATH`
  - `DEPLOY_SSH_PRIVATE_KEY`
  - `DEPLOY_HEALTHCHECK_URL`
  - `SMOKE_BASE_URL`
  - `ADMIN_SMOKE_EMAIL`
  - `ADMIN_SMOKE_PASSWORD`

### production

- Required reviewers enabled
- Deployment branch policy enabled (limit to `main`/tags)
- Optional wait timer (5-15 minutes)
- Environment secrets configured separately from staging

## Repository Rulesets (Optional but Recommended)

If rulesets are enabled, add:

- Rule: no direct pushes to `main`
- Rule: require PR and required checks for `main`
- Rule: block bypass except admin/maintainers

## Token and Permissions Hygiene

- Keep workflow permissions minimal (`contents: read` unless write is needed)
- Use environment-scoped secrets for deploy/smoke credentials
- Rotate deploy SSH keys periodically

## Deployment Workflow Safeguards Already in Code

Current workflow safeguards:

- Production deployments require `main` or tag refs in [deploy.yml](workflows/deploy.yml)
- Production deployments require manual `production_confirmation=DEPLOY_PRODUCTION` in [deploy.yml](workflows/deploy.yml)
- Automatic deploy path only targets staging after successful CI on develop in [deploy.yml](workflows/deploy.yml)
- Runtime smoke can auto-run after successful deploy completion in [runtime-smoke.yml](workflows/runtime-smoke.yml)
- Rollback workflow available in [rollback.yml](workflows/rollback.yml)

## Post-Setup Verification

After settings are applied:

1. Open a test PR to `develop` and verify required checks block merge until green.
2. Trigger manual staging deploy and confirm smoke artifacts are uploaded.
3. Trigger manual production deploy without confirmation and verify it fails.
4. Trigger manual production deploy with confirmation and required reviewer approval and verify success.
