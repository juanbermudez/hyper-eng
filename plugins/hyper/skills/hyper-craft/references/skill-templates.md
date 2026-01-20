# Skill Templates Reference

Skill templates enable customizable skill loading for hyper workflows. Users configure which skills are loaded via templates that materialize to workspace settings.

## Overview

The skill template system follows the same pattern as agent and command templates:

1. **Plugin provides templates** at `templates/hyper/settings/skills/*.yaml`
2. **User customizes** by editing templates or workspace settings
3. **Runtime resolves** skill from workspace → template → default

## Skill Slots

Skill slots are functional roles filled by specific skill implementations:

### Core Slot (Always Loaded)

| Slot | Skill | Purpose |
|------|-------|---------|
| `core` | `hyper-craft` | Foundational knowledge for all agents |

The core skill is **always loaded** and cannot be changed. It provides:
- Directory structure (`$HYPER_WORKSPACE_ROOT/` layout)
- CLI reference
- Output contracts
- Lifecycle management
- Writing guidelines

### Configurable Slots

| Slot | Default | Options | Purpose |
|------|---------|---------|---------|
| `doc-lookup` | `context7` | `context7`, `web-search`, `none` | Documentation retrieval |
| `code-search` | `codebase-search` | `codebase-search`, `sourcegraph`, `none` | Codebase analysis |
| `browser-testing` | `playwright` | `playwright`, `puppeteer`, `none` | Browser automation |
| `error-tracking` | `sentry` | `sentry`, `none` | Error monitoring |

## Template Format

Skill templates use YAML format with standard sections:

```yaml
# {slot-name}.yaml
# Description comment

# Selected skill implementation
selected: default-skill-name

# Implementation-specific configuration
config:
  skill-name-1:
    setting1: value1
    setting2: value2
  skill-name-2:
    setting1: value1

# Instructions added when this skill loads
instructions_append: |
  Additional context or instructions...

# Contexts where this skill should be skipped
skip_in_contexts: []
```

## Resolution Flow

When an agent needs a skill slot, resolution happens in this order:

```
┌─────────────────────────────────────────────────────┐
│ 1. Check workspace settings                          │
│    $HYPER_WORKSPACE_ROOT/settings/skills/{slot}.yaml  │
│    └─ If found and selected ≠ 'none', use this       │
├─────────────────────────────────────────────────────┤
│ 2. Check template defaults                           │
│    templates/hyper/settings/skills/{slot}.yaml       │
│    └─ Use 'selected' value from template             │
├─────────────────────────────────────────────────────┤
│ 3. Use built-in default                              │
│    └─ Hard-coded default for each slot               │
└─────────────────────────────────────────────────────┘
```

## Workspace Settings Structure

When templates materialize to workspace:

```
$HYPER_WORKSPACE_ROOT/settings/
├── skills/
│   ├── doc-lookup.yaml       # User's doc-lookup config
│   ├── code-search.yaml      # User's code-search config
│   ├── browser-testing.yaml  # User's browser-testing config
│   └── error-tracking.yaml   # User's error-tracking config
├── agents/
│   └── {agent}.yaml          # Agent customization
└── commands/
    └── {command}.yaml        # Command customization
```

## Skill Configuration Examples

### Switching Documentation Lookup

To use web search instead of Context7:

```yaml
# $HYPER_WORKSPACE_ROOT/settings/skills/doc-lookup.yaml
selected: web-search

config:
  web-search:
    preferred_domains:
      - "react.dev"
      - "nextjs.org"
```

### Disabling Browser Testing

To skip browser testing entirely:

```yaml
# $HYPER_WORKSPACE_ROOT/settings/skills/browser-testing.yaml
selected: none
```

### Adding Project Context

To add project-specific instructions to any skill:

```yaml
# $HYPER_WORKSPACE_ROOT/settings/skills/code-search.yaml
selected: codebase-search

instructions_append: |
  When searching code:
  - Prioritize files in src/core/ for business logic
  - Legacy code in src/legacy/ is deprecated, avoid recommending patterns from there
  - Always check for corresponding test files
```

## Integration with Agents

Agents declare skill dependencies in their prose definition:

```prose
agent research-analyst:
  skills: [hyper-craft, doc-lookup, code-search]
  prompt: |
    Research the codebase and documentation...
```

At runtime, each skill slot is resolved and the appropriate skill content is loaded into the agent's context.

## Creating Custom Skills

To create a new skill for a slot:

1. Create skill directory: `skills/{skill-name}/SKILL.md`
2. Add to slot options in template
3. Add configuration section in template

Example for a custom `sourcegraph` code-search skill:

```markdown
<!-- skills/sourcegraph-search/SKILL.md -->
---
name: sourcegraph-search
description: Sourcegraph-powered code search for large repositories
---

# Sourcegraph Search Skill

Use Sourcegraph's semantic code search for complex queries...
```

Then reference in templates:

```yaml
# templates/hyper/settings/skills/code-search.yaml
selected: codebase-search

config:
  sourcegraph-search:
    instance_url: "https://sourcegraph.example.com"
    repo_patterns:
      - "github.com/myorg/*"
```

## Best Practices

1. **Start with defaults** - Only customize when needed
2. **Use `none` sparingly** - Disabling skills reduces capabilities
3. **Add context, don't replace** - Use `instructions_append` to extend
4. **Test after changes** - Verify workflows still work
5. **Version control settings** - Track `$HYPER_WORKSPACE_ROOT/settings/` in git

## Troubleshooting

### Skill not loading

1. Check `selected` value matches available skill
2. Verify YAML syntax is valid
3. Check for typos in skill name

### Wrong skill configuration

1. Verify the `config` section uses correct skill name
2. Check that configuration keys are valid

### Skill loading but not used

1. Verify agent declares the skill slot in `skills:` array
2. Check `skip_in_contexts` isn't blocking the current context
