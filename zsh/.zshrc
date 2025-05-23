# For a nice loading-time output (see end of file)
# zmodload zsh/zprof

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

# List by folder
alias listpf="ls $(echo $PATH | tr ':' ' ') | grep -v '/' | grep . | sort"

# List all commands by name
alias listp="ls $(echo $PATH | tr ':' ' ')"

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

