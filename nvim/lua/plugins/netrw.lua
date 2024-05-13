local keymaps = require"core.keymaps"

return {
  "prichrd/netrw.nvim",
  dependencies = {
  },
  config = function()
    require"netrw".setup {
      -- configuration.
      -- icons = {
      --   symlink = "", -- Symlink icon (directory and file)
      --   directory = "", -- Directory icon
      --   file = "", -- File icon
      -- },
      use_devicons = true, -- Uses nvim-web-devicons if true, otherwise use the file icon specified above
      mappings = keymaps.netrw -- Custom key mappings
    }
  end
}
