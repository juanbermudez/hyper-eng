# AI Agent Patterns for Linear Agent CLI

Best practices and workflow patterns for AI agents using the Linear Agent CLI (Deno-based, JSON-first).

## Installation

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
  await exec('linear issue create -t "Task" --team ENG'),
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
  -t "Fix bug" \
  --team ENG \
  --priority 1

# Avoid - Will prompt for input
linear issue create
```

### 4. Leverage VCS Context

The CLI automatically detects issue context from git branches:

```bash
# If on branch: feature/ENG-123-new-feature
linear issue view        # Shows ENG-123 automatically
linear issue update --state "In Progress"  # Updates ENG-123
```

## JSON Response Formats

### Issue Create/Update Response

```json
{
  "success": true,
  "operation": "create",
  "issue": {
    "id": "uuid",
    "identifier": "ENG-123",
    "title": "Task title",
    "url": "https://linear.app/...",
    "state": { "name": "Todo" },
    "team": { "key": "ENG" },
    "assignee": { "name": "John" },
    "priority": 1,
    "estimate": 5
  }
}
```

### Project Create Response

```json
{
  "success": true,
  "operation": "create",
  "project": {
    "id": "uuid",
    "name": "API Redesign",
    "slugId": "api-redesign",
    "url": "https://linear.app/...",
    "status": {
      "id": "uuid",
      "name": "Planned",
      "type": "planned"
    },
    "lead": {
      "id": "uuid",
      "name": "John Doe"
    },
    "teams": [
      { "id": "uuid", "key": "ENG", "name": "Engineering" }
    ]
  },
  "document": {
    "id": "uuid",
    "title": "PRD: API Redesign",
    "slugId": "prd-api-redesign",
    "url": "https://linear.app/..."
  }
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "MISSING_REQUIRED_FIELD",
    "message": "--title is required",
    "field": "title"
  }
}
```

## Common Workflows

### Workflow 1: Create Issue with Full Context

```bash
# Read specification from file
SPEC=$(cat spec.md)

# Create issue with all metadata
# Note: Use -l for each label (repeated flag pattern)
ISSUE_JSON=$(linear issue create \
  -t "Implement OAuth 2.0" \
  -d "$SPEC" \
  --team ENG \
  --project "Auth System" \
  --milestone "Phase 1" \
  --priority 1 \
  --estimate 8 \
  -l backend \
  -l security \
  -a self \
  --blocks ENG-100 \
  --blocks ENG-101)

# Extract issue ID
ISSUE_ID=$(echo "$ISSUE_JSON" | jq -r '.issue.identifier')

# Start working (creates branch, updates status)
linear issue start $ISSUE_ID
```

### Workflow 2: Project with Document and Milestones

```bash
# 1. Create project with linked document
PROJECT_JSON=$(linear project create \
  -n "Mobile App" \
  -d "iOS and Android applications" \
  -c "$(cat project-spec.md)" \
  -t ENG \
  -l self \
  -p 1 \
  --start-date 2026-01-01 \
  --target-date 2026-06-30 \
  --with-doc \
  --doc-title "PRD: Mobile App")

PROJECT_ID=$(echo "$PROJECT_JSON" | jq -r '.project.id')
PROJECT_SLUG=$(echo "$PROJECT_JSON" | jq -r '.project.slugId')

# 2. Create milestone
linear project milestone create $PROJECT_ID \
  --name "Phase 1: Core Features" \
  --target-date 2026-03-31

# 3. Create issues linked to project and milestone
linear issue create \
  -t "Setup authentication" \
  --team ENG \
  --project "$PROJECT_SLUG" \
  --milestone "Phase 1: Core Features" \
  --priority 1 \
  -a self

# 4. Add status update
linear project update-create $PROJECT_SLUG \
  --body "Week 1: Project kicked off successfully" \
  --health onTrack
```

### Workflow 3: Label Hierarchy for Organization

```bash
# 1. Create label groups
linear label create --name "Work-Type" --is-group --team ENG
linear label create --name "Scope" --is-group --team ENG

# 2. Create sub-labels
linear label create --name "Bugfix" --parent "Work-Type" --team ENG
linear label create --name "New-Feature" --parent "Work-Type" --team ENG
linear label create --name "Backend" --parent "Scope" --team ENG
linear label create --name "Frontend" --parent "Scope" --team ENG

# 3. Use on issues (use -l for each label)
linear issue create \
  -t "Fix API bug" \
  -l Bugfix \
  -l Backend \
  --team ENG
