# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive dotfiles repository for macOS development environments. It includes shell configurations (Zsh with Oh My Zsh), editor settings (Neovim), and various development tools.

## Common Commands

### Installation and Setup
```bash
# Full installation (symlinks all dotfiles, installs packages)
./install.sh

# Install/update Homebrew packages
brew bundle

# Update Oh My Zsh
cd ohmyzsh && git pull
```

### Adding New Configurations
- Add dotfiles to `homedir/` directory (they will be symlinked to ~/)
- Add scripts to `scripts/` directory (they will be symlinked to ~/.local/bin/)
- Add Homebrew packages to `Brewfile`
- Run `./install.sh` to apply changes

## Architecture and Key Components

### Directory Structure
- `homedir/`: Contains all dotfiles that get symlinked to home directory
  - `.zshrc`: Main Zsh configuration, sources Oh My Zsh and custom theme
  - `.profile`: Sources shell variables, functions, paths, and aliases
  - `.shellvars`: Environment variables including API keys (security concern)
  - `nvim/`: Modern Neovim configuration using Lua with Lazy.nvim
- `ohmyzsh/`: Full Oh My Zsh installation (not a submodule)
- `scripts/`: Utility scripts (tmux-sessionizer, dn, psg)
- `themes/`: Custom "headline" Zsh theme
- `plugins/`: Custom git plugin with extended aliases

### Installation Process (install.sh)
1. Installs prerequisites: Homebrew, nvm, Node.js LTS
2. Ensures Zsh is the default shell
3. Backs up existing dotfiles to `~/.dotfiles_backup/[timestamp]/`
4. Creates symlinks from `homedir/*` to `~/*`
5. Special handling for Neovim (symlinks to `~/.config/nvim`)
6. Links scripts to `~/.local/bin/`
7. Runs `brew bundle` to install all packages

### Shell Configuration Flow
1. `.zshrc` → sources Oh My Zsh, nvm, custom theme, and `.zprofile`
2. `.zprofile` → sources `.profile` and sets up Python/Homebrew paths
3. `.profile` → sources `.shellvars`, `.shellfn`, `.shellpaths`, `.shellaliases`

### Important Notes
- The repository expects to be cloned to `~/projects/dotfiles/`
- Backup strategy: Old configs are moved to `~/.dotfiles_backup/[timestamp]/`
- The `.shellvars` file contains API keys that should be secured
- Custom git plugin provides extensive git aliases and functions