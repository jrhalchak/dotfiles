# Prevent default (venv) prompt from Python venv
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Original Tokyo Night colors
TOKYO_BLUE='#7aa2f7'
# TOKYO_PURPLE='#bb9af7'
# TOKYO_GREEN='#9ece6a'
TOKYO_YELLOW='#e0af68'
# TOKYO_RED='#f7768e'
# TOKYO_CYAN='#7dcfff'

# Darker variants (for backgrounds or subtle elements)
TOKYO_DARK_BLUE='#4c71c7'
# TOKYO_DARK_PURPLE='#9070d0'
TOKYO_DARK_GREEN='#6ba845'
# TOKYO_DARK_YELLOW='#b88940'
TOKYO_DARK_RED='#d0506a'
# TOKYO_DARK_CYAN='#4fa8d8'

# Even deeper/darker variants
# TOKYO_DEEP_BLUE='#33508f'
TOKYO_DEEP_PURPLE='#664f93'
TOKYO_DEEP_GREEN='#4a7530'
# TOKYO_DEEP_YELLOW='#85622e'
TOKYO_DEEP_RED='#9a3a4d'
# TOKYO_DEEP_CYAN='#377a9e'

# Lighter variants (for highlights or text on dark backgrounds)
# TOKYO_LIGHT_BLUE='#a8c4ff'
# TOKYO_LIGHT_PURPLE='#d7c0ff'
# TOKYO_LIGHT_GREEN='#b8f788'
# TOKYO_LIGHT_YELLOW='#ffd08a'
# TOKYO_LIGHT_RED='#ff9caf'
# TOKYO_LIGHT_CYAN='#a5e8ff'

# High contrast variants (for emphasis)
# TOKYO_BRIGHT_BLUE='#5a8eff'
# TOKYO_BRIGHT_PURPLE='#c17aff'
TOKYO_BRIGHT_GREEN='#7ae03a'
# TOKYO_BRIGHT_YELLOW='#ffc23a'
TOKYO_BRIGHT_RED='#ff4d6b'
# TOKYO_BRIGHT_CYAN='#38d9ff'

# Additional complementary colors
# TOKYO_ORANGE='#ff9e64'     # Warm accent
# TOKYO_TEAL='#2ac3a2'       # Cool alternative to green
# TOKYO_PINK='#ff75a0'       # Softer alternative to red
# TOKYO_LAVENDER='#9d7cd8'   # Between blue and purple

# Neutrals for backgrounds and text
TOKYO_BG_DARK='#1a1b26'    # Dark background
TOKYO_BG_MID='#202233'      # Midpoint background
TOKYO_BG_MEDIUM='#24283b'  # Medium background
TOKYO_BG_BRIGHT='#2e3348'   # Bright background
TOKYO_FG_BRIGHT='#c0caf5'  # Bright foreground
TOKYO_FG_MUTED='#565f89'   # Muted foreground

BLINKON=$'\033[5m'
BLINKOFF=$'\033[25m'

# Custom venv prompt element
venv_prompt() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local venv_name="${VIRTUAL_ENV##*/}"
    # Use a unique color/icon for venv
    echo "%K{$TOKYO_DARK_BLUE}%F{$TOKYO_BG_DARK}  %B$venv_name%b %f%k"
  fi
}

function preexec() {
  timer=${timer:-$SECONDS}
}

