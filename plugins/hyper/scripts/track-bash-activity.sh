#!/bin/bash
# Track activity from Bash commands that use the Hypercraft CLI
# Called by PostToolUse hook after Bash operations
#
# This hook addresses the CLI bypass gap where agents using `hypercraft project create`
# or `hypercraft task create` via Bash don't trigger the Write|Edit PostToolUse hooks.
#
# Design:
# - Parse command for Hypercraft CLI operations (project, task, file, activity)
# - Extract project/task identifiers from arguments
# - Call update-session.sh to create sidecar file with workspace target

set -euo pipefail

# Debug logging
DEBUG_LOG="/tmp/hyper-hook-debug.log"
log_debug() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] track-bash-activity.sh: $*" >> "$DEBUG_LOG"
}

log_debug "triggered"

# Read PostToolUse JSON from stdin
INPUT=$(cat)
log_debug "INPUT: ${INPUT:0:500}..."

# Extract fields using jq
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
PARENT_SESSION=$(echo "$INPUT" | jq -r '.parent_session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
TOOL_RESULT=$(echo "$INPUT" | jq -r '.tool_result // empty')

log_debug "COMMAND: ${COMMAND:0:200}"
log_debug "SESSION_ID: $SESSION_ID"
log_debug "CWD: $CWD"

resolve_hyper_bin() {
  local hyper_bin="${CLAUDE_PLUGIN_ROOT:-}/binaries/hypercraft"
  if [[ -x "$hyper_bin" ]]; then
    echo "$hyper_bin"
    return
  fi

  hyper_bin="${CLAUDE_PLUGIN_ROOT:-}/binaries/hyper"
  if [[ -x "$hyper_bin" ]]; then
    echo "$hyper_bin"
    return
  fi

  echo "hypercraft"
}

# Skip if no session ID
if [[ -z "$SESSION_ID" ]]; then
  log_debug "SKIP: no session ID"
  exit 0
fi

# Skip if command failed (check for error in result)
# We want to track successful operations only
if echo "$TOOL_RESULT" | grep -qi "error\|failed\|not found" 2>/dev/null; then
  log_debug "SKIP: command appears to have failed"
  exit 0
fi

# Extract the first command (before any pipes)
# This handles cases like "hypercraft project create | grep something"
FIRST_CMD=$(echo "$COMMAND" | cut -d'|' -f1 | xargs)

# Check if this is a Hypercraft CLI command
# Match: hypercraft/hyper project|task|file|activity|drive
# Also match: ${CLAUDE_PLUGIN_ROOT}/binaries/hypercraft (full path invocation)
HYPER_PATTERN='(^hypercraft |^hyper |/hypercraft |/hyper )(project|task|file|activity|drive)'
if ! echo "$FIRST_CMD" | grep -qE "$HYPER_PATTERN"; then
  log_debug "SKIP: not a Hypercraft CLI command"
  exit 0
fi

# Skip `hyper activity add` calls - these are already tracking activity
# and we don't want to create a recursive loop
if echo "$FIRST_CMD" | grep -qE '(hypercraft|hyper)\s+activity\s+add'; then
  log_debug "SKIP: Hypercraft activity add (already tracking)"
  exit 0
fi

# Skip read-only commands
if echo "$FIRST_CMD" | grep -qE '(hypercraft|hyper)\s+(project|task|file|drive)\s+(list|get|show|read|search|find)'; then
  log_debug "SKIP: read-only command"
  exit 0
fi

log_debug "Detected Hypercraft CLI command"

# Extract subcommand (project, task, file, activity, drive)
SUBCOMMAND=""
if echo "$FIRST_CMD" | grep -qE '(^hypercraft |^hyper |/hypercraft |/hyper )project'; then
  SUBCOMMAND="project"
elif echo "$FIRST_CMD" | grep -qE '(^hypercraft |^hyper |/hypercraft |/hyper )task'; then
  SUBCOMMAND="task"
elif echo "$FIRST_CMD" | grep -qE '(^hypercraft |^hyper |/hypercraft |/hyper )file'; then
  SUBCOMMAND="file"
elif echo "$FIRST_CMD" | grep -qE '(^hypercraft |^hyper |/hypercraft |/hyper )activity'; then
  SUBCOMMAND="activity"
elif echo "$FIRST_CMD" | grep -qE '(^hypercraft |^hyper |/hypercraft |/hyper )drive'; then
  SUBCOMMAND="drive"
fi

log_debug "Subcommand: $SUBCOMMAND"

# Extract project slug from various argument formats
# --slug <value>, --project <value>, -p <value>, or positional arg after action verb
extract_project_slug() {
  local cmd="$1"
  local slug=""

  # Try --slug
  slug=$(echo "$cmd" | grep -oE '\-\-slug[= ]+"?([^" ]+)"?' | sed -E 's/--slug[= ]+"?([^" ]+)"?/\1/' | head -1)
  if [[ -n "$slug" ]]; then
    echo "$slug"
    return
  fi

  # Try --project
  slug=$(echo "$cmd" | grep -oE '\-\-project[= ]+"?([^" ]+)"?' | sed -E 's/--project[= ]+"?([^" ]+)"?/\1/' | head -1)
  if [[ -n "$slug" ]]; then
    echo "$slug"
    return
  fi

  # Try -p (short form)
  slug=$(echo "$cmd" | grep -oE '\-p[= ]+"?([^" ]+)"?' | sed -E 's/-p[= ]+"?([^" ]+)"?/\1/' | head -1)
  if [[ -n "$slug" ]]; then
    echo "$slug"
    return
  fi

  # For project commands, try positional arg after action verb
  # e.g., "hyper project create my-project" or "hyper project update my-project --status done"
  if echo "$cmd" | grep -qE '(^hypercraft |^hyper |/hypercraft |/hyper )project\s+(create|update)'; then
    slug=$(echo "$cmd" | sed -E 's/.*(^hypercraft |^hyper |\/hypercraft |\/hyper )project (create|update) +"?([^" -][^" ]*)"?.*/\3/' | head -1)
    # Clean up - remove anything that looks like a flag
    if [[ "$slug" != -* && -n "$slug" ]]; then
      echo "$slug"
      return
    fi
  fi

  echo ""
}

# Extract task ID from command
extract_task_id() {
  local cmd="$1"
  local task_id=""

  # Try --task or --id
  task_id=$(echo "$cmd" | grep -oE '\-\-(task|id)[= ]+"?([^" ]+)"?' | sed -E 's/--[a-z]+[= ]+"?([^" ]+)"?/\1/' | head -1)
  if [[ -n "$task_id" ]]; then
    echo "$task_id"
    return
  fi

  # For task commands, try positional arg after action verb
  # e.g., "hyper task update sat-001 --status complete"
  if echo "$cmd" | grep -qE '(^hypercraft |^hyper |/hypercraft |/hyper )task\s+(create|update)'; then
    task_id=$(echo "$cmd" | sed -E 's/.*(^hypercraft |^hyper |\/hypercraft |\/hyper )task (create|update) +"?([^" -][^" ]*)"?.*/\3/' | head -1)
    if [[ "$task_id" != -* && -n "$task_id" ]]; then
      echo "$task_id"
      return
    fi
  fi

  echo ""
}

# Extract file path from command
extract_file_path() {
  local cmd="$1"
  local file_path=""

  # Try --file or --path
  file_path=$(echo "$cmd" | grep -oE '\-\-(file|path)[= ]+"?([^" ]+)"?' | sed -E 's/--[a-z]+[= ]+"?([^" ]+)"?/\1/' | head -1)
  if [[ -n "$file_path" ]]; then
    echo "$file_path"
    return
  fi

  echo ""
}

# Resolve workspace root
resolve_workspace_root() {
  if [[ -n "${HYPER_WORKSPACE_ROOT:-}" ]]; then
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

# Build transcript path
# NOTE: Claude Code encodes CWD by replacing / with - but KEEPS the leading dash
# e.g. /Users/juan/project → -Users-juan-project
build_transcript_path() {
  local session_id="$1"
  local cwd="$2"

  if [[ -z "$session_id" || -z "$cwd" ]]; then
    echo ""
    return
  fi

  # Encode CWD: replace / with - (keep leading dash!)
  local encoded_cwd="${cwd//\//-}"
  local transcript_path="$HOME/.claude/projects/${encoded_cwd}/${session_id}.jsonl"

  if [[ -f "$transcript_path" ]]; then
    echo "$transcript_path"
  else
    echo ""
  fi
}

# Get workspace root
WORKSPACE_ROOT="$(resolve_workspace_root)"
WORKSPACE_ROOT="${WORKSPACE_ROOT%/}"

log_debug "WORKSPACE_ROOT: $WORKSPACE_ROOT"

# Skip if no workspace root
if [[ -z "$WORKSPACE_ROOT" ]]; then
  log_debug "SKIP: no workspace root"
  exit 0
fi

# Get transcript path
TRANSCRIPT_PATH=$(build_transcript_path "$SESSION_ID" "$CWD")

if [[ -z "$TRANSCRIPT_PATH" ]]; then
  log_debug "SKIP: no transcript path found"
  exit 0
fi

log_debug "TRANSCRIPT_PATH: $TRANSCRIPT_PATH"

# Extract identifiers based on subcommand
PROJECT_SLUG=""
TASK_ID=""
FILE_PATH=""

case "$SUBCOMMAND" in
  project)
    PROJECT_SLUG=$(extract_project_slug "$FIRST_CMD")
    ;;
  task)
    TASK_ID=$(extract_task_id "$FIRST_CMD")
    PROJECT_SLUG=$(extract_project_slug "$FIRST_CMD")
    ;;
  file)
    FILE_PATH=$(extract_file_path "$FIRST_CMD")
    PROJECT_SLUG=$(extract_project_slug "$FIRST_CMD")
    ;;
  drive)
    # Drive commands don't have project context
    ;;
