# Troubleshooting Guide

**Something not working?** Find your issue below and follow the fix.

---

## Setup Issues

### Python Won't Install

**Problem:** `1-SETUP-INFRASTRUCTURE.bat` says "ERROR: Python not found"

**Solution:**
1. Install Python manually: https://www.python.org/downloads/
2. **CRITICAL:** During installation, check **"Add Python to PATH"**
3. Close ALL command prompts and PowerShell windows
4. Restart your computer
5. Run `1-SETUP-INFRASTRUCTURE.bat` again

**If still failing:**
- Open Command Prompt
- Type: `python --version`
- Should show: `Python 3.X.X`
- If not, Python isn't in PATH — reinstall and check the box

---

### Setup Hangs or Freezes

**Problem:** `1-SETUP-INFRASTRUCTURE.bat` starts but never finishes

**Solution:**
1. Close the window (Ctrl+C)
2. Delete the venv folder: `C:\Repo\NemesisProject\venv`
3. Run `1-SETUP-INFRASTRUCTURE.bat` again

**If still freezing:**
- Check internet connection (setup downloads packages)
- Try running as Administrator
- Check disk space (need ~200MB free)

---

### "Import verification failed"

**Problem:** Setup completes but shows "ERROR: Import verification failed"

**Solution:**
1. Delete venv: `C:\Repo\NemesisProject\venv`
2. Run `1-SETUP-INFRASTRUCTURE.bat` again
3. If still fails, manually verify:
   ```powershell
   C:\Repo\NemesisProject\venv\Scripts\python.exe -c "import fuzzywuzzy; import requests; print('OK')"
   ```
   Should print: `OK`

If it doesn't, reinstall dependencies manually:
```powershell
C:\Repo\NemesisProject\venv\Scripts\pip install -r C:\Repo\NemesisProject\requirements.txt
```

---

## Project Creation Issues

### "Project Created Successfully" but folder doesn't exist

**Problem:** `2-CREATE-PROJECT.bat` says success but no folder appears

**Solution:**
1. Check the path: `c:\Repo\Projects\Project-{YourClientName}\`
2. Make sure you typed the name correctly
3. Refresh File Explorer (F5)
4. If still missing, run `2-CREATE-PROJECT.bat` again with the same name

---

### "ERROR: Phase must be a number"

**Problem:** Phase Number prompt rejected your input

**Solution:**
- You entered: letters, spaces, or special characters
- Valid input: `1` or `2` or `3` (just the number)
- Try again with only the number

---

### "ERROR: Failed to create project structure"

**Problem:** Setup succeeded but project creation failed

**Solution:**
1. Run `1-SETUP-INFRASTRUCTURE.bat` again (venv may be corrupted)
2. Run `2-CREATE-PROJECT.bat` again
3. If still failing:
   - Check disk space (need ~100MB free)
   - Check permissions (need write access to `c:\Repo\Projects\`)
   - Try with a different client name

---

## Meeting Notes Issues

### Project Not Detected

**Problem:** You type meeting notes but system says "Cannot detect project"

**Example:**
```
New session meeting notes TWG
[your notes...]
```

System says: "Cannot detect project from this text"

**Solution:**
Make sure format includes project name clearly:
- ✓ "New session meeting notes TWG"
- ✓ "Meeting notes for TWG"
- ✓ "notes: TWG"
- ✓ "TWG meeting"
- ✗ "notes from today" (no project name)
- ✗ "t-w-g meeting" (broken name)

**Try:**
```
New session meeting notes TWG

[your notes here]
```

---

### No Asana Tasks Found for Line Item

**Problem:** System searches but finds zero matching Asana tasks

**Example:**
```
Line 1: "Some random text"
No Asana tasks found matching this item.
Enter task GID manually or [SKIP]:
```

**Causes & Solutions:**

**Cause 1: No Asana tasks exist**
- Solution: Create the task in Asana first, then re-run notes

**Cause 2: Item text doesn't match any task names**
- Solution: Use more specific task names
  - ✗ "Entity workflow" (too vague, multiple matches)
  - ✓ "Entity Management Workflow Phase 1" (specific)

**Cause 3: Typo in item text**
- Solution: Type exact task name from Asana
  - Copy from Asana if possible

**Cause 4: Abbreviation not recognized**
- Solution: Use full names instead
  - ✗ "BDT workflow" (abbreviation)
  - ✓ "Business Development Team workflow" (full name)

**Workaround:** Enter task GID manually:
```
Enter task GID manually or [SKIP]: 1215428532115696
```
(You'll be prompted to provide this)

---

### Confirmation Prompt Stuck or Not Responding

**Problem:** System shows confirmation prompt but never proceeds

**Example:**
```
Line 1: "Q4 timeline"
Detected: "Q4 Planning" (GID: 123456)
→ Correct? [YES/NO]

