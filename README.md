# Dotfiles

Cross-platform dotfiles supporting both macOS and Linux environments with Zsh, Neovim, and (on macOS) Hammerspoon configurations optimized for the ZSA Voyager keyboard.

## Overview

This repository contains my personal configuration files for:
- **Shell**: Zsh with Oh My Zsh and custom theme
- **Editor**: Neovim with Lua configuration and Lazy.nvim
- **Window Management**: Hammerspoon with portrait monitor support
- **Package Management**: Homebrew bundle
- **Development Tools**: Git, tmux, and various CLI utilities

## Quick Start

```bash
# Clone the repository
git clone https://github.com/djohnston08/dotfiles.git ~/projects/dotfiles

# Run the unified installer (works on both macOS and Linux)
cd ~/projects/dotfiles
./install-unified.sh

# Or use the original macOS-only installer
./install.sh
```

The unified installer will:
1. Detect your operating system (macOS or Linux)
2. Install platform-specific prerequisites
3. Set Zsh as the default shell
4. Backup existing dotfiles to `~/.dotfiles_backup/[timestamp]/`
5. Create symlinks for common and platform-specific configurations
6. On macOS: Install Homebrew packages from the Brewfile
7. On Linux: Install essential packages via your distribution's package manager

## Directory Structure

```
dotfiles/
├── common/           # Cross-platform configurations
│   └── shell/        # Shell configs that work everywhere
│       ├── .shellaliases.common
│       ├── .shellvars.common
│       └── .shellpaths.common
├── macos/            # macOS-specific configurations
│   ├── install.sh    # macOS installer
│   └── shell/        # macOS shell configs
│       ├── .shellaliases.macos
│       ├── .shellvars.macos
│       └── .shellpaths.macos
├── linux/            # Linux-specific configurations
│   ├── install.sh    # Linux installer
│   └── shell/        # Linux shell configs
│       ├── .shellaliases.linux
│       ├── .shellvars.linux
│       └── .shellpaths.linux
├── lib/              # Shared libraries
│   ├── platform.sh   # Platform detection
│   └── common.sh     # Common functions
├── homedir/          # Dotfiles symlinked to ~/
│   ├── .zshrc        # Main Zsh configuration
│   ├── .profile      # Shell loader
│   ├── .shellvars    # Sources common + platform vars
│   ├── .shellaliases # Sources common + platform aliases
│   ├── .shellpaths   # Sources common + platform paths
│   ├── .hammerspoon/ # macOS window management
│   └── nvim/         # Neovim configuration
├── ohmyzsh/          # Full Oh My Zsh installation
├── scripts/          # Utility scripts
├── themes/           # Custom Zsh theme
├── plugins/          # Custom plugins
├── Brewfile          # Homebrew packages (macOS)
├── install-unified.sh # Cross-platform installer
├── install.sh        # Legacy macOS installer
└── CLAUDE.md         # AI assistant instructions
```

## Key Features

### Shell Configuration

The shell configuration follows this loading order:
1. `.zshrc` → Sources Oh My Zsh, nvm, custom theme, and `.zprofile`
2. `.zprofile` → Sources `.profile` and sets up platform-specific paths
3. `.profile` → Sources `.shellvars`, `.shellfn`, `.shellpaths`, `.shellaliases`
4. Each shell config file sources common configurations first, then platform-specific ones

**Platform Detection**: Shell files automatically detect the OS and load appropriate configurations:
- Common configurations are shared between platforms
- macOS-specific configs include Homebrew paths, Tailscale aliases, etc.
- Linux-specific configs include package manager aliases, system paths, etc.

### Neovim Setup

Modern Neovim configuration using:
- Lua-based configuration
- Lazy.nvim for plugin management
- LSP support for multiple languages
- Custom keymaps and themes

### Hammerspoon Window Management (macOS only)

Modular Hammerspoon configuration with:
- Portrait monitor detection and layouts
- Application launcher hotkeys
- Advanced window positioning
- Spotify controls and auto-positioning

