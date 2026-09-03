# Nemesis Project — Asana Integration System

**Automated notes-to-Asana sync for any client project.**

## What Is This?

A production-ready system that automatically syncs meeting notes to Asana tasks. Write naturally in Claude Code, and the system detects task references (with or without explicit `@task` markers) and updates Asana automatically.

**Key Features:**
- ✅ Auto-detect task names (no `@task` syntax required)
- ✅ Backward compatible with explicit `@task` references
- ✅ Works for any project (Project-<Client>)
- ✅ Per-user authentication (ASANA_PAT tokens)
- ✅ Claude Code hooks for automatic sync on file save
- ✅ Email-to-notes integration (from meetingNotes@Alphafmc.com)
- ✅ Full audit trail of all syncs

## ⭐ Quick Start — EASIEST METHOD

### Step 1: Double-Click Setup
Navigate to this folder and double-click:
```
1-SETUP-INFRASTRUCTURE.bat
```

**What it does:**
- ✓ Checks if Python 3.7+ is installed
- ✓ Creates virtual environment
- ✓ Installs all dependencies
- ✓ Verifies installation

**Wait for:** "Setup Complete!" message

### Step 2: Double-Click Project Creator
Double-click:
```
2-CREATE-PROJECT.bat
```

**Follow the prompts:**
- Client Name (e.g., TWG, BDT, Acme)
- Phase Number (1, 2, 3, etc.)
- Asana Project GID (from project URL)
- Your ASANA_PAT (personal token)
- Folder Pattern (where your notes live)

**What it creates:**
- `c:\Repo\Projects\Project-<Client>\Phase <N>\`
- `.env` file (never committed to Git)
- `.claude/settings.json` (hook configuration)
- `.gitignore` (protects secrets)
- Project README

### Step 3: Start Writing Notes

Drop notes into:
```
c:\Repo\Projects\Project-<Client>\Phase <N>\08 - Meeting Notes\
```

**Sync happens automatically** when you save files!

Or send emails to `meetingNotes@Alphafmc.com` (CC/BCC with `[ProjectName]` in subject).

---

## Alternative: PowerShell Method

If you prefer command-line:

```powershell
cd C:\Repo\NemesisProject

# One-time setup
.\scripts\setup-infrastructure.ps1

# Create new project
.\scripts\create-new-project.ps1
```

---

## How Auto-Detection Works

### Automatic (No Special Syntax)
```markdown
Bloomberg integration complete. Ready for production.
```
→ Auto-syncs to the "Bloomberg Integration #27" task

### Explicit (Always Works)
```markdown
@task search:"Task Name"
Your comment here.
```
→ Explicitly syncs to specified task

### Issue Number
```markdown
Fixed bug #27 in the integration flow.
```
→ Automatically finds task #27 (if unique)

**Learn more:** See `docs/AUTO_DETECTION.md`

---

## Documentation

- **[QUICK_START.txt](QUICK_START.txt)** — Brain-dead simple guide (3 steps, no jargon)
- **[docs/SETUP.md](docs/SETUP.md)** — Detailed infrastructure setup
- **[docs/AUTO_DETECTION.md](docs/AUTO_DETECTION.md)** — How auto-detection works
- **[email-integration/README.md](email-integration/README.md)** — Email-to-notes integration
- **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** — Common issues and solutions
- **[DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md)** — What was created

## Architecture

```
c:\Repo\NemesisProject\           ← Central (this repo)
├── 1-SETUP-INFRASTRUCTURE.bat   ← Double-click for setup
├── 2-CREATE-PROJECT.bat         ← Double-click to create project
├── scripts\
│   ├── asana-sync-enhanced.py   ← Shared by all projects
│   ├── setup-infrastructure.ps1 ← One-time setup script
│   └── create-new-project.ps1   ← Project creation script
├── requirements.txt              ← Python dependencies
└── docs\                          ← Documentation

c:\Repo\Projects\
├── Project-TWG\
│   ├── Phase 1\
│   ├── Phase 2\
│   ├── .claude\settings.json     ← References shared script
│   ├── .env                       ← User's personal token
│   └── 08 - Meeting Notes\
├── Project-BDT\
│   └── ...similar structure
└── Project-Nullpoint\
    └── ...similar structure
```

## System Requirements

- **Windows 10+**, **macOS**, or **Linux**
- **Python 3.7+** (setup script checks and guides installation if needed)
- **~500MB** free disk space
- **Internet connection**
- **Asana account** with Personal Access Token

## How It Works

### Setup (One-Time)
1. Double-click `1-SETUP-INFRASTRUCTURE.bat`
2. Wait for "Setup Complete!" message
3. Done! (Virtual environment created, dependencies installed)

### Project Creation (Per Client)
1. Double-click `2-CREATE-PROJECT.bat`
2. Answer prompts (Client Name, Phase, Asana GID, Token, Folders)
3. Done! (Project folder created with all configuration)

### Using the System
1. Drop notes into project's `08 - Meeting Notes` folder
2. Write naturally: "Bloomberg integration complete"
3. Save file → Hook fires → Sync to Asana automatically

**No manual:**
- File editing
- Python knowledge
- Environment variables
- Folder creation

## Key Features

### Auto-Detection
- Write naturally in notes
- System finds task references
- Fuzzy matching with confidence scoring
- Ambiguous matches show user options

### Backward Compatible
- Explicit `@task search:"Task"` syntax still works
- Takes priority over auto-detection (100% confidence)
- Guaranteed to sync when explicitly tagged

### Multi-User
- Each user has personal ASANA_PAT in `.env`
- Tokens never committed to Git
- Full audit trail (who synced what, when)

### Claude Code Hooks
- Automatic sync on file save
- No manual command execution needed
- `--no-prompt` flag auto-approves (no user interaction)

### Production Ready
- Comprehensive error handling
- Full audit logging
- Graceful failure modes
- Clear error messages

## Troubleshooting

**Python not found?**
→ Run `1-SETUP-INFRASTRUCTURE.bat` again (it will guide installation)

**ASANA_PAT error?**
→ Check `.env` file in your project folder has your token

**Hook not firing?**
→ Resave `.claude/settings.json` to re-enable hook

**More help?**
→ See `docs/TROUBLESHOOTING.md`

## Deployment

This project is ready to:
- ✅ Push to GitHub immediately
- ✅ Deploy to team members
- ✅ Scale to unlimited projects
- ✅ Use in production

Everything is included:
- ✅ Core Python script
- ✅ Setup automation
- ✅ Project creation automation
- ✅ Complete documentation
- ✅ Error handling
- ✅ Audit logging

---

## Getting Started

**Path 1: File-based notes (Recommended)**
1. Double-click `1-SETUP-INFRASTRUCTURE.bat`
2. Double-click `2-CREATE-PROJECT.bat`
3. Drop notes into `Project-<Name>/Phase <N>/08 - Meeting Notes/`
4. Notes sync to Asana automatically

**Path 2: Email-based notes**
1. Follow Path 1 first
2. Double-click `sync-emails.bat` anytime to import emails
3. Send emails to `meetingNotes@Alphafmc.com` with `[ProjectName]` in subject
4. Notes automatically routed to correct project

**Learning resources:**
- **[QUICK_START.txt](QUICK_START.txt)** — Start here (3 simple steps)
- **[docs/AUTO_DETECTION.md](docs/AUTO_DETECTION.md)** — How note detection works
- **[email-integration/README.md](email-integration/README.md)** — Email integration guide

---

**Ready to go.** Double-click the batch files or read `QUICK_START.txt`.
