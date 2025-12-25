# AI Agent Patterns for Linear CLI

Best practices and workflow patterns for AI agents using the Linear CLI.

## Core Principles

### 1. JSON is the Default Output

JSON output is automatic - no flags needed:

```bash
# JSON by default (pipe to jq)
linear issue list | jq '.issues[].title'

# Use --human for readable output
linear issue list --human
```

### 2. Always Check Command Success

Parse JSON responses to verify success:

```typescript
const result = JSON.parse(
  await exec('linear issue create --title "Task" --team LOT'),
)
if (!result.success) {
  console.error(`Error: ${result.error.message}`)
  // Handle error
}
```

### 3. Use Specific Options (Non-Interactive)

Always provide all required options to avoid interactive prompts:

```bash
# Good - Non-interactive
linear issue create \
  --title "Fix bug" \
  --team LOT \
  --priority 1

# Avoid - Will prompt for input
linear issue create
```

### 4. Leverage VCS Context

The CLI automatically detects issue context from git branches:

```bash
# If on branch: feature/LOT-123-new-feature
linear issue view        # Shows LOT-123 automatically
linear issue update --state "In Progress"  # Updates LOT-123
```

## JSON Response Formats

### Issue Create/Update Response

```json
{
  "success": true,
  "operation": "create",
  "issue": {
    "id": "uuid",
    "identifier": "LOT-123",
    "title": "Task title",
    "url": "https://linear.app/...",
    "state": { "name": "Todo" },
    "team": { "key": "LOT" },
    "assignee": { "name": "John" },
    "priority": 1,
    "estimate": 5
  }
}
```

### Issue View Response

```json
{
  "issue": {
    "identifier": "LOT-123",
    "title": "Task title",
    "description": "...",
    "state": { "name": "In Progress" },
    "team": { "key": "LOT", "name": "Engineering" },
    "assignee": { "name": "John", "email": "john@example.com" },
    "priority": 1,
    "estimate": 5,
    "dueDate": "2025-12-31",
    "project": { "name": "API Redesign" },
    "milestone": { "name": "Phase 1", "targetDate": "2026-03-31" },
    "parent": { "identifier": "LOT-100" },
    "children": [{ "identifier": "LOT-124" }],
    "relations": {
      "nodes": [
        { "type": "blocks", "issue": { "identifier": "LOT-125" } }
      ]
    },
    "labels": {
      "nodes": [
        { "name": "Bugfix", "parent": { "name": "Work-Type" } }
      ]
    }
  }
}
```

### Comment Response

```json
{
  "success": true,
  "comments": [
    {
      "id": "uuid",
      "body": "This looks good to merge",
      "createdAt": "2025-11-02T10:00:00.000Z",
      "author": {
        "id": "uuid",
        "name": "John Doe",
        "email": "john@example.com"
      },
      "issue": {
        "id": "uuid",
        "identifier": "LOT-123"
      }
    }
  ]
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "MISSING_REQUIRED_FIELD",
    "message": "--title is required"
  }
}
```

## Common Workflows

### Workflow 1: Create Issue with Full Context

```bash
# Read specification from file
SPEC=$(cat spec.md)

# Create issue with all metadata
ISSUE_JSON=$(linear issue create \
  --title "Implement OAuth 2.0" \
  --description "$SPEC" \
  --team LOT \
  --project "Auth System" \
  --milestone "Phase 1" \
  --priority 1 \
  --estimate 8 \
  --label backend security \
  --assignee @me \
  --blocks LOT-100 LOT-101)

# Extract issue ID
ISSUE_ID=$(echo "$ISSUE_JSON" | jq -r '.issue.identifier')

# Start working
linear issue start $ISSUE_ID
```

### Workflow 2: Project with Milestones and Issues

```bash
# 1. Create project
PROJECT_JSON=$(linear project create \
  --name "Mobile App" \
  --description "iOS and Android applications" \
  --content "$(cat project-spec.md)" \
  --team LOT \
  --lead @me \
  --priority 1 \
  --start-date 2026-01-01 \
  --target-date 2026-06-30)

PROJECT_ID=$(echo "$PROJECT_JSON" | jq -r '.project.id')
PROJECT_SLUG=$(echo "$PROJECT_JSON" | jq -r '.project.slug')

# 2. Create milestones
linear project milestone create $PROJECT_ID \
  --name "Phase 1: Core Features" \
  --target-date 2026-03-31

# 3. Create issues linked to project and milestone
linear issue create \
  --title "Setup authentication" \
  --team LOT \
  --project "$PROJECT_SLUG" \
  --milestone "Phase 1: Core Features" \
  --priority 1 \
  --assignee @me

# 4. Add status update
linear project update-create $PROJECT_SLUG \
  --body "Week 1: Project kicked off successfully" \
  --health onTrack
```

### Workflow 3: Label Hierarchy for Organization

```bash
# 1. Create label groups
linear label create --name "Work-Type" --is-group --team LOT
linear label create --name "Scope" --is-group --team LOT

# 2. Create sub-labels
linear label create --name "Bugfix" --parent "Work-Type" --team LOT
linear label create --name "New-Feature" --parent "Work-Type" --team LOT
linear label create --name "Backend" --parent "Scope" --team LOT
linear label create --name "Frontend" --parent "Scope" --team LOT

# 3. Use on issues (displays as "parent/child")
linear issue create \
  --title "Fix API bug" \
  --label Bugfix Backend \
  --team LOT
# Result: Labels show as "Work-Type/Bugfix, Scope/Backend"
```

