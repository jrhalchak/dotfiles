local constants = require"constants"

return {
  "zaldih/themery.nvim",
  lazy = false,
  dependencies = constants.THEMES,
  config = function()
    require"themery".setup {
      -- add the config here
      themes = constants.THEME_NAMES
    }

    vim.cmd[[
      hi Normal guibg=NONE ctermbg=NONE
      colorscheme tokyo-night-dark
    ]]
  end
}
