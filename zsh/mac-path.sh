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

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

export REQUESTS_CA_BUNDLE="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"
export NODE_EXTRA_CA_CERTS="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"
export GIT_SSL_CAPATH="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"
export CURL_CA_BUNDLE="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"
export AWS_CA_BUNDLE="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"

export PATH="/opt/homebrew/opt/util-linux/bin:$PATH"
export PATH="/opt/homebrew/opt/util-linux/sbin:$PATH"

