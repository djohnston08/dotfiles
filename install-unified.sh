#!/usr/bin/env bash

#################################
# Unified Dotfiles Installer
# Works on both macOS and Linux
#################################

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Source libraries
source ./lib_sh/echos.sh
source ./lib/platform.sh
source ./lib/common.sh

# Detect platform
OS=$(detect_os)
bot "Detected OS: $OS"

if [[ "$OS" == "unknown" ]]; then
    error "Unsupported operating system"
    exit 1
fi

# Run pre-installation checks
bot "Running pre-installation checks..."

# Ensure we're in the right directory
if [[ ! -d "$HOME/projects/dotfiles" ]]; then
    error "This installer expects to be run from ~/projects/dotfiles"
    error "Please clone the repository to that location and try again"
    exit 1
fi

# Platform-specific setup
if is_macos; then
    bot "Setting up macOS environment..."
    source ./macos/install.sh
elif is_linux; then
    bot "Setting up Linux environment..."
    source ./linux/install.sh
fi

# Common installations
bot "Installing common configurations..."

# Install common shell configurations
install_common_shell_configs

# Install Neovim configuration
install_neovim_config

# Install scripts
install_scripts

# Install Git configuration
install_git_config

# Setup Zsh
setup_zsh

# Setup Oh My Zsh custom plugins
setup_ohmyzsh_custom

# Platform-specific post-installation
if is_macos; then
    bot "Running macOS post-installation tasks..."
    macos_post_install
elif is_linux; then
    bot "Running Linux post-installation tasks..."
    linux_post_install
fi

bot "Installation complete! 🎉"
bot "Please restart your shell or run: exec zsh"