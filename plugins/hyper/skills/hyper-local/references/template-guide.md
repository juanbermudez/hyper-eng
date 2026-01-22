# Template Guide

The hyper-local workflow uses templates to generate consistent document structures. Templates can be customized per-workspace.

## Template Loading Priority

Templates are loaded in this order:

1. **Workspace templates**: `$HYPER_WORKSPACE_ROOT/templates/*.template`
2. **Plugin templates**: `templates/hyper/*.template`

This allows project-specific customization while falling back to plugin defaults.

## Available Templates

| Template | Purpose | Variables |
|----------|---------|-----------|
| `workspace.json.template` | Workspace metadata | WORKSPACE_PATH, NAME, DATE |
| `project.mdx.template` | Project definition | SLUG, TITLE, PRIORITY, SUMMARY, DATE, etc. |
| `task.mdx.template` | Implementation task | PROJECT_SLUG, NUM, TITLE, PRIORITY, etc. |
| `resource.mdx.template` | Supporting documentation | PROJECT_SLUG, SLUG, TITLE, etc. |
| `doc.mdx.template` | Standalone documentation | SLUG, TITLE, DATE, etc. |

## Template Variables

### Common Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{{SLUG}}` | URL-safe identifier | `auth-system` |
| `{{TITLE}}` | Human-readable title | `User Authentication System` |
| `{{DATE}}` | Current date (YYYY-MM-DD) | `2025-12-28` |
| `{{PRIORITY}}` | Priority level | `high` |
| `{{STATUS}}` | Initial status | `todo` |
| `{{DESCRIPTION}}` | Full description | Multi-line text |
| `{{TAGS}}` | YAML array of tags | `[auth, oauth]` |

### Task Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{{PROJECT_SLUG}}` | Parent project identifier | `auth-system` |
| `{{NUM}}` | Task number (zero-padded) | `001` |
| `{{PARENT}}` | Parent project ID | `proj-auth-system` |
| `{{DEPENDS_ON}}` | YAML array of dependencies | `[]` |

### Project Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{{SUMMARY}}` | Brief description | `OAuth-based auth...` |
| `{{GOALS}}` | Project goals list | Multi-line markdown |
| `{{APPROACH}}` | Technical approach | Multi-line markdown |
| `{{OUT_OF_SCOPE}}` | Excluded items | Multi-line markdown |
| `{{SUCCESS_CRITERIA}}` | Testable criteria | Markdown checklist |
| `{{ARCHITECTURE_DIAGRAM}}` | Mermaid diagram | Mermaid code |
| `{{IMPLEMENTATION_PHASES}}` | Phase breakdown | Multi-line markdown |
| `{{MANUAL_VERIFICATION}}` | Manual test steps | Markdown checklist |

## Customizing Templates

### Step 1: Copy Templates

```bash
mkdir -p $HYPER_WORKSPACE_ROOT/templates
cp templates/hyper/*.template $HYPER_WORKSPACE_ROOT/templates/
```

### Step 2: Edit Templates

Modify templates in `$HYPER_WORKSPACE_ROOT/templates/` to match your project's conventions.

### Step 3: Use Custom Templates

The hyper-* commands will automatically use workspace templates when available.

## Template Examples

### Custom Project Template

```yaml
---
id: proj-{{SLUG}}
title: "{{TITLE}}"
type: project
status: planned
priority: {{PRIORITY}}
summary: "{{SUMMARY}}"
created: {{DATE}}
updated: {{DATE}}
tags: {{TAGS}}
# Custom fields for our workflow
team: engineering
quarter: Q1-2025
---

# {{TITLE}}

## Overview

{{DESCRIPTION}}

## Team

- Lead: @TBD
- Engineers: TBD

## Goals

{{GOALS}}

## Non-Goals

{{OUT_OF_SCOPE}}

## Technical Approach

{{APPROACH}}

## Success Metrics

{{SUCCESS_CRITERIA}}

## Architecture

```mermaid
{{ARCHITECTURE_DIAGRAM}}
```

## Phases

{{IMPLEMENTATION_PHASES}}

## Verification

### Automated
- [ ] CI passes

### Manual
{{MANUAL_VERIFICATION}}

## Dependencies

{{DEPENDENCIES}}

## Risks

{{RISKS}}
```

### Custom Task Template

```yaml
---
id: task-{{PROJECT_SLUG}}-{{NUM}}
title: "{{TITLE}}"
type: task
status: todo
priority: {{PRIORITY}}
parent: proj-{{PROJECT_SLUG}}
depends_on: {{DEPENDS_ON}}
created: {{DATE}}
updated: {{DATE}}
tags: {{TAGS}}
# Custom fields
estimated_hours: {{ESTIMATED_HOURS}}
complexity: {{COMPLEXITY}}
---

# {{TITLE}}

## Summary

{{DESCRIPTION}}

## Acceptance Criteria

{{ACCEPTANCE_CRITERIA}}

## Implementation Notes

{{IMPLEMENTATION}}

## Files

### Create
{{NEW_FILES}}

### Modify
{{MODIFIED_FILES}}

## Verification

{{MANUAL_VERIFICATION}}

## Progress Log

<!-- Agent will append progress here -->
```

## Variable Substitution Logic

When creating documents, variables are substituted as follows:

```python
def substitute_template(template: str, variables: dict) -> str:
    result = template
    for key, value in variables.items():
        placeholder = f"{{{{{key}}}}}"
        result = result.replace(placeholder, str(value))
    return result
```

### Array Variables

For YAML arrays (tags, depends_on), format as:

```yaml
# Inline format
tags: [tag1, tag2, tag3]

# Multi-line format (preferred for longer lists)
tags:
  - tag1
  - tag2
  - tag3
```

### Multi-line Variables

For multi-line content (description, goals), preserve formatting:

```yaml
description: |
  This is a multi-line description.

  It spans multiple paragraphs.

  - Supports markdown
  - Including lists
```

## Template Validation

Before using a template, ensure:

1. All `{{VARIABLE}}` placeholders are documented
2. Frontmatter structure is valid YAML
3. Required fields (id, title, type, created, updated) are present
4. Status values match the document type

## Best Practices

1. **Keep templates minimal** - Only include fields you actually use
2. **Use meaningful defaults** - Pre-fill common values
3. **Include examples** - Comment sections show expected format
4. **Version control templates** - Track changes to templates
5. **Document custom fields** - Explain what custom fields mean
