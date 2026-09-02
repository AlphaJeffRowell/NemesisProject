# Nemesis Project — Create New Client Project
# Run this to set up a new client project with all necessary configuration

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Create New Client Project" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Helper function for colored input prompts
function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$Default = "",
        [switch]$IsSecret = $false
    )

    $displayPrompt = if ($Default) { "$Prompt [$Default]: " } else { "$Prompt: " }

    if ($IsSecret) {
        $value = Read-Host $displayPrompt -AsSecureString
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUni($value))
    } else {
        $value = Read-Host $displayPrompt
        return if ($value) { $value } else { $Default }
    }
}

# Step 1: Gather user input
Write-Host "Step 1: Project Information" -ForegroundColor Yellow
Write-Host ""

$clientName = Get-UserInput -Prompt "Client Code (e.g., TWG, BDT, Acme)" -Default "TestClient"
if (-not $clientName) {
    Write-Host "ERROR: Client name is required" -ForegroundColor Red
    exit 1
}

$phaseNumber = Get-UserInput -Prompt "Phase Number (1, 2, 3, etc.)" -Default "1"
if (-not $phaseNumber -match '^\d+$') {
    Write-Host "ERROR: Phase must be a number" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Asana Configuration" -ForegroundColor Yellow
Write-Host ""

$asanaGID = Get-UserInput -Prompt "Asana Project GID (from URL: https://app.asana.com/0/WORKSPACE/[THIS])"
if (-not $asanaGID) {
    Write-Host "ERROR: Asana GID is required" -ForegroundColor Red
    exit 1
}

$asanaPAT = Get-UserInput -Prompt "Your ASANA_PAT (from: https://app.asana.com/-/profile_options/apps)" -IsSecret
if (-not $asanaPAT) {
    Write-Host "ERROR: ASANA_PAT is required" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 3: Notes Folder Configuration" -ForegroundColor Yellow
Write-Host ""
Write-Host "Which folders contain your meeting notes?" -ForegroundColor Gray
Write-Host "Examples:" -ForegroundColor Gray
Write-Host "  - Single folder: '08 - Meeting Notes'" -ForegroundColor Gray
Write-Host "  - Multiple: '08 - Meeting Notes|02 - Business Requirements|04 - Technical Requirements'" -ForegroundColor Gray
Write-Host ""

$folderPattern = Get-UserInput -Prompt "Folder Pattern" -Default "08 - Meeting Notes"
if (-not $folderPattern) {
    Write-Host "ERROR: Folder pattern is required" -ForegroundColor Red
    exit 1
}

# Step 2: Create folder structure
Write-Host ""
Write-Host "Step 4: Creating folder structure..." -ForegroundColor Yellow

$projectRoot = "c:\Repo\Projects\Project-$clientName"
$phaseFolder = Join-Path $projectRoot "Phase $phaseNumber"
$notesFolder = Join-Path $phaseFolder "08 - Meeting Notes"
$scriptsFolder = Join-Path $phaseFolder "scripts"

try {
    # Create folders
    if (-not (Test-Path $phaseFolder)) {
        New-Item -ItemType Directory -Path $phaseFolder -Force | Out-Null
        Write-Host "✓ Created: $phaseFolder" -ForegroundColor Green
    } else {
        Write-Host "✓ Already exists: $phaseFolder" -ForegroundColor Green
    }

    if (-not (Test-Path $notesFolder)) {
        New-Item -ItemType Directory -Path $notesFolder -Force | Out-Null
        Write-Host "✓ Created: $notesFolder" -ForegroundColor Green
    } else {
        Write-Host "✓ Already exists: $notesFolder" -ForegroundColor Green
    }

    if (-not (Test-Path $scriptsFolder)) {
        New-Item -ItemType Directory -Path $scriptsFolder -Force | Out-Null
        Write-Host "✓ Created: $scriptsFolder" -ForegroundColor Green
    } else {
        Write-Host "✓ Already exists: $scriptsFolder" -ForegroundColor Green
    }
} catch {
    Write-Host "ERROR: Failed to create folders: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Create .env file
Write-Host ""
Write-Host "Step 5: Creating configuration files..." -ForegroundColor Yellow

$envFile = Join-Path $projectRoot ".env"
try {
    $envContent = "ASANA_PAT=$asanaPAT`n"
    Set-Content -Path $envFile -Value $envContent -Encoding UTF8
    Write-Host "✓ Created: .env" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create .env: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Create .claude/settings.json
$claudeFolder = Join-Path $projectRoot ".claude"
$settingsFile = Join-Path $claudeFolder "settings.json"

try {
    if (-not (Test-Path $claudeFolder)) {
        New-Item -ItemType Directory -Path $claudeFolder -Force | Out-Null
    }

    # Get the NemesisProject scripts path
    $nemesisScriptPath = "C:\Repo\NemesisProject\scripts\asana-sync-enhanced.py"

    # Escape backslashes for JSON
    $scriptPath = $nemesisScriptPath -replace '\\', '\\'

    $settingsContent = @"
{
  "version": "1.0",
  "hooks": [
    {
      "on": "file_write",
      "match": "**/$folderPattern/**/*.md",
      "run": "python $nemesisScriptPath --no-prompt --project-gid $asanaGID"
    }
  ]
}
"@

    Set-Content -Path $settingsFile -Value $settingsContent -Encoding UTF8
    Write-Host "✓ Created: .claude/settings.json" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create settings.json: $_" -ForegroundColor Red
    exit 1
}

# Step 5: Create .gitignore
$gitignoreFile = Join-Path $projectRoot ".gitignore"
try {
    $gitignoreContent = ".env`nvenv/`n__pycache__/`n*.pyc`n.DS_Store`n"
    Set-Content -Path $gitignoreFile -Value $gitignoreContent -Encoding UTF8
    Write-Host "✓ Created: .gitignore" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create .gitignore: $_" -ForegroundColor Red
    exit 1
}

# Step 6: Create project README
$projectReadmeFile = Join-Path $phaseFolder "README.md"
try {
    $projectReadmeContent = @"
# Project-$clientName — Phase $phaseNumber

**Asana Project GID:** $asanaGID

## Getting Started

1. Drop meeting notes into: `$notesFolder`
2. Notes are automatically synced to Asana
3. Write naturally — auto-detection finds task references
4. Or use explicit: `@task search:"Task Name"`

## How Auto-Detection Works

### Automatic (No Special Syntax Required)
\`\`\`markdown
Bloomberg integration complete. Ready for production.
\`\`\`
→ Auto-syncs to the Bloomberg task

### Explicit (Always Works)
\`\`\`markdown
@task search:"Task Name"
Your comment here.
\`\`\`
→ Explicitly syncs to specified task

## File Location

All notes should go in: **08 - Meeting Notes**

Subfolders within are OK:
- 08 - Meeting Notes/Client Meetings/
- 08 - Meeting Notes/Internal/
- etc.

## Manual Sync

If you want to sync without using hooks:

\`\`\`bash
cd $projectRoot
python C:\Repo\NemesisProject\scripts\asana-sync-enhanced.py --dry-run
\`\`\`

## Configuration

Your settings are stored in:
- `.env` — Your ASANA_PAT (never commit this)
- `.claude/settings.json` — Hook configuration

## Troubleshooting

**Hook not firing?**
- Save .claude/settings.json to re-enable

**ASANA_PAT error?**
- Check .env file has your token

**Wrong task synced?**
- Use explicit @task syntax for clarity

---

**Ready to use. Start writing notes!**
"@

    Set-Content -Path $projectReadmeFile -Value $projectReadmeContent -Encoding UTF8
    Write-Host "✓ Created: Phase folder README" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create project README: $_" -ForegroundColor Red
    exit 1
}

# Step 7: Create test note
$testNoteFile = Join-Path $notesFolder "Test_AutoDetect.md"
try {
    $testNoteContent = @"
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

**Test:** Run \`python C:\Repo\NemesisProject\scripts\asana-sync-enhanced.py --dry-run\` to see proposals.
"@

    Set-Content -Path $testNoteFile -Value $testNoteContent -Encoding UTF8
    Write-Host "✓ Created: Test note file" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create test note: $_" -ForegroundColor Red
    exit 1
}

# Success
Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "✓ Project Created Successfully!" -ForegroundColor Green
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
Write-Host "  .env (your token — never commit)" -ForegroundColor Gray
Write-Host "  .claude/settings.json (hook config)" -ForegroundColor Gray
Write-Host "  .gitignore (protect secrets)" -ForegroundColor Gray
Write-Host "  README.md (project guide)" -ForegroundColor Gray
