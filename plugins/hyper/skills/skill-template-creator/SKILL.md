---
name: skill-template-creator
description: This skill creates new skills as templates for HyperCraft workflows, integrating with the workspace settings and template system. Use when creating custom skills that follow hyper-engineering conventions.
model: sonnet
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

# Skill Template Creator

Create new skills that integrate with HyperCraft's template system and workspace settings.

## When to Use

Use this skill when:
- Creating a new skill for hyper workflows
- Converting an existing skill to use templates
- Adding a configurable skill slot

## Workflow

### Step 1: Understand the Use Case

Use AskUserQuestion to gather requirements:

```
question: "What should this skill do?"
header: "Purpose"
options:
  - label: "Documentation/Research"
    description: "Fetch docs, research topics, analyze information"
  - label: "Code Operations"
    description: "Search, analyze, or transform code"
  - label: "Testing/Verification"
    description: "Run tests, verify behavior, check quality"
  - label: "Integration"
    description: "Connect to external services or APIs"
```

### Step 2: Determine Skill Location

```
question: "Where should this skill live?"
header: "Location"
options:
  - label: "Plugin skill (Recommended)"
    description: "Available to all workspaces, lives in hyper-eng-plugin"
  - label: "Workspace skill"
    description: "Project-specific, lives in $HYPER_WORKSPACE_ROOT/skills/"
```

### Step 3: Determine Configurability

```
question: "Should users be able to customize this skill?"
header: "Config"
options:
  - label: "Yes, create template"
    description: "Users can configure via Settings UI"
  - label: "No, fixed implementation"
    description: "Skill works the same for everyone"
```

### Step 4: Create Skill Structure

See [skill-structure.md](./references/skill-structure.md) for required structure.

### Step 5: Generate Template (if configurable)

See [template-integration.md](./references/template-integration.md) for template format.

## Output Locations

### Plugin Skills

```
hyper-engineer-plugin/plugins/hyper/
├── skills/{skill-name}/
│   ├── SKILL.md
│   └── references/
│       └── *.md
└── templates/hyper/settings/skills/
    └── {skill-slot}.yaml
```

### Workspace Skills

```
$HYPER_WORKSPACE_ROOT/
├── skills/{skill-name}/
│   ├── SKILL.md
│   └── references/
│       └── *.md
└── settings/skills/
    └── {skill-slot}.yaml
```

## Skill File Requirements

### SKILL.md Frontmatter

```yaml
---
name: skill-name                    # Required: lowercase-with-hyphens
description: This skill...          # Required: Third person, starts with "This skill"
model: sonnet                       # Optional: sonnet|opus|haiku
allowed-tools:                      # Optional: Tool restrictions
  - Read
  - Write
  - Bash
---
```

### Content Structure

1. **Title** - `# Skill Name`
2. **Overview** - What this skill does
3. **Quick Reference** - Most common operations
4. **Detailed Sections** - Comprehensive guidance
5. **References** - Links to reference docs

## Template Integration

If the skill is configurable, create a template:

```yaml
# templates/hyper/settings/skills/{slot}.yaml
# Description of the skill slot

# Selected skill implementation
selected: default-skill-name

# Implementation-specific configuration
config:
  skill-name-1:
    setting1: value1
  skill-name-2:
    setting1: value1

# Instructions added when skill loads
instructions_append: |
  Additional context...

# Contexts where skill should be skipped
skip_in_contexts: []
```

## References

- [skill-structure.md](./references/skill-structure.md) - Required file structure
- [frontmatter-guide.md](./references/frontmatter-guide.md) - SKILL.md frontmatter requirements
- [template-integration.md](./references/template-integration.md) - Template system integration
- [examples/](./references/examples/) - Example skill templates

## Best Practices

1. **Follow hyper-craft conventions** - Load hyper-craft for shared knowledge
2. **Use third person** - "This skill provides..." not "Use this skill to..."
3. **Keep skills focused** - One skill, one responsibility
4. **Include examples** - Show common usage patterns
5. **Reference don't repeat** - Link to reference docs for detailed info
6. **Test with skill: command** - Verify skill loads correctly
