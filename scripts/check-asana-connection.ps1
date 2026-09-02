# Nemesis Project — Asana Connectivity Check
# Verifies that all Asana requirements are met and connection works

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Asana Connectivity Check" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Get the directory where this script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$venvPath = Join-Path $projectRoot "venv"
$pythonExe = Join-Path $venvPath "Scripts\python.exe"

# Check 1: Virtual environment exists
Write-Host "Check 1: Virtual environment..." -ForegroundColor Yellow
if (Test-Path $venvPath) {
    Write-Host "✓ Virtual environment found at: $venvPath" -ForegroundColor Green
} else {
    Write-Host "ERROR: Virtual environment not found at: $venvPath" -ForegroundColor Red
    Write-Host "Run 1-SETUP-INFRASTRUCTURE.bat first" -ForegroundColor Yellow
    pause
    exit 1
}

# Check 2: Python executable exists
Write-Host ""
Write-Host "Check 2: Python executable..." -ForegroundColor Yellow
if (Test-Path $pythonExe) {
    Write-Host "✓ Python found at: $pythonExe" -ForegroundColor Green
} else {
    Write-Host "ERROR: Python executable not found" -ForegroundColor Red
    pause
    exit 1
}

# Check 3: Required packages installed
Write-Host ""
Write-Host "Check 3: Required Python packages..." -ForegroundColor Yellow
& $pythonExe -c "
import sys
packages = ['requests', 'fuzzywuzzy', 'dotenv']
missing = []
for pkg in packages:
    try:
        __import__(pkg.replace('-', '_'))
        print(f'  ✓ {pkg}')
    except ImportError:
        missing.append(pkg)
        print(f'  ✗ {pkg} (MISSING)')

if missing:
    print(f'ERROR: Missing packages: {missing}')
    sys.exit(1)
"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Some packages are missing" -ForegroundColor Red
    Write-Host "Run 1-SETUP-INFRASTRUCTURE.bat again" -ForegroundColor Yellow
    pause
    exit 1
}

# Check 4: .env file exists
Write-Host ""
Write-Host "Check 4: Configuration files..." -ForegroundColor Yellow
$projectFolder = Split-Path -Parent $projectRoot
$envFile = Join-Path $projectFolder ".env"

if (-not (Test-Path $envFile)) {
    Write-Host "✗ .env file not found at: $envFile" -ForegroundColor Yellow
    Write-Host "  (This is OK if you haven't created a project yet)" -ForegroundColor Gray
    Write-Host "  Run 2-CREATE-PROJECT.bat to create a project and .env file" -ForegroundColor Yellow
} else {
    Write-Host "✓ .env file found" -ForegroundColor Green

    # Check 5: ASANA_PAT is set
    Write-Host ""
    Write-Host "Check 5: ASANA_PAT in .env..." -ForegroundColor Yellow
    $envContent = Get-Content $envFile -Raw
    if ($envContent -match "ASANA_PAT\s*=\s*(\S+)") {
        $token = $matches[1]
        if ($token -and $token.Length -gt 10) {
            Write-Host "✓ ASANA_PAT is set (${token.Length} characters)" -ForegroundColor Green

            # Check 6: Test Asana API connection
            Write-Host ""
            Write-Host "Check 6: Testing Asana API connection..." -ForegroundColor Yellow
            & $pythonExe -c "
import os
from dotenv import load_dotenv
import requests

# Load .env
load_dotenv('$envFile')
token = os.getenv('ASANA_PAT')

if not token:
    print('ERROR: ASANA_PAT not loaded from .env')
    exit(1)

# Test API call
headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

try:
    response = requests.get(
        'https://app.asana.com/api/1.0/users/me',
        headers=headers,
        timeout=10
    )

    if response.status_code == 200:
        user = response.json().get('data', {})
        name = user.get('name', 'User')
        print(f'✓ Asana connection successful!')
        print(f'✓ Authenticated as: {name}')
    elif response.status_code == 401:
        print('ERROR: Invalid or expired ASANA_PAT')
        print('Get a new token: https://app.asana.com/-/profile_options/apps')
        exit(1)
    else:
        print(f'ERROR: Asana API returned {response.status_code}')
        print(f'Response: {response.text}')
        exit(1)

except requests.exceptions.ConnectionError:
    print('ERROR: Cannot connect to Asana (network error)')
    exit(1)
except Exception as e:
    print(f'ERROR: {e}')
    exit(1)
"
            if ($LASTEXITCODE -ne 0) {
                Write-Host "✗ Asana API test failed (see error above)" -ForegroundColor Red
                Write-Host ""
                Write-Host "Troubleshooting:" -ForegroundColor Yellow
                Write-Host "  1. Verify your ASANA_PAT is correct" -ForegroundColor Gray
                Write-Host "  2. Get a new token: https://app.asana.com/-/profile_options/apps" -ForegroundColor Gray
                Write-Host "  3. Update .env and try again" -ForegroundColor Gray
                pause
                exit 1
            }
        } else {
            Write-Host "✗ ASANA_PAT is empty or invalid" -ForegroundColor Red
            Write-Host "Get a new token: https://app.asana.com/-/profile_options/apps" -ForegroundColor Yellow
            pause
            exit 1
        }
    } else {
        Write-Host "✗ ASANA_PAT not found in .env" -ForegroundColor Red
        Write-Host "Add it manually or run 2-CREATE-PROJECT.bat" -ForegroundColor Yellow
        pause
        exit 1
    }
}

# Success
Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "✓ All Asana requirements met!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "You're ready to use Nemesis Project!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Drop notes into: c:\Repo\Projects\Project-<Client>\Phase <N>\08 - Meeting Notes\" -ForegroundColor Gray
Write-Host "  2. Save the file" -ForegroundColor Gray
Write-Host "  3. Changes sync to Asana automatically!" -ForegroundColor Gray
Write-Host ""

pause
