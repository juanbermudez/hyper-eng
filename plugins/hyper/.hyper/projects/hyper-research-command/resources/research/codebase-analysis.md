---
type: resource
category: research
title: Codebase Analysis
project: hyper-research-command
created: 2026-01-03
---

# Codebase Analysis: /hyper:research Command

## Executive Summary

Analysis of the Hyper Engineering Plugin codebase reveals a well-structured architecture for spec-driven development. Adding a `/hyper:research` command requires extending the existing document type system, status workflow, and integrating with both the CLI and desktop app. The current research-orchestrator agent provides a solid foundation that can be enhanced for standalone deep research workflows.

## Existing Architecture Patterns

### 1. Command Structure Pattern

**Location**: `commands/*.md`

All commands follow a consistent structure:
```markdown
---
name: command-name
description: Brief description
argument-hint: "[expected arguments]"
---

<agent name="command-agent">
  <description>Extended description</description>
  <context>
    <role>Agent role</role>
    <tools>Comma-separated tool list</tools>
    <workflow_stage>Stage in workflow</workflow_stage>
    <skills>Skills this command uses</skills>
  </context>
  <workflow>
    <phase name="phase_name" required="true|false" condition="optional">
      <instructions>Phase instructions</instructions>
    </phase>
  </workflow>
  <best_practices>...</best_practices>
  <error_handling>...</error_handling>
</agent>
```

**Key Commands to Reference**:
- `hyper-plan.md` (lines 1-1132): Most comprehensive command with research orchestration
- `hyper-status.md` (lines 1-323): Good template for status display patterns
- `hyper-init.md`: Template for initialization commands

### 2. Research Orchestrator Pattern

**Location**: `agents/orchestrators/research-orchestrator.md`

Current research-orchestrator:
- Spawns 4 sub-agents in parallel using Task tool
- Synthesizes findings into structured documents
- Writes to `$HYPER_WORKSPACE_ROOT/projects/{slug}/resources/research/`
- Returns JSON summary to parent (hyper-plan)

**Enhancement Opportunity**: Currently research is only a phase within `/hyper:plan`. A standalone `/hyper:research` command would:
1. Skip spec creation phases
2. Support deeper, iterative research
3. Use a different project type to indicate "research-only"

### 3. Document Type System

**Plugin Schema**: `skills/hyper-local/references/frontmatter-schema.md`

Current types:
```yaml
type: initiative | project | task | resource | doc
```

**Desktop App Schema**: `apps/desktop/src/lib/collections/schemas.ts`

```typescript
export const DocumentTypeSchema = z.enum([
  'initiative',
  'project',
  'task',
  'resource',
  'doc',
]);
```

**Finding**: No `research` type exists. We have two options:
1. Add `research` as a new document type
2. Use `type: project` with a new field like `project_type: research`

### 4. Status Workflow System

**Workflow Config**: `templates/hyper/settings/workflows.yaml`

Current project workflow stages:
```yaml
project_workflow:
  stages:
    - id: planned
    - id: review      # Spec review gate
    - id: todo        # Ready for work
    - id: in-progress
    - id: blocked
    - id: verification
    - id: complete
    - id: cancelled
```

Current task workflow stages:
```yaml
task_workflow:
  stages:
    - id: todo
    - id: in-progress
    - id: blocked
    - id: review      # Implementation review
    - id: complete
    - id: cancelled
```

**Missing for Research**:
- `ready-for-review` - research complete, awaiting feedback
- `archived` - research concluded, preserved for reference

### 5. CLI Integration Pattern

**Referenced in**: `hyper-plan.md` (lines 258-273)

CLI usage pattern:
```bash
${CLAUDE_PLUGIN_ROOT}/binaries/hyper project create \
  --slug "${PROJECT_SLUG}" \
  --title "[TITLE]" \
  --priority "[PRIORITY]" \
  --summary "[BRIEF_SUMMARY]"

${CLAUDE_PLUGIN_ROOT}/binaries/hyper task create \
  --project "${PROJECT_SLUG}" \
  --id "${TASK_ID}" \
  --title "Phase ${TASK_NUM}: [Phase Name]"
```

**New Commands Needed**:
- `hyper research create` - Create research project with proper type
- `hyper research update` - Update research findings/status
- `hyper research archive` - Archive completed research

### 6. Desktop App Type Handling

**Schema Location**: `apps/desktop/src/lib/collections/schemas.ts`

The desktop app uses Zod schemas and TanStack DB collections. Key patterns:

```typescript
// Document types are enum-based
export const DocumentTypeSchema = z.enum([...]);

// Status accepts all possible values
export const AnyStatusSchema = z.enum([
  // Task statuses
  'draft', 'todo', 'in-progress', 'review', 'qa', 'complete', 'blocked',
  // Project-specific statuses
  'planned', 'planning', 'completed', 'canceled',
]);
```

