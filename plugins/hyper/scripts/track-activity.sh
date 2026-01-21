#!/bin/bash
# Track activity on workspace data root file modifications
# Called by PostToolUse hook after Write|Edit operations

# Debug logging (remove after testing)
DEBUG_LOG="/tmp/hyper-hook-debug.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] track-activity.sh triggered" >> "$DEBUG_LOG"

# Read PostToolUse JSON from stdin
INPUT=$(cat)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] INPUT: $INPUT" >> "$DEBUG_LOG"

# Extract fields using jq
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
PARENT_SESSION=$(echo "$INPUT" | jq -r '.parent_session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Build transcript path: ~/.claude/projects/{encoded-cwd}/{session_id}.jsonl
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

  # Only return if the file exists (session is active)
  if [[ -f "$transcript_path" ]]; then
    echo "$transcript_path"
  else
    echo ""
  fi
}

TRANSCRIPT_PATH=$(build_transcript_path "$SESSION_ID" "$CWD")

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

HYPER_BIN="$(resolve_hyper_bin)"
WORKSPACE_ROOT="$(resolve_workspace_root)"
WORKSPACE_ROOT="${WORKSPACE_ROOT%/}"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] FILE_PATH: $FILE_PATH" >> "$DEBUG_LOG"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] SESSION_ID: $SESSION_ID" >> "$DEBUG_LOG"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] CWD: $CWD" >> "$DEBUG_LOG"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] TRANSCRIPT_PATH: $TRANSCRIPT_PATH" >> "$DEBUG_LOG"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] WORKSPACE_ROOT: $WORKSPACE_ROOT" >> "$DEBUG_LOG"

# Check if file is in HyperHome (global ~/.hyper/accounts/...)
# This takes priority over local .hyper folders
HYPER_HOME="$HOME/.hyper"
IS_HYPER_HOME_FILE=false
if [[ "$FILE_PATH" == "$HYPER_HOME/accounts/"* ]]; then
  IS_HYPER_HOME_FILE=true
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] File is in HyperHome" >> "$DEBUG_LOG"
fi

# Skip if not a workspace data file
if [[ "$IS_HYPER_HOME_FILE" == "true" ]]; then
  # HyperHome files are always valid for activity tracking
  :
elif [[ -n "$WORKSPACE_ROOT" ]]; then
  case "$FILE_PATH" in
    "$WORKSPACE_ROOT"/*) ;;
    *) echo "[$(date '+%Y-%m-%d %H:%M:%S')] SKIP: file not in workspace root" >> "$DEBUG_LOG"; exit 0 ;;
  esac
else
  if [[ "$FILE_PATH" != *".hyper/"* ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SKIP: no workspace root and file not in .hyper/" >> "$DEBUG_LOG"
    exit 0
  fi
fi

# Skip if not an .mdx file
if [[ "$FILE_PATH" != *.mdx ]]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] SKIP: not an .mdx file" >> "$DEBUG_LOG"
  exit 0
fi

# Skip if no session ID
if [[ -z "$SESSION_ID" ]]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] SKIP: no session ID" >> "$DEBUG_LOG"
  exit 0
fi

# Build command with actor schema
CMD="$HYPER_BIN activity add"
CMD="$CMD --file \"$FILE_PATH\""
CMD="$CMD --actor-type session"
CMD="$CMD --actor-id \"$SESSION_ID\""

# Add parent session if present (for sub-agents)
if [[ -n "$PARENT_SESSION" && "$PARENT_SESSION" != "null" ]]; then
  CMD="$CMD --parent-id \"$PARENT_SESSION\""
fi

# Add transcript path if available
if [[ -n "$TRANSCRIPT_PATH" ]]; then
  CMD="$CMD --transcript \"$TRANSCRIPT_PATH\""
fi

# Action is always "modified" for automatic tracking
CMD="$CMD --action modified"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] EXECUTING: $CMD" >> "$DEBUG_LOG"

# Execute (silently fail - don't block agent)
RESULT=$(eval $CMD 2>&1) || true
echo "[$(date '+%Y-%m-%d %H:%M:%S')] RESULT: $RESULT" >> "$DEBUG_LOG"

# Also update the session registry for active session tracking
# This creates/updates $HYPER_WORKSPACE_ROOT/.sessions/{session-id}.json
# for the desktop app to display which sessions are active on which projects/tasks
SESSION_SCRIPT="${CLAUDE_PLUGIN_ROOT}/scripts/update-session.sh"
if [[ -x "$SESSION_SCRIPT" ]]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Calling update-session.sh" >> "$DEBUG_LOG"
  export SESSION_ID
  export PARENT_SESSION
  export CWD
  export TRANSCRIPT_PATH
  export FILE_PATH
  export WORKSPACE_ROOT="$WORKSPACE_ROOT"
  "$SESSION_SCRIPT" 2>&1 || true
fi

exit 0
