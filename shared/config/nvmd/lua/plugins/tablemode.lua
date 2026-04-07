return {
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "text" },
    init = function()
      vim.g.table_mode_corner = "|"
    end,
  },
}
