# Linear CLI Reference

Complete command reference for the Linear Agent CLI.

## Global Flags

| Flag | Description |
|------|-------------|
| `--human` | Human-readable output (default: JSON) |
| `--team` | Team ID or key (overrides config) |
| `--project` | Project ID (overrides VCS detection) |

## Issue Commands

### Create Issue
```bash
linear issue create \
  --title "Issue title" \
  --team LOT \
  --description "Markdown description" \
  --priority 2 \
  --assignee "@username" \
  --label "bug" \
  --project [project-id] \
  --state "To Do" \
  --parent LOT-123  # For subtasks
```

### View Issue
```bash
linear issue view LOT-123
linear issue view LOT-123 --human
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
linear issue update LOT-123 \
  --title "New title" \
  --state "Done" \
  --priority 1 \
  --assignee "@username"
```

### Delete Issue
```bash
linear issue delete LOT-123
```

### Search Issues
```bash
linear issue search "search query"
```

### Issue Relationships
```bash
# Create relationship
linear issue relate LOT-123 LOT-456 --blocks
linear issue relate LOT-123 LOT-456 --blocked-by
linear issue relate LOT-123 LOT-456 --related-to
linear issue relate LOT-123 LOT-456 --duplicate-of

# Remove relationship
linear issue unrelate LOT-123 LOT-456

# View relationships
linear issue relations LOT-123
```

### Issue Comments
```bash
# Create comment
linear issue comment create LOT-123 --body "Comment text"

# List comments
linear issue comment list LOT-123
```

### Issue Attachments
```bash
# Create attachment
linear issue attachment create LOT-123 --url "https://..."

# List attachments
linear issue attachment list LOT-123
```

### Start Work (Git Branch)
```bash
linear issue start LOT-123
# Creates branch: feature/LOT-123-issue-title
```

## Project Commands

### Create Project
```bash
linear project create \
  --name "Project Name" \
  --team LOT \
  --description "Description" \
  --status planned

# With document
linear project create \
  --name "Feature X" \
  --with-doc \
  --doc-title "PRD: Feature X"
```

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
  --team LOT \
  --color "#FF0000"
```

### List Labels
```bash
linear label list
linear label list --team LOT
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
linear workflow list --team LOT
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
linear config set team_key "LOT"
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
# [{"id": "...", "identifier": "LOT-123", ...}]
```

### Human-Readable
```bash
linear issue list --human
# LOT-123  Fix login bug  In Progress  @juan
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
team_key = "LOT"
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
feature/LOT-123-issue-title → Detects LOT-123
```

This enables commands without explicit IDs:
```bash
linear issue view  # Uses branch context
```
