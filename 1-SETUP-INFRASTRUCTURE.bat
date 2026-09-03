@echo off
REM Nemesis Project — Email Integration Setup
REM Double-click this file to run setup (checks Python, creates venv, installs email dependencies)

setlocal enabledelayedexpansion

REM Get the directory where this batch file is located
set SCRIPT_DIR=%~dp0

REM Change to that directory
cd /d "%SCRIPT_DIR%"

REM Check if PowerShell is available
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: PowerShell not found on your system
    echo Please install PowerShell or ensure it's in your PATH
    pause
    exit /b 1
)

REM Run the setup script
echo.
echo ============================================================
echo  Nemesis Project — Email Integration Setup
echo ============================================================
echo.
echo Starting setup script...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "& '.\scripts\setup-infrastructure.ps1'"

if %errorlevel% equ 0 (
    echo.
    echo ============================================================
    echo  Setup Complete!
    echo ============================================================
    echo.
    echo Next step: Double-click "2-CREATE-PROJECT.bat"
    echo.
) else (
    echo.
    echo ============================================================
    echo  Setup Failed!
    echo ============================================================
    echo.
    echo Check the error message above and try again.
    echo See docs/TROUBLESHOOTING.md for help.
    echo.
)

pause
