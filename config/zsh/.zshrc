# ~/.zshrc
# Shell configuration for interactive sessions
# Loads aliases, functions, and customizations for interactive use
# Assumes core environment variables have already been set in ~/.zshenv

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# MacOS specific services
if [ "$(uname -s)" = "Darwin" ]; then
    # Add Brew to path, if it's installed
    if [[ -d /opt/homebrew/bin ]]; then
        export PATH="$PATH:/opt/homebrew/bin"
        export PATH="$PATH:/opt/homebrew/sbin"
    fi
fi

# Append Cargo to path, if it's installed
if [[ -d "$HOME/.cargo/bin" ]]; then
    export PATH="$PATH:$HOME/.cargo/bin"
fi
