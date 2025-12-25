#!/bin/bash
# Hyper-Engineering Statusline - Dracula Theme
# A modern statusline with visual context bar

# Read JSON input from stdin
input=$(cat)

# ═══════════════════════════════════════════════════════════════════════════════
# DRACULA THEME COLORS (ANSI 256-color codes)
# ═══════════════════════════════════════════════════════════════════════════════
# Using true color (24-bit) ANSI escape codes for exact Dracula colors
RESET="\033[0m"

# Dracula palette
DRACULA_BG="\033[48;2;40;42;54m"        # #282a36
DRACULA_FG="\033[38;2;248;248;242m"     # #f8f8f2
DRACULA_COMMENT="\033[38;2;98;114;164m" # #6272a4
DRACULA_CYAN="\033[38;2;139;233;253m"   # #8be9fd
DRACULA_GREEN="\033[38;2;80;250;123m"   # #50fa7b
DRACULA_ORANGE="\033[38;2;255;184;108m" # #ffb86c
DRACULA_PINK="\033[38;2;255;121;198m"   # #ff79c6
DRACULA_PURPLE="\033[38;2;189;147;249m" # #bd93f9
DRACULA_RED="\033[38;2;255;85;85m"      # #ff5555
DRACULA_YELLOW="\033[38;2;241;250;140m" # #f1fa8c

# Bold variants
BOLD="\033[1m"
DIM="\033[2m"

# ═══════════════════════════════════════════════════════════════════════════════
# EXTRACT DATA FROM JSON INPUT
# ═══════════════════════════════════════════════════════════════════════════════
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Claude"')
MODEL_ID=$(echo "$input" | jq -r '.model.id // ""')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "~"')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // ""')
VERSION=$(echo "$input" | jq -r '.version // ""')

# Cost data
COST_USD=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Context window data
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
USAGE=$(echo "$input" | jq '.context_window.current_usage // null')

# ═══════════════════════════════════════════════════════════════════════════════
# CALCULATE CONTEXT USAGE
# ═══════════════════════════════════════════════════════════════════════════════
PERCENT_USED=0
CURRENT_TOKENS=0

if [ "$USAGE" != "null" ]; then
    INPUT_TOKENS=$(echo "$USAGE" | jq -r '.input_tokens // 0')
    CACHE_CREATE=$(echo "$USAGE" | jq -r '.cache_creation_input_tokens // 0')
    CACHE_READ=$(echo "$USAGE" | jq -r '.cache_read_input_tokens // 0')
    CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))
    if [ "$CONTEXT_SIZE" -gt 0 ]; then
        PERCENT_USED=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
# BUILD CONTEXT BAR
# ═══════════════════════════════════════════════════════════════════════════════
build_context_bar() {
    local percent=$1
    local bar_width=10  # Width of the bar in characters
    local filled=$((percent * bar_width / 100))
    local empty=$((bar_width - filled))

    # Ensure we don't go negative or exceed bar width
    [ $filled -lt 0 ] && filled=0
    [ $filled -gt $bar_width ] && filled=$bar_width
    [ $empty -lt 0 ] && empty=0

    # Choose color based on percentage thresholds
    local bar_color
    if [ $percent -lt 50 ]; then
        bar_color="$DRACULA_GREEN"
    elif [ $percent -lt 80 ]; then
        bar_color="$DRACULA_YELLOW"
    else
        bar_color="$DRACULA_RED"
    fi

    # Build the bar with unicode block characters
    local bar=""
    local i

    # Filled portion
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done

    # Empty portion (using dim block or space)
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done

    # Return the colored bar
    echo -e "${bar_color}${bar}${RESET}"
}

# Build the context bar
CONTEXT_BAR=$(build_context_bar $PERCENT_USED)

