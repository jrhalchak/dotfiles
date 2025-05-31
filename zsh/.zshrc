# For a nice loading-time output (see end of file)
# zmodload zsh/zprof

# Enable Vim mode in ZSH
bindkey -v
# Reduce the timeout between switching modes (from 0.4s to 0.1s)
export KEYTIMEOUT=1

# Change cursor shape for different vi modes - Kitty compatible
# Block cursor for normal mode, line cursor for insert mode
cursor_mode() {
    # Cursor shapes: 0=block, 1=beam, 2=underline
    # Different terminals use different escape sequences
    cursor_block='\e[1 q' # Block cursor
    cursor_beam='\e[5 q'  # Beam cursor

    # For Kitty terminal specifically
    kitty_block='\e]50;CursorShape=0\x7'
    kitty_beam='\e]50;CursorShape=1\x7'

    function zle-keymap-select {
        if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
            echo -ne $kitty_block
        elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
            echo -ne $cursor_beam
            echo -ne $kitty_beam
        fi
    }

    zle -N zle-keymap-select

    # Initialize cursor shape for new prompts
    function zle-line-init {
        echo -ne $cursor_beam
        echo -ne $kitty_beam
    }
    zle -N zle-line-init

    # Ensure beam cursor when starting the shell
    function precmd {
        echo -ne $cursor_beam
        echo -ne $kitty_beam
    }

    # Ensure beam cursor for each new prompt
    function preexec {
        echo -ne $cursor_beam
        echo -ne $kitty_beam
    }
}

# Initialize the cursor mode
cursor_mode

# Source private configs if it exists
if [ -f ~/dotfiles/zsh/private.sh ]; then
  source ~/dotfiles/zsh/private.sh
elif [ -f ~/private.sh ]; then
  source ~/private.sh
fi

export GIT_EDITOR=nvim

# Aliases
alias vi="nvim"
alias vim="vi"

alias ctags='/usr/local/bin/ctags'
alias vidc="nvim -u \"NONE\""

# alias neorg="nvim -u ~/neorg/.config/init.lua"
alias neorg="NVIM_APPNAME=neorg nvim"
alias nvorg="cd ~/orgfiles && NVIM_APPNAME=nvorg nvim"

alias gg="git log --graph --abbrev-commit --decorate --oneline"

# TODO: This requires `source-highlight`
# You can get it via brew on MacOS (`brew install source-highlight`)
# Or apt on Deb-based distro if you have the software source
# (`sudo apt install source-highlight`)
LESSPIPE=`which src-hilite-lesspipe.sh`
export LESSOPEN="| ${LESSPIPE} %s"
# Default args
# -R is needed for coloring, so leave that.
# -X will leave the text in your Terminal, so it doesn’t disappear when you exit less.
# -F will exit less if the output fits on one screen (so you don’t have to press “q”).
export LESS=' -R -X -F '

# `source-highlight` (any version) doesn't currently support markdown so
# add `glow` with `brew install glow` or `sudo snap install glow` or
# # Debian/Ubuntu
# sudo mkdir -p /etc/apt/keyrings
# curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
# echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
# sudo apt update && sudo apt install glow

# not desired for workflow of controlling terminal title.
DISABLE_AUTO_TITLE="true"

function stt() {
  echo -en "\e]2;$@\a"
}

# Helpers so I remember basic worktree commands, lol
source ~/dotfiles/zsh/worktree-helpers.sh

# Mac-specific configurations
if [[ "$(uname)" == "Darwin" ]]; then
  source ~/dotfiles/zsh/mac-linux-utils.sh
fi

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/bin:/usr/local/bin:$PATH"

# fnm
FNM_PATH="/Users/jonathan.halchack/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/jonathan.halchack/Library/Application Support/fnm:$PATH"
  eval "`fnm env`"
fi

eval "$(fnm env --shell zsh)"

source ~/dotfiles/zsh/promptline.sh

# -------------------------
# NOTE: You need to install cargo/rust for Neovim/Mason's jinja-lsp
# curl https://sh.rustup.rs -sSf | sh
#
# Followed by?:
# . "$HOME/.cargo/env"
#
# -------------------------

# For a nice loading-time output (see beginning of file)
# zprof