function precmd() {
  local cmd_status=$?

  if [[ -z "$PROMPTLINE_INITIALIZED" ]]; then
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    #|-> TODO: do the darwin/linux tests for different configs <-|#
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    clear
    echo "" # buffer line
    fastfetch
    echo "" # buffer line
  else
    echo "" # Add a buffer line after command output
  fi
  PROMPTLINE_INITIALIZED=1

  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    timer_show=$(printf '%.*f\n' 3 $timer_show)

    # Status code color based on success/failure
    local status_val="%F{$TOKYO_BG_BRIGHT}%f%F{$TOKYO_DARK_GREEN}%K{$TOKYO_BG_BRIGHT} 󰄬 ${cmd_status} %k%f"
    [ $cmd_status -ne 0 ] && status_val="%F{$TOKYO_DEEP_RED}%f%F{$TOKYO_FG_BRIGHT}%K{$TOKYO_DEEP_RED}  %{${BLINKON}%}${cmd_status}%{${BLINKOFF}%} %k%f"

   # Status color based on success/failure
    local status_end="%K{$TOKYO_BG_BRIGHT}"
    [ $cmd_status -ne 0 ] && status_end="%K{$TOKYO_DEEP_RED}"

    # Time color based on duration
    local time_val="${status_end}%F{$TOKYO_BG_MID}%f%k%K{$TOKYO_BG_MID}%F{$TOKYO_FG_MUTED} 󰔚 ${timer_show}s %f%k"
    if (( $(echo "$timer_show > 3.0" | bc -l) )); then
      time_val="%B${status_end}%F{$TOKYO_YELLOW}%f%k%K{$TOKYO_YELLOW}%F{$TOKYO_BG_MID} 󰔚 ${timer_show}s %f%k%b"
    fi
    if (( $(echo "$timer_show > 10.0" | bc -l) )); then
      time_val="%B${status_end}%F{$TOKYO_DEEP_RED}%f%k%K{$TOKYO_DEEP_RED}%F{$TOKYO_FG_BRIGHT} 󰔚 ${timer_show}s %f%k%b"
    fi

    # Build the right prompt with icons and colors
    export RPROMPT="${status_val}${time_val}"

    unset timer
  fi
}

get_git_branch() {
  # Check if the current directory is part of a git repository or worktree
  if git rev-parse --is-inside-work-tree &>/dev/null || git rev-parse --is-bare-repository &>/dev/null; then
    # Get the branch name
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    # Get the change counts (staged, unstaged, untracked)
    changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    staged=$(git diff --cached --name-status 2>/dev/null | wc -l | tr -d ' ')

    local preamble="%F{$TOKYO_DEEP_PURPLE}%K{$TOKYO_BG_MEDIUM}%f"

    # Check ahead/behind status compared to remote
    local sync_char=""  # Default to neutral (in sync)
    local remote_exists=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)

    if [[ -n "$remote_exists" ]]; then
      local ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null)
      local behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null)

      if [[ $ahead -gt 0 ]]; then
        sync_char="󱟀"   # Ahead (up)
      elif [[ $behind -gt 0 ]]; then
        sync_char="󱞢"   # Behind (down)
      fi
    fi

    # Format output based on changes
    if [[ $changes -gt 0 ]]; then
      if [[ $staged -gt 0 ]]; then
        # Yellow if staged changes
        indicator=" %F{$TOKYO_YELLOW}%f%K{$TOKYO_YELLOW}%F{$TOKYO_BG_DARK} $sync_char%f%k%F{$TOKYO_YELLOW}"
        echo "$preamble %F{$TOKYO_YELLOW}%B  $branch $indicator%F{$TOKYO_BG_DARK}%K{$TOKYO_YELLOW}  $changes %k%f%F{$TOKYO_YELLOW}%f %b%f%k"
      else
        # Red and bold when there are unstaged/untracked changes only
        indicator=" %F{$TOKYO_DARK_RED}%f%K{$TOKYO_DARK_RED}%F{$TOKYO_FG_BRIGHT} $sync_char%f%k%F{$TOKYO_DARK_RED}"
        echo "$preamble %F{$TOKYO_BRIGHT_RED}%B  $branch $indicator%F{$TOKYO_FG_BRIGHT}%K{$TOKYO_DARK_RED}  $changes %k%f%F{$TOKYO_DARK_RED}%f %b%f%k"
      fi
    else
      indicator=" %F{$TOKYO_DARK_GREEN}%f%K{$TOKYO_DARK_GREEN}%F{$TOKYO_BG_DARK} $sync_char%f%k%F{$TOKYO_DARK_GREEN}"
      # Green when clean
      echo "$preamble %F{$TOKYO_BRIGHT_GREEN}%B  $branch $indicator%F{$TOKYO_BG_DARK}%K{$TOKYO_DARK_GREEN}  󰔓 %k%f%F{$TOKYO_DARK_GREEN}%f %b%f%k"
    fi
  else
    # Not a git repository or worktree
    echo "%F{$TOKYO_DEEP_PURPLE}%f%k "
  fi
}

