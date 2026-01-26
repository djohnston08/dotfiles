#!/usr/bin/env bash

###
# Colorized output helpers
# Based on Adam Eivy's dotfiles
###

# Colors
COL_BLUE="\033[0;34m"
COL_GREEN="\033[0;32m"
COL_YELLOW="\033[0;33m"
COL_RED="\033[0;31m"
COL_RESET="\033[0m"

# Print a "bot" message (main status)
bot() {
    echo -e "\n${COL_BLUE}[BOT]${COL_RESET} $1"
}

# Print an "action" message (about to do something)
action() {
    echo -e "  ${COL_YELLOW}[ACTION]${COL_RESET} $1"
}

# Print a "running" message (currently doing something)
running() {
    echo -en "  ${COL_YELLOW}[RUNNING]${COL_RESET} $1..."
}

# Print an "ok" message (success)
ok() {
    if [[ -n "$1" ]]; then
        echo -e "  ${COL_GREEN}[OK]${COL_RESET} $1"
    else
        echo -e " ${COL_GREEN}OK${COL_RESET}"
    fi
}

# Print a "warn" message
warn() {
    echo -e "  ${COL_YELLOW}[WARN]${COL_RESET} $1"
}

# Print an "error" message
error() {
    echo -e "  ${COL_RED}[ERROR]${COL_RESET} $1"
}
