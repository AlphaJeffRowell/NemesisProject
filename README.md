# Nemesis Project — Natural Language Meeting Notes Sync

**Type your meeting notes naturally. System automatically detects project, parses items, searches Asana, confirms matches, and posts. ZERO manual steps.**

## What Is This?

A production-ready system that syncs meeting notes to Asana tasks with **maximum automation + explicit user confirmation**.

**Key Features:**
- ✅ Natural-language input (just type in Claude Code)
- ✅ Automatic project detection (TWG, BDT, Acme, etc.)
- ✅ Line-item parsing (bullets, actions, discussions)
- ✅ Asana task fuzzy matching
- ✅ Per-item confirmation (YOU control what gets posted)
- ✅ Smart grouping (one comment per task, no duplicates)
- ✅ Email-to-notes integration (optional)
- ✅ File automatically created — no manual steps

---

## ⭐ Quick Start (2 Setup Steps)

### Step 1: Double-Click Python Setup
```
1-SETUP-INFRASTRUCTURE.bat
```
- Auto-installs Python if missing
- Creates virtual environment
- Installs dependencies
- Wait for: "Setup Complete!"

### Step 2: Double-Click Project Creator
```
2-CREATE-PROJECT.bat
```
- Asks: Client Name (e.g., TWG, BDT)
- Asks: Phase Number (1, 2, 3, etc.)
- Creates full folder structure
- Wait for: "Project Created Successfully!"

---

## Now Use It — Just Type

Open Claude Code and type naturally:

```
New session meeting notes TWG

Met with team on 2026-09-03.

Discussed:
- Q4 timeline confirmed
- Technical requirements approved
- Ready for Phase 2

Action items:
- Update project plan
- Schedule review meeting
```

**System automatically:**
1. ✓ Creates file in `Project-TWG/Phase 1/08 - Meeting Notes/`
2. ✓ Parses all items
3. ✓ Searches Asana for matches
4. ✓ Shows confirmation prompts:
   ```
   Line 1: "Q4 timeline confirmed"
   Detected: "Q4 Planning" (GID: 123456)
   → Is this correct? [YES/NO]
   ```
5. ✓ You confirm each match
6. ✓ Groups by task
7. ✓ Posts to Asana

**That's it. Done.**

---

## How It Works

### The 6-Phase Workflow

**Phase 1: Detect Project**
- User types: "meeting notes TWG"
- System finds: `Project-TWG/Phase 1/`

**Phase 2: Parse Items**
- Extracts bullets, numbered items, action items
- Creates list of {index, text}

**Phase 3: Confirmation Loop (One Per Item)**
- For each item, search Asana
- Show detection with task name + GID
- Wait for YES / NO / or alternate GID

**Phase 4: Group by Task**
- Collect YES responses
- Group by task GID
- Remove duplicates

**Phase 5: Post to Asana**
- One comment per task
- Multiple items = one grouped comment
- No duplicate posts

**Phase 6: Summary**
```
✓ Processed 5 line items
✓ Posted to 3 Asana tasks
✓ File saved to: Project-TWG/Phase 1/08 - Meeting Notes/2026-09-03-Meeting-Notes.md
```

---

## Zero Configuration

✅ No Asana tokens or `.env` files  
✅ No manual file creation  
✅ No syntax requirements  
✅ No Python knowledge needed  

System uses Asana MCP connector automatically.

---

## Documentation

**Start Here:**
- **[QUICK_START.txt](QUICK_START.txt)** — Beginner 3-step guide (5 min read)
- **[docs/SETUP.md](docs/SETUP.md)** — Setup details and verification

**How to Use:**
- **[MEETING-NOTES-WORKFLOW.md](MEETING-NOTES-WORKFLOW.md)** — Complete workflow guide with examples
- **[SYSTEM-PROMPT-MEETING-NOTES.md](SYSTEM-PROMPT-MEETING-NOTES.md)** — Technical implementation details

**Reference:**
- **[docs/INDEX.md](docs/INDEX.md)** — Navigation guide (find what you need)
- **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** — Common issues & fixes
- **[docs/EMAIL-INTEGRATION.md](docs/EMAIL-INTEGRATION.md)** — Optional: send notes via email

---

## System Requirements

- **Windows 10+**, **macOS**, or **Linux**
- **Python 3.7+** (auto-installs if missing)
- **~200MB** free disk space
- **Internet connection**
- **Claude Code** (any version)
- **Asana account** (free tier works)

---

## Architecture

