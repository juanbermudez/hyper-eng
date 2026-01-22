#!/usr/bin/env bash
# Update session workspace metadata as sidecar file
# Creates/updates ~/.claude/projects/{path}/{session-id}.hyper.json
# Called by track-activity.sh after Write|Edit operations
#
# Design rationale:
# - Sidecar file next to session JSONL (same directory app already watches)
# - Easy to merge into existing sessionsMetadataCollection
# - Natural association via matching session ID
# - No new directories to watch

set -euo pipefail

# ==============================================================================
# Path Resolution
# ==============================================================================

# Note: This script receives WORKSPACE_ROOT as an environment variable from
# track-activity.sh, which sources resolve-paths.sh and exports the correct value.
# We don't need to source resolve-paths.sh again here, but we include the
# standard header for documentation purposes.

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
WORKSPACE_ROOT="${WORKSPACE_ROOT:-}"  # Already resolved by caller

log_debug "update-session.sh called with SESSION_ID=$SESSION_ID TRANSCRIPT_PATH=$TRANSCRIPT_PATH"

# Validate required inputs
if [[ -z "$SESSION_ID" ]]; then
  log_debug "No SESSION_ID, exiting"
  exit 0
fi

if [[ -z "$TRANSCRIPT_PATH" ]]; then
  log_debug "No TRANSCRIPT_PATH, exiting"
  exit 0
fi

# Derive sidecar path from transcript path
# ~/.claude/projects/{path}/{session-id}.jsonl → ~/.claude/projects/{path}/{session-id}.hyper.json
SIDECAR_PATH="${TRANSCRIPT_PATH%.jsonl}.hyper.json"

log_debug "Sidecar path: $SIDECAR_PATH"

# Ensure parent directory exists (should already exist if transcript exists)
SIDECAR_DIR=$(dirname "$SIDECAR_PATH")
if [[ ! -d "$SIDECAR_DIR" ]]; then
  log_debug "Sidecar directory doesn't exist: $SIDECAR_DIR"
  exit 0
fi

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

log_debug "Sidecar file updated: $SIDECAR_PATH"

exit 0
