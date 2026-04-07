return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  -- zk LSP client: note search, backlinks, tag search, wikilink completion
  {
    "zk-org/zk-nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    ft = { "markdown" },
    config = function()
      require("zk").setup({
        picker = "telescope",
        lsp = {
          config = {
            cmd = { "zk", "lsp" },
            name = "zk",
          },
          auto_attach = {
            enabled = true,
            filetypes = { "markdown" },
          },
        },
      })
    end,
  },

  -- mkdnflow: in-buffer markdown editing (links, todos, lists, YAML, folding)
  -- tables module disabled — vim-table-mode handles tables (with formula support)
  {
    "jakewvincent/mkdnflow.nvim",
    ft = { "markdown" },
    config = function()
      require("mkdnflow").setup({
        modules = {
          tables = false,  -- handled by vim-table-mode (formula support)
          yaml   = true,   -- parse YAML frontmatter
          folds  = false, -- markview.nvim owns folding
        },
        -- resolve links relative to the current file's directory
        path_resolution = {
          primary     = "current",
          fallback    = "current",
          root_marker = ".zk",
        },
        links = {
          style              = "wiki",
          implicit_extension = "md",
          -- disable mkdnflow's auto date-prefix on link creation
          transform_on_create = false,
        },
        to_do = {
          statuses = {
            not_started = {
              marker = " ",
              sort   = { section = 1, position = "top" },
              propagate = {
                up = function(host_list)
                  for _, item in ipairs(host_list.items) do
                    if item.status.name ~= "not_started" then
                      return "in_progress"
                    end
                  end
                  return "not_started"
                end,
                down = function(child_list)
                  local t = {}
                  for _ = 1, #child_list.items do
                    table.insert(t, "not_started")
                  end
                  return t
                end,
              },
            },
            in_progress = {
              marker = "/",
              sort   = { section = 2, position = "bottom" },
              propagate = {
                up   = function() return "in_progress" end,
                down = function() end,
              },
            },
            blocked = {
              marker = "!",
              sort   = { section = 3, position = "bottom" },
              propagate = {
                up   = function() return "in_progress" end,
                down = function() end,
              },
            },
            cancelled = {
              marker = "-",
              sort   = { section = 4, position = "top" },
              propagate = {
                up = function(host_list)
                  for _, item in ipairs(host_list.items) do
                    if item.status.name ~= "cancelled" then
                      return "in_progress"
                    end
                  end
                  return "cancelled"
                end,
                down = function(child_list)
                  local t = {}
                  for _ = 1, #child_list.items do
                    table.insert(t, "cancelled")
                  end
                  return t
                end,
              },
            },
            complete = {
              marker = { "x", "X" },
              sort   = { section = 5, position = "top" },
              propagate = {
                up = function(host_list)
                  for _, item in ipairs(host_list.items) do
                    if item.status.name ~= "complete" then
                      return "in_progress"
                    end
                  end
                  return "complete"
                end,
                down = function(child_list)
                  local t = {}
                  for _ = 1, #child_list.items do
                    table.insert(t, "complete")
                  end
                  return t
                end,
              },
            },
          },
          status_order = { "not_started", "in_progress", "blocked", "cancelled", "complete" },
        },
        mappings = {
          MkdnEnter                  = { { "n", "v" }, "<CR>" },
          MkdnGoBack                 = { "n", "<BS>" },
          MkdnGoForward              = { "n", "<Del>" },
          MkdnNextLink               = { "n", "<Tab>" },
          MkdnPrevLink               = { "n", "<S-Tab>" },
          MkdnFollowLink             = false,
          MkdnDestroyLink            = { "n", "<M-CR>" },
          MkdnToggleToDo             = { { "n", "v" }, "<C-Space>" },
          MkdnNewListItemBelowInsert = { "n", "o" },
          MkdnNewListItemAboveInsert = { "n", "O" },
          MkdnUpdateNumbering        = false,
          MkdnNextHeading            = { "n", "]]" },
          MkdnPrevHeading            = { "n", "[[" },
          MkdnFoldSection            = false,
          MkdnUnfoldSection          = false,
          -- table mappings off (vim-table-mode owns tables)
          MkdnTableNextCell          = false,
          MkdnTablePrevCell          = false,
          MkdnTableNextRow           = false,
          MkdnTablePrevRow           = false,
          MkdnTableNewRowBelow       = false,
          MkdnTableNewRowAbove       = false,
          MkdnTableNewColAfter       = false,
          MkdnTableNewColBefore      = false,
          MkdnTableDeleteRow         = false,
          MkdnTableDeleteCol         = false,
          MkdnTab                    = false,
          MkdnSTab                   = false,
          MkdnCreateLink             = false,
          MkdnCreateLinkFromClipboard = { { "n", "v" }, "<leader>p" },
          MkdnMoveSource             = false,
          MkdnYankAnchorLink         = false,
          MkdnYankFileAnchorLink     = false,
          MkdnIncreaseHeading        = false,
          MkdnDecreaseHeading        = false,
          MkdnTagSpan                = false,
        },
      })
    end,
  },

  -- markview.nvim: treesitter-based markdown concealment and rendering
  -- lazy = false per upstream recommendation (already lazy by design)
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("markview").setup({
        preview = {
          -- hybrid mode: concealment clears around the cursor while editing
          modes        = { "n", "no", "c" },
          hybrid_modes = { "n" },
        },

        markdown = {
          headings = {
            enable = true,
            -- icons carried over from neorg config (user can swap)
            heading_1 = { style = "icon", icon = "  ",  hl = "MarkviewHeading1" },
            heading_2 = { style = "icon", icon = "  ",  hl = "MarkviewHeading2" },
            heading_3 = { style = "icon", icon = "󰔶  ", hl = "MarkviewHeading3" },
            heading_4 = { style = "icon", icon = "  ",  hl = "MarkviewHeading4" },
            heading_5 = { style = "icon", icon = "󰜁  ", hl = "MarkviewHeading5" },
            heading_6 = { style = "icon", icon = "  ",  hl = "MarkviewHeading6" },
            shift_width = 0,
          },

          list_items = {
            enable = true,
            -- placeholder bullet — user will swap for NERDfont glyph
            marker_minus = { add_padding = true, conceal_on_checkboxes = true, text = "→", hl = "MarkviewListItemMinus" },
            marker_plus  = { add_padding = true, conceal_on_checkboxes = true, text = "→", hl = "MarkviewListItemPlus" },
            marker_star  = { add_padding = true, conceal_on_checkboxes = true, text = "→", hl = "MarkviewListItemStar" },
          },

          code_blocks = { enable = true },
          tables      = { enable = true },  -- decorative only, no edit conflict with vim-table-mode
        },

        markdown_inline = {
          -- checkboxes matching mkdnflow markers
          -- placeholder icons — user will swap for NERDfont glyphs
          checkboxes = {
            enable   = true,
            unchecked = { text = "○", hl = "MarkviewCheckboxUnchecked" },  -- [ ]  not_started
            checked   = { text = "●", hl = "MarkviewCheckboxChecked" },    -- [x]  complete
            ["/"]     = { text = "◎", hl = "MarkviewCheckboxPending" },    -- [/]  in_progress
            ["!"]     = { text = "⊘", hl = "MarkviewCheckboxUnchecked" }, -- [!]  blocked
            ["-"]     = { text = "⊗", hl = "MarkviewCheckboxCancelled" }, -- [-]  cancelled
          },
        },

        yaml = {
          properties = {
            enable = true,
            -- frontmatter field icons (user will swap for NERDfont glyphs)
            ["^title$"]    = { use_types = false, text = " ",  hl = "MarkviewIcon4" },
            ["^tags$"]     = { use_types = false, text = " ",  hl = "MarkviewIcon0" },
            ["^status$"]   = { use_types = false, text = " ",  hl = "MarkviewIcon3" },
            ["^priority$"] = { use_types = false, text = " ",  hl = "MarkviewIcon2" },
            ["^due$"]      = { use_types = false, text = "󰃭 ", hl = "MarkviewIcon5" },
            ["^created$"]  = { use_types = false, text = " ",  hl = "MarkviewIcon6" },
            ["^updated$"]  = { use_types = false, text = " ",  hl = "MarkviewIcon6" },
          },
        },
      })
    end,
  },

  -- calendar-vim: date picker, dispatches to insert-date or open-journal
  {
    "mattn/calendar-vim",
    cmd = { "Calendar", "CalendarH", "CalendarT", "CalendarVR" },
    config = function()
      -- module-level mode variable; set by keymaps before opening calendar
      _G._calendar_mode = "date"

      -- calendar-vim calls g:calendar_action(day, month, year, week, mode)
      -- Bridge to Lua via luaeval.
      vim.cmd([[
        function! CalendarAction(day, month, year, week, mode)
          call luaeval(
            \ 'require("config.calendar").action(_A[1],_A[2],_A[3],_A[4],_A[5])',
            \ [a:day, a:month, a:year, a:week, a:mode]
          \ )
        endfunction
        let g:calendar_action = 'CalendarAction'
      ]])
    end,
  },

  -- mdagenda: custom markdown todo/agenda panel (local plugin)
  {
    dir = vim.fn.stdpath("config") .. "/lua/mdagenda",
    name = "mdagenda",
    lazy = true,
    keys = {
      { "<leader>na", function() require("mdagenda").toggle() end, desc = "zk: Agenda" },
    },
    config = function()
      require("mdagenda").setup()
    end,
  },
}
