#!/usr/bin/env bash

echo "Install Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Install XCode command-line tools"
xcode-select --install

echo "Have ZSH? If not, install it"
which zsh > /dev/null 2>&1
if (( $? != 0 )); then
	brew install zsh
fi

echo "Set ZSH as default shell"
chsh -s $(which zsh)

echo "Create projects directory and clone dotfiles"
mkdir -p $HOME/projects
git clone https://github.com/djohnston08/dotfiles.git

echo "Please restart the terminal and run $HOME/projects/dotfiles/install.sh"
