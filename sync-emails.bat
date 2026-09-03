@echo off
REM Nemesis Project — Email to Notes Sync
REM Run from anywhere: sync-emails.bat

setlocal enabledelayedexpansion

REM NemesisProject root
set PROJECT_ROOT=C:\Repo\NemesisProject

REM Venv path
set VENV_PATH=%PROJECT_ROOT%\venv

REM Script path
set SCRIPT_PATH=%PROJECT_ROOT%\email-integration\sync-emails.py

REM Check if venv exists
if not exist "%VENV_PATH%" (
    echo ERROR: Virtual environment not found
    echo Run: C:\Repo\NemesisProject\1-SETUP-INFRASTRUCTURE.bat first
    pause
    exit /b 1
)

REM Check if script exists
if not exist "%SCRIPT_PATH%" (
    echo ERROR: Script not found at: %SCRIPT_PATH%
    pause
    exit /b 1
)

REM Activate venv and run script
call "%VENV_PATH%\Scripts\activate.bat"
cd /d "%PROJECT_ROOT%\email-integration"
python sync-emails.py

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Sync failed with error code %errorlevel%
    pause
    exit /b 1
)

pause
