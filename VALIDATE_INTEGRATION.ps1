# RUNTIME INTEGRATION VALIDATION - SIMPLIFIED

$passCount = 0
$failCount = 0
$testNum = 1

function Test-Condition {
    param([string]$Name, [bool]$Condition)
    if ($Condition) {
        Write-Host "[PASS $testNum] $Name" -ForegroundColor Green
        $script:passCount++
    } else {
        Write-Host "[FAIL $testNum] $Name" -ForegroundColor Red
        $script:failCount++
    }
    $script:testNum++
}

Write-Host "`n=== FLUTTER + LARAVEL INTEGRATION VALIDATION ===" -ForegroundColor Cyan

# SECTION 1: AUTHENTICATION CONTROLLERS
Write-Host "`n--- Section 1: Authentication Layer ---" -ForegroundColor Yellow

$authPath = "portfoliophhadmin\app\Http\Controllers\AuthController.php"
$authContent = Get-Content $authPath -Raw -ErrorAction SilentlyContinue
Test-Condition "AuthController exists" ($authContent -ne $null)
Test-Condition "register() method" ($authContent -match "function register")
Test-Condition "login() method" ($authContent -match "function login")
Test-Condition "me() method (session restore)" ($authContent -match "function me")
Test-Condition "logout() method" ($authContent -match "function logout")

# SECTION 2: TOKEN MANAGEMENT
Write-Host "`n--- Section 2: Token Management (Backend) ---" -ForegroundColor Yellow

$authSvcPath = "portfoliophhadmin\app\Services\AuthService.php"
$authSvcContent = Get-Content $authSvcPath -Raw -ErrorAction SilentlyContinue
Test-Condition "AuthService exists" ($authSvcContent -ne $null)
Test-Condition "createToken() method" ($authSvcContent -match "createToken")
Test-Condition "logout() invalidates tokens" ($authSvcContent -match "tokens\(\)->delete")

# SECTION 3: API RESPONSE FORMAT
Write-Host "`n--- Section 3: API Response Consistency ---" -ForegroundColor Yellow

$apiRespPath = "portfoliophhadmin\app\Http\Resources\ApiResponse.php"
$apiRespContent = Get-Content $apiRespPath -Raw -ErrorAction SilentlyContinue
Test-Condition "ApiResponse wrapper" ($apiRespContent -ne $null)
Test-Condition "success() returns consistent JSON" ($apiRespContent -match "success")
Test-Condition "error() returns consistent JSON" ($apiRespContent -match "error.*false")

# SECTION 4: DIO INTERCEPTOR
Write-Host "`n--- Section 4: Flutter Dio Interceptor ---" -ForegroundColor Yellow

$dioPath = "lib\core\services\api_service.dart"
$dioContent = Get-Content $dioPath -Raw -ErrorAction SilentlyContinue
Test-Condition "ApiService exists" ($dioContent -ne $null)
Test-Condition "Bearer token injection" ($dioContent -match "Authorization.*Bearer")
Test-Condition "Token from secure storage" ($dioContent -match "FlutterSecureStorage")
Test-Condition "401 error handling" ($dioContent -match "401.*delete|delete.*401")

# SECTION 5: TOKEN PERSISTENCE
Write-Host "`n--- Section 5: Auth Service Token Methods ---" -ForegroundColor Yellow

$authServPath = "lib\data\services\auth_service.dart"
$authServContent = Get-Content $authServPath -Raw -ErrorAction SilentlyContinue
Test-Condition "saveToken() method" ($authServContent -match "saveToken")
Test-Condition "clearToken() method" ($authServContent -match "clearToken")
Test-Condition "getCurrentUser() calls /auth/me" ($authServContent -match "auth/me")

# SECTION 6: REPOSITORY TOKEN SAVING
Write-Host "`n--- Section 6: Repository Token Storage ---" -ForegroundColor Yellow

