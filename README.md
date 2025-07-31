# Dotfiles

Personal dotfiles for macOS development environment with Zsh, Neovim, and Hammerspoon configurations optimized for the ZSA Voyager keyboard.

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

# Run the installer
cd ~/projects/dotfiles
./install.sh
```

The installer will:
1. Install prerequisites (Homebrew, nvm, Node.js LTS)
2. Set Zsh as the default shell
3. Backup existing dotfiles to `~/.dotfiles_backup/[timestamp]/`
4. Create symlinks from `homedir/*` to `~/*`
5. Install all Homebrew packages from the Brewfile

## Directory Structure

```
dotfiles/
├── homedir/          # All dotfiles that get symlinked to ~/
│   ├── .zshrc        # Main Zsh configuration
│   ├── .profile      # Shell variables, functions, paths, aliases
│   ├── .shellvars    # Environment variables (contains API keys)
│   ├── .hammerspoon/ # Window management configuration
│   └── nvim/         # Neovim configuration
├── ohmyzsh/          # Full Oh My Zsh installation
├── scripts/          # Utility scripts (linked to ~/.local/bin/)
├── themes/           # Custom "headline" Zsh theme
├── plugins/          # Custom git plugin
├── Brewfile          # Homebrew package definitions
├── install.sh        # Installation script
└── CLAUDE.md         # AI coding assistant instructions
```

## Key Features

### Shell Configuration

The shell configuration follows this loading order:
1. `.zshrc` → Sources Oh My Zsh, nvm, custom theme, and `.zprofile`
2. `.zprofile` → Sources `.profile` and sets up Python/Homebrew paths
3. `.profile` → Sources `.shellvars`, `.shellfn`, `.shellpaths`, `.shellaliases`

### Neovim Setup

Modern Neovim configuration using:
- Lua-based configuration
- Lazy.nvim for plugin management
- LSP support for multiple languages
- Custom keymaps and themes

### Hammerspoon Window Management

Modular Hammerspoon configuration with:
- Portrait monitor detection and layouts
- Application launcher hotkeys
- Advanced window positioning
- Spotify controls and auto-positioning

See [Hammerspoon Key Reference](#hammerspoon-key-reference) below for all keyboard shortcuts.

## Hammerspoon Key Reference

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
- `Hyper + 6` → Productivity layout (Spotify, Linear, Slack)
- `Hyper + 5` → Monitoring layout (Activity Monitor, Console)
- `Hyper + 4` → Communication layout (Slack, Messages, Discord)

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

### Update Homebrew Packages
```bash
brew bundle
```

### Update Oh My Zsh
```bash
cd ~/projects/dotfiles/ohmyzsh && git pull
```

### Add New Dotfiles
1. Add the file to `homedir/` directory
2. Run `./install.sh` to create symlinks

### Add New Homebrew Packages
1. Add to `Brewfile`
2. Run `brew bundle`

## Security Note

The `.shellvars` file contains API keys and sensitive environment variables. This file should be secured appropriately and not committed with actual keys.

## Customization

To customize for your own use:
1. Fork this repository
2. Update personal information in `.gitconfig`
3. Modify `.shellvars` with your own API keys
4. Adjust Hammerspoon app shortcuts in `homedir/.hammerspoon/app-launcher.lua`
5. Update the Brewfile with your preferred packages

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

## License

These dotfiles are available for reference and learning. Feel free to use any parts that are helpful for your own configuration.