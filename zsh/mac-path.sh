# Yarn paths
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/bin:/usr/local/bin:$PATH"

# fnm
FNM_PATH="/Users/jonathan.halchack/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/jonathan.halchack/Library/Application Support/fnm:$PATH"
  eval "$(fnm env)"
fi

# For pipx but also everything else
export PATH="$PATH:/Users/jonathan.halchack/.local/bin"

# Golang
export PATH="$PATH:/Users/jonathan.halchack/go/bin"

# Ghostty (TODO: not using, revisit)
export PATH="$PATH:/Applications/Ghostty.app/Contents/MacOS/"