### Workflow 4: Issue Dependencies

```bash
# Create parent issue
PARENT=$(linear issue create \
  --title "Database migration" \
  --team LOT \
  --priority 1 | jq -r '.issue.identifier')

# Create dependent issues with relationships
linear issue create \
  --title "Update API layer" \
  --team LOT \
  --parent $PARENT \
  --blocks LOT-200 LOT-201

# View all relationships
linear issue relations $PARENT
```

## Error Handling

### Common Error Patterns

```typescript
try {
  const result = JSON.parse(
    await exec('linear issue create --title "Task"'),
  )

  if (!result.success) {
    switch (result.error.code) {
      case "MISSING_REQUIRED_FIELD":
        // Handle validation error
        break
      case "NOT_FOUND":
        // Resource not found
        break
      case "API_ERROR":
        // Linear API error
        break
      default:
        // Unknown error
    }
  }
} catch (e) {
  // Command execution failed
}
```

### Verify Operations

```bash
# Always check the result
RESULT=$(linear issue create --title "Task")
if echo "$RESULT" | jq -e '.success' > /dev/null; then
  ISSUE_ID=$(echo "$RESULT" | jq -r '.issue.identifier')
  echo "Created $ISSUE_ID"
else
  echo "Failed: $(echo "$RESULT" | jq -r '.error.message')"
fi
```

## Content Formatting

### Markdown Support

Linear supports rich markdown with cross-references:

```markdown
# Technical Specification

## Overview
This feature implements OAuth 2.0 authentication.

## Dependencies
- Depends on: [LOT-100](https://linear.app/workspace/issue/LOT-100)
- Part of: [Auth Project](https://linear.app/workspace/project/auth-abc)

## Implementation
\`\`\`typescript
// Code example
\`\`\`

## Checklist
- [ ] Task 1
- [ ] Task 2

## Diagrams
\`\`\`mermaid
graph TB
    A --> B
\`\`\`
```

### Cross-Reference Format

**All cross-references require markdown links with full URLs:**

| Resource  | Format         | Example                                                 |
|-----------|----------------|---------------------------------------------------------|
| Issues    | `[ID](url)`    | `[LOT-123](https://linear.app/workspace/issue/LOT-123)` |
| Projects  | `[Name](url)`  | `[Project](https://linear.app/workspace/project/slug)`  |
| Documents | `[Title](url)` | `[Spec](https://linear.app/workspace/document/id)`      |
| Users     | `@username`    | `@john` or `@alice` (username only)                     |

**What doesn't work:**
- Plain identifiers: `LOT-123`
- Hash symbol: `#LOT-123`
- At symbol for issues: `@LOT-123`

### Content Fields Limits

| Resource   | Field       | Limit     |
|------------|-------------|-----------|
| Project    | description | 255 chars |
| Project    | content     | ~200KB    |
| Issue      | description | ~200KB    |
| Initiative | content     | ~200KB    |
| Document   | content     | ~200KB    |

## Best Practices

### 1. Plan Before Executing

```bash
# Get context first
TEAM=$(linear whoami | jq -r '.configuration.team_id')
PROJECT=$(linear project list --team $TEAM | jq -r '.projects[0].slug')

# Then create with full context
linear issue create \
  --title "Task" \
  --team $TEAM \
  --project $PROJECT
```

### 2. Use Consistent Naming

```bash
# Good: Descriptive, actionable titles
"Fix authentication timeout on mobile"
"Implement OAuth 2.0 provider integration"
"Add caching layer to API endpoints"

# Avoid: Vague or unclear
"Fix bug"
"Update code"
"Changes"
```

### 3. Link Related Work

Always create relationships between related issues:

```bash
# When you discover dependencies
linear issue create \
  --title "Add API tests" \
  --team LOT \
  --blocks LOT-123

# When working on related features
linear issue update LOT-124 \
  --related-to LOT-123
```

### 4. Keep Content in Files

```bash
# Good: Keep content in files
linear issue create \
  --title "Task" \
  --description "$(cat spec.md)"

# Avoid: Inline content for long text
linear issue create \
  --title "Task" \
  --description "Very long content..."
```

## Important Notes

1. **User References**: Use `@me` for yourself, not `self`
2. **Labels**: Space-separated, not repeated flags: `--label A B` not `--label A --label B`
3. **Milestones**: Require project UUID, not slug (use `| jq -r '.project.id'`)
4. **Label Groups**: Parent must be created with `--is-group` before children
5. **Project UUID vs Slug**: Most commands accept slug, but milestones need UUID

## Critical Reminders

1. **JSON is the default output** - No flags needed, use `--human` for readable format
2. **Always check `success` field** in response
3. **Use `@me`** for self-assignment, not `self`
4. **Label groups require `--is-group`** flag for parent
5. **Space-separate multiple labels**: `--label A B C`
6. **Milestones need project UUID**, not slug
7. **Cross-references need full URLs** in markdown format
8. **VCS context is automatically detected** from git branches
9. **All relationship types are bidirectional** (show outgoing + incoming)
