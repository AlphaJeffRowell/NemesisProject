# Infrastructure Setup Guide

## One-Time Setup (Per Machine)

Run this once on your computer to set up Python, dependencies, and virtual environment.

### Prerequisites

- **Windows 10+**, **macOS**, or **Linux**
- Administrator access (to install Python if needed)
- ~500MB free disk space

### Step 1: Run Setup Script

```powershell
cd C:\Repo\NemesisProject
.\scripts\setup-infrastructure.ps1
```

**What it does:**
- ✓ Checks if Python 3.7+ is installed
- ✓ Creates virtual environment at `C:\Repo\NemesisProject\venv`
- ✓ Installs all dependencies from `requirements.txt`
- ✓ Verifies installation with import test

### Step 2: Verify Success

After setup completes, you should see:
```
✓ Setup Complete!
✓ All imports successful
```

If you get an error, see **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**.

### Python Not Found?

If the script says "Python not found", you need to install it:

1. Download from: https://www.python.org/downloads/
2. Run installer
3. **IMPORTANT:** Check "Add Python to PATH" during installation
4. Close and re-open PowerShell
5. Run setup script again

## What Gets Installed

**System-level (via Python installer):**
- Python 3.7+ runtime
- pip (package manager)

**In virtual environment (`venv` folder):**
- `anthropic` — Anthropic API client
- `requests` — HTTP library
- `fuzzywuzzy` — Fuzzy string matching
- `python-Levenshtein` — Performance boost for fuzzy matching

**Virtual Environment Location:**
```
C:\Repo\NemesisProject\venv\
```

## Activate Virtual Environment (Manual)

If you need to manually activate the virtual environment:

```powershell
C:\Repo\NemesisProject\venv\Scripts\Activate.ps1
```

You'll see `(venv)` in your prompt when active.

## Next Step

Once setup completes, run:

```powershell
.\scripts\create-new-project.ps1
```

This will create your first client project.

## Troubleshooting

See **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** for common issues and solutions.

---

**Done with setup?** Run `create-new-project.ps1` to create your first client project.
