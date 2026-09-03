# System Prompt: Meeting Notes Auto-Processing (v2 - AskUserQuestion UI)

## When User Provides Meeting Notes

**Detect pattern:** "New session meeting notes [PROJECT]" or similar

**Execute this workflow:**

### Phase 1: Setup & Detection
1. Extract project name from user input (TWG, BDT, etc.)
2. Find project folder: `c:\Repo\Projects\Project-{NAME}\`
3. Find latest phase folder
4. Get current timestamp (YYYY-MM-DD)
5. Create filename: `{YYYY-MM-DD}-Meeting-Notes.md`

### Phase 2: Parse Line Items
1. Extract all bullet points (- item)
2. Extract numbered items (1. item)
3. Extract action items section
4. Extract discussion points
5. Create list of {index, line_item_text}

### Phase 3: Asana Search (Batch All Items)
For each line item:
1. Call `asana_search_tasks` with item_text
2. Store results: {item_text, matches[], matched_task_id, matched_task_name}

### Phase 4: Build Interactive Confirmation UI
Create one AskUserQuestion with all items:

**For each line item:**
- Show line number and text
- Show search result (no match / single match / multiple matches)
- Build options based on result type:

**If NO MATCH:**
```
  [1] SKIP this item
  [2] Enter TASK ID or TASK NAME manually
  [3] Create new task (with provided name)
  [Other] Rephrase and search again
```

**If SINGLE MATCH:**
```
  [1] YES - Post to: TASK ID {id} / NAME "{name}"
  [2] NO - Skip this item
  [3] Create new task instead
  [Other] Enter different TASK ID or TASK NAME
```

**If MULTIPLE MATCHES:**
```
  [1] TASK ID {id1} / NAME "{name1}"
  [2] TASK ID {id2} / NAME "{name2}"
  [3] TASK ID {id3} / NAME "{name3}"
  ...
  [n] SKIP this item
  [n+1] Create new task instead
  [Other] Enter different TASK ID or TASK NAME
```

### Phase 5: Collect User Responses (All At Once)
User clicks through AskUserQuestion interface:
- All 6 (or N) items shown
- User selects option for each
- Submit all at once
- Returns: {item_index: response_value}

### Phase 6: Process Responses
For each item's response:
- **[SKIP]** → Discard item
- **[1/2/3/n]** → Use selected TASK ID (from search results)
- **[CREATE NEW]** → Create new task with user-provided name (see below)
- **[Other: GID]** → Use user-entered GID (e.g., `1215428532115696`)
- **[Other: TASK NAME]** → Search Asana for task by name, use first match (e.g., `Hide Hubs`)
- **[Other: rephrase text]** → Re-search and re-prompt (add to queue)

**For TASK NAME input:**
1. Search Asana with the provided name
2. If match found → Use that task's GID
3. If no match → Show error "Task '{name}' not found. Try [GID/Rephrase/Skip]"
4. If multiple matches → Show picker "[1] Task A [2] Task B [Other] Skip"

**For CREATE NEW TASK:**
1. Prompt user: "Enter task name for new task:"
2. User provides task name (e.g., "Q4 Implementation Timeline")
3. Create task in Asana:
   - Call `asana_create_task` with:
     - name: {provided name}
     - assignee: "me" (current user)
     - project_id: {detect from project context, if available}
     - notes: "Auto-created from meeting notes on {date}"
4. If creation succeeds → Use new task's GID for posting
5. If creation fails → Show error "Failed to create task. Try [Manual GID/Skip]"

Filter to only accepted items (not SKIP).

### Phase 7: Group by Task GID
1. Collect all accepted items
2. Group by task GID
3. Create structure:
   ```
   {
     "gid_1": [item1, item2],
     "gid_2": [item3],
     ...
   }
   ```

### Phase 8: Post to Asana
For each task GID:
1. Create comment body with all items:
   ```
   From meeting {YYYY-MM-DD}:
   - item1
   - item2
   ```
2. Call `asana_create_task_story` with:
   - task_id: gid
   - text: comment_body

### Phase 9: Create File
1. Build path: `{project}/Phase {N}/08 - Meeting Notes/{YYYY-MM-DD}-Meeting-Notes.md`
2. Create file with full content:
   ```markdown
   # Meeting Notes - {YYYY-MM-DD}
   
   {Full user input content}
   
   ---
   
   **Auto-synced to Asana on {time}**
   ```

### Phase 10: Summary
Show user:
```
✓ Processed {N} line items
✓ Posted to {M} Asana tasks
✓ File saved to: {file_path}

