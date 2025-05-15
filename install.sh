#!/bin/bash

#################################################################
# ychie/.dotfiles												#
#################################################################
# Installs essential required packages, when using new system.	#
#################################################################

# If not already set, specify dotfiles repo remote and local locations
DOTFILES_DIR="${DOTFILES_DIR}:-$HOME/Projects/.dotfiles"
DOTFILES_REP="${DOTFILES_REP}:-https://github.com/ychie/.dotfiles.git"

# List of packages to install
CORE_PACKAGES=(
	"git"
	"vim"
	"zsh"
)

#################################################################
# Terminal format												#
#################################################################

# Color variables
PURPLE='\033[0;35m'
YELLOW='\033[0;93m'
LIGHT='\x1b[2m'
RESET='\033[0m'

#################################################################
# MacOS helper functions										#
#################################################################

# Installs MacOS developer tool set and accepts user licanse agreement
function _install_mac_cli_tools () {
	echo -e "${PURPLE}Setting up xcode developer tools.${RESET}"
	
	if ! xcode-select --print-path &>/dev/null; then
		xcode-select --install >/dev/null 2>&1

		# Wait untill installation process is finished
		until xcode-select --print-path &>/dev/null; do
			sleep 5
		done

		# Path to Xcode if installed
		local x=$(find '/Applications' -maxdepth 1 -regex '.*/Xcode[^ ]*.app' -print -quit)

		# Accept license
		if [ e "$x" ]; then
			sudo xcode-select -s "$x"
			sudo xcodebuild -license accept
		fi
	fi

	echo -e "${GREEN}Xcode developer tools installed.${RESET}"
	sleep 2
}

function _install_homebrew () {
	echo -e "${PURPLE}Setting up Homebrew.${RESET}"

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  	export PATH=/opt/homebrew/bin:$PATH	

	echo -e "${GREEN}Homebrew installed.${RESET}"
	sleep 2
}

function _install_mac_package () {
	echo -e "${PURPLE}Installing ${1} via Homebew${RESET}"
	brew install $1
}

#################################################################
# Install														#
#################################################################

function _multi_system_install () {
	app=$1
	if [ "$(uname -s)" = "Darwin" ]; then
		if ! xcode-select --print-path &> /dev/null; then _install_mac_cli_tools; fi
		if ! hash brew 2> /dev/null; then _install_homebrew; fi
		_install_mac_package $app
	else
		echo -e "${YELLOW}Skipping ${app} installation, as not supported system type${RESET}"
	fi
}

function _install_core_packages () {
	for app in "${CORE_PACKAGES[@]}"; do
		if ! hash "${app}" 2> /dev/null; then
			_multi_system_install $app
		else
			echo -e "${YELLOW}${app} is already installed, skipping.${RESET}"
		fi
	done
}

#################################################################
# Install														#
#################################################################

_install_core_packages

