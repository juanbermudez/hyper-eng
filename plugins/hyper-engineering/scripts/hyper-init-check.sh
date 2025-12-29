#!/bin/bash
# hyper-init-check.sh
# Runs at session startup to check if .hyper/ exists and is properly structured

# Only run if we're in a project directory (not home, not system paths)
if [[ "$PWD" == "$HOME" ]] || [[ "$PWD" == "/" ]]; then
    exit 0
fi

# Check if .hyper exists
if [[ ! -d ".hyper" ]]; then
    # Output JSON to add context for Claude
    cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Note: This project does not have a .hyper/ directory. If you need to create planning documents, run /hyper-init first to set up the project management structure."
  }
}
EOF
    exit 0
fi

# Verify structure
MISSING=""

if [[ ! -d ".hyper/projects" ]]; then
    MISSING="$MISSING projects/"
fi

if [[ ! -d ".hyper/docs" ]]; then
    MISSING="$MISSING docs/"
fi

if [[ ! -f ".hyper/workspace.json" ]]; then
    MISSING="$MISSING workspace.json"
fi

if [[ -n "$MISSING" ]]; then
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Warning: .hyper/ directory exists but is missing: $MISSING. Consider running /hyper-init to repair the structure."
  }
}
EOF
fi

exit 0
