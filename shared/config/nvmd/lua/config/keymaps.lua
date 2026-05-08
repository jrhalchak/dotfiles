-- TODO: remove whichkey, maybe export LSP keymaps from here somehow?
local constants = require"config.constants"
local utils = require"config.utils"

-- Opens index.md for the given vault entry { name, path }.
local function open_vault_index(vault)
  vim.cmd("edit " .. vim.fn.fnameescape(vault.path .. "/index.md"))
end

-- Shows a telescope picker over all configured vaults; calls cb with the chosen entry.
local function pick_vault(prompt, cb)
  local cfg = require("mdagenda.config")
  vim.ui.select(cfg.vault_list(), {
    prompt = prompt,
    format_item = function(v) return v.name end,
  }, function(choice)
    if choice then cb(choice) end
  end)
end

-- Inserts YAML frontmatter at the top of the current markdown buffer.
-- No-ops if frontmatter already exists.
local function insert_note_metadata()
  if vim.bo.filetype ~= "markdown" then return end
  if vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "---" then
    vim.notify("Frontmatter already exists", vim.log.levels.INFO)
    return
  end
  local title     = vim.fn.expand("%:t:r")
  local author    = vim.fn.expand("$USER")
  local timestamp = vim.fn.strftime("%Y-%m-%dT%H:%M:%S%z")
  local lines = {
    "---",
    "title: " .. title,
    "description: ",
    "authors: " .. author,
    "categories: ",
    "created: " .. timestamp,
    "updated: " .. timestamp,
    "---",
    "",
  }
  vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
  -- land on the title value, ready to edit
  vim.api.nvim_win_set_cursor(0, { 2, #"title: " })
  vim.cmd("startinsert!")
end

-- Follow the first wiki link or markdown link on the current line.
-- Mimics Neorg's <CR> navigation: jump to the link target regardless of where
-- the cursor sits on the line. Silent no-op when no link is found.
local function follow_first_link_on_line()
  local line = vim.api.nvim_get_current_line()

  -- Wiki link: [[path]], [[path#anchor]], [[path|alias]], [[path#anchor|alias]]
  local wiki = line:match('%[%[([^%]]+)%]%]')
  if wiki then
    local target = wiki:match('^([^|]+)') or wiki
    local path, anchor = target:match('^([^#]+)#?(.*)')
    anchor = (anchor and anchor ~= '') and anchor or nil
    require('mkdnflow').links.followLink({
      path   = vim.trim(path),
      anchor = anchor and vim.trim(anchor) or nil,
    })
    return
  end

  -- Standard markdown link: [text](path) or [text](path#anchor)
  local md = line:match('%[.-%]%(([^)]+)%)')
  if md then
    local path, anchor = md:match('^([^#]+)#?(.*)')
    anchor = (anchor and anchor ~= '') and anchor or nil
    require('mkdnflow').links.followLink({
      path   = vim.trim(path),
      anchor = anchor and vim.trim(anchor) or nil,
    })
    return
  end

  -- No link found: silent no-op
end

--[[
  The normal/visual configurations are setup for which-key. Use utils.keymap if
  which-key isn"t in the config.
--]]
local M = {}

local function genfoldkeys_whichkey()
  local folds = {}
  for i = 0, 9 do
    table.insert(folds, {
      "f" .. i,
      ":set foldlevel=" .. i .. "<CR>",
      desc = "Set fold lvl " .. i,
    })
  end
  return folds
end

-- normal mode
-- Now handled by smart-splits.nvim (below)
-- local window_traversal_keys_whichkey = {
--   { "<C-h>", "<C-w>h", desc = "Move left" },
--   { "<C-j>", "<C-w>j", desc = "Move right" },
--   { "<C-k>", "<C-w>k", desc = "Move up" },
--   { "<C-l>", "<C-w>l", desc = "Move down" },
-- }

M.setup = function()
  local wk = require"which-key"
  local opencode = require"opencode"


  local opencode_select = { '<leader>os', opencode.select, desc = 'Select opencode prompt' }

  local which_keymaps = {
    -- Arrow keys disabled
    mode = { "n" },
    { "<up>", "<nop>" },
    { "<down>", "<nop>" },
    { "<left>", "<nop>" },
    { "<right>", "<nop>" },

    -- Window resizing
    -- Now handled by smart-splits.nvim (below)
    -- { "<up>", ":resize -2<CR>", desc = "+/- Win v-size" },
    -- { "<down>", ":resize +2<CR>", desc = "+/- Win v-size" },
    -- { "<left>", ":vertical resize -2<CR>", desc = "+/- Win h-size" },
    -- { "<right>", ":vertical resize +2<CR>", desc = "+/- Win h-size" },

    -- Buffer switching
    { "L", ":bnext<CR>", desc = "Next buffer" },
    { "H", ":bprevious<CR>", desc = "Previous buffer" },

    -- Tab switching
    { constants.IS_MAC and "Ò" or "<A-L>", ":tabn<CR>", desc = "Next tab" },
    { constants.IS_MAC and "Ó" or "<A-H>", ":tabp<CR>", desc = "Previous tab" },

    { constants.IS_MAC and "∆" or "<A-j>", "<Esc>:m .+1<CR>==gi", desc = "Move line up" },
    { constants.IS_MAC and "˚" or "<A-k>", "<Esc>:m .-2<CR>==gi", desc = "Move line down" },

    -- Telescope
    { "<leader>f", group = "Telescope" },
    { "<leader>ff", ":Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fg", ":Telescope live_grep<CR>", desc = "Grep files" },
    { "<leader>fr", ":Telescope oldfiles<CR>", desc = "Old files" },
    { "<leader>fp", ":Telescope projects<CR>", desc = "Projects" },
    { "<leader>fb", ":Telescope buffers<CR>", desc = "Buffers" },
    { "<leader>fe", ":Telescope emoji<CR>", desc = "Emojis" },

    -- Netrw
    -- { "<leader>et", ":20Vex<CR>", desc = "Netrw side panel" },
    -- { "<leader>ev", ":Vex<CR>", desc = "Netrw (vsplit)" },
    -- { "<leader>es", ":Sex<CR>", desc = "Netrw (split)" },
    -- { "<leader>ew", ":Ex<CR>", desc = "Netrw here (also \"-\")" },
    -- { "-", ":Ex<CR>", desc = "Jump up to Netrw" },

    -- Oil.nvim
    { "<leader>et", "<CMD>Oil --float<CR>", desc = "Oil side panel (float)" },
    { "<leader>ev", "<CMD>vertical Oil<CR>", desc = "Oil (vsplit)" },
    { "<leader>es", "<CMD>split | Oil<CR>", desc = "Oil (split)" },
    { "<leader>ew", "<CMD>Oil<CR>", desc = "Oil here" },
    { "-", "<CMD>Oil<CR>", desc = "Jump up to folder w/ Oil" },

    -- Misc
    { "<leader>u", group = "Utilities" },
    { "<leader>uh", ":nohl<CR>", desc = "UTIL: Clear highlights" },
    { "<leader>ug", utils.open_plugin_url, desc = "UTIL: Open Github Plugin URL" },
    { "<leader>ut", utils.toggle_coverage_filter, desc = "UTIL: Toggle a filter for test coverage with < 60% in any column" },

    -- Splits
    { "<leader>tk", "<C-w>t<C-w>K", desc = "Split Orientation V to H" },
    { "<leader>th", "<C-w>t<C-w>H", desc = "Split Orientation H to V" },

    -- Diffing
    { "<leader>wv", ":set scb<CR>", desc = "Mark buf for sync view" },
    { "<leader>wd", ":diffthis<CR>", desc = "Mark buf for diff" },

    -- Notes
    { "<leader>n",   group = "Notes" },
    -- new notes
    { "<leader>nn",  group = "New note" },
    { "<leader>nnn", function() require("config.notes").new_note() end,            desc = "notes: New note (here)" },
    -- journal
    { "<leader>nj",  group = "Journal" },
    { "<leader>njt", function() require("config.notes").journal(0)  end,           desc = "notes: Journal today" },
    { "<leader>njn", function() require("config.notes").journal(1)  end,           desc = "notes: Journal tomorrow" },
    { "<leader>njp", function() require("config.notes").journal(-1) end,           desc = "notes: Journal yesterday" },
    { "<leader>njc", function() _G._calendar_mode = "journal" vim.cmd("Calendar") end, desc = "notes: Journal calendar picker" },
    { "<leader>njl", function() require("config.notes").journal_list() end,        desc = "notes: List journal entries" },
    -- find / search
    { "<leader>nf",  group = "Find" },
    { "<leader>nd",  function() _G._calendar_mode = "date"    vim.cmd("Calendar") end, desc = "notes: Insert date from calendar" },
    { "<leader>nff", function() require("config.notes").find() end,                desc = "notes: Find notes" },
    { "<leader>nft", function() require("config.notes").grep_tags() end,           desc = "notes: Find by tag" },
    { "<leader>nfg", function() require("config.notes").grep() end,                desc = "notes: Grep notes" },
    -- current buffer
    { "<leader>nb",  function() require("config.notes").backlinks() end,           desc = "notes: Backlinks" },
    { "<leader>nl",  function() require("config.notes").note_links() end,          desc = "notes: Links in note" },
    { "<leader>ni",  function() require("config.notes").insert_link() end,         desc = "notes: Insert link" },
    { "<leader>nm",  insert_note_metadata,                                         desc = "notes: Insert note metadata" },
    { "<leader>nI",  function()
        -- 1. If inside a vault, open its index directly
        local vault = require("config.notes").vault_for_buf()
        if vault then
          open_vault_index(vault)
          return
        end
        -- 2. Fall back to ZK_DEFAULT_VAULT (or configured env var)
        local default = require("mdagenda.config").default_vault()
        if default then
          open_vault_index(default)
          return
        end
        -- 3. Nothing configured: show picker
        pick_vault("Open vault index:", open_vault_index)
      end,                                                                          desc = "notes: Open vault index" },
    { "<leader>nv",  function()
        pick_vault("Switch vault:", open_vault_index)
      end,                                                                          desc = "notes: Switch vault" },
    { "<leader>nV",  function()
        if vim.o.virtualedit == "all" then
          vim.o.virtualedit = ""
          vim.notify("virtualedit: off", vim.log.levels.INFO)
        else
          vim.o.virtualedit = "all"
          vim.notify("virtualedit: all (edit anywhere)", vim.log.levels.INFO)
        end
      end,                                                                          desc = "notes: Toggle virtualedit (edit anywhere, for diagrams)" },
    { "<leader>n?",  function()
        vim.cmd("vsplit " .. vim.fn.fnameescape(vim.fn.stdpath("config") .. "/NOTES.md"))
      end,                                                                          desc = "notes: Open reference" },
    -- agenda
    { "<leader>na",  function() require("mdagenda").toggle() end,                  desc = "Agenda" },
    { "<leader>nD",  function() _G._calendar_mode = "due_date"     vim.cmd("Calendar") end, desc = "Set due date" },
    { "<leader>nT",  function() _G._calendar_mode = "due_datetime" vim.cmd("Calendar") end, desc = "Set due date+time" },
    { "<leader>nP",  function() require("mdagenda.edit").cycle_priority() end,     desc = "Cycle priority" },
    { "<leader>nC",  function() require("mdagenda.convert").todo_to_task() end,    desc = "Convert todo to task file" },

    -- Table mode
    { "<leader>nt",   group = "Table mode" },
    { "<leader>ntt",  ":TableModeToggle<CR>",      desc = "Table: Toggle table mode" },
    { "<leader>ntr",  ":TableModeRealign<CR>",     desc = "Table: Realign" },
    { "<leader>ntf",  ":TableEvalFormulaLine<CR>", desc = "Table: Eval formula line" },
    { "<leader>nta",  ":TableAddFormula<CR>",      desc = "Table: Add formula" },
    { "<leader>ntd",  group = "Table: Delete" },
    { "<leader>nti",  group = "Table: Insert" },

    -- Opencode
    { '<leader>ot', opencode.toggle, desc = 'Toggle opencode' },
    { '<leader>oA', opencode.ask, desc = 'Ask opencode' },
    { '<leader>oa', function() opencode.ask('@cursor: ') end, desc = 'Ask opencode about this' },
    { '<leader>on', function() opencode.command('session_new') end, desc = 'New opencode session' },
    { '<leader>oy', function() opencode.command('messages_copy') end, desc = 'Copy last opencode response' },
    { '<S-C-u>',    function() opencode.command('messages_half_page_up') end, desc = 'Messages half page up' },
    { '<S-C-d>',    function() opencode.command('messages_half_page_down') end, desc = 'Messages half page down' },

    -- Example: keymap for custom prompt
    { '<leader>oe', function() opencode.prompt('Explain @cursor and its context') end, desc = 'Explain this code' },
    opencode_select
  }

  -- Add window traversal keys
  -- Now handled by smart-splits.nvim (below)
  -- for _, v in ipairs(window_traversal_keys_whichkey) do
  --   table.insert(which_keymaps, v)
  -- end

  -- VISUAL mode mappings
  local which_keymaps_v = {
    mode = { "v" },
    { "zL", "zL", desc = "Scroll right" },
    { "zH", "zH", desc = "Scroll left" },
    { "p", "\"_dP", desc = "Better paste" },
    { "<", "<gv", desc = "Better decrease indent" },
    { ">", ">gv", desc = "Better increase indent" },
    { ";", ":", desc = "Command in visual mode" },
    { '<leader>oa', function() opencode.ask('@selection: ') end, desc = 'Ask opencode about selection' },
    opencode_select
  }

  for _, v in ipairs(genfoldkeys_whichkey()) do
    table.insert(which_keymaps_v, v)
  end

  wk.add(which_keymaps)
  wk.add(which_keymaps_v)
end

M.setup_lsp = function(buf)
  local wk = require"which-key"

  wk.add({
    {
      mode = "n",
      buffer = buf,
      { "K", vim.lsp.buf.hover, desc = "LSP: Hover" },
      { "gD", vim.lsp.buf.declaration, desc = "Go to Declaration" },
      { "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
      { "gi", vim.lsp.buf.implementation, desc = "Go to Implementation" },
      { "gr", vim.lsp.buf.references, desc = "Go to References" },
      { "<leadeR>l", group ="lsp" },
      { "<leader>lt", vim.lsp.buf.type_definition, desc = "LSP: Go to Type Definition" },
      { '<leader>ll', vim.diagnostic.setloclist, desc = "LSP: Set loclist" },
      { "<leader>ls", vim.lsp.buf.workspace_symbol, desc = "LSP: View Workspace Symbols" },
      { "<leader>ld", vim.diagnostic.open_float, desc = "LSP: View Diagnostic" },
      { "<leader>la", vim.lsp.buf.code_action, desc = "LSP: View Code Action" },
      { "<leader>lr", vim.lsp.buf.references, desc = "LSP: View References" },
      { "<leader>ln", vim.lsp.buf.rename, desc = "LSP: Rename" },
      {
        "<leader>lwa",
        vim.lsp.buf.add_workspace_folder,
        desc = "LSP: Add Workspace Folder",
      },
      {
        "<leader>lwr",
        vim.lsp.buf.remove_workspace_folder,
        desc = "LSP: Remove Workspace Folder",
      },
      {
        "<leader>lwl",
        function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end,
        desc = "LSP: List Workspace Folders",
      },

      {
        "<leader>lf",
        function()
          vim.lsp.buf.format { async = true }
        end,
        desc = "LSP: Format",
      },
      {
        "[d",
        function()
          vim.diagnostic.jump({ count=1, float=true })
        end,
        desc = "LSP: Next Diagnostic"
      },
      {
        "]d",
        function()
          vim.diagnostic.jump({ count=-1, float=true })
        end,
        desc = "LSP: Previous Diagnostic"
      },
    },
    {
      mode = "i",
      buffer = buf,
      {
        "<C-h>",
        function()
          vim.lsp.buf.signature_help()
        end,
        desc = "LSP: Signature Help"
      },
    },
  })
end


M.setup_markdown = function(buf)
  local wk = require("which-key")

  -- Normal mode: <CR> follows the first link on the line (Neorg-style navigation)
  vim.keymap.set('n', '<CR>', follow_first_link_on_line, {
    buffer = buf,
    desc   = 'Follow first link on line',
  })

  -- Normal mode: <leader>nL selects the word under cursor, then opens a picker
  -- to choose an existing note; the word becomes the link display text.
  vim.keymap.set('n', '<leader>nL', function()
    require("config.notes").insert_link()
  end, { buffer = buf, desc = 'notes: Insert link (word as display text)' })

  -- Visual mode: <leader>nL inserts a link, using selection as display text
  -- Visual mode: <leader>nc creates a new note from selection (title = selection)
  --              and replaces the selection with a link to the new note
  wk.add({
    {
      mode   = { "v" },
      buffer = buf,
      { "<leader>nL", function() require("config.notes").insert_link_visual() end,    desc = "notes: Insert link (selection as display text)" },
      { "<leader>nc", function() require("config.notes").new_from_selection() end,    desc = "notes: New note from selection" },
    }
  })
end

M.setup_splits = function()
  local wk = require"which-key"
  local smart_splits = require("smart-splits")

  wk.add({
    {
      mode = "n",
      { "<C-h>", smart_splits.move_cursor_left, desc = "" },
      { "<C-j>", smart_splits.move_cursor_down, desc = "" },
      { "<C-k>", smart_splits.move_cursor_up, desc = "" },
      { "<C-l>", smart_splits.move_cursor_right, desc = "" },

      { "<A-h>", smart_splits.resize_left, desc = "" },
      { "<A-j>", smart_splits.resize_down, desc = "" },
      { "<A-k>", smart_splits.resize_up, desc = "" },
      { "<A-l>", smart_splits.resize_right, desc = "" },
    },
  })
end

-- until this is fixed
return M
-- M.netrw = {
--   --[[ Function mappings
--   ["p"] = function(payload)
--     -- Payload is an object describing the node under the cursor, the object
--     -- has the following keys:
--     -- - dir: the current netrw directory (vim.b.netrw_curdir)
--     -- - node: the name of the file or directory under the cursor
--     -- - link: the referenced file if the node under the cursor is a symlink
--     -- - extension: the file extension if the node under the cursor is a file
--     -- - type: the type of node under the cursor (0=dir, 1=file, 2=symlink)
--     -- - col: the column of the node (for liststyle 3)
--     print(vim.inspect(payload))
--   end,
--   -- String command mappings
--   ["<Leader><Tab>"] = ":echo "string command"<CR>",
--   --]]
-- }
-- M.cmp = {
--   -- Since we're requiring modules, I want to make sure this is
--   -- loaded when the module is configured so it's invoked in the
--   -- cmp config.
--   get_mapping_presets = function()
--     local cmp = require"cmp"
--     local luasnip = require"luasnip"
--
--     local check_backspace = function()
--       local col = vim.fn.col(".") - 1
--       return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
--     end
--
--     return {
--       ["<C-k>"] = cmp.mapping.select_prev_item(),
--       ["<C-j>"] = cmp.mapping.select_next_item(),
--       ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
--       ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
--       ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
--       ["<C-e>"] = cmp.mapping({
--         i = cmp.mapping.abort(),
--         c = cmp.mapping.close(),
--       }),
--       -- Accept currently selected item. If none selected, `select` first item.
--       -- Set `select` to `false` to only confirm explicitly selected items.
--       ["<CR>"] = cmp.mapping.confirm({ select = true }),
--       ["<Tab>"] = cmp.mapping(function(fallback)
--           if cmp.visible() then
--             cmp.select_next_item()
--           elseif luasnip.expandable() then
--             luasnip.expand()
--           elseif luasnip.expand_or_jumpable() then
--             luasnip.expand_or_jump()
--           elseif check_backspace() then
--             fallback()
--           else
--             fallback()
--           end
--         end, {
--         "i",
--         "s",
--       }),
--       ["<S-Tab>"] = cmp.mapping(function(fallback)
--         if cmp.visible() then
--           cmp.select_prev_item()
--         elseif luasnip.jumpable(-1) then
--           luasnip.jump(-1)
--         else
--           fallback()
--         end
--       end, {
--         "i",
--         "s",
--       }),
--     }
--   end,
--   which_key = {
--     {
--       name = "CMP Key Helper (not normal)",
--     }
--   },
-- }
--
-- return M
