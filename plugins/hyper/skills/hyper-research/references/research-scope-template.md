# Research Scope Template

Define the research scope before spawning sub-agents.

## Scope Definition

```yaml
feature: "[Feature name/description]"
project_slug: "[kebab-case-slug]"

frameworks:
  - "[Framework 1]"
  - "[Framework 2]"

focus_areas:
  - "[Focus 1]"
  - "[Focus 2]"

related_files:
  - "src/path/related/*.ts"
  - "src/components/related/"

exclude:
  - "node_modules/"
  - "dist/"
  - "*.test.ts"  # Unless testing focus

questions_to_answer:
  - "How is [similar feature] implemented?"
  - "What's the best approach for [specific concern]?"
  - "Are there security considerations for [area]?"
```

## Scope Elements

### Feature Description

Clear description of what we're researching:
- What problem does it solve?
- What are the expected outcomes?
- What are the technical boundaries?

### Framework Focus

List frameworks/libraries to research:
- Primary framework (e.g., Next.js, React)
- Supporting libraries (e.g., Prisma, NextAuth)
- Testing frameworks (e.g., Jest, Playwright)

### Focus Areas

Specific aspects to research:
- Security implications
- Performance considerations
- Accessibility requirements
- Integration patterns
- Error handling

### Related Files

Codebase areas to analyze:
- Similar feature implementations
- Shared utilities and hooks
- Type definitions
- Test files for patterns

### Exclusions

What to skip:
- Third-party dependencies (node_modules)
- Build artifacts (dist, .next)
- Test files (unless testing is the focus)
- Generated code

### Questions to Answer

Specific questions the research should answer:
- "How do we handle authentication in this codebase?"
- "What's the error boundary pattern?"
- "How are API routes structured?"

## Example Scope

```yaml
feature: "User authentication with OAuth"
project_slug: "user-auth-oauth"

frameworks:
  - "Next.js 15"
  - "NextAuth.js v5"
  - "Prisma"

focus_areas:
  - "Session management (JWT vs database)"
  - "OAuth provider integration"
  - "Protected route patterns"
  - "User model schema"

related_files:
  - "src/app/api/auth/**"
  - "src/lib/auth.ts"
  - "src/middleware.ts"
  - "prisma/schema.prisma"

exclude:
  - "node_modules/"
  - ".next/"

questions_to_answer:
  - "How are other protected routes implemented?"
  - "What session strategy is used elsewhere?"
  - "How is the User model currently structured?"
  - "Are there existing auth utilities to reuse?"
```
