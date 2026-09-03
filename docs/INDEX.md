# Documentation Index

Navigate to what you need. Start here, then jump to specific guides.

---

## 🚀 Getting Started (Start Here)

**New to Nemesis Project?** Read in this order:

1. **[QUICK_START.txt](../QUICK_START.txt)** — 3-step guide (2 min read)
   - Double-click 1-SETUP-INFRASTRUCTURE.bat
   - Double-click 2-CREATE-PROJECT.bat
   - Start typing meeting notes
   - **When:** First time setup

2. **[README.md](../README.md)** — Full system overview (5 min read)
   - What Nemesis Project is
   - Key features
   - Architecture overview
   - **When:** Understand the big picture

3. **[MEETING-NOTES-WORKFLOW.md](MEETING-NOTES-WORKFLOW.md)** — How to use (10 min read)
   - Natural-language workflow
   - Examples with input/output
   - Confirmation flow
   - **When:** Ready to start using it

---

## 📋 Reference & Deep Dives

### Core Workflow Documentation

**[MEETING-NOTES-WORKFLOW.md](MEETING-NOTES-WORKFLOW.md)** — User guide
- How to type meeting notes
- What happens automatically
- Confirmation prompts
- Project detection
- **Read when:** You need to understand how to use the system

**[../SYSTEM-PROMPT-MEETING-NOTES.md](../SYSTEM-PROMPT-MEETING-NOTES.md)** — Technical implementation
- Phase-by-phase workflow steps
- Exact algorithm
- Tool calls (asana_search_tasks, asana_create_task_story)
- Error handling logic
- **Read when:** You want to understand how it works internally

**[../MEETING-NOTES-WORKFLOW.md](../MEETING-NOTES-WORKFLOW.md)** — Complete automation guide
- Every step of the workflow
- Examples (simple, complex, with duplicates)
- Grouping logic
- File creation details
- **Read when:** You need complete details

### Setup & Configuration

**[SETUP.md](SETUP.md)** — Installation and configuration
- 1-SETUP-INFRASTRUCTURE.bat details
- 2-CREATE-PROJECT.bat details
- 3-CHECK-ASANA.bat details
- What gets created
- **Read when:** You're setting up or something went wrong during setup

**[../QUICK_START.txt](../QUICK_START.txt)** — Super simple 3-step guide
- Plain English, no jargon
- Exact file names to double-click
- What to expect at each step
- **Read when:** You want the absolute simplest instructions

### Optional Features

**[EMAIL-INTEGRATION.md](EMAIL-INTEGRATION.md)** — Email-to-notes
- Send meeting notes via email
- Subject line routing
- Automatic folder routing
- Running sync-emails.bat
- **Read when:** You want to sync notes from email

### Troubleshooting

**[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** — Common issues and fixes
- Setup failures (Python installation, venv, imports)
- Project creation errors
- Meeting notes detection issues
- Asana matching and confirmation problems
- File creation and folder issues
- Quick reference table
- **Read when:** Something isn't working

---

## 🎯 Find What You Need

### "I'm brand new. Where do I start?"
→ **[QUICK_START.txt](../QUICK_START.txt)**

### "I want to understand the whole system"
→ **[README.md](../README.md)** then **[MEETING-NOTES-WORKFLOW.md](MEETING-NOTES-WORKFLOW.md)**

### "How do I write and sync meeting notes?"
→ **[MEETING-NOTES-WORKFLOW.md](MEETING-NOTES-WORKFLOW.md)**

### "How does it work internally?"
→ **[../SYSTEM-PROMPT-MEETING-NOTES.md](../SYSTEM-PROMPT-MEETING-NOTES.md)**

### "Setup failed, something's wrong"
→ **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**

### "I want to use email to send notes"
→ **[EMAIL-INTEGRATION.md](EMAIL-INTEGRATION.md)**

### "What gets created when I run setup?"
→ **[SETUP.md](SETUP.md)**

---

## 📂 File Structure

**Root level** (C:\Repo\NemesisProject\):
- `README.md` — System overview
- `QUICK_START.txt` — 3-step beginner guide
- `MEETING-NOTES-WORKFLOW.md` — User workflow guide
- `SYSTEM-PROMPT-MEETING-NOTES.md` — Technical implementation
- `1-SETUP-INFRASTRUCTURE.bat` — Python/venv setup
- `2-CREATE-PROJECT.bat` — Project creation
- `3-CHECK-ASANA.bat` — MCP connector check

**docs/** (C:\Repo\NemesisProject\docs\):
- `INDEX.md` ← You are here
- `SETUP.md` — Setup details
- `TROUBLESHOOTING.md` — Common issues
- `EMAIL-INTEGRATION.md` — Email sync guide

---

## 🔄 Typical User Journey

```
1. Read QUICK_START.txt
   ↓
2. Double-click 1-SETUP-INFRASTRUCTURE.bat
   ↓
3. Double-click 2-CREATE-PROJECT.bat
   ↓
4. Read MEETING-NOTES-WORKFLOW.md
   ↓
5. Open Claude Code and type meeting notes
   ↓
6. Confirm matches (YES/NO)
   ↓
7. Done! Notes are in Asana
   ↓
8. (Optional) Read EMAIL-INTEGRATION.md to send notes via email
   ↓
9. (If stuck) Read TROUBLESHOOTING.md
```

---

## ✅ Docs Checklist

- [x] README.md — System overview
- [x] QUICK_START.txt — Beginner guide
- [x] MEETING-NOTES-WORKFLOW.md — User workflow
- [x] SYSTEM-PROMPT-MEETING-NOTES.md — Technical details
- [x] SETUP.md — Setup instructions
- [x] TROUBLESHOOTING.md — Common issues (updated for new workflow)
- [x] EMAIL-INTEGRATION.md — Email sync
- [x] INDEX.md — Navigation (you are here)

---

## Questions?

- **Setup issue?** → TROUBLESHOOTING.md
- **How to use?** → MEETING-NOTES-WORKFLOW.md
- **How it works?** → SYSTEM-PROMPT-MEETING-NOTES.md
- **Email sync?** → EMAIL-INTEGRATION.md
- **Still stuck?** → README.md

Start with QUICK_START.txt. Everything else links from there.
