# bdiagram

Neorg plugin for fancy diagram conceals using regular ascii characters using a custom `@bdiagram` block.

The goal is to turn [ASCII Syntax](#ascii-syntax) into a ["beautiful" box-drawing diagram](#concealed-view).

## Structure

```
├── lua/
│   └── bdiagram/
│       ├── init.lua           # Main plugin entry (setup, autocmds)
│       ├── conceal.lua        # Logic for conceal/extmarks
│       └── utils.lua          # (Optional) Helper functions
├── queries/
│   └── bdiagram/
│       └── highlights.scm     # Treesitter highlight/conceal queries
├── syntax/
│   └── bdiagram.vim           # (Optional) Vim syntax fallback
├── tree-sitter-bdiagram/
│   ├── grammar.js             # Treesitter grammar (JS)
│   ├── src/
│   │   └── parser.c           # Generated parser (after `tree-sitter generate`)
│   └── package.json           # Grammar package info
└── README.md
```

### **File/Directory Details**

#### `lua/bdiagram/init.lua`
- Loads the plugin, sets up autocmds for Neorg buffers, and loads the grammar.

#### `lua/bdiagram/conceal.lua`
- Contains functions to parse `@bdiagram` blocks, apply/remove extmarks/conceal.
- **Responsibility**: The `get_box_char` functio nbelow will replace ASCII characters with unicode box-drawing equivalentsa in the UI
- **Use**: Provides actual visual transformation

#### `lua/bdiagram/utils.lua`
- (Optional) Utility functions for block detection, etc.

#### `queries/bdiagram/highlights.scm`
- Treesitter queries for highlighting/conceal (e.g., mapping diagram elements to highlight groups).
- Generated from `grammar.js`
- **Responsibility**: Match all text nodes inside `@bdiagram` blocks, or individual characters
- **Use**: Selects characters in the `@bdiagram` block for further processing

#### `syntax/bdiagram.vim`
- (Optional) Vim syntax fallback if Treesitter isn’t available.
- **Likely will be unused & treesitter will be required**

#### `tree-sitter-bdiagram/`
- Contains custom Treesitter grammar (`grammar.js`) for diagrams.
- Use `tree-sitter generate` to produce `src/parser.c`.
- **Responsibility**: Identify `@bdiagram` blocks and lines/characters within them
- **Use**: Only apply conceal logic to diagram blocks

### How They Work Together
1. **Treesitter** parses the buffer and identifies `@bdiagram` blocks.
2. **Treesitter queries** select the relevant diagram characters inside those blocks.
3. For each matched character, your **conceal function** (`get_box_char`) is called, which contextually replaces it with the correct Unicode character for display.
4. **Highlights** are applied to further enhance the diagram’s appearance.


---

## Example Mapping-Table & Contextual Replacement Function

```lua
local box_map = {
  -- Horizontal lines
  ["-"] = "─",   -- single
  ["="] = "═",   -- double
  ["_"] = "━",   -- thick
  ["~"] = "╌",   -- dotted

  -- Vertical lines
  ["|"] = "│",   -- single
  [":"] = "┊",   -- dotted
  ["!"] = "┃",   -- thick
  [";"] = "║",   -- double

  -- Diagonals
  ["/"] = "╱",
  ["\\"] = "╲",

  -- Crosses and junctions (contextual for '+')
  ["x"] = "╳",
  ["X"] = "╳",

  -- Arrows
  [">"] = "▶",
  ["<"] = "◀",
  ["^"] = "▲",
  ["v"] = "▼",

  -- Block corners/fills
  ["▗"] = "▗",
  ["▖"] = "▖",
  ["▝"] = "▝",
  ["▘"] = "▘",
  ["░"] = "░",
  ["▒"] = "▒",
  ["▓"] = "▓",
  ["█"] = "█",

  -- Wavy lines
  ["w"] = "◠",
  ["m"] = "◡",

  -- Box corner holders
  ["A"] = "◤",
  ["B"] = "◥",
  ["C"] = "◣",
  ["D"] = "◢",
}

local function get_box_char(char, left, right, above, below)
  local function is_single_h(c) return c == "-" end
  local function is_double_h(c) return c == "=" end
  local function is_thick_h(c) return c == "_" end
  local function is_dotted_h(c) return c == "~" end
  local function is_single_v(c) return c == "|" end
  local function is_double_v(c) return c == ";" end
  local function is_thick_v(c) return c == "!" end
  local function is_dotted_v(c) return c == ":" end

  -- Contextual for '+'
  if char == "+" then
    local hor = (left and (is_single_h(left) or is_double_h(left) or is_thick_h(left) or is_dotted_h(left)))
             or (right and (is_single_h(right) or is_double_h(right) or is_thick_h(right) or is_dotted_h(right)))
    local ver = (above and (is_single_v(above) or is_double_v(above) or is_thick_v(above) or is_dotted_v(above)))
             or (below and (is_single_v(below) or is_double_v(below) or is_thick_v(below) or is_dotted_v(below)))

    local line_type = "single"
    if (left == "=" or right == "=" or above == ";" or below == ";") then
      line_type = "double"
    elseif (left == "_" or right == "_" or above == "!" or below == "!") then
      line_type = "thick"
    elseif (left == "~" or right == "~" or above == ":" or below == ":") then
      line_type = "dotted"
    end

    if hor and ver then
      if line_type == "single" then return "┼"
      elseif line_type == "double" then return "╬"
      elseif line_type == "thick" then return "╋"
      elseif line_type == "dotted" then return "┿"
      end
    elseif hor then
      if line_type == "single" then return "─"
      elseif line_type == "double" then return "═"
      elseif line_type == "thick" then return "━"
      elseif line_type == "dotted" then return "╌"
      end
    elseif ver then
      if line_type == "single" then return "│"
      elseif line_type == "double" then return "║"
      elseif line_type == "thick" then return "┃"
      elseif line_type == "dotted" then return "┊"
      end
    else
      return "+"
    end
  end

  -- Contextual for corners
  if char == "/" then
    if below and (is_single_v(below) or is_double_v(below) or is_thick_v(below) or is_dotted_v(below))
      and right and (is_single_h(right) or is_double_h(right) or is_thick_h(right) or is_dotted_h(right)) then
      if right == "=" or below == ";" then return "╔"
      elseif right == "_" or below == "!" then return "┏"
      elseif right == "~" or below == ":" then return "╭"
      else return "┌"
      end
    end
  elseif char == "\\" then
    if below and (is_single_v(below) or is_double_v(below) or is_thick_v(below) or is_dotted_v(below))
      and left and (is_single_h(left) or is_double_h(left) or is_thick_h(left) or is_dotted_h(left)) then
      if left == "=" or below == ";" then return "╗"
      elseif left == "_" or below == "!" then return "┓"
      elseif left == "~" or below == ":" then return "╮"
      else return "┐"
      end
    end
  elseif char == "," then
    if above and (is_single_v(above) or is_double_v(above) or is_thick_v(above) or is_dotted_v(above))
      and right and (is_single_h(right) or is_double_h(right) or is_thick_h(right) or is_dotted_h(right)) then
      if right == "=" or above == ";" then return "╚"
      elseif right == "_" or above == "!" then return "┗"
      elseif right == "~" or above == ":" then return "╰"
      else return "└"
      end
    end
  elseif char == "." then
    if above and (is_single_v(above) or is_double_v(above) or is_thick_v(above) or is_dotted_v(above))
      and left and (is_single_h(left) or is_double_h(left) or is_thick_h(left) or is_dotted_h(left)) then
      if left == "=" or above == ";" then return "╝"
      elseif left == "_" or above == "!" then return "┛"
      elseif left == "~" or above == ":" then return "╯"
      else return "┘"
      end
    end
  end

  return box_map[char] or char
end

return {
  box_map = box_map,
  get_box_char = get_box_char,
}
```

## Copilot ───

[file:README.md](README.md) line:1-1000

```lua
local box_map = {
  -- Horizontal lines
  ["-"] = "─",   -- single
  ["="] = "═",   -- double
  ["_"] = "━",   -- thick
  ["~"] = "╌",   -- dotted

  -- Vertical lines
  ["|"] = "│",   -- single
  [":"] = "┊",   -- dotted
  ["!"] = "┃",   -- thick
  [";"] = "║",   -- double

  -- Arrows
  [">"] = "▶",
  ["<"] = "◄",
  ["^"] = "▲",
  ["v"] = "▼",

  -- Wavy lines
  ["w"] = "◠",
  ["m"] = "◡",
}

local function get_box_char(char, left, right, above, below)
  local function is_single_h(c) return c == "-" end
  local function is_double_h(c) return c == "=" end
  local function is_thick_h(c) return c == "_" end
  local function is_dotted_h(c) return c == "~" end
  local function is_single_v(c) return c == "|" end
  local function is_double_v(c) return c == ";" end
  local function is_thick_v(c) return c == "!" end
  local function is_dotted_v(c) return c == ":" end

  -- Contextual for '+'
  if char == "+" then
    local left_h = left and (is_single_h(left) or is_double_h(left) or is_thick_h(left) or is_dotted_h(left))
    local right_h = right and (is_single_h(right) or is_double_h(right) or is_thick_h(right) or is_dotted_h(right))
    local above_v = above and (is_single_v(above) or is_double_v(above) or is_thick_v(above) or is_dotted_v(above))
    local below_v = below and (is_single_v(below) or is_double_v(below) or is_thick_v(below) or is_dotted_v(below))

    -- Determine line types for each direction
    local function line_type_h(c)
      if is_double_h(c) then return "double"
      elseif is_thick_h(c) then return "thick"
      elseif is_dotted_h(c) then return "dotted"
      elseif is_single_h(c) then return "single"
      end
    end
    local function line_type_v(c)
      if is_double_v(c) then return "double"
      elseif is_thick_v(c) then return "thick"
      elseif is_dotted_v(c) then return "dotted"
      elseif is_single_v(c) then return "single"
      end
    end

    local lt_left = line_type_h(left)
    local lt_right = line_type_h(right)
    local lt_above = line_type_v(above)
    local lt_below = line_type_v(below)

    -- Corners
    if not left_h and not above_v and right_h and below_v then
      -- Top-left
      if lt_right == "double" or lt_below == "double" then return "╔"
      elseif lt_right == "thick" or lt_below == "thick" then return "┏"
      elseif lt_right == "dotted" or lt_below == "dotted" then return "╭"
      elseif (lt_right == "single" or lt_below == "single") then return "┌"
      end
    elseif not right_h and not above_v and left_h and below_v then
      -- Top-right
      if lt_left == "double" or lt_below == "double" then return "╗"
      elseif lt_left == "thick" or lt_below == "thick" then return "┓"
      elseif lt_left == "dotted" or lt_below == "dotted" then return "╮"
      elseif (lt_left == "single" or lt_below == "single") then return "┐"
      end
    elseif not left_h and not below_v and right_h and above_v then
      -- Bottom-left
      if lt_right == "double" or lt_above == "double" then return "╚"
      elseif lt_right == "thick" or lt_above == "thick" then return "┗"
      elseif lt_right == "dotted" or lt_above == "dotted" then return "╰"
      elseif (lt_right == "single" or lt_above == "single") then return "└"
      end
    elseif not right_h and not below_v and left_h and above_v then
      -- Bottom-right
      if lt_left == "double" or lt_above == "double" then return "╝"
      elseif lt_left == "thick" or lt_above == "thick" then return "┛"
      elseif lt_left == "dotted" or lt_above == "dotted" then return "╯"
      elseif (lt_left == "single" or lt_above == "single") then return "┘"
      end
    -- One-way junctions (tees)
    elseif left_h and right_h and not above_v and below_v then
      -- Tee up
      if lt_left == "double" or lt_right == "double" or lt_below == "double" then return "╦"
      elseif lt_left == "thick" or lt_right == "thick" or lt_below == "thick" then return "┳"
      elseif lt_left == "dotted" or lt_right == "dotted" or lt_below == "dotted" then return "┰"
      else return "┬"
      end
    elseif left_h and right_h and above_v and not below_v then
      -- Tee down
      if lt_left == "double" or lt_right == "double" or lt_above == "double" then return "╩"
      elseif lt_left == "thick" or lt_right == "thick" or lt_above == "thick" then return "┻"
      elseif lt_left == "dotted" or lt_right == "dotted" or lt_above == "dotted" then return "┸"
      else return "┴"
      end
    elseif above_v and below_v and not left_h and right_h then
      -- Tee left
      if lt_above == "double" or lt_below == "double" or lt_right == "double" then return "╠"
      elseif lt_above == "thick" or lt_below == "thick" or lt_right == "thick" then return "┣"
      elseif lt_above == "dotted" or lt_below == "dotted" or lt_right == "dotted" then return "┝"
      else return "├"
      end
    elseif above_v and below_v and left_h and not right_h then
      -- Tee right
      if lt_above == "double" or lt_below == "double" or lt_left == "double" then return "╣"
      elseif lt_above == "thick" or lt_below == "thick" or lt_left == "thick" then return "┫"
      elseif lt_above == "dotted" or lt_below == "dotted" or lt_left == "dotted" then return "┥"
      else return "┤"
      end
    -- Crossbars (all four directions)
    elseif left_h and right_h and above_v and below_v then
      if lt_left == "double" or lt_right == "double" or lt_above == "double" or lt_below == "double" then return "╬"
      elseif lt_left == "thick" or lt_right == "thick" or lt_above == "thick" or lt_below == "thick" then return "╋"
      elseif lt_left == "dotted" or lt_right == "dotted" or lt_above == "dotted" or lt_below == "dotted" then return "╪"
      else return "┼"
      end
    -- Single lines
    elseif left_h and right_h and not above_v and not below_v then
      if lt_left == "double" or lt_right == "double" then return "═"
      elseif lt_left == "thick" or lt_right == "thick" then return "━"
      elseif lt_left == "dotted" or lt_right == "dotted" then return "╌"
      else return "─"
      end
    elseif above_v and below_v and not left_h and not right_h then
      if lt_above == "double" or lt_below == "double" then return "║"
      elseif lt_above == "thick" or lt_below == "thick" then return "┃"
      elseif lt_above == "dotted" or lt_below == "dotted" then return "┊"
      else return "│"
      end
    end
    return "+"
  end

  return box_map[char] or char
end

return {
  box_map = box_map,
  get_box_char = get_box_char,
}
```

## Syntax Transformation Example

### ASCII Syntax
Using the syntax above (based on conventional ascii syntax), you could turn something like this:
```norg
@bdiagram
+===============================+
|                               |
|           Perception          |
|              -+-              |
|  +-----+      |               |
|  |   +--v------+--------------+ |
|  |   | Effectors            |<-;+------+
|  |   +--+---------+----------+ |  +===+=======+
|  |   : |  Tools  |  Memory  : |  |  Environment |
|  |   +~+~~~~~~~~~|~~~~~~~~~~+ |  +===^=======+
|  +--^--+         v            |      |
|     :          Action -------;+------+
| (Planning)                  |
|                             |
+===============================+
@end
```

### Concealed View
...into:
```norg
@bdiagram
╔════════════════════════════════╗
║                                ║
║           Perception           ║
║               ─┬─              ║
║  ╭─────╮       │               ║
║  │   ╭─▼───────┴────────────╮  ║
║  │   │ Effectors            │◄─╫──────╮
║  │   ├─┬─────────┬──────────┤  ║  ╭═══╧═══════════╮
║  │   ┊ │  Tools  │  Memory  ┊  ║  │  Environment  │
║  │   ╰╌┼╌╌╌╌╌╌╌╌╌│╌╌╌╌╌╌╌╌╌╌╯  ║  ╰═══▲═══════════╯
║  ╰──▲──╯         ▼             ║      │
║     ┊          Action ─────────╫──────╯
║ (Planning)                     ║
║                                ║
╚════════════════════════════════╝
@end
```

## Grammar Example
```js
module.exports = grammar({
  name: 'bdiagram',

  rules: {
    source_file: $ => repeat($._block),

    _block: $ => choice(
      $.bdiagram_block,
      $.other
    ),

    bdiagram_block: $ => seq(
      '@bdiagram',
      '\n',
      repeat1($.diagram_line),
      '@end'
    ),

    diagram_line: $ => seq(
      optional($.diagram_indent),
      repeat1($.diagram_char),
      '\n'
    ),

    diagram_indent: $ => /[ ]+/,

    diagram_char: $ => token(choice(
      '+', '-', '=', '_', '~', '|', ':', ';', '!', // box drawing
      '>', '<', '^', 'v',                          // arrows
      'w', 'm',                                    // wavy
      ' ',                                         // space
      /[A-Za-z0-9]/,                               // text/labels
      '[', ']', '{', '}', '(', ')', '.', ',', '\'', '"', '/', '\\', '?', '@', '#', '$', '%', '&', '*', '`', '~'
    )),

    other: $ => /[^\n]+/
  }
});
```

## Plans

### 1. **Create a Neovim Plugin Directory**

Create a directory for your plugin, e.g.:
```
~/.config/nvim/lua/bdiagram/
```

### 2. **Define the Custom Block in Neorg**

Neorg supports custom code block tags. In your Neorg files, you’ll use:
```
@bdiagram
...your ascii diagram...
@end
```

### 3. **Write a Minimal Treesitter Grammar for `bdiagram`**

- Create a new [tree-sitter](https://tree-sitter.github.io/tree-sitter/) grammar for your diagrams (e.g., `tree-sitter-bdiagram`).
- The grammar should recognize diagram elements (`+`, `-`, `|`, etc.) and expose them as nodes.
- You can keep this grammar in your plugin directory or as a submodule.

**Example grammar snippet (in JS):**
```js
module.exports = grammar({
  name: 'bdiagram',
  rules: {
    source_file: $ => repeat($.diagram_line),
    diagram_line: $ => /[^\n]*/,
  }
});
```
*(You’ll want to expand this to recognize boxes, connectors, etc.)*

### 4. **Install and Register the Grammar in Neovim**

- Use [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) to install your grammar.
- In your plugin’s `init.lua`:
```lua
require'nvim-treesitter.parsers'.get_parser_configs().bdiagram = {
  install_info = {
    url = '/path/to/tree-sitter-bdiagram', -- local path or git repo
    files = {'src/parser.c'},
    branch = 'main',
  },
  filetype = 'bdiagram',
}
```

### 5. **Detect `@bdiagram` Blocks and Set Buffer Filetype**

- Write a Lua autocmd that, when you enter a `@bdiagram ... @end` block, sets the filetype for that region to `bdiagram`.
- You can use [nvim_buf_set_extmark](https://neovim.io/doc/user/api.html#nvim_buf_set_extmark()) to highlight and conceal.

**Example autocmd:**
```lua
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.norg",
  callback = function()
    -- Scan for @bdiagram blocks and set extmarks/filetype as needed
    -- (You may want to use Treesitter or regex for this)
  end,
})
```

### 6. **Apply Conceal/Extmarks When Leaving the Block**

- Use Neovim’s [CursorMoved](https://neovim.io/doc/user/autocmd.html#CursorMoved) or [InsertLeave](https://neovim.io/doc/user/autocmd.html#InsertLeave) autocmds.
- When the cursor is outside a `@bdiagram` block, parse the block and apply extmarks with conceal for ASCII → box-drawing.

**Example Lua logic:**
```lua
-- Pseudocode
function conceal_bdiagram(bufnr, start_line, end_line)
  for line = start_line, end_line do
    local text = vim.api.nvim_buf_get_lines(bufnr, line, line+1, false)[1]
    -- Replace ASCII with box-drawing, set extmarks with conceal
    -- e.g., replace "+" with "╭", "-" with "─", etc.
    -- Use nvim_buf_set_extmark with 'conceal' option
  end
