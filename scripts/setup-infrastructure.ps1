# Nemesis Project — One-Time Infrastructure Setup
# Run this ONCE on your machine to set up Python, dependencies, and virtual environment

param(
    [switch]$SkipVenv = $false
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Nemesis Project — Infrastructure Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Python
Write-Host "Step 1: Checking Python installation..." -ForegroundColor Yellow
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Python not found on your system" -ForegroundColor Red
    Write-Host "Please install Python 3.7+ from: https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "Make sure to check 'Add Python to PATH' during installation" -ForegroundColor Yellow
    exit 1
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
Write-Host "1. Run: .\scripts\create-new-project.ps1" -ForegroundColor Gray
Write-Host "2. Follow the prompts to create a new client project" -ForegroundColor Gray
Write-Host "3. Start writing notes in Claude Code" -ForegroundColor Gray
Write-Host ""
Write-Host "Your virtual environment is at: $venvPath" -ForegroundColor Gray
Write-Host "Activate it manually with: $activateScript" -ForegroundColor Gray
