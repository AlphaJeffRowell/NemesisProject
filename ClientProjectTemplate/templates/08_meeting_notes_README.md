# Meeting Notes

This section contains meeting notes and discussions that automatically sync to Asana.

## How It Works

Type naturally in Claude Code and I handle everything automatically:

```
New session meeting notes <ProjectName>

Your meeting notes here...
- Discussion point 1
- Action item 1
- Action item 2
```

**Process:**
1. I create a file in this folder with your notes
2. I parse the line items (bullets, discussions, action items)
3. I search Asana for matching tasks
4. I ask for confirmation on each match
5. I post confirmed items as comments on Asana tasks (grouped by task GID)

## Example

**Input:**
```
New session meeting notes TWG

Test meeting with stakeholders.

Discussed:
- Q4 implementation timeline of hiding hubs
- Technical requirements approved

Action items:
- Hide Portfolio Summary
- Schedule showcase
- Prepare development environment
```

**Output:**
```
Detected task: "Q4 Implementation - Hide Hubs" (GID: 1215428532115696)
  → is this correct for "Q4 implementation timeline of hiding hubs"? 
  [YES / NO]

Detected task: "Hide Portfolio Summary" (GID: 1215428532115697)
  → is this correct for "Hide Portfolio Summary"?
  [YES / NO]

... (confirmation for each item)

Result: Posted 6 items to 3 Asana tasks ✓
```

## File Organization

Create subfolders as needed:
- Meeting Notes/Client Meetings/
- Meeting Notes/Internal/
- Meeting Notes/Steering Committee/

## What Gets Posted to Asana

Each line item becomes a comment on its matched Asana task:

**Example comment on task "Q4 Implementation":**
```
From meeting 2026-09-03:
- Q4 implementation timeline of hiding hubs
- Technical requirements approved
```

All items for the same task post in ONE comment (no duplicates).

## Getting Started

Open Claude Code in this project folder and type:

```
New session meeting notes <YourProjectName>

Your notes here...
```

That's it. No setup, no tokens, no configuration. Just write naturally.

---

**Note:** Line items must be distinct action items, decisions, or discussion points. Short, clear bullet points work best for parsing.
