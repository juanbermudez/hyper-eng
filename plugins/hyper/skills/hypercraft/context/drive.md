## Drive Overview

The Drive is a local, wiki-style notes system stored in HyperHome. Use it for non-git artifacts and shared context.

**Use Drive for:**
- Personal notes or drafts
- Workspace-shared docs
- Project diagrams or design notes that should not live in git

**Use `projects/{slug}/resources/` for:**
- Git-tracked research and artifacts tied to the project

## Core Commands

```bash
# List drive items
hypercraft drive list --json

# Create a note (personal by default)
hypercraft drive create "Research Notes" --icon "FileText" --json

# Create a folder
hypercraft drive mkdir "research/experiments" --json

# Show a note
hypercraft drive show <id> --json

# Delete a note
hypercraft drive delete <id> --force --json
```

## Scopes and IDs

Drive items are scoped. The scope is part of the `id`:

| Scope | ID Format | Example |
|-------|-----------|---------|
| Personal | `personal:{slug}` | `personal:my-note` |
| Organization | `org-{orgId}:{slug}` | `org-abc123:team-docs` |
| Workspace | `ws-{wsId}:{slug}` | `ws-123:feature-notes` |
| Project | `proj-{projId}:{slug}` | `proj-auth:design-doc` |

**Always use the CLI** to create Drive notes so IDs are correct.

## Moving Items

```bash
# Move to a different folder
hypercraft drive move "personal:my-note" --to-folder "archive" --json

# Move to a different scope (creates new ID)
hypercraft drive move "personal:my-note" --to-scope "ws:workspace-id" --json

# Move with redirect
hypercraft drive move "personal:my-note" --to-scope "ws:workspace-id" --keep-redirect --json
```

## Scope Guidance

| Artifact Type | Recommended Scope |
|---------------|-------------------|
| Personal notes | `personal:` |
| Workspace docs | `ws:{workspaceId}:` |
| Project artifacts | `proj:{projectId}:` |
| Org standards | `org:{orgId}:` |
