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

source $ZSH/oh-my-zsh.sh

source $HOME/.nvm/nvm.sh

source $HOME/projects/dotfiles/themes/headline.zsh-theme

source ~/.zprofile

# Customize to your needs...
unsetopt correct

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