# Result: Labels show as "Work-Type/Bugfix, Scope/Backend"
```

### Workflow 4: Issue Dependencies

```bash
# Create parent issue
PARENT=$(linear issue create \
  -t "Database migration" \
  --team ENG \
  --priority 1 | jq -r '.issue.identifier')

# Create sub-task with blocking relationships
linear issue create \
  -t "Update API layer" \
  --team ENG \
  -p $PARENT \
  --blocks ENG-200 \
  --blocks ENG-201

# View all relationships
linear issue relations $PARENT
```

## Error Handling

### Common Error Patterns

```typescript
try {
  const result = JSON.parse(
    await exec('linear issue create -t "Task"'),
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
RESULT=$(linear issue create -t "Task" --team ENG)
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
- Depends on: [ENG-100](https://linear.app/workspace/issue/ENG-100)
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
| Issues    | `[ID](url)`    | `[ENG-123](https://linear.app/workspace/issue/ENG-123)` |
| Projects  | `[Name](url)`  | `[Project](https://linear.app/workspace/project/slug)`  |
| Documents | `[Title](url)` | `[Spec](https://linear.app/workspace/document/id)`      |
| Users     | `@username`    | `@john` or `@alice` (username only)                     |

**What doesn't work:**
- Plain identifiers: `ENG-123`
- Hash symbol: `#ENG-123`
- At symbol for issues: `@ENG-123`

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
linear whoami | jq '.'

# Check available teams
linear team list | jq '.teams[].key'

# Then create with full context
linear issue create \
  -t "Task" \
  --team ENG \
  --project "my-project"
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
# When you discover dependencies (use repeated flags)
linear issue create \
  -t "Add API tests" \
  --team ENG \
  --blocks ENG-123

# When working on related features
linear issue update ENG-124 \
  --related-to ENG-123
```

### 4. Keep Content in Files

```bash
# Good: Keep content in files
linear issue create \
  -t "Task" \
  -d "$(cat spec.md)"

# Avoid: Inline content for long text
linear issue create \
  -t "Task" \
  -d "Very long content..."
```

## CLI Flag Reference

### Issue Create Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--title` | `-t` | Issue title (required) |
| `--description` | `-d` | Issue description (markdown) |
| `--team` | | Team key |
| `--assignee` | `-a` | Assign to `self` or username |
| `--priority` | | Priority 1-4 (1=urgent, 4=low) |
| `--estimate` | | Points estimate |
| `--label` | `-l` | Label name (repeat for multiple) |
| `--project` | | Project name or slug |
| `--milestone` | | Milestone name |
| `--cycle` | | Cycle name or ID |
| `--state` | `-s` | Workflow state name |
| `--parent` | `-p` | Parent issue identifier |
| `--blocks` | | Issue this blocks (repeat for multiple) |
| `--related-to` | | Related issue (repeat for multiple) |
| `--duplicate-of` | | Duplicate of issue |
| `--similar-to` | | Similar to issue |
| `--due-date` | | Due date (YYYY-MM-DD) |
| `--start` | | Start work after creation |
| `--human` | | Human-readable output |

### Project Create Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--name` | `-n` | Project name (required) |
| `--description` | `-d` | Short description (max 255 chars) |
| `--content` | `-c` | Full markdown content |
| `--team` | `-t` | Team key (repeat for multiple) |
| `--status` | `-s` | Status name or ID |
| `--lead` | `-l` | Lead username or email |
| `--icon` | `-i` | Icon emoji |
| `--color` | | Color hex (#RRGGBB) |
| `--start-date` | | Start date (YYYY-MM-DD) |
| `--target-date` | | Target date (YYYY-MM-DD) |
| `--priority` | `-p` | Priority 0-4 |
| `--with-doc` | | Create linked document |
| `--doc-title` | | Document title |
| `--human` | | Human-readable output |

## Important Notes

1. **Self-assignment**: Use `self` (not `@me` or `@self`)
2. **Labels**: Use repeated `-l` flags: `-l bug -l feature`
3. **Relationships**: Use repeated flags: `--blocks ENG-1 --blocks ENG-2`
4. **Milestones**: Require project UUID, not slug
5. **Project UUID vs Slug**: Milestone commands need UUID from `jq -r '.project.id'`
6. **Content from files**: Use `"$(cat file.md)"` for long content

## Critical Reminders

1. **JSON is the default output** - No flags needed, use `--human` for readable format
2. **Always check `success` field** in response
3. **Use `self`** for self-assignment, not `@me`
4. **Labels use repeated flags**: `-l A -l B -l C`
5. **Milestones need project UUID**, not slug
6. **Cross-references need full URLs** in markdown format
7. **VCS context is automatically detected** from git branches
8. **All relationship types are bidirectional** (show outgoing + incoming)
