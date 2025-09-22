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
      "🧽 Clean Cache") sudo apt clean ;;
      "🔄 Update System") sudo apt update && sudo apt upgrade -y ;;
      "📂 List Disk Usage") du -h --max-depth=1 ;;
      "🔙 Back") exec "$0" ;; # Restart script
    esac
    ;;

  "🧰 Dev Tools")
    ACTION=$(gum choose "📝 Open Neovim" "🧪 Run Tests" "📦 Build Project" "🔙 Back")
    case "$ACTION" in
      "📝 Open Neovim") nvim ;;
      "🧪 Run Tests") bash ~/dotfiles/scripts/run_tests.sh ;;
      "📦 Build Project") make build ;;
      "🔙 Back") exec "$0" ;;
    esac
    ;;

  "⚙️  Dotfile Scripts")
    ACTION=$(gum choose "🚀 Setup Dev Env" "📁 Link Dotfiles" "🕵️ Show Git Status" "🔙 Back")
    case "$ACTION" in
      "🚀 Setup Dev Env") bash ~/dotfiles/scripts/dev_setup.sh ;;
      "📁 Link Dotfiles") bash ~/dotfiles/link_dotfiles.sh ;;
      "🕵️ Show Git Status") git -C ~/dotfiles status ;;
      "🔙 Back") exec "$0" ;;
    esac
    ;;
esac