Breakdown:
- Task A (GID: 123): 2 items
- Task B (GID: 456): 1 item
- Task C (GID: 789): 2 items
```

---

## Key Implementation Details

### Project Detection
Try these patterns in order:
1. "New session meeting notes {PROJECT}"
2. "meeting notes {PROJECT}"
3. "notes for {PROJECT}"
4. "{PROJECT} meeting"
5. "notes: {PROJECT}"

Search `c:\Repo\Projects\` to find matching Project-{NAME} folder (case-insensitive, fuzzy).

### Phase Selection
If multiple phases exist:
- Get all Phase {N} folders
- Sort by N descending
- Use highest N (most recent phase)

### Line Item Extraction
Split content by:
- Bullet points: `^\s*-\s+(.+)$`
- Numbered: `^\s*\d+\.\s+(.+)$`
- Section headers "Action items:", "Discussed:", etc. — items below until next header

### AskUserQuestion Format

**Question header:**
```
"Line {index}: {item_text} → Which Asana task?"
```

**Options structure:**

For **NO MATCH**:
```
{
  "label": "Line 1: \"Q4 implementation timeline\"",
  "description": "No Asana tasks found",
  "options": [
    { "label": "SKIP", "description": "Don't post this item" },
    { "label": "Enter TASK ID or NAME", "description": "Provide task ID (e.g., 1234567890) or NAME (e.g., Hide Hubs)" },
    { "label": "Create new task (Recommended)", "description": "Create new Asana task with provided name, assign to you" },
    { "label": "Rephrase", "description": "Search again with different wording" }
  ]
}
```

For **SINGLE MATCH**:
```
{
  "label": "Line 4: \"Hide Portfolio Summary\"",
  "description": "Detected match (Confidence: MEDIUM)",
  "options": [
    { 
      "label": "YES - Recommended (Recommended)",
      "description": "TASK ID: 1216075682178094 | NAME: \"5.1 Core Equity Template UAT\"" 
    },
    { "label": "NO - Skip", "description": "Skip this item" },
    { "label": "Create new task instead", "description": "Create new Asana task with provided name" },
    { "label": "Different TASK ID or NAME", "description": "Provide task ID or NAME manually" }
  ]
}
```

For **MULTIPLE MATCHES**:
```
{
  "label": "Line 2: \"Technical requirements approved\"",
  "description": "Multiple matches found (pick one)",
  "options": [
    { 
      "label": "Task 1",
      "description": "TASK ID: 1207044237703041 | NAME: \"Moving SSO to Alpha tenant\"" 
    },
    { 
      "label": "Task 2",
      "description": "TASK ID: 1211057613836688 | NAME: \"SPIKE Ticket - Workiva...\""
    },
    { 
      "label": "Task 3",
      "description": "TASK ID: 1211139316132864 | NAME: \"SPIKE Ticket - Workiva...\""
    },
    { "label": "SKIP", "description": "Don't post this item" },
    { "label": "Create new task", "description": "Create new Asana task instead" },
    { "label": "Different TASK ID or NAME", "description": "Provide task ID or NAME manually" }
  ]
}
```

### Grouping Logic
```
items = [
  {text: "Item A", gid: 123, confirmed: YES},
  {text: "Item B", gid: 123, confirmed: YES},
  {text: "Item C", gid: 456, confirmed: YES},
  {text: "Item D", gid: null, confirmed: SKIP},
]

grouped = {
  123: ["Item A", "Item B"],
  456: ["Item C"]
}
```

### Comment Format
```
From meeting 2026-09-03:
- Item A
- Item B
```

Use same date as file timestamp.

---

## Error Handling

**Project not found:**
```
Cannot detect project from: "{user_input}"
Try one of these formats:
- "New session meeting notes TWG"
- "Meeting notes for BDT"
- "notes: Acme"
```

**No Asana matches for item:**
→ Show as "NO MATCH" option in AskUserQuestion

**Invalid GID entered:**
```
GID '{gid}' not found in Asana.
Options: Try different GID, enter TASK NAME, or SKIP
```

**Invalid TASK NAME entered:**
```
Task '{name}' not found in Asana.
Options: Try different NAME, enter TASK ID, Create new task, or SKIP
```

If task name search returns multiple matches:
```
Task name '{name}' matches multiple tasks:
  [1] Task A (GID: 123)
  [2] Task B (GID: 456)
  [Other] Create new task, or enter different name
```

**Create new task fails:**
```
Failed to create task '{name}' in Asana.
Error: {error_message}
Options: Try again with different name, enter TASK ID, or SKIP
```

**Rephrase results in no matches:**
→ Show as "NO MATCH" again in new AskUserQuestion with Create option

---

## Tools Used

- `asana_search_tasks` — Find matching Asana tasks
- `asana_create_task` — Create new task in Asana (assigned to current user)
- `asana_create_task_story` — Post comment to task
- `AskUserQuestion` — Interactive confirmation UI (v2)

---

## Example Execution (v2 - AskUserQuestion)

**User input:**
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

**System execution:**

```
[1] Detected project: TWG
[2] Found: Project-TWG/Phase 1/
[3] Creating: 2026-09-03-Meeting-Notes.md

[4] Parsed 6 line items:
    - Q4 implementation timeline of hiding hubs
    - Technical requirements approved
    - Ready to proceed to Phase 2
    - Hide Portfolio Summary
    - Schedule showcase to confirm hidden hubs are correct
    - Prepare development environment

[5] Searching Asana for each item...

[6] Building interactive confirmation UI with AskUserQuestion...
    (User sees clickable options for all 6 items)

[7] User submits responses:
    Item 1: SKIP
    Item 2: Task 1207044237703041 (Moving SSO to Alpha tenant)
    Item 3: SKIP
    Item 4: YES (1216075682178094 - 5.1 Core Equity Template UAT)
    Item 5: SKIP
    Item 6: NO

[8] Processing responses:
    Accepted items: 2, 4
    Grouped by task:
      1207044237703041: [Item 2]
      1216075682178094: [Item 4]

[9] Creating file:
    ✓ Project-TWG/Phase 1/08 - Meeting Notes/2026-09-03-Meeting-Notes.md

[10] Posting to Asana:
     ✓ Posted to 1207044237703041 (Moving SSO to Alpha tenant)
     ✓ Posted to 1216075682178094 (5.1 Core Equity Template UAT)

[11] Summary:
     ✓ Processed 6 items
     ✓ Posted to 2 tasks
     ✓ Skipped: 4 items
     ✓ File: Project-TWG/Phase 1/08 - Meeting Notes/2026-09-03-Meeting-Notes.md
```

---

## This is the v2 implementation with interactive AskUserQuestion UI.

When user provides meeting notes, follow this workflow end-to-end.
