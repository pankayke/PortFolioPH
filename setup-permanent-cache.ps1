# ============================================================================
# Permanent Flutter Package Cache Setup Script (PowerShell)
# Run this once to ensure all Flutter packages are cached permanently
# ============================================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Flutter Permanent Cache Setup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$CACHE_PATH = "$env:USERPROFILE\.flutter_pub_cache"

# Step 1: Create cache directory
Write-Host "[1/4] Creating cache directory..." -ForegroundColor Yellow
if (!(Test-Path $CACHE_PATH)) {
    New-Item -ItemType Directory -Path $CACHE_PATH -Force | Out-Null
    Write-Host "   ✓ Directory created: $CACHE_PATH" -ForegroundColor Green
} else {
    Write-Host "   ✓ Directory already exists: $CACHE_PATH" -ForegroundColor Green
}

# Step 2: Set environment variable
Write-Host ""
Write-Host "[2/4] Setting PUB_CACHE environment variable..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable('PUB_CACHE', $CACHE_PATH, 'User')
Write-Host "   ✓ Set PUB_CACHE=$CACHE_PATH" -ForegroundColor Green

# Step 3: Verify environment variable
Write-Host ""
Write-Host "[3/4] Verifying environment variable..." -ForegroundColor Yellow
$CURRENT_CACHE = $env:PUB_CACHE
if ($CURRENT_CACHE -eq $CACHE_PATH) {
    Write-Host "   ✓ Environment variable is correctly set" -ForegroundColor Green
} else {
    Write-Host "   ! Note: Environment variable may need terminal restart to take effect" -ForegroundColor Yellow
}

# Step 4: Cache info
Write-Host ""
Write-Host "[4/4] Cache information:" -ForegroundColor Yellow
if (Test-Path $CACHE_PATH) {
    Write-Host "   ✓ Cache path exists: $CACHE_PATH" -ForegroundColor Green
    
    # Count items in cache
    $itemCount = @(Get-ChildItem $CACHE_PATH -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host "   ✓ Items in cache: $itemCount" -ForegroundColor Green
    
    # Calculate cache size
    $cacheSize = (Get-ChildItem $CACHE_PATH -Recurse | Measure-Object -Property Length -Sum).Sum
    $cacheSizeGB = [math]::Round($cacheSize / 1GB, 2)
    Write-Host "   ✓ Cache size: $cacheSizeGB GB" -ForegroundColor Green
}

# Summary
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your Flutter package cache is now permanent:" -ForegroundColor Green
Write-Host "  Location: $CACHE_PATH"
Write-Host "  Variable: PUB_CACHE"
Write-Host ""
Write-Host "For future Flutter projects:" -ForegroundColor Cyan
Write-Host "  1. Create new project: flutter create my_app"
Write-Host "  2. Get dependencies: flutter pub get"
Write-Host "  3. Run: flutter run"
Write-Host ""
Write-Host "All packages will be instantly cached! ⚡" -ForegroundColor Green
Write-Host ""
Write-Host "NOTE: If environment variable doesn't show immediately," -ForegroundColor Yellow
Write-Host "      restart your terminal/IDE and it will work." -ForegroundColor Yellow
Write-Host ""

# Offer to open the guide
$response = Read-Host "Would you like to open the cache guide? (y/n)"
if ($response -eq 'y' -or $response -eq 'Y') {
    if (Test-Path "c:\Users\USER\portfolioph\PERMANENT_CACHE_GUIDE.md") {
        Start-Process "c:\Users\USER\portfolioph\PERMANENT_CACHE_GUIDE.md"
    }
}
