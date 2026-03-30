@echo off
REM ============================================================================
REM  Permanent Flutter Package Cache Setup Script
REM  Run this once to ensure all Flutter packages are cached permanently
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ============================================
echo  Flutter Permanent Cache Setup
echo ============================================
echo.

REM Set cache path
set "CACHE_PATH=%USERPROFILE%\.flutter_pub_cache"

REM 1. Create cache directory if it doesn't exist
echo [1/4] Creating cache directory...
if not exist "%CACHE_PATH%" (
    mkdir "%CACHE_PATH%"
    echo   ✓ Directory created: %CACHE_PATH%
) else (
    echo   ✓ Directory already exists: %CACHE_PATH%
)

REM 2. Set environment variable
echo.
echo [2/4] Setting PUB_CACHE environment variable...
setx PUB_CACHE "%CACHE_PATH%" >nul
echo   ✓ Set PUB_CACHE=%CACHE_PATH%

REM 3. Verify environment variable
echo.
echo [3/4] Verifying environment variable...
set "CURRENT_CACHE=%PUB_CACHE%"
if "%CURRENT_CACHE%"=="%CACHE_PATH%" (
    echo   ✓ Environment variable is correctly set
) else (
    echo   ! Environment variable may need restart to take effect
)

REM 4. Cache info
echo.
echo [4/4] Cache information:
if exist "%CACHE_PATH%" (
    echo   ✓ Cache path exists: %CACHE_PATH%
    
    REM Count directories in cache
    for /f "delims=" %%i in ('dir "%CACHE_PATH%" /s /b /a:d ^| find /c /v ""') do (
        set "DIR_COUNT=%%i"
    )
    echo   ✓ Cache directories: !DIR_COUNT!
)

REM 5. Summary
echo.
echo ============================================
echo  Setup Complete!
echo ============================================
echo.
echo Your Flutter package cache is now permanent:
echo   Location: %CACHE_PATH%
echo   Variable: PUB_CACHE
echo.
echo For future Flutter projects:
echo   1. Create new project: flutter create my_app
echo   2. Get dependencies: flutter pub get
echo   3. Run: flutter run
echo.
echo All packages will be instantly cached! ⚡
echo.
echo NOTE: If environment variable doesn't show immediately,
echo       restart your terminal/IDE and it will work.
echo.
pause
