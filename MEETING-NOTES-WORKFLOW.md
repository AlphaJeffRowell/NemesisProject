# Meeting Notes Workflow — Complete Automation

## How to Use

**In any Claude Code session:**

```
New session meeting notes TWG

Test meeting with TWG stakeholders on 2026-09-03.

Discussed:
- Q4 implementation timeline of hiding hubs
- Technical requirements approved
- Ready to proceed to Phase 2

Action items:
- Hide Portfolio Summary
- Schedule showcase to confirm hidden hubs are correct
- Prepare development environment
```

**That's it.** System does everything automatically.

## What Happens Automatically

### 1. Project Detection
Extracts "TWG" → Finds `Project-TWG/Phase 1/`

### 2. File Creation
Creates: `Project-TWG/Phase 1/08 - Meeting Notes/2026-09-03-Meeting-Notes.md`

### 3. Line Parsing
Extracts 6 line items:
- Q4 implementation timeline of hiding hubs
- Technical requirements approved
- Ready to proceed to Phase 2
- Hide Portfolio Summary
- Schedule showcase to confirm hidden hubs are correct
- Prepare development environment

### 4. Asana Search & Confirmation Loop
For each item, shows:
```
Line 1: "Q4 implementation timeline of hiding hubs"
Searching Asana...
Detected: "Q4 Implementation - Hide Hubs" (GID: 1215428532115696)
→ Is this correct? [YES/NO]

Line 2: "Technical requirements approved"
Searching Asana...
Detected: "Technical Requirements Review" (GID: 1215428532115697)
→ Is this correct? [YES/NO]

[continues for all 6 items...]
```

### 5. User Confirmation
User responds: `YES` or `NO` for each match

### 6. Grouping by Task
Groups confirmed items by task GID:
```
Task 1215428532115696 (Q4 Implementation - Hide Hubs):
  - Q4 implementation timeline of hiding hubs
  - Schedule showcase to confirm hidden hubs are correct

Task 1215428532115697 (Technical Requirements Review):
  - Technical requirements approved

Task 1215428532115698 (Phase Planning):
  - Ready to proceed to Phase 2

... etc
```

### 7. Asana Posting
Posts ONE comment per task:

**Task 1215428532115696:**
```
From meeting 2026-09-03:
- Q4 implementation timeline of hiding hubs
- Schedule showcase to confirm hidden hubs are correct
```

### 8. Summary
```
✓ Processed 6 line items
✓ Posted to 4 Asana tasks
✓ File saved to: Project-TWG/Phase 1/08 - Meeting Notes/2026-09-03-Meeting-Notes.md
```

---

## Project Detection

System recognizes:
- "New session meeting notes TWG" → Project-TWG
- "meeting notes for BDT" → Project-BDT
- "notes: Acme" → Project-Acme
- "Nullpoint meeting" → Project-Nullpoint

Works with any client name in your `c:\Repo\Projects\` folder.

---

## Confirmation Options

For each item:
- **YES** → Post to that task
- **NO** → Skip this item
- **Other task GID** → Post to a different task

Example:
```
Line 3: "Hide Portfolio Summary"
Detected: "Hide Portfolio Summary" (GID: 1215428532115698)
→ Is this correct? [YES/NO/or enter GID]

User: NO
→ Skipped.

OR

User: 1234567890
→ Will post to task 1234567890 instead.
```

---

## One-Shot Workflow

**Start to finish in one Claude session:**
1. User types meeting notes
2. System processes automatically
3. User confirms matches (YES/NO)
4. System posts to Asana
5. Done

**No file creation. No manual steps. No complexity.**

---

## Supported Formats

All of these work:

**Format 1: Header style**
```
New session meeting notes TWG

Met with stakeholders...
- Item 1
- Item 2
```

**Format 2: Inline project**
```
Meeting notes for TWG:

Discussion:
- Item 1
- Item 2
```

**Format 3: Simple**
```
TWG notes

- Item 1
- Item 2
```

**Format 4: Email-style**
```
Subject: Notes - BDT Project

Body:
- Item 1
- Item 2
```

---

## Smart Features

### Automatic Grouping
Same task mentioned multiple times = ONE comment

```
Items 1 & 4 both match: Q4 Implementation (GID: 123456)
→ Single comment with both items (no duplicates)
```

### Fuzzy Matching
Finds tasks even with typos/partial names:
- "Qe planning" → "Q4 Planning"
- "hide portfolio" → "Hide Portfolio Summary"
- "tech review" → "Technical Requirements Review"

### Phase Detection
Automatically uses latest phase if multiple exist:
- Project-TWG has Phase 1 & Phase 2
- System uses Phase 2 (most recent)

---

## Examples

### Example 1: Simple Status Update

**Input:**
```
New session meeting notes TWG

Quick standup today.

- Completed Q4 timeline
- Technical review passed
- Ready for Phase 2
```

**Processing:**
- Creates file
- Parses 3 items
- Shows 3 confirmations
- User confirms all YES
- Posts to 3 tasks
- Done

### Example 2: Complex Meeting with Duplicates

**Input:**
```
architecture review for BDT

Discussed the new system:
- Database schema approved
- API design finalized
- Security review completed

Action items:
- Update deployment docs
- Notify stakeholders about API changes
- Schedule next review
```

**Processing:**
- Creates file
- Parses 6 items
- Shows confirmations
- Items 2 & 5 both match "API Design" task
- Groups them together
- Posts 6 items to 5 tasks (API Design gets 2 items in one comment)
- Done

---

## That's It

**Type once. Confirm matches. Done.**

No files to create. No setup. Maximum automation.
