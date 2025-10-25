# Exit this script early if running on macOS (Darwin)
if [ "$(uname)" = "Darwin" ]; then
  return 0
fi

# Track whether we've installed anything for notification
installed=false

# Some common utils I install with every fresh install
## NOTE: This presupposes you're using `apt`, won't work on
## non-apt distroes
sudo apt update && sudo apt install ripgrep xclip xdotool jq pipx inotify-tools x11-xkb-utils xinput dunst

# Ensure dunst config is linked
mkdir -p "$HOME/.config/dunst"
ln -sf "$HOME/dotfiles/linux/config/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"

# Install xborder dependencies
if ! command -v xborders >/dev/null 2>&1; then
  echo "Installing xborder dependencies and script..."

  # Install system dependencies
  sudo apt install -y libwnck-3-0 libwnck-3-dev libnotify-bin python3-gi gir1.2-gtk-3.0 python3-venv

  # Clone xborder to shared/apps/bin
  if [ ! -d "$HOME/dotfiles/shared/apps/bin/xborder" ]; then
    git clone https://github.com/deter0/xborder "$HOME/dotfiles/shared/apps/bin/xborder"
    chmod +x "$HOME/dotfiles/shared/apps/bin/xborder/xborders"
  fi

  # Create or repair venv and install Python dependencies
  venv_dir="$HOME/dotfiles/shared/apps/bin/xborder/venv"
  if [ ! -d "$venv_dir" ]; then
    python3 -m venv "$venv_dir"
    "$venv_dir/bin/pip" install -r "$HOME/dotfiles/shared/apps/bin/xborder/requirements.txt"
  else
    if grep -q "/dotfiles/apps/bin/xborder/venv" "$venv_dir/bin/activate" 2>/dev/null; then
      echo "Rebuilding xborder venv under shared path..."
      rm -rf "$venv_dir"
      python3 -m venv "$venv_dir"
      "$venv_dir/bin/pip" install -r "$HOME/dotfiles/shared/apps/bin/xborder/requirements.txt"
    fi
  fi

  installed=true
fi

# Create wrapper for the bin folder
cat << 'EOF' > "$HOME/dotfiles/shared/apps/bin/xborders"
#!/bin/bash
exec "$HOME/dotfiles/shared/apps/bin/xborder/venv/bin/python3" "$HOME/dotfiles/shared/apps/bin/xborder/xborders" "$@"
EOF


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
nvim_appimage="$HOME/dotfiles/shared/apps/bin/nvim"

if [ ! -f "$nvim_appimage" ]; then
  echo "Installing Neovim AppImage $nvim_version..."
  mkdir -p "$HOME/dotfiles/shared/apps/bin"
  curl -fsSL "https://github.com/neovim/neovim/releases/download/${nvim_version}/nvim-linux-x86_64.appimage" -o "nvim"
  chmod +x "nvim"
  installed=true
fi

# Wezterm if not installed
# Filename from wezterm site, make version variable for latest if desired
WEZTERM_FILENAME="WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage"
WEZTERM_APPIMAGE="$HOME/dotfiles/shared/apps/bin/wezterm"
alias wezterm="$WEZTERM_APPIMAGE"

if [ ! -f "$WEZTERM_APPIMAGE" ]; then
  echo "Installing Wezterm"
  mkdir -p "$HOME/dotfiles/shared/apps/bin"
  curl -fsSL -o "$HOME/dotfiles/shared/apps/bin/wezterm" "https://github.com/wezterm/wezterm/releases/download/20240203-110809-5046fc22/$WEZTERM_FILENAME"
  chmod +x "$HOME/dotfiles/shared/apps/bin/wezterm"
  installed=true
fi

# Install Vifm AppImage if not present
VIFM_VERSION="v0.14.2"
VIFM_APPIMAGE="$HOME/dotfiles/shared/apps/bin/vifm"

if [ ! -f "$VIFM_APPIMAGE" ]; then
  echo "Installing Vifm AppImage $VIFM_VERSION..."
  mkdir -p "$HOME/dotfiles/shared/apps/bin/"
  curl -fsSL "https://prdownloads.sourceforge.net/vifm/vifm-${VIFM_VERSION}-x86_64.AppImage?download" -o "$VIFM_APPIMAGE"
  chmod +x "$VIFM_APPIMAGE"
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