esac

log_debug "PROJECT_SLUG: $PROJECT_SLUG"
log_debug "TASK_ID: $TASK_ID"
log_debug "FILE_PATH: $FILE_PATH"

# Skip if we couldn't extract any useful identifier
if [[ -z "$PROJECT_SLUG" && -z "$TASK_ID" && -z "$FILE_PATH" ]]; then
  log_debug "SKIP: no project/task/file identifier found"
  exit 0
fi

# Build the target JSON for the sidecar file
# This matches the format expected by update-session.sh
build_workspace_target() {
  local type="$1"
  local project="$2"
  local task="$3"

  if [[ "$type" == "task" && -n "$task" && -n "$project" ]]; then
    echo "{\"type\":\"task\",\"taskId\":\"${task}\",\"projectSlug\":\"${project}\"}"
  elif [[ -n "$project" ]]; then
    echo "{\"type\":\"project\",\"projectSlug\":\"${project}\"}"
  else
    echo ""
  fi
}

# Determine target type
TARGET_TYPE="project"
if [[ -n "$TASK_ID" ]]; then
  TARGET_TYPE="task"
fi

WORKSPACE_TARGET=$(build_workspace_target "$TARGET_TYPE" "$PROJECT_SLUG" "$TASK_ID")

if [[ -z "$WORKSPACE_TARGET" ]]; then
  log_debug "SKIP: couldn't build workspace target"
  exit 0
