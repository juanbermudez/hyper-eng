# Session Workspace Metadata Schema

Sidecar files that track Claude Code session workspace context and agent hierarchy.

## File Location

```
~/.hyper/sessions/
├── abc-123-def.json         ← Session metadata (indexed by session ID)
├── xyz-789-ghi.json
└── ...
```

Sessions are stored in a centralized `~/.hyper/sessions/` directory, indexed by session ID.

## Sidecar File Schema

```json
{
  "sessionId": "abc-123-def",
  "parentId": "xyz-789",
  "transcriptPath": "~/.claude/projects/{encoded-path}/abc-123-def.jsonl",
  "workspaceRoot": "~/.hyper/accounts/user/hyper/workspaces/ws-123",
  "currentTarget": {
    "type": "task",
    "taskId": "task-001",
    "projectSlug": "auth-system",
    "filePath": "$HYPER_WORKSPACE_ROOT/projects/auth/tasks/task-001.mdx"
  },
  "recentTargets": [
    { "type": "task", "taskId": "task-001", "projectSlug": "auth-system", "filePath": "..." },
    { "type": "project", "projectSlug": "auth-system", "filePath": "..." }
  ],
  "startedAt": "2026-01-18T10:00:00Z",
  "lastActivity": "2026-01-18T10:05:00Z",
  "agent": {
    "role": "squad-leader",
    "name": "Captain Zephyr",
    "runId": "plan-20260118-100000-a7b3c9",
    "workflow": "hyper-plan",
    "phase": "Research"
  }
}
```

## Field Definitions

### Core Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sessionId` | string | Yes | Claude session identifier |
| `parentId` | string | No | Parent session (if sub-agent) |
| `transcriptPath` | string | No | Path to Claude Code JSONL transcript |
| `workspaceRoot` | string | No | Resolved workspace path |
| `currentTarget` | object | Yes | What the session is currently working on |
| `recentTargets` | array | Yes | Last 10 targets (history, most recent first) |
| `startedAt` | string (ISO 8601) | Yes | When session first modified workspace |
| `lastActivity` | string (ISO 8601) | Yes | Most recent workspace file modification |

### Agent Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `agent.role` | string | No | Agent role: `captain`, `squad-leader`, `worker` |
| `agent.name` | string | No | Generated display name (e.g., "Captain Zephyr") |
| `agent.runId` | string | No | OpenProse run ID for grouping |
| `agent.workflow` | string | No | Workflow name (e.g., "hyper-plan") |
| `agent.phase` | string | No | Current workflow phase (e.g., "Research") |

### Environment Variables

Set these when spawning agent sessions to populate the agent fields:

```bash
export HYPER_AGENT_ROLE="squad-leader"
export HYPER_AGENT_NAME="Captain Zephyr"
export HYPER_RUN_ID="plan-20260118-100000-a7b3c9"
export HYPER_WORKFLOW="hyper-plan"
export HYPER_PHASE="Research"
```

## Target Object Types

### Task Target

```json
{
  "type": "task",
  "taskId": "task-001",
  "projectSlug": "auth-system",
  "filePath": "$HYPER_WORKSPACE_ROOT/projects/auth/tasks/task-001.mdx"
}
```

### Project Target

```json
{
  "type": "project",
  "projectSlug": "auth-system",
  "filePath": "$HYPER_WORKSPACE_ROOT/projects/auth/_project.mdx"
}
```

### Resource Target

```json
{
  "type": "resource",
  "projectSlug": "auth-system",
  "resourcePath": "research/api-patterns.md",
  "filePath": "$HYPER_WORKSPACE_ROOT/projects/auth/resources/api-patterns.md"
}
```

### Doc Target

```json
{
  "type": "doc",
  "docSlug": "architecture",
  "filePath": "$HYPER_WORKSPACE_ROOT/docs/architecture.mdx"
}
```

### Other/Unknown Target

```json
{
  "type": "other",
  "filePath": "$HYPER_WORKSPACE_ROOT/some-file.mdx"
}
```

