#!/usr/bin/env bash

#################################
# @author David Johnston
# Using echos.sh library from Adam Eivy
#################################

source ./lib_sh/echos.sh

bot "Hi! I'm going to setup your shell settings..."

which brew >/dev/null 2>&1
if (( $? != 0 )); then
    action "Installing homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

which nvm >/dev/null 2>&1
if (( $? != 0 )); then
    action "Installing nvm"
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
    action "Installing and defaulting to latest LTS"
    latest=$(nvm version-remote --lts)
    nvm install $latest
    nvm use $latest
    nvm alias default $latest
fi

CURRENTSHELL=$SHELL
if [[ "$CURRENTSHELL" =~ "bash" ]]; then
    action "We have bash...setting up zsh"
    which zsh > /dev/null 2>&1
    if (( $? != 0 )); then
        brew install zsh
    fi
    chsh -s $(which zsh)
    ok
elif [[ "$CURRENTSHELL" =~ "zsh" ]]; then
    ok "We have zsh...moving on"
else
    error "I don't know this shell: ${CURRENTSHELL}"
fi

bot "Going to now install oh-my-zsh and a custom git plugin"
if [[ ! -d "./oh-my-zsh" ]]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git ./oh-my-zsh
fi

if [[ ! -d "./oh-my-zsh/custom/plugins/git" ]]; then
    mkdir -p ./oh-my-zsh/custom/plugins/git
    cp ./plugins/git.plugin.zsh ./oh-my-zsh/custom/plugins/git/
fi

if [[ ! -d "./oh-my-zsh/custom/themes/powerlevel9k" ]]; then
  git clone https://github.com/bhilburn/powerlevel9k.git oh-my-zsh/custom/themes/powerlevel9k
fi

ok "Oh My ZSH is all setup"

bot "Install z-zsh"
if [[ ! -d "./z-zsh" ]]; then
  git clone https://github.com/sjl/z-zsh.git
fi

bot "creating symlinks for project dotfiles..."
pushd homedir > /dev/null 2>&1
now=$(date +"%Y.%m.%d.%H.%M.%S")

for file in .*; do
  if [[ $file == "." || $file == ".." ]]; then
    continue
  fi
  running "~/$file"
  # if the file exists:
  if [[ -e ~/$file ]]; then
      mkdir -p ~/.dotfiles_backup/$now
      mv ~/$file ~/.dotfiles_backup/$now/$file
      echo "backup saved as ~/.dotfiles_backup/$now/$file"
  fi
  # symlink might still exist
  unlink ~/$file > /dev/null 2>&1
  # create the link
  ln -s ~/projects/dotfiles/homedir/$file ~/$file
  echo -en '\tlinked';ok
done

popd > /dev/null 2>&1

bot "Woot! All done. Kill this terminal and launch iTerm.  You may also reboot to guarantee everything has updated."


