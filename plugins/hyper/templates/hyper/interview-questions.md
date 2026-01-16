# Interview Questions Template

## Initial Interview Phase

Use AskUserQuestion for each question. Don't batch questions.

### Open-Ended Exploration (1-2 questions)

1. "Can you walk me through what you're trying to achieve and why this is important now?"
2. "What does success look like for this feature from the user's perspective?"

### Scope & Boundaries (2-3 questions)

1. "What should definitely be included in v1? What can wait for later?"
2. "Are there any edge cases or scenarios you want me to explicitly NOT handle?"
3. "What are the hard constraints? (security, accessibility, browser support)"

### Technical Direction (2-3 questions)

1. "Do you have preferences on how this should be built? Any patterns or libraries to use or avoid?"
2. "Are there existing parts of the codebase this should integrate with or mimic?"
3. "Does this depend on or affect any other features or systems?"

### User Context (1-2 questions)

1. "Who will use this? What's their typical workflow?"
2. "How frequently will this be used? Any performance expectations?"

### Confirmation (1 question)

"Let me make sure I understand: [summary]. Does that capture your intent correctly?"

## Post-Research Interview Phase

After reading all research documents, clarify decision points.

### Present Options from Research

"The research found two common approaches for [X]:

Option A: [Approach] - Pros: [pros], Cons: [cons]
Option B: [Approach] - Pros: [pros], Cons: [cons]

Given your goals, which direction feels right?"

### Flag Risks or Concerns

"I noticed something in the research I want to flag:
[Concern or risk discovered]

How would you like me to handle this?"

### Validate Assumptions

"Based on the research, I'm planning to [assumption].
Is that correct, or should I approach it differently?"

### Fill Knowledge Gaps

"The research couldn't determine [specific thing].
Can you clarify how [X] currently works or what you'd expect?"

## Interview Principles

1. **Use AskUserQuestion for EVERY question** - Don't batch
2. **Listen and follow up** - Each answer may surface new questions
3. **Don't assume** - If uncertain, ask
4. **Complex features may need 10+ questions**
5. **Present trade-offs** - Let user decide direction

## Example Flow

```
AskUserQuestion: "Can you walk me through what you're trying to achieve?"
[User explains OAuth login]

AskUserQuestion: "Which providers are must-haves? Google, GitHub, others?"
[User says Google and GitHub]

AskUserQuestion: "Should users also be able to sign up with email/password?"
[User says OAuth only for v1]

AskUserQuestion: "Where should users land after login? New vs returning users?"
[User explains flow]

AskUserQuestion: "Any specific security requirements? Token expiration?"
[User mentions 7-day sessions]

AskUserQuestion: "Let me confirm: OAuth-only (Google + GitHub), 7-day sessions, new users to onboarding. Sound right?"
[User confirms]
```