## Design Rationale

### Why ~/.hyper/sessions/?

1. **Centralized location** - All session metadata in one directory
2. **Decoupled from Claude Code** - Not tied to `~/.claude/` internal structure
3. **Easy to scan** - List all active sessions with a single directory read
4. **Fast lookup** - Files indexed by session ID
5. **Survives Claude Code changes** - Independent of transcript location changes

### Why Not Next to JSONL?

Storing sidecars in `~/.claude/projects/` had issues:
- Couples to Claude Code's internal structure
- Harder to scan all sessions across workspaces
- Would need to watch many directories

### Agent Hierarchy Tracking

The `agent` object enables rich UI display:

```
Captain Zephyr (hyper-plan / Research)
├─ Squad Leader Alpha (hyper-plan / Implementation)
│  ├─ Worker-001 (working on task-001) ✓
│  └─ Worker-002 (working on task-002) ...
└─ Squad Leader Beta (waiting)
```

## Desktop App Integration

### Session Watcher

The app watches `~/.hyper/sessions/` for session sidecar files:

```typescript
// Watch for sidecar changes
const watcher = watch('~/.hyper/sessions/', { persistent: true });
watcher.on('change', (path) => {
  const sessionId = basename(path, '.json');
  refreshSessionMetadata(sessionId);
});
```

### Merging into Session Metadata

```typescript
// Load sidecar and merge with Claude Code session
async function loadSessionWithSidecar(sessionId: string): Promise<SessionWithWorkspace> {
  const sidecarPath = `~/.hyper/sessions/${sessionId}.json`;

  if (await fileExists(sidecarPath)) {
    const sidecar = await readJson(sidecarPath);
    const session = await parseSessionJsonl(sidecar.transcriptPath);

    return {
      ...session,
      workspaceTarget: sidecar.currentTarget,
      recentTargets: sidecar.recentTargets,
      workspaceRoot: sidecar.workspaceRoot,
      // Agent fields
      agentRole: sidecar.agent?.role,
      agentName: sidecar.agent?.name,
      runId: sidecar.agent?.runId,
      workflow: sidecar.agent?.workflow,
      phase: sidecar.agent?.phase,
    };
  }

  return session;
}
```

### TanStack DB Query Examples

```typescript
// Get sessions working on a specific project
const projectSessions = useLiveQueryClientOnly((q) =>
  q.from({ s: sessionsMetadataCollection })
   .where(({ s }) => s.workspaceTarget?.projectSlug === projectSlug)
);

// Get sessions with workspace activity (have sidecar)
const activeSessions = useLiveQueryClientOnly((q) =>
  q.from({ s: sessionsMetadataCollection })
   .where(({ s }) => s.workspaceTarget !== undefined)
   .orderBy((s) => s.lastActivity, 'desc')
);
```

### UI Display

With sidecar data merged into session metadata:

```tsx
function SessionBadge({ session }: { session: SessionWithWorkspace }) {
  if (!session.workspaceTarget) return null;

  const { type, projectSlug, taskId } = session.workspaceTarget;

  return (
    <Badge variant="outline">
      {type === 'task' && `Working on ${projectSlug}/${taskId}`}
      {type === 'project' && `Working on ${projectSlug}`}
      {type === 'resource' && `Researching ${projectSlug}`}
    </Badge>
  );
}
```

## File Lifecycle

1. **Created** - First time session modifies a workspace file
2. **Updated** - Each subsequent workspace file modification
3. **Persists** - Stays alongside JSONL (no TTL needed, matches session lifetime)

Unlike the previous `.sessions/` approach, sidecar files don't need cleanup - they naturally expire with their parent session JSONL.

## Best Practices

1. **Let hooks handle it** - Don't manually create sidecar files
2. **Merge at load time** - Combine JSONL + sidecar when loading sessions
3. **Query via session collection** - Use existing session queries with added workspace fields
4. **Display contextually** - Show workspace target when viewing sessions
