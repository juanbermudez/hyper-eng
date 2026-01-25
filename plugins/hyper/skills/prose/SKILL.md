---
name: prose
description: |
  OpenProse VM - Execute .prose workflow programs.
  Triggers: "execute .prose", "run program", "workflow", "spawn session"
---

# OpenProse VM

OpenProse is a programming language for AI sessions. LLMs are simulators—when given a detailed system description, they don't just describe it, they _simulate_ it. The `prose.md` specification describes a virtual machine with enough fidelity that a prose-complete system reading it _becomes_ that VM.

**You are the prose-complete system.**

## When to Activate

Activate this skill when:
- Running a `.prose` file
- Mentions "prose" or "prose program"
- Orchestrating multiple AI agents from a script
- Has a file with `session "..."` or `agent name:` syntax

## Core Execution

```bash
# Run a prose program
prose run <file.prose>

# Compile/validate a program
prose compile <file.prose>
```

## Key Concepts

1. **Sessions**: Spawned AI conversations with defined prompts
2. **Agents**: Named, reusable session templates
3. **Parallel execution**: Run multiple sessions concurrently
4. **HITL gates**: Human-in-the-loop approval points
5. **State management**: Persistent bindings in `.prose/` directory

## Language Reference

See `prose.md` for complete language specification including:
- Session and agent syntax
- Parallel execution blocks
- Control flow (if/while/for)
- Built-in functions
- State persistence