See [Hammerspoon Key Reference](#hammerspoon-key-reference) below for all keyboard shortcuts.

## Hammerspoon Key Reference (macOS only)

### Key Modifiers
- **Hyper**: `Cmd + Alt + Ctrl + Shift`
- **Mash**: `Shift + Ctrl + Alt`

### Application Launchers (Hyper + Letter)

#### Communication
- `Hyper + S` → Slack
- `Hyper + I` → Messages  
- `Hyper + Q` → Discord
- `Hyper + E` → Superhuman

#### Development Tools
- `Hyper + P` → PhpStorm
- `Hyper + V` → Visual Studio Code
- `Hyper + T` → iTerm
- `Hyper + ;` → Linear
- `Hyper + G` → OpenLens
- `Hyper + R` → Postman
- `Hyper + M` → DataGrip

#### Productivity & Browser
- `Hyper + C` → Google Chrome
- `Hyper + N` → Obsidian
- `Hyper + W` → Claude
- `Hyper + F` → Fantastical
- `Hyper + D` → Reminders
- `Hyper + X` → Microsoft Excel
- `Hyper + B` → Miro
- `Hyper + A` → ChatGPT

#### Media & Utilities
- `Hyper + Y` → Spotify
- `Hyper + U` → Granola
- `Hyper + Z` → Keymapp

### Window Management

#### Basic Window Controls (Hyper + Direction)
- `Hyper + H` → Left half of screen
- `Hyper + L` → Right half of screen
- `Hyper + J` → Maximize window
- `Hyper + K` → Move to next screen
- `Hyper + 1` → Center window (big)

#### Advanced Window Positioning (Mash + Key)
- `Mash + H` → Left 70%
- `Mash + L` → Right 30%
- `Mash + K` → Top 50%
- `Mash + J` → Bottom 50%
- `Mash + [` → Upper left 70%
- `Mash + ]` → Upper right 30%
- `Mash + ;` → Bottom left 70%
- `Mash + '` → Bottom right 30%
- `Mash + M` → Maximize
- `Mash + I` → Center (small)
- `Mash + O` → Center (medium)
- `Mash + P` → Center (big)
- `Mash + Y` → Center on screen

### Portrait Monitor Features
- `Hyper + 9` → Quick position Spotify on portrait monitor
- `Hyper + 6` → Meeting layout:
  - Left monitor: Granola (left 30%), iTerm (right 70%)
  - Middle monitor: Chrome centered (70% size)
  - Portrait monitor: Fantastical (top half), Slack (bottom half)
- `Hyper + 5` → Monitoring layout:
  - Portrait monitor: OpenLens (top), DataGrip (middle), Docker Desktop (bottom)
- `Hyper + 4` → Communication layout:
  - Portrait monitor: Discord (top), Slack (middle), Messages (bottom)
- `Hyper + 3` → Coding layout:
  - Left monitor: Chrome (90% width, 88% height, centered), DataGrip (bottom 60%, overlapping)
  - Middle monitor: iTerm fullscreen
  - Portrait monitor: Spotify (top 20%), Linear (25% height), Claude (bottom 55%)
  - Note: DataGrip overlaps behind Chrome for quick access via app switcher

### Other Controls
- `Hyper + \` → Display current Spotify track
- `Hyper + PageUp` → Spotify volume up
- `Hyper + PageDown` → Spotify volume down
- `Hyper + 0` → Reload Hammerspoon config

## Custom Scripts

Located in `scripts/` and symlinked to `~/.local/bin/`:
- `tmux-sessionizer` - Quick tmux session management
- `dn` - Directory navigation helper
- `psg` - Process search with grep

## Common Tasks

### Update Packages

**macOS (Homebrew):**
```bash
brew bundle
```

**Linux (varies by distribution):**
```bash
# Debian/Ubuntu
sudo apt update && sudo apt upgrade

# Arch/Manjaro
sudo pacman -Syu

# Fedora
sudo dnf update
```

### Update Oh My Zsh
```bash
cd ~/projects/dotfiles/ohmyzsh && git pull
```

### Add New Dotfiles
1. Determine if the config is common or platform-specific
2. Add to appropriate directory:
   - Common: `common/shell/`
   - macOS: `macos/shell/` or `homedir/` (for macOS-only apps)
   - Linux: `linux/shell/`
3. Run `./install-unified.sh` to create symlinks

### Add New Packages

**macOS:**
1. Add to `Brewfile`
2. Run `brew bundle`

**Linux:**
1. Update the package list in `linux/install.sh`
2. Re-run the installer or install manually

## Security Note

The `.shellvars` file contains API keys and sensitive environment variables. This file should be secured appropriately and not committed with actual keys.

## Platform Support

### macOS
- Full feature support including Hammerspoon window management
- Homebrew package management
- macOS-specific shell configurations
- Tested on macOS 13+ (Ventura and later)

### Linux
- Shell configurations (Zsh, aliases, paths)
- Neovim setup
- Package management for major distributions:
  - Debian/Ubuntu (apt)
  - Arch/Manjaro (pacman)
  - Fedora/RHEL (yum/dnf)
- Essential development tools installation

## Customization

To customize for your own use:
1. Fork this repository
2. Update personal information in `.gitconfig`
3. Modify shell variables:
   - Common: `common/shell/.shellvars.common`
   - Platform-specific: `{macos,linux}/shell/.shellvars.{macos,linux}`
4. For macOS: Adjust Hammerspoon app shortcuts in `homedir/.hammerspoon/app-launcher.lua`
5. Update package lists:
   - macOS: Edit `Brewfile`
   - Linux: Edit `linux/install.sh`

## Troubleshooting

### Symlinks Not Working
Ensure the repository is cloned to `~/projects/dotfiles/`. The installer expects this exact path.

### Hammerspoon Not Loading
1. Check Console.app for error messages
2. Run `hs.reload()` in the Hammerspoon console
3. Verify all module files exist in `~/.hammerspoon/`

### Shell Configuration Not Loading
Verify that Zsh is the default shell:
```bash
echo $SHELL  # Should output /bin/zsh
chsh -s /bin/zsh  # Set as default if needed
```

## Requirements

### macOS
- macOS 13+ (Ventura or later)
- Command Line Tools for Xcode
- Git

### Linux
- A supported distribution (Debian/Ubuntu, Arch, Fedora, etc.)
- Git
- sudo access for package installation

## License

These dotfiles are available for reference and learning. Feel free to use any parts that are helpful for your own configuration.