end
```

### 7. **Remove Conceal When Entering the Block**

- When the cursor enters a `@bdiagram` block, remove the extmarks/conceal so you can edit the ASCII directly.

### 8. **Highlighting**

- Define highlight groups for diagram elements.
- Use Treesitter queries or extmarks to apply highlights.

### 9. **No Neorg Modification Needed**

- All logic is in your plugin.
- You’re just leveraging Neorg’s code block extensibility and Neovim’s APIs.

---

### **Summary of Steps**

1. Create a plugin directory.
2. Write a minimal Treesitter grammar for diagrams.
3. Register the grammar with nvim-treesitter.
4. Detect `@bdiagram` blocks in Neorg files.
5. Set filetype or apply extmarks/conceal/highlights to those blocks.
6. Conceal ASCII to box-drawing when not editing.
7. Remove conceal when editing.
8. No changes to Neorg itself.

### Notes for users once this is a real README
- **Plugin Spec Example for `lazy.nvim`:**
  ```lua
  {
    dir = ".../bdiagram", -- remove this when ready
    name = "bdiagram",
    build = "make install",
    config = function()
      require("bdiagram").setup()
    end,
  }

## TODOS / Future Plans
- Figure out a way to not ruin the diagrams with indentations (which currently requires a character at the start of the line, like the `.` characters above)
- (**Nice to have**) It would be _awesome_ if you could use like, Mermaid or
  basic PlantUML diagrams and have them rendered as versions of those
  diagrams... but that would massively increase the scope to include a custom
  mermaid/plantUML renderer