# ═══════════════════════════════════════════════════════════════════════════════
# GET GIT INFORMATION
# ═══════════════════════════════════════════════════════════════════════════════
GIT_INFO=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        # Check for uncommitted changes
        if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
            GIT_INFO="${DRACULA_PURPLE} ${BRANCH}${RESET}"
        else
            # Has changes - show with indicator
            GIT_INFO="${DRACULA_ORANGE} ${BRANCH}*${RESET}"
        fi
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
# FORMAT DIRECTORY NAME
# ═══════════════════════════════════════════════════════════════════════════════
DIR_NAME="${CURRENT_DIR##*/}"
# If we're in a subdirectory of the project, show relative path
if [ -n "$PROJECT_DIR" ] && [ "$CURRENT_DIR" != "$PROJECT_DIR" ]; then
    PROJECT_NAME="${PROJECT_DIR##*/}"
    RELATIVE_PATH="${CURRENT_DIR#$PROJECT_DIR/}"
    if [ "$RELATIVE_PATH" != "$CURRENT_DIR" ]; then
        DIR_NAME="${PROJECT_NAME}/${RELATIVE_PATH}"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
# FORMAT COST
# ═══════════════════════════════════════════════════════════════════════════════
COST_DISPLAY=""
if [ "$(echo "$COST_USD > 0" | bc -l 2>/dev/null || echo "0")" = "1" ]; then
    # Format to 4 decimal places
    COST_FORMATTED=$(printf "%.4f" "$COST_USD")
    COST_DISPLAY="${DRACULA_COMMENT}\$${COST_FORMATTED}${RESET}"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# FORMAT LINES CHANGED
# ═══════════════════════════════════════════════════════════════════════════════
LINES_DISPLAY=""
if [ "$LINES_ADDED" -gt 0 ] || [ "$LINES_REMOVED" -gt 0 ]; then
    LINES_DISPLAY="${DRACULA_GREEN}+${LINES_ADDED}${RESET} ${DRACULA_RED}-${LINES_REMOVED}${RESET}"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# BUILD MODEL BADGE
# ═══════════════════════════════════════════════════════════════════════════════
# Color-code model based on type
MODEL_BADGE=""
case "$MODEL_ID" in
    *opus*)
        MODEL_BADGE="${BOLD}${DRACULA_PINK}◆ ${MODEL_DISPLAY}${RESET}"
        ;;
    *sonnet*)
        MODEL_BADGE="${BOLD}${DRACULA_PURPLE}◇ ${MODEL_DISPLAY}${RESET}"
        ;;
    *haiku*)
        MODEL_BADGE="${BOLD}${DRACULA_CYAN}○ ${MODEL_DISPLAY}${RESET}"
        ;;
    *)
        MODEL_BADGE="${BOLD}${DRACULA_FG}● ${MODEL_DISPLAY}${RESET}"
        ;;
esac

# ═══════════════════════════════════════════════════════════════════════════════
# ASSEMBLE THE STATUS LINE
# ═══════════════════════════════════════════════════════════════════════════════
# Separator character
SEP="${DRACULA_COMMENT}│${RESET}"

# Build status line components
STATUS=""

# Model badge (always shown)
STATUS+="${MODEL_BADGE}"

# Directory
STATUS+=" ${SEP} ${DRACULA_CYAN} ${DIR_NAME}${RESET}"

# Git branch (if available)
if [ -n "$GIT_INFO" ]; then
    STATUS+=" ${SEP}${GIT_INFO}"
fi

# Context bar with percentage
STATUS+=" ${SEP} ${DRACULA_COMMENT}ctx${RESET} ${CONTEXT_BAR} ${DRACULA_COMMENT}${PERCENT_USED}%${RESET}"

# Lines changed (if any)
if [ -n "$LINES_DISPLAY" ]; then
    STATUS+=" ${SEP} ${LINES_DISPLAY}"
fi

# Cost (if available)
if [ -n "$COST_DISPLAY" ]; then
    STATUS+=" ${SEP} ${COST_DISPLAY}"
fi

# Output the status line
echo -e "$STATUS"
