local M = {}

M.options = {
  conceal_on_move = true,
  conceal_on_change = true,
  conceal_insert_toggle = true,
}

local conceal = require("bdiagram.conceal")

local function clear_bdiagram_conceal(bufnr, start_row, end_row)
  vim.api.nvim_buf_clear_namespace(bufnr, conceal.namespace, start_row, end_row+1)
end

local function conceal_visible_bdiagrams()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_row = vim.fn.line("w0") - 1  -- 0-based
  local end_row = vim.fn.line("w$") - 1
  conceal.conceal_bdiagram(bufnr, start_row, end_row)
end

function M.setup(opts)
  local plugin_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local parser_path = plugin_dir:gsub("lua/bdiagram/$", "") .. "tree-sitter-bdiagram"

require'nvim-treesitter.parsers'.get_parser_configs().bdiagram = {
  install_info = {
    url = parser_path,
    files = { "src/parser.c" },
    branch = "main",
  },
}

  M.options = vim.tbl_deep_extend("force", M.options, opts or {})

  if M.options.conceal_on_change then
    vim.api.nvim_create_autocmd({"BufReadPost", "TextChanged", "TextChangedI"}, {
      pattern = "*.norg",
      callback = function()
        conceal_visible_bdiagrams()
      end,
    })
  end

  if M.options.conceal_on_move then
    vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
      pattern = "*.norg",
      callback = function()
        conceal_visible_bdiagrams()
      end,
    })
  end

  if M.options.conceal_insert_toggle then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "norg",
      callback = function(args)
        local bufnr = args.buf

        vim.api.nvim_create_autocmd({"InsertEnter"}, {
          buffer = bufnr,
          callback = function()
            clear_bdiagram_conceal(bufnr, 0, vim.api.nvim_buf_line_count(bufnr)-1)
          end,
          desc = "Clear bdiagram conceals in insert mode"
        })
        vim.api.nvim_create_autocmd({"InsertLeave"}, {
          buffer = bufnr,
          callback = function()
            require("bdiagram.conceal").conceal_bdiagram(bufnr, 0, vim.api.nvim_buf_line_count(bufnr)-1)
          end,
          desc = "Restore bdiagram conceals after insert mode"
        })
      end,
    })
  end

  vim.api.nvim_create_user_command("BdiagramConceal", function()
    conceal_visible_bdiagrams()
  end, {})

  vim.schedule(function()
    vim.notify("bdiagram: ASCII diagram conceal loaded", vim.log.levels.INFO)
  end)
end

return M
