# ------------------------------------------------------------
# -- Mac linux-utils
# ------------------------------------------------------------

# If you need to have util-linux first in your PATH, run:
export PATH="/usr/local/opt/util-linux/bin:$PATH"
export PATH="/usr/local/opt/util-linux/sbin:$PATH"

# For compilers to find util-linux you may need to set:
export LDFLAGS="-L/usr/local/opt/util-linux/lib"
export CPPFLAGS="-I/usr/local/opt/util-linux/include"

# For pkg-config to find util-linux you may need to set:
export PKG_CONFIG_PATH="/usr/local/opt/util-linux/lib/pkgconfig"

# ------------------------------------------------------------
# -- /Mac linux-utils
# ------------------------------------------------------------
