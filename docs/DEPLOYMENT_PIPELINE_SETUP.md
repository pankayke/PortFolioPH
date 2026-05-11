# Deployment Pipeline Setup

This repository includes two GitHub Actions workflows:

- CI: `.github/workflows/ci.yml`
- Deployment: `.github/workflows/deploy.yml`
- Manual Rollback: `.github/workflows/rollback.yml`
- Runtime Smoke: `.github/workflows/runtime-smoke.yml`

Use this guide to finish setup for staging and production.

## 1. Create GitHub Environments

In your GitHub repository:

1. Go to **Settings > Environments**.
2. Create environment `staging`.
3. Create environment `production`.

Recommended protection rules:

- `staging`: optional reviewer (or none for rapid feedback).
- `production`: required reviewers, and optionally restrict branch to `main`.

## 2. Add Environment Secrets

Add these secrets to both `staging` and `production` environments.

Required:

- `DEPLOY_HOST`: server hostname or IP.
- `DEPLOY_USER`: SSH username.
- `DEPLOY_PATH`: absolute deployment path on server.
- `DEPLOY_SSH_PRIVATE_KEY`: private key content used by GitHub Action.

Runtime smoke secrets (per environment):

- `SMOKE_BASE_URL`: for example `https://staging.example.com`

Admin runtime smoke secrets (required only when running admin smoke):

- `ADMIN_SMOKE_EMAIL`
- `ADMIN_SMOKE_PASSWORD`

Optional (recommended):

- `DEPLOY_HEALTHCHECK_URL`: URL checked post-deploy, for example `https://your-host/health`.
- `DEPLOY_BACKUP_RETENTION`: number of pre-deploy backups to keep (default handled in workflow docs/process).

## 3. Prepare Target Server

On each target server:

1. Install Docker and Docker Compose plugin.
2. Ensure deploy user can run Docker commands.
3. Create deployment path and clone/sync baseline if needed.
4. Ensure `.env.docker` exists at `DEPLOY_PATH` with environment-appropriate values.

Example:

```bash
mkdir -p /opt/portfolioph
cd /opt/portfolioph
# place .env.docker with production/staging values
```

## 4. Trigger Modes

### Auto staging deployment

- Trigger: successful completion of `Full Codebase CI` on `develop`.
- Target: `staging`.
- Reference: commit SHA from the CI run.

### Manual deployment

From **Actions > Deployment Pipeline > Run workflow**:

Inputs:

- `target_environment`: `staging` or `production`
- `deploy_ref`: branch, tag, or SHA
- `run_migrations`: `true`/`false`
- `enforce_healthcheck`: `true`/`false`

Production policy enforced in workflow:

- `production` deploys accept only `main` or a tag ref (`refs/tags/...`).

### Manual rollback

From **Actions > Manual Rollback Pipeline > Run workflow**:

Inputs:

- `target_environment`: `staging` or `production`
- `backup_selector`: `latest` or a specific backup file name
- `verify_healthcheck`: `true`/`false`

Rollback source:

- Backups are read from `DEPLOY_PATH/.deploy-backups/predeploy-*.tar.gz`.

### Runtime smoke tests

From **Actions > Runtime Smoke Tests > Run workflow**:

Inputs:

- `target_environment`: `staging` or `production`
- `run_admin_smoke`: `true`/`false`

Checks performed:

- Seeker/recruiter registration and role-guard smoke via `scripts/e2e_role_smoke.ps1`
- Admin export/auth smoke via `scripts/e2e_admin_smoke.ps1` (when enabled)

Credential handling note:

- `e2e_admin_smoke.ps1` prefers `ADMIN_SMOKE_PASSWORD` environment variable in CI, and also supports `-AdminPasswordSecure` for local/manual runs.

Schedule:

- Nightly at `02:30 UTC` targeting `staging` environment.

Artifacts:

- `runtime-smoke-role.json`
- `runtime-smoke-admin.json` (when admin smoke is enabled)

Note:

- `e2e_role_smoke.ps1` supports `-RunAdminProbe` and defaults to `false` to reduce rate-limit pressure during routine smoke runs.
- Full CI now includes PowerShell script syntax + Pester validation in `.github/workflows/ci.yml`.

## 5. What Deployment Does

1. Checks out selected ref.
2. Validates required secrets.
3. Connects over SSH.
4. Uploads release archive.
5. Extracts release on server.
6. Validates `docker compose` config.
7. Runs `docker compose up -d --build`.
8. Optionally runs Laravel migrations.
9. Optionally verifies health endpoint.
10. If deployment fails, automatically restores the latest pre-deploy snapshot and restarts services.
11. Cleans temporary release archive.

## 6. Rollback Model

- Every deployment creates a server snapshot in `.deploy-backups/predeploy-<timestamp>.tar.gz`.
- If deploy, migration, or health check fails, workflow automatically restores this snapshot.
- Rollback restores files and reruns `docker compose up -d --build`.
- Database rollback is not automatic; use migration rollback strategy separately when required.

## 7. First Run Checklist

- CI is green on selected ref.
- `DEPLOY_PATH/.env.docker` is correct.
- Host has enough disk space for Docker image rebuild.
- Health endpoint returns HTTP 200.
- Production environment has reviewer approval enabled.

## 8. Troubleshooting

- Missing secret failure: verify environment secret names exactly match workflow.
- SSH failures: verify host key, user permissions, and private key format.
- Docker permission errors: add deploy user to `docker` group or use rootless setup.
- Migration failures: run `docker compose exec -T api php artisan migrate --force` manually on server to inspect details.
- Rollback backup not found: list files in `DEPLOY_PATH/.deploy-backups` and retry with an exact `backup_selector` name.