fi

log_debug "WORKSPACE_TARGET: $WORKSPACE_TARGET"

# Create/update the sidecar file directly
# This is similar to what update-session.sh does, but with CLI-extracted context
SIDECAR_PATH="${TRANSCRIPT_PATH%.jsonl}.hyper.json"
SIDECAR_DIR=$(dirname "$SIDECAR_PATH")

if [[ ! -d "$SIDECAR_DIR" ]]; then
  log_debug "SKIP: sidecar directory doesn't exist: $SIDECAR_DIR"
  exit 0
fi

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Read existing sidecar if it exists
if [[ -f "$SIDECAR_PATH" ]]; then
  EXISTING_TARGETS=$(jq -c '.recentTargets // []' "$SIDECAR_PATH" 2>/dev/null || echo "[]")
  STARTED_AT=$(jq -r '.startedAt // empty' "$SIDECAR_PATH" 2>/dev/null || echo "$NOW")
else
  EXISTING_TARGETS="[]"
  STARTED_AT="$NOW"
fi

# Add timestamp to current target
CURRENT_TARGET=$(echo "$WORKSPACE_TARGET" | jq -c --arg ts "$NOW" '. + {timestamp: $ts}')

# Check if this is a different target than the last one
LAST_TARGET_PROJECT=$(echo "$EXISTING_TARGETS" | jq -r '.[0].projectSlug // ""' 2>/dev/null || echo "")
CURRENT_TARGET_PROJECT=$(echo "$CURRENT_TARGET" | jq -r '.projectSlug // ""' 2>/dev/null || echo "")

