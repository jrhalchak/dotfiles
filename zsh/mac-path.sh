# Yarn paths
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/bin:/usr/local/bin:$PATH"

# fnm
FNM_PATH="/Users/jonathan.halchak/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/jonathan.halchak/Library/Application Support/fnm:$PATH"
  eval "$(fnm env)"
fi

# For pipx but also everything else
export PATH="$PATH:/Users/jonathan.halchak/.local/bin"

# Golang
export PATH="$PATH:/Users/jonathan.halchak/go/bin"
