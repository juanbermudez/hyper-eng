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
- [Session Registry Schema](./references/session-registry-schema.md) - Per-session file format

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

## Session Workspace Metadata (Sidecar Files)

In addition to per-file activity tracking, the system creates sidecar files next to Claude Code session transcripts:

```
~/.claude/projects/{encoded-path}/
├── abc-123-def.jsonl        ← Claude Code transcript (existing)
├── abc-123-def.hyper.json   ← Workspace metadata (our sidecar)
└── ...
```

### Sidecar File Format

```json
{
  "sessionId": "abc-123-def",
  "parentId": "xyz-789",
  "workspaceRoot": "~/.hyper/accounts/user/hyper/workspaces/ws-123",
  "currentTarget": {
    "type": "task",
    "taskId": "task-001",
    "projectSlug": "auth-system",
    "filePath": "$HYPER_WORKSPACE_ROOT/projects/auth/tasks/task-001.mdx"
  },
  "recentTargets": [...],
  "startedAt": "2026-01-18T10:00:00Z",
  "lastActivity": "2026-01-18T10:05:00Z"
}
```

### Target Types

| Type | Fields | Example |
|------|--------|---------|
| `task` | `taskId`, `projectSlug`, `filePath` | Working on a specific task |
| `project` | `projectSlug`, `filePath` | Working on project spec |
| `resource` | `projectSlug`, `resourcePath`, `filePath` | Writing research docs |
| `initiative` | `initiativeSlug`, `filePath` | Working on initiative |
| `doc` | `docSlug`, `filePath` | Writing documentation |
| `other` | `filePath` | Other workspace files |

### Design Rationale

1. **Integrates with existing sessions** - Same directory app already watches
2. **Natural association** - Session ID matches JSONL filename
3. **No new directories** - Leverages `~/.claude/projects/` structure
4. **Easy to merge** - Combine JSONL + sidecar at load time
5. **No TTL needed** - Persists with parent session

## Integration with Desktop

The Hyperbench desktop app uses:

### Activity (per-file)
- Display modification history
- Link sessions to changes
- Audit trail for files

### Session Sidecar (per-session)
- Extend existing session metadata with workspace context
- Show which project/task a session is working on
- Query sessions by project via TanStack DB
- Display workspace activity badges on session list
