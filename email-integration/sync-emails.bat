@echo off
REM Nemesis Project — Email to Notes Sync
REM Activates venv and runs Python script

setlocal enabledelayedexpansion

REM Get the directory where this batch file is located
set SCRIPT_DIR=%~dp0

REM Get parent directory (NemesisProject root)
for %%I in ("%SCRIPT_DIR%..") do set PROJECT_ROOT=%%~fI

REM Venv path
set VENV_PATH=%PROJECT_ROOT%\venv

REM Check if venv exists
if not exist "%VENV_PATH%" (
    echo ERROR: Virtual environment not found at: %VENV_PATH%
    echo Run 1-SETUP-INFRASTRUCTURE.bat first
    pause
    exit /b 1
)

REM Activate venv
call "%VENV_PATH%\Scripts\activate.bat"

REM Run the sync script
cd /d "%SCRIPT_DIR%"
python sync-emails.py

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Sync failed with error code %errorlevel%
    pause
    exit /b 1
)

pause