(waiting... nothing happens)
```

**Solution:**
1. Type your response clearly:
   - `YES` (press Enter)
   - `NO` (press Enter)
   - Or a GID number (press Enter)

2. If still stuck:
   - Close the session
   - Reopen Claude Code
   - Start over (notes are saved, you can re-paste)

---

### Wrong Task Matched

**Problem:** System suggests wrong Asana task for your line item

**Example:**
```
Line 1: "Hide Portfolio"
Detected: "Show Portfolio" (wrong task!)
→ Correct? [YES/NO]
```

**Solution:**
- Type `NO`
- System skips this item
- Or enter the correct task GID manually

**To avoid this:**
- Use complete, unambiguous item names
- Avoid single words or abbreviations
- Be specific: "Hide Portfolio Summary Feature" not just "Hide Portfolio"

---

### File Not Created in 08 - Meeting Notes

**Problem:** You type meeting notes but no file appears in the folder

**Solution:**
1. Check the folder exists: `Project-TWG/Phase 1/08 - Meeting Notes/`
2. Make sure you're looking in the right project (did system detect the right one?)
3. Refresh File Explorer (F5)
4. Check the file was actually created (system should show summary)

**If file still missing:**
- Try again with a simpler project name
- Check disk space
- Check folder permissions

---

### "Processed 0 items"

**Problem:** System says it processed 0 line items from your notes

**Causes:**

**Cause 1: No line items in format**
- Solution: Use bullet points or clear structure
  - ✗ "We discussed things and met with people"
  - ✓ "- Item 1\n- Item 2\n- Item 3"

**Cause 2: All items were skipped (no matches)**
- Solution: Use explicit task GIDs or create tasks in Asana first

**Cause 3: All items were answered NO**
- Solution: Review the detections and answer YES to at least one

---

## Asana Matching Issues

### Multiple Tasks Shown (Ambiguous Match)

**Problem:** System finds several matching Asana tasks, unsure which one

**Example:**
```
Line: "Entity workflow"
Detected:
  [0] Entity Management (GID: 111)
  [1] Entity Design (GID: 222)
  [2] Sub-Entity Mapping (GID: 333)
→ Pick one or [SKIP]:
```

**Solution:**
- Type the number of the correct task: `0` or `1` or `2`
- Or type `SKIP` to skip this item

**To avoid ambiguity:**
- Use more specific item names
- Include context: "Entity Management Workflow" not just "Entity"

---

## File & Folder Issues

### Can't Find Project-{Name} Folder

**Problem:** You created a project but can't find it on disk

**Solution:**
1. Check location: `c:\Repo\Projects\`
2. Check exact spelling (case-sensitive on some systems)
3. Refresh File Explorer (F5)
4. Search Windows for `Project-{Name}`

**If completely missing:**
- Run `2-CREATE-PROJECT.bat` again
- Use same client name and phase number
- It will recreate the folder

---

### "08 - Meeting Notes" Folder Missing

**Problem:** Project created but no "08 - Meeting Notes" folder

**Solution:**
- This folder is created automatically by `2-CREATE-PROJECT.bat`
- If missing, check full folder structure was created
- All folders 00-08 should exist
- If missing, delete project and recreate it

---

## Asana Connectivity Issues

### "Asana check failed" (3-CHECK-ASANA.bat)

**Problem:** `3-CHECK-ASANA.bat` shows red X instead of green ✓

**Causes:**

**Cause 1: No internet connection**
- Solution: Check your internet, try again

**Cause 2: Asana service down**
- Solution: Check Asana status page, try again later

**Cause 3: MCP connector not configured**
- Solution: Verify Claude Code settings, check docs/SETUP.md

---

## File Encoding Issues

### "UnicodeEncodeError" or garbled characters

**Problem:** System shows encoding errors or strange characters in filenames

**Solution:**
- File was created with non-ASCII characters (é, ñ, 中文, etc.)
- Use ASCII-only characters in project names and file names
- Valid: "Project-TWG", "Q4-Planning-Phase-1"
- Invalid: "Projet-Québec", "Q4-計画", "PhaseΩ"

---

## Still Not Working?

**Last resort:**
1. Delete everything and start fresh:
   ```
   1. Delete: C:\Repo\NemesisProject\venv
   2. Delete: C:\Repo\Projects\Project-{YourName}
   3. Run: 1-SETUP-INFRASTRUCTURE.bat
   4. Run: 2-CREATE-PROJECT.bat
   5. Try meeting notes again
   ```

2. Check logs for error details
3. See README.md for contact/support info

---

## Quick Reference

| Issue | Check First |
|-------|-------------|
| Setup fails | Python installed + in PATH? |
| Project not created | Ran BOTH Step 1 AND Step 2? |
| Project not detected | Included project name in text? |
| No Asana matches | Does task exist in Asana? |
| Wrong task matched | Try entering GID manually |
| File not created | Refreshed File Explorer? |
| Confirmation stuck | Did you type YES/NO and press Enter? |

---

## Report a New Issue

If you encounter a problem not listed here:
1. Note the exact error message
2. Note what you were doing
3. Check README.md for support information

See: [INDEX.md](INDEX.md) for navigation to other docs
