param(
    [string]$BaseUrl = 'http://localhost:8000',
    [string]$AdminEmail = $env:ADMIN_SMOKE_EMAIL,
    [securestring]$AdminPasswordSecure,
    [int]$MaxRetries = 3
)

$ErrorActionPreference = 'Stop'

Set-Location (Join-Path $PSScriptRoot '..')
. (Join-Path $PSScriptRoot 'lib\url_normalization.ps1')

. (Join-Path $PSScriptRoot 'lib\http_helpers.ps1')

function ConvertFrom-SecureStringToPlainText {
    param(
        [Parameter(Mandatory = $true)][securestring]$SecureString
    )

    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

$adminPassword = $null
if ($PSBoundParameters.ContainsKey('AdminPasswordSecure')) {
    $adminPassword = ConvertFrom-SecureStringToPlainText -SecureString $AdminPasswordSecure
} elseif (-not [string]::IsNullOrWhiteSpace($env:ADMIN_SMOKE_PASSWORD)) {
    $adminPassword = $env:ADMIN_SMOKE_PASSWORD
}

if ([string]::IsNullOrWhiteSpace($AdminEmail) -or [string]::IsNullOrWhiteSpace($adminPassword)) {
    throw 'Admin smoke requires AdminEmail/AdminPassword (or ADMIN_SMOKE_EMAIL/ADMIN_SMOKE_PASSWORD env vars).'
}

$base = Normalize-ApiRootUrl -Url $BaseUrl
$apiBase = "$base/api"

$results = [ordered]@{}

$login = Invoke-JsonPostWithRetry -Url "$apiBase/auth/login" -MaxRetries $MaxRetries -Body @{ email = $AdminEmail; password = $adminPassword }
$token = $login.data.token
$results['admin_login_success'] = ([bool]$login.success -and -not [string]::IsNullOrWhiteSpace($token))

$headers = @{ Authorization = "Bearer $token" }

$usersExportStatus = Invoke-StatusGetWithRetry -Url "$apiBase/admin/users/export/csv" -Headers $headers -MaxRetries $MaxRetries
$jobsExportStatus = Invoke-StatusGetWithRetry -Url "$apiBase/admin/jobs/export/csv" -Headers $headers -MaxRetries $MaxRetries

$results['admin_users_export_status'] = $usersExportStatus
$results['admin_jobs_export_status'] = $jobsExportStatus
$results['admin_exports_accessible'] = ($usersExportStatus -eq 200 -and $jobsExportStatus -eq 200)

$adminWebStatus = Invoke-StatusGetWithRetry -Url "$base/admin/dashboard" -NoRedirect -MaxRetries $MaxRetries
$results['admin_web_unauth_guard_status'] = $adminWebStatus
$results['admin_web_unauth_guard_works'] = ($adminWebStatus -eq 302)

$results['base_url'] = $base

$results | ConvertTo-Json -Depth 10
