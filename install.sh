#!/usr/bin/env bash

 getOS() {
	local type=""
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		type="linux"
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		type="mac"
	fi
	echo -n "$type"
}

hasMacFundamentals() {
	which brew >/dev/null 2>&1
}

installMacFundamentals() {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/djohnston08/dotfiles/main/install-mac-fundamentals.sh)"
}

setupMac() {
	hasMacFundamentals
	if (( $? != 0)) {
		installMacFundamentals
		return 0
	}
}

 main() {
	os="$(getOS)"
	
	if [[ "X$os" == "Xmac" ]]; then
		setupMac
	elif [[ "X$os" == "Xlinux" ]]; then
		# do something
	fi
}

main
