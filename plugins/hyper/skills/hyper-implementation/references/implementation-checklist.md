# Implementation Checklist

## Before Writing Code

- [ ] Read task file completely
- [ ] Read project spec for context
- [ ] Read all files mentioned in task
- [ ] Read related files (imports, tests, similar features)
- [ ] Understand existing patterns
- [ ] Identify verification commands from spec

## During Implementation

### Follow Patterns

1. **File Organization**
   - Place new files in appropriate directories
   - Follow existing naming conventions
   - Match import/export patterns

2. **Code Style**
   - Match existing code style
   - Use same error handling patterns
   - Follow typing conventions

3. **Tests**
   - Add tests for new functionality
   - Follow existing test patterns
   - Include edge cases

### Implementation Order

1. **Types First**
   - Add type definitions
   - Export from appropriate modules

2. **Core Logic**
   - Implement business logic
   - Handle error cases
   - Add validation

3. **Integration**
   - Wire up components
   - Add to exports
   - Update configurations

4. **Tests**
   - Unit tests
   - Integration tests (if applicable)

## Code Quality Guidelines

### Do

- Use descriptive variable names
- Add comments for complex logic
- Handle edge cases explicitly
- Follow single responsibility principle
- Keep functions focused and small

### Don't

- Leave TODO comments without context
- Skip error handling
- Hardcode values that should be configurable
- Ignore TypeScript errors
- Skip tests for new code

## File Modification Pattern

For each file to modify:

1. **Read Current State**
   ```bash
   cat "path/to/file.ts"
   ```

2. **Identify Change Location**
   - Find specific lines to modify
   - Note surrounding context

3. **Make Minimal Changes**
   - Only change what's necessary
   - Preserve existing patterns

4. **Verify Syntax**
   - Run typecheck after changes
   - Ensure imports resolve

## Progress Tracking

Update task file with progress:

```markdown
## Implementation Progress

- [x] Read context and patterns
- [x] Created type definitions
- [x] Implemented core logic
- [ ] Added tests
- [ ] Ran verification

### Notes
- [Any important notes or decisions]
```

## Common Pitfalls

| Pitfall | Prevention |
|---------|------------|
| Breaking existing tests | Run tests before and after |
| Type errors | Run typecheck frequently |
| Missing imports | Check import chains |
| Lint errors | Run lint before commit |
| Forgetting edge cases | Review spec acceptance criteria |

## When Stuck

If implementation is difficult:

1. **Check research docs** for patterns
2. **Look at similar implementations** in codebase
3. **Break into smaller steps**
4. **Ask user** for clarification

Don't spend more than 15 minutes stuck without escalating.
