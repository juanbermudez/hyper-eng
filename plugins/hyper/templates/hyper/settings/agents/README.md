# Agent Customization

This directory contains customization files for Hyper Engineering agents. You can override default agent behavior by editing these files.

## How It Works

1. Each agent has a corresponding `.yaml` file in this directory
2. Edit the file to customize prompts, instructions, or behavior
3. The hyper-engineering plugin merges your customizations with the default agent configuration
4. Only specify what you want to change - defaults are preserved for everything else

## File Structure

```
agents/
├── README.md                           # This file
├── research-orchestrator.yaml          # Customize research coordination
├── implementation-orchestrator.yaml    # Customize implementation coordination
├── repo-research-analyst.yaml          # Customize codebase research
├── best-practices-researcher.yaml      # Customize best practices research
├── framework-docs-researcher.yaml      # Customize framework docs research
├── git-history-analyzer.yaml           # Customize git history analysis
└── web-app-debugger.yaml              # Customize browser debugging
```

## Customization Options

Each agent file supports these customization sections:

### `context_additions`
Add project-specific context that all invocations of this agent should know:

```yaml
context_additions: |
  - Our team uses Tailwind CSS for all styling
  - We follow the BEM naming convention for CSS classes
  - All API calls should use the custom `useApi` hook
```

### `instructions_prepend`
Instructions added BEFORE the default agent instructions:

```yaml
instructions_prepend: |
  IMPORTANT: Always check for existing implementations in src/legacy/ before creating new code.
```

### `instructions_append`
Instructions added AFTER the default agent instructions:

```yaml
instructions_append: |
  When complete, also update the internal wiki at docs/internal/.
```

### `output_format`
Override the default output format:

```yaml
output_format: |
  Return findings as a bullet list, not JSON.
  Include file paths as clickable links.
```

### `disabled`
Temporarily disable an agent:

```yaml
disabled: true
reason: "Using custom research process"
```

## Example: Customizing the Research Orchestrator

```yaml
# $HYPER_WORKSPACE_ROOT/settings/agents/research-orchestrator.yaml

context_additions: |
  - This is a Ruby on Rails monolith
  - We use RSpec for testing
  - The legacy code is in app/legacy/ - analyze but don't recommend patterns from there

instructions_append: |
  After research completes, also check:
  1. Are there any TODOs in the codebase related to this feature?
  2. Are there any open GitHub issues related to this?

  Include findings in the research summary.

# Skip git history analysis for this project (we have a messy history)
skip_sub_agents:
  - git-history-analyzer
```

## Example: Customizing the Implementation Orchestrator

```yaml
# $HYPER_WORKSPACE_ROOT/settings/agents/implementation-orchestrator.yaml

context_additions: |
  - All new code must include JSDoc comments
  - Use TypeScript strict mode
  - Components should be functional, not class-based

instructions_prepend: |
  CRITICAL: Never modify files in src/core/ without explicit approval.
  These are shared across multiple products.

verification_overrides:
  # Add additional verification step
  additional_checks:
    - name: "JSDoc Coverage"
      command: "npm run check:jsdoc"
      required: true
```

## Tips

1. **Start minimal**: Only add customizations you actually need
2. **Test changes**: Run a small task after customizing to verify behavior
3. **Version control**: Commit your settings/ directory to share with team
4. **Reset to defaults**: Delete a file to reset that agent to defaults
