local neorg = require("neorg.core")
local parser = require("neorg_todos.parser")
local processing = require("neorg_todos.processing")
local list_manager = require("neorg_todos.list_manager")
local state = require("neorg_todos.state")

local dirman = neorg.modules.get_module("core.dirman")

local M = {}

function M.create_highlights()
  vim.api.nvim_set_hl(0, "TodosHeader", { fg = "#ffffff", bg = "#5f5faf", bold = true })
  vim.api.nvim_set_hl(0, "TodosHeaderBorder", { fg = "#5f5faf" })
  vim.api.nvim_set_hl(0, "TodosButton", { fg = "#d0d0d0", bg = "#3c1361" })
  vim.api.nvim_set_hl(0, "TodosButtonSelected", { fg = "#22223b", bg = "#b491c8", bold = true })
  vim.api.nvim_set_hl(0, "TodosGroupHeader", { fg = "#b4befe", bg = "#2d2d3d", bold = true })
  vim.api.nvim_set_hl(0, "TodosGroupHeaderBorder", { fg = "#2d2d3d" })
  vim.api.nvim_set_hl(0, "TodosBoxBorder", { fg = "#4c4c5c" })
  vim.api.nvim_set_hl(0, "TodosStatusPending", { fg = "#6c7086" })
  vim.api.nvim_set_hl(0, "TodosStatusProgress", { fg = "#f9e2af" })
  vim.api.nvim_set_hl(0, "TodosStatusImportant", { fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "TodosStatusUnknown", { fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "TodosStatusHold", { fg = "#fab387" })
  vim.api.nvim_set_hl(0, "TodosHeadingContext", { fg = "#7f849c", italic = true })
  vim.api.nvim_set_hl(0, "TodosTodoText", { fg = "#cdd6f4" })
  vim.api.nvim_set_hl(0, "TodosEmpty", { fg = "#a6adc8", italic = true })
  
  local normal_bg = vim.api.nvim_get_hl(0, {name = "Normal"}).bg
  if normal_bg then
    vim.api.nvim_set_hl(0, "TodosStatusLine", { fg = normal_bg, bg = normal_bg })
  else
    vim.api.nvim_set_hl(0, "TodosStatusLine", { fg = "NONE", bg = "NONE" })
  end
end

local function get_status_icon(status)
  local icons = state.config.icons
  return icons[status] or icons.pending
end

local function capitalize(str)
  return str:sub(1, 1):upper() .. str:sub(2)
end

local function render_button(text, win_width)
  local padding = 1
  local content_width = #text + (padding * 2)
  local top_line = "▗" .. string.rep("▄", content_width) .. "▖"
  local mid_line = "▐" .. string.rep(" ", padding) .. text .. string.rep(" ", padding) .. "▌"
  local bot_line = "▝" .. string.rep("▀", content_width) .. "▘"
  
  return {top_line, mid_line, bot_line}
end

local function pad_center(text, width)
  local padding = math.floor((width - #text) / 2)
  return string.rep(" ", padding) .. text .. string.rep(" ", width - padding - #text)
end

local function pad_right(text, width)
  if #text >= width then
    return text:sub(1, width)
  end
  return text .. string.rep(" ", width - #text)
end

function M.render()
  if not state.content_buf or not vim.api.nvim_buf_is_valid(state.content_buf) then
    return
  end
  
  if state.rendering then
    return
  end
  
  state.rendering = true
  
  local workspace = dirman.get_current_workspace()
  if not workspace then
    vim.api.nvim_set_option_value("modifiable", true, { buf = state.content_buf })
    vim.api.nvim_buf_set_lines(state.content_buf, 0, -1, false, {"No workspace active"})
    vim.api.nvim_set_option_value("modifiable", false, { buf = state.content_buf })
    state.rendering = false
    return
  end
  
  local raw_todos = parser.find_and_parse_todos(workspace)
  state.raw_todos = raw_todos
  
  local filtered = processing.apply_filter(raw_todos, state.filter_mode)
  local sorted = processing.apply_sort(filtered, state.sort_mode)
  local grouped = processing.apply_group(sorted, state.group_mode)
  
  state.virtual_list = list_manager.build_virtual_list(
    grouped, 
    state.show_heading_context, 
    state.sort_mode, 
    state.group_mode, 
    state.filter_mode
  )
  
  local header_win_width = state.header_win and vim.api.nvim_win_is_valid(state.header_win)
    and vim.api.nvim_win_get_width(state.header_win) or 80
  local content_win_width = state.content_win and vim.api.nvim_win_is_valid(state.content_win)
    and vim.api.nvim_win_get_width(state.content_win) or 80
  
  M.render_header(header_win_width)
  M.render_content(content_win_width)
  
  state.rendering = false
end

function M.render_header(win_width)
  if not state.header_buf or not vim.api.nvim_buf_is_valid(state.header_buf) then
    return
  end
  
  vim.api.nvim_set_option_value("modifiable", true, { buf = state.header_buf })
  
  local lines = {}
  local highlights = {}
  
  table.insert(lines, "")
  local header_text = "  Outstanding Todos  "
  local padded = pad_center(header_text, win_width)
  table.insert(lines, padded)
  table.insert(highlights, {#lines, "TodosHeader", 0, -1})
  
  table.insert(lines, "")
  
  local sort_text = "Sort: " .. capitalize(state.sort_mode)
  local group_text = "Group: " .. capitalize(state.group_mode)
  local filter_text = "Filter: " .. capitalize(state.filter_mode)
  local button_parts = {sort_text, group_text, filter_text}
  
  if win_width < 80 then
    for i, part in ipairs(button_parts) do
      local line = "  ▐ " .. part .. " ▌"
      table.insert(lines, line)
      local start_col = 2
      local end_col = start_col + vim.fn.strlen("▐ " .. part .. " ▌")
      table.insert(highlights, {#lines, "TodosButton", start_col, end_col})
    end
  else
    local total_width = 0
    for _, part in ipairs(button_parts) do
      total_width = total_width + vim.fn.strlen("▐ " .. part .. " ▌") + 2
    end
    
    local spacing = math.max(2, math.floor((win_width - total_width) / 4))
    local line = string.rep(" ", spacing)
    local positions = {}
    
    for i, part in ipairs(button_parts) do
      local btn_text = "▐ " .. part .. " ▌"
      local start_col = vim.fn.strlen(line)
      line = line .. btn_text
      local end_col = vim.fn.strlen(line)
      table.insert(positions, {start_col, end_col})
      if i < #button_parts then
        line = line .. "  "
      end
    end
    
    table.insert(lines, line)
    
    for i, pos in ipairs(positions) do
      table.insert(highlights, {#lines, "TodosButton", pos[1], pos[2]})
    end
  end
  
  table.insert(lines, "")
  
  vim.api.nvim_buf_set_lines(state.header_buf, 0, -1, false, lines)
  
  local ns_id = vim.api.nvim_create_namespace("neorg_todos_header")
  vim.api.nvim_buf_clear_namespace(state.header_buf, ns_id, 0, -1)
  
  for _, hl in ipairs(highlights) do
    local line, group, col_start, col_end = hl[1], hl[2], hl[3], hl[4]
    if line <= #lines then
      vim.api.nvim_buf_add_highlight(state.header_buf, ns_id, group, line - 1, col_start, col_end)
    end
  end
  
  vim.api.nvim_set_option_value("modifiable", false, { buf = state.header_buf })
end

function M.render_content(win_width)
  vim.api.nvim_set_option_value("modifiable", true, { buf = state.content_buf })
  
  local lines = {}
  local highlights = {}
  local virtual_to_buffer = {}
  
  local has_todos = false
  
  for line_idx, item in ipairs(state.virtual_list) do
    if item.type == "spacer" or item.type == "header" or item.type == "controls" then
      
    elseif item.type == "group_header_top" then
      has_todos = true
      local top_border = string.rep("▄", win_width)
      table.insert(lines, top_border)
      virtual_to_buffer[line_idx] = #lines
      table.insert(highlights, {#lines, "TodosGroupHeaderBorder", 0, -1})
      
    elseif item.type == "group_header" then
      local icon = "📁"
      local header_text = "  " .. icon .. " " .. item.text .. "  "
      local padded = pad_right(header_text, win_width)
      table.insert(lines, padded)
      virtual_to_buffer[line_idx] = #lines
      table.insert(highlights, {#lines, "TodosGroupHeader", 0, -1})
      
    elseif item.type == "group_header_bottom" then
      local bot_border = string.rep("▀", win_width)
      table.insert(lines, bot_border)
      virtual_to_buffer[line_idx] = #lines
      table.insert(highlights, {#lines, "TodosGroupHeaderBorder", 0, -1})
      
    elseif item.type == "heading_context" then
      local context_line = "  ▌" .. item.text
      table.insert(lines, context_line)
      virtual_to_buffer[line_idx] = #lines
      table.insert(highlights, {#lines, "TodosHeadingContext", 0, -1})
      
    elseif item.type == "todo" then
      local icon = get_status_icon(item.status)
      local todo_line = "    " .. icon .. " " .. item.text
      table.insert(lines, todo_line)
      virtual_to_buffer[line_idx] = #lines
      
      local hl_group = "TodosStatus" .. capitalize(item.status)
      table.insert(highlights, {#lines, hl_group, 4, 5})
      table.insert(highlights, {#lines, "TodosTodoText", 6, -1})
      
    elseif item.type == "empty" then
      local empty_line = pad_center(item.text, win_width)
      table.insert(lines, empty_line)
      virtual_to_buffer[line_idx] = #lines
      table.insert(highlights, {#lines, "TodosEmpty", 0, -1})
    end
  end
  
  if not has_todos then
    table.insert(lines, "")
    table.insert(lines, "")
    local empty_line = pad_center("No Outstanding Todos 🎉", win_width)
    table.insert(lines, empty_line)
    table.insert(highlights, {#lines, "TodosEmpty", 0, -1})
  end
  
  vim.api.nvim_buf_set_lines(state.content_buf, 0, -1, false, lines)
  
  state.virtual_to_buffer_line = virtual_to_buffer
  
  local ns_id = vim.api.nvim_create_namespace("neorg_todos_content")
  vim.api.nvim_buf_clear_namespace(state.content_buf, ns_id, 0, -1)
  
  for _, hl in ipairs(highlights) do
    local line, group, col_start, col_end = hl[1], hl[2], hl[3], hl[4]
    if line <= #lines then
      vim.api.nvim_buf_add_highlight(state.content_buf, ns_id, group, line - 1, col_start, col_end)
    end
  end
  
  vim.api.nvim_set_option_value("modifiable", false, { buf = state.content_buf })
  
  if state.selected_line > #state.virtual_list then
    state.selected_line = list_manager.find_first_selectable(state.virtual_list)
  end
  
  if state.content_win and vim.api.nvim_win_is_valid(state.content_win) then
    local buffer_line = state.virtual_to_buffer_line[state.selected_line]
    if buffer_line then
      local win_height = vim.api.nvim_win_get_height(state.content_win)
      
      if buffer_line < state.topline then
        state.topline = buffer_line
      elseif buffer_line >= state.topline + win_height then
        state.topline = buffer_line - win_height + 1
      end
      
      state.topline = math.max(1, state.topline)
      
      vim.api.nvim_win_call(state.content_win, function()
        vim.fn.winrestview({topline = state.topline})
      end)
      
      vim.api.nvim_win_set_cursor(state.content_win, {buffer_line, 0})
    end
  end
end

function M.create_win()
  local start_win = vim.api.nvim_get_current_win()
  
  local width = math.ceil(vim.api.nvim_win_get_width(start_win) / 5 * 2)
  vim.api.nvim_command("botright " .. width .. " vnew")
  
  state.header_buf = vim.api.nvim_create_buf(false, true)
  state.content_buf = vim.api.nvim_create_buf(false, true)
  
  vim.api.nvim_buf_set_name(state.header_buf, "Todos Header #" .. state.header_buf)
  vim.api.nvim_buf_set_name(state.content_buf, "Todos Content #" .. state.content_buf)
  
  for _, buf in ipairs({state.header_buf, state.content_buf}) do
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "neorg_todos_ui", { buf = buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  end
  
  local main_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(main_win, state.header_buf)
  state.header_win = main_win
  
  vim.api.nvim_command("below split")
  state.content_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.content_win, state.content_buf)
  
  vim.api.nvim_win_set_height(state.header_win, 6)
  
  for _, win in ipairs({state.header_win, state.content_win}) do
    vim.api.nvim_win_call(win, function()
      vim.api.nvim_command("setlocal nowrap")
      vim.api.nvim_command("setlocal nonumber")
      vim.api.nvim_command("setlocal norelativenumber")
      vim.api.nvim_command("setlocal scrolloff=0")
    end)
  end
  
  vim.api.nvim_win_call(state.header_win, function()
    vim.api.nvim_command("setlocal winfixheight")
    vim.api.nvim_win_set_option(0, "statusline", "%#TodosStatusLine#%=")
    vim.api.nvim_win_set_option(0, "winhl", "StatusLine:TodosStatusLine,StatusLineNC:TodosStatusLine")
  end)
  
  vim.api.nvim_win_call(state.content_win, function()
    vim.api.nvim_command("setlocal cursorline")
  end)
  
  vim.api.nvim_set_current_win(state.content_win)
  
  vim.api.nvim_create_autocmd("WinResized", {
    buffer = state.content_buf,
    callback = function()
      if not state.rendering and state.content_win and vim.api.nvim_win_is_valid(state.content_win) then
        vim.schedule(function()
          M.render()
        end)
      end
    end
  })
end

function M.set_mappings()
  local actions = require("neorg_todos.actions")
  
  local mappings = {
    q = actions.close,
    j = actions.move_cursor_down,
    k = actions.move_cursor_up,
    h = actions.move_to_prev_group,
    l = actions.move_to_next_group,
    ["<CR>"] = actions.open_todo_at_cursor,
    s = actions.cycle_sort,
    g = actions.cycle_group,
    f = actions.cycle_filter,
    d = actions.toggle_heading_context,
    r = actions.refresh,
  }
  
  for key, action in pairs(mappings) do
    vim.keymap.set("n", key, action, {
      buffer = state.content_buf,
      nowait = true,
      noremap = true,
      silent = true
    })
  end
end

return M
