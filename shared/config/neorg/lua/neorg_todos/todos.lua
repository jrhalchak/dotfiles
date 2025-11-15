-- TODO
-- Setup custom concealers for links and such: https://www.youtube.com/watch?v=8fCkt5qgHw8
-- More about treesitter here: https://www.youtube.com/watch?v=09-9LltqWLY

local ui = require("neorg_todos.ui")
local state = require("neorg_todos.state")

local M = {}

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
  else
    ui.create_highlights()
    ui.create_win()
    ui.set_mappings()
    M.setup_autocmds()
  end
  ui.render()
  
  local list_manager = require("neorg_todos.list_manager")
  state.selected_line = list_manager.find_first_selectable(state.virtual_list)
  
  if state.content_win and vim.api.nvim_win_is_valid(state.content_win) then
    local buffer_line = state.virtual_to_buffer_line[state.selected_line]
    if buffer_line then
      vim.api.nvim_win_set_cursor(state.content_win, {buffer_line, 0})
    end
  end
end

function M.setup_autocmds()
  local augroup = vim.api.nvim_create_augroup("NeorgTodos", { clear = true })
  
  vim.api.nvim_create_autocmd({"BufWritePost"}, {
    group = augroup,
    pattern = "*.norg",
    callback = function()
      if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.schedule(function()
          ui.render()
        end)
      end
    end,
  })
  
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_create_autocmd("BufWinLeave", {
      group = augroup,
      buffer = state.buf,
      callback = function()
        state.win = nil
        state.buf = nil
      end,
    })
  end
end

print("NEORG TODOS MODULE LOADED")
vim.api.nvim_create_user_command('OpenTodos', M.open, {})

return M
