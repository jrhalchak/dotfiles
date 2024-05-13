return {
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      local devicons = require"nvim-web-devicons"

      devicons.setup {
        override = {
          norg = {
            icon = "", -- Default icon for Header 1
            color = "#4878BE",
            name = "Norg",
          },
        },
        default = true,
      }

      local default_icons = devicons.get_icons()

      devicons.set_icon {
        pyi = default_icons.pyd,
        latex = default_icons.tex,
        [".latexmkrc"] = default_icons.tex,
        sty = default_icons.tex,
        [".pylintrc"] = default_icons.toml,
        [".python-version"] = default_icons.toml,
        ["Makefile"] = default_icons.makefile,
      }
    end,
  },
}
