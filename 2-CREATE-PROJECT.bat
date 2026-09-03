@echo off
REM Nemesis Project — Create New Client Project
REM Double-click this file to create a new client project (e.g., Project-TWG)

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

REM Run the create project script
echo.
echo ============================================================
echo  Create New Client Project
echo ============================================================
echo.
echo Starting project creation script...
echo.
echo You will be prompted for:
echo   - Client Name (e.g., TWG, BDT, Acme)
echo   - Phase Number (1, 2, 3, etc.)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "& '.\scripts\create-new-project.ps1'"

if %errorlevel% equ 0 (
    echo.
    echo ============================================================
    echo  Project Created Successfully!
    echo ============================================================
    echo.
    echo Your project is ready to use. Start in Claude Code with:
    echo   New session meeting notes ^<ClientName^>
    echo.
    echo Files will be created automatically in:
    echo   %SCRIPT_DIR%..\Projects\Project-^<ClientName^>\Phase ^<N^>\08 - Meeting Notes\
    echo.
) else (
    echo.
    echo ============================================================
    echo  Project Creation Failed!
    echo ============================================================
    echo.
    echo Check the error message above and try again.
    echo See docs/TROUBLESHOOTING.md for help.
    echo.
)

pause
