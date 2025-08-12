# For a nice loading-time output (see end of file)
# zmodload zsh/zprof

# Setup completion
autoload -U compinit; compinit

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

alias ssh-all='ssh-add $(find ~/.ssh -type f ! -name "*.*" -not -name "config" -not -name "known_hosts" -exec realpath {} \;)'

if [[ "$(uname)" == "Darwin" ]]; then
  source ~/dotfiles/zsh/mac-linux-utils.sh

  # Source fjira terminal completion for macbook pro
  source ~/dotfiles/zsh/fjir-mac-completion.sh

  # Setup PATH for mac
  source ~/dotfiles/zsh/mac-path.sh

  export NEORG_DW="omni"
else
  export NEORG_DW="notes"

  # Setup PATH for linux
  source ~/dotfiles/zsh/linux-path.sh
fi

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

# Cheat sheet helper - type "cheat ls" for an example
function cheat() {
  curl cheat.sh/$1
}

# Auto add/commit/push neorg notes
# Arguments:
#   $1 - The (optional) workspace to sync, defaults to '~/neorg/'
function notesync() {
  local base_dir="$HOME/neorg"
  local workspace="${1:-}"
  local target_dir="$base_dir"

  if [[ "$workspace" == "work" || "$workspace" == "omni" ]]; then
    target_dir="$base_dir/$workspace"
  fi

  if [ ! -d "$target_dir/.git" ]; then
    echo "No git repository found in $target_dir"
    return 1
  fi

  if command -v gdate >/dev/null 2>&1; then
    timestamp="$(gdate --rfc-3339=seconds)"
  else
    timestamp="$(date --rfc-3339=seconds)"
  fi

  cd "$target_dir" || return 1
  git add . && git commit -m "$timestamp" && git push origin main
}

# ghlc: Submit a comment with Github CLI on a specific line of the diff via the API
# Arguments:
#   $1 - The commit hash where the change was made
#   $2 - The message
#   $3 - The path to the file you're commenting on
#   $4 - The
#   $5 - The
function ghlc() {
  gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /repos/OWNER/REPO/pulls/PULL_NUMBER/comments \
    -f body="$2" \
    -f commit_id="$1" \
    -f path="$3" \
    -F start_line=1 \
    -F start_side='RIGHT' \
    -F line=2 \
    -f side='RIGHT'
}

# doc: Extract out the docs for a given bash function from a file (default: ~/.zshrc)
# Arguments:
#   $1 - The function name
#   $2 - (Optional) The file to search (default: ~/.zshrc)
function doc() {
  local func="$1"
  local file="${2:-$ZSHRC}"
  # Fallback to ~/.zshrc if $ZSHRC is unset
  if [[ -z "$file" ]]; then
    file="$HOME/.zshrc"
  fi
  if [[ ! -f "$file" ]]; then
    echo "File not found: $file"
    return 1
  fi
  # Find the line number where the function is defined (support both syntaxes)
  local line
  line=$(grep -nE "^[[:space:]]*(function[[:space:]]+)?${func}[[:space:]]*\(\)[[:space:]]*\{" "$file" | head -n1 | cut -d: -f1)
  if [[ -z "$line" ]]; then
    echo "Function '$func' not found in $file"
    return 1
  fi
  # Walk backwards to find the comment block
  awk -v func_line="$line" '
    NR==func_line {
      for (i=NR-1; i>0; i--) {
        if (lines[i] ~ /^[[:space:]]*#/ || lines[i] ~ /^[[:space:]]*$/) {
          doc = lines[i] "\n" doc
        } else {
          break
        }
      }
      print doc
      exit
    }
    { lines[NR]=$0 }
  ' "$file" | sed '/^[[:space:]]*$/d' | sed 's/^[[:space:]]*#\s\{0,1\}//'
}

function qr() {
  curl "qrenco.de/$1"
}

function tnf() {
  if ! command -v telnet >/dev/null 2>&1; then
    echo "telnet is not installed. Please install it first."
    return 1
  fi

  if [ $# -eq 0 ]; then
    echo "I don't know what you want."
    return 1
  fi

  case "$1" in
    # Starwars Died :'(
    starwars)
      #  telnet 2001:7b8:666:ffff::1:42
      #  telnet towel.blinkenlights.nl
      echo "RIP Star Wars 😭"
      ;;
    maps)
      telnet mapscii.me
      ;;
    doom)
      telnet doom.w-graj.net 666
      ;;
    horizons)
      telnet horizons.jpl.nasa.gov 6775
      ;;
    chess)
      telnet freechess.org 5000
      ;;
    btc)
      telnet ticker.bitcointicker.co 10080
      ;;
    1984)
      telnet 1984.ws 23
      ;;
    # see https://github.com/ballerburg9005/wikipedia-live-telnet
    wiki)
      telnet telnet.wiki.gd
      ;;
      # Wikimedia has their own but it didn't seem to work
      # wikio)
      #   telnet telnet.wmflabs.org
      #   ;;
    bofh)
      telnet bofh.jeffballard.us 666
      ;;
    trek)
      telnet mtrek.com 1701
      ;;
    telehack)
      telnet telehack.com 23
      ;;
    abin)
      telnet bbs.archaicbinary.net 23
      ;;
    # )
    #   telnet
    #   ;;
    *)
      echo "I don't know what you mean: $1"
      return 1
      ;;
  esac
}


# Helpers so I remember basic worktree commands, lol
source ~/dotfiles/zsh/worktree-helpers.sh

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

