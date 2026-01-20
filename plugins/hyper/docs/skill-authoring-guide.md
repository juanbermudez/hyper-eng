# Skill Authoring Guide

How to create custom skills for HyperCraft workflows.

## Overview

Skills are specialized knowledge packages that agents load at runtime. They provide domain-specific guidance, patterns, and instructions that help agents perform tasks more effectively.

**Types of skills:**
- **Core skills** - Always loaded by hyper agents (e.g., `hyper-craft`)
- **Task skills** - Loaded for specific workflow phases (e.g., `hyper-planning`)
- **User skills** - Configurable skills selected via Settings UI

## Skill Structure

### Minimal Skill

```
skills/{skill-name}/
└── SKILL.md              # Main skill file (required)
```

### Full Skill

```
skills/{skill-name}/
├── SKILL.md              # Main skill file (required)
├── references/           # Supporting documentation (optional)
│   ├── quick-reference.md
│   ├── detailed-guide.md
│   └── api-reference.md
├── assets/               # Static files (optional)
│   └── diagram.png
└── scripts/              # Helper scripts (optional)
    └── setup.sh
```

## SKILL.md Format

### Required Frontmatter

```yaml
---
name: skill-name                    # Must match directory name
description: This skill...          # Third person, starts with "This skill"
---
```

### Optional Frontmatter

```yaml
---
name: skill-name
description: This skill provides...
model: sonnet                       # Preferred model: opus|sonnet|haiku
version: 1.0.0                      # Semantic version
allowed-tools:                      # Tool restrictions
  - Read
  - Write
  - Bash
  - Grep
  - Glob
includes:                           # Other skills to load
  - hyper-craft
---
```

### Content Structure

```markdown
---
name: my-skill
description: This skill provides guidance for XYZ operations.
---

# My Skill

## Overview
[What this skill does - 2-3 paragraphs]

## Quick Reference
[Most common operations - table or code blocks]

## [Main Content Sections]
[Detailed guidance organized by topic]

## References
[Links to reference docs in ./references/]
```

## Writing Style

### Do's
- Use imperative/infinitive form ("Run the command", "Create the file")
- Be concise but complete
- Include code examples with language annotations
- Link reference files using markdown: `[filename.md](./references/filename.md)`

### Don'ts
- Don't use second person ("you should...")
- Don't use backticks for file references: `` `references/file.md` ``
- Don't leave dead links to reference files

## Creating a Plugin Skill

Plugin skills are shared across all workspaces.

**Location**: `hyper-engineer-plugin/plugins/hyper/skills/{skill-name}/`

**When to use**:
- Skill applies to all projects
- Skill is part of the core workflow
- Skill should be available out-of-the-box

### Steps

1. Create skill directory:
   ```bash
   mkdir -p hyper-engineer-plugin/plugins/hyper/skills/my-skill/references
   ```

2. Create SKILL.md with frontmatter:
   ```markdown
   ---
   name: my-skill
   description: This skill provides guidance for...
   ---
   ```

3. Write content following the structure above

4. Test the skill:
   ```bash
   claude skill my-skill
   ```

## Creating a Workspace Skill

Workspace skills are project-specific.

**Location**: `$HYPER_WORKSPACE_ROOT/skills/{skill-name}/`

**When to use**:
- Skill is specific to this project
- Skill contains proprietary patterns
- Skill needs to evolve with the project

### Steps

1. Create skill directory:
   ```bash
   mkdir -p $HYPER_WORKSPACE_ROOT/skills/my-project-skill
   ```

2. Create SKILL.md following the same format as plugin skills

3. Workspace skills are automatically discovered and available

## Making Skills Configurable

To allow users to select between skill implementations via the Settings UI:

### 1. Create Skill Slot Template

Create at `templates/hyper/settings/skills/{slot-name}.yaml`:

