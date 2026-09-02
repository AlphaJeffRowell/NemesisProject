# Auto-Detection Guide

## How It Works

The system automatically detects task references in your notes **without requiring special syntax**. Three detection methods work together:

### Method 1: Explicit References (Highest Priority)

Use explicit `@task` syntax when you want to be certain:

```markdown
@task search:"Task Name"
Your comment here.

@task name:"Exact Task Name"
Another comment.

@task #27
Reference by issue number.

@task gid:1212383809935634
Direct GID reference.
```

**Confidence:** 100% — Always syncs

---

### Method 2: Bare Issue Numbers (Medium Priority)

Just mention the issue number anywhere:

```markdown
Fixed bug #27 in the Bloomberg integration.
```

→ Automatically finds task #27 if unique

**Confidence:** 80% if unique match, skips if ambiguous

---

### Method 3: Task Name Matching (Auto-Detection)

Write naturally and the system finds related tasks:

```markdown
Bloomberg integration complete. Ready for production.
```

→ Searches for "Bloomberg" in task names
→ Finds "Bloomberg Integration #27"
→ Auto-syncs with confidence score

**Confidence:** Varies (0.6 to 1.0) based on match quality

---

## Confidence Scores

| Score | Action |
|-------|--------|
| **1.0** | Explicit @task syntax — always syncs |
| **0.9+** | Exact or near-exact match — auto-syncs |
| **0.75-0.90** | Good match — shows options if ambiguous |
| **0.60-0.75** | Partial match — requires clarification |
| **<0.60** | Poor match — skipped (use @task instead) |

---

## Examples

### Example 1: Clear Auto-Detect

```markdown
Bloomberg integration progressing. All tests passing.
```

**System detects:**
- Task: "Bloomberg Integration #27"
- Confidence: 0.95
- Action: ✓ Auto-syncs

**Result:** Comment posted to task #27

---

### Example 2: Ambiguous (Requires Clarification)

```markdown
Entity workflow fixed and tested.
```

**System detects:**
- "Entity Management #1" (confidence: 0.72)
- "Sub-Entity Design #4" (confidence: 0.68)
- "Legal Entity Mapping #8" (confidence: 0.65)
- Action: Shows options to user

**Interactive Prompt:**
```
Multiple possible tasks found:
[0] Entity Management #1 (72%)
[1] Sub-Entity Design #4 (68%)
[2] Legal Entity Mapping #8 (65%)

Pick task (0-2) or skip (s):
```

---

### Example 3: Mixed Explicit + Auto

```markdown
Bloomberg integration complete. #27

Entity workflow improvements documented.

@task search:"Fix Bug"
Fixed the authentication flow.
```

**System detects:**
- Para 1: Issue #27 → Bloomberg task (confidence: 1.0 — explicit)
- Para 2: "Entity" ambiguous → Shows options
- Para 3: Explicit @task → Always syncs

**Result:** Para 1 auto-syncs, Para 2 asks user, Para 3 auto-syncs

---

### Example 4: Multi-Paragraph Grouping

```markdown
Bloomberg integration progressing.

Fixed connection timeout issue.
Still working on auth flow.
```

**System detects:**
- Para 1: "Bloomberg" → Task #27 (confidence: 0.95)
- Para 2: No new task → Groups under #27
- Para 3: No new task → Groups under #27

**Result:** All three paragraphs sync as one comment to task #27

---

## Best Practices

### ✓ DO: Use explicit @task for clarity

```markdown
@task search:"High Priority Item"
Completed the critical deliverable.
```

### ✗ DON'T: Mix multiple references in one paragraph

```markdown
✗ Bloomberg integration done. Entity structure updated.
```
→ System may pick wrong task or show ambiguous options

**Instead:**

```markdown
✓ Bloomberg integration done.

✓ Entity structure updated.
```

---

### ✓ DO: Use natural language with clear keywords

```markdown
✓ Bloomberg DLWS connection established.
✓ Entity hierarchy validated.
✓ Financial template pushed to production.
```

### ✗ DON'T: Use ambiguous short names

```markdown
✗ Entity workflow fixed.
✗ Fixed bug.
✗ Status update.
```

---

## Configuration

Auto-detection threshold (default: 0.75) can be adjusted in `.claude/settings.json`:

```json
{
  "detection": {
    "confidence_threshold": 0.75,
    "enable_fuzzy": true
  }
}
```

- **Lower threshold (0.6):** More auto-syncs, more risk of wrong task
- **Higher threshold (0.9):** Safer, but requires more user confirmation

---

## Fallback: Explicit @task

If auto-detection isn't working, **explicit @task always works**:

```markdown
@task search:"Task Name"
Your content here.
```

This guarantees sync with 100% confidence.

---

## Troubleshooting

**"Task not found"**
→ Use explicit @task syntax with exact name

**"Wrong task synced"**
→ Use explicit @task to override auto-detection

**"Ambiguous prompt appearing"**
→ Use explicit @task or pick option from prompt

**"Task name is abbreviation (e.g., 'BDT')"**
→ Fuzzy matching may struggle with abbreviations — use explicit @task

---

## How to Test

1. Create a test note: `08 - Meeting Notes/Test_AutoDetect.md`
2. Add various references:
   ```markdown
   Bloomberg integration complete.
   @task search:"Test Task"
   #27
   Entity workflow updated.
   ```
3. Run: `python scripts/asana-sync-enhanced.py --dry-run`
4. Review proposals before syncing

---

**Auto-detection works best with clear, natural language task names.**
