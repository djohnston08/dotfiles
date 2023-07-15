#!/usr/bin/env bash

echo "Install Homebrew if it doesn't exist"
which brew > /dev/null 2>&1
if (( $? != 0 )); then
	echo "No brew... Install Homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "If we do not have git, let's insteall Xcode cli tools"
which git > /dev/null 2>&1
if (( $? != 0 )); then
	echo "Installing XCode command-line tools"
	xcode-select --install
fi

echo "Have ZSH? If not, install it"
which zsh > /dev/null 2>&1
if (( $? != 0 )); then
	brew install zsh
fi

echo "If shell is not zsh, set it as default"
if [[ "$SHELL" != *"zsh"* ]]; then
	echo "Setting ZSH as default shell"
	chsh -s $(which zsh)
fi

if [[ ! -d $HOME/projects/dotfiles ]]; then
	echo "Create projects directory and clone dotfiles"
	mkdir -p $HOME/projects
	git clone https://github.com/djohnston08/dotfiles.git
fi

echo "Please restart the terminal and run $HOME/projects/dotfiles/install.sh"
