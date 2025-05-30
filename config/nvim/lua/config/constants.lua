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

M.CMP_KIND_ICONS = {
	Text = "󰊄",
	Method = "",
	Function = "󰊕",
	Constructor = "",
  Field = "",
  Variable = "󱄑", -- "",
	Class = "", -- "",
	Interface = "",
	Module = "󰕳",
	Property = "",
	Unit = "",
	Value = "󰫧",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "󰉦",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "󰀱",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = "",
}

return M
