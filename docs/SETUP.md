# Setup Guide

Complete setup in 2 steps. No command line needed.

---

## Step 1: Python & Environment Setup (One-Time)

**Double-click this file:**
```
C:\Repo\NemesisProject\1-SETUP-INFRASTRUCTURE.bat
```

**What it does:**
- Checks if Python 3.7+ is installed
- Auto-installs Python if missing (via winget or chocolatey)
- Creates virtual environment
- Installs email integration dependencies
- Verifies everything works

**You'll see:**
```
============================================================
  Nemesis Project — Email Integration Setup
============================================================

Starting setup script...

✓ Virtual environment created
✓ All dependencies installed
✓ Setup Complete!

Next step: Double-click "2-CREATE-PROJECT.bat"
```

**If Python auto-install fails:**
- Download from: https://www.python.org/downloads/
- Run installer
- **IMPORTANT:** Check "Add Python to PATH"
- Restart your computer
- Run `1-SETUP-INFRASTRUCTURE.bat` again

**Wait for:** "Setup Complete!" message

---

## Step 2: Create Your First Project

**Double-click this file:**
```
C:\Repo\NemesisProject\2-CREATE-PROJECT.bat
```

**You'll be asked:**
1. **Client Code** (e.g., TWG, BDT, Acme)
2. **Phase Number** (e.g., 1, 2, or 3)

**What it creates:**
```
c:\Repo\Projects\Project-{ClientCode}\
  Phase {N}\
    00 - Project Overview\
    01 - Requirements\
    02 - Technical Specs\
    03 - Architecture\
    04 - Implementation\
    05 - Testing\
    06 - Deployment\
    07 - Documentation\
    08 - Meeting Notes\    ← Where notes go
    scripts\
    README.md
    .claude\
      settings.json       ← Auto-processing configuration
    .gitignore
```

**Wait for:** "Project Created Successfully!" message

---

## Step 3: Verify Everything Works (Optional)

**Double-click this file:**
```
C:\Repo\NemesisProject\3-CHECK-ASANA.bat
```

**What it does:**
- Verifies Asana MCP connector is available
- Checks system is ready for meeting notes processing

**You'll see green checkmarks** if everything is working.

---

## What Gets Installed

**Python (system-level):**
- Python 3.7+ runtime
- pip (package manager)

**Virtual Environment** (`venv` folder):
- `requests` — HTTP library (for email integration)
- `fuzzywuzzy` — Fuzzy string matching (for project name detection)
- `python-Levenshtein` — Performance optimization

**Project-specific** (created in each project):
- `.claude/settings.json` — Auto-processing hook configuration
- Folder structure (00-08 sections)
- README template

---

## System Requirements

- **Windows 10+**, **macOS**, or **Linux**
- ~200MB free disk space
- Internet connection (for first-time setup)
- **No manual Python knowledge needed** — auto-installs if missing

---

## After Setup: Start Using

Once both steps complete, you're ready to use Nemesis Project.

**In Claude Code, type:**
```
New session meeting notes TWG

Met with team today.

Discussed:
- Q4 timeline
- Tech requirements

Action items:
- Update docs
- Schedule review
```

System automatically:
1. Creates file in `Project-TWG/Phase 1/08 - Meeting Notes/`
2. Parses line items
3. Shows Asana confirmation prompts
4. Posts to tasks
5. Done

**See:** [MEETING-NOTES-WORKFLOW.md](MEETING-NOTES-WORKFLOW.md) for complete workflow details.

---

## Troubleshooting

**Setup failed?**
→ See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

**Python won't install?**
→ Manual install: https://www.python.org/downloads/
→ Check "Add Python to PATH"
→ Restart computer
→ Run setup again

**Project not created?**
→ Make sure you ran BOTH steps
→ Run 1-SETUP-INFRASTRUCTURE.bat first
→ Then run 2-CREATE-PROJECT.bat

**Asana check failed?**
→ Internet connection required
→ Asana account needed
→ Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## Workspace Folder Structure

After setup:

```
c:\Repo\NemesisProject\        ← Central repo
  1-SETUP-INFRASTRUCTURE.bat   ← Step 1
  2-CREATE-PROJECT.bat         ← Step 2
  3-CHECK-ASANA.bat            ← Step 3 (optional)
  README.md
  QUICK_START.txt
  venv\                         ← Created by Step 1
  scripts\
    setup-infrastructure.ps1
    create-new-project.ps1
  docs\
    INDEX.md
    SETUP.md ← You are here
    TROUBLESHOOTING.md
  ClientProjectTemplate\
  email-integration\

c:\Repo\Projects\              ← Your projects (created by Step 2)
  Project-TWG\
    Phase 1\
      08 - Meeting Notes\ ← Where notes go
    Phase 2\
    .claude\settings.json
    README.md
  Project-BDT\
    ...similar structure
  Project-Acme\
    ...similar structure
```

---

## Manual Activation (Advanced)

If you need to manually activate the virtual environment for development:

```powershell
C:\Repo\NemesisProject\venv\Scripts\Activate.ps1
```

You'll see `(venv)` in your prompt when active.

**Most users don't need this.** The .bat files handle activation automatically.

---

## Next Steps

**Ready to use?**
→ [QUICK_START.txt](../QUICK_START.txt) — 3-step beginner guide

**Want full details?**
→ [MEETING-NOTES-WORKFLOW.md](MEETING-NOTES-WORKFLOW.md) — Complete workflow

**Something broken?**
→ [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — Common issues

**Need navigation?**
→ [INDEX.md](INDEX.md) — Documentation index
