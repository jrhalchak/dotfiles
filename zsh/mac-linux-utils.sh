# ------------------------------------------------------------
# -- Mac linux-utils
# ------------------------------------------------------------

# If you need to have util-linux first in your PATH, run:
# echo 'export PATH="/opt/homebrew/opt/util-linux/bin:$PATH"' >> ~/.zshrc
# echo 'export PATH="/opt/homebrew/opt/util-linux/sbin:$PATH"' >> ~/.zshrc

# For compilers to find util-linux you may need to set:
export LDFLAGS="-L/opt/homebrew/opt/util-linux/lib"
export CPPFLAGS="-I/opt/homebrew/opt/util-linux/include"

# For pkg-config to find util-linux you may need to set:
export PKG_CONFIG_PATH="/opt/homebrew/opt/util-linux/lib/pkgconfig"

# ------------------------------------------------------------
# -- /Mac linux-utils
# ------------------------------------------------------------