```yaml
# {slot-name}.yaml
# Description of what this skill slot provides

# Selected skill implementation
# Options: skill-1, skill-2, none
selected: skill-1

# Implementation-specific configuration
config:
  skill-1:
    setting1: value1
  skill-2:
    setting1: value1

# Contexts where this skill should be skipped
skip_in_contexts: []
```

### 2. Create Skill Implementations

Create a skill for each option:

```
skills/skill-1/SKILL.md
skills/skill-2/SKILL.md
```

### 3. Use in Agent Definitions

Reference the slot in prose agent definitions:

```prose
agent my-agent:
  skills:
    - hyper-craft        # Core skill
    - {slot-name}        # Resolved from settings
```

### 4. Resolution Order

1. Workspace settings (`$HYPER_WORKSPACE_ROOT/settings/skills/{slot}.yaml`)
2. Template defaults (`templates/hyper/settings/skills/{slot}.yaml`)
3. Built-in defaults

## Tool Restrictions

Specify which tools the skill can use:

```yaml
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - WebFetch
  - AskUserQuestion
```

**Common tool sets by skill type:**

| Skill Type | Recommended Tools |
|------------|-------------------|
| Read-only research | Read, Grep, Glob, WebFetch |
| Code modification | Read, Write, Edit, Grep, Glob |
| CLI operations | Read, Bash, Grep, Glob |
| Interactive | All + AskUserQuestion |

## Including Other Skills

Load other skills to compose capabilities:

```yaml
includes:
  - hyper-craft              # Core knowledge
  - code-search              # Add code search capability
```

**Guidelines:**
- Most skills should include `hyper-craft`
- Avoid circular dependencies
- Use includes for shared knowledge, not composition

## Best Practices

### 1. Keep Skills Focused

One skill = one responsibility. If a skill does too much, split it.

### 2. Use References for Large Content

Keep SKILL.md digestible. Move detailed content to `references/`:

```markdown
## References

- [api-reference.md](./references/api-reference.md) - Full API documentation
- [patterns.md](./references/patterns.md) - Common patterns and examples
```

### 3. Follow Output Contract Format

If the skill is used by sub-agents, follow the output contract:

```json
{
  "status": "complete",
  "findings": { ... },
  "artifacts": { ... },
  "next_steps": [ ... ]
}
```

### 4. Test with Skill Command

Before committing, verify the skill loads:

```bash
claude skill my-skill
```

### 5. Update CHANGELOG

When adding/modifying skills, update the plugin CHANGELOG:

```markdown
## [1.x.x] - YYYY-MM-DD

### Added
- `my-skill` skill for XYZ operations
```

## Examples

### Research Skill

```markdown
---
name: framework-research
description: This skill provides guidance for researching framework documentation and best practices.
model: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebFetch
includes:
  - hyper-craft
---

# Framework Research

## Overview
This skill guides systematic research of framework documentation...

## Workflow

1. Identify framework and version
2. Fetch official documentation
3. Search for relevant patterns
4. Summarize findings

## Quick Reference

| Task | Tool |
|------|------|
| Fetch docs | WebFetch |
| Search code | Grep, Glob |
| Analyze patterns | Read |
```

### Verification Skill

```markdown
---
name: browser-verification
description: This skill provides guidance for verifying UI behavior through browser automation.
model: sonnet
allowed-tools:
  - Read
  - Bash
includes:
  - hyper-craft
---

# Browser Verification

## Overview
This skill guides automated UI verification...

## Verification Steps

1. Start the application
2. Navigate to target page
3. Verify expected elements
4. Capture screenshots
5. Report results
```

## Troubleshooting

### Skill Not Loading

1. Check frontmatter syntax (YAML must be valid)
2. Verify `name` matches directory name
3. Check `description` starts with "This skill"
4. Look for reference link errors

### Skill Conflicts

If two skills conflict:
1. Use `includes` to share common base
2. Create a combined skill that merges both
3. Use skill slots to let users choose

### References Not Found

Ensure all referenced files exist and links use proper format:
```markdown
[filename.md](./references/filename.md)  # Correct
`references/filename.md`                  # Wrong
```
