local utils = require"utils"
local constants = require"constants"

--[[
  The normal/visual configurations are setup for which-key. Use utils.keymap if
  which-key isn"t in the config.
--]]
local M = {}

-- Disable arrow keys before setting
utils.keymap('', '<up>', '<nop>')
utils.keymap('', '<down>', '<nop>')
utils.keymap('', '<left>', '<nop>')
utils.keymap('', '<right>', '<nop>')

-- ============================================================
-- Keymaps for vim modes using plugins/whichkey
-- ============================================================
M.normal = {
  {
    name = "Win resize",
    ["<up>"] = { ":resize -2<CR>", "+/- Win v-size" },
    ["<down>"] = { ":resize +2<CR>", "+/- Win v-size" },
    ["<left>"] = { ":vertical resize -2<CR>", "+/- Win h-size" },
    ["<right>"] = { ":vertical resize +2<CR>", "+/- Win h-size" },
  },
  -- TODO add to netrw commands
  {
    name = "Win traversal",
    ["<C-h>"] = { "<C-w>h", "Move left" },
    ["<C-j>"] = { "<C-w>j", "Move right" },
    ["<C-k>"] = { "<C-w>k", "Move up" },
    ["<C-l>"] = { "<C-w>l", "Move down" },
  },
  {
    name = "quickfix",
    ["[c"] = { ":cprevious<CR>", "previous" },
    ["]c"] = { ":cnext<CR>", "next" },
  },
  {
    name = "Buffer switching",
    L = { ":bnext<CR>", "Next buffer" },
    H = { ":bprevious<CR>", "Previous buffer" },
  },
  {
    name = "Tab traversal",
    [constants.IS_MAC and "Ò" or "<A-L>"] = { ":tabn<CR>", "Next tab" },
    [constants.IS_MAC and "Ó" or "<A-H>"] = { ":tabp<CR>", "Previous tab" },
  },

  ["<leader>"] = {
    h = { ":nohl<CR>", "Clear highlights" },
    t = {
      name = "Split Orientation",
      k = { "<C-w>t<C-w>K", "V to H" },
      h = { "<C-w>t<C-w>H", "H to V" },
    },
    g = {
      name = "git",
      b = { ":CocCommand git.showBlameDoc<CR>", "git blame" },
    },
    -- lf = { "<cmd>lua vim.lsp.buf.format{ async = true }<cr>", "Format buffer" },
    {
      name = "Explore with Neotree",
      e = {
        -- t = { ":20Vex<CR>", "Explore w/ side tree" },
        v = { ":vsplit | Neotree current<CR>", "Explore (vertical split)" },
        s = { ":split | Neotree current<CR>", "Explore (horizontal split)" },
        w = { ":Neotree current<CR>", "Explore in window (also \"-\")" },
        l = { ":Neotree left<CR>", "Explore (tree left)" },
        r = { ":Neotree right<CR>", "Explore (tree right)" },
      }
    },
  },
  ["-"] = { ":Neotree current<CR>", "Jump up to Netrw" },
  {
    name = "Diagnostics",
    ['<leader>k'] = { vim.diagnostic.open_float, "Open floating diagnostics" },
    ['[d'] = { vim.diagnostic.goto_prev, "Previous diagnostic" },
    [']d'] = { vim.diagnostic.goto_next, "Next diagnostic" },
    ['<leader>ll'] = { vim.diagnostic.setloclist, "Set loclist" },
  },
  -- TODO: This doesn"t work well
  {
    name = "Move lines",
    [constants.IS_MAC and "∆" or "<A-j>"] = {
      "<Esc>:m .+1<CR>==gi", "Move line up"
    },
    [constants.IS_MAC and "˚" or "<A-k>"] = {
      "<Esc>:m .-2<CR>==gi", "Move line down"
    },
  },
}

--[[
  TODO: consider below
  -- Helper for sync scrolling and Diffing
  -- Mark current buffer for syncing view
  -- map("n", "<leader>wv", ":set scb<CR>")
  -- Mark current buffer for diffing
  -- map("n", "<leader>wd", ":diffthis<CR>")
--]]

M.visual = {
  {
    name = "Horizontal scrolling",
    zL = { "zL", "Scroll right "},
    zH = { "zH", "Scroll left "},
  },
  p = { "\"_dP", "Better paste" },
  -- TODO: This doesn"t work well
  ["<"] = { "<gv", "Better decrease indent"},
  [">"] = { ">gv", "Better increase indent"},
  [";"] = { ":", "Command in visual mode" },
  f = {
    name = "Fold levels",
    ["0"] = { ":set foldlevel=0<CR>", "Set fold lvl 0" },
    ["1"] = { ":set foldlevel=1<CR>", "Set fold lvl 1" },
    ["2"] = { ":set foldlevel=2<CR>", "Set fold lvl 2" },
    ["3"] = { ":set foldlevel=3<CR>", "Set fold lvl 3" },
    ["4"] = { ":set foldlevel=4<CR>", "Set fold lvl 4" },
    ["5"] = { ":set foldlevel=5<CR>", "Set fold lvl 5" },
    ["6"] = { ":set foldlevel=6<CR>", "Set fold lvl 6" },
    ["7"] = { ":set foldlevel=7<CR>", "Set fold lvl 7" },
    ["8"] = { ":set foldlevel=8<CR>", "Set fold lvl 8" },
    ["9"] = { ":set foldlevel=9<CR>", "Set fold lvl 9" },
  }
}

