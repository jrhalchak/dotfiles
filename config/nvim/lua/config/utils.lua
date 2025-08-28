local M = {}

M.update_cmp_sel = function()
  local cmp = require('cmp')
  local entry = cmp.get_selected_entry()
  if not entry then return end

  local kind = entry:get_kind()
  local kind_name = vim.lsp.protocol.CompletionItemKind[kind]
  local hl = "CmpItemKind" .. kind_name

  -- Extract bg color from kind group
  local ok, kind_def = pcall(vim.api.nvim_get_hl_by_name, hl, true)
  if not ok or not kind_def.background then return end

  vim.api.nvim_set_hl(0, "CmpSel", {
    background = kind_def.background,
    foreground = kind_def.foreground or kind_def.bg or 0x000000,
    bold = true,
  })
end

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

local ORIGINAL_COVERAGE = nil

M.toggle_coverage_filter = function()
  local buf = vim.api.nvim_get_current_buf()

  if ORIGINAL_COVERAGE == nil then
    -- Store original and filter
    ORIGINAL_COVERAGE = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    local lines = ORIGINAL_COVERAGE
    local header_line = nil

    -- Find header
    for i, line in ipairs(lines) do
      if line:match("%%.*Stmts") and line:match("%%.*Branch") then
        header_line = i
        break
      end
    end

    if not header_line then
      vim.notify("Coverage table header not found", vim.log.levels.WARN)
      ORIGINAL_COVERAGE = nil
      return
    end

    local filtered_lines = {}

    -- Keep header section
    for i = 1, header_line + 1 do
      table.insert(filtered_lines, lines[i])
    end

    -- Filter for low coverage (under 60%)
    for i = header_line + 2, #lines do
      local line = lines[i]
      -- Look for lines with file paths and extract coverage percentages
      if line:match("%.ts") or line:match("%.js") or line:match("%.tsx") or line:match("%.jsx") then
        -- Extract all percentage values from the line
        local percentages = {}
        for pct in line:gmatch("%s+([0-9]+%.?[0-9]*)%s+") do
          table.insert(percentages, tonumber(pct))
        end

        -- Check if any percentage is below 60%
        local has_low_coverage = false
        for _, pct in ipairs(percentages) do
          if pct and pct < 60 then
            has_low_coverage = true
            break
          end
        end

        if has_low_coverage then
          table.insert(filtered_lines, line)
        end
      end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, filtered_lines)
    vim.notify("Showing low coverage only (<60%)", vim.log.levels.INFO)
  else
    -- Restore original
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, ORIGINAL_COVERAGE)
    ORIGINAL_COVERAGE = nil
    vim.notify("Restored full coverage table", vim.log.levels.INFO)
  end
end

return M;
