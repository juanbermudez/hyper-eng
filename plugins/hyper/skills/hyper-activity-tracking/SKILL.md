---
name: hyper-activity-tracking
description: This skill provides activity tracking for file modifications in the $HYPER_WORKSPACE_ROOT/ directory. It captures session IDs, parent chains, and operation types automatically via PostToolUse hooks.
version: 1.0.0
system: true
allowed-tools:
  - Read
  - Bash
---

# Hyper Activity Tracking

System skill that tracks file modifications with session lineage.

## Overview

Activity tracking captures:
- Which session modified a file
- Parent session chain (for sub-agents)
- Operation type (create, modify, delete)
- Timestamp

This enables:
- Attributing changes to specific sessions
- Tracing sub-agent work back to parent
- Displaying active sessions in UI

## Reference Documents

- [Tracking Schema](./references/tracking-schema.md) - Activity entry format

## Activity Schema

<hyper-embed file="references/tracking-schema.md" />

## How Tracking Works

### PostToolUse Hook

When a file in `$HYPER_WORKSPACE_ROOT/` is modified, the PostToolUse hook:

1. Detects Write/Edit tool completion
2. Extracts file path and session ID
3. Calls `hyper activity track` with metadata
4. Activity is appended to file's frontmatter

### Session ID Sources

| Environment Variable | Description |
|---------------------|-------------|
| `CLAUDE_SESSION_ID` | Current session identifier |
| `CLAUDE_PARENT_SESSION_ID` | Parent session (if sub-agent) |

### Tracked Operations

| Operation | When |
|-----------|------|
| `create` | New file created |
| `modify` | Existing file edited |
| `delete` | File removed |

## CLI Commands

```bash
# Track activity (called by hook)
hyper activity track \
  --session "$CLAUDE_SESSION_ID" \
  --parent "$CLAUDE_PARENT_SESSION_ID" \
  --path "$HYPER_WORKSPACE_ROOT/projects/x/tasks/task-001.mdx" \
  --operation "modify"

# Query active sessions
hyper activity active --json

# Query file history
hyper activity history --path "$HYPER_WORKSPACE_ROOT/projects/x/_project.mdx"
```

## Activity Entry Format

Appended to frontmatter `activity` array:

```yaml
activity:
  - timestamp: "2026-01-15T10:30:00Z"
    actor:
      type: session
      id: "abc123-def456"
    parent_id: "parent-session-id"  # if sub-agent
    action: modified
```

## Best Practices

- Activity tracking is automatic via hooks
- Don't manually add activity entries
- Use CLI for activity queries
- Parent chain enables sub-agent tracing

## Integration with Desktop

The Hyperbench desktop app uses activity to:
- Show active session indicators
- Display modification history
- Link sessions to changes
