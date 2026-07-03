# wt-theme

A live-preview theme switcher for Windows Terminal. Browse themes with arrow keys and watch your terminal change in real time.

![bash](https://img.shields.io/badge/bash-5.0%2B-green)
![themes](https://img.shields.io/badge/themes-14-blue)
![platform](https://img.shields.io/badge/platform-WSL-orange)

## Demo

```
  ╔══════════════════════════════════════╗
  ║   Windows Terminal Theme Switcher    ║
  ╚══════════════════════════════════════╝

   ▸ Catppuccin Mocha  (original)
     Dracula
     Everforest Dark
     Gruvbox Dark
     Tokyo Night
     ...

  ↑↓ browse (live) · enter confirm · q revert & quit
```

Themes apply **instantly** as you navigate — no need to confirm first. If you quit with `q`, it reverts to your original theme.

## Themes

| Theme | Vibe |
|-------|------|
| Ayu Dark | Minimal, deep black with warm orange accents |
| Catppuccin Mocha | Pastel on dark blue, easy on the eyes |
| Dracula | Classic purple-dark with neon accents |
| Everforest Dark | Soft green-tinted, muted and calm |
| Gruvbox Dark | Warm earthy retro tones |
| Kanagawa | Japanese wave-inspired, cool indigo |
| Nightfox | Rich midnight blue, vibrant but tasteful |
| Nord | Arctic blue-grey, minimal and calming |
| One Dark | Atom editor's balanced dark theme |
| Oxocarbon | IBM's design system, cool and modern |
| Rosé Pine | Elegant plum-navy with muted pastels |
| Solarized Dark | The original precision-crafted dark theme |
| Synthwave '84 | Retro neon pink/purple/cyan |
| Tokyo Night | Cyberpunk city lights, deep blue-purple |

## Install

Requires: `bash 5.0+`, `jq`, WSL with Windows Terminal

```bash
git clone https://github.com/Musheer360/wt-theme.git ~/.dotfiles/windows-terminal
chmod +x ~/.dotfiles/windows-terminal/wt-theme.sh
ln -sf ~/.dotfiles/windows-terminal/wt-theme.sh ~/.local/bin/wt-theme
```

> Make sure `~/.local/bin` is in your `PATH`.

### jq

The script auto-installs `jq` if missing, or install manually:

```bash
sudo apt install jq
```

## Usage

```bash
# Interactive live-preview mode (arrow keys / j,k to navigate)
wt-theme

# Apply a theme directly
wt-theme dracula
wt-theme tokyo-night

# List available themes
wt-theme --list

# Show current theme
wt-theme --current
```

### Controls (interactive mode)

| Key | Action |
|-----|--------|
| `↑` / `k` | Previous theme (applies live) |
| `↓` / `j` | Next theme (applies live) |
| `Enter` | Confirm and exit |
| `q` | Revert to original and exit |

## Configuration

The script expects Windows Terminal settings at:
```
/mnt/c/Users/<username>/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
```

Edit the `WT_SETTINGS` variable in `wt-theme.sh` if your path differs.

## Adding custom themes

Drop a JSON file in the `themes/` directory:

```json
{
    "name": "My Theme",
    "scheme": {
        "background": "#1a1a2e",
        "foreground": "#eaeaea",
        "black": "#000000",
        "red": "#ff0000",
        "green": "#00ff00",
        "yellow": "#ffff00",
        "blue": "#0000ff",
        "purple": "#ff00ff",
        "cyan": "#00ffff",
        "white": "#ffffff",
        "brightBlack": "#555555",
        "brightRed": "#ff5555",
        "brightGreen": "#55ff55",
        "brightYellow": "#ffff55",
        "brightBlue": "#5555ff",
        "brightPurple": "#ff55ff",
        "brightCyan": "#55ffff",
        "brightWhite": "#ffffff",
        "cursorColor": "#eaeaea",
        "selectionBackground": "#333333",
        "name": "My Theme"
    },
    "background": "#1a1a2e",
    "cursorColor": "#eaeaea",
    "tab": {
        "background": "#1a1a2eFF",
        "unfocusedBackground": "#141422FF"
    },
    "tabRow": {
        "background": "#141422FF",
        "unfocusedBackground": "#141422FF"
    }
}
```

The theme will appear in the switcher immediately.

## License

MIT
