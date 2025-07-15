local neorg = require('neorg.core')
local parser = require("neorg_todos.parser")
local utils = require("neorg_todos.utils")
local state = require("neorg_todos.state")

local dirman = neorg.modules.get_module('core.dirman')

local M = {}

function M.render()
  vim.api.nvim_set_option_value('modifiable', true, { buf = state.buf })
  local win_width = vim.api.nvim_win_get_width(state.win)
  local workspace = dirman.get_current_workspace()
  local files = {}
d- ocal result =hparser.find_files(workspace)

  for k in pairs(result) do
    local item = utils.split_str(result[k], ':')
    local path = vim.trim(string.gsub(item[1], workspace[2] .. '/', ''))
    local output = vim.trim(item[2])

    if files[path] and type(files[path]) == 'table' then
      table.insert(files[path], output)
    elseif files[path] then
      files[path] = {
        files[path]
      }
      table.insert(files[path], output)
    else
      files[path] = output
    end
  end

  local lines = {
    { type = "header", text = "Outstanding Todos", icon = "󰄯" },
    { type = "button", text = "Sort: None", selected = false },
    { type = "button", text = "Group By: File", selected = true },
    { type = "spacer" },
  }

  -- print(vim.inspect(files))

  function append_line(ln)
    local line_pad = '      '
    local cutoff = win_width - (#line_pad * 2)
    local line_item = ln:sub(0, cutoff)

    if #ln > cutoff then
      line_item = line_item .. ''
    end

    table.insert(lines, line_pad .. line_item)
  end

  -- TODO: Change this to use 1 table with lines and files that can be used
  -- to insert the entry, but also to grab the file path based on line # when
  -- <CR> is pressed
  for k,v in pairs(files) do
    -- header
    table.insert(lines, '    ** ' .. k);

    -- todos
    if type(v) == 'table' then
      for _,ln in pairs(v) do
        append_line(ln)
      end
    else
      append_line(v)
    end

    -- spacer line
    table.insert(lines, '')
  end

  if #result == 0 then
    local line_start = math.floor(vim.api.nvim_win_get_height(win) / 2) - 1
    local title = '* */No Outstanding Todos/* 🎉'
    local left_offset = math.floor(win_width / 2) - math.floor(string.len(title) / 2)

    lines = {}

    for i=1,line_start do
      table.insert(lines, '')
    end
    table.insert(lines, string.rep(' ', left_offset) .. title)
  end

  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', true, { buf = state.buf })

  -- local items_count =  vim.api.nvim_win_get_height(win) - 1
  -- local res = {}
  -- local files = get_norg_files()
  --
  -- if not files or not files[2] then
  --   return
  -- end
  --
  -- local ts = neorg.modules.get_module('core.integrations.treesitter')
  --
  -- for _, file in pairs(files[2]) do
  --   local bufnr = dirman.get_file_bufnr(file)
  --
  --   local title = nil
  --   local title_display = ''
  --   if ts then
  --     local metadata = ts.get_document_metadata(bufnr)
  --     if metadata and metadata.title then
  --       title = metadata.title
  --       title_display = ' [' .. title .. ']'
  --     end
  --   end
  --
  --   if vim.api.nvim_get_current_buf() ~= bufnr then
  --     local links = {
  --       file = file,
  --       display = '$' .. file:sub(#files[1] + 1, -1) .. title_display,
  --       relative = file:sub(#files[1] + 1, -1):sub(0, -6),
  --       title = title,
  --     }
  --     table.insert(res, links)
  --   end
  -- end

  -- for i = #oldfiles, #oldfiles - items_count, -1 do
  --   pcall(function()
  --     local path = vim.api.nvim_call_function('fnamemodify', {oldfiles[i], ':.'})
  --     table.insert(list, #list + 1, path)
  --   end)
  -- end
  --
  -- vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)
  -- vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

-- TODO : make configurable? At least abstract out objects for looping
function M.create_highlights()
  -- Define highlight groups (once)
  vim.api.nvim_set_hl(0, "TodosHeader", { fg = "#ffffff", bg = "#5f5faf", bold = true })
  vim.api.nvim_set_hl(0, "TodosButton", { fg = "#ffffff", bg = "#3c1361", bold = true })
  vim.api.nvim_set_hl(0, "TodosButtonSelected", { fg = "#22223b", bg = "#b491c8", bold = true })
  vim.api.nvim_set_hl(0, "TodosFile", { fg = "#b4befe", bg = "#1e1e2e", bold = true })
  vim.api.nvim_set_hl(0, "TodosTodo", { fg = "#ffaf00", bg = "#22223b" })
end

function M.create_win()
  local start_win = vim.api.nvim_get_current_win()

  -- 2/5ths?
  local width = math.ceil(vim.api.nvim_win_get_width(start_win) / 5 * 2);
  vim.api.nvim_command('botright ' .. width .. ' vnew')

  state.win = vim.api.nvim_get_current_win()
  state.buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_set_name(0, 'Todos #' .. state.buf)

  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = 0 })
  vim.api.nvim_set_option_value('swapfile', false, { buf = 0 })
  vim.api.nvim_set_option_value('filetype', 'neorg_todos_ui', { buf = 0 })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = 0 })

  -- vim.api.nvim_command('setlocal nowrap')
  vim.api.nvim_command('setlocal cursorline')
end

function M.set_mappings()
  local mappings = {
    q = 'close()',
    ['<cr>'] = 'open_and_close()',
    v = 'split("v")',
    s = 'split("")',
    p = 'preview()',
    t = 'open_in_tab()'
  }

  for k,v in pairs(mappings) do
    vim.api.nvim_buf_set_keymap(state.buf, 'n', k, ':lua require"nvim-oldfile".'..v..'<cr>', {
        nowait = true, noremap = true, silent = true
      })
  end
end

return M
