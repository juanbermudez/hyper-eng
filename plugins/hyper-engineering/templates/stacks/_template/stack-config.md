---
name: your-stack-name
description: Brief description of your stack (e.g., "Ruby on Rails web applications")
---

# [Your Stack Name] Configuration Template

This is a generic template for creating custom stack configurations. Copy this file and customize it for your specific technology stack.

## How to Use This Template

1. Copy this entire directory to create your own stack:
   ```bash
   cp -r _template my-stack-name
   ```

2. Edit `stack-config.md` (this file):
   - Update the frontmatter (name, description)
   - Fill in verification commands
   - Document common patterns for your stack
   - Add stack-specific reviewer guidelines

3. Initialize for your project:
   ```bash
   claude /hyper-init-stack my-stack-name
   ```

## Verification Commands

### Automated Checks

```yaml
verification:
  lint:
    primary: "[your lint command]"
    fallback: "[alternative lint command]"
    description: "Run linter/code quality checks"
    fail_on_error: true

  typecheck:
    primary: "[your typecheck command]"
    fallback: "[alternative typecheck command]"
    description: "Run type checking (if applicable)"
    fail_on_error: true

  test:
    primary: "[your test command]"
    fallback: "[alternative test command]"
    description: "Run all tests"
    fail_on_error: true

  build:
    primary: "[your build command]"
    fallback: "[alternative build command]"
    description: "Build/compile the application"
    fail_on_error: true
```

### Optional Checks

```yaml
optional_verification:
  test_coverage:
    command: "[coverage command]"
    description: "Generate test coverage report"
    threshold: "80%"

  security:
    command: "[security scan command]"
    description: "Run security vulnerability checks"

  performance:
    command: "[performance test command]"
    description: "Run performance benchmarks"
```

## Common Patterns

### Pattern Category 1

```[your-language]
// Add code examples showing common patterns in your stack
// For example: API route handlers, database queries, etc.

[code example here]
```

### Pattern Category 2

```[your-language]
// Add more patterns specific to your stack

[code example here]
```

### Pattern Category 3

```[your-language]
// Add additional patterns as needed

[code example here]
```

## Stack-Specific Reviewer Additions

### Code Quality Checks

```markdown
## [Your Stack] Quality Standards

- [ ] [Quality check 1]
- [ ] [Quality check 2]
- [ ] [Quality check 3]
- [ ] [Quality check 4]
```

### Best Practices

```markdown
## [Framework/Library] Best Practices

- [ ] [Best practice 1]
- [ ] [Best practice 2]
- [ ] [Best practice 3]
- [ ] [Best practice 4]
```

### Performance Considerations

```markdown
## Performance Guidelines

- [ ] [Performance check 1]
- [ ] [Performance check 2]
- [ ] [Performance check 3]
```

### Security Checks

```markdown
## Security Validation

- [ ] [Security check 1]
- [ ] [Security check 2]
- [ ] [Security check 3]
```

## Common Project Structures

### Project Layout Example 1

```
your-project/
├── [directory-1]/
│   ├── [file-1]
│   └── [file-2]
├── [directory-2]/
│   ├── [subdirectory]/
│   └── [file-3]
└── [config-file]
```

### Project Layout Example 2

```
alternative-structure/
├── [different-layout]/
└── [different-organization]
```

## Environment Variables

```bash
# .env - Never commit this file
[VARIABLE_1]=[value]
[VARIABLE_2]=[value]

# .env.example - Commit this as template
[VARIABLE_1]=[example-value]
[VARIABLE_2]=[example-value]
```

## Dependency Management

```yaml
# Detection order (first match wins)
dependency_managers:
  - file: "[lockfile-1]"
    manager: "[package-manager-1]"
    install: "[install-command]"

  - file: "[lockfile-2]"
    manager: "[package-manager-2]"
    install: "[install-command]"
```

## Initialization Checklist

When setting up this stack for a project:

- [ ] Detect [language/framework] version
- [ ] Install dependencies
- [ ] Set up development environment
- [ ] Run database migrations (if applicable)
- [ ] Create .env from .env.example
- [ ] Run initial verification
- [ ] Verify all verification commands work
- [ ] Document project-specific patterns in .claude/stacks/README.md

## Additional Resources

- [Link to official documentation]
- [Link to style guide]
- [Link to best practices]
- [Link to community resources]

---

## Notes for Customization

When filling out this template, consider:

1. **Verification Commands**: What commands does your team run to verify code quality?
2. **Common Patterns**: What code patterns are repeated throughout your codebase?
3. **Review Criteria**: What should reviewers check for in your stack?
4. **Project Structure**: How do you organize files and directories?
5. **Environment Setup**: What steps are needed to get started?

Remember: The goal is to codify your team's existing practices, not create new ones. Document what already works.
