#!/usr/bin/env bash
# ==============================================================================
# Central Path Resolution for Hyper Engineering Plugin
# ==============================================================================
# This script provides cross-platform path resolution for HyperHome directories.
# All plugin scripts should source this file to ensure consistent path handling
# across macOS, Linux, and Windows (Git Bash/MSYS2).
#
# Usage:
#   source "$(dirname "$0")/resolve-paths.sh"
#   echo "HyperHome: $HYPER_HOME"
#   echo "Workspace: $HYPER_WORKSPACE_ROOT"
#
# Exported Variables:
#   HYPER_HOME            - Base HyperHome directory
#   HYPER_ACCOUNT_ID      - Active account ID
#   HYPER_ACCOUNT_ROOT    - Account-scoped directory
#   HYPER_WORKSPACE_ID    - Current workspace ID (if in workspace)
#   HYPER_WORKSPACE_ROOT  - Resolved workspace directory (if in workspace)
#   HYPER_PERSONAL_DRIVE  - Personal Drive notes directory
#   HYPER_PLATFORM        - Detected platform (macos|linux|windows)
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Platform Detection
# ==============================================================================

detect_platform() {
  local os_name
  os_name="$(uname -s)"

  case "$os_name" in
    Darwin*)
      echo "macos"
      ;;
    Linux*)
      echo "linux"
      ;;
    CYGWIN*|MINGW*|MSYS*)
      echo "windows"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

HYPER_PLATFORM=$(detect_platform)
export HYPER_PLATFORM

# ==============================================================================
# Base HyperHome Resolution
# ==============================================================================

resolve_hyper_home() {
  local hyper_home

  case "$HYPER_PLATFORM" in
    macos|linux)
      # Standard Unix location
      hyper_home="${HOME}/.hyper"

      # Linux: Respect XDG Base Directory Specification
      if [ "$HYPER_PLATFORM" = "linux" ] && [ -n "${XDG_DATA_HOME:-}" ]; then
        # Only use XDG if explicitly set by user
        if [ -d "$XDG_DATA_HOME/hyper" ]; then
          hyper_home="$XDG_DATA_HOME/hyper"
        fi
      fi
      ;;

    windows)
      # Windows: Use USERPROFILE or LOCALAPPDATA
      if [ -n "${USERPROFILE:-}" ]; then
        hyper_home="$USERPROFILE/.hyper"
      elif [ -n "${LOCALAPPDATA:-}" ]; then
        hyper_home="$LOCALAPPDATA/Hyper"
      else
        hyper_home="${HOME}/.hyper"
      fi
      ;;

    *)
      # Fallback for unknown platforms
      hyper_home="${HOME}/.hyper"
      ;;
  esac

  echo "$hyper_home"
}

HYPER_HOME=$(resolve_hyper_home)
export HYPER_HOME

# ==============================================================================
# Account Resolution
# ==============================================================================

resolve_account_id() {
  local active_account_file="$HYPER_HOME/active-account.json"
  local account_id="local"  # Default fallback

  if [ -f "$active_account_file" ]; then
    # Use jq if available, otherwise fall back to grep/sed
    if command -v jq &> /dev/null; then
      account_id=$(jq -r '.activeAccountId // "local"' "$active_account_file" 2>/dev/null || echo "local")
    else
      # Fallback parsing without jq
      account_id=$(grep -o '"activeAccountId"[[:space:]]*:[[:space:]]*"[^"]*"' "$active_account_file" 2>/dev/null | \
                   sed 's/.*"\([^"]*\)".*/\1/' || echo "local")
    fi
  fi

  echo "$account_id"
}

HYPER_ACCOUNT_ID=$(resolve_account_id)
export HYPER_ACCOUNT_ID

# Account-scoped root directory
HYPER_ACCOUNT_ROOT="$HYPER_HOME/accounts/$HYPER_ACCOUNT_ID/hyper"
export HYPER_ACCOUNT_ROOT

# Personal Drive (account-level, NOT workspace-level)
HYPER_PERSONAL_DRIVE="$HYPER_ACCOUNT_ROOT/notes"
export HYPER_PERSONAL_DRIVE

# ==============================================================================
# Workspace Resolution
# ==============================================================================

