# Exit this script early if running on macOS (Darwin)
if [ "$(uname)" = "Darwin" ]; then
  return 0
fi

# Track whether we've installed anything for notification
installed=false

# TODO Maybe install VictorMono and setup kitty/wezterm?
# This would be getting more into system initialization though...
# Maybe hold out until I'm using nix or have a big system install script

# Check for required packages for AppImage integrator
# missing=""
#
# for pkg in inotifywait git wget; do
#   if ! command -v "$pkg" >/dev/null 2>&1; then
#     missing="$missing $pkg"
#   fi
# done

# TODO Import colors for fun w/ Nerdfont
# if [ -n "$missing" ]; then
#   echo ""
#   echo "-----------------------------------------------------------"
#   echo " The following packages are required but missing:$missing"
#   echo ""
#   echo " Please install them with:"
#   echo "   sudo apt update && sudo apt install$missing"
#   echo ""
#   echo " Then restart zsh with:"
#   echo "   exec zsh"
#   echo "-----------------------------------------------------------"
#   echo ""
#   return 1
# fi

# TODO - Get rid of all the aliases and stuff where they're unecessary, and just
# move from using ~/Applications to ~/bin/ and update the PATH or something..

export PATH=$PATH:/usr/local/go/bin

# Install Go v1.24.3
if ! command -v go >/dev/null 2>&1; then
  echo "Installing Go v1.24.3..."
  # TODO see if this version can be variablized and retrieved by URL convention
  curl -fsSL https://go.dev/dl/go1.24.3.linux-amd64.tar.gz -o "$HOME/go1.24.3.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$HOME/go1.24.3.linux-amd64.tar.gz"
  installed=true
fi

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi

# Install fnm
if ! command -v fnm >/dev/null 2>&1; then
  echo "Installing fnm (Fast Node Manager)..."
  curl -fsSL https://fnm.vercel.app/install | bash
  eval "$(fnm env --shell zsh)"
  installed=true
fi

# Install Rust / cargo
if ! command -v cargo >/dev/null 2>&1; then
  echo "Installing Rust/cargo..."
  curl https://sh.rustup.rs -sSf | sh
  # Followed by?:
  # . "$HOME/.cargo/env"
  installed=true
fi

# Install Neovim AppImage if not present
nvim_version="v0.11.1"
nvim_appimage="$HOME/Applications/nvim-linux-x86_64_${nvim_version}.appimage"

# Setup aliases for vi, vim, and nvim
alias nvim="$nvim_appimage"
alias vim="$nvim_appimage"
alias vi="$nvim_appimage"

if [ ! -f "$nvim_appimage" ]; then
  echo "Installing Neovim AppImage $nvim_version..."
  mkdir -p "$HOME/Applications"
  curl -fsSL "https://github.com/neovim/neovim/releases/download/${nvim_version}/nvim-linux-x86_64.appimage" -o "$nvim_appimage"
  chmod +x "$nvim_appimage"
  installed=true
fi

# Wezterm if not installed
# Filename from wezterm site, make version variable for latest if desired
WEZTERM_FILENAME="WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage"
WEZTERM_APPIMAGE="$HOME/Applications/$WEZTERM_FILENAME"
alias wezterm="$WEZTERM_APPIMAGE"

if [ ! -f "$WEZTERM_APPIMAGE" ]; then
  echo "Installing Wezterm"
  curl -fsSL -o "$HOME/Applications/$WEZTERM_FILENAME" "https://github.com/wezterm/wezterm/releases/download/20240203-110809-5046fc22/$WEZTERM_FILENAME"
  chmod +x "$HOME/Applications/$WEZTERM_FILENAME"
  installed=true
fi

# Install Vifm AppImage if not present
vifm_version="v0.14.2"
vifm_appimage="$HOME/Applications/vifm-${vifm_version}-x86_64.appimage"

# Setup alias for vifm to avoid PATH issues
alias vifm="$vifm_appimage"

if [ ! -f "$vifm_appimage" ]; then
  echo "Installing Vifm AppImage $vifm_version..."
  mkdir -p "$HOME/Applications"
  curl -fsSL "https://prdownloads.sourceforge.net/vifm/vifm-${vifm_version}-x86_64.AppImage?download" -o "$vifm_appimage"
  chmod +x "$vifm_appimage"
  installed=true
fi

# Notify of new installations
if [ "$installed" = true ]; then
  echo ""
  echo "-----------------------------------------------------"
  echo " New packages were installed. Restart zsh by running:"
  echo "   exec zsh"
  echo "-----------------------------------------------------"
  echo ""
fi

