# Tracking Schema

Activity entry schema for file modifications.

## Frontmatter Activity Array

Activity is stored in the `activity` field of MDX frontmatter:

```yaml
---
id: task-example-001
title: Example Task
# ... other fields ...
activity:
  - timestamp: "2026-01-15T10:30:00Z"
    actor:
      type: session
      id: "abc123-def456-ghi789"
    action: created
  - timestamp: "2026-01-15T11:45:00Z"
    actor:
      type: session
      id: "xyz789-abc123-def456"
    parent_id: "abc123-def456-ghi789"
    action: modified
---
```

## Activity Entry Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `timestamp` | string (ISO 8601) | Yes | When modification occurred |
| `actor.type` | string | Yes | Always "session" for now |
| `actor.id` | string | Yes | Session ID making the change |
| `parent_id` | string | No | Parent session ID (sub-agents) |
| `action` | string | Yes | Operation type |

## Action Values

| Action | Description |
|--------|-------------|
| `created` | File was created |
| `modified` | File content changed |
| `deleted` | File was removed (in deletion log) |

## Session ID Format

Session IDs are UUIDs: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

Example: `2eab5989-9a2f-4a5d-8371-6b72a938e98f`

## Parent Chain

Sub-agents have a parent session ID, creating a chain:

```
Main Session: abc-123
  └─ Sub-Agent 1: def-456 (parent: abc-123)
      └─ Sub-Agent 2: ghi-789 (parent: def-456)
```

This enables tracing any modification back to the root session.

## CLI Track Command

```bash
hypercraft activity track \
  --session "current-session-id" \
  --parent "parent-session-id" \    # optional
  --path "$HYPER_WORKSPACE_ROOT/projects/x/y.mdx" \
  --operation "modify"
```

The CLI:
1. Reads current file frontmatter
2. Appends new activity entry
3. Writes updated frontmatter
4. Preserves existing activity history

## Query Commands

### Active Sessions

```bash
# Returns sessions with recent activity (last 5 minutes)
hypercraft activity active --json
```

Response:
```json
{
  "sessions": [
    {
      "id": "abc123",
      "last_activity": "2026-01-15T10:30:00Z",
      "files_modified": ["$HYPER_WORKSPACE_ROOT/projects/x/_project.mdx"],
      "parent_id": null
    }
  ]
}
```

### File History

```bash
# Returns activity history for a file
hypercraft activity history --path "$HYPER_WORKSPACE_ROOT/projects/x/_project.mdx" --json
```

Response:
```json
{
  "path": "$HYPER_WORKSPACE_ROOT/projects/x/_project.mdx",
  "activity": [
    {
      "timestamp": "2026-01-15T10:30:00Z",
      "actor": {"type": "session", "id": "abc123"},
      "action": "created"
    },
    {
      "timestamp": "2026-01-15T11:45:00Z",
      "actor": {"type": "session", "id": "def456"},
      "parent_id": "abc123",
      "action": "modified"
    }
  ]
}
```

## Best Practices

1. **Don't manually edit activity** - Let hooks handle it
2. **Preserve history** - Never truncate activity array
3. **Use CLI for queries** - Consistent parsing
4. **Track meaningful changes** - Status updates, content changes
