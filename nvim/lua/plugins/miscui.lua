local keymaps = require("config.keymaps")

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
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    -- optionally, override the default options:
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end
  },
  {
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true, -- or `opts = {}`
  },
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      toggle = {
        -- your toggle configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    }
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- configuration goes here
    },
    -- Just adding them in keymaps.lua
    -- keys = {},
    config = function()
      keymaps.setup();
    end
  }
}
