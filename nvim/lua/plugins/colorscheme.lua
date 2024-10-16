return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- Ensure it loads first
    config = function()
      local color = require("onedarkpro.helpers")

      require("onedarkpro").setup {
        options = {
          transparency = true,
        },
        styles = {
          -- types = "NONE",
          -- methods = "NONE",
          -- numbers = "NONE",
          -- strings = "NONE",
          -- comments = "italic",
          keywords = "bold,italic",
          -- constants = "NONE",
          -- functions = "italic",
          -- operators = "NONE",
          -- variables = "NONE",
          -- parameters = "NONE",
          -- conditionals = "italic",
          -- virtual_text = "NONE",
        },
        colors = {
          yellow = color.darken("yellow", 7, "onelight"),
          orange = color.darken("orange", 7, "onelight"),
          comment_color = color.darken("gray", 10, "onelight"),
        --   my_new_green = "require('onedarkpro.helpers').darken('green', 10, 'onedark')"
        },
        highlights = {
          Comment = { fg = "${comment_color}", italic = true, bold = true },
          CocFloating = { bg = "${white}" },
          CocFloatingBorder = { fg = "${gray}", bg = "${white}" },
        --   Error = {
        --     fg = "${my_new_red}",
        --     bg = "${my_new_green}"
        --   },
        }
      }
      vim.cmd("colorscheme onelight")
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
