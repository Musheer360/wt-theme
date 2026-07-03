#!/bin/bash
# Windows Terminal Theme Switcher (Live Preview)
# Usage: wt-theme [theme-name]
#   Interactive mode: wt-theme (arrow keys to browse, enter to confirm, q to quit)
#   Direct apply:    wt-theme catppuccin-mocha

set -e

THEMES_DIR="$HOME/.dotfiles/windows-terminal/themes"
WT_SETTINGS="/mnt/c/Users/MusheerAlam/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

# Colors
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
MAGENTA='\033[35m'
RED='\033[31m'
RESET='\033[0m'
REVERSE='\033[7m'

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Installing jq...${RESET}"
    sudo apt-get install -y jq > /dev/null 2>&1
fi

# Get available themes as array
mapfile -t THEMES < <(ls "$THEMES_DIR"/*.json 2>/dev/null | xargs -I{} basename {} .json | sort)
THEME_COUNT=${#THEMES[@]}

if [ "$THEME_COUNT" -eq 0 ]; then
    echo -e "${RED}No themes found in $THEMES_DIR${RESET}"
    exit 1
fi

# Get display name from theme file
get_name() {
    jq -r '.name' "$THEMES_DIR/$1.json"
}

# Get current theme index
get_current_index() {
    local current=$(jq -r '.profiles.defaults.colorScheme // ""' "$WT_SETTINGS" 2>/dev/null)
    for i in "${!THEMES[@]}"; do
        local name=$(get_name "${THEMES[$i]}")
        if [ "$name" = "$current" ]; then
            echo "$i"
            return
        fi
    done
    echo "0"
}

# Apply theme (silent, fast)
apply_theme() {
    local theme_file="$THEMES_DIR/$1.json"
    [ ! -f "$theme_file" ] && return 1

    local name=$(jq -r '.name' "$theme_file")
    local background=$(jq -r '.background' "$theme_file")
    local cursor_color=$(jq -r '.cursorColor' "$theme_file")
    local tab_bg=$(jq -r '.tab.background' "$theme_file")
    local tab_unfocused=$(jq -r '.tab.unfocusedBackground' "$theme_file")
    local tabrow_bg=$(jq -r '.tabRow.background' "$theme_file")
    local tabrow_unfocused=$(jq -r '.tabRow.unfocusedBackground' "$theme_file")
    local scheme=$(jq '.scheme' "$theme_file")

    local tmp=$(mktemp)
    jq --arg name "$name" \
       --arg bg "$background" \
       --arg cursor "$cursor_color" \
       --arg tab_bg "$tab_bg" \
       --arg tab_unfocused "$tab_unfocused" \
       --arg tabrow_bg "$tabrow_bg" \
       --arg tabrow_unfocused "$tabrow_unfocused" \
       --argjson scheme "$scheme" \
       '
       .profiles.defaults.colorScheme = $name |
       .profiles.defaults.background = $bg |
       .profiles.defaults.cursorColor = $cursor |
       .schemes = [$scheme] |
       .theme = $name |
       .themes = [{
           "name": $name,
           "tab": {
               "background": $tab_bg,
               "iconStyle": "default",
               "showCloseButton": "always",
               "unfocusedBackground": $tab_unfocused
           },
           "tabRow": {
               "background": $tabrow_bg,
               "unfocusedBackground": $tabrow_unfocused
           },
           "window": {
               "applicationTheme": "dark",
               "experimental.rainbowFrame": false,
               "frame": null,
               "unfocusedFrame": null,
               "useMica": true
           }
       }]
       ' "$WT_SETTINGS" > "$tmp"

    mv "$tmp" "$WT_SETTINGS"
}

# Draw the interactive menu
draw_menu() {
    local selected=$1
    local original=$2

    # Move cursor to top of menu area
    tput cup $MENU_START_ROW 0

    for i in "${!THEMES[@]}"; do
        local name=$(get_name "${THEMES[$i]}")
        local prefix="   "
        local suffix=""

        # Clear line
        tput el

        if [ "$i" -eq "$original" ]; then
            suffix=" ${DIM}(original)${RESET}"
        fi

        if [ "$i" -eq "$selected" ]; then
            echo -e "  ${REVERSE} ${BOLD}▸ ${name}${RESET}${REVERSE} ${RESET}${suffix}"
        else
            echo -e "  ${DIM}  ${name}${RESET}${suffix}"
        fi
    done

    # Footer
    echo ""
    tput el
    local current_name=$(get_name "${THEMES[$selected]}")
    local bg=$(jq -r '.scheme.background' "$THEMES_DIR/${THEMES[$selected]}.json")
    local fg=$(jq -r '.scheme.foreground' "$THEMES_DIR/${THEMES[$selected]}.json")
    echo -e "  ${DIM}${bg} · ${fg}${RESET}"
    tput el
    echo ""
    tput el
    echo -e "  ${DIM}↑↓ browse (live) · enter confirm · q revert & quit${RESET}"
}

# Interactive mode with live preview
interactive_mode() {
    local selected=$(get_current_index)
    local original=$selected

    # Hide cursor
    tput civis

    # Trap to restore on exit
    trap 'tput cnorm; tput sgr0; echo ""' EXIT

    # Print header
    clear
    echo ""
    echo -e "  ${BOLD}${MAGENTA}╔══════════════════════════════════════╗${RESET}"
    echo -e "  ${BOLD}${MAGENTA}║   Windows Terminal Theme Switcher    ║${RESET}"
    echo -e "  ${BOLD}${MAGENTA}╚══════════════════════════════════════╝${RESET}"
    echo ""

    # Save where menu starts
    MENU_START_ROW=$(tput lines)
    MENU_START_ROW=5

    # Initial draw
    draw_menu $selected $original

    # Read input
    while true; do
        # Read a single character
        IFS= read -rsn1 key

        case "$key" in
            # Arrow key escape sequence
            $'\x1b')
                read -rsn2 -t 0.1 seq
                case "$seq" in
                    '[A') # Up
                        selected=$(( (selected - 1 + THEME_COUNT) % THEME_COUNT ))
                        apply_theme "${THEMES[$selected]}"
                        draw_menu $selected $original
                        ;;
                    '[B') # Down
                        selected=$(( (selected + 1) % THEME_COUNT ))
                        apply_theme "${THEMES[$selected]}"
                        draw_menu $selected $original
                        ;;
                esac
                ;;
            # Enter - confirm
            '')
                tput cnorm
                clear
                echo -e "  ${GREEN}✓${RESET} Applied ${BOLD}$(get_name "${THEMES[$selected]}")${RESET}"
                trap - EXIT
                exit 0
                ;;
            # q - revert and quit
            'q'|'Q')
                if [ "$selected" -ne "$original" ]; then
                    apply_theme "${THEMES[$original]}"
                fi
                tput cnorm
                clear
                echo -e "  ${DIM}Reverted to${RESET} ${BOLD}$(get_name "${THEMES[$original]}")${RESET}"
                trap - EXIT
                exit 0
                ;;
            # j/k vim keys
            'j')
                selected=$(( (selected + 1) % THEME_COUNT ))
                apply_theme "${THEMES[$selected]}"
                draw_menu $selected $original
                ;;
            'k')
                selected=$(( (selected - 1 + THEME_COUNT) % THEME_COUNT ))
                apply_theme "${THEMES[$selected]}"
                draw_menu $selected $original
                ;;
        esac
    done
}

# --- Main ---

if [ $# -eq 0 ]; then
    interactive_mode
elif [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
    echo -e "${BOLD}Available themes:${RESET}"
    for theme in "${THEMES[@]}"; do
        name=$(get_name "$theme")
        echo "  $name ($theme)"
    done
elif [ "$1" = "--current" ] || [ "$1" = "-c" ]; then
    jq -r '.profiles.defaults.colorScheme' "$WT_SETTINGS"
else
    if apply_theme "$1"; then
        echo -e "${GREEN}✓${RESET} Applied ${BOLD}$(get_name "$1")${RESET}"
    else
        echo -e "${RED}✗${RESET} Theme '$1' not found. Run ${BOLD}wt-theme --list${RESET} to see available themes."
        exit 1
    fi
fi
