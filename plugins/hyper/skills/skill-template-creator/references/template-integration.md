# Template Integration Guide

How to create skills that integrate with HyperCraft's workspace settings and template system.

## Overview

Configurable skills use templates that:
1. Define a **skill slot** with multiple implementations
2. Allow users to **select** their preferred implementation
3. **Materialize** to workspace settings
4. Get **resolved** at runtime

## Template Location

### Plugin Templates

```
hyper-engineer-plugin/plugins/hyper/templates/hyper/settings/skills/{slot}.yaml
```

### Workspace Settings (Materialized)

```
$HYPER_WORKSPACE_ROOT/settings/skills/{slot}.yaml
```

## Template Format

```yaml
# {slot-name}.yaml
# Description comment explaining this skill slot

# Selected skill implementation
# Options: skill-1, skill-2, none
selected: skill-1

# Implementation-specific configuration
config:
  skill-1:
    setting1: value1
    setting2: value2
  skill-2:
    setting1: value1
    setting2: value2

# Instructions added when this skill loads
instructions_append: |
  Additional context or guidelines that apply
  regardless of which implementation is selected.

# Contexts where this skill should be skipped
skip_in_contexts: []
  # Example:
  # - quick-review
  # - docs-only
```

## Creating a New Skill Slot

### Step 1: Define the Slot

Determine:
- **Slot name**: lowercase-with-hyphens (e.g., `api-client`)
- **Purpose**: What capability this slot provides
- **Implementations**: Available skill options

### Step 2: Create Plugin Template

```yaml
# templates/hyper/settings/skills/api-client.yaml
# API Client Skill Configuration
# This skill provides HTTP client capabilities for API integration.

# Selected skill implementation
# Options: fetch-wrapper, axios-helper, none
selected: fetch-wrapper

config:
  fetch-wrapper:
    timeout_ms: 30000
    retry_count: 3

  axios-helper:
    timeout_ms: 30000
    base_url: ""

instructions_append: |
  When making API calls:
  - Always handle errors gracefully
  - Include appropriate headers
  - Log requests for debugging

skip_in_contexts: []
```

### Step 3: Create Skill Implementations

For each implementation option, create a skill:

```
skills/fetch-wrapper/
├── SKILL.md
└── references/
    └── api.md

skills/axios-helper/
├── SKILL.md
└── references/
    └── api.md
```

### Step 4: Document in README

Update the skills README to document the new slot:

```markdown
## Skill Slots

| Slot | Default | Options | Purpose |
|------|---------|---------|---------|
| api-client | fetch-wrapper | fetch-wrapper, axios-helper, none | HTTP client |
```

## Runtime Resolution

When an agent declares a skill slot:

```prose
agent api-integrator:
  skills:
    - hyper-craft
    - api-client       # This is a slot, not a specific skill
```

The runtime resolves `api-client` by:

1. Check `$HYPER_WORKSPACE_ROOT/settings/skills/api-client.yaml`
2. If found, use `selected` value
3. If not found, use template default
4. Load the corresponding skill implementation

## Configuration Access

Skills can access their configuration:

```markdown
## Configuration

This skill reads configuration from the workspace settings:

- `timeout_ms`: Request timeout in milliseconds
- `retry_count`: Number of retry attempts

Default values are used if not configured.
```

## Best Practices

1. **Provide sensible defaults** - Templates should work without customization
2. **Document all options** - Comments in template explain each setting
3. **Include `none` option** - Allow users to disable the slot
4. **Keep config minimal** - Only expose settings that users need
5. **Use consistent naming** - Slot names match skill purposes

## Example: Adding a New Slot

### Scenario

Create an `ai-model` slot for model selection.

### Implementation

1. **Create template**:

```yaml
# templates/hyper/settings/skills/ai-model.yaml
# AI Model Skill Configuration
# Configures model preferences for AI operations.

selected: anthropic-claude

config:
  anthropic-claude:
    default_model: sonnet

  openai-gpt:
    default_model: gpt-4

skip_in_contexts: []
```

2. **Create skills**:

```
skills/anthropic-claude/SKILL.md
skills/openai-gpt/SKILL.md
```

3. **Use in agents**:

```prose
agent summarizer:
  skills:
    - ai-model     # Resolved from settings
  prompt: "Summarize the following..."
```
