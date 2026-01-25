# Cross-Platform Path Resolution

This document explains how Hyper Engineering resolves paths across macOS, Linux, and Windows.

## Overview

All path operations in Hyper Engineering use **central path resolution** via `scripts/resolve-paths.sh`. This ensures consistent behavior across all platforms and handles account/workspace scoping correctly.

## Platform-Specific HyperHome Locations

| Platform | Primary Location | Alternative | Notes |
|----------|------------------|-------------|-------|
| **macOS** | `~/.hyper/` | - | Standard Unix location |
| **Linux** | `~/.hyper/` | `$XDG_DATA_HOME/hyper/` | Respects XDG Base Dir if set |
| **Windows** | `%USERPROFILE%\.hyper\` | `%LOCALAPPDATA%\Hyper\` | Git Bash/WSL recommended |

### Resolution Priority

1. **Environment variable** (if set): `$HYPER_HOME`
2. **Platform-specific default**:
   - **Linux**: Check `$XDG_DATA_HOME/hyper/` if XDG_DATA_HOME is set
   - **Windows**: Use `$USERPROFILE/.hyper` or fallback to `$LOCALAPPDATA/Hyper`
   - **macOS**: Use `~/.hyper/`

## HyperHome Directory Structure

Regardless of platform, HyperHome follows this structure:

```
~/.hyper/                               # Base HyperHome (OS-specific)
├── active-account.json                 # Current account pointer
├── config.json                         # Global workspace registry
└── accounts/
    └── {accountId}/
        └── hyper/
            ├── config.json             # Account settings
            ├── notes/                  # Personal Drive (account-level)
            │   ├── personal-note-1.mdx
            │   └── personal-note-2.mdx
            └── workspaces/
                └── {workspaceId}/      # Workspace-scoped directory
                    ├── workspace.json  # Workspace metadata
                    ├── projects/       # Projects and tasks
                    │   └── {slug}/
                    │       ├── _project.mdx
                    │       └── tasks/
                    └── settings/       # Workspace configuration
                        ├── workflows.yaml
                        ├── agents/
                        ├── commands/
                        └── skills/
```

## Path Resolution Variables

When scripts source `resolve-paths.sh`, these variables are exported:

| Variable | Example Value (macOS) | Example Value (Windows) | Description |
|----------|------------------------|-------------------------|-------------|
| `HYPER_PLATFORM` | `macos` | `windows` | Detected platform |
| `HYPER_HOME` | `/Users/juan/.hyper` | `C:/Users/juan/.hyper` | Base HyperHome |
| `HYPER_ACCOUNT_ID` | `local` | `local` | Active account ID |
| `HYPER_ACCOUNT_ROOT` | `/Users/juan/.hyper/accounts/local/hyper` | `C:/Users/juan/.hyper/accounts/local/hyper` | Account root |
| `HYPER_PERSONAL_DRIVE` | `/Users/juan/.hyper/accounts/local/hyper/notes` | `C:/Users/juan/.hyper/accounts/local/hyper/notes` | Personal Drive |
| `HYPER_WORKSPACE_ID` | `my-project-a1b2c3` | `my-project-a1b2c3` | Current workspace ID |
| `HYPER_WORKSPACE_ROOT` | `/Users/juan/.hyper/accounts/local/hyper/workspaces/my-project-a1b2c3` | `C:/Users/juan/.hyper/accounts/local/hyper/workspaces/my-project-a1b2c3` | Workspace directory |

## Using Path Resolution in Scripts

**Always source the central resolver first**:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Source central path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/resolve-paths.sh"

# Now use exported variables
echo "Platform: $HYPER_PLATFORM"
echo "HyperHome: $HYPER_HOME"
echo "Workspace: $HYPER_WORKSPACE_ROOT"
```

**Check if in workspace**:

```bash
if hyper_in_workspace; then
  echo "Working in workspace: $HYPER_WORKSPACE_ID"
else
  echo "Not in a workspace directory"
fi
```

**Require workspace (exit if not present)**:

```bash
hyper_require_workspace
# Script continues only if in workspace
```

## Cross-Platform Considerations

### Path Separators

