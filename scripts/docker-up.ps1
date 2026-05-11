param(
    [switch]$NoBuild,
    [switch]$FollowLogs
)

$ErrorActionPreference = 'Stop'

Set-Location (Join-Path $PSScriptRoot '..')
$envFile = '.env.docker'

if (-not (Test-Path $envFile)) {
    throw "Missing $envFile. Create it before running Docker stack."
}

Write-Host 'Starting PortfolioPH Docker stack...' -ForegroundColor Cyan

Write-Host 'Pre-pulling base images...' -ForegroundColor Cyan
$baseImages = @(
    'debian:bookworm-slim',
    'nginx:1.28-alpine',
    'php:8.3-fpm-bookworm',
    'composer:latest'
)

foreach ($image in $baseImages) {
    docker pull $image
}

if ($NoBuild) {
    docker compose --env-file $envFile up -d
} else {
    docker compose --env-file $envFile up -d --build
}

Write-Host ''
Write-Host 'Container status:' -ForegroundColor Green
docker compose ps

Write-Host ''
Write-Host 'URLs:' -ForegroundColor Green
Write-Host 'Frontend:   http://localhost:3000'
Write-Host 'API:        http://localhost:8000'
Write-Host 'phpMyAdmin: http://localhost:8080'
Write-Host 'Mailpit:    http://localhost:8025'
Write-Host 'MySQL host: localhost:3307'

if ($FollowLogs) {
    Write-Host ''
    Write-Host 'Following logs (Ctrl+C to stop)...' -ForegroundColor Yellow
    docker compose --env-file $envFile logs -f
}
