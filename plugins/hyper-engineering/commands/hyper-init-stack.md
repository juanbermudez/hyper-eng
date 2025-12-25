# /hyper-init-stack - Initialize Stack Template

Initialize a stack template for the current project, configuring hyper-engineering with stack-specific verification commands and patterns.

## Command

```
/hyper-init-stack [stack-name]
```

## Arguments

- `stack-name` (optional): The stack to initialize. Available stacks:
  - `node-typescript` - Node.js/TypeScript (React, Next.js, Express)
  - `python` - Python (FastAPI, Django, Flask)
  - `go` - Go backend services
  - Custom stack name from `templates/stacks/` directory

If no stack name provided, the command will:
1. Detect the stack automatically based on project files
2. Prompt the user to confirm or choose a different stack

## What This Command Does

1. **Detects or confirms stack type**
2. **Copies stack template** to `.claude/stacks/` in the project
3. **Prompts for customization** of verification commands
4. **Updates CLAUDE.md** with stack-specific patterns and reviewer guidelines
5. **Validates verification commands** to ensure they work in the project

## Usage Examples

### Initialize with explicit stack

```bash
claude /hyper-init-stack node-typescript
```

### Auto-detect stack

```bash
claude /hyper-init-stack
```

This will:
- Detect `package.json` → suggest `node-typescript`
- Detect `pyproject.toml` or `requirements.txt` → suggest `python`
- Detect `go.mod` → suggest `go`
- Show available stacks if detection fails

### Initialize custom stack

```bash
claude /hyper-init-stack my-custom-stack
```

This looks for `templates/stacks/my-custom-stack/stack-config.md`

## Stack Detection Logic

The command uses this detection order:

```yaml
detection_rules:
  node-typescript:
    indicators:
      - package.json
      - tsconfig.json
      - package-lock.json
      - pnpm-lock.yaml
      - yarn.lock

  python:
    indicators:
      - pyproject.toml
      - requirements.txt
      - Pipfile
      - setup.py
      - poetry.lock

  go:
    indicators:
      - go.mod
      - go.sum
```

## Interactive Customization

After selecting a stack, the command prompts for customization:

### Step 1: Verify Detection

```
Detected stack: node-typescript
Project type: Next.js application (found next.config.js)
Package manager: pnpm (found pnpm-lock.yaml)

Is this correct? (y/n)
```

### Step 2: Customize Verification Commands

```
Verification Commands
━━━━━━━━━━━━━━━━━━━━━━━

Lint Command
Default: pnpm lint
Custom:  [press Enter to use default, or type custom command]

Typecheck Command
Default: pnpm typecheck
Custom:  [press Enter to use default, or type custom command]

Test Command
Default: pnpm test
Custom:  [press Enter to use default, or type custom command]

Build Command
Default: pnpm build
Custom:  [press Enter to use default, or type custom command]
```

### Step 3: Test Commands

```
Testing verification commands...

✓ pnpm lint - passed
✓ pnpm typecheck - passed
✓ pnpm test - passed
✓ pnpm build - passed

All verification commands validated successfully!
```

### Step 4: Summary

```
Stack Initialization Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Created files:
  .claude/stacks/stack-config.md
  .claude/stacks/README.md

Updated files:
  .claude/CLAUDE.md

Verification commands configured:
  Lint:      pnpm lint
  Typecheck: pnpm typecheck
  Test:      pnpm test
  Build:     pnpm build

Next steps:
  1. Review .claude/stacks/stack-config.md
  2. Customize patterns if needed
  3. Run: claude /hyper-verify to test verification workflow
```

## Files Created

### .claude/stacks/stack-config.md

Contains the complete stack configuration with:
- Verification commands (customized)
- Common patterns for the stack
- Stack-specific reviewer guidelines
- Project structure examples

### .claude/stacks/README.md

Project-specific documentation:
```markdown
# Stack Configuration

This project uses: node-typescript

## Verification Commands

Run all verification:
\`\`\`bash
pnpm lint && pnpm typecheck && pnpm test && pnpm build
\`\`\`

Individual commands:
- Lint: \`pnpm lint\`
- Typecheck: \`pnpm typecheck\`
- Test: \`pnpm test\`
- Build: \`pnpm build\`

## Project-Specific Patterns

[Document any patterns unique to this project]
```

## Updates to CLAUDE.md

The command appends stack-specific content to `.claude/CLAUDE.md`:

```markdown
## Stack Configuration

This project uses: **node-typescript**

### Verification Commands

Before committing, ensure all checks pass:

\`\`\`bash
pnpm lint        # Linting
pnpm typecheck   # Type checking
pnpm test        # Tests
pnpm build       # Build
\`\`\`

### Stack-Specific Patterns

[Includes relevant patterns from stack-config.md]

### Code Review Checklist

[Includes stack-specific reviewer guidelines]
```