-- ============================================================
-- Keymaps for plugins/netrw
-- ============================================================

M.netrw = {
  --[[ Function mappings
  ["p"] = function(payload)
    -- Payload is an object describing the node under the cursor, the object
    -- has the following keys:
    -- - dir: the current netrw directory (vim.b.netrw_curdir)
    -- - node: the name of the file or directory under the cursor
    -- - link: the referenced file if the node under the cursor is a symlink
    -- - extension: the file extension if the node under the cursor is a file
    -- - type: the type of node under the cursor (0=dir, 1=file, 2=symlink)
    -- - col: the column of the node (for liststyle 3)
    print(vim.inspect(payload))
  end,
  -- String command mappings
  ["<Leader><Tab>"] = ":echo "string command"<CR>",
  --]]
}

-- ============================================================
-- LSP keymaps for use on buffer attach in plugins/lsp.lua
-- ============================================================

M.lsp = {
  ['gD'] = { vim.lsp.buf.declaration, "Go to Declaration" },
  ['gd'] = { vim.lsp.buf.definition, "Go to Definition" },
  ['K'] = { vim.lsp.buf.hover, "Show Hover" },
  ['gi'] = { vim.lsp.buf.implementation, "Go to Implementation" },
  ['<C-k>'] = { vim.lsp.buf.signature_help, "Signature Help" },
  ['<leader>wa'] = {
    vim.lsp.buf.add_workspace_folder,
    "Add Workspace Folder",
  },
  ['<leader>wr'] = {
    vim.lsp.buf.remove_workspace_folder,
    "Remove Workspace Folder",
  },
  ['<leader>wl'] = {
    function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end,
    "List Workspace Folders",
  },
  ['<leader>D'] = { vim.lsp.buf.type_definition, "Go to Type Definition" },
  ['<leader>rn'] = { vim.lsp.buf.rename, "Rename Symbol" },
  ['<leader>ca'] = { vim.lsp.buf.code_action, "Code Actions" },
  ['gr'] = { vim.lsp.buf.references, "Go to References" },
  ['<leader>f'] = {
    function()
      vim.lsp.buf.format { async = true }
    end,
    "Format",
  },
}

M.lsp = {}

-- ============================================================
-- Completion keymaps for use with cmp.mapping_preset in
-- plugins/lsp.lua
-- ============================================================

M.cmp = {
  -- Since we're requiring modules, I want to make sure this is
  -- loaded when the module is configured so it's invoked in the
  -- cmp config.
  get_mapping_presets = function()
    local cmp = require"cmp"
    local luasnip = require"luasnip"

    local check_backspace = function()
      local col = vim.fn.col(".") - 1
      return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
    end

    return {
      ["<C-k>"] = cmp.mapping.select_prev_item(),
      ["<C-j>"] = cmp.mapping.select_next_item(),
      ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
      ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
      ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
      ["<C-e>"] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      -- Accept currently selected item. If none selected, `select` first item.
      -- Set `select` to `false` to only confirm explicitly selected items.
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expandable() then
            luasnip.expand()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif check_backspace() then
            fallback()
          else
            fallback()
          end
        end, {
        "i",
        "s",
      }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),
    }
  end,
  which_key = {
    {
      name = "CMP Key Helper (not normal)",
    }
  },
}

M.cmp = {}


-- ============================================================
-- Telescope
-- ============================================================

-- TODO the "which_key" keys should probably have an i, v, and n, property
M.telescope = {
  get_mapping_presets = function()
    local actions = require "telescope.actions"
    -- These are INPUT MODE mappings
    return {
      ["<Down>"] = actions.cycle_history_next,
      ["<Up>"] = actions.cycle_history_prev,
      ["<C-j>"] = actions.move_selection_next,
      ["<C-k>"] = actions.move_selection_previous,
    }
  end,
  which_key = {
    -- Telescope
    normal = {
      -- TODO include lsp_definitions, diagnostics, and implemention combos if they work with CoC
      -- find
      ["<leader>ff"] = { "<cmd> Telescope find_files <CR>", "find files" },
      ["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "find all" },
      ["<leader>fw"] = { "<cmd> Telescope live_grep <CR>", "live grep" },
      ["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "find buffers" },
      ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "help page" },
      -- ["<leader>fo"] = { "<cmd> Telescope oldfiles <CR>", "find oldfiles" },
      ["<leader>fz"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "find in current buffer" },
      ["<leader>fe"] = { "<cmd> Telescope symbols <CR>", "find emojis & symbols" },

      ["<leader>fqf"] = { "<cmd> Telescope quickfix <CR>", "quickfix items" },
      ["<leader>fqfa"] = { "<cmd> Telescope quickfixhistory <CR>", "quickfix history" },
      ["<leader>fll"] = { "<cmd> Telescope loclist <CR>", "loclist items" },
      ["<leader>fch"] = { "<cmd> Telescope command_history <CR>", "command history" },
      ["<leader>fsh"] = { "<cmd> Telescope search_history <CR>", "search history" },

      -- git
      ["<leader>fgc"] = { "<cmd> Telescope git_bcommits <CR>", "buffer git commits" },
      ["<leader>fga"] = { "<cmd> Telescope git_commits <CR>", "all git commits" },
      ["<leader>fgs"] = { "<cmd> Telescope git_status <CR>", "git status" },
    },
    visual = {
      -- git
      ["<leader>fgc"] = { "<cmd> Telescope git_bcommits_range <CR>", "(visual) range git commits" },
    },
  }
}


return M
