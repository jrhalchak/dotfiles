return {
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "text" },
    init = function()
      vim.g.table_mode_corner = "|"

      -- Remap all built-in maps to <leader>nt prefix
      vim.g.table_mode_toggle_map        = "ntt"  -- <leader>ntt
      vim.g.table_mode_relign_map        = "ntr"  -- <leader>ntr  (note: typo in upstream var name)
      vim.g.table_mode_tableize_map      = "ntT"  -- <leader>ntT  (Tableize CSV selection)
      vim.g.table_mode_tableize_op_map   = "ntz"  -- <leader>ntz  (Tableize with delimiter)
      vim.g.table_mode_add_formula_map   = "nta"  -- <leader>nta
      vim.g.table_mode_eval_expr_map     = "ntf"  -- <leader>ntf
      vim.g.table_mode_delete_row_map    = "ntdd" -- <leader>ntdd
      vim.g.table_mode_delete_column_map = "ntdc" -- <leader>ntdc
      vim.g.table_mode_insert_column_after_map  = "ntic"  -- <leader>ntic
      vim.g.table_mode_insert_column_before_map = "ntiC" -- <leader>ntiC
    end,
  },
}
