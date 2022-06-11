export TERM="xterm-256color"

# Path to your oh-my-zsh configuration.
export ZSH=$HOME/projects/dotfiles/oh-my-zsh
# if you want to use this, change your non-ascii font to Droid Sans Mono for Awesome
# POWERLEVEL9K_MODE='awesome'
# export ZSH_THEME="powerlevel9k/powerlevel9k"
# POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
# https://github.com/bhilburn/powerlevel9k#customizing-prompt-segments
# https://github.com/bhilburn/powerlevel9k/wiki/Stylizing-Your-Prompt
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(battery)
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir vcs)
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status php_version node_version vi_mode battery)
# colorcode test
# for code ({000..255}) print -P -- "$code: %F{$code}This is how your text would look like%f"
# POWERLEVEL9K_NVM_FOREGROUND='015'
# POWERLEVEL9K_NVM_BACKGROUND='072'
# POWERLEVEL9K_SHOW_CHANGESET=true
# POWERLEVEL9K_PROMPT_ON_NEWLINE=true
#export ZSH_THEME="random"

# Set to this to use case-sensitive completion
export CASE_SENSITIVE="true"

# disable autosetting terminal title.
export DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.dotfiles/oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(colorize compleat dirpersist autojump git history cp kubectl)

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

source $HOME/projects/dotfiles-new/headline.zsh-theme

cdpath=($HOME/projects $GOPATH/src)
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

