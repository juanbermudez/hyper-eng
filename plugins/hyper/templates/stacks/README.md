# Stack Templates

This directory contains stack-specific configurations for hyper-engineering. Each stack template provides:

- Verification commands (lint, typecheck, test, build)
- Common code patterns
- Stack-specific review criteria
- Project structure conventions

## Available Stacks

### node-typescript
**Node.js/TypeScript web stack (React, Next.js, Express)**

- Verification: pnpm/npm lint, typecheck, test, build
- Patterns: React components, Next.js App Router, Express middleware
- Review focus: React hooks, TypeScript strict mode, bundle size

[View template →](./node-typescript/stack-config.md)

### python
**Python web stack (FastAPI, Django, Flask)**

- Verification: ruff, mypy, pytest
- Patterns: FastAPI routes, Django models, async/await, Pydantic
- Review focus: Type hints, async correctness, ORM efficiency

[View template →](./python/stack-config.md)

### go
**Go backend services**

- Verification: golangci-lint, go test, go build
- Patterns: Interfaces, error handling, context propagation, struct embedding
- Review focus: Error wrapping, goroutine safety, interface design

[View template →](./go/stack-config.md)

### _template
**Generic template for custom stacks**

Use this as a starting point to create your own stack configuration.

[View template →](./_template/stack-config.md)

## Using Stack Templates

### Initialize for Your Project

```bash
# Auto-detect stack
claude /hyper:init-stack

# Specific stack
claude /hyper:init-stack node-typescript
```

This will:
1. Copy the template to your project's `.claude/stacks/` directory
2. Prompt you to customize verification commands
3. Test that commands work in your project
4. Update `.claude/CLAUDE.md` with stack-specific patterns

### Create a Custom Stack

1. Copy the `_template` directory:
   ```bash
   cp -r _template my-stack-name
   ```

2. Edit `my-stack-name/stack-config.md`:
   - Update frontmatter (name, description)
   - Fill in verification commands
   - Document common patterns
   - Add review criteria

3. Initialize in your project:
   ```bash
   claude /hyper:init-stack my-stack-name
   ```

## Stack Template Structure

Each stack template contains:

### stack-config.md

```yaml
---
name: stack-name
description: Brief description
---

# Stack Configuration

## Verification Commands
- Primary and fallback commands
- Optional verification steps

## Common Patterns
- Code examples showing best practices
- Framework/library-specific patterns

## Stack-Specific Reviewer Additions
- Quality checks
- Best practices
- Performance guidelines
- Security validation

## Common Project Structures
- Directory layouts
- File organization

## Environment Variables
- Required configuration
- Example files

## Initialization Checklist
- Setup steps for new projects
```

## How Templates Are Used

### During Planning (`/hyper:plan`)
- **planning-agent** references patterns when creating specs
- Suggests appropriate architecture for the stack
- Includes stack-specific diagrams in specs

### During Implementation (`/hyper:implement`)
- **engineering-agent** follows patterns from stack config
- Uses verification commands to validate work
- Implements code matching stack conventions

### During Review (`/hyper:review`)
- **review-orchestrator** loads stack-specific reviewer sub-agent
- Checks code against stack-specific criteria
- Validates patterns and best practices

### During Verification (`/hyper:verify`)
- Runs verification commands from stack config
- Checks automated and manual criteria
- Ensures all stack-specific requirements met

## Adding Stack-Specific Patterns to Your Project

After initialization, you can add project-specific patterns:

1. Edit `.claude/stacks/stack-config.md`
2. Add patterns under "Project-Specific Patterns"
3. Document in `.claude/stacks/README.md`

Example:

```markdown
## Project-Specific Patterns

### Our API Response Format

All API responses follow this structure:

\`\`\`typescript
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
  };
  meta?: {
    timestamp: string;
    requestId: string;
  };
}
\`\`\`

### Our Database Transaction Pattern

\`\`\`python
async with db.transaction():
    # All database operations here
    # Automatically rolled back on error
\`\`\`
```

## Contributing Stack Templates

To contribute a new stack template to hyper-engineering:

1. Create the stack directory under `templates/stacks/`
2. Fill out `stack-config.md` completely
3. Test with a real project
4. Document common patterns thoroughly
5. Include comprehensive review criteria
6. Submit PR with example project

### Template Quality Checklist

- [ ] Frontmatter complete (name, description)
- [ ] Verification commands tested
- [ ] At least 3 common patterns documented
- [ ] Stack-specific review criteria defined
- [ ] Project structure examples provided
- [ ] Environment variable template included
- [ ] Initialization checklist complete
- [ ] All code examples are syntactically correct
- [ ] Examples follow stack's official style guide

## Stack Detection

The `/hyper:init-stack` command auto-detects stacks based on these files:

| Stack | Detection Files |
|-------|----------------|
| node-typescript | package.json, tsconfig.json |
| python | pyproject.toml, requirements.txt, Pipfile |
| go | go.mod, go.sum |

Custom stacks must be specified explicitly.

## Maintenance

### Updating Stack Templates

When updating a stack template:

1. Update the template in `templates/stacks/[stack-name]/`
2. Version the change in plugin CHANGELOG.md
3. Users can update their local config by:
   - Re-running `/hyper:init-stack [stack-name]`
   - Choosing "Reconfigure" when prompted

### Deprecating a Stack

To deprecate a stack:

1. Add deprecation notice to stack-config.md
2. Suggest migration path to alternative stack
3. Keep template available for existing users
4. Remove from auto-detection

## Philosophy

Stack templates embody the hyper-engineering principle:

**Codify what works, automate verification, compound knowledge.**

By documenting patterns and verification commands:
- New team members learn faster
- Reviews are more consistent
- Quality standards are enforced
- Knowledge compounds over time

Each template is a living document that should grow with your team's learnings.
