local M = {}

function M.get_document_headings(filepath)
  local bufnr = vim.fn.bufnr(filepath, false)
  local should_delete = false
  
  if bufnr == -1 then
    bufnr = vim.fn.bufadd(filepath)
    vim.fn.bufload(bufnr)
    should_delete = true
  end
  
  local parser = vim.treesitter.get_parser(bufnr, "norg")
  if not parser then
    if should_delete then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
    return {}
  end
  
  local tree = parser:parse()[1]
  local root = tree:root()
  
  local headings = {}
  local query = vim.treesitter.query.parse("norg", [[
    (heading1 title: (paragraph_segment) @title) @heading
    (heading2 title: (paragraph_segment) @title) @heading
    (heading3 title: (paragraph_segment) @title) @heading
    (heading4 title: (paragraph_segment) @title) @heading
    (heading5 title: (paragraph_segment) @title) @heading
    (heading6 title: (paragraph_segment) @title) @heading
  ]])
  
  for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
    local capture_name = query.captures[id]
    if capture_name == "heading" then
      local line = node:start()
      
      local title_node = node:field("title")[1]
      if title_node then
        local title_text = vim.treesitter.get_node_text(title_node, bufnr)
        local full_text = vim.treesitter.get_node_text(node, bufnr)
        local level = #(full_text:match("^(%*+)") or "*")
        
        table.insert(headings, {
          level = level,
          line = line,
          text = title_text:gsub("^%s+", ""):gsub("%s+$", "")
        })
      end
    end
  end
  
  if should_delete then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
  
  return headings
end

function M.get_parent_heading_for_line(filepath, line_num)
  local headings = M.get_document_headings(filepath)
  
  if #headings == 0 then
    return nil, {}
  end
  
  local current_heading = nil
  local heading_path = {}
  local level_stack = {}
  
  for _, heading in ipairs(headings) do
    if heading.line < line_num then
      while #level_stack > 0 and level_stack[#level_stack].level >= heading.level do
        table.remove(level_stack)
      end
      
      table.insert(level_stack, heading)
      current_heading = heading
    else
      break
    end
  end
  
  for _, h in ipairs(level_stack) do
    table.insert(heading_path, h.text)
  end
  
  return current_heading and current_heading.text or nil, heading_path
end

function M.is_todo_heading(heading_text)
  if not heading_text then
    return false
  end
  
  local lower = heading_text:lower():gsub("%s+", "")
  return lower == "todo" or 
         lower == "todos" or 
         lower == "tasks" or
         lower == "task" or
         lower:match("^todo[s]?:")
end

return M
