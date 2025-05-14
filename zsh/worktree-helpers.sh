declare -A colors

# Reset
colors['reset']='\033[0m' # Text Reset

# Regular Colors
colors['black']='\033[0;30m'        # Black
colors['red']='\033[0;31m'          # Red
colors['green']='\033[0;32m'        # Green
colors['yellow']='\033[0;33m'       # Yellow
colors['blue']='\033[0;34m'         # Blue
colors['purple']='\033[0;35m'       # Purple
colors['cyan']='\033[0;36m'         # Cyan
colors['white']='\033[0;37m'        # White

# Bold
colors['bblack']='\033[1;30m'       # Black
colors['bred']='\033[1;31m'         # Red
colors['bgreen']='\033[1;32m'       # Green
colors['byellow']='\033[1;33m'      # Yellow
colors['bblue']='\033[1;34m'        # Blue
colors['bpurple']='\033[1;35m'      # Purple
colors['bcyan']='\033[1;36m'        # Cyan
colors['bwhite']='\033[1;37m'       # White

# Underline
colors['ublack']='\033[4;30m'       # Black
colors['ured']='\033[4;31m'         # Red
colors['ugreen']='\033[4;32m'       # Green
colors['uyellow']='\033[4;33m'      # Yellow
colors['ublue']='\033[4;34m'        # Blue
colors['upurple']='\033[4;35m'      # Purple
colors['ucyan']='\033[4;36m'        # Cyan
colors['uwhite']='\033[4;37m'       # White

# Background
colors['on_black']='\033[40m'       # Black
colors['on_red']='\033[41m'         # Red
colors['on_green']='\033[42m'       # Green
colors['on_yellow']='\033[43m'      # Yellow
colors['on_blue']='\033[44m'        # Blue
colors['on_purple']='\033[45m'      # Purple
colors['on_cyan']='\033[46m'        # Cyan
colors['on_white']='\033[47m'       # White

function gwta() {
  BRANCH_NAME=$1
  POINTER=${2:=develop}
  FOLDER_NAME=$BRANCH_NAME

  if [[ $BRANCH_NAME  == *"/"* ]]; then
    FOLDER_NAME="${BRANCH_NAME##*/}"
  fi

  TS_NOTE="${colors['white']}${colors['on_black']}"
  TS_BRANCH="${colors['ugreen']}${colors['bgreen']}"
  TS_CHUNK1="${colors['black']}${colors['on_green']}"
  TS_CHUNK2="${colors['black']}${colors['on_yellow']}"
  TS_CHUNK3="${colors['black']}${colors['on_blue']}"
  TS_WARN="${colors['yellow']}${colors['on_black']}"
  TS_RESET="${colors['reset']}"

  echo -e "$TS_NOTE Preparing to add a worktree for $TS_BRANCH$BRANCH_NAME$TS_RESET${colors['on_black']}. $TS_RESET"
  echo -e "$TS_WARN Make sure you are in the folder you store worktrees in and that, if you have a prefix, the ending won't conflict with existing folders $TS_RESET"
  echo -e " "
  echo -e "--- "
  echo -e " "
  while true; do
    echo "$TS_NOTE git worktree add -b $TS_CHUNK1  $BRANCH_NAME $TS_NOTE $TS_CHUNK2  $FOLDER_NAME $TS_NOTE $TS_CHUNK3  $POINTER $TS_RESET"
    echo "$TS_NOTE Do you wish to create the branch? $TS_RESET"
    # "?" prefix is for zsh read, similar to bash's "-p" flag
    read "?[y/N]:" BRANCH_CONFIRMED
    BRANCH_CONFIRMED=${BRANCH_CONFIRMED:-N}

    if [[ $BRANCH_CONFIRMED == 'n' || $BRANCH_CONFIRMED == 'N' ]]; then
      echo "Okay, exiting now."
      break
    elif [[ $BRANCH_CONFIRMED  == 'y' || $BRANCH_CONFIRMED  == 'Y' ]]; then
      git worktree add -b $BRANCH_NAME ./$FOLDER_NAME $POINTER
      break
    fi
  done
}

function gwth() {
  TS_NOTE="${colors['white']}${colors['on_black']}"
  TS_CHUNK1="${colors['black']}${colors['on_green']}"
  TS_CHUNK2="${colors['black']}${colors['on_yellow']}"
  TS_CHUNK3="${colors['black']}${colors['on_blue']}"
  TS_RESET="${colors['reset']}"

  echo "Example: $TS_NOTE git worktree add -b $TS_CHUNK1  branch-name $TS_NOTE $TS_CHUNK2  folder-name $TS_NOTE $TS_CHUNK3  branch-source $TS_RESET"
}

