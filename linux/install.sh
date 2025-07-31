#!/usr/bin/env bash

#################################
# Linux-specific Installation
#################################

# Detect Linux distribution and package manager
DISTRO=$(detect_linux_distro)
PKG_MANAGER=$(get_package_manager)

bot "Detected Linux distribution: $DISTRO"
bot "Package manager: $PKG_MANAGER"

# Install essential packages based on package manager
install_linux_essentials() {
    bot "Installing essential packages..."
    
    case "$PKG_MANAGER" in
        apt)
            sudo apt update
            sudo apt install -y \
                curl \
                git \
                zsh \
                neovim \
                tmux \
                ripgrep \
                fd-find \
                build-essential \
                python3-pip
            ;;
        yum)
            sudo yum update -y
            sudo yum install -y \
                curl \
                git \
                zsh \
                neovim \
                tmux \
                ripgrep \
                fd-find \
                gcc \
                gcc-c++ \
                make \
                python3-pip
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm \
                curl \
                git \
                zsh \
                neovim \
                tmux \
                ripgrep \
                fd \
                base-devel \
                python-pip
            ;;
        *)
            error "Unsupported package manager: $PKG_MANAGER"
            error "Please install the following packages manually:"
            error "curl, git, zsh, neovim, tmux, ripgrep, fd, build tools, python3-pip"
            ;;
    esac
}

# Install Node.js via nvm
install_nodejs() {
    if ! command_exists nvm; then
        bot "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
        
        # Load nvm for this session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        bot "Installing Node.js LTS..."
        nvm install --lts
        nvm use --lts
        nvm alias default node
    else
        ok "nvm is already installed"
    fi
}

# Install Linux-specific tools
install_linux_tools() {
    bot "Installing additional Linux tools..."
    
    # Install fzf (fuzzy finder)
    if ! command_exists fzf; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all --no-bash --no-fish
    fi
    
    # Install Go (if not present)
    if ! command_exists go; then
        bot "Installing Go..."
        GO_VERSION="1.21.5"
        wget -O /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
    fi
}

# Linux post-installation tasks
linux_post_install() {
    # Install essential packages
    install_linux_essentials
    
    # Install Node.js
    install_nodejs
    
    # Install additional tools
    install_linux_tools
    
    # Create common directories
    mkdir -p "$HOME/projects"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/tmp"
    
    ok "Linux setup complete!"
}