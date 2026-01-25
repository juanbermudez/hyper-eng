#!/bin/bash
# Update session workspace metadata as sidecar file
# Creates/updates ~/.hyper/sessions/{session-id}.json
# Called by track-activity.sh after Write|Edit operations
#
# Design rationale:
# - Centralized in HyperHome (~/.hyper/sessions/)
# - Easy to scan for all active sessions
# - Decoupled from Claude Code's internal structure
# - Indexed by session ID for fast lookup

set -euo pipefail

# Debug logging
DEBUG_LOG="/tmp/hyper-session-debug.log"
log_debug() {
  if [[ "${HYPER_DEBUG:-false}" == "true" ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$DEBUG_LOG"
  fi
}

# Input parameters (passed as environment variables from track-activity.sh)
SESSION_ID="${SESSION_ID:-}"
PARENT_SESSION="${PARENT_SESSION:-}"
CWD="${CWD:-}"
TRANSCRIPT_PATH="${TRANSCRIPT_PATH:-}"
FILE_PATH="${FILE_PATH:-}"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-}"

# New fields for agent tracking (set by .prose workflows)
HYPER_AGENT_ROLE="${HYPER_AGENT_ROLE:-}"       # captain, squad-leader, worker
HYPER_AGENT_NAME="${HYPER_AGENT_NAME:-}"       # Generated name (e.g., "Captain Zephyr")
HYPER_RUN_ID="${HYPER_RUN_ID:-}"               # .prose run ID
HYPER_WORKFLOW="${HYPER_WORKFLOW:-}"           # Workflow name (e.g., "hyper-plan")
HYPER_PHASE="${HYPER_PHASE:-}"                 # Current phase (e.g., "Research")

log_debug "update-session.sh called with SESSION_ID=$SESSION_ID"

# Validate required inputs
if [[ -z "$SESSION_ID" ]]; then
  log_debug "No SESSION_ID, exiting"
  exit 0
fi

# Resolve HyperHome path
HYPER_HOME="${HYPER_HOME:-$HOME/.hyper}"

# Create sessions directory if it doesn't exist
SESSIONS_DIR="$HYPER_HOME/sessions"
mkdir -p "$SESSIONS_DIR"

# Sidecar path: ~/.hyper/sessions/{session-id}.json
SIDECAR_PATH="$SESSIONS_DIR/${SESSION_ID}.json"

log_debug "Sidecar path: $SIDECAR_PATH"

# Determine target from file path
determine_target() {
  local file_path="$1"
  local workspace_root="$2"

  # If no workspace root, return minimal target
  if [[ -z "$workspace_root" ]]; then
    echo "{\"type\":\"unknown\",\"file_path\":\"${file_path}\"}"
    return
  fi

  # Remove workspace root prefix
  local rel_path="${file_path#$workspace_root/}"

  # Check if it's a task file: projects/{slug}/tasks/task-NNN.mdx
  if [[ "$rel_path" =~ ^projects/([^/]+)/tasks/(task-[0-9]+)\.mdx$ ]]; then
    local project_slug="${BASH_REMATCH[1]}"
    local task_id="${BASH_REMATCH[2]}"
    echo "{\"type\":\"task\",\"taskId\":\"${task_id}\",\"projectSlug\":\"${project_slug}\",\"filePath\":\"${file_path}\"}"
    return
  fi

  # Check if it's a project file: projects/{slug}/_project.mdx
  if [[ "$rel_path" =~ ^projects/([^/]+)/_project\.mdx$ ]]; then
    local project_slug="${BASH_REMATCH[1]}"
    echo "{\"type\":\"project\",\"projectSlug\":\"${project_slug}\",\"filePath\":\"${file_path}\"}"
    return
  fi

  # Check if it's a resource file: projects/{slug}/resources/*
  if [[ "$rel_path" =~ ^projects/([^/]+)/resources/(.+)$ ]]; then
    local project_slug="${BASH_REMATCH[1]}"
    local resource_path="${BASH_REMATCH[2]}"
    echo "{\"type\":\"resource\",\"projectSlug\":\"${project_slug}\",\"resourcePath\":\"${resource_path}\",\"filePath\":\"${file_path}\"}"
    return
  fi

  # Check if it's a doc: docs/{slug}.mdx
  if [[ "$rel_path" =~ ^docs/([^/]+)\.mdx$ ]]; then
    local doc_slug="${BASH_REMATCH[1]}"
    echo "{\"type\":\"doc\",\"docSlug\":\"${doc_slug}\",\"filePath\":\"${file_path}\"}"
    return
  fi

  # Other workspace file
  echo "{\"type\":\"other\",\"filePath\":\"${file_path}\"}"
}

# Get current timestamp in ISO format
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Determine current target
CURRENT_TARGET=$(determine_target "$FILE_PATH" "$WORKSPACE_ROOT")

log_debug "Current target: $CURRENT_TARGET"

# Read existing sidecar if it exists to preserve history
if [[ -f "$SIDECAR_PATH" ]]; then
  # Get existing targets array (last 10)
  EXISTING_TARGETS=$(jq -c '.recentTargets // []' "$SIDECAR_PATH" 2>/dev/null || echo "[]")
  STARTED_AT=$(jq -r '.startedAt // empty' "$SIDECAR_PATH" 2>/dev/null || echo "$NOW")
else
  EXISTING_TARGETS="[]"
  STARTED_AT="$NOW"
fi

# Add current target to history (keep last 10, avoid duplicates)
# Only add if different from last target
LAST_TARGET=$(echo "$EXISTING_TARGETS" | jq -c '.[0] // {}' 2>/dev/null || echo "{}")
LAST_TARGET_PATH=$(echo "$LAST_TARGET" | jq -r '.filePath // ""' 2>/dev/null || echo "")
CURRENT_TARGET_PATH=$(echo "$CURRENT_TARGET" | jq -r '.filePath // ""' 2>/dev/null || echo "")

if [[ "$LAST_TARGET_PATH" != "$CURRENT_TARGET_PATH" ]]; then
  # Prepend current target and keep last 10
  UPDATED_TARGETS=$(echo "$EXISTING_TARGETS" | jq -c --argjson new "$CURRENT_TARGET" '[$new] + . | .[0:10]' 2>/dev/null || echo "[$CURRENT_TARGET]")
else
  UPDATED_TARGETS="$EXISTING_TARGETS"
fi

# Build sidecar JSON
# Uses camelCase to match TypeScript conventions in the app
# Note: Use proper conditional JSON values - if set, wrap in quotes; if not, use null
json_string_or_null() {
  if [[ -n "$1" ]]; then
    echo "\"$1\""
  else
    echo "null"
  fi
}

PARENT_JSON=$(json_string_or_null "$PARENT_SESSION")
WORKSPACE_JSON=$(json_string_or_null "$WORKSPACE_ROOT")
TRANSCRIPT_JSON=$(json_string_or_null "$TRANSCRIPT_PATH")

# New agent tracking fields
ROLE_JSON=$(json_string_or_null "$HYPER_AGENT_ROLE")
NAME_JSON=$(json_string_or_null "$HYPER_AGENT_NAME")
RUN_ID_JSON=$(json_string_or_null "$HYPER_RUN_ID")
WORKFLOW_JSON=$(json_string_or_null "$HYPER_WORKFLOW")
PHASE_JSON=$(json_string_or_null "$HYPER_PHASE")

cat > "$SIDECAR_PATH" << EOF
{
  "sessionId": "${SESSION_ID}",
  "parentId": ${PARENT_JSON},
  "transcriptPath": ${TRANSCRIPT_JSON},
  "workspaceRoot": ${WORKSPACE_JSON},
  "currentTarget": ${CURRENT_TARGET},
  "recentTargets": ${UPDATED_TARGETS},
  "startedAt": "${STARTED_AT}",
  "lastActivity": "${NOW}",
  "agent": {
    "role": ${ROLE_JSON},
    "name": ${NAME_JSON},
    "runId": ${RUN_ID_JSON},
    "workflow": ${WORKFLOW_JSON},
    "phase": ${PHASE_JSON}
  }
}
EOF

log_debug "Sidecar file updated: $SIDECAR_PATH"

exit 0
