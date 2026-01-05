---
description: Opt out of the hyper-statusline setup prompt
---

# Opt Out of Statusline Prompt

The user wants to opt out of seeing the hyper-statusline setup prompt on session start.

## Action

Create the opt-out marker file:

```bash
mkdir -p ~/.claude
touch ~/.claude/.hyper-statusline-optout
```

## Response

After creating the file, inform the user:

---

**Statusline prompt disabled.**

You won't see the statusline setup prompt on future sessions.

If you change your mind later, you can:
- Run `/hyper-statusline:setup` to install the statusline
- Delete `~/.claude/.hyper-statusline-optout` to re-enable the prompt

---
