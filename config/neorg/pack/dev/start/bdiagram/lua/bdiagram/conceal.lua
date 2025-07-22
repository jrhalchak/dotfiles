local ts = vim.treesitter
local boxdraw = require("bdiagram.boxdraw")

local M = {}

M.namespace = vim.api.nvim_create_namespace("bdiagram_conceal")

local function get_char_at(bufnr, row, col)
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row+1, false)[1] or ""
  return line:sub(col, col)
end

function M.conceal_bdiagram(bufnr, start_row, end_row)
  if not vim.api.nvim_buf_is_loaded(bufnr) then return end
  if vim.bo[bufnr].filetype ~= "norg" then return end

  local ok, parser = pcall(require("vim.treesitter").get_parser, bufnr)
  if not ok or not parser then return end

  vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, start_row, end_row+1)

  -- Get the main norg tree
  local tree = parser:trees()[1]
  if not tree then return end
  local root = tree:root()

  -- Query for ranged_verbatim_tag blocks named "bdiagram"
  local query = ts.query.parse("norg", [[
    (ranged_verbatim_tag
      (tag_name) @bdiagram_name
      (ranged_verbatim_tag_content) @bdiagram_content)
  ]])

  for _, matches, _ in query:iter_matches(root, bufnr, start_row, end_row+1) do
    -- -- print("Query matched!")
    local name_node = matches[1]
    local content_node = matches[2]

    -- print("name_node type:", type(name_node), vim.inspect(name_node))

    -- Unwrap tables if needed
    if type(name_node) == "table" then name_node = name_node[1] end

    if type(content_node) == "table" then content_node = content_node[1] end

    if name_node and type(name_node.range) == "function" and content_node and type(content_node.range) == "function" then
      local name_text = vim.treesitter.get_node_text(name_node, bufnr)
      -- print("Tag name:", name_text)
      if name_text == "bdiagram" then
        -- print("Found bdiagram block")
        for child in content_node:iter_children() do
          -- print("Child type:", child:type(), child:range())
          if child:type() == "_segment" then
            local row, _, end_row_c, _ = child:range()
            for r = row, end_row_c do
              local line = vim.api.nvim_buf_get_lines(bufnr, r, r+1, false)[1] or ""
              -- print("Processing line:", line)
              for col = 1, #line do
                local char = line:sub(col, col)
                local left  = col > 1 and line:sub(col-1, col-1) or nil
                local right = col < #line and line:sub(col+1, col+1) or nil
                local above = r > 0 and get_char_at(bufnr, r-1, col) or nil
                local below = get_char_at(bufnr, r+1, col) or nil

                if char == "." and line:find("%S") == col then
                  -- print("Matched start indent character:", char, col, line:find("%S"))
                  vim.api.nvim_buf_set_extmark(bufnr, M.namespace, r, col-1, {
                    virt_text = {{" ", "Conceal"}},
                    virt_text_pos = "overlay",
                    hl_mode = "combine",
                  })
                else
                  local conceal = boxdraw.get_box_char(char, left, right, above, below)
                  if conceal ~= char and (boxdraw.box_map[conceal] or boxdraw.box_map[char] or char == "+") then
                    vim.api.nvim_buf_set_extmark(bufnr, M.namespace, r, col-1, {
                      virt_text = {{tostring(conceal), "Conceal"}},
                      virt_text_pos = "overlay",
                      hl_mode = "combine",
                    })
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

return M

