# Email to Notes Sync

Automatically syncs emails from `meetingNotes@Alphafmc.com` to project folders.

**Status:** Mock test version (real connector integration coming soon)

## How It Works

1. **Email criteria:** Email must have `meetingNotes@Alphafmc.com` in CC or BCC
2. **Subject line:** Must contain `[ProjectName]` tag
3. **Routing:** Automatically routes to `Project-<Name>/Phase <N>/08 - Meeting Notes/`
4. **File naming:** `sender-subject-timestamp.md`
5. **Attachments:** Saved to `07 - Documentation/`
6. **Asana:** Automatically syncs to Asana tasks

## Testing

### Run Mock Test

```bash
python sync-emails.py
```

This tests the routing logic with simulated emails:
- `[TWG]` format
- `BDT-Phase1` format (alternative)
- Invalid project (skipped)
- No project tag (skipped)

**Output:** Files created in `08 - Meeting Notes/` for valid projects

## Usage (When Real Connector Ready)

### In Claude Code

```bash
/sync-emails
```

This syncs all emails matching the criteria across ALL projects.

### For Specific Project (Future)

```bash
/sync-emails TWG
```

## Setup

No setup required. Uses Claude's authenticated Microsoft 365 connector.

## Email Format

### Format 1: [ProjectName] (Recommended)

**To:** (any recipients)
**CC/BCC:** `meetingNotes@Alphafmc.com`
**Subject:** `[TWG] Q4 Planning Meeting`
**Body:** Your meeting notes

### Format 2: ProjectName-PhaseN (Alternative)

**Subject:** `BDT-Phase1 Technical Requirements`

Both formats are supported and automatically routed.

### Example

```
To: team@company.com
CC: meetingNotes@Alphafmc.com
Subject: [TWG] Q4 Planning Meeting - Sept 2
Body: 
Met with Bloomberg team today.
Discussed integration timeline.
Ready for Phase 2.
```

→ Saved to: `c:\Repo\Projects\Project-TWG\Phase 1\08 - Meeting Notes\jeff-q4-planning-meeting-20260902-143022.md`
→ Auto-syncs to Asana

## Features

- ✅ Dual subject format: `[ProjectName]` and `ProjectName-PhaseN`
- ✅ Fuzzy project name matching (handles typos)
- ✅ Auto-routes to latest phase
- ✅ Multi-project support (concurrent projects)
- ✅ Hybrid format testing (mock test included)
- ✅ Graceful error handling (invalid emails skipped)
- ⏳ Attachment saving (coming with real connector)
- ⏳ Automatic Asana sync (coming with real connector)

## Error Handling

- **No [ProjectName]:** Email skipped (silent)
- **Project not found:** Email skipped (silent)
- **No phases in project:** Email skipped (silent)

If emails aren't syncing, check:
1. Email has `meetingNotes@Alphafmc.com` in CC or BCC
2. Subject contains `[ProjectName]` (e.g., `[TWG]`)
3. Project folder exists at `c:\Repo\Projects\Project-<Name>\`

---

**Ready to use.** Just send emails with the correct format.
