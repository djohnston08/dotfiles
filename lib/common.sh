#!/usr/bin/env bash

#################################
# Common Installation Functions
# Shared utilities for both Mac and Linux
#################################

source ./lib_sh/echos.sh
source ./lib/platform.sh

# Create backup of existing file/directory
backup_if_exists() {
    local file="$1"
    local now=$(date +"%Y.%m.%d.%H.%M.%S")
    
    if [[ -e "$file" ]]; then
        local backup_dir="$HOME/.dotfiles_backup/$now"
        mkdir -p "$backup_dir"
        mv "$file" "$backup_dir/"
        echo "backup saved as $backup_dir/$(basename "$file")"
    fi
}

# Create symlink with backup
safe_symlink() {
    local source="$1"
    local target="$2"
    
    # Backup existing file/directory
    backup_if_exists "$target"
    
    # Remove any existing symlink
    if [[ -L "$target" ]]; then
        unlink "$target" >/dev/null 2>&1
    fi
    
    # Create the symlink
    ln -s "$source" "$target"
    ok "linked $target → $source"
}

# Initialize git submodules (oh-my-zsh, etc.)
init_submodules() {
    bot "Initializing git submodules..."

    if [[ -f ".gitmodules" ]]; then
        git submodule update --init --recursive
        ok "Submodules initialized"
    fi
}

# Install all dotfiles from homedir/
install_homedir_dotfiles() {
    bot "Creating symlinks for dotfiles..."

    pushd homedir > /dev/null 2>&1

    for file in .*; do
        if [[ $file == "." || $file == ".." ]]; then
            continue
        fi
        # Skip nvim directory (handled separately)
        if [[ $file == "nvim" ]]; then
            continue
        fi
        running "~/$file"
        safe_symlink "$HOME/projects/dotfiles/homedir/$file" "$HOME/$file"
    done

    popd > /dev/null 2>&1
}

# Install Neovim configuration
install_neovim_config() {
    bot "Installing Neovim configuration..."
    
    # Ensure config directory exists
    mkdir -p "$HOME/.config"
    
    # Symlink nvim config
    if [[ -d "homedir/nvim" ]]; then
        running "~/.config/nvim"
        safe_symlink "$HOME/projects/dotfiles/homedir/nvim" "$HOME/.config/nvim"
    fi
}

# Install scripts
install_scripts() {
    bot "Installing utility scripts..."
    
    # Ensure bin directory exists
    mkdir -p "$HOME/.local/bin"
    
    # Link all scripts
    for script in scripts/*; do
        if [[ -f "$script" ]]; then
            local script_name=$(basename "$script")
            running "~/.local/bin/$script_name"
            safe_symlink "$HOME/projects/dotfiles/$script" "$HOME/.local/bin/$script_name"
        fi
    done
}

# Setup Zsh if not already the default shell
setup_zsh() {
    local current_shell="$SHELL"
    
    if [[ ! "$current_shell" =~ "zsh" ]]; then
        bot "Setting up Zsh as default shell..."
        
        # Check if zsh is installed
        if ! command_exists zsh; then
            return 1  # Let platform-specific installer handle installation
        fi
        
        # Change default shell
        chsh -s "$(which zsh)"
        ok "Zsh set as default shell"
    else
        ok "Zsh is already the default shell"
    fi
}

# Setup Oh My Zsh custom plugins
setup_ohmyzsh_custom() {
    bot "Setting up Oh My Zsh custom plugins..."
    
    # Git plugin
    if [[ ! -d "./ohmyzsh/custom/plugins/git" ]]; then
        mkdir -p ./ohmyzsh/custom/plugins/git
        ln -s "$HOME/projects/dotfiles/plugins/git/git.plugin.zsh" ./ohmyzsh/custom/plugins/git/
        ok "Git plugin linked"
    fi
    
    # Custom theme
    if [[ ! -d "./ohmyzsh/custom/themes" ]]; then
        mkdir -p ./ohmyzsh/custom/themes
        ln -s "$HOME/projects/dotfiles/themes/headline.zsh-theme" ./ohmyzsh/custom/themes/
        ok "Headline theme linked"
    fi
}

# Install Git configuration
install_git_config() {
    bot "Installing Git configuration..."
    
    if [[ -f "homedir/.gitconfig" ]]; then
        running "~/.gitconfig"
        safe_symlink "$HOME/projects/dotfiles/homedir/.gitconfig" "$HOME/.gitconfig"
    fi
    
    if [[ -f "homedir/.gitignore_global" ]]; then
        running "~/.gitignore_global"
        safe_symlink "$HOME/projects/dotfiles/homedir/.gitignore_global" "$HOME/.gitignore_global"
    fi
}