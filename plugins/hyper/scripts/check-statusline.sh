#!/bin/bash
# Check if hyper-statusline is configured
# Called by PostSessionStart hook on first use

SETTINGS_FILE="$HOME/.claude/settings.json"
OPT_OUT_FILE="$HOME/.claude/.hyper-statusline-optout"

# If user opted out, exit silently
if [ -f "$OPT_OUT_FILE" ]; then
    exit 0
fi

# Check if statusline is already configured
if [ -f "$SETTINGS_FILE" ]; then
    if grep -q '"statusLine"' "$SETTINGS_FILE" 2>/dev/null; then
        # Already configured, exit silently
        exit 0
    fi
fi

# Not configured and not opted out - show prompt
cat << 'EOF'

┌─────────────────────────────────────────────────────────────────┐
│  Hyper-Engineering Statusline Available                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  A Dracula-themed statusline with visual context bar is         │
│  included with this plugin.                                     │
│                                                                 │
│  Preview:                                                       │
│  ◆ Opus │  project │  main* │ ctx ████████░░ 78% │ +156 -23   │
│                                                                 │
│  • Visual context bar (green → yellow → red)                    │
│  • Model badge with color coding                                │
│  • Git branch with change indicator                             │
│  • Session stats (lines changed, cost)                          │
│                                                                 │
│  To install:  /hyper-statusline:setup                           │
│  To opt out:  /hyper-statusline:optout                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

EOF
