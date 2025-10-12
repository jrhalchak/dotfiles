#!/bin/bash

# Exit this script early if running on macOS (Darwin)
if [ "$(uname)" = "Darwin" ]; then
  echo "No configuration for MacOS"
  return 0
fi

# First menu: choose category
CATEGORY=$(gum choose "📦 System Utilities" "🧰 Dev Tools" "⚙️  Dotfile Scripts" "❌ Quit")
[[ -z "$CATEGORY" || "$CATEGORY" == "❌ Quit" ]] && exit

# Second menu: actions within each category
case "$CATEGORY" in
  "📦 System Utilities")
    ACTION=$(gum choose "🧽 Clean Cache" "🔄 Update System" "📂 List Disk Usage" "🔙 Back")
    case "$ACTION" in
      "🔉 Pulseaudio Mixer") pulsemixer ;;
      "📓 Sync Neorg Notes (personal)") notesync ;;
      "📔 Sync Neorg Notes (omni)") notesync omni ;;
      "🗒️ Sync Neorg Notes (work)") notesync work ;;
      "🧽 Clean Cache") sudo apt clean ;;
      "📂 List Disk Usage") du -h --max-depth=1 ;;
      "🔙 Back") exec "$0" ;; # Restart script
    esac
    ;;

  "🧰 Dev Tools")
    ACTION=$(gum choose "📝 Open Neovim" "🧪 Run Tests" "📦 Build Project" "🔙 Back")
    case "$ACTION" in
      "🛳️ Lazdocker") lazydocker ;;
      "🤖 Opencode (here)") opencode . ;;
      "🐱 Lazgit") lazygit ;;
      "📝 Open Neovim") nvim ;;
      "🚒 Start Docker Engine") sudo systemctl start docker ;;
      "🔙 Back") exec "$0" ;;
    esac
    ;;

  "⚙️  Dotfile Scripts")
    ACTION=$(gum choose "🚀 Setup Dev Env" "📁 Link Dotfiles" "🕵️ Show Git Status" "🔙 Back")
    case "$ACTION" in
      "⌨️ Fix Inputs (Esc remap + Inverse Scroll") bash ~/dotfiles/scripts/sys/input.sh ;;
      "🚀 Setup Dotfiles") bash ~/dotfiles/setup.sh ;;
      "⤵️ App Auto-Install (Deb-based only)") bash ~/dotfiles/scripts/sys/deb/installs.sh ;;
      "🕵️ Show Git Status") git -C ~/dotfiles status ;;
      "🔙 Back") exec "$0" ;;
    esac
    ;;
esac
