@echo off
REM Nemesis Project — Check Asana MCP Connector
REM Double-click this file to verify Asana MCP connector is available

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

REM Run the connectivity check script
echo.
echo ============================================================
echo  Nemesis Project — Asana MCP Connector Check
echo ============================================================
echo.
echo Verifying Asana MCP connector is available...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "& '.\scripts\check-asana-mcp.ps1'"

if %errorlevel% equ 0 (
    echo.
    echo ============================================================
    echo  All Checks Passed!
    echo ============================================================
    echo.
) else (
    echo.
    echo ============================================================
    echo  Checks Failed!
    echo ============================================================
    echo.
    echo Review the errors above and try again.
    echo.
)

pause
