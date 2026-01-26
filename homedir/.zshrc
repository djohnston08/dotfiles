export TERM="xterm-256color"

# Path to your oh-my-zsh configuration.
export ZSH=$HOME/projects/dotfiles/ohmyzsh

# Set to this to use case-sensitive completion
export CASE_SENSITIVE="true"

# disable autosetting terminal title.
export DISABLE_AUTO_TITLE="true"

# Add to your shell config (zsh/bashrc)
if [[ -f "$HOME/projects/dotfiles/.env" ]]; then
    set -a
    source "$HOME/projects/dotfiles/.env"
    set +a
fi

plugins=(git)

# Source oh-my-zsh if available
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Source nvm if installed
[[ -s "$HOME/.nvm/nvm.sh" ]] && source "$HOME/.nvm/nvm.sh"

# Source theme
[[ -f "$HOME/projects/dotfiles/themes/headline.zsh-theme" ]] && source "$HOME/projects/dotfiles/themes/headline.zsh-theme"

source ~/.zprofile

# Customize to your needs...
unsetopt correct

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# gag alias and completion (added by gag-install.sh)
if [[ -f "$HOME/projects/gag/gag" ]]; then
    alias gag="$HOME/projects/gag/gag"
    # Enable bash completion compatibility for zsh
    autoload -U +X bashcompinit && bashcompinit
    [[ -f "$HOME/projects/gag/gag-completion.bash" ]] && source "$HOME/projects/gag/gag-completion.bash"
fi
