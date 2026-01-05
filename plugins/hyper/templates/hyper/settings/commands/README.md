# Command Customization

This directory contains customization files for Hyper Engineering commands. You can override default command behavior by editing these files.

## How It Works

1. Each command has a corresponding `.yaml` file in this directory
2. Edit the file to customize prompts, phases, or behavior
3. The hyper-engineering plugin merges your customizations with the default command configuration
4. Only specify what you want to change - defaults are preserved for everything else

## File Structure

```
commands/
├── README.md                    # This file
├── hyper-plan.yaml              # Customize planning workflow
├── hyper-implement.yaml         # Customize implementation workflow
├── hyper-review.yaml            # Customize review workflow
├── hyper-verify.yaml            # Customize verification workflow
└── hyper-init-stack.yaml        # Customize stack initialization
```

## Customization Options

Each command file supports these customization sections:

### `context_additions`
Add project-specific context that all invocations of this command should know:

```yaml
context_additions: |
  - Our team uses a 2-week sprint cycle
  - All changes require at least one reviewer
  - We deploy to production every Thursday
```

### `phase_overrides`
Override specific phases of the command workflow:

```yaml
phase_overrides:
  research:
    instructions_append: |
      Also check our internal wiki at docs/internal/ for prior art.
  spec_creation:
    instructions_prepend: |
      IMPORTANT: All specs must include performance requirements.
```

### `skip_phases`
Skip phases that aren't relevant to your workflow:

```yaml
skip_phases:
  - browser_verification  # We don't have a frontend
```

### `quality_gates`
Override quality gate requirements:

```yaml
quality_gates:
  # Override specific gates
  lint:
    command: "pnpm lint"
    required: true
  # Add custom gates
  custom_check:
    name: "Security Scan"
    command: "npm run security:scan"
    required: true
```

### `disabled`
Temporarily disable a command:

```yaml
disabled: true
reason: "Using custom planning process during migration"
```

## Example: Customizing hyper-plan

```yaml
# .hyper/settings/commands/hyper-plan.yaml

context_additions: |
  - This project follows Domain-Driven Design principles
  - We use event sourcing for state management
  - All features must have a feature flag

phase_overrides:
  initial_interview:
    instructions_append: |
      Always ask about:
      1. Which bounded context does this belong to?
      2. What events will this feature emit?
      3. Should this be behind a feature flag?

  spec_creation:
    instructions_prepend: |
      REQUIRED in every spec:
      - Bounded context classification
      - Event definitions (name, payload, schema)
      - Feature flag configuration
```

## Example: Customizing hyper-implement

```yaml
# .hyper/settings/commands/hyper-implement.yaml

context_additions: |
  - Run tests in watch mode during development
  - Use conventional commit messages
  - Create a draft PR early for visibility

phase_overrides:
  implementation:
    instructions_append: |
      After implementing:
      1. Run `npm test -- --watch` to verify
      2. Create draft PR with `gh pr create --draft`
      3. Update task with PR link

quality_gates:
  test:
    command: "npm run test:coverage"
    required: true
    threshold:
      coverage: 80

  bundle_size:
    name: "Bundle Size Check"
    command: "npm run build && npm run analyze"
    required: false  # Warning only
```

## Example: Customizing hyper-verify

```yaml
# .hyper/settings/commands/hyper-verify.yaml

context_additions: |
  - E2E tests require Docker to be running
  - Visual regression tests use Percy

quality_gates:
  e2e:
    command: "docker-compose up -d && npm run e2e"
    required: true
    timeout_seconds: 600

  visual_regression:
    name: "Visual Regression"
    command: "npm run test:visual"
    required: false

skip_phases:
  - browser_verification  # We use visual regression instead
```

## Tips

1. **Start minimal**: Only add customizations you actually need
2. **Test changes**: Run a command after customizing to verify behavior
3. **Version control**: Commit your settings/ directory to share with team
4. **Reset to defaults**: Delete a file to reset that command to defaults
5. **Use variables**: Commands support `{{PROJECT_SLUG}}`, `{{TASK_ID}}`, `{{DATE}}` variables