resolve_workspace_id() {
  local cwd
  local registry_file="$HYPER_HOME/config.json"
  local workspace_id=""

  # Get current working directory
  cwd="$(pwd)"

  # Normalize path for comparison (remove trailing slash, resolve symlinks)
  cwd="$(cd "$cwd" && pwd -P)"

  if [ -f "$registry_file" ]; then
    # Use jq if available
    if command -v jq &> /dev/null; then
      workspace_id=$(jq -r --arg cwd "$cwd" \
        '.workspaces[]? | select(.localPath == $cwd) | .id' \
        "$registry_file" 2>/dev/null | head -n1)
    else
      # Fallback: Manual parsing (less reliable but works without jq)
      # This is a simplified parser - jq is strongly recommended
      while IFS= read -r line; do
        if echo "$line" | grep -q "\"localPath\".*\"$cwd\""; then
          # Found matching entry, extract id from previous/next lines
          workspace_id=$(echo "$line" | grep -o '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | \
                        sed 's/.*"\([^"]*\)".*/\1/' | head -n1)
          break
        fi
      done < "$registry_file"
    fi
  fi

  # If not found in registry, check for legacy local .hyper directory
  if [ -z "$workspace_id" ]; then
    local legacy_config=".hyper/workspace.json"
    if [ -f "$legacy_config" ]; then
      if command -v jq &> /dev/null; then
        workspace_id=$(jq -r '.workspaceId // .id // ""' "$legacy_config" 2>/dev/null)
      fi
    fi
  fi

  echo "$workspace_id"
}

resolve_workspace_root() {
  local workspace_id="$1"

  if [ -z "$workspace_id" ]; then
    echo ""
    return
  fi

  # Resolve to HyperHome workspace directory
  local workspace_root="$HYPER_ACCOUNT_ROOT/workspaces/$workspace_id"

  # Verify it exists
  if [ -d "$workspace_root" ]; then
    echo "$workspace_root"
  else
    # Fall back to legacy local .hyper if HyperHome doesn't exist
    if [ -d ".hyper" ] && [ -f ".hyper/workspace.json" ]; then
      echo "$(pwd)/.hyper"
    else
      echo ""
    fi
  fi
}

# Only resolve workspace if we're in a directory (not during script testing)
if [ -n "${PWD:-}" ]; then
  HYPER_WORKSPACE_ID=$(resolve_workspace_id)
  export HYPER_WORKSPACE_ID

  if [ -n "$HYPER_WORKSPACE_ID" ]; then
    HYPER_WORKSPACE_ROOT=$(resolve_workspace_root "$HYPER_WORKSPACE_ID")
    export HYPER_WORKSPACE_ROOT
  else
    HYPER_WORKSPACE_ROOT=""
    export HYPER_WORKSPACE_ROOT
  fi
fi

# ==============================================================================
# Utility Functions
# ==============================================================================

# Print all resolved paths (for debugging)
hyper_print_paths() {
  cat <<EOF
Hyper Path Resolution
=====================
Platform:              $HYPER_PLATFORM
HyperHome:             $HYPER_HOME
Account ID:            $HYPER_ACCOUNT_ID
Account Root:          $HYPER_ACCOUNT_ROOT
Personal Drive:        $HYPER_PERSONAL_DRIVE
Workspace ID:          ${HYPER_WORKSPACE_ID:-<not in workspace>}
Workspace Root:        ${HYPER_WORKSPACE_ROOT:-<not in workspace>}
EOF
}

# Check if we're currently in a workspace
hyper_in_workspace() {
  [ -n "${HYPER_WORKSPACE_ROOT:-}" ] && [ -d "$HYPER_WORKSPACE_ROOT" ]
}

# Ensure we're in a workspace (exit with error if not)
hyper_require_workspace() {
  if ! hyper_in_workspace; then
    echo "Error: Not in a Hyper workspace" >&2
    echo "Run 'hypercraft init' to initialize this directory as a workspace" >&2
    exit 1
  fi
}

# ==============================================================================
# Validation
# ==============================================================================

# Check if jq is available (warn but don't fail)
if ! command -v jq &> /dev/null; then
  echo "Warning: 'jq' not found. Path resolution will use fallback parsing." >&2
  echo "Install jq for more reliable JSON parsing:" >&2
  case "$HYPER_PLATFORM" in
    macos)
      echo "  brew install jq" >&2
      ;;
    linux)
      echo "  sudo apt-get install jq  # Debian/Ubuntu" >&2
      echo "  sudo yum install jq      # RHEL/CentOS" >&2
      ;;
    windows)
      echo "  Download from: https://stedolan.github.io/jq/download/" >&2
      ;;
  esac
fi

# ==============================================================================
# Export all functions for use in other scripts
# ==============================================================================

export -f hyper_print_paths
export -f hyper_in_workspace
export -f hyper_require_workspace
