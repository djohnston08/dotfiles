#!/usr/bin/env bash

#################################
# macOS-specific Installation
#################################

# Check for Homebrew
which brew >/dev/null 2>&1
if (( $? != 0 )); then
    action "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Install mas (Mac App Store CLI)
brew install mas

# Check for nvm
which nvm >/dev/null 2>&1
if (( $? != 0 )); then
    action "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    
    # Load nvm for this session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    action "Installing and defaulting to latest LTS..."
    nvm install --lts
    nvm use --lts
    nvm alias default node
fi

# Install macOS-specific dotfiles
install_macos_dotfiles() {
    bot "Installing macOS-specific configurations..."
    
    # Hammerspoon
    if [[ -d "homedir/.hammerspoon" ]]; then
        running "~/.hammerspoon"
        safe_symlink "$HOME/projects/dotfiles/homedir/.hammerspoon" "$HOME/.hammerspoon"
    fi
    
    # Karabiner
    if [[ -d "homedir/.config/karabiner" ]]; then
        mkdir -p "$HOME/.config"
        running "~/.config/karabiner"
        safe_symlink "$HOME/projects/dotfiles/homedir/.config/karabiner" "$HOME/.config/karabiner"
    fi
}

# macOS post-installation tasks
macos_post_install() {
    # Install macOS-specific dotfiles
    install_macos_dotfiles
    
    # Install Homebrew packages
    if [[ -f "Brewfile" ]]; then
        bot "Installing Homebrew packages..."
        brew bundle
    fi
    
    # Set macOS defaults (optional)
    if [[ -f "macos/set-defaults.sh" ]]; then
        bot "Setting macOS defaults..."
        source ./macos/set-defaults.sh
    fi
}