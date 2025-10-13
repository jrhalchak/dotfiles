local M = {}

---@diagnostic disable-next-line: undefined-field
M.IS_MAC = vim.loop.os_uname().sysname == "Darwin"

M.WINDOW_STYLE = {
  focusable = false,
  style = "minimal",
  border = "rounded",
  source = "always",
  header = "",
  prefix = "",
}

M.CMP_KINDS = {
  Text =        { icon = "󰊄",  bg = "fg_gutter", fg = "fg" },
  Method =      { icon = "",  bg = "blue",      fg = "bg_dark" },
  Function =    { icon = "󰊕",  bg = "blue",      fg = "bg_dark" },
  Constructor = { icon = "",  bg = "cyan",      fg = "bg_dark" },
  Field =       { icon = "",  bg = "green",     fg = "bg_dark" },
  Variable =    { icon = "󱄑",  bg = "magenta",   fg = "bg_dark" },
  Class =       { icon = "",  bg = "yellow",    fg = "bg_dark" },
  Interface =   { icon = "",  bg = "yellow",    fg = "bg_dark" },
  Module =      { icon = "󰕳",  bg = "orange",    fg = "bg_dark" },
  Property =    { icon = "",  bg = "cyan",      fg = "bg_dark" },
  Unit =        { icon = "",  bg = "green",     fg = "bg_dark" },
  Value =       { icon = "󰫧",  bg = "green",     fg = "bg_dark" },
  Enum =        { icon = "",  bg = "purple",    fg = "bg_dark" },
  Keyword =     { icon = "",  bg = "red",       fg = "bg_dark" },
  Snippet =     { icon = "",  bg = "teal",      fg = "bg_dark" },
  Color =       { icon = "󰉦",  bg = "red",       fg = "bg_dark" },
  File =        { icon = "",  bg = "blue",      fg = "bg_dark" },
  Reference =   { icon = "",  bg = "red",       fg = "bg_dark" },
  Folder =      { icon = "",  bg = "blue",      fg = "bg_dark" },
  EnumMember =  { icon = "",  bg = "purple",    fg = "bg_dark" },
  Constant =    { icon = "󰀱",  bg = "orange",    fg = "bg_dark" },
  Struct =      { icon = "",  bg = "yellow",    fg = "bg_dark" },
  Event =       { icon = "",  bg = "yellow",    fg = "bg_dark" },
  Operator =    { icon = "",  bg = "red",       fg = "bg_dark" },
  TypeParameter = { icon = "", bg = "blue",     fg = "bg_dark" },
}

return M
