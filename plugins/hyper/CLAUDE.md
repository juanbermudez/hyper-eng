# Hyper-Engineering Plugin Development

A Claude Code plugin for spec-driven development workflows with local `$HYPER_WORKSPACE_ROOT/` directory management.

## Claude Code Documentation

This plugin uses core Claude Code concepts. Reference these docs when modifying or extending:

| Concept | Documentation | Used For |
|---------|---------------|----------|
| **Sub-Agents** | [code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents) | Research/implementation orchestrators |
| **Plugins** | [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins) | Plugin structure, plugin.json manifest |
| **Skills** | [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills) | SKILL.md format, model-invoked knowledge |
| **Hooks** | [code.claude.com/docs/en/hooks-guide](https://code.claude.com/docs/en/hooks-guide) | Event-driven automation |

---

## Plugin Structure

```
plugins/hyper-engineering/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest (name, version, description)
├── agents/                      # Sub-agent definitions (10 agents)
│   ├── orchestrators/           # Workflow coordinators
│   │   ├── research-orchestrator.md
│   │   └── implementation-orchestrator.md
│   ├── research/                # Specialized researchers (4)
│   │   ├── repo-research-analyst.md
│   │   ├── best-practices-researcher.md
│   │   ├── framework-docs-researcher.md
│   │   └── git-history-analyzer.md
│   └── testing/
│       └── web-app-debugger.md
├── commands/                    # Slash commands (8 commands)
│   ├── hyper-plan.md            # /hyper:plan - Research → Spec → Tasks
│   ├── hyper-implement.md       # /hyper:implement - Execute tasks
│   ├── hyper-verify.md          # /hyper:verify - Verification loop
│   ├── hyper-review.md          # /hyper:review - Code review
│   ├── hyper-status.md          # /hyper:status - Project status
│   ├── hyper-init.md            # /hyper:init - Initialize $HYPER_WORKSPACE_ROOT/
│   ├── hyper-init-stack.md      # /hyper:init-stack - Project scaffolding
├── skills/                      # Model-invoked skills (3 skills)
│   ├── hyper-local/             # $HYPER_WORKSPACE_ROOT/ directory operations
│   │   ├── SKILL.md             # Main skill definition
│   │   └── references/          # Supporting documentation
│   │       ├── directory-structure.md
│   │       ├── frontmatter-schema.md
│   │       ├── template-guide.md
│   │       ├── workflow-guide.md
│   │       └── settings-guide.md
│   ├── compound-docs/           # Pattern documentation
│   └── git-worktree/            # Git worktree management
├── templates/                   # Scaffolding templates
│   ├── hyper/                   # $HYPER_WORKSPACE_ROOT/ templates
│   └── stacks/                  # Project stack templates
├── CLAUDE.md                    # This file
├── README.md                    # User documentation
└── CHANGELOG.md                 # Version history
```

---

## Versioning Requirements

**IMPORTANT**: Every change to this plugin MUST include updates to all three files:

1. **`.claude-plugin/plugin.json`** - Bump version using semver
2. **`CHANGELOG.md`** - Document changes using Keep a Changelog format
3. **`README.md`** - Verify/update component counts and tables

### Version Bumping Rules

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes, major reorganization
- **MINOR** (1.0.0 → 1.1.0): New agents, commands, or skills
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, doc updates, minor improvements

### Pre-Commit Checklist

Before committing ANY changes:

- [ ] Version bumped in `.claude-plugin/plugin.json`
- [ ] CHANGELOG.md updated with changes
- [ ] README.md component counts verified
- [ ] README.md tables accurate (agents, commands, skills)
- [ ] plugin.json description matches current counts

### Counting Components

```bash
# Count agents
ls agents/*/*.md | wc -l

# Count commands
ls commands/*.md | wc -l

# Count skills
ls -d skills/*/ 2>/dev/null | wc -l
```

Current counts: **10 agents, 8 commands, 12 skills, 1 MCP server**

---

## Project/Task MDX Format

**CRITICAL**: When agents create projects and tasks, they MUST follow this exact format. Incorrect formatting causes parsing failures in Hypercraft.

### Project Frontmatter (`_project.mdx`)

```yaml
---
id: proj-{slug}                    # REQUIRED: Prefix with "proj-"
title: "Project Title"             # REQUIRED: Human-readable name
type: project                      # REQUIRED: Must be "project"
status: planned                    # REQUIRED: See status values below
priority: high                     # REQUIRED: urgent|high|medium|low
summary: "Brief description"       # REQUIRED: One-line summary
created: YYYY-MM-DD                # REQUIRED: ISO date
updated: YYYY-MM-DD                # REQUIRED: ISO date
tags:                              # OPTIONAL: Searchable tags
  - tag1
  - tag2
---
```

**Project Status Values**: `planned` → `todo` → `in-progress` → `qa` → `completed` | `canceled`

### Task Frontmatter (`tasks/task-NNN.mdx`)

```yaml
---
id: task-{slug}-NNN                # REQUIRED: Match filename number
title: "Phase N: Task Name"        # REQUIRED: Descriptive title
type: task                         # REQUIRED: Must be "task"
status: todo                       # REQUIRED: See status values below
priority: high                     # REQUIRED: urgent|high|medium|low
parent: proj-{slug}                # REQUIRED: Must match parent project ID
depends_on: []                     # OPTIONAL: Array of task IDs
created: YYYY-MM-DD                # REQUIRED: ISO date
updated: YYYY-MM-DD                # REQUIRED: ISO date
tags:                              # OPTIONAL: Searchable tags
  - phase-1
---
```

**Task Status Values**: `draft` | `todo` → `in-progress` → `qa` → `complete` | `blocked`

### QA Status

The `qa` status is the quality assurance phase where verification happens:

**For Tasks**:
- Run automated checks: lint, typecheck, test, build
- Run manual verification: browser testing, code review
- If checks fail → back to `in-progress` to fix
- Only move to `complete` when ALL checks pass

**For Projects**:
- All tasks must be `complete` before project enters `qa`
- Integration testing, final review, documentation check
- If issues found → back to `in-progress`
- Only move to `completed` when project-level QA passes

### Common Mistakes to Avoid

| Mistake | Correct |
|---------|---------|
| `id: auth-system` | `id: proj-auth-system` (projects need `proj-` prefix) |
| `id: 001` | `id: task-auth-system-001` (tasks need full ID) |
| `status: in_progress` | `status: in-progress` (use hyphens) |
| `status: done` | `status: complete` (exact status values) |
| `parent: auth-system` | `parent: proj-auth-system` (include prefix) |
| Missing `type: task` | Always include `type` field |

### Validation Reference

See `skills/hyper-local/references/frontmatter-schema.md` for complete schema.

---

## Drive/Notes MDX Format

**CRITICAL**: When creating Drive notes (artifacts), you MUST use the correct ID format or files will not appear in Hypercraft UI.

### Drive Note Frontmatter

```yaml
---
id: "personal:my-note-slug"        # REQUIRED: Scope-prefixed ID
title: "My Note Title"             # REQUIRED: Human-readable title
icon: FileText                     # OPTIONAL: Lucide icon name
created: 2026-01-18                # REQUIRED: ISO date
updated: 2026-01-18                # OPTIONAL: ISO date
sortPosition: a0                   # OPTIONAL: Ordering position
---
```

### Drive ID Format (CRITICAL)

The `id` field MUST include a scope prefix followed by a colon:

| Scope | ID Format | Example |
|-------|-----------|---------|
| Personal | `personal:{slug}` | `id: "personal:research-notes"` |
| Organization | `org-{orgId}:{slug}` | `id: "org-abc123:team-docs"` |
| Workspace | `ws-{wsId}:{slug}` | `id: "ws-proj-123:notes"` |

**Always prefer the CLI** for creating drive files:

```bash
hyper drive create "My Note Title" --icon "FileText" --json
```

See `skills/hyper-cli/SKILL.md` for full Drive API documentation.

### Choosing the Right Scope

| Artifact Type | Recommended Scope | Rationale |
|---------------|-------------------|-----------|
| Personal notes | `personal:` | Private learning, research, drafts |
| Workspace artifacts | `ws:{workspaceId}:` | Shared context for workspace projects |
| Project diagrams | `proj:{projectId}:` | Project-specific design docs |
| Team templates | `org:{orgId}:` | Cross-workspace org standards |

**Rule of thumb**:
- Personal notes → Personal Drive (global `/drive`)
- Project artifacts → Workspace Drive (per-workspace)
- Planning docs → `$HYPER_WORKSPACE_ROOT/projects/{slug}/` (git-tracked)

### Creating Workspace-Scoped Artifacts

```bash
# Create in personal drive (default)
hyper drive create "My Personal Note" --icon "FileText"

# Create in workspace drive
hyper drive create "Design Doc" --scope ws:my-workspace --icon "Layout"

# Create in project scope
hyper drive create "Architecture" --scope proj:my-project --icon "Box"
```

---

## Command Naming Convention

**Workflow commands** use `hyper-` prefix to identify them as Hyper Engineering commands:

- `/hyper:plan` - Create implementation plans with research
- `/hyper:implement` - Execute tasks with verification
- `/hyper:review` - Run comprehensive code reviews
- `/hyper:verify` - Verification loops
- `/hyper:status` - View project/task status

---

## Skill Compliance Checklist

When adding or modifying skills, verify compliance with Claude Code skill spec:

### YAML Frontmatter (Required)

- [ ] `name:` present and matches directory name (lowercase-with-hyphens)
- [ ] `description:` present and uses **third person** ("This skill should be used when..." NOT "Use this skill when...")

### Reference Links (Required if references/ exists)

- [ ] All files in `references/` are linked as `[filename.md](./references/filename.md)`
- [ ] All files in `assets/` are linked as `[filename](./assets/filename)`
- [ ] All files in `scripts/` are linked as `[filename](./scripts/filename)`
- [ ] No bare backtick references like `` `references/file.md` `` - use proper markdown links

### Writing Style

- [ ] Use imperative/infinitive form (verb-first instructions)
- [ ] Avoid second person ("you should") - use objective language

### Quick Validation Command

```bash
# Check for unlinked references in a skill
grep -E '`(references|assets|scripts)/[^`]+`' skills/*/SKILL.md
# Should return nothing if all refs are properly linked

# Check description format
grep -E '^description:' skills/*/SKILL.md | grep -v 'This skill'
# Should return nothing if all use third person
```

---

## Agent Definition Format

Agents are Markdown files with YAML frontmatter. See [Sub-Agents documentation](https://code.claude.com/docs/en/sub-agents).

```markdown
---
name: agent-name
description: When this agent should be invoked (natural language)
tools: Read, Grep, Glob, Bash, Task      # Optional - comma-separated
model: sonnet                             # Optional - sonnet|opus|haiku|inherit
---

Agent system prompt goes here. Include:
- Role and expertise area
- Specific instructions and workflow
- Output format expectations
- Best practices and constraints
```

---

## Testing Changes Locally

1. Install the marketplace locally:
   ```bash
   claude /plugin marketplace add /path/to/hyper-eng
   ```

2. Install the plugin:
   ```bash
   claude /plugin install hyper
   ```

3. Test commands and agents:
   ```bash
   claude /hyper:status
   claude /hyper:plan "Test feature"
   ```

4. Or load directly:
   ```bash
   claude --plugin-dir ./plugins/hyper-engineering
   ```

---

## Integration with Hypercraft

This plugin creates `$HYPER_WORKSPACE_ROOT/` directory structures that are visualized by the Hypercraft desktop app:

- **Plugin creates**: Projects, tasks, specs, research docs in `$HYPER_WORKSPACE_ROOT/`
- **Hypercraft reads**: Displays projects, tasks, status in UI
- **File system is the API**: No sync needed, changes are immediate

---

## Resources

- [Claude Code Plugin Documentation](https://code.claude.com/docs/en/plugins)
- [Sub-Agents Guide](https://code.claude.com/docs/en/sub-agents)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
