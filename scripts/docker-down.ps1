$ErrorActionPreference = 'Stop'

Set-Location (Join-Path $PSScriptRoot '..')
$envFile = '.env.docker'

Write-Host 'Stopping PortfolioPH Docker stack...' -ForegroundColor Cyan
if (Test-Path $envFile) {
	docker compose --env-file $envFile down
} else {
	docker compose down
}

Write-Host 'Done.' -ForegroundColor Green
