# Troubleshooting Guide

## Setup Issues

### "Python not found"

**Error:** `python command not found` or similar

**Solution:**
1. Install Python from: https://www.python.org/downloads/
2. **IMPORTANT:** During installation, check "Add Python to PATH"
3. Close and reopen PowerShell
4. Run setup script again

**Verify:**
```powershell
python --version
```

Should show Python 3.7 or higher.

---

### "pip not found"

**Error:** `pip command not found`

**Solution:**
```powershell
python -m pip --version
```

If that works, use:
```powershell
python -m pip install -r requirements.txt
```

---

### "Permission denied"

**Error:** When running setup script

**Solution:**
1. Right-click PowerShell
2. Select "Run as Administrator"
3. Run setup script

Or change execution policy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## Dependency Issues

### "ModuleNotFoundError: No module named 'fuzzywuzzy'"

**Error:** Script crashes with import error

**Solution:**
1. Activate virtual environment:
   ```powershell
   C:\Repo\NemesisProject\venv\Scripts\Activate.ps1
   ```

2. Install missing package:
   ```powershell
   pip install fuzzywuzzy python-Levenshtein
   ```

3. Try again

---

### "ImportError: requests"

**Error:** Similar to above

**Solution:**
```powershell
pip install requests
```

---

## Authentication Issues

### "ASANA_PAT not found" or "401 Unauthorized"

**Error:** Script fails with authentication error

**Solution:**
1. Generate token: https://app.asana.com/-/profile_options/apps
2. Create `.env` file in your project folder:
   ```
   ASANA_PAT=<your-token>
   ```
3. Make sure `.env` is in `.gitignore` (never commit)
4. Try again

**Check:**
```powershell
echo $env:ASANA_PAT
```

If empty, set it:
```powershell
$env:ASANA_PAT = "your-token-here"
```

---

### "Invalid token"

**Error:** `401 Unauthorized`

**Solution:**
- Token may have expired
- Regenerate at: https://app.asana.com/-/profile_options/apps
- Update `.env` file
- Try again

---

## Hook Issues

### "Hook not firing" (File saved but no sync)

**Error:** Save file but nothing happens

**Solution:**
1. Verify `.claude/settings.json` exists in project root
2. Check JSON syntax (use JSON validator)
3. Verify folder pattern matches your notes location
4. **Resave `.claude/settings.json`** to re-enable hook
5. Save a test note file

**Debug:**
```powershell
# Check settings.json syntax
cd Project-<Client>
cat .\.claude\settings.json | ConvertFrom-Json
```

If error, JSON is malformed.

---

### "Hook path invalid"

**Error:** Hook points to wrong script path

**Solution:**
Update `.claude/settings.json`:
```json
{
  "hooks": [{
    "run": "python C:\\Repo\\NemesisProject\\scripts\\asana-sync-enhanced.py --no-prompt --project-gid YOUR_GID"
  }]
}
```

Note: Use forward slashes OR escaped backslashes in JSON.

---

## Sync Issues

### "No tasks found" or "Cannot find task"

**Error:** Script runs but says task doesn't exist

**Solution:**
1. Verify Asana project GID in `.claude/settings.json`
2. Verify task exists in Asana
3. Try explicit @task reference:
   ```markdown
   @task name:"Exact Task Name"
   Your content.
   ```
4. Check Asana project URL matches GID:
   ```
   https://app.asana.com/0/WORKSPACE/GID/list
   ```

---

### "Wrong task synced"

**Error:** Comment posted to wrong Asana task

**Solution:**
- Auto-detection is ambiguous for your text
- Use explicit @task syntax instead:
  ```markdown
  @task search:"Exact Task Name"
  Your comment here.
  ```

---

### "Connection timeout"

**Error:** Script hangs or fails with timeout

**Solution:**
1. Check internet connection
2. Check Asana status: https://status.asana.com/
3. Retry operation
4. If persistent, check firewall/proxy settings

---

## File Issues

### "Cannot read file" or encoding errors

**Error:** Script fails to read .md file

**Solution:**
1. Ensure file is UTF-8 encoded
2. Check file path is correct
3. Ensure file is not locked (not open in editor)
4. Try different file

---

### "No markdown files found"

**Error:** Script says no files to process

**Solution:**
1. Create test file: `08 - Meeting Notes/test.md`
2. Verify folder pattern matches in `.claude/settings.json`
3. Run: `python scripts/asana-sync-enhanced.py --dry-run`

---

## General Debugging

### Run in verbose mode

```powershell
python C:\Repo\NemesisProject\scripts\asana-sync-enhanced.py --verbose --dry-run
```

Shows detailed debug output.

---

### Check audit log

```powershell
cd Project-<Client>
type scripts\asana-sync.log
# or
tail -20 scripts\asana-sync.log  # Last 20 lines
```

Shows all sync activity.

---

### Test manual sync

```powershell
cd C:\Repo\Projects\Project-<Client>
python C:\Repo\NemesisProject\scripts\asana-sync-enhanced.py --dry-run
```

Should show proposals without making changes.

---

## Still Stuck?

1. **Check all three:**
   - `.env` file exists with ASANA_PAT
   - `.claude/settings.json` exists with correct GID
   - Asana project exists and is accessible

2. **Run setup again:**
   ```powershell
   C:\Repo\NemesisProject\scripts\setup-infrastructure.ps1
   ```

3. **Try explicit @task:**
   ```markdown
   @task search:"Task Name"
   ```

4. **Check logs:**
   ```powershell
   cat asana-sync.log
   ```

---

## Common Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| `No such file or directory` | Wrong path | Check file exists |
| `401 Unauthorized` | Invalid token | Update .env |
| `ModuleNotFoundError` | Package not installed | Run `pip install` |
| `JSON decode error` | Malformed settings.json | Fix JSON syntax |
| `Connection refused` | Wrong GID | Verify GID in URL |
| `timeout` | Network issue | Check connection |

---

**Can't find your issue?** Check the documentation or try running with `--verbose` for more details.
