---
description: Install the Dracula-themed statusline with visual context bar
---

# Hyper Statusline Setup

You are setting up the hyper-engineering statusline for the user. Follow these steps:

## Step 1: Locate the statusline script

The statusline script is at `${CLAUDE_PLUGIN_ROOT}/scripts/statusline.sh` within the plugin directory.

If testing locally with `--plugin-dir`, the path will be relative to that directory.

## Step 2: Copy to user's Claude config

Copy the statusline script to the user's home Claude directory:

```bash
mkdir -p ~/.claude
cp ${CLAUDE_PLUGIN_ROOT}/scripts/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

Also remove the opt-out file if it exists (user is explicitly setting up):

```bash
rm -f ~/.claude/.hyper-statusline-optout
```

## Step 3: Update settings.json

Read the user's `~/.claude/settings.json` file (create if it doesn't exist).

Add or update the `statusLine` configuration:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

**Important**: Preserve any existing settings in the file. Only add/update the `statusLine` key.

## Step 4: Verify installation

Test the statusline script works:

```bash
echo '{"model":{"display_name":"Opus","id":"claude-opus-4"},"workspace":{"current_dir":"/test"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":100000,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}}}' | ~/.claude/statusline.sh
```

Expected output should show colored text with:
- Model badge (◆ Opus)
- Directory ( /test)
- Context bar with percentage

## Step 5: Inform user

Tell the user:

---

**Hyper Statusline installed!**

Your statusline is now configured with:
- Visual context bar (green → yellow → red based on usage)
- Dracula theme colors
- Git branch indicator
- Session cost and lines changed

**Restart Claude Code** to see your new statusline.

**Customization**: Edit `~/.claude/statusline.sh` to modify colors, thresholds, or components.

---

## Troubleshooting

If the test command fails:

1. **jq not installed**:
   ```bash
   brew install jq  # macOS
   apt install jq   # Linux
   ```

2. **Permission denied**:
   ```bash
   chmod +x ~/.claude/statusline.sh
   ```

3. **Colors look wrong**: Ensure terminal supports 24-bit color (iTerm2, Kitty, Alacritty recommended)
