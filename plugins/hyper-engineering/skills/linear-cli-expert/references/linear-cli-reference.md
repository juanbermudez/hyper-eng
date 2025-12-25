# Linear CLI Reference

Complete command reference for the Linear Agent CLI.

> **For AI agent patterns and workflow examples, see [ai-agent-patterns.md](./ai-agent-patterns.md)**

## Installation

The Linear Agent CLI is a Deno-based tool optimized for AI agents:

```bash
# Install from GitHub
deno install --global --allow-all --name linear \
  https://raw.githubusercontent.com/juanbermudez/linear-agent-cli/main/src/main.ts

# Verify installation
linear --version

# Authenticate
linear whoami
# Enter API key when prompted
```

Get your API key from [Linear Settings > API](https://linear.app/settings/api).

## Global Flags

| Flag | Description |
|------|-------------|
| `--human` | Human-readable output (default: JSON) |
| `--team` | Team ID or key (overrides config) |
| `--project` | Project ID (overrides VCS detection) |

## Issue Commands

### Create Issue

**All Available Options:**

```bash
linear issue create \
  -t "Task title" \
  -d "$(cat description.md)" \
  --team ENG \
  -a self \
  --priority 1 \
  --estimate 5 \
  -l backend \
  -l feature \
  --project "API Redesign" \
  --milestone "Phase 1" \
  --cycle "Sprint 5" \
  -p ENG-100 \
  -s "In Progress" \
  --due-date 2025-12-31 \
  --blocks ENG-101 \
  --blocks ENG-102 \
  --related-to ENG-103 \
  --start
```

**Common Patterns:**

```bash
# Quick bug report
linear issue create \
  -t "Login button not working" \
  --priority 1 \
  -l bug \
  -a self \
  --team ENG

# Feature with full metadata
linear issue create \
  -t "Add OAuth support" \
  -d "$(cat spec.md)" \
  --project "Auth System" \
  --milestone "Phase 1" \
  --estimate 8 \
  -l backend \
  -l feature \
  --blocks ENG-100 \
  --team ENG

# Sub-task
linear issue create \
  -t "Write tests" \
  -p ENG-123 \
  -a self \
  --estimate 3 \
  --team ENG
```

### View Issue
```bash
linear issue view ENG-123
linear issue view ENG-123 --human
```

### List Issues
```bash
linear issue list
linear issue list --state "In Progress"
linear issue list --project [project-id]
linear issue list --limit 100
```

### Update Issue
```bash
linear issue update ENG-123 \
  --title "New title" \
  --state "Done" \
  --priority 1 \
  --assignee "@username"
```

### Delete Issue
```bash
linear issue delete ENG-123
```

### Search Issues
```bash
linear issue search "search query"
```

### Issue Relationships
```bash
# Create relationship
linear issue relate ENG-123 ENG-456 --blocks
linear issue relate ENG-123 ENG-456 --blocked-by
linear issue relate ENG-123 ENG-456 --related-to
linear issue relate ENG-123 ENG-456 --duplicate-of

# Remove relationship
linear issue unrelate ENG-123 ENG-456

# View relationships
linear issue relations ENG-123
```

### Issue Comments
```bash
# Create comment
linear issue comment create ENG-123 --body "Comment text"

# List comments
linear issue comment list ENG-123
```

### Issue Attachments
```bash
# Create attachment
linear issue attachment create ENG-123 --url "https://..."

# List attachments
linear issue attachment list ENG-123
```

### Start Work (Git Branch)
```bash
linear issue start ENG-123
# Creates branch: feature/ENG-123-issue-title
```

## Project Commands

### Create Project

```bash
linear project create \
  -n "API Redesign" \
  -d "Modernize API with GraphQL" \
  -c "$(cat overview.md)" \
  -t ENG \
  -l self \
  --color "#6366F1" \
  --start-date 2026-01-01 \
  --target-date 2026-09-30 \
  -p 1 \
  -s "In Progress"

# With linked document
linear project create \
  -n "Feature X" \
  -t ENG \
  --with-doc \
  --doc-title "PRD: Feature X"
```

**Key Points:**
- `-d, --description`: Short summary (max 255 chars)
- `-c, --content`: Full markdown content (large body)
- `-l, --lead`: Use `self` for yourself or username/email
- `--color`: Hex format `#RRGGBB`
- `--with-doc`: Creates a linked document automatically

### View Project
```bash
linear project view [project-id]
linear project view [project-id] --human
```

### List Projects
```bash
linear project list
linear project list --status planned
linear project list --limit 20
```

### Update Project
```bash
linear project update [project-id] \
  --name "New Name" \
  --status started
```

### Delete/Restore Project
```bash
linear project delete [project-id]
linear project restore [project-id]
```

### Project Milestones
```bash
# Create milestone
linear project milestone create [project-id] \
  --name "Milestone 1" \
  --target-date "2024-03-01"

# List milestones
linear project milestone list [project-id]
```

### Project Status Updates
```bash
# Create status update
linear project update-status create [project-id] \
  --body "Status update text" \
  --health onTrack

# List status updates
linear project update-status list [project-id]
```

## Document Commands

### Create Document
```bash
linear document create \
  --title "Document Title" \
  --content "Markdown content" \
  --project [project-id]
```

### View Document
```bash
linear document view [document-id]
```

### List Documents
```bash
linear document list
linear document list --project [project-id]
```

### Update Document
```bash
linear document update [document-id] \
  --title "New Title" \
  --content "New content"
```

### Delete/Restore Document
```bash
linear document delete [document-id]
linear document restore [document-id]
```

### Search Documents
```bash
linear document search "search query"
```

## Label Commands

### Create Label
```bash
linear label create \
  --name "Label Name" \
  --team ENG \
  --color "#FF0000"
```

### List Labels
```bash
linear label list
linear label list --team ENG
```

### Update Label
```bash
linear label update [label-id] \
  --name "New Name" \
  --color "#00FF00"
```

### Delete Label
```bash
linear label delete [label-id]
```

## Workflow Commands

### List Workflow States
```bash
linear workflow list
linear workflow list --team ENG
```

### Refresh Cache
```bash
linear workflow cache
```

## Status Commands

### List Project Statuses
```bash
linear status list
```

### Refresh Cache
```bash
linear status cache
```

## User Commands

### List Users
```bash
linear user list
```

### Search Users
```bash
linear user search "name or email"
```

## Team Commands

### List Teams
```bash
linear team list
```

## Initiative Commands

### Create Initiative
```bash
linear initiative create \
  --name "Initiative Name" \
  --description "Description"
```

### View Initiative
```bash
linear initiative view [initiative-id]
```

### List Initiatives
```bash
linear initiative list
```

### Update Initiative
```bash
linear initiative update [initiative-id] \
  --name "New Name"
```

### Archive/Restore Initiative
```bash
linear initiative archive [initiative-id]
linear initiative restore [initiative-id]
```

### Manage Projects
```bash
linear initiative project-add [initiative-id] [project-id]
linear initiative project-remove [initiative-id] [project-id]
```

## Configuration Commands

### Interactive Setup
```bash
linear config setup
```

### Set Configuration
```bash
linear config set api_key "lin_api_..."
linear config set team_key "ENG"
linear config set team_id "[uuid]"
```

### Get Configuration
```bash
linear config get api_key
linear config get team_key
```

### List Configuration
```bash
linear config list
```

## Utility Commands

### Who Am I
```bash
linear whoami
```

Shows current user and configuration status.

## Output Formats

### JSON (Default)
```bash
linear issue list
# [{"id": "...", "identifier": "ENG-123", ...}]
```

### Human-Readable
```bash
linear issue list --human
# ENG-123  Fix login bug  In Progress  @juan
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `LINEAR_API_KEY` | API key (overrides config file) |

## Configuration File

Location: `.linear.toml` (current directory or home)

```toml
api_key = "lin_api_..."
team_id = "uuid"
team_key = "ENG"
```

## Caching

The CLI caches these resources for 24 hours:
- Workflow states
- Project statuses
- Users
- Labels

Force refresh with:
```bash
linear workflow cache
linear status cache
```

## VCS Integration

The CLI detects issue context from git branches:
```
feature/ENG-123-issue-title → Detects ENG-123
```

This enables commands without explicit IDs:
```bash
linear issue view  # Uses branch context
linear issue update --state "In Progress"  # Updates detected issue
linear issue comment create --body "Fixed"  # Comments on detected issue
```

## Important Notes

1. **Self-assignment**: Use `self` for yourself (not `@me`)
2. **Labels**: Use repeated `-l` flags: `-l bug -l feature` (not space-separated)
3. **Relationships**: Use repeated flags: `--blocks ENG-1 --blocks ENG-2`
4. **Milestones**: Require project UUID, not slug (use `| jq -r '.project.id'`)
5. **Label Groups**: Parent must be created with `--is-group` before children
6. **Project UUID vs Slug**: Most commands accept slug, but milestones need UUID
7. **Content from files**: Use `-d "$(cat file.md)"` for long content

## Related Documentation

- [AI Agent Patterns](./ai-agent-patterns.md) - Workflow examples and best practices
- [Workflow Guide](./workflow-guide.md) - Hyper-engineering workflow stages
