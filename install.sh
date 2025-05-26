#!/bin/bash

#################################################################
# ychie/dotfiles                                                #
#################################################################
# Installs essential required packages, when using new system.  #
# If packages installed makes sure that dotfiles repository     #
# is clonned and runs setup.sh script if all requirements are   #
# met.                                                          #
#                                                               #
# OPTIONS:                                                      #
#       --help: prints script usage                             #
#       --auto-yes: skips all prompts                           #
# VARIABLES:                                                    #
#       DOTFILES_DIR: local dotfiles destination directory      #
#       DOTFILES_REP: remote dotfiles source repo               #
#################################################################

# If not already set, specify dotfiles repo remote and local locations
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Projects/dotfiles}"
DOTFILES_REP="${DOTFILES_REP:-https://github.com/ychie/dotfiles.git}"

# List of packages to install
CORE_PACKAGES=(
    "git"
    "vim"
    "zsh"
)

#################################################################
# Terminal Format                                               #
#################################################################

# Color variables
PURPLE='\033[0;35m'
YELLOW='\033[0;93m'
RESET='\033[0m'

#################################################################
# MacOS Helpers                                                 #
#################################################################

# installs macos developer tool set and accepts user licanse agreement
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

# Install homebrew
function _install_homebrew () {
    echo -e "${PURPLE}Setting up Homebrew.${RESET}"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    export PATH=/opt/homebrew/bin:$PATH     

    echo -e "${GREEN}Homebrew installed.${RESET}"
    sleep 2
}

# Install package with homebrew
function _install_mac_package () {
    echo -e "${PURPLE}Installing ${1} via Homebew${RESET}"
    brew install $1
}

#################################################################
# Install                                                       #
#################################################################

# Prints script usage
function _print_usage () {
    echo -e "${PURPLE}Prerequiset dependency installation\n"\
        "There's a few packages that are needed in order to continue with setting up dotfiles.\n"\
        "This script will detect distro and use appropriate package manager to install apps.\n"\
        "Elavated permissions may be required. Ensure you've read the script before proceeding."\
        "\n${RESET}"
    }

# Install packages with system specific manager
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

# Install required core packages
function _install_core_packages () {
    for app in "${CORE_PACKAGES[@]}"; do
        if ! hash "${app}" 2> /dev/null; then
            _multi_system_install $app
        else
            echo -e "${YELLOW}${app} is already installed, skipping.${RESET}"
        fi
    done
}

# If dotfiles not present, clone remote repo
function _clone_dotfiles_repo () {
    if [[ ! -d "${DOTFILES_DIR}" ]]; then
        mkdir -p "${DOTFILES_DIR}" && \
            git clone --recursive "${DOTFILES_REP}" "${DOTFILES_DIR}"
    fi
}

#################################################################
# Main                                                          #
#################################################################

_print_usage
if [[ $* == *"--help"* ]]; then exit; fi

if [[ ! $* == *"--auto-yes"* ]]; then
    echo -e "${PURPLE}Are you sure you want to preceed? (y/n)${RESET}"
    read -t 15 -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy] ]]; then
        echo -e "${YELLOW}Proceeding was rejected by user, exiting...${RESET}"
        exit 0
    fi
fi

_install_core_packages
_clone_dotfiles_repo

cd "${DOTFILES_DIR}" &&     \
    chmod +x ./setup.sh &&  \
    ./setup.sh --no-clear
