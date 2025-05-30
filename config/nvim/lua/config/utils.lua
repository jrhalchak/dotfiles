local M = {}

-- @tparam mode string which vim mode
-- @tparam lhs string a key combination
-- @tparam rhs string command to run
-- @tparam opts table vim keymap options
M.keymap = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end

  -- `nvim_set_keymap` doesn't accept a "buffer" option
  -- this is used for LSP
  if options.buffer then
    vim.keymap.set(mode, lhs, rhs, options)
  else
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
  end
end

M.open_plugin_url = function()
  local line = vim.api.nvim_get_current_line()
  local plugin = line:match([["([^"]+/[^"]+)"]])
  if not plugin then
    vim.notify("No plugin string found under cursor", vim.log.levels.ERROR)
    return
  end
  local url = "https://github.com/" .. plugin
  local open_cmd
  if vim.fn.has("macunix") == 1 then
    open_cmd = { "open", url }
  elseif vim.fn.has("unix") == 1 then
    open_cmd = { "xdg-open", url }
  else
    vim.notify("Unsupported OS for opening URLs", vim.log.levels.ERROR)
    return
  end
  vim.fn.jobstart(open_cmd, { detach = true })
end

-- M.lsp_on_attach = function(client, bufnr)
--   local keymaps = require"core.keymaps"
--
--   -- Enable completion triggered by <c-x><c-o>
--   vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })
--
--   -- Highlighting references.
--   -- See: https://sbulav.github.io/til/til-neovim-highlight-references/
--   -- for the highlight trigger time see: `vim.opt.updatetime`
--   if client.server_capabilities.documentHighlightProvider then
--       vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
--       vim.api.nvim_clear_autocmds { buffer = bufnr, group = "lsp_document_highlight" }
--       vim.api.nvim_create_autocmd("CursorHold", {
--           callback = vim.lsp.buf.document_highlight,
--           buffer = bufnr,
--           group = "lsp_document_highlight",
--           desc = "Document Highlight",
--       })
--       vim.api.nvim_create_autocmd("CursorMoved", {
--           callback = vim.lsp.buf.clear_references,
--           buffer = bufnr,
--           group = "lsp_document_highlight",
--           desc = "Clear All the References",
--       })
--   end
--
--   -- Mappings.
--   -- See `:help vim.lsp.*` for documentation on any of the below functions
--   local bufopts = { noremap=true, silent=true, buffer=bufnr }
--
--   -- Setup keymaps
--   for key, val in ipairs(keymaps.lsp) do
--     M.keymap("n", key, val, bufopts)
--   end
-- end

return M;
