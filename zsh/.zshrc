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

source ~/dotfiles/zsh/git-helpers.sh

if [[ "$(uname)" == "Darwin" ]]; then
  source ~/dotfiles/zsh/mac-linux-utils.sh

  # Source fjira terminal completion for macbook pro
  source ~/dotfiles/zsh/fjir-mac-completion.sh

  # Setup PATH for mac
  source ~/dotfiles/zsh/mac-path.sh

  # ZSH Plugins
  # TODO: Update Linux with these plugins if needed
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  # fnm
  FNM_PATH="/opt/homebrew/opt/fnm/bin"
  if [ -d "$FNM_PATH" ]; then
    eval "`fnm env`"
  fi

  # TODO: Check whether this is necessary *here*, and whether the aliases on the bat repo are helpful
  # Hard-coded from `fdellwing/zsh-bat`, requires `bat` from *https://github.com/sharkdp/bat?tab=readme-ov-file#how-to-use*
  if command -v batcat >/dev/null 2>&1; then
    # Save the original system `cat` under `rcat`
    alias rcat="$(which cat)"

    # For Ubuntu and Debian-based `bat` packages
    # the `bat` program is named `batcat` on these systems
    alias cat="$(which batcat)"
    export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
    export MANROFFOPT="-c"
  elif command -v bat >/dev/null 2>&1; then
    # Save the original system `cat` under `rcat`
    alias rcat="$(which cat)"

    # For all other systems
    alias cat="$(which bat)"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
  fi

  export NEORG_DW="omni"
else
  export NEORG_DW="notes"

  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  alias m="$HOME/dotfiles/scripts/utils/launcher.sh"

  # Setup PATH for linux
  source ~/dotfiles/zsh/linux-path.sh
fi

# TODO: Check whether this is necessary *here*, and whether the aliases on the bat repo are helpful
# Hard-coded from `fdellwing/zsh-bat`, requires `bat` from *https://github.com/sharkdp/bat?tab=readme-ov-file#how-to-use*
if command -v batcat >/dev/null 2>&1; then
  # Save the original system `cat` under `rcat`
  alias rcat="$(which cat)"

  # For Ubuntu and Debian-based `bat` packages
  # the `bat` program is named `batcat` on these systems
  alias cat="$(which batcat)"
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
  export MANROFFOPT="-c"
elif command -v bat >/dev/null 2>&1; then
  # Save the original system `cat` under `rcat`
  alias rcat="$(which cat)"

  # For all other systems
  alias cat="$(which bat)"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
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

# Simple markdown renderer using pandoc
function md() {
  local filename=$(basename "$1" .md)
  local output="/tmp/${filename}.html"
  cat > "$output" <<EOF
<!DOCTYPE html>
<head>
  <title>${filename}</title>
  <style>
    *, *:before, *:after { box-sizing: border-box; }
    :root {
      --tn-bg: #1a1b26;
      --tn-bg-dark: #16161e;
      --tn-bg-dark1: #0C0E14;
      --tn-bg-highlight: #292e42;
      --tn-blue: #7aa2f7;
      --tn-blue0: #3d59a1;
      --tn-blue1: #2ac3de;
      --tn-blue2: #0db9d7;
      --tn-blue5: #89ddff;
      --tn-blue6: #b4f9f8;
      --tn-blue7: #394b70;
      --tn-comment: #565f89;
      --tn-cyan: #7dcfff;
      --tn-dark3: #545c7e;
      --tn-dark5: #737aa2;
      --tn-fg: #c0caf5;
      --tn-fg-dark: #a9b1d6;
      --tn-fg-gutter: #3b4261;
      --tn-green: #9ece6a;
      --tn-green1: #73daca;
      --tn-green2: #41a6b5;
      --tn-magenta: #bb9af7;
      --tn-magenta2: #ff007c;
      --tn-orange: #ff9e64;
      --tn-purple: #9d7cd8;
      --tn-red: #f7768e;
      --tn-red1: #db4b4b;
      --tn-teal: #1abc9c;
      --tn-terminal-black: #414868;
      --tn-yellow: #e0af68;
      --tn-git-add: #449dab;
      --tn-git-change: #6183bb;
      --tn-git-delete: #914c54;
    }

    html, body {
      margin: 0; padding: 0; font-family: sans-serif;
    }

    body {
      background-color: var(--tn-bg);
      color: var(--tn-fg);
    }

    main {
      width: clamp(50vw, calc(95vw - 4rem), 100vw);
      margin: 2rem auto;
    }

    h1, h2 { font-weight: 200; font-size: 2rem; }
    h3, h4, h5, h6 { font-weight: 900; }

    p { line-height: 1.75; margin: 1.5rem 0; }

    code {
      color: var(--tn-fg);
      font-family: 'VictorMono Nerd Font Mono' !important;
      background-color: var(--tn-bg-dark);
      padding: 0.125rem;
      margin: 0.125rem 0.5rem;

      &.javascript, &.typescript {
        .op { color: var(--tn-cyan); font-weight: bold; }
        .bu { color: var(--tn-blue2); }
        .kw { color: var(--tn-purple); font-style: italic; }
        .im { color: var(--tn-blue5); }
        .cf { color: var(--tn-purple); }
        .fu { color: var(--tn-blue); }
        .dv, .st { color: var(--tn-green); }
        .co { color: var(--tn-fg-dark); font-style: italic; }
        .ch { color: var(--tn-fg); }
      }

      &.css, &.scss, &.sass {
        .op { color: var(--tn-cyan); font-weight: bold; }
        .bu, .kw + .ch ~ .fu { color: var(--tn-blue); }
        .kw { color: var(--tn-cyan); }
        .im { color: var(--tn-blue5); }
        .cf { color: var(--tn-purple); }
        .fu { color: var(--tn-purple); }

        /* value */
        .dv { color: var(--tn-green); }
        .dv:has(+ .dt) { color: var(--tn-orange); }
        /* units */
        .dt { color: var(--tn-green); }

        .st { color: var(--tn-green); }
        .co { color: var(--tn-fg-dark); font-style: italic; }
        .ch { color: var(--tn-fg); }
      }
    }

    pre > code { display: block; padding: 0.5rem; margin: 0.5rem 0; }

    hr { background-color: var(--tn-blue7); height: 1px; border: none; margin: 3rem 0; }
  </style>
</head>
<body>
  <main>
  $(pandoc "$1")
  </main>
</body>
</html>
EOF
  if [[ "$(uname)" == "Darwin" ]]; then
    open "$output"
  else
    xdg-open "$output"
  fi
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

# tnf: Telnet to various fun services and games
# Arguments:
#   $1 - Service name (starwars, maps, doom, horizons, chess, btc, 1984, wiki, bofh, trek, telehack, abin)
# Available services:
#   starwars  - (Deprecated) Star Wars ASCII animation
#   maps      - ASCII world map viewer
#   doom      - Play DOOM multiplayer
#   horizons  - NASA JPL Horizons ephemeris system
#   chess     - Free Internet Chess Server
#   btc       - Bitcoin ticker
#   1984      - George Orwell's 1984 book
#   wiki      - Wikipedia live search
#   bofh      - Bastard Operator From Hell excuse server
#   trek      - Multi-Trek game
#   telehack  - Simulated 1980s computer system
#   abin      - Archaic Binary BBS
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
