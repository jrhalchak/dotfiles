local M = {}

function M.sort_by_none(todos)
  return todos
end

function M.sort_by_modified(todos)
  local sorted = vim.deepcopy(todos)
  table.sort(sorted, function(a, b)
    local a_time = a.file_metadata and a.file_metadata.modified or 0
    local b_time = b.file_metadata and b.file_metadata.modified or 0
    return a_time > b_time
  end)
  return sorted
end

function M.sort_by_created(todos)
  local sorted = vim.deepcopy(todos)
  table.sort(sorted, function(a, b)
    local a_time = a.file_metadata and a.file_metadata.created or 0
    local b_time = b.file_metadata and b.file_metadata.created or 0
    return a_time > b_time
  end)
  return sorted
end

function M.group_by_file(todos)
  local groups = {}
  local group_order = {}
  
  for _, todo in ipairs(todos) do
    local key = todo.file
    if not groups[key] then
      groups[key] = {
        key = key,
        display = key:match("([^/]+)$") or key,
        todos = {}
      }
      table.insert(group_order, key)
    end
    table.insert(groups[key].todos, todo)
  end
  
  local result = {}
  for _, key in ipairs(group_order) do
    table.insert(result, groups[key])
  end
  
  return result
end

function M.group_by_folder(todos)
  local groups = {}
  local group_order = {}
  
  for _, todo in ipairs(todos) do
    local folder = todo.file:match("(.*/)")
    if not folder then
      folder = "."
    else
      folder = folder:sub(1, -2)
    end
    
    if not groups[folder] then
      groups[folder] = {
        key = folder,
        display = folder:match("([^/]+)$") or folder,
        todos = {}
      }
      table.insert(group_order, folder)
    end
    table.insert(groups[folder].todos, todo)
  end
  
  local result = {}
  for _, key in ipairs(group_order) do
    table.insert(result, groups[key])
  end
  
  return result
end

function M.group_by_day(todos)
  local groups = {}
  local group_order = {}
  
  for _, todo in ipairs(todos) do
    local timestamp = todo.file_metadata and todo.file_metadata.modified or 0
    local date = os.date("%Y-%m-%d", timestamp)
    
    if not groups[date] then
      groups[date] = {
        key = date,
        display = date,
        todos = {}
      }
      table.insert(group_order, date)
    end
    table.insert(groups[date].todos, todo)
  end
  
  table.sort(group_order, function(a, b) return a > b end)
  
  local result = {}
  for _, key in ipairs(group_order) do
    table.insert(result, groups[key])
  end
  
  return result
end

function M.group_by_week(todos)
  local groups = {}
  local group_order = {}
  
  for _, todo in ipairs(todos) do
    local timestamp = todo.file_metadata and todo.file_metadata.modified or 0
    local year = os.date("%Y", timestamp)
    local week = os.date("%W", timestamp)
    local key = year .. "-W" .. week
    
    if not groups[key] then
      groups[key] = {
        key = key,
        display = "Week " .. week .. ", " .. year,
        todos = {}
      }
      table.insert(group_order, key)
    end
    table.insert(groups[key].todos, todo)
  end
  
  table.sort(group_order, function(a, b) return a > b end)
  
  local result = {}
  for _, key in ipairs(group_order) do
    table.insert(result, groups[key])
  end
  
  return result
end

function M.group_by_month(todos)
  local groups = {}
  local group_order = {}
  
  for _, todo in ipairs(todos) do
    local timestamp = todo.file_metadata and todo.file_metadata.modified or 0
    local month = os.date("%Y-%m", timestamp)
    
    if not groups[month] then
      groups[month] = {
        key = month,
        display = os.date("%B %Y", timestamp),
        todos = {}
      }
      table.insert(group_order, month)
    end
    table.insert(groups[month].todos, todo)
  end
  
  table.sort(group_order, function(a, b) return a > b end)
  
  local result = {}
  for _, key in ipairs(group_order) do
    table.insert(result, groups[key])
  end
  
  return result
end

function M.filter_journal(todos)
  local filtered = {}
  for _, todo in ipairs(todos) do
    if todo.file:match("journal/") then
      table.insert(filtered, todo)
    end
  end
  return filtered
end

function M.filter_by_status(todos, status)
  local filtered = {}
  for _, todo in ipairs(todos) do
    if todo.status == status then
      table.insert(filtered, todo)
    end
  end
  return filtered
end

function M.apply_filter(todos, filter_mode)
  if filter_mode == "all" then
    return todos
  elseif filter_mode == "journal" then
    return M.filter_journal(todos)
  elseif filter_mode == "important" then
    return M.filter_by_status(todos, "important")
  elseif filter_mode == "partial" then
    return M.filter_by_status(todos, "progress")
  elseif filter_mode == "unknown" then
    return M.filter_by_status(todos, "unknown")
  elseif filter_mode == "hold" then
    return M.filter_by_status(todos, "hold")
  else
    return todos
  end
end

function M.apply_sort(todos, sort_mode)
  if sort_mode == "none" then
    return M.sort_by_none(todos)
  elseif sort_mode == "modified" then
    return M.sort_by_modified(todos)
  elseif sort_mode == "created" then
    return M.sort_by_created(todos)
  else
    return todos
  end
end

function M.apply_group(todos, group_mode)
  if group_mode == "file" then
    return M.group_by_file(todos)
  elseif group_mode == "folder" then
    return M.group_by_folder(todos)
  elseif group_mode == "day" then
    return M.group_by_day(todos)
  elseif group_mode == "week" then
    return M.group_by_week(todos)
  elseif group_mode == "month" then
    return M.group_by_month(todos)
  else
    return M.group_by_file(todos)
  end
end

return M
