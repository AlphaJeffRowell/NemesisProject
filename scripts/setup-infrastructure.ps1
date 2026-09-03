# Nemesis Project — Email Integration Setup
# Run this ONCE on your machine to set up Python and email dependencies

param(
    [switch]$SkipVenv = $false
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Nemesis Project — Email Integration Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Python
Write-Host "Step 1: Checking Python installation..." -ForegroundColor Yellow
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Python not found on your system" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Installing Python 3.11+ automatically..." -ForegroundColor Cyan

    # Try winget first
    $wingetCheck = where.exe winget 2>$null
    if ($wingetCheck) {
        Write-Host "Using winget to install Python..." -ForegroundColor Gray
        winget install -e --id Python.Python.3.11 -h
        if ($LASTEXITCODE -ne 0) {
            Write-Host "WARNING: winget install failed, trying chocolatey..." -ForegroundColor Yellow
        }
    } else {
        # Try chocolatey
        $chocoCheck = where.exe choco 2>$null
        if ($chocoCheck) {
            Write-Host "Using chocolatey to install Python..." -ForegroundColor Gray
            choco install python311 -y
            if ($LASTEXITCODE -ne 0) {
                Write-Host "ERROR: chocolatey install failed" -ForegroundColor Red
                Write-Host "Install Python manually from: https://www.python.org/downloads/" -ForegroundColor Yellow
                exit 1
            }
        } else {
            Write-Host "ERROR: Neither winget nor chocolatey found" -ForegroundColor Red
            Write-Host "Install Python manually from: https://www.python.org/downloads/" -ForegroundColor Yellow
            Write-Host "Ensure you check 'Add Python to PATH' during installation" -ForegroundColor Yellow
            exit 1
        }
    }

    Write-Host "Refreshing PATH and verifying Python..." -ForegroundColor Gray
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Python still not found after install" -ForegroundColor Red
        Write-Host "Try restarting your terminal or computer, then run this script again" -ForegroundColor Yellow
        exit 1
    }
}

$version = $pythonVersion -replace "Python ", ""
Write-Host "✓ Found: $pythonVersion" -ForegroundColor Green

# Step 2: Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$venvPath = Join-Path $projectRoot "venv"

Write-Host ""
Write-Host "Step 2: Setting up Python virtual environment..." -ForegroundColor Yellow
Write-Host "Location: $venvPath" -ForegroundColor Gray

# Step 3: Create virtual environment if it doesn't exist
if (-not (Test-Path $venvPath)) {
    Write-Host "Creating virtual environment..." -ForegroundColor Gray
    python -m venv $venvPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to create virtual environment" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Virtual environment created" -ForegroundColor Green
} else {
    Write-Host "✓ Virtual environment already exists" -ForegroundColor Green
}

# Step 4: Activate virtual environment
Write-Host ""
Write-Host "Step 3: Installing Python dependencies..." -ForegroundColor Yellow
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
& $activateScript

# Step 5: Upgrade pip
Write-Host "Upgrading pip..." -ForegroundColor Gray
python -m pip install --upgrade pip -q
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Failed to upgrade pip (continuing anyway)" -ForegroundColor Yellow
}

# Step 6: Install requirements
$requirementsFile = Join-Path $projectRoot "requirements.txt"
Write-Host "Installing requirements from: $requirementsFile" -ForegroundColor Gray
pip install -r $requirementsFile
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install requirements" -ForegroundColor Red
    exit 1
}
Write-Host "✓ All dependencies installed" -ForegroundColor Green

# Step 7: Verify installation
Write-Host ""
Write-Host "Step 4: Verifying installation..." -ForegroundColor Yellow
& "$venvPath\Scripts\python.exe" -c 'import fuzzywuzzy; import requests; print("All imports successful")'
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Import verification failed" -ForegroundColor Red
    exit 1
}

# Step 8: Success
Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "✓ Setup Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Double-click: 2-CREATE-PROJECT.bat" -ForegroundColor Gray
Write-Host "2. Follow prompts to create a new client project" -ForegroundColor Gray
Write-Host "3. (Optional) Use sync-emails.bat to import meeting notes from email" -ForegroundColor Gray
Write-Host "4. Type naturally in Claude Code to create notes and sync to Asana" -ForegroundColor Gray
Write-Host ""
Write-Host "Your virtual environment is at: $venvPath" -ForegroundColor Gray
Write-Host "Activate it manually with: $activateScript" -ForegroundColor Gray
