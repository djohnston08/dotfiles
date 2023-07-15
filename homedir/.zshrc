export TERM="xterm-256color"

# Path to your oh-my-zsh configuration.
export ZSH=$HOME/projects/dotfiles/oh-my-zsh
export ZSH_THEME="steeef"

# Set to this to use case-sensitive completion
export CASE_SENSITIVE="true"

# disable autosetting terminal title.
export DISABLE_AUTO_TITLE="true"

plugins=(colorize compleat dirpersist autojump git history cp kubectl wakatime)

source $ZSH/oh-my-zsh.sh

source $HOME/.nvm/nvm.sh

source ~/.zprofile

if [ -d ~/local_configs ]; then
    for local_config in $(find ~/local_configs -type f -iname "*.zsh"); do
        source $local_config
    done
fi

autoload -U add-zsh-hook
load-nvmrc() {
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    nvm use &> /dev/null
  elif [[ $(nvm version) != $(nvm version default)  ]]; then
    nvm use default &> /dev/null
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Customize to your needs...
unsetopt correct

# run fortune on new terminal :)
fortune

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/djohnston/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/djohnston/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/djohnston/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/djohnston/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<



# Load Angular CLI autocompletion.
# source <(ng completion script)
