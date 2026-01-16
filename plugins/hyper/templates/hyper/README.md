# Hyper Templates

Templates for the `$HYPER_WORKSPACE_ROOT/` directory structure used by the hyper-engineering workflow.

## Template Files

| Template | Purpose |
|----------|---------|
| `project.mdx.template` | Project definition with metadata and goals |
| `task.mdx.template` | Implementation task with acceptance criteria |
| `initiative.mdx.template` | Strategic grouping of projects |
| `resource.mdx.template` | Supporting documentation (specs, research) |
| `doc.mdx.template` | Standalone documentation |
| `workspace.json.template` | Workspace metadata |

## Customizing Templates

To customize templates for your project:

1. Copy default templates to workspace:
   ```bash
   mkdir -p $HYPER_WORKSPACE_ROOT/templates
   cp templates/hyper/*.template $HYPER_WORKSPACE_ROOT/templates/
   ```

2. Edit templates in `$HYPER_WORKSPACE_ROOT/templates/`

3. Templates in `$HYPER_WORKSPACE_ROOT/templates/` take priority over plugin defaults

## Template Variables

Use `{{VARIABLE_NAME}}` for substitution. Available variables:

### Common Variables

| Variable | Description |
|----------|-------------|
| `{{SLUG}}` | URL-safe identifier (kebab-case) |
| `{{TITLE}}` | Human-readable title |
| `{{DATE}}` | Current date (YYYY-MM-DD) |
| `{{PRIORITY}}` | Priority level (urgent/high/medium/low) |
| `{{STATUS}}` | Initial status |
| `{{DESCRIPTION}}` | Full description |
| `{{TAGS}}` | YAML array of tags |

### Task-Specific Variables

| Variable | Description |
|----------|-------------|
| `{{PROJECT_SLUG}}` | Parent project identifier |
| `{{NUM}}` | Task number (zero-padded, e.g., 001) |
| `{{DEPENDS_ON}}` | YAML array of dependency IDs |
| `{{PARENT}}` | Parent project ID |

### Project-Specific Variables

| Variable | Description |
|----------|-------------|
| `{{SUMMARY}}` | Brief description for project cards |
| `{{GOALS}}` | Project goals list |
| `{{APPROACH}}` | Technical approach description |
| `{{OUT_OF_SCOPE}}` | Explicitly excluded items |
| `{{SUCCESS_CRITERIA}}` | Testable success criteria |

## Adding Custom Fields

You can add custom frontmatter fields to templates. Hyper Control will display them in the document details panel.

Example:
```yaml
---
id: task-custom-001
title: My Task
type: task
status: todo
custom_field: custom value
---
```

## Document Types

### Initiative
High-level strategic grouping (e.g., "Q1 2025 Product Launch")
- Status: `planned`, `in-progress`, `completed`, `canceled`

### Project
A discrete piece of work with tasks and resources
- Status: `planned`, `todo`, `in-progress`, `completed`, `canceled`

### Task
Individual implementation units within a project
- Status: `draft`, `todo`, `in-progress`, `review`, `complete`, `blocked`

### Resource
Supporting documentation, specifications, research
- No status (informational)

### Doc
Standalone documentation not tied to a project
- No status (informational)

## Frontmatter Schema

All documents follow this schema (compatible with Hyper Control):

```yaml
---
id: string           # Unique identifier (e.g., "proj-auth", "task-auth-001")
title: string        # Human-readable title
type: string         # initiative | project | task | resource | doc
status: string       # See status enums above
priority: string     # urgent | high | medium | low (optional)
created: string      # ISO date (YYYY-MM-DD)
updated: string      # ISO date (YYYY-MM-DD)
tags: string[]       # Searchable tags

# Task-specific fields
parent: string       # Parent project ID (for tasks)
depends_on: string[] # Blocking dependencies
blocks: string[]     # What this blocks
assignee: string     # Optional assignee

# Project-specific fields
summary: string      # Brief description for project cards
---
```

## Integration with Hyper Control

When Hyper Control is running, it watches `$HYPER_WORKSPACE_ROOT/` for changes. All file operations are immediately reflected in the UI.

No special integration needed - the filesystem IS the API.
