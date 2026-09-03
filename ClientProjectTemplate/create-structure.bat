@echo off
REM Nemesis Project — Client Project Template Deployment
REM Called from create-new-project.ps1

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "& '.\scripts\create-structure.ps1' -ClientName '%1' -PhaseNumber '%2' -FolderPattern '%3'"

if %errorlevel% neq 0 (
    echo ERROR: Failed to create project structure
    exit /b 1
)

exit /b 0
