#!/bin/bash
# hyper-init-check.sh
# Runs at session startup to check if the workspace data root exists and is properly structured
# Also detects existing steering docs and task tracking systems that may need migration

# Only run if we're in a project directory (not home, not system paths)
if [[ "$PWD" == "$HOME" ]] || [[ "$PWD" == "/" ]]; then
    exit 0
fi

resolve_workspace_root() {
    if [[ -n "$HYPER_WORKSPACE_ROOT" ]]; then
        echo "$HYPER_WORKSPACE_ROOT"
        return
    fi

    local hyper_bin
    hyper_bin="$(resolve_hyper_bin)"
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

resolve_hyper_bin() {
    local hyper_bin="${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft"
    if [[ -x "$hyper_bin" ]]; then
        echo "$hyper_bin"
        return
    fi

    hyper_bin="${CLAUDE_PLUGIN_ROOT}/binaries/hyper"
    if [[ -x "$hyper_bin" ]]; then
        echo "$hyper_bin"
        return
    fi

    echo "hypercraft"
}

# ============================================================
# PRIOR SYSTEM DETECTION (lightweight version for session start)
# ============================================================

detect_prior_systems() {
    local warnings=()

    # Check for existing CLAUDE.md without Hyper integration
    if [[ -f "CLAUDE.md" ]]; then
        if ! grep -qE '(Hyper Engineering|/hyper:|HYPER_WORKSPACE_ROOT)' CLAUDE.md 2>/dev/null; then
            # Check if it has workflow/task tracking content
            if grep -qiE '(workflow|## tasks|task tracking|linear|jira|github issues)' CLAUDE.md 2>/dev/null; then
                warnings+=("Found CLAUDE.md with existing workflow configuration. Run /hyper:init for guided migration.")
            fi
        fi
    fi

    # Check for common task tracking files
    local task_files=""
    for f in TODO.md TASKS.md ROADMAP.md BACKLOG.md; do
        if [[ -f "$f" ]]; then
            task_files="$task_files $f"
        fi
    done
    if [[ -n "$task_files" ]]; then
        warnings+=("Found task files:$task_files. Run /hyper:import-external to import them.")
    fi

    # Check for legacy local .hyper directory that needs migration
    if [[ -d ".hyper" ]]; then
        local global_configured=false
        local hyper_bin
        hyper_bin="$(resolve_hyper_bin)"
        if [[ -x "$hyper_bin" ]]; then
            local resolved
            resolved=$("$hyper_bin" config get globalPath 2>/dev/null || true)
            if [[ -n "$resolved" && "$resolved" != "null" && -d "$resolved" ]]; then
                global_configured=true
            fi
        fi
        if [[ "$global_configured" == "true" ]]; then
            warnings+=("Found legacy local .hyper/ directory. Run /hyper:init to migrate to HyperHome.")
        fi
    fi

    # Return warnings as newline-separated string
    printf '%s\n' "${warnings[@]}"
}

# ============================================================
# MAIN WORKSPACE CHECK
# ============================================================

WORKSPACE_ROOT="$(resolve_workspace_root)"
WORKSPACE_ROOT="${WORKSPACE_ROOT%/}"

# Collect additional context messages
ADDITIONAL_CONTEXT=""

# First, check for prior systems (always check, even if workspace exists)
PRIOR_WARNINGS=$(detect_prior_systems)
if [[ -n "$PRIOR_WARNINGS" ]]; then
    # Format warnings for output
    while IFS= read -r warning; do
        if [[ -n "$warning" ]]; then
            if [[ -n "$ADDITIONAL_CONTEXT" ]]; then
                ADDITIONAL_CONTEXT="$ADDITIONAL_CONTEXT | $warning"
            else
                ADDITIONAL_CONTEXT="$warning"
            fi
        fi
    done <<< "$PRIOR_WARNINGS"
fi

# Check if workspace root exists
if [[ -z "$WORKSPACE_ROOT" ]] || [[ ! -d "$WORKSPACE_ROOT" ]]; then
    if [[ -n "$ADDITIONAL_CONTEXT" ]]; then
        ADDITIONAL_CONTEXT="Note: No workspace data root is registered for this project. Run /hyper:init to create the workspace structure in HyperHome. | $ADDITIONAL_CONTEXT"
    else
        ADDITIONAL_CONTEXT="Note: No workspace data root is registered for this project. Run /hyper:init to create the workspace structure in HyperHome."
    fi

    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$ADDITIONAL_CONTEXT"
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
    if [[ -n "$ADDITIONAL_CONTEXT" ]]; then
        ADDITIONAL_CONTEXT="Warning: Workspace data root is missing:$MISSING. Consider running /hyper:init to repair the structure. | $ADDITIONAL_CONTEXT"
    else
        ADDITIONAL_CONTEXT="Warning: Workspace data root is missing:$MISSING. Consider running /hyper:init to repair the structure."
    fi
fi

# Output any collected context
if [[ -n "$ADDITIONAL_CONTEXT" ]]; then
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$ADDITIONAL_CONTEXT"
  }
}
EOF
fi

exit 0
