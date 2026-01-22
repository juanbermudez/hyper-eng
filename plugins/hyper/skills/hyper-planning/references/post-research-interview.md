# Post-Research Interview

## Step 1: Read Research Documents

Read ALL research documents in full - do not skim:

```bash
cat "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/codebase-analysis.md"
cat "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/best-practices.md"
cat "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/framework-docs.md"
cat "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/git-history.md"
cat "$HYPER_WORKSPACE_ROOT/projects/${PROJECT_SLUG}/resources/research-summary.md"
```

## Step 2: Identify Decision Points

As you read, identify:

- **Architectural decisions** needing user input (e.g., "Research shows 3 valid approaches to X")
- **Trade-offs** depending on user priorities (e.g., "Simpler approach vs more flexible")
- **Risks or concerns** discovered (e.g., "This pattern has known issues with Y")
- **Gaps in understanding** (e.g., "Research couldn't determine how Z currently works")
- **Conflicts with requirements** (e.g., "User wanted X but research suggests Y is better")

## Step 3: Follow-Up Interview

Use AskUserQuestion to clarify decision points:

### Pattern 1: Present Options from Research

```
AskUserQuestion: "The research found two common approaches for [X]:

Option A: [Approach] - Pros: [pros], Cons: [cons]
Option B: [Approach] - Pros: [pros], Cons: [cons]

Given your goals, which direction feels right? Or would you like more detail on either?"
```

### Pattern 2: Flag Risks or Concerns

```
AskUserQuestion: "I noticed something in the research I want to flag:
[Concern or risk discovered]

How would you like me to handle this? Should we:
1. [Option 1]
2. [Option 2]
3. Accept the risk and proceed"
```

### Pattern 3: Validate Assumptions

```
AskUserQuestion: "Based on the research, I'm planning to [assumption].
Is that correct, or should I approach it differently?"
```

### Pattern 4: Fill Knowledge Gaps

```
AskUserQuestion: "The research couldn't determine [specific thing].
Can you clarify how [X] currently works or what you'd expect?"
```

## Principles for Post-Research Interview

- Focus on the 2-4 most important decision points
- Present research findings as context for questions
- Be specific about trade-offs and their implications
- If research confirmed everything clearly, you may only need 1-2 questions
- Use this phase to resolve remaining ambiguity BEFORE spec creation

## Example Post-Research Interview

```
[After reading research on OAuth implementation]

AskUserQuestion: "Research found that NextAuth.js supports two session strategies:
- JWT (stateless): Simpler, but tokens can't be revoked until expiry
- Database sessions: More control, can revoke anytime, but requires session table

Given you mentioned 7-day sessions, which matters more: simplicity or ability to force logout?"
[User chooses database sessions]

AskUserQuestion: "The codebase analysis shows you're using Prisma. Should I add the session table to your existing schema, or would you prefer a separate auth database?"
[User says existing schema]

AskUserQuestion: "One more thing - research flagged that your current User model doesn't have an 'emailVerified' field that NextAuth expects. Should I add it, or handle this differently?"
[User confirms to add it]
```

## Do NOT Proceed Until

- All significant architectural decisions are made
- Risks have been acknowledged or mitigated
- Knowledge gaps are filled
- User has confirmed direction based on research findings
