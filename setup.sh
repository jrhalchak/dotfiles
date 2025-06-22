#!/bin/sh

set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")"; pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup"

link() {
  src="$1"
  dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ]; then
      rm "$dest"
    else
      mkdir -p "$BACKUP_DIR"
      base="$(basename "$dest")"
      backup="$BACKUP_DIR/$base"
      i=1
      while [ -e "$backup" ]; do
        backup="$BACKUP_DIR/${base}.$i"
        i=$((i+1))
      done
      mv "$dest" "$backup"
    fi
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "Linked $src -> $dest"
}

link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
link "$DOTFILES_DIR/config/neorg" "$HOME/.config/neorg"
link "$DOTFILES_DIR/config/wezterm" "$HOME/.config/wezterm"