## Implementation Guide

When implementing this command:

### 1. Stack Detection

```typescript
async function detectStack(): Promise<string | null> {
  // Check for Node/TypeScript
  if (await fileExists('package.json')) {
    if (await fileExists('tsconfig.json')) {
      return 'node-typescript';
    }
  }

  // Check for Python
  if (await fileExists('pyproject.toml') ||
      await fileExists('requirements.txt')) {
    return 'python';
  }

  // Check for Go
  if (await fileExists('go.mod')) {
    return 'go';
  }

  return null;
}
```

### 2. Copy Stack Template

```typescript
async function copyStackTemplate(stackName: string) {
  const templatePath = `templates/stacks/${stackName}/stack-config.md`;
  const targetPath = `.claude/stacks/stack-config.md`;

  await copyFile(templatePath, targetPath);
}
```

### 3. Customize Commands

```typescript
async function customizeCommands(config: StackConfig): Promise<StackConfig> {
  // Read current package.json scripts
  const packageJson = await readJSON('package.json');
  const scripts = packageJson.scripts || {};

  // Suggest commands based on available scripts
  const suggestions = {
    lint: scripts.lint || config.verification.lint.primary,
    typecheck: scripts.typecheck || config.verification.typecheck.primary,
    test: scripts.test || config.verification.test.primary,
    build: scripts.build || config.verification.build.primary,
  };

  // Prompt user for each command
  // ...

  return updatedConfig;
}
```

### 4. Validate Commands

```typescript
async function validateCommands(commands: Commands): Promise<ValidationResult> {
  const results = {
    lint: await runCommand(commands.lint),
    typecheck: await runCommand(commands.typecheck),
    test: await runCommand(commands.test),
    build: await runCommand(commands.build),
  };

  return results;
}
```

### 5. Update CLAUDE.md

```typescript
async function updateClaudeMd(stackName: string, config: StackConfig) {
  const claudeMdPath = '.claude/CLAUDE.md';
  let content = await readFile(claudeMdPath);

  // Remove existing stack configuration section if present
  content = removeSection(content, '## Stack Configuration');

  // Append new stack configuration
  const stackSection = generateStackSection(stackName, config);
  content += '\n\n' + stackSection;

  await writeFile(claudeMdPath, content);
}
```

## Error Handling

### Stack Not Found

```
Error: Stack 'my-stack' not found

Available stacks:
  - node-typescript
  - python
  - go
  - _template (for creating custom stacks)

To create a custom stack:
  1. Copy templates/stacks/_template/ to templates/stacks/my-stack/
  2. Edit stack-config.md with your configuration
  3. Run: claude /hyper-init-stack my-stack
```

### Verification Command Failed

```
Warning: Verification command failed

Command: pnpm test
Error: Command not found

This command will be saved but may need adjustment.
You can edit .claude/stacks/stack-config.md to fix it.
```

### No .claude Directory

```
Creating .claude directory structure...

Created:
  .claude/
  .claude/stacks/

Run the command again to initialize stack.
```

## Re-initialization

If stack is already initialized:

```
Stack already initialized: node-typescript

Options:
  1. Reconfigure (update verification commands)
  2. Switch stack (change to different stack)
  3. Cancel

Choice: [1/2/3]
```

## Integration with Hyper-Engineering Workflow

After initialization, the stack configuration is used by:

1. **/hyper-verify** - Runs verification commands from stack config
2. **/hyper-review** - Uses stack-specific reviewer guidelines
3. **engineering-agent** - References patterns when implementing
4. **review-orchestrator** - Includes stack-specific reviewer sub-agent

## Advanced Usage

### Multiple Stacks (Monorepo)

For projects with multiple stacks:

```bash
# Initialize different stacks for different directories
cd packages/frontend
claude /hyper-init-stack node-typescript

cd ../backend
claude /hyper-init-stack go
```

Each directory gets its own `.claude/stacks/` configuration.

### Custom Verification Scripts

Create custom verification in `package.json`:

```json
{
  "scripts": {
    "verify": "pnpm lint && pnpm typecheck && pnpm test && pnpm build",
    "verify:quick": "pnpm lint && pnpm typecheck"
  }
}
```

Then use in stack config:

```yaml
verification:
  full:
    command: "pnpm verify"
  quick:
    command: "pnpm verify:quick"
```

## See Also

- `/hyper-verify` - Run verification workflow
- `/hyper-review` - Run code review with stack-specific checks
- `/hyper-setup` - Initial hyper-engineering setup
