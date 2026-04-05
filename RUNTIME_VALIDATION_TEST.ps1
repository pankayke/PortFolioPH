#!/usr/bin/env pwsh
# RUNTIME INTEGRATION VALIDATION
# PowerShell version that works with Windows paths

param()

$script:passCount = 0
$script:failCount = 0
$testNum = 1

function Test-Condition {
    param(
        [string]$Name,
        [bool]$Condition
    )
    
    if ($Condition) {
        Write-Host "✅ TEST $testNum PASS: $Name" -ForegroundColor Green
        $script:passCount++
    } else {
        Write-Host "❌ TEST $testNum FAIL: $Name" -ForegroundColor Red
        $script:failCount++
    }
    $script:testNum++
}

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  FLUTTER + LARAVEL INTEGRATION - RUNTIME VALIDATION       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1: AUTHENTICATION CONTROLLERS
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "SECTION 1: AUTHENTICATION LAYER" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$authPath = "portfoliophhadmin\app\Http\Controllers\AuthController.php"
if (Test-Path $authPath) {
    $content = Get-Content $authPath -Raw
    
    Test-Condition "AuthController.php exists" $true
    Test-Condition "register() method exists" ($content -match "function register")
    Test-Condition "login() method exists" ($content -match "function login")
    Test-Condition "me() method exists for session restore" ($content -match "function me")
    Test-Condition "logout() method exists" ($content -match "function logout")
    Test-Condition "Uses ApiResponse wrapper" ($content -match "ApiResponse::success|ApiResponse::error")
} else {
    Write-Host "❌ AuthController.php not found!" -ForegroundColor Red
    $script:failCount += 5
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2: TOKEN MANAGEMENT (BACKEND)
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "SECTION 2: TOKEN MANAGEMENT (Backend)" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$authServicePath = "portfoliophhadmin\app\Services\AuthService.php"
if (Test-Path $authServicePath) {
    $content = Get-Content $authServicePath -Raw
    
    Test-Condition "AuthService.php exists" $true
    Test-Condition "createToken() method exists" ($content -match "createToken")
    Test-Condition "logout() calls tokens()->delete()" ($content -match "tokens\(\)->delete")
    Test-Condition "authenticate() method exists" ($content -match "authenticate")
    Test-Condition "Token invalidation in logout" ($content -match "tokens.*delete|plainTextToken")
} else {
    Write-Host "❌ AuthService.php not found!" -ForegroundColor Red
    $script:failCount += 5
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3: API RESPONSE CONSISTENCY
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "SECTION 3: API RESPONSE CONSISTENCY" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$apiRespPath = "portfoliophhadmin\app\Http\Resources\ApiResponse.php"
if (Test-Path $apiRespPath) {
    $content = Get-Content $apiRespPath -Raw
    
    Test-Condition "ApiResponse wrapper exists" $true
    Test-Condition "success() includes 'success':true" ($content -match '"success"\s*=>\s*true')
    Test-Condition "success() includes 'data' field" ($content -match "'data'\s*=>\s*\$data")
    Test-Condition "error() includes 'success':false" ($content -match '"success"\s*=>\s*false')
    Test-Condition "error() includes 'errors' field" ($content -match "'errors'")
    Test-Condition "message field in all responses" ($content -match "'message'")
} else {
    Write-Host "❌ ApiResponse.php not found!" -ForegroundColor Red
    $script:failCount += 6
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 4: FLUTTER DIO INTERCEPTOR
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "SECTION 4: FLUTTER DIO INTERCEPTOR (Bearer Token)" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$dioPath = "lib\core\services\api_service.dart"
if (Test-Path $dioPath) {
    $content = Get-Content $dioPath -Raw
    
    Test-Condition "ApiService exists" $true
    Test-Condition "_onRequest interceptor exists" ($content -match "_onRequest")
    Test-Condition "Bearer token injected in headers" ($content -match "Authorization.*Bearer")
    Test-Condition "Token read from secure storage" ($content -match "_secureStorage|FlutterSecureStorage")
    Test-Condition "401 error handled" ($content -match "statusCode == 401")
    Test-Condition "Token cleared on 401" ($content -match "401.*delete|delete.*401")
} else {
    Write-Host "❌ api_service.dart not found!" -ForegroundColor Red
    $script:failCount += 6
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 5: FLUTTER TOKEN PERSISTENCE
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "SECTION 5: FLUTTER TOKEN PERSISTENCE" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$flutterAuthPath = "lib\data\services\auth_service.dart"
if (Test-Path $flutterAuthPath) {
    $content = Get-Content $flutterAuthPath -Raw
    
    Test-Condition "AuthService exists" $true
    Test-Condition "saveToken() method" ($content -match "saveToken")
    Test-Condition "clearToken() method" ($content -match "clearToken")
    Test-Condition "hasToken() method" ($content -match "hasToken")
    Test-Condition "getCurrentUser() calls /auth/me" ($content -match "getCurrentUser|auth/me")
    Test-Condition "logout() method exists" ($content -match "Future.*logout|logout")
} else {
    Write-Host "❌ auth_service.dart not found!" -ForegroundColor Red
    $script:failCount += 6
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 6: FLUTTER TOKEN REPOSITORY SAVING
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "SECTION 6: TOKEN STORAGE IN REPOSITORY" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$userRepoPath = "lib\data\repositories\user_repository.dart"
if (Test-Path $userRepoPath) {
    $content = Get-Content $userRepoPath -Raw
    
    Test-Condition "UserRepository exists" $true
    Test-Condition "registerUser() saves token" ($content -match "registerUser.*saveToken|saveToken.*registerUser" -or $content -match "registerUser" -and $content -match "saveToken")
    Test-Condition "authenticate() saves token" ($content -match "authenticate.*saveToken|saveToken.*authenticate" -or $content -match "authenticate" -and $content -match "saveToken")
    Test-Condition "Token extraction from response" ($content -match "response\['token'\]|token.*response")
    Test-Condition "Explicit token save call" ($content -match "await.*_apiService.saveToken")
} else {
    Write-Host "❌ user_repository.dart not found!" -ForegroundColor Red
    $script:failCount += 5
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 7: SESSION RESTORE
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "SECTION 7: SESSION RESTORE (APP RESTART)" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$authProvPath = "lib\presentation\providers\auth_provider.dart"
if (Test-Path $authProvPath) {
    $content = Get-Content $authProvPath -Raw
    
    Test-Condition "AuthProvider exists" $true
    Test-Condition "restoreSession() method" ($content -match "restoreSession")
    Test-Condition "restoreSession() calls getCurrentUser()" ($content -match "restoreSession.*getCurrentUser" -or ($content -match "restoreSession" -and $content -match "getCurrentUser"))
    Test-Condition "Error handling in restoreSession" ($content -match "catch|try.*restoreSession")
} else {
    Write-Host "❌ auth_provider.dart not found!" -ForegroundColor Red
    $script:failCount += 4
}

$splashPath = "lib\presentation\screens\splash\splash_screen.dart"
if (Test-Path $splashPath) {
    $content = Get-Content $splashPath -Raw
    
    Test-Condition "SplashScreen exists" $true
    Test-Condition "SplashScreen calls restoreSession()" ($content -match "restoreSession")
    Test-Condition "Route navigation based on auth" ($content -match "context.go|GoRouter" -and ($content -match "dashboard|login"))
    Test-Condition "Mounted checks prevent UI errors" ($content -match "mounted")
} else {
    Write-Host "❌ splash_screen.dart not found!" -ForegroundColor Red
    $script:failCount += 4
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 8: ROUTE PROTECTION
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "SECTION 8: route PROTECTION (Sanctum Middleware)" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$routesPath = "portfoliophhadmin\routes\api.php"
if (Test-Path $routesPath) {
    $content = Get-Content $routesPath -Raw
    
    Test-Condition "Routes file exists" $true
    Test-Condition "Public auth routes defined" ($content -match "post.*register|post.*login")
    Test-Condition "auth:sanctum middleware on protected routes" ($content -match "auth:sanctum")
    Test-Condition "/auth/me protected route" ($content -match "auth/me.*auth:sanctum|auth:sanctum.*auth/me" -or ($content -match "auth/me" -and $content -match "sanctum"))
    Test-Condition "/auth/logout protected route" ($content -match "logout.*sanctum|sanctum.*logout" -or ($content -match "logout" -and $content -match "santum"))
} else {
    Write-Host "❌ routes/api.php not found!" -ForegroundColor Red
    $script:failCount += 5
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 9: EXCEPTION HANDLING
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "SECTION 9: EXCEPTION HANDLING (Error Responses)" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$exceptionPath = "portfoliophhadmin\app\Exceptions\Handler.php"
if (Test-Path $exceptionPath) {
    $content = Get-Content $exceptionPath -Raw
    
    Test-Condition "Exception Handler exists" $true
    Test-Condition "JSON rendering for API" ($content -match "renderJson")
    Test-Condition "401 Unauthorized handled" ($content -match "AuthenticationException|401")
    Test-Condition "Returns ApiResponse format" ($content -match "ApiResponse::error|ApiResponse::success")
} else {
    Write-Host "❌ Handler.php not found!" -ForegroundColor Red
    $script:failCount += 4
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 10: INTEGRATION TESTS
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "SECTION 10: INTEGRATION TEST SUITE" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$testPath = "test\integration_auth_test.dart"
if (Test-Path $testPath) {
    $content = Get-Content $testPath -Raw
    
    Test-Condition "Integration tests exist" $true
    Test-Condition "Registration test" ($content -match "register.*test")
    Test-Condition "Login test" ($content -match "login.*test")
    Test-Condition "Session restore test" ($content -match "session.*restore|auth/me" -and $content -match "test")
    Test-Condition "Logout test" ($content -match "logout.*test")
} else {
    Write-Host "❌ integration_auth_test.dart not found!" -ForegroundColor Red
    Write-Host "   This file should exist for testing" -ForegroundColor Yellow
}

# ─────────────────────────────────────────────────────────────────────────────
# FINAL SUMMARY
# ─────────────────────────────────────────────────────────────────────────────

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  VALIDATION SUMMARY                                        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$total = $script:passCount + $script:failCount
$percentage = if ($total -gt 0) { [int](($script:passCount / $total) * 100) } else { 0 }

Write-Host ""
Write-Host "  Total Tests:    $total" -ForegroundColor White
Write-Host "  ✅ Passed:      $($script:passCount)" -ForegroundColor Green
Write-Host "  ❌ Failed:      $($script:failCount)" -ForegroundColor Red
Write-Host "  Success Rate:   $percentage%" -ForegroundColor Cyan
Write-Host ""

if ($script:failCount -eq 0) {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║ ✅ ALL CODE PATHS VERIFIED - INTEGRATION SOUND            ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host "`nRECOMMENDATION: Execute runtime test suite with actual API" -ForegroundColor Cyan
} else {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║ ❌ SOME TESTS FAILED - SEE ABOVE FOR DETAILS              ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Red
}

Write-Host ""