```
c:\Repo\NemesisProject\              ← Central repo
├── 1-SETUP-INFRASTRUCTURE.bat       ← Step 1: Setup Python
├── 2-CREATE-PROJECT.bat             ← Step 2: Create project
├── 3-CHECK-ASANA.bat                ← Verify MCP connector
├── README.md ← You are here
├── QUICK_START.txt
├── MEETING-NOTES-WORKFLOW.md
├── SYSTEM-PROMPT-MEETING-NOTES.md
├── venv/                            ← Python environment
├── scripts/
├── ClientProjectTemplate/           ← Copied to new projects
├── email-integration/               ← Optional email sync
└── docs/

c:\Repo\Projects\                    ← Your projects (created by Step 2)
├── Project-TWG/
│   ├── Phase 1/
│   │   ├── 00 - Project Overview/
│   │   ├── ...
│   │   └── 08 - Meeting Notes/  ← Your notes go here
│   ├── Phase 2/
│   ├── .claude/settings.json
│   └── README.md
├── Project-BDT/
│   └── ...similar structure
└── Project-Acme/
    └── ...similar structure
```

---

## Features

### 1. Natural Language Input
Just type meeting notes naturally — no special syntax, no file creation.

### 2. Automatic Project Detection
Recognizes:
- "New session meeting notes TWG" → Project-TWG
- "meeting notes for BDT" → Project-BDT
- "notes: Acme" → Project-Acme
- "Nullpoint meeting" → Project-Nullpoint

### 3. Intelligent Line Parsing
Extracts:
- Bullet points (- item)
- Numbered items (1. item)
- Discussion sections
- Action items sections
- Decisions

### 4. Fuzzy Asana Matching
Finds tasks even with:
- Typos ("Qe Planning" → "Q4 Planning")
- Partial names ("Hide" → "Hide Portfolio Summary")
- Abbreviations ("IA" → "Investment Accounting")

### 5. Per-Item User Confirmation
Every match requires explicit YES/NO:
```
Line 1: "Q4 timeline"
Detected: "Q4 Planning" (GID: 123456)
→ Correct? [YES/NO]
```

You say YES/NO — you control what gets posted.

### 6. Smart Grouping
Prevents duplicate comments:
```
Item 1: "Q4 timeline" → Task 123456
Item 4: "Timeline schedule" → Task 123456

Result: ONE comment with both items
        (not two separate comments)
```

### 7. Automatic File Creation
File created automatically:
- Path: `Project-{Name}/Phase {N}/08 - Meeting Notes/`
- Name: `{YYYY-MM-DD}-Meeting-Notes.md`
- Full content saved for reference

---

## Email Integration (Optional)

**Send notes via email instead of typing:**

1. Create email to: `meetingNotes@Alphafmc.com`
2. Subject: `[TWG] Q4 Meeting Notes`
3. Body: Your meeting notes
4. Double-click `email-integration/sync-emails.bat`

Automatically:
- Routes to Project-TWG
- Creates file in 08 - Meeting Notes/
- Processes like typed notes

See [docs/EMAIL-INTEGRATION.md](docs/EMAIL-INTEGRATION.md) for details.

---

## Examples

### Example 1: Simple Status Update
```
New session meeting notes TWG

- Completed Q4 timeline
- Technical review passed
- Ready for Phase 2
```
**Result:** 3 items, 3 confirmations, posted to 3 tasks

### Example 2: Complex Meeting with Duplicates
```
architecture review for BDT

Discussed new system:
- Database schema approved
- API design finalized
- Security review completed

Action items:
- Update deployment docs
- Notify stakeholders about API
- Schedule next review
```
**Result:** 6 items parsed, items 2 & 5 both match "API Design" task → posted to 5 tasks (API Design gets 2 items in one comment)

---

## Troubleshooting

**Something not working?** See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

Quick fixes:
- **Project not detected** → Include project name in text
- **No Asana matches** → Use more specific task names
- **Wrong task matched** → Say NO, enter correct GID
- **File not created** → Check project exists, refresh File Explorer
- **Setup fails** → Python won't install — see TROUBLESHOOTING.md

---

## Ready to Deploy?

This project is:
- ✅ Production-ready
- ✅ Fully documented
- ✅ Tested end-to-end
- ✅ Ready for GitHub

---

## Getting Started Right Now

**New here?** → Read [QUICK_START.txt](QUICK_START.txt) (2 min)

**Ready to set up?** → Double-click:
```
1-SETUP-INFRASTRUCTURE.bat
```

**Need full details?** → See [docs/INDEX.md](docs/INDEX.md) for navigation

**Questions?** → [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

---

Welcome to Nemesis Project. **Type once. Confirm matches. Done.**