**To add research project support**:
1. Either add `research` to `DocumentTypeSchema`
2. Or add a `projectType` field to distinguish research from implementation projects

## Relevant Files

### Plugin Core Files

| File | Lines | Purpose |
|------|-------|---------|
| `agents/orchestrators/research-orchestrator.md` | 1-407 | Current research coordination logic |
| `commands/hyper:plan.md` | 1-1132 | Main planning command with embedded research |
| `commands/hyper:status.md` | 1-323 | Status display patterns |
| `skills/hyper-local/references/frontmatter-schema.md` | 1-445 | Schema definitions |
| `skills/hyper-local/references/directory-structure.md` | 1-225 | Directory conventions |
| `templates/hyper/settings/workflows.yaml` | 1-291 | Workflow stage definitions |
| `templates/hyper/project.mdx.template` | 1-148 | Project template |

### Desktop App Files

| File | Lines | Purpose |
|------|-------|---------|
| `apps/desktop/src/lib/collections/schemas.ts` | 1-298 | Zod schemas for all types |
| `apps/desktop/src/lib/workflow/types.ts` | 1-95 | Workflow stage types |
| `apps/desktop/src/lib/parser/frontmatter.ts` | - | Frontmatter parsing logic |
| `apps/desktop/src/lib/sync/handlers/DocumentSyncHandler.ts` | - | Document sync logic |

## Reusable Components

### From Research Orchestrator

The current research-orchestrator can be extracted and enhanced:

```markdown
<phase name="parallel_research">
  Spawn research sub-agents in parallel using Task tool:
  1. repo-research-analyst
  2. best-practices-researcher
  3. framework-docs-researcher
  4. git-history-analyzer
</phase>

<phase name="synthesis">
  1. Collect JSON output from each agent
  2. Cross-reference patterns
  3. Prioritize by relevance
  4. Identify key decisions
</phase>

<phase name="document_creation">
  Write to: $HYPER_WORKSPACE_ROOT/projects/{slug}/resources/research/
  - codebase-analysis.md
  - best-practices.md
  - framework-docs.md
  - git-history.md
  - research-summary.md
</phase>
```

### From Status Command

Status display patterns for research-specific views:

```bash
# Status emoji mapping
case "$status" in
  "complete") status_icon="✓" ;;
  "in-progress") status_icon="▶" ;;
  "ready-for-review") status_icon="🔍" ;;  # New for research
  "archived") status_icon="📦" ;;           # New for research
  ...
esac
```

## Conventions to Follow

### Naming Conventions

| Convention | Pattern | Example |
|------------|---------|---------|
| Command file | `hyper-{name}.md` | `hyper-research.md` |
| Agent name | `hyper-{name}-agent` | `hyper-research-agent` |
| Project ID | `proj-{slug}` | `proj-auth-research` |
| Research resource | `resources/research/*.md` | Same as current |

### Status Values

Current pattern uses kebab-case:
- `in-progress` (not `in_progress`)
- `ready-for-review` (proposed)
- `qa` (quality assurance phase)

### Directory Structure for Research Projects

```
$HYPER_WORKSPACE_ROOT/projects/{research-slug}/
├── _project.mdx           # type: project, project_type: research
├── resources/
│   └── research/
│       ├── codebase-analysis.md
│       ├── best-practices.md
│       ├── framework-docs.md
│       ├── git-history.md
│       └── research-summary.md
└── (no tasks/ directory for pure research)
```

## Integration Points

### 1. Plugin Changes Needed

- [ ] New command: `commands/hyper:research.md`
- [ ] Update: `skills/hyper-local/references/frontmatter-schema.md` - add `project_type` field
- [ ] Update: `templates/hyper/settings/workflows.yaml` - add research-specific statuses
- [ ] Update: `CHANGELOG.md` and `plugin.json` version

### 2. CLI Changes Needed

- [ ] Add `hyper research create` subcommand
- [ ] Add `hyper research update` subcommand
- [ ] Add `hyper research archive` subcommand
- [ ] Support `--project-type research` flag on `project create`

### 3. Desktop App Changes Needed

- [ ] Update `DocumentTypeSchema` OR add `projectType` field to schema
- [ ] Update `AnyStatusSchema` with new research statuses
- [ ] Add visual indicator for research vs implementation projects
- [ ] Filter/sort options for project types

## Key Architectural Decision

**Recommended Approach: Use `project_type` field instead of new document type**

Reasoning:
1. Research projects still have the same directory structure as regular projects
2. The UI can filter/display differently based on `project_type`
3. Less disruptive to existing schema and parsing logic
4. Research can later transition to implementation (change `project_type`, add tasks)

```yaml
---
id: proj-auth-research
title: "Authentication Security Research"
type: project                    # Keep as project
project_type: research           # NEW: research | implementation (default)
status: in-progress
---
```
