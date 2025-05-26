#!/bin/bash

######################################################################
# dejevin/dotfiles - All-in-One Install and Setup Script for Unix    #
######################################################################
# Fetches latest changes, symlinks files, and installs dependencies  #
# Then sets up ZSH, TMUX, NVim as well as OS-specific tools and apps #
# Checks all dependencies are met, and prompts to install if missing #
# For docs and more info, see: https://github.com/dejevin/dotfiles   #
#                                                                    #
# OPTIONS:                                                           #
#   --auto-yes: Skip all prompts, and auto-accept all changes        #
#   --no-clear: Don't clear the screen before running                #
#                                                                    #
# ENVIRONMENTAL VARIABLES:                                           #
#   DOTFILES_DIR: Where to save dotfiles to                          #
#   DOTFILES_REPO: Git repo to USE                                   #
#                                                                    #
# IMPORTANT: Before running, read through everything very carefully! #
######################################################################
# Licensed under MIT (C) Nazar Voitovych 2025                        #
######################################################################

######################################################################
# VARIABLES                                                          #
######################################################################

# Reference
SOURCE_DIR=$(dirname ${0})
CURRENT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
SYSTEM_TYPE=$(uname -s)
START_TIME=`date +%s`

# Prompt
PROMPT_TIMEOUT=15

# Directories
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Projects/dotfiles}"
DOTFILES_REP="${DOTFILES_REP:-https://github.com/ychie/dotfiles.git}"

# Colors
RED="\033[1;31m"
CYAN="\033[1;96m"
GREEN="\033[1;32m"
YELLOW="\033[1;93m"
PURPLE="\033[0;35m"
RESET="\033[0m"

######################################################################
# Print helpers                                                      #
######################################################################

