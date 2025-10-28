function ga() {
  TARGET=${1:="."}
  if [[ $TARGET = "." ]]; then;
    echo "Adding all files... careful, now."
  fi;
  git add $TARGET
}

alias gbl="git branch list"
alias gbd="git branch -D"

alias gf="git fetch"
alias gfp="git fetch -p"

alias gca="git commit --amend"
alias gcae="git commit --amend --no-edit"
alias gcaen="git commit --amend --no-edit --no-verify"

alias gch="git checkout"
alias gchb="git checkout -b"

alias gc="git commit"
alias gcm="git commit -m"
alias gcn="git commit --no-verify"

alias gcr="git reset --soft HEAD~1"
alias gcrh="git reset --hard HEAD~1"

alias gd="git diff | cat"
alias gds="git diff --staged | cat"

function glg() {
  COUNT=${1:="5"}
  git log -$COUNT | bat
}

function gm() {
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  SOURCE=${1:="develop"}
  TARGET=${2:="$CURRENT_BRANCH"}
  git merge $SOURCE $TARGET
}

function gpl() {
  BRANCH=${1:="develop"}
  APPROACH=${2:="--rebase"}
  git pull origin $BRANCH $APPROACH
}

function gps() {
  BRANCH=${1:=main}
  git push origin $BRANCH
}

function gr() {
  TARGET=${1:="."}
  if [[ $TARGET = "." ]]; then;
    echo "Resetting all files... careful, now."
  fi;
  git reset $TARGET
}

alias grb="git rebase -i"
alias gs="git status"

