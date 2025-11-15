local M = {}

function M.build_virtual_list(grouped_todos, show_heading_context, sort_mode, group_mode, filter_mode)
  local list = {}
  
  local function add_item(item)
    table.insert(list, item)
  end
  
  add_item({ type = "spacer", selectable = false })
  add_item({ 
    type = "header", 
    text = "Outstanding Todos", 
    selectable = false 
  })
  add_item({ type = "spacer", selectable = false })
  
  add_item({
    type = "controls",
    sort_mode = sort_mode,
    group_mode = group_mode,
    filter_mode = filter_mode,
    selectable = false
  })
  
  add_item({ type = "spacer", selectable = false })
  add_item({ type = "spacer", selectable = false })
  
  for _, group in ipairs(grouped_todos) do
    add_item({
      type = "group_header_top",
      text = group.display,
      key = group.key,
      selectable = false,
      group_key = group.key
    })
    
    add_item({
      type = "group_header",
      text = group.display,
      key = group.key,
      selectable = true,
      group_key = group.key
    })
    
    add_item({
      type = "group_header_bottom",
      text = group.display,
      key = group.key,
      selectable = false,
      group_key = group.key
    })
    
    local last_heading = nil
    for _, todo in ipairs(group.todos) do
      if show_heading_context and not todo.is_under_todo_heading then
        local heading_text = table.concat(todo.heading_path or {}, " → ")
        if heading_text ~= "" and heading_text ~= last_heading then
          add_item({
            type = "heading_context",
            text = heading_text,
            selectable = false
          })
          last_heading = heading_text
        end
      end
      
      add_item({
        type = "todo",
        text = todo.text,
        status = todo.status,
        file = todo.file,
        line = todo.line,
        selectable = true,
        todo = todo
      })
    end
    
    add_item({ type = "spacer", selectable = false })
  end
  
  if #grouped_todos == 0 then
    add_item({ type = "spacer", selectable = false })
    add_item({ type = "spacer", selectable = false })
    add_item({
      type = "empty",
      text = "No Outstanding Todos 🎉",
      selectable = false
    })
  end
  
  return list
end

function M.get_next_selectable(list, current_line)
  for i = current_line + 1, #list do
    if list[i].selectable then
      return i
    end
  end
  return current_line
end

function M.get_prev_selectable(list, current_line)
  for i = current_line - 1, 1, -1 do
    if list[i].selectable then
      return i
    end
  end
  return current_line
end

function M.get_next_group(list, current_line)
  for i = current_line + 1, #list do
    if list[i].type == "group_header" or list[i].type == "group_header_top" then
      for j = i, #list do
        if list[j].type == "group_header" then
          return j
        end
      end
    end
  end
  return current_line
end

function M.get_prev_group(list, current_line)
  for i = current_line - 1, 1, -1 do
    if list[i].type == "group_header" or list[i].type == "group_header_top" then
      for j = i, 1, -1 do
        if list[j].type == "group_header" then
          return j
        end
      end
    end
  end
  return current_line
end

function M.get_item_at_line(list, line_num)
  return list[line_num]
end

function M.find_first_selectable(list)
  for i, item in ipairs(list) do
    if item.selectable then
      return i
    end
  end
  return 1
end

return M
