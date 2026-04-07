-- mdagenda/highlights.lua
-- Define all highlight groups used by the agenda panel.
-- Called once from init.lua during setup().

local M = {}

-- Each entry: { group, link } or { group, fg, bg, bold, italic }
-- We link to standard groups where possible so the user's colorscheme is
-- respected without extra config.
local groups = {
  -- Section headers
  { group = "MdAgendaHeader",       link = "Title" },
  { group = "MdAgendaHeaderToday",  fg = "#98c379", bold = true },
  { group = "MdAgendaHeaderOverdue",fg = "#e06c75", bold = true },
  { group = "MdAgendaHeaderLater",  link = "Comment" },

  -- Priority labels
  { group = "MdAgendaPriorityHigh",   fg = "#e06c75", bold = true },
  { group = "MdAgendaPriorityMedium", fg = "#e5c07b" },
  { group = "MdAgendaPriorityLow",    fg = "#61afef" },
  { group = "MdAgendaPriorityUnset",  link = "Comment" },

  -- Checkbox state glyphs
  { group = "MdAgendaStateNotStarted", link = "Normal" },
  { group = "MdAgendaStateInProgress", fg = "#e5c07b" },
  { group = "MdAgendaStateBlocked",    fg = "#e06c75" },
  { group = "MdAgendaStateCancelled",  link = "Comment" },
  { group = "MdAgendaStateDone",       link = "Comment" },

  -- Due dates
  { group = "MdAgendaDueOverdue", fg = "#e06c75" },
  { group = "MdAgendaDueToday",   fg = "#98c379" },
  { group = "MdAgendaDueSoon",    fg = "#e5c07b" },
  { group = "MdAgendaDueLater",   link = "Comment" },

  -- Vault tag
  { group = "MdAgendaVaultNotes", fg = "#61afef" },
  { group = "MdAgendaVaultOmni",  fg = "#c678dd" },
  { group = "MdAgendaVaultWork",  fg = "#56b6c2" },

  -- Misc
  { group = "MdAgendaDimmed",     link = "Comment" },
  { group = "MdAgendaFilePath",   link = "Directory" },
  { group = "MdAgendaCalDay",     link = "Normal" },
  { group = "MdAgendaCalToday",   fg = "#98c379", bold = true },
  { group = "MdAgendaCalWeekend", link = "Comment" },
  { group = "MdAgendaCalHasTodo", fg = "#e5c07b" },
}

function M.setup()
  for _, spec in ipairs(groups) do
    local opts = {}
    if spec.link then
      opts.link = spec.link
    else
      if spec.fg   then opts.fg   = spec.fg   end
      if spec.bg   then opts.bg   = spec.bg   end
      if spec.bold then opts.bold = spec.bold end
      if spec.italic then opts.italic = spec.italic end
    end
    -- Only set if not already defined (lets user override in colorscheme).
    if vim.fn.hlID(spec.group) == 0 then
      vim.api.nvim_set_hl(0, spec.group, opts)
    end
  end
end

-- Re-apply after colorscheme changes.
function M.attach_autocmd()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group    = vim.api.nvim_create_augroup("MdAgendaHighlights", { clear = true }),
    callback = function()
      -- Clear existing definitions so links survive theme switches.
      for _, spec in ipairs(groups) do
        vim.api.nvim_set_hl(0, spec.group, {})
      end
      M.setup()
    end,
  })
end

return M