function _print_banner () {
    local text=$1
    local color="${2:-$CYAN}"
    local padding="${3:-0}"
    local length=$(expr ${#text} + 4 + $padding);
        local line_char="-"

        local line=""
        for (( i = 0; i < "$length"; ++i )); do
            line="${line}${line_char}"
        done

        banner="${color}${line} \n| ${RESET}${text}${color} |\n${line}"
        echo -e "\n${banner}${RESET}"
    }

# Explain to the user what changes will be made
function _make_intro () {
    C2="\033[0;35m"
    C3="\x1b[2m"
    echo -e "${CYAN_B}The seup script will do the following:${RESET}\n"\
        "${C2}(1) Pre-Setup Tasls\n"\
        "  ${C3}- Check that all requirements are met, and system is compatible\n"\
        "  ${C3}- Sets environmental variables from params, or uses sensible defaults\n"\
        "  ${C3}- Output welcome message and summary of changes\n"\
        "${C2}(2) Setup Dotfiles\n"\
        "  ${C3}- Clone or update dotfiles from git\n"\
        "  ${C3}- Symlinks dotfiles to correct locations\n"\
        "${C2}(3) Install packages\n"\
        "  ${C3}- On MacOS, prompt to install Homebrew if not present\n"\
        "  ${C3}- On MacOS, updates and installs apps liseted in Brewfile\n"\
        "  ${C3}- Checks that OS is up-to-date and critical patches are installed\n"\
        "${C2}(4) Configure system\n"\
        "  ${C3}- Setup Vim, and install / update Vim plugins via Plug\n"\
        "  ${C3}- Setup Tmux, and install / update Tmux plugins via TPM\n"\
        "  ${C3}- Setup ZSH, and install / update ZSH plugins via Antigen\n"\
        "  ${C3}- Apply system settings (via NSDefaults on Mac)\n"\
        "  ${C3}- Apply assets, wallpaper, fonts, screensaver, etc\n"\
        "${C2}(5) Finishing Up\n"\
        "  ${C3}- Refresh current terminal session\n"\
        "  ${C3}- Exit with appropriate status code\n\n"\
        "${PURPLE}You will be prompted at each stage, before any changes are made.${RESET}\n"\
        "${PURPLE}For more info, see GitHub: \033[4;35mhttps://github.com/${REPO_NAME}${RESET}"
    }

######################################################################
# Terminate helpers                                                  #
######################################################################

function _terminate () {
    _show_banner "Installing failed. Terminating..."
    exit 1
}

function _cleanup () {
    unset PROMPT_TIMEOUT
    unset PROMPT_AUTO

    echo "Finished"
}    

######################################################################
# COMMAND HELPERS                                                    #
######################################################################

function _command_exist () {
    hash "$1" 2> /dev/null
}

function _command_ensure () {
    if ! _command_exist $1; then
        if $2; then
            echo -e "${RED}Error: $1 is not installed${RESET}"
            _terminate
        else
            echo -e "${YELLOW}Warning: $1 is not installed${RESET}"
        fi
    fi
}

######################################################################
# LINK HELPERS                                                       #
######################################################################

function _soft_link () {
    local target="$1"
    local source="$2"

    echo "Linking $target -> $source"
    mkdir -p "$(dirname "$target")"

    if [[ -f "$PWD/$source" || -d "$PWD/$source" ]]; then
        ln -sf "$PWD/$source" "$target"
    fi
}

######################################################################
# PRE SETUP                                                          #
######################################################################

function _pre_setup_tasks () {
    # Print intro, listing what changes will be applied
    _make_intro

    # Verify start
    echo -e "\n${CYAN}Would you like to continue? (y/N)${RESET}"
    read -t $PROMPT_TIMEOUT -n 1 -r ans
    if [[ ! $ans =~ ^[Yy]$ ]] && [[ $PROMPT_AUTO != true ]]; then
        echo -e "\n${PURPLE}Installation cancelled...${RESET}"
        _terminate
    fi
    echo

    # Verify required packages
    _command_ensure git true
    _command_ensure zsh false 
    _command_ensure vim false 
    _command_ensure nvim false 
    _command_ensure tmux false

    # Ensure XDG variables
    if [ -z ${XDG_CONFIG_HOME+x} ]; then
        echo -e "${YELLOW}XDG_CONFIG_HOME is not set. Will use ~/.config${RESET}"
        export XDG_CONFIG_HOME="${HOME}/.config"
    fi
    if [ -z ${XDG_DATA_HOME+x} ]; then
        echo -e "${YELLOW}XDG_DATA_HOME is not set. Will use ~/.local/share${RESET}"
        export XDG_DATA_HOME="${HOME}/.local/share"
    fi
}

######################################################################
# DOTFILES                                                           #
######################################################################

function _setup_dotfiles () {
    # Pull repo
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        echo -e "${RED}Error: dotfiles directory (${DOTFILES_DIR}) not present.${RESET}"
        _terminate
    else
        echo -e "${PURPLE}Pulling changes from ${DOTFILES_REP} into ${DOTFILES_DIR}${RESET}"
        cd "${DOTFILES_DIR}" && git pull origin main
    fi

    # Set up symlinks
    echo -e "${PURPLE}Setting up symlinks...${RESET}"
    cd "${DOTFILES_DIR}"

    echo -e "${PURPLE}Cleaning old config files...${RESET}"
    rm -rf "$HOME/.zshenv" "$XDG_CONFIG_HOME"

    echo -e "${PURPLE}Linking files...${RESET}"

    # Shell links
    _soft_link "$HOME/.zshenv" "config/zsh/.zshenv"
    _soft_link "$XDG_CONFIG_HOME/zsh" "config/zsh"
    _soft_link "$XDG_CONFIG_HOME/vim" "config/vim"
    _soft_link "$XDG_CONFIG_HOME/nvim" "config/nvim"
    _soft_link "$XDG_CONFIG_HOME/kitty" "config/kitty"
    _soft_link "$XDG_CONFIG_HOME/aerospace" "config/aerospace"

    # Tmux 
    _soft_link "$XDG_CONFIG_HOME/tmux" "config/tmux"

    # Bash
    _soft_link "$XDG_CONFIG_HOME/.bashrc" "config/general/.bashrc"

    # Git
    _soft_link "$HOME/.gitconfig" "config/general/.gitconfig"
    _soft_link "$XDG_CONFIG_HOME/.gitignore_global" "config/general/.gitignore_global"

    # MacOS
    if [ "${SYSTEM_TYPE}" = "Darwin" ]; then
        _soft_link "$HOME/.Brewfile" "scripts/installs/Brewfile"
    fi

    echo -e "${PURPLE}Creating directories...${RESET}"
    mkdir -p "$HOME/Projects"
    mkdir -p "$HOME/Downloads"
    mkdir -p "$HOME/Documents"
    mkdir -p "$HOME/Applications"
}

######################################################################
# Packages                                                           #
######################################################################

function _install_sbarlua () {
    if [[ ! -d "$XDG_DATA_HOME/sketchybar_lua" ]]; then
        echo -e "\n${CYAN}Would you like to install sketchybar lua helper? (y/N)${RESET}"
        read -t $PROMPT_TIMEOUT -n 1 -r ans_sketchybar
        if [[ $ans_sketchybar =~ ^[Yy]$ ]] || [[ $PROMPT_AUTO = true ]]; then
            (
                git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && \
                    cd /tmp/SbarLua/ &&                                                 \
                    make install &&                                                     \
                    rm -rf /tmp/SbarLua/
                )
        fi
    fi
}

function _install_codelldb () {
    if [[ ! -d "$XDG_DATA_HOME/codelldb" ]]; then
        echo -e "\n${CYAN}Would you like to install Codelldb? (y/N)${RESET}"
        read -t $PROMPT_TIMEOUT -n 1 -r ans_codelldb
        if [[ $ans_codelldb =~ ^[Yy]$ ]] || [[ $PROMPT_AUTO = true ]]; then
            if [ "${SYSTEM_TYPE}" = "Darwin" ]; then
                curl --create-dirs -O -L --output-dir /tmp/codelldb                                                 \
                    "https://github.com/vadimcn/codelldb/releases/download/v1.10.0/codelldb-aarch64-darwin.vsix" && \
                    unzip /tmp/codelldb/codelldb-aarch64-darwin.vsix -d $XDG_DATA_HOME/codelldb
                rm -rf /tmp/codelldb
            else
                echo -e "${PURPLE}Skipping Codelldb installation as requirements are not met${RESET}"
            fi
        fi
    fi
}

function _install_macos_packages () {
    if ! _command_exist brew; then
        echo -e "\n${CYAN}Would you like to install Homebrew? (y/N)${RESET}"
        read -t $PROMPT_TIMEOUT -n 1 -r ans_homebrewins
        if [[ $ans_homebrewins =~ ^[Yy]$ ]] || [[ $PROMPT_AUTO = true ]]; then
            echo -en "🍺 ${PURPLE}Installing Homebrew...${RESET}\n"
            brew_url='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
            /bin/bash -c "$(curl -fsSL $brew_url)"
            export PATH=/opt/homebrew/bin:$PATH
        fi
    fi

    if _command_exist brew && [ -f "${DOTFILES_DIR}/scripts/installs/Brewfile" ]; then
        echo -e "${PURPLE}Updating homebrew and packages...${RESET}"
        brew update
        brew upgrade
        brew bundle --global --file $HOME/.Brewfile
        brew cleanup
        killall Finder
    else
        echo -e "${PURPLE}Skipping Homebrew as requirements are not met${RESET}"
    fi

    if _command_exist sketchybar; then
        _install_sbarlua
        brew services restart sketchybar
    fi
}

function _install_packages () {
    echo -e "\n${CYAN}Would you like to install system packages? (y/N)${RESET}"
    read -t $PROMPT_TIMEOUT -n 1 -r ans
    echo

    if [[ ! $ans =~ ^[Yy]$ ]] && [[ $PROMPT_AUTO != true ]]; then
        echo -e "\n${PURPLE}Skipping packages installs${RESET}"
        return
    fi

    if [ "${SYSTEM_TYPE}" = "Darwin" ]; then
        _install_codelldb
        _install_macos_packages
    fi
}

function _apply_preferences () {
    # If ZSH not the default shell, ask user if they'd like to set it
    if [[ $SHELL != *"zsh"* ]] && _command_exists zsh; then
        echo -e "\n${CYAN}Would you like to set ZSH as your default shell? (y/N)${RESET}"
        read -t $PROMPT_TIMEOUT -n 1 -r ans_zsh
        if [[ $ans_zsh =~ ^[Yy]$ ]] || [[ $PROMPT_AUTO = true ]] ; then
            echo -e "${PURPLE}Setting ZSH as default shell${RESET}"
            chsh -s $(which zsh) $USER
        fi
    fi

    # Apply general system, app and OS security preferences (prompt user first)
    echo -e "\n${CYAN}Would you like to apply system preferences? (y/N)${RESET}"
    read -t $PROMPT_TIMEOUT -n 1 -r ans_syspref
    echo
    if [[ $ans_syspref =~ ^[Yy]$ ]] || [[ $PROMPT_AUTO = true ]]; then
        if [ "$SYSTEM_TYPE" = "Darwin" ]; then
            echo -e "\n${PURPLE}Applying MacOS system preferences, ensure you've understood before proceeding${RESET}\n"
            macos_settings_dir="$DOTFILES_DIR/scripts/macos"
            chmod +x "$macos_settings_dir/preferences.sh" && \
                "$macos_settings_dir/preferences.sh" --quick-exit --yes-to-all
        fi
    fi
}

######################################################################
# FINISH UP                                                          #
######################################################################

function _finish_up () {
    # Update source to ZSH entry point
    source "${HOME}/.zshenv"

    # Show press any key to exit
    echo -e "${CYAN}Press any key to exit.${RESET}\n"
    read -t $PROMPT_TIMEOUT -n 1 -s

    # Bye
    exit 0
}

######################################################################
# MAIN                                                               #
######################################################################

# Clear screen
if [[ ! $* == *"--no-clear"* ]] && [[ ! $* == *"--help"* ]]; then
    clear
fi

# Auto prompts
if [[ $* == *"--auto-yes"* ]]; then
    PROMPT_TIMEOUT=1
    PROMPT_AUTO=true
fi

# Cleanup on exit
trap _cleanup EXIT

# Tasks
_pre_setup_tasks
_setup_dotfiles
_install_packages
_apply_preferences
_finish_up
