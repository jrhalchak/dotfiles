return {
  {
    "dhruvasagar/vim-table-mode",
    ft = { "norg", "markdown", "text", "org" },
    init = function()
      vim.g.table_mode_corner = "|"
    end,
  },
}
