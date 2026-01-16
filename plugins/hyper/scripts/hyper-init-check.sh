#!/bin/bash
# hyper-init-check.sh
# Runs at session startup to check if the workspace data root exists and is properly structured

# Only run if we're in a project directory (not home, not system paths)
if [[ "$PWD" == "$HOME" ]] || [[ "$PWD" == "/" ]]; then
    exit 0
fi

resolve_workspace_root() {
    if [[ -n "$HYPER_WORKSPACE_ROOT" ]]; then
        echo "$HYPER_WORKSPACE_ROOT"
        return
    fi

    local hyper_bin="${CLAUDE_PLUGIN_ROOT}/binaries/hyper"
    if [[ -x "$hyper_bin" ]]; then
        local resolved
        resolved=$("$hyper_bin" config get globalPath 2>/dev/null || true)
        if [[ -n "$resolved" && "$resolved" != "null" ]]; then
            echo "$resolved"
            return
        fi
    fi

    if [[ -d ".hyper" ]]; then
        echo "$PWD/.hyper"
        return
    fi

    echo ""
}

WORKSPACE_ROOT="$(resolve_workspace_root)"
WORKSPACE_ROOT="${WORKSPACE_ROOT%/}"

if [[ -z "$WORKSPACE_ROOT" ]] || [[ ! -d "$WORKSPACE_ROOT" ]]; then
    cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Note: No workspace data root is registered for this project. Run /hyper-init to create the workspace structure in HyperHome."
  }
}
EOF
    exit 0
fi

# Verify structure
MISSING=""

if [[ ! -d "$WORKSPACE_ROOT/projects" ]]; then
    MISSING="$MISSING projects/"
fi

if [[ ! -d "$WORKSPACE_ROOT/docs" ]]; then
    MISSING="$MISSING docs/"
fi

if [[ ! -f "$WORKSPACE_ROOT/workspace.json" ]]; then
    MISSING="$MISSING workspace.json"
fi

if [[ -n "$MISSING" ]]; then
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Warning: Workspace data root is missing: $MISSING. Consider running /hyper-init to repair the structure."
  }
}
EOF
fi

exit 0
