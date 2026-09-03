# Nemesis Project — Create New Client Project
# Creates folder structure for client projects (no Asana config needed - MCP handles sync)

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

# Create folder structure
Write-Host ""
Write-Host "Creating folder structure..." -ForegroundColor Cyan

$clientProjectTemplatePath = "C:\Repo\NemesisProject\ClientProjectTemplate\create-structure.bat"
if (Test-Path $clientProjectTemplatePath) {
    & $clientProjectTemplatePath $clientName $phaseNumber $folderPattern
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to create project structure" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "ERROR: ClientProjectTemplate not found at: $clientProjectTemplatePath" -ForegroundColor Red
    exit 1
}

$notesFolder = Join-Path $phaseFolder "08 - Meeting Notes"

# Create .claude folder and settings
$claudeFolder = Join-Path $projectRoot ".claude"
if (-not (Test-Path $claudeFolder)) {
    New-Item -ItemType Directory -Path $claudeFolder -Force | Out-Null
}

$claudeSettingsFile = Join-Path $claudeFolder "settings.json"
try {
    $claudeSettingsContent = @"
{
  "version": "1.0",
  "hooks": [
    {
      "on": "file_write",
      "match": "**/08 - Meeting Notes/**/*.md",
      "description": "Auto-process meeting notes on file save"
    }
  ]
}
"@
    Set-Content -Path $claudeSettingsFile -Value $claudeSettingsContent -Encoding UTF8
    Write-Host "[+] Created: .claude/settings.json (auto-processing on save)" -ForegroundColor Green
} catch {
    Write-Host "WARNING: Failed to create .claude/settings.json: $_" -ForegroundColor Yellow
}

# Create .gitignore
$gitignoreFile = Join-Path $projectRoot ".gitignore"
try {
    $gitignoreContent = ".env`nvenv/`n__pycache__/`n*.pyc`n.DS_Store`n"
    Set-Content -Path $gitignoreFile -Value $gitignoreContent -Encoding UTF8
    Write-Host "[+] Created: .gitignore" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create .gitignore: $_" -ForegroundColor Red
    exit 1
}

# Create project README
$projectReadmeFile = Join-Path $phaseFolder "README.md"
try {
    $readmeContent = @"
# Project-$clientName - Phase $phaseNumber

## Quick Start

Open Claude Code in this folder and type:

\`\`\`
New session meeting notes $clientName

Your meeting notes...
- Discussion point 1
- Action item 1
- Action item 2
\`\`\`

## What Happens Automatically

1. **File Creation** — I create a timestamped file in \`08 - Meeting Notes/\`
2. **Line Parsing** — I extract each bullet/action item
3. **Asana Search** — I search Asana for matching tasks (fuzzy matching)
4. **Confirmation** — I ask you to confirm each match
5. **Posting** — I post confirmed items as comments on Asana tasks

## Example Workflow

**You type:**
\`\`\`
New session meeting notes $clientName

Team planning meeting on 2026-09-03.

Discussed:
- Q4 timeline confirmed
- Technical requirements approved

Action items:
- Update project plan
- Schedule review meeting
- Prepare documentation
\`\`\`

**I respond with:**
\`\`\`
Detected task: "Q4 Planning" (GID: 123456)
  → correct for "Q4 timeline confirmed"? [YES/NO]

Detected task: "Technical Review" (GID: 123457)
  → correct for "Technical requirements approved"? [YES/NO]

... (confirmation prompts for each item)

✓ Posted 6 items to 3 Asana tasks
\`\`\`

## Folder Structure

- **00 - Project Overview** — High-level documentation
- **01 - Requirements** — Functional and non-functional requirements
- **02 - Technical Specs** — Implementation specifications
- **03 - Architecture** — System architecture and design
- **04 - Implementation** — Code, scripts, deployment files
- **05 - Testing** — Test cases and test results
- **06 - Deployment** — Deployment guides and checklists
- **07 - Documentation** — User guides and API docs
- **08 - Meeting Notes** — Meeting notes (auto-synced to Asana)

## No Setup Required

✓ No Asana tokens
✓ No .env files
✓ No configuration
✓ Just write naturally in Claude Code

Asana MCP connector handles everything automatically.

---

Ready to use. Start writing meeting notes in Claude Code!
"@

    Set-Content -Path $projectReadmeFile -Value $readmeContent -Encoding UTF8
    Write-Host "[+] Created: Phase folder README" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create project README: $_" -ForegroundColor Red
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
Write-Host "  Phase:       Phase $phaseNumber" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Open Claude Code and navigate to: $projectRoot" -ForegroundColor Gray
Write-Host "2. Type naturally: New session meeting notes $clientName" -ForegroundColor Gray
Write-Host "3. Paste your notes - Claude syncs to Asana automatically" -ForegroundColor Gray
Write-Host ""