if [[ "$LAST_TARGET_PROJECT" != "$CURRENT_TARGET_PROJECT" || -z "$LAST_TARGET_PROJECT" ]]; then
  UPDATED_TARGETS=$(echo "$EXISTING_TARGETS" | jq -c --argjson new "$CURRENT_TARGET" '[$new] + . | .[0:10]' 2>/dev/null || echo "[$CURRENT_TARGET]")
else
  UPDATED_TARGETS="$EXISTING_TARGETS"
fi

# Build sidecar JSON
# IMPORTANT: Must match schema expected by SessionSyncHandler:
# - currentTarget (not workspaceTarget)
# - lastActivity (not lastWorkspaceActivity)
PARENT_JSON="${PARENT_SESSION:+\"$PARENT_SESSION\"}"
PARENT_JSON="${PARENT_JSON:-null}"
WORKSPACE_JSON="${WORKSPACE_ROOT:+\"$WORKSPACE_ROOT\"}"
WORKSPACE_JSON="${WORKSPACE_JSON:-null}"

cat > "$SIDECAR_PATH" << EOF
{
  "sessionId": "${SESSION_ID}",
  "parentId": ${PARENT_JSON},
  "workspaceRoot": ${WORKSPACE_JSON},
  "currentTarget": ${CURRENT_TARGET},
  "recentTargets": ${UPDATED_TARGETS},
  "startedAt": "${STARTED_AT}",
  "lastActivity": "${NOW}"
}
EOF

log_debug "Sidecar file created/updated: $SIDECAR_PATH"

# For file write commands, extract path from tool_result and call hyper activity add
# This tracks file modifications in the activity log for audit/history purposes
if [[ "$SUBCOMMAND" == "file" ]]; then
  # Try to extract written path from JSON tool result
  # The CLI returns: {"success":true,"data":{"path":"..."}}
  WRITTEN_PATH=""
  if echo "$TOOL_RESULT" | grep -q '"path"'; then
    WRITTEN_PATH=$(echo "$TOOL_RESULT" | jq -r '.data.path // .path // empty' 2>/dev/null || true)
  fi

  if [[ -n "$WRITTEN_PATH" && -n "$SESSION_ID" ]]; then
    log_debug "Tracking file write activity: $WRITTEN_PATH"

    # Determine action based on command (write vs create)
    ACTION="modified"
    if echo "$FIRST_CMD" | grep -qE 'file\s+create'; then
      ACTION="created"
    fi

    # Get hyper binary path
    HYPER_BIN="$(resolve_hyper_bin)"

    # Call activity add (async, don't block on failure)
    "$HYPER_BIN" activity add \
      --file "$WRITTEN_PATH" \
      --actor-type session \
      --actor-id "$SESSION_ID" \
      --action "$ACTION" \
      2>/dev/null &

    log_debug "Activity tracking initiated for $WRITTEN_PATH ($ACTION)"
  fi
fi

# For drive commands (move, create), also track activity
if [[ "$SUBCOMMAND" == "drive" ]]; then
  # Extract path from drive command result
  DRIVE_PATH=""
  if echo "$TOOL_RESULT" | grep -q '"path"'; then
    DRIVE_PATH=$(echo "$TOOL_RESULT" | jq -r '.data.path // .data.new_path // .path // empty' 2>/dev/null || true)
  fi

  if [[ -n "$DRIVE_PATH" && -n "$SESSION_ID" ]]; then
    log_debug "Tracking drive activity: $DRIVE_PATH"

    # Determine action based on command
    ACTION="modified"
    if echo "$FIRST_CMD" | grep -qE 'drive\s+create'; then
      ACTION="created"
    elif echo "$FIRST_CMD" | grep -qE 'drive\s+move'; then
      ACTION="moved"
    fi

    # Get hyper binary path
    HYPER_BIN="$(resolve_hyper_bin)"

    # Call activity add (async, don't block on failure)
    "$HYPER_BIN" activity add \
      --file "$DRIVE_PATH" \
      --actor-type session \
      --actor-id "$SESSION_ID" \
      --action "$ACTION" \
      2>/dev/null &

    log_debug "Activity tracking initiated for $DRIVE_PATH ($ACTION)"
  fi
fi

exit 0
