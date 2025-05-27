local keymaps = require("config.keymaps")

return {
  {
    'prichrd/netrw.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    config = function()
      require("netrw").setup({
        -- File icons to use when `use_devicons` is false or if
        -- no icon is found for the given file type.
        icons = {
          symlink = '',
          directory = '',
          file = '',
        },
        -- Uses mini.icon or nvim-web-devicons if true, otherwise use the file icon specified above
        use_devicons = true,
        mappings = keymaps.get_netrw(),
      })
    end,
  }
}
