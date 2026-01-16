# Interview Guide

## Philosophy

This is a **conversation**, not a checklist. Use AskUserQuestion for EVERY question - don't batch. Each answer informs the next question.

## Interview Protocol

### 1. Open-Ended Exploration (1-2 questions)

Start with understanding the big picture:

```
AskUserQuestion: "Can you walk me through what you're trying to achieve and why this is important now?"
```

```
AskUserQuestion: "What does success look like for this feature from the user's perspective?"
```

### 2. Drill Into Specifics (3-5 questions)

Based on their answers, ask targeted follow-ups:

**Scope & Boundaries**:
```
AskUserQuestion: "What should definitely be included in v1? What can wait for later?"
```

```
AskUserQuestion: "Are there any edge cases or scenarios you want me to explicitly NOT handle?"
```

**Technical Direction**:
```
AskUserQuestion: "Do you have preferences on how this should be built? Any patterns or libraries you want to use or avoid?"
```

```
AskUserQuestion: "Are there existing parts of the codebase this should integrate with or mimic?"
```

**User Context**:
```
AskUserQuestion: "Who will use this? What's their typical workflow?"
```

```
AskUserQuestion: "How frequently will this be used? Any performance expectations?"
```

**Constraints & Dependencies**:
```
AskUserQuestion: "Are there any hard constraints I should know about? (security, accessibility, browser support)"
```

```
AskUserQuestion: "Does this depend on or affect any other features or systems?"
```

### 3. Confirm Understanding (1 question)

Summarize what you heard:

```
AskUserQuestion: "Let me make sure I understand: [summary]. Does that capture your intent correctly?"
```

## Interview Principles

- Use AskUserQuestion for EVERY question
- Listen to answers and ask relevant follow-ups
- If something is unclear, probe deeper before moving on
- Don't assume anything - if unsure, ask
- Complex features may require 8-10 questions
- Each answer may surface new questions - follow the thread

## Do NOT Proceed Until You Have

- What exactly is being built (and what's NOT)
- Why it matters (business/user value)
- Any technical preferences or constraints
- How success will be measured

## Example Interview Flow

```
AskUserQuestion: "Can you walk me through what you're trying to achieve with user authentication?"
[User explains they want OAuth login]

AskUserQuestion: "Got it - OAuth login. Which providers are must-haves for launch? Google, GitHub, others?"
[User says Google and GitHub]

AskUserQuestion: "Should users also be able to sign up with email/password, or OAuth only?"
[User says OAuth only for v1]

AskUserQuestion: "Where should users land after successful login? And what happens if they're a new user vs returning?"
[User explains flow]

AskUserQuestion: "Any specific security requirements? Token expiration, session management preferences?"
[User mentions 7-day sessions]

AskUserQuestion: "Let me confirm: OAuth-only auth (Google + GitHub), 7-day sessions, new users go to onboarding, returning users go to dashboard. Sound right?"
[User confirms]
```