# Function to generate binary clock using braille characters
# binary_clock() {
#   # Get current time components
#   local -i hour=$(date +%H)
#   local -i min=$(date +%M)
#   local -i sec=$(date +%S)
#
#   # Initialize output
#   local output=""
#
#   # Generate 3 braille characters
#   for col in {0..2}; do
#     local char_code=10240  # base braille character (⠀)
#
#     # Hours (top row)
#     if (( hour & (1 << (5 - col * 2)) )); then
#       char_code=$((char_code + 1))
#     fi
#     if (( hour & (1 << (4 - col * 2)) )); then
#       char_code=$((char_code + 8))
#     fi
#
#     # Minutes (middle row)
#     if (( min & (1 << (5 - col * 2)) )); then
#       char_code=$((char_code + 2))
#     fi
#     if (( min & (1 << (4 - col * 2)) )); then
#       char_code=$((char_code + 16))
#     fi
#
#     # Seconds (bottom row)
#     if (( sec & (1 << (5 - col * 2)) )); then
#       char_code=$((char_code + 4))
#     fi
#     if (( sec & (1 << (4 - col * 2)) )); then
#       char_code=$((char_code + 32))
#     fi
#
#     # Convert code to character using perl (more reliable for Unicode)
#     output+=$(perl -e "binmode(STDOUT, ':utf8'); print chr($char_code);")
#   done
#
#   echo -n $output
# }

# Alternative horizontal binary clock
binary_clock() {
  local time parts part bin vis output=" " count=0
  time=$(date +"%H %M")
  parts=(${=time})  # Zsh: split $time into array
  for part in $parts; do
    local one='%F{white}󰨓%f'
    local zero='%F{$TOKYO_FG_MUTED}󰨔%f'
    bin=$(printf "%06d" "$(echo "obase=2; $((10#$part))" | bc)")
    vis=$(echo "$bin" | sed "s/1/$one /g; s/0/$zero /g; s/ $/ /")
    output+="$vis"
    (( ++count < 2 )) && output+=" "
  done
  echo "$output"
}


setopt PROMPT_SUBST

function update_prompt() {
  # PROMPT=$'%K{$TOKYO_BLUE}%F{$TOKYO_BG_DARK} %B󰅏%b %f%k' # Icon segment
  local base_prompt=$'$(venv_prompt)' # Python venv prompt (if active)
  base_prompt+=$'%K{$TOKYO_BLUE}%F{$TOKYO_BG_DARK} %B󰥋%b %f%k' # Icon segment
  base_prompt+=$'%K{$TOKYO_BG_MEDIUM}%F{$TOKYO_BLUE}%f' # First separator

  local end_prompt=$'%F{$TOKYO_DEEP_PURPLE}%f%k' # Second separator
  end_prompt+=$'%K{$TOKYO_DEEP_PURPLE} %F{$TOKYO_FG_BRIGHT} %B%(5~|%-1~/…/%3~|%4~)%b%f %k' # Directory path
  end_prompt+=$'$(get_git_branch)' # Git status

  # Calculate actual rendered lengths (strip color codes and expand prompt sequences)
  local left_length=$(print -P "${base_prompt}${end_prompt}" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)
  local right_length=$(print -P "$RPROMPT" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)

  # Calculate binary clock width dynamically - expand and strip zsh color codes
  local binary_clock_width=$(print -P "$(binary_clock)" | sed 's/\x1b\[[0-9;]*m//g' | wc -m)

  # Check if there's enough space for binary clock (at least 50 chars between prompts)
  local available_space=$((COLUMNS - left_length - right_length))
  local required_space=$((binary_clock_width + 50))  # desired gap

  if (( available_space >= required_space )); then
    PROMPT="${base_prompt}"'$(binary_clock)'"${end_prompt}"
  else
    PROMPT="${base_prompt}${end_prompt}"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd update_prompt

# Add this function to handle window resize
TRAPWINCH() {
  update_prompt
}
