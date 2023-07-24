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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

which nvm >/dev/null 2>&1
if (( $? != 0 )); then
    action "Installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    action "Installing and defaulting to latest LTS"
    latest=$(nvm version-remote --lts)
    nvm install $latest
    nvm use $latest
    nvm alias default $latest
fi

brew install mas

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

if [[ ! -d "./ohmyzsh/custom/plugins/git" ]]; then
    mkdir -p ./ohmyzsh/custom/plugins/git
    ln -s $HOME/projects/dotfiles/plugins/git.plugin.zsh ./ohmyzsh/custom/plugins/git/
fi

ok "Oh My ZSH is all setup"

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

if [[ -d ~/.config/nvim ]]; then
	if [ ! -d ~/.dotfiles_backup ]; then
		mkdir -p ~/.dotfiles_backup/$now
	fi
	mv ~/.config/nvim ~/.dotfiles_backup/$now/nvim
	unlink ~/.config/nvim > /dev/null 2>&1
fi
bot "symlinking neovim config"
ln -s ~/projects/dotfiles/homedir/nvim ~/.config/

popd > /dev/null 2>&1

if [[ -d ~/.config/phpactor ]]; then
	if [ ! -d ~/.dotfiles_backup ]; then
		mkdir -p ~/.dotfiles_backup/$now
	fi
	mv ~/.config/phpactor ~/.dotfiles_backup/$now/phpactor
	unlink ~/.config/phpactor > /dev/null 2>&1
fi
bot "symlinking phpactor config"
ln -s ~/projects/dotfiles/phpactor ~/.config/

bot "link scripts"
pushd scripts > /dev/null 2>&1
for file in *; do
    if [ ! -d $HOME/.local/bin ]; then
        mkdir -p $HOME/.local/bin
    fi
    if [[ $file == "." || $file == ".." ]]; then
    continue
    fi
    if [ -e $HOME/.local/bin/$file ]; then
        unlink $HOME/.local/bin/$file > /dev/null 2>&1
        rm $HOME/.local/bin/$file > /dev/null 2>&1
    fi
    ln -s $HOME/projects/dotfiles/scripts/$file $HOME/.local/bin/$file
done
popd > /dev/null 2>&1

bot "Installing additional tools via Brew"
brew bundle

bot "Woot! All done. Kill this terminal and launch iTerm.  You may also reboot to guarantee everything has updated."