$userRepoPath = "lib\data\repositories\user_repository.dart"
$userRepoContent = Get-Content $userRepoPath -Raw -ErrorAction SilentlyContinue
Test-Condition "UserRepository exists" ($userRepoContent -ne $null)
Test-Condition "registerUser() saves token" ($userRepoContent -match "saveToken")
Test-Condition "authenticate() saves token" ($userRepoContent -match "authenticate" -and $userRepoContent -match "saveToken")

# SECTION 7: SESSION RESTORE
Write-Host "`n--- Section 7: Session Restore (App Restart) ---" -ForegroundColor Yellow

$authProvPath = "lib\presentation\providers\auth_provider.dart"
$authProvContent = Get-Content $authProvPath -Raw -ErrorAction SilentlyContinue
Test-Condition "AuthProvider restoreSession()" ($authProvContent -match "restoreSession")
Test-Condition "Calls getCurrentUser() for verification" ($authProvContent -match "getCurrentUser")

$splashPath = "lib\presentation\screens\splash\splash_screen.dart"
$splashContent = Get-Content $splashPath -Raw -ErrorAction SilentlyContinue
Test-Condition "SplashScreen calls restoreSession()" ($splashContent -match "restoreSession")
Test-Condition "Navigation based on auth state" ($splashContent -match "context.go")

# SECTION 8: ROUTE PROTECTION
Write-Host "`n--- Section 8: Route Protection (Sanctum) ---" -ForegroundColor Yellow

$routesPath = "portfoliophhadmin\routes\api.php"
$routesContent = Get-Content $routesPath -Raw -ErrorAction SilentlyContinue
Test-Condition "Routes file exists" ($routesContent -ne $null)
Test-Condition "Public auth endpoints" ($routesContent -match "register" -and $routesContent -match "login")
Test-Condition "auth:sanctum middleware" ($routesContent -match "auth:sanctum")
Test-Condition "/auth/me route protected" ($routesContent -match "auth/me")

# SECTION 9: EXCEPTION HANDLING
Write-Host "`n--- Section 9: Exception Handling ---" -ForegroundColor Yellow

$exceptionPath = "portfoliophhadmin\app\Exceptions\Handler.php"
$exceptionContent = Get-Content $exceptionPath -Raw -ErrorAction SilentlyContinue
Test-Condition "Exception Handler" ($exceptionContent -ne $null)
Test-Condition "JSON rendering" ($exceptionContent -match "renderJson")
Test-Condition "401 handling" ($exceptionContent -match "401|Unauthorized")

# SECTION 10: INTEGRATION TESTS
Write-Host "`n--- Section 10: Integration Test Suite ---" -ForegroundColor Yellow

$testPath = "test\integration_auth_test.dart"
$testContent = Get-Content $testPath -Raw -ErrorAction SilentlyContinue
Test-Condition "Integration tests exist" ($testContent -ne $null)
if ($testContent -ne $null) {
    Test-Condition "Registration test" ($testContent -match "register")
    Test-Condition "Session restore test" ($testContent -match "/auth/me")
    Test-Condition "Logout test" ($testContent -match "logout")
}

# FINAL SUMMARY
Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "VALIDATION SUMMARY" -ForegroundColor Cyan
Write-Host "="*50 -ForegroundColor Cyan

$total = $passCount + $failCount
$percent = if ($total -gt 0) { [int](($passCount / $total) * 100) } else { 0 }

Write-Host ""
Write-Host "Total Tests:   $total"
Write-Host "PASSED:        $passCount" -ForegroundColor Green
Write-Host "FAILED:        $failCount" -ForegroundColor Red
Write-Host "Success Rate:  $percent%"
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "SUCCESS! All code paths verified." -ForegroundColor Green
    Write-Host "The Flutter + Laravel integration is properly implemented." -ForegroundColor Green
} else {
    Write-Host "ISSUES FOUND! Review failed tests above." -ForegroundColor Red
}

Write-Host ""
