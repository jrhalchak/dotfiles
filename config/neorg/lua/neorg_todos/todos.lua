-- TODO
-- Setup custom concealers for links and such: https://www.youtube.com/watch?v=8fCkt5qgHw8
-- More about treesitter here: https://www.youtube.com/watch?v=09-9LltqWLY

local ui = require("neorg_todos.ui")
local state = require("neorg_todos.state")

-- lua/neorg_todos/todos.lua
local M = {}

function M.open()
  -- This is your todos() function
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
  else
    ui.create_win()
    -- TODO move this out?
    ui.set_mappings()
  end
  ui.render()
end

vim.api.nvim_create_user_command('OpenTodos', M.open, {})

-- vim.api.nvim_create_autocmd({ 'BufWritePost', 'FileWritePost'}, {
--   pattern = { '*.norg' },
--   callback = todos,
-- })

return M
