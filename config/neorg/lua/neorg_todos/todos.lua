--
-- TODO
-- Setup custom concealers for links and such: https://www.youtube.com/watch?v=8fCkt5qgHw8
-- More about treesitter here: https://www.youtube.com/watch?v=09-9LltqWLY
--

--
-- TODO
-- From the neorg discord in response to me asking about querying the tree:
-- You can query the treesitter tree. There's a query language (the scm you mention) and a few functions. :h treesitter-query for query basics, :h vim.treesitter.query.parse() for parsing a query :h lua-treesitter-query to see what you can do with that
--

-- lua/neorg_todos/todos.lua
local M = {}

local buf, win, start_win

local function map(mode, lhs, rhs, opts)
  local options = { noremap=true, silent=true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function split_str(input_str, sep)
  if sep == nil then
    sep = '%s'
  end

  local sep_index = string.find(input_str, sep) or 0

  return {
    string.sub(input_str, 0, sep_index),
    string.sub(input_str, sep_index + 1, #input_str),
  }
end

local function redraw()
  vim.api.nvim_set_option_value('modifiable', true, { buf = buf })

  local neorg = require('neorg.core')
  local dirman = neorg.modules.get_module('core.dirman')

  if not dirman then
    return nil
  end

  local files = {}
  local workspace = dirman.get_current_workspace();

  local result = vim.fn.systemlist('rg "[-~] \\([^(x|_)]\\)" '.. workspace[2] .. '/**/*.norg')
  local win_width = vim.api.nvim_win_get_width(win)

  for k in pairs(result) do
    local item = split_str(result[k], ':')
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
    '',
    '',
    '    * Outstanding Todos',
    '',
    '',
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


  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', true, { buf = buf })

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

local function set_mappings()
  local mappings = {
    q = 'close()',
    ['<cr>'] = 'open_and_close()',
    v = 'split("v")',
    s = 'split("")',
    p = 'preview()',
    t = 'open_in_tab()'
  }

  for k,v in pairs(mappings) do
    vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"nvim-oldfile".'..v..'<cr>', {
        nowait = true, noremap = true, silent = true
      })
  end
end

local function create_win()
  start_win = vim.api.nvim_get_current_win()

  -- 2/5ths?
  local width = math.ceil(vim.api.nvim_win_get_width(start_win) / 5 * 2);
  vim.api.nvim_command('botright ' .. width .. ' vnew')

  win = vim.api.nvim_get_current_win()
  buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_set_name(0, 'Todos #' .. buf)

  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = 0 })
  vim.api.nvim_set_option_value('swapfile', false, { buf = 0 })
  vim.api.nvim_set_option_value('filetype', 'norg', { buf = 0 })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = 0 })

  -- vim.api.nvim_command('setlocal nowrap')
  vim.api.nvim_command('setlocal cursorline')

  set_mappings()
end

local function todos()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
  else
    create_win()
  end

  redraw()
end

-- todos()

local function debounce(fn)
  local timer = vim.loop.new_timer()

  return function(...)
    local argv = {...}
    local argc = select('#', ...)

    timer:start(500, 0, function()
      pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
    end)
  end, timer
end

-- vim.api.nvim_create_autocmd("VimResized", { callback = redraw })
-- vim.api.nvim_create_autocmd("WinResized", {
--   callback = debounce(redraw)
-- })

function M.open()
  -- This is your todos() function
  -- if win and vim.api.nvim_win_is_valid(win) then
  --   vim.api.nvim_set_current_win(win)
  -- else
  --   create_win()
  -- end
  -- redraw()
end

--
-- TODO
-- When you add git, use this for the commit timestamp:
-- date --rfc-3339=seconds
-- Like:
-- eval "git commit --amend -m \"$(date --rfc-3339=seconds)\""
-- NOTE: You'll need to use gdate if on MacOS to keep the same command/ouput
--

--
-- TODO
-- Look at https://github.com/jbyuki/venn.nvim
--

--
-- TODO
-- Look at https://github.com/nvim-neorocks/rocks.nvim
--

vim.api.nvim_create_user_command('OpenTodos', todos, {})

-- vim.api.nvim_create_autocmd({ 'BufWritePost', 'FileWritePost'}, {
--   pattern = { '*.norg' },
--   callback = todos,
-- })

-- TODO
-- to update runtimepath when passing in the config
-- to use (like with neorg alias)

-- local function open()
--   local path = vim.api.nvim_get_current_line()
--
--   if vim.api.nvim_win_is_valid(start_win) then
--     vim.api.nvim_set_current_win(start_win)
--     vim.api.nvim_command('edit ' .. path)
--   else
--     vim.api.nvim_command('botright vsplit ' .. path)
--     start_win = vim.api.nvim_get_current_win()
--   end
-- end
--
-- local function close()
--   if win and vim.api.nvim_win_is_valid(win) then
--     vim.api.nvim_win_close(win, true)
--   end
-- end
--
-- local function open_and_close()
--   open()
--   close()
-- end
--
-- local function preview()
--   open()
--   vim.api.nvim_set_current_win(win)
-- end
--
-- local function split(axis)
--   local path = vim.api.nvim_get_current_line()
--
--   if vim.api.nvim_win_is_valid(start_win) then
--     vim.api.nvim_set_current_win(start_win)
--     vim.api.nvim_command(axis ..'split ' .. path)
--   else
--     vim.api.nvim_command('botright ' .. axis..'split ' .. path)
--   end
--
--   close()
-- end
--
-- local function open_in_tab()
--   local path = vim.api.nvim_get_current_line()
--
--   vim.api.nvim_command('tabnew ' .. path)
--   close()
-- end

-- TODO: add a boolean to "regrep" the results and rebuild it, otherwise we
-- can just use it as a render method so it doesn't re-pull and modify
-- everything again
-- open workspace index on start

--- Get a list of all norg files in current workspace. Returns { workspace_path, norg_files }
--- @return table|nil
-- local function get_norg_files()
--     local dirman = neorg.modules.get_module('core.dirman')
--
--     if not dirman then
--         return nil
--     end
--
--     local current_workspace = dirman.get_current_workspace()
--
--     local norg_files = dirman.get_norg_files(current_workspace[1])
--
--     return { current_workspace[2], norg_files }
-- end

return M
