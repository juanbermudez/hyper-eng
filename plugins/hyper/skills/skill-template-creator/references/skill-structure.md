# Skill Structure Reference

Required file structure for HyperCraft skills.

## Directory Layout

### Minimal Skill

```
skills/{skill-name}/
└── SKILL.md              # Main skill file (required)
```

### Full Skill

```
skills/{skill-name}/
├── SKILL.md              # Main skill file (required)
├── references/           # Supporting documentation (optional)
│   ├── quick-reference.md
│   ├── detailed-guide.md
│   └── api-reference.md
├── assets/               # Static files (optional)
│   └── diagram.png
└── scripts/              # Helper scripts (optional)
    └── setup.sh
```

## SKILL.md Structure

### Required Sections

```markdown
---
name: skill-name
description: This skill...
---

# Skill Name

## Overview
[What this skill does - 2-3 paragraphs]

## Quick Reference
[Most common operations - table or code blocks]

## [Main Content Sections]
[Detailed guidance organized by topic]

## References
[Links to reference docs in ./references/]
```

### Optional Sections

- **When to Use** - Clear activation triggers
- **Workflow** - Step-by-step processes
- **Best Practices** - Do's and don'ts
- **Error Handling** - Common issues and solutions
- **Examples** - Usage examples

## Reference Linking

Always link reference files using relative markdown links:

```markdown
## References

- [quick-reference.md](./references/quick-reference.md) - Description
- [detailed-guide.md](./references/detailed-guide.md) - Description
```

**Never use backticks** for file references:
- WRONG: `references/quick-reference.md`
- RIGHT: [quick-reference.md](./references/quick-reference.md)

## Naming Conventions

| Item | Convention | Example |
|------|------------|---------|
| Skill directory | lowercase-with-hyphens | `code-search` |
| SKILL.md | Uppercase | `SKILL.md` |
| Reference files | lowercase-with-hyphens | `api-reference.md` |
| Assets | lowercase | `diagram.png` |
| Scripts | lowercase | `setup.sh` |

## Content Guidelines

### Writing Style

- Use imperative/infinitive form
- Avoid second person ("you should...")
- Be concise but complete
- Include code examples

### Code Blocks

- Always specify language
- Use realistic examples
- Include comments for complex code

```typescript
// Good: Realistic example with language
const result = await skill.execute({
  query: "search pattern",
  options: { limit: 10 }
});
```

### Tables

- Use for structured comparisons
- Include header row
- Keep content brief

| Option | Default | Description |
|--------|---------|-------------|
| `limit` | 10 | Maximum results |
| `timeout` | 5000 | Timeout in ms |
