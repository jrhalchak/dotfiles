local todos = require("neorg_todos.todos")
local state = require("neorg_todos.state")

local M = {
  open = todos.open,
}

function M.setup(opts)
  opts = opts or {}
  
  if opts.sort_default then
    state.sort_mode = opts.sort_default
  end
  
  if opts.group_default then
    state.group_mode = opts.group_default
  end
  
  if opts.filter_default then
    state.filter_mode = opts.filter_default
  end
  
  if opts.show_heading_context ~= nil then
    state.show_heading_context = opts.show_heading_context
  end
  
  if opts.icons then
    state.config.icons = vim.tbl_extend("force", state.config.icons, opts.icons)
  end
  
  if opts.custom_filters then
    for name, fn in pairs(opts.custom_filters) do
      table.insert(state.config.filter_modes, name)
      local processing = require("neorg_todos.processing")
      processing["filter_" .. name] = fn
    end
  end
end

return M
