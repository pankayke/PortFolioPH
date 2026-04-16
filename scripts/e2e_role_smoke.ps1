param(
    [string]$BaseUrl = 'http://localhost:8000/api',
    [int]$MaxRetries = 3,
    [bool]$RunAdminProbe = $false
)

$ErrorActionPreference = 'Stop'

Set-Location (Join-Path $PSScriptRoot '..')
. (Join-Path $PSScriptRoot 'lib\http_helpers.ps1')

$base = $BaseUrl.TrimEnd('/')
$ts = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$recruiterEmail = "recruiter_$ts@example.com"
$seekerEmail = "seeker_$ts@example.com"
$adminProbeEmail = "adminprobe_$ts@example.com"
$testPassword = 'Passw0rd!123'

$results = [ordered]@{}

# Register recruiter
$recReg = Invoke-JsonPostWithRetry -Url "$base/auth/register" -MaxRetries $MaxRetries -Body @{
    name     = 'Rec Test'
    username = "recruiter_$ts"
    email    = $recruiterEmail
    password = $testPassword
    role     = 'recruiter'
}
$results['register_recruiter_success'] = [bool]$recReg.success

# Register seeker
$seekReg = Invoke-JsonPostWithRetry -Url "$base/auth/register" -MaxRetries $MaxRetries -Body @{
    name     = 'Seek Test'
    username = "seeker_$ts"
    email    = $seekerEmail
    password = $testPassword
    role     = 'job_seeker'
}
$results['register_seeker_success'] = [bool]$seekReg.success

if ($RunAdminProbe) {
    $adminProbeAllowed = $true
    try {
        $adminProbe = Invoke-JsonPostWithRetry -Url "$base/auth/register" -MaxRetries $MaxRetries -Body @{
            name     = 'Admin Probe'
            username = "adminprobe_$ts"
            email    = $adminProbeEmail
            password = $testPassword
            role     = 'admin'
        }
        $adminProbeAllowed = [bool]$adminProbe.success
    } catch {
        $adminProbeAllowed = $false
    }
    $results['admin_self_register_allowed'] = $adminProbeAllowed
}

$recToken = $recReg.data.token
$seekToken = $seekReg.data.token

$results['login_recruiter_success'] = -not [string]::IsNullOrWhiteSpace($recToken)
$results['login_seeker_success'] = -not [string]::IsNullOrWhiteSpace($seekToken)

$recHeaders = @{ Authorization = "Bearer $recToken" }
$seekHeaders = @{ Authorization = "Bearer $seekToken" }

# Recruiter creates a job
$jobCreate = Invoke-JsonPostWithRetry -Url "$base/jobs" -Headers $recHeaders -MaxRetries $MaxRetries -Body @{
    title       = 'E2E QA Job'
    description = 'End to end verification job posting for smoke test.'
    location    = 'Manila'
    job_type    = 'full_time'
    salary_min  = 25000
    salary_max  = 40000
}
$jobId = $jobCreate.data.id
$results['create_job_as_recruiter_success'] = ([bool]$jobCreate.success -and $null -ne $jobId)

# Seeker applies to job
$apply = Invoke-JsonPostWithRetry -Url "$base/applications" -Headers $seekHeaders -MaxRetries $MaxRetries -Body @{
    job_id       = $jobId
    cover_letter = 'Applying from smoke test.'
}
$results['apply_as_seeker_success'] = [bool]$apply.success

$applicationId = $apply.data.id

# Seeker lists own applications
$seekApps = Invoke-JsonGetWithRetry -Url "$base/applications" -Headers $seekHeaders -MaxRetries $MaxRetries
$results['seeker_list_applications_success'] = [bool]$seekApps.success

if ($null -eq $applicationId -and $seekApps -and $seekApps.data) {
    $match = @($seekApps.data | Where-Object { $_.job_id -eq $jobId } | Select-Object -First 1)
    if ($match.Count -gt 0) {
        $applicationId = $match[0].id
    }
}

# Recruiter updates application status and seeker sees the update
$results['recruiter_update_application_status_success'] = $false
$results['seeker_sees_updated_application_status'] = $false
if ($null -ne $applicationId) {
    $statusUpdate = Invoke-JsonPutWithRetry -Url "$base/applications/$applicationId/status" -Headers $recHeaders -MaxRetries $MaxRetries -Body @{ status = 'reviewed' }
    $results['recruiter_update_application_status_success'] = [bool]$statusUpdate.success

    $seekAppsAfterUpdate = Invoke-JsonGetWithRetry -Url "$base/applications" -Headers $seekHeaders -MaxRetries $MaxRetries
    if ($seekAppsAfterUpdate.success -and $seekAppsAfterUpdate.data) {
        $updated = @($seekAppsAfterUpdate.data | Where-Object { $_.id -eq $applicationId } | Select-Object -First 1)
        if ($updated.Count -gt 0) {
            $results['seeker_sees_updated_application_status'] = ($updated[0].status -eq 'reviewed')
        }
    }
}

# Recruiter dashboard access
$dash = Invoke-JsonGetWithRetry -Url "$base/recruiter/dashboard" -Headers $recHeaders -MaxRetries $MaxRetries
$results['recruiter_dashboard_success'] = [bool]$dash.success

# Negative check: seeker cannot create job
$seekerCreateJobAllowed = $true
try {
    $null = Invoke-JsonPostWithRetry -Url "$base/jobs" -Headers $seekHeaders -MaxRetries $MaxRetries -Body @{
        title       = 'Bad job'
        description = 'Should fail for seeker'
        location    = 'Nowhere'
        job_type    = 'full_time'
    }
} catch {
    $seekerCreateJobAllowed = $false
}
$results['seeker_can_create_job'] = $seekerCreateJobAllowed

# Negative check: unauthenticated recruiter dashboard access
$unauthDashboardAllowed = $true
try {
    $null = Invoke-JsonGetWithRetry -Url "$base/recruiter/dashboard" -MaxRetries $MaxRetries
} catch {
    $unauthDashboardAllowed = $false
}
$results['unauth_can_access_recruiter_dashboard'] = $unauthDashboardAllowed

$results['base_url'] = $base

$results | ConvertTo-Json -Depth 10
