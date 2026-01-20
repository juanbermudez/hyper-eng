# SKILL.md Frontmatter Guide

Required and optional frontmatter fields for HyperCraft skills.

## Required Fields

### name

Skill identifier, must match directory name.

```yaml
name: skill-name
```

**Rules:**
- Lowercase with hyphens
- No spaces or underscores
- Descriptive but concise
- Examples: `code-search`, `doc-lookup`, `browser-testing`

### description

Third-person description of the skill.

```yaml
description: This skill provides documentation lookup capabilities for framework and library research.
```

**Rules:**
- MUST start with "This skill..."
- Third person only (no "you" or imperatives)
- Single sentence or short paragraph
- Describes when the skill should be activated

## Optional Fields

### model

Preferred model for this skill.

```yaml
model: sonnet
```

**Values:** `sonnet`, `opus`, `haiku`

**Guidelines:**
- `opus` - Complex reasoning, multi-step tasks
- `sonnet` - General purpose (default)
- `haiku` - Simple lookups, formatting

### allowed-tools

Restrict which tools the skill can use.

```yaml
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
```

**Common Tool Sets:**

| Skill Type | Recommended Tools |
|------------|-------------------|
| Read-only research | Read, Grep, Glob |
| Code modification | Read, Write, Edit, Grep, Glob |
| CLI operations | Read, Bash, Grep, Glob |
| Interactive | All + AskUserQuestion |

### includes

Other skills to load with this one.

```yaml
includes:
  - hyper-craft
  - hyper-cli
```

**Guidelines:**
- Most skills should include `hyper-craft`
- Use for shared knowledge
- Avoid circular dependencies

### version

Semantic version for the skill.

```yaml
version: 1.0.0
```

## Complete Example

```yaml
---
name: api-integration
description: This skill provides guidance for integrating with external APIs including authentication, error handling, and rate limiting best practices.
model: sonnet
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - WebFetch
includes:
  - hyper-craft
---
```

## Validation Checklist

Before committing a new skill:

- [ ] `name` matches directory name
- [ ] `description` starts with "This skill..."
- [ ] `description` is third person
- [ ] `model` is valid (if specified)
- [ ] `allowed-tools` are appropriate (if specified)
- [ ] `includes` don't create circular dependencies
