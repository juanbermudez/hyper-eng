# Session Workspace Metadata Schema

Sidecar files that extend Claude Code session transcripts with workspace context.

## File Location

```
~/.claude/projects/{encoded-path}/
├── abc-123-def.jsonl        ← Claude Code transcript (existing, read-only)
├── abc-123-def.hyper.json   ← Workspace metadata (our sidecar)
└── ...
```

The sidecar file is created next to the session JSONL, using the same session ID with `.hyper.json` extension.

## Sidecar File Schema

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
  "recentTargets": [
    { "type": "task", "taskId": "task-001", "projectSlug": "auth-system", "filePath": "..." },
    { "type": "project", "projectSlug": "auth-system", "filePath": "..." }
  ],
  "startedAt": "2026-01-18T10:00:00Z",
  "lastActivity": "2026-01-18T10:05:00Z"
}
```

## Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sessionId` | string | Yes | Claude session identifier (matches JSONL filename) |
| `parentId` | string | No | Parent session (if sub-agent) |
| `workspaceRoot` | string | No | Resolved workspace path |
| `currentTarget` | object | Yes | What the session is currently working on |
| `recentTargets` | array | Yes | Last 10 targets (history, most recent first) |
| `startedAt` | string (ISO 8601) | Yes | When session first modified workspace |
| `lastActivity` | string (ISO 8601) | Yes | Most recent workspace file modification |

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
  "filePath": "$HYPER_WORKSPACE_ROOT/projects/auth/resources/research/api-patterns.md"
}
```

### Initiative Target

```json
{
  "type": "initiative",
  "initiativeSlug": "q1-goals",
  "filePath": "$HYPER_WORKSPACE_ROOT/initiatives/q1-goals.mdx"
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

### Why Sidecar Files?

1. **Integrates with existing session system** - Same directory the app already watches
2. **Natural association** - Session ID matches JSONL filename
3. **No new directories** - Leverages existing `~/.claude/projects/` structure
4. **Easy to merge** - App can combine JSONL metadata with sidecar data

### Why Not Separate Registry?

A separate `.sessions/` directory would:
- Require watching a new location
- Create divergent session tracking
- Complicate the data model

Sidecar files keep everything in one place.

## Desktop App Integration

### Existing Session Watcher

The app already watches `~/.claude/projects/` for session JSONL files. It can be extended to also pick up `.hyper.json` sidecars.

### Merging into Session Metadata

```typescript
// When loading sessions, also check for sidecar
async function loadSessionWithSidecar(jsonlPath: string): Promise<SessionWithWorkspace> {
  const session = await parseSessionJsonl(jsonlPath);

  const sidecarPath = jsonlPath.replace('.jsonl', '.hyper.json');
  if (await fileExists(sidecarPath)) {
    const sidecar = await readJson(sidecarPath);
    return {
      ...session,
      workspaceTarget: sidecar.currentTarget,
      recentTargets: sidecar.recentTargets,
      workspaceRoot: sidecar.workspaceRoot,
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
