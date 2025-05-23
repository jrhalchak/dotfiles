# - Use symlinks for both files and directories.
# - Consider using `ln -sf` to force overwrite existing links.
# - Optionally, back up existing files before linking.
#
# **Example:**
# ```sh
# ln -sf "$(pwd)/zsh/.zshrc" ~/.zshrc
# ln -sf "$(pwd)/nvim" ~/.config/nvim
# ```

