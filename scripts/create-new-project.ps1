# Nemesis Project — Create New Client Project
# Run this to set up a new client project with all necessary configuration

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Create New Client Project" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$Default = "",
        [switch]$IsSecret = $false
    )

    if ($Default) {
        $displayPrompt = "${Prompt} [${Default}]: "
    } else {
        $displayPrompt = "${Prompt}: "
    }

    if ($IsSecret) {
        $value = Read-Host $displayPrompt -AsSecureString
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUni($value))
    } else {
        $value = Read-Host $displayPrompt
        if ($value) {
            return $value
        } else {
            return $Default
        }
    }
}

Write-Host "Step 1: Client Code" -ForegroundColor Yellow
Write-Host ""

$clientName = Get-UserInput -Prompt "Client Code (e.g., TWG, BDT, Acme)" -Default "TestClient"
if (-not $clientName) {
    Write-Host "ERROR: Client name is required" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Phase Number" -ForegroundColor Yellow
Write-Host ""

$phaseNumber = Get-UserInput -Prompt "Phase Number (1, 2, 3, etc.)" -Default "1"
if (-not $phaseNumber -match '^\d+$') {
    Write-Host "ERROR: Phase must be a number" -ForegroundColor Red
    exit 1
}

$folderPattern = "08 - Meeting Notes"

$projectRoot = "c:\Repo\Projects\Project-$clientName"
$phaseFolder = Join-Path $projectRoot "Phase $phaseNumber"

# Check if folder structure already exists
if (Test-Path $phaseFolder) {
    Write-Host ""
    Write-Host "WARNING: Project folder already exists at: $phaseFolder" -ForegroundColor Yellow
    $response = Read-Host "Overwrite and recreate folder structure? (yes/no)"
    if ($response -ne "yes") {
        Write-Host "Cancelled. Folder not modified." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Write-Host "Step 3: Asana Project GID (optional)" -ForegroundColor Yellow
Write-Host ""

$asanaGID = Get-UserInput -Prompt "Asana Project GID (from URL, or press Enter to skip)" -Default ""
Write-Host "  (Asana GID: $asanaGID)" -ForegroundColor Gray

Write-Host ""
Write-Host "Step 4: Asana Personal Access Token (optional)" -ForegroundColor Yellow
Write-Host ""

$asanaPAT = Get-UserInput -Prompt "Your ASANA_PAT (or press Enter to skip)" -Default ""
Write-Host "  (Token provided: $(if ($asanaPAT) { 'yes' } else { 'no' }))" -ForegroundColor Gray

# Call ClientProjectTemplate to create folder structure and templates
Write-Host ""
Write-Host "Creating folder structure with templates..." -ForegroundColor Cyan

$clientProjectTemplatePath = "C:\Repo\NemesisProject\ClientProjectTemplate\create-structure.bat"
if (Test-Path $clientProjectTemplatePath) {
    & $clientProjectTemplatePath $clientName $phaseNumber $folderPattern $asanaGID $asanaPAT
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to create project structure" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "ERROR: ClientProjectTemplate not found at: $clientProjectTemplatePath" -ForegroundColor Red
    exit 1
}

$notesFolder = Join-Path $phaseFolder "08 - Meeting Notes"
$scriptsFolder = Join-Path $phaseFolder "scripts"

Write-Host ""
Write-Host "Step 5: Creating configuration files..." -ForegroundColor Yellow

$envFile = Join-Path $projectRoot ".env"
try {
    $envContent = "ASANA_PAT=$asanaPAT`n"
    Set-Content -Path $envFile -Value $envContent -Encoding UTF8
    Write-Host "[+] Created: .env" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create .env: $_" -ForegroundColor Red
    exit 1
}

$claudeFolder = Join-Path $projectRoot ".claude"
$settingsFile = Join-Path $claudeFolder "settings.json"

try {
    if (-not (Test-Path $claudeFolder)) {
        New-Item -ItemType Directory -Path $claudeFolder -Force | Out-Null
    }

    $nemesisScriptPath = "C:\Repo\NemesisProject\scripts\asana-sync-enhanced.py"
    $escapedPath = $nemesisScriptPath -replace '\\', '\\'

    $hookCommand = "python `"$nemesisScriptPath`" --no-prompt --project-gid $asanaGID"

    $settingsJson = @{
        version = "1.0"
        hooks = @(
            @{
                on = "file_write"
                match = "**/$folderPattern/**/*.md"
                run = $hookCommand
            }
        )
    } | ConvertTo-Json -Depth 10

    Set-Content -Path $settingsFile -Value $settingsJson -Encoding UTF8
    Write-Host "[+] Created: .claude/settings.json" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create settings.json: $_" -ForegroundColor Red
    exit 1
}

$gitignoreFile = Join-Path $projectRoot ".gitignore"
try {
    $gitignoreContent = ".env`nvenv/`n__pycache__/`n*.pyc`n.DS_Store`n"
    Set-Content -Path $gitignoreFile -Value $gitignoreContent -Encoding UTF8
    Write-Host "[+] Created: .gitignore" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create .gitignore: $_" -ForegroundColor Red
    exit 1
}

$projectReadmeFile = Join-Path $phaseFolder "README.md"
try {
    $readmeContent = @"
# Project-$clientName - Phase $phaseNumber

**Asana Project GID:** $asanaGID

## Getting Started

1. Drop meeting notes into: $notesFolder
2. Notes are automatically synced to Asana
3. Write naturally - auto-detection finds task references

## How Auto-Detection Works

### Automatic (No Special Syntax Required)
Bloomberg integration complete. Ready for production.
-> Auto-syncs to the Bloomberg task

### Explicit (Always Works)
@task search:"Task Name"
Your comment here.
-> Explicitly syncs to specified task

## File Location

All notes should go in: **08 - Meeting Notes**

Subfolders within are OK:
- 08 - Meeting Notes/Client Meetings/
- 08 - Meeting Notes/Internal/

## Manual Sync

If you want to sync without using hooks:

cd $projectRoot
python C:\Repo\NemesisProject\scripts\asana-sync-enhanced.py --dry-run

## Configuration

Your settings are stored in:
- .env - Your ASANA_PAT (never commit this)
- .claude/settings.json - Hook configuration

## Troubleshooting

Hook not firing?
- Save .claude/settings.json to re-enable

ASANA_PAT error?
- Check .env file has your token

Wrong task synced?
- Use explicit @task syntax for clarity

---

Ready to use. Start writing notes!
"@

    Set-Content -Path $projectReadmeFile -Value $readmeContent -Encoding UTF8
    Write-Host "[+] Created: Phase folder README" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create project README: $_" -ForegroundColor Red
    exit 1
}

$testNoteFile = Join-Path $notesFolder "Test_AutoDetect.md"
try {
    $testContent = @"
# Test Auto-Detection

This file tests the auto-detection system.

## Auto-Detect Examples

### Clear task name (should sync)
Bloomberg integration testing complete.

### Explicit reference (always works)
@task search:"Test Task"
Manual reference works.

### Issue number
#27

---

Test: Run python C:\Repo\NemesisProject\scripts\asana-sync-enhanced.py --dry-run to see proposals.
"@

    Set-Content -Path $testNoteFile -Value $testContent -Encoding UTF8
    Write-Host "[+] Created: Test note file" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create test note: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "[OK] Project Created Successfully!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Project Details:" -ForegroundColor Cyan
Write-Host "  Name:        Project-$clientName" -ForegroundColor Gray
Write-Host "  Location:    $projectRoot" -ForegroundColor Gray
Write-Host "  Asana GID:   $asanaGID" -ForegroundColor Gray
Write-Host "  Folders:     $folderPattern" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Add .claude/settings.json to your project in Claude Code" -ForegroundColor Gray
Write-Host "2. Start writing notes in: $notesFolder" -ForegroundColor Gray
Write-Host "3. Notes sync to Asana automatically on save" -ForegroundColor Gray
Write-Host ""
Write-Host "Test the sync (optional):" -ForegroundColor Cyan
Write-Host "  cd '$projectRoot'" -ForegroundColor Gray
Write-Host "  python C:\Repo\NemesisProject\scripts\asana-sync-enhanced.py --dry-run" -ForegroundColor Gray
Write-Host ""
Write-Host "Files Created:" -ForegroundColor Cyan
Write-Host "  .env (your token - never commit)" -ForegroundColor Gray
Write-Host "  .claude/settings.json (hook config)" -ForegroundColor Gray
Write-Host "  .gitignore (protect secrets)" -ForegroundColor Gray
Write-Host "  README.md (project guide)" -ForegroundColor Gray
