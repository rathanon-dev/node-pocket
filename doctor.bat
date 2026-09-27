@echo off
chcp 65001 >nul
echo =====================================================
echo   🩺 NODE-POCKET SYSTEM DOCTOR
echo   Checking your machine for required tools...
echo =====================================================
echo.

set PASS=0
set FAIL=0

:: Check Node.js
where node >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('node -v') do echo   ✅ Node.js: %%i
    set /a PASS+=1
) else (
    echo   ❌ Node.js: NOT FOUND — Install from https://nodejs.org
    set /a FAIL+=1
)

:: Check Deno
where deno >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('deno --version 2^>nul ^| findstr /i "deno"') do echo   ✅ Deno: %%i
    set /a PASS+=1
) else (
    echo   ❌ Deno: NOT FOUND
    echo      Install: winget install DenoLand.Deno
    echo      Or download: https://deno.land/#installation
    set /a FAIL+=1
)

:: Check Git
where git >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('git --version') do echo   ✅ Git: %%i
    set /a PASS+=1
    
    :: Check if repository is initialized
    if not exist "%~dp0.git" (
        echo      ℹ️  Initializing local git repository...
        git -C "%~dp0" init -q
        git -C "%~dp0" config user.name "AI Auto-Snapshot" 2>nul
        git -C "%~dp0" config user.email "local@node-pocket.internal" 2>nul
        git -C "%~dp0" add -A
        git -C "%~dp0" commit -m "init: baseline repository initialized by doctor" -q 2>nul
        echo      ✅ Local git repository initialized!
    ) else (
        echo   ✅ Git Repository: Active (.git present)
    )
) else (
    echo   ❌ Git: NOT FOUND — Install from https://git-scm.com
    set /a FAIL+=1
)

:: Check Python (optional)
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('python -V 2^>^&1') do echo   ✅ Python: %%i (optional)
    set /a PASS+=1
) else (
    echo   ⚠️  Python: NOT FOUND (optional, not required)
)

echo.
echo =====================================================
echo   Results: %PASS% passed, %FAIL% failed
echo =====================================================

if %FAIL% GTR 0 (
    echo.
    echo   ⚠️  Some tools are missing. Install them before proceeding.
) else (
    echo.
    echo   🎉 All required tools are installed! You're ready to go.
)

echo.
pause