The path resolver handles path separators automatically:
- **Unix (macOS/Linux)**: `/`
- **Windows (Git Bash)**: `/` (converted from `\` automatically)

**Best Practice**: Always use forward slashes `/` in scripts. Git Bash handles conversion.

### Command Availability

Not all commands are available on all platforms:

| Command | macOS | Linux | Windows (Git Bash) | Fallback |
|---------|-------|-------|---------------------|----------|
| `jq` | ✅ (via Homebrew) | ✅ (via apt/yum) | ⚠️ Manual install | grep/sed parsing |
| `md5sum` | ❌ Use `md5` | ✅ | ✅ | `shasum` fallback |
| `date -u` | ✅ | ✅ | ✅ | - |
| `pwd -P` | ✅ | ✅ | ✅ | - |

**The resolver handles these differences automatically**.

### User Home Directory

Different shell environments may set `$HOME` differently:

| Environment | `$HOME` |
|-------------|---------|
| **macOS Terminal** | `/Users/username` |
| **Linux bash** | `/home/username` |
| **Windows Git Bash** | `/c/Users/username` or `C:/Users/username` |
| **Windows WSL** | `/home/username` |
| **Windows PowerShell** | Uses `$env:USERPROFILE` |

**The resolver normalizes these automatically**.

## Account Resolution

### Active Account Detection

1. Check `$HYPER_HOME/active-account.json`
2. Parse `activeAccountId` field
3. Fallback to `"local"` if not found

**Example `active-account.json`**:

```json
{
  "activeAccountId": "local",
  "created": "2026-01-22T10:00:00Z"
}
```

### Multi-Account Support

Users can have multiple accounts for different machines or contexts:

```
~/.hyper/accounts/
├── local/           # Default local account
├── work-laptop/     # Work machine account
└── home-desktop/    # Home machine account
```

**Switching accounts**:

```bash
# Manually edit active-account.json
cat > ~/.hyper/active-account.json << EOF
{
  "activeAccountId": "work-laptop"
}
EOF
```

## Workspace Resolution

### Registry-Based Resolution

1. Read `$HYPER_HOME/config.json` (workspace registry)
2. Find entry where `localPath` matches current directory
3. Use that entry's `id` to resolve workspace directory
4. Fallback to legacy local `.hyper/` if not in registry

**Example `config.json`**:

```json
{
  "version": 1,
  "workspaces": [
    {
      "id": "my-project-a1b2c3",
      "localPath": "/Users/juan/projects/my-project",
      "lastOpened": "2026-01-22T10:00:00Z"
    },
    {
      "id": "other-proj-d4e5f6",
      "localPath": "/Users/juan/projects/other-proj",
      "lastOpened": "2026-01-20T15:30:00Z"
    }
  ]
}
```

### Workspace ID Generation

Workspace IDs combine name + path hash for uniqueness:

```bash
WORKSPACE_NAME=$(basename "$(pwd)")        # e.g., "my-project"
PATH_HASH=$(echo "$(pwd)" | md5sum | cut -c1-6)  # e.g., "a1b2c3"
WORKSPACE_ID="$WORKSPACE_NAME-$PATH_HASH"  # "my-project-a1b2c3"
```

**Why hash the path?**
- Prevents ID collisions if multiple projects have same name
- Workspace ID stays consistent even if project is renamed locally

### Cross-Machine Workspace Sync

When working from different machines:

**Machine A** (where workspace was created):
```
Local: /Users/alice/projects/my-app
Workspace ID: my-app-a1b2c3
HyperHome: ~/.hyper/accounts/local/hyper/workspaces/my-app-a1b2c3/
```

**Machine B** (cloned repo):
```
Local: /home/alice/repos/my-app
Workspace ID: my-app-d4e5f6  (different hash!)
HyperHome: ~/.hyper/accounts/local/hyper/workspaces/my-app-d4e5f6/
```

**Solution**: Each machine gets its own workspace entry. To share workspace data:
1. Export from Machine A: `tar -czf workspace.tar.gz -C ~/.hyper/accounts/local/hyper/workspaces my-app-a1b2c3`
2. Import to Machine B: `tar -xzf workspace.tar.gz -C ~/.hyper/accounts/local/hyper/workspaces/`
3. Update registry on Machine B to point to imported workspace

## Drive Scope Resolution

Personal Drive notes are **account-scoped**, not workspace-scoped:

```
$HYPER_ACCOUNT_ROOT/notes/           # Personal Drive (all workspaces)
  ├── personal-research.mdx          # id: "personal:research"
  └── personal-ideas.mdx             # id: "personal:ideas"

$HYPER_WORKSPACE_ROOT/               # Workspace (project-specific)
  └── projects/{slug}/
      └── resources/                 # Project resources (git-tracked)
          └── research.md
```

**When to use Personal Drive vs Workspace resources**:

| Content | Location | Scope | Git-Tracked |
|---------|----------|-------|-------------|
| Personal notes, research | Personal Drive | Account | ❌ No |
| Project specs, tasks | Workspace | Workspace | ✅ Yes |
| Shared design docs | Workspace Drive | Workspace | ❌ No |
| Org templates | Org Drive | Organization | ❌ No |

## Platform-Specific Tips

### macOS

**Installation**:
```bash
# Install jq via Homebrew
brew install jq
```

**Permissions**:
- HyperHome at `~/.hyper/` has standard Unix permissions
- No special setup needed

### Linux

**Installation**:
```bash
# Ubuntu/Debian
sudo apt-get install jq

# RHEL/CentOS
sudo yum install jq

# Arch
sudo pacman -S jq
```

**XDG Support**:
```bash
# Optional: Use XDG location
export XDG_DATA_HOME="$HOME/.local/share"
# HyperHome will resolve to ~/.local/share/hyper/
```

**Permissions**:
- Ensure `~/.hyper/` is writable: `chmod 755 ~/.hyper`

### Windows

**Recommended**: Use Git Bash or WSL for best compatibility.

**PowerShell users**: Plugin scripts expect bash environment. Install Git Bash:
1. Download from https://git-scm.com/download/win
2. During install, select "Use Git Bash only"
3. Run Claude Code in Git Bash

**Installation**:
```powershell
# Install jq via Scoop (PowerShell)
scoop install jq

# Or download manually
# https://stedolan.github.io/jq/download/
```

**Path Resolution**:
- Git Bash: Paths use forward slashes `/c/Users/juan/.hyper`
- PowerShell: Use `$env:USERPROFILE\.hyper` (backslashes)
- WSL: Standard Unix paths `/home/juan/.hyper`

**Troubleshooting**:

If path resolution fails on Windows:
```bash
# Check HOME variable
echo $HOME

# If empty, set manually
export HOME="$USERPROFILE"

# Verify HyperHome
ls -la ~/.hyper
```

## Debugging Path Resolution

**Print all resolved paths**:

```bash
# After sourcing resolve-paths.sh
hyper_print_paths
```

**Output**:
```
Hyper Path Resolution
=====================
Platform:              macos
HyperHome:             /Users/juan/.hyper
Account ID:            local
Account Root:          /Users/juan/.hyper/accounts/local/hyper
Personal Drive:        /Users/juan/.hyper/accounts/local/hyper/notes
Workspace ID:          my-project-a1b2c3
Workspace Root:        /Users/juan/.hyper/accounts/local/hyper/workspaces/my-project-a1b2c3
```

**Manual path check**:

```bash
# Check if HyperHome exists
if [ -d "$HYPER_HOME" ]; then
  echo "✅ HyperHome exists"
else
  echo "❌ HyperHome not found"
fi

# Check if in workspace
if hyper_in_workspace; then
  echo "✅ In workspace: $HYPER_WORKSPACE_ID"
else
  echo "❌ Not in workspace"
fi
```

## Migration from Legacy Structure

**Old (Legacy)**: Local `.hyper/` in each project
```
my-project/
├── .hyper/
│   ├── workspace.json
│   ├── projects/
│   └── notes/
└── src/
```

**New (HyperHome)**: Centralized account-scoped structure
```
my-project/
└── src/

~/.hyper/accounts/local/hyper/
├── notes/                          # Personal Drive (account-level)
└── workspaces/my-project-a1b2c3/  # Workspace (project-specific)
    ├── workspace.json
    └── projects/
```

**Benefits**:
- Cleaner project directories
- Centralized management
- Account-scoped Drive notes
- Better multi-workspace support

**Migration command**: `/hyper:init` automatically detects and offers migration.

## Summary

1. **Always use central path resolution** via `resolve-paths.sh`
2. **HyperHome location is platform-aware** (respects OS conventions)
3. **Account scoping** separates data by account/machine
4. **Workspace registry** maps local directories to HyperHome workspaces
5. **Personal Drive is account-level**, not workspace-level
6. **Cross-platform scripts** handle OS differences automatically

**Golden rule**: Never hardcode paths. Always use `$HYPER_WORKSPACE_ROOT`, `$HYPER_PERSONAL_DRIVE`, etc.
