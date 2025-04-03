return {
  {
    "folke/tokyonight.nvim",
    priority = 1000, -- Ensure it loads first
    config = function()
      require("tokyonight").setup {
        style = "night",
        transparent = true,
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = true },
          keywords = { bold = true, italic = true },
          functions = {},
          variables = {},
          -- Background styles. Can be "dark", "transparent" or "normal"
          sidebars = "dark", -- style for sidebars, see below
          floats = "dark", -- style for floating windows
        },
        dim_inactive = true,

        on_colors = function(colors)
          -- local util = require("tokyonight.util")

          -- aplugin.background = colors.bg_dark
          -- aplugin.my_error = util.lighten(colors.red1, 0.3) -- number between 0 and 1. 0 results in white, 1 results in red1
          -- colors = {
          --   yellow = color.darken("yellow", 7, "onelight"),
          --   orange = color.darken("orange", 7, "onelight"),
          --   comment_color = color.darken("gray", 10, "onelight"),
          --   -- my_new_green = "require('onedarkpro.helpers').darken('green', 10, 'onedark')"
          -- }
        end,
        on_highlights = function(highlights, colors)
          -- highlights = {
          --   Comment = { fg = "${comment_color}", italic = true, bold = true }
          --   CocFloating = { bg = "${white}" },
          --   CocFloatingBorder = { fg = "${gray}", bg = "${white}" },
          -- --   Error = {
          -- --     fg = "${my_new_red}",
          -- --     bg = "${my_new_green}"
          -- --   },
          -- }
        end
      }
      vim.cmd("colorscheme tokyonight-night")
    end
  }
}

--[[
=============================================================================
Color keys/values from OneDarkPro's "onelight" theme
=============================================================================
{
    bg = "#fafafa",
    fg = "#6a6a6a",
    red = "#e05661",
    orange = "#ee9025",
    yellow = "#eea825",
    green = "#1da912",
    cyan = "#56b6c2",
    blue = "#118dc3",
    purple = "#9a77cf",
    white = "#fafafa",
    black = "#6a6a6a",
    gray = "#bebebe",
    highlight = "#e2be7d",
    comment = "#9b9fa6",
    none = "NONE",
}
--]]
