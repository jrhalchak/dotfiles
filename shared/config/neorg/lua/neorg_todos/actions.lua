local state = require("neorg_todos.state")
local list_manager = require("neorg_todos.list_manager")

local M = {}

function M.move_cursor_down()
  if not state.content_win or not vim.api.nvim_win_is_valid(state.content_win) then
    return
  end
  
  local new_line = list_manager.get_next_selectable(state.virtual_list, state.selected_line)
  state.selected_line = new_line
  
  local buffer_line = state.virtual_to_buffer_line[new_line] or new_line
  local win_height = vim.api.nvim_win_get_height(state.content_win)
  
  if buffer_line >= state.topline + win_height then
    state.topline = buffer_line - win_height + 1
    vim.api.nvim_win_call(state.content_win, function()
      vim.fn.winrestview({topline = state.topline})
    end)
  end
  
  vim.api.nvim_win_set_cursor(state.content_win, {buffer_line, 0})
end

function M.move_cursor_up()
  if not state.content_win or not vim.api.nvim_win_is_valid(state.content_win) then
    return
  end
  
  local new_line = list_manager.get_prev_selectable(state.virtual_list, state.selected_line)
  state.selected_line = new_line
  
  local buffer_line = state.virtual_to_buffer_line[new_line] or new_line
  
  if buffer_line < state.topline then
    state.topline = buffer_line
    vim.api.nvim_win_call(state.content_win, function()
      vim.fn.winrestview({topline = state.topline})
    end)
  end
  
  vim.api.nvim_win_set_cursor(state.content_win, {buffer_line, 0})
end

function M.move_to_next_group()
  if not state.content_win or not vim.api.nvim_win_is_valid(state.content_win) then
    return
  end
  
  local new_line = list_manager.get_next_group(state.virtual_list, state.selected_line)
  state.selected_line = new_line
  
  local buffer_line = state.virtual_to_buffer_line[new_line] or new_line
  local win_height = vim.api.nvim_win_get_height(state.content_win)
  
  if buffer_line >= state.topline + win_height then
    state.topline = buffer_line - win_height + 1
    vim.api.nvim_win_call(state.content_win, function()
      vim.fn.winrestview({topline = state.topline})
    end)
  end
  
  vim.api.nvim_win_set_cursor(state.content_win, {buffer_line, 0})
end

function M.move_to_prev_group()
  if not state.content_win or not vim.api.nvim_win_is_valid(state.content_win) then
    return
  end
  
  local new_line = list_manager.get_prev_group(state.virtual_list, state.selected_line)
  state.selected_line = new_line
  
  local buffer_line = state.virtual_to_buffer_line[new_line] or new_line
  
  if buffer_line < state.topline then
    state.topline = buffer_line
    vim.api.nvim_win_call(state.content_win, function()
      vim.fn.winrestview({topline = state.topline})
    end)
  end
  
  vim.api.nvim_win_set_cursor(state.content_win, {buffer_line, 0})
end

function M.cycle_sort()
  local modes = state.config.sort_modes
  local current_idx = 1
  for i, mode in ipairs(modes) do
    if mode == state.sort_mode then
      current_idx = i
      break
    end
  end
  
  local next_idx = (current_idx % #modes) + 1
  state.sort_mode = modes[next_idx]
  
  local ui = require("neorg_todos.ui")
  ui.render()
end

function M.cycle_group()
  local modes = state.config.group_modes
  local current_idx = 1
  for i, mode in ipairs(modes) do
    if mode == state.group_mode then
      current_idx = i
      break
    end
  end
  
  local next_idx = (current_idx % #modes) + 1
  state.group_mode = modes[next_idx]
  
  local ui = require("neorg_todos.ui")
  ui.render()
end

function M.cycle_filter()
  local modes = state.config.filter_modes
  local current_idx = 1
  for i, mode in ipairs(modes) do
    if mode == state.filter_mode then
      current_idx = i
      break
    end
  end
  
  local next_idx = (current_idx % #modes) + 1
  state.filter_mode = modes[next_idx]
  
  local ui = require("neorg_todos.ui")
  ui.render()
end

function M.toggle_heading_context()
  state.show_heading_context = not state.show_heading_context
  
  local ui = require("neorg_todos.ui")
  ui.render()
end

function M.open_todo_at_cursor()
  local item = list_manager.get_item_at_line(state.virtual_list, state.selected_line)
  if not item then
    return
  end
  
  if item.type == "todo" and item.file and item.line then
    local windows = vim.api.nvim_list_wins()
    local target_win = nil
    
    for _, win in ipairs(windows) do
      if win ~= state.content_win and win ~= state.header_win then
        target_win = win
        break
      end
    end
    
    if not target_win then
      vim.cmd("wincmd p")
      target_win = vim.api.nvim_get_current_win()
    else
      vim.api.nvim_set_current_win(target_win)
    end
    
    vim.cmd("edit " .. vim.fn.fnameescape(item.file))
    vim.api.nvim_win_set_cursor(target_win, {item.line, 0})
    vim.cmd("normal! zz")
  elseif item.type == "group_header" and item.key then
    if item.key:match("%.norg$") then
      local windows = vim.api.nvim_list_wins()
      local target_win = nil
      
      for _, win in ipairs(windows) do
        if win ~= state.content_win and win ~= state.header_win then
          target_win = win
          break
        end
      end
      
      if not target_win then
        vim.cmd("wincmd p")
        target_win = vim.api.nvim_get_current_win()
      else
        vim.api.nvim_set_current_win(target_win)
      end
      
      vim.cmd("edit " .. vim.fn.fnameescape(item.key))
    end
  end
end

function M.close()
  if state.header_win and vim.api.nvim_win_is_valid(state.header_win) then
    vim.api.nvim_win_close(state.header_win, true)
  end
  if state.content_win and vim.api.nvim_win_is_valid(state.content_win) then
    vim.api.nvim_win_close(state.content_win, true)
  end
  state.header_win = nil
  state.content_win = nil
  state.header_buf = nil
  state.content_buf = nil
end

function M.refresh()
  local ui = require("neorg_todos.ui")
  ui.render()
end

return M
