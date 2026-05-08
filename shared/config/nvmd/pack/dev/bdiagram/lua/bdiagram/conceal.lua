local ts = vim.treesitter
local boxdraw = require("bdiagram.boxdraw")

local M = {}

M.namespace = vim.api.nvim_create_namespace("bdiagram_conceal")

-- markview uses this namespace for code block decorations; we clear it over
-- bdiagram blocks so its background highlights and fence concealment don't
-- interfere with our extmarks.
local markview_ns = vim.api.nvim_create_namespace("markview/markdown")

local function get_char_at(bufnr, row, col)
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row+1, false)[1] or ""
  return line:sub(col, col)
end

function M.conceal_bdiagram(bufnr, start_row, end_row)
  if not vim.api.nvim_buf_is_loaded(bufnr) then return end
  if vim.bo[bufnr].filetype ~= "markdown" then return end

  local ok, parser = pcall(ts.get_parser, bufnr, "markdown")
  if not ok or not parser then return end

  vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, start_row, end_row + 1)

  local tree = parser:parse()[1]
  if not tree then return end
  local root = tree:root()

  local query = ts.query.parse("markdown", [[
    (fenced_code_block
      (info_string) @lang
      (code_fence_content) @content)
  ]])

  for _, matches, _ in query:iter_matches(root, bufnr, start_row, end_row + 1) do
    local lang_node    = matches[1]
    local content_node = matches[2]

    if type(lang_node) == "table"    then lang_node    = lang_node[1]    end
    if type(content_node) == "table" then content_node = content_node[1] end

    if not lang_node or not content_node then goto continue end

    local lang_text = ts.get_node_text(lang_node, bufnr)
    if vim.trim(lang_text) ~= "bdiagram" then goto continue end

    local c_start, _, c_end, _ = content_node:range()
    local block_start = c_start - 1  -- the ```bdiagram line
    local block_end   = c_end        -- the closing ``` line

    -- Clear markview decorations over the entire fenced block
    vim.api.nvim_buf_clear_namespace(bufnr, markview_ns, block_start, block_end + 1)

    for r = c_start, c_end - 1 do
      local line = vim.api.nvim_buf_get_lines(bufnr, r, r + 1, false)[1] or ""

      for col = 1, #line do
        local char  = line:sub(col, col)
        local left  = col > 1    and line:sub(col - 1, col - 1) or nil
        local right = col < #line and line:sub(col + 1, col + 1) or nil
        local above = r > 0 and get_char_at(bufnr, r - 1, col) or nil
        local below = get_char_at(bufnr, r + 1, col) or nil

        -- Leading "." is used as a structural indent marker — conceal as space
        if char == "." and line:find("%S") == col then
          vim.api.nvim_buf_set_extmark(bufnr, M.namespace, r, col - 1, {
            virt_text     = {{ " ", "Conceal" }},
            virt_text_pos = "overlay",
            hl_mode       = "combine",
          })
        else
          local conceal = boxdraw.get_box_char(char, left, right, above, below)
          if type(conceal) == "string" and conceal ~= "" and conceal ~= char then
            vim.api.nvim_buf_set_extmark(bufnr, M.namespace, r, col - 1, {
              virt_text     = {{ conceal, "Conceal" }},
              virt_text_pos = "overlay",
              hl_mode       = "combine",
            })
          end
        end
      end
    end

    ::continue::
  end
end

return M
