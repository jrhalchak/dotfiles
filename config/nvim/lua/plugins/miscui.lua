local keymaps = require("config.keymaps")

return {
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      local devicons = require"nvim-web-devicons"

      devicons.setup {
        override = {
          norg = {
            icon = "", -- Default icon for Header 1
            color = "#4878BE",
            name = "Norg",
          },
        },
        default = true,
      }

      local default_icons = devicons.get_icons()

      devicons.set_icon {
        pyi = default_icons.pyd,
        latex = default_icons.tex,
        [".latexmkrc"] = default_icons.tex,
        sty = default_icons.tex,
        [".pylintrc"] = default_icons.toml,
        [".python-version"] = default_icons.toml,
        ["Makefile"] = default_icons.makefile,
      }
    end,
  },
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    -- optionally, override the default options:
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end
  },
  -- this is just for markdown/norg/org, move to that when it's set
  -- {
    --   "lukas-reineke/headlines.nvim",
    --   dependencies = "nvim-treesitter/nvim-treesitter",
    --   config = true
    -- },
    -- {
      --   "ramilito/winbar.nvim",
      --   event = "VimEnter", -- Alternatively, BufReadPre if we don't care about the empty file when starting with 'nvim'
      --   dependencies = { "nvim-tree/nvim-web-devicons" },
      --   config = function()
        --     require("winbar").setup({
          --       -- your configuration comes here, for example:
          --       icons = true,
          --       diagnostics = true,
          --       buf_modified = true,
          --       buf_modified_symbol = "M",
          --       -- or use an icon
          --       -- buf_modified_symbol = "●"
          --       background_color = "WinBarNC",
          --       -- or use a hex code:
          --       -- background_color = "#141415",
          --       -- or a different highlight:
          --       -- background_color = "Statusline"
          --       dim_inactive = {
            --         enabled = false,
            --         highlight = "WinBarNC",
            --         icons = true, -- whether to dim the icons
            --         name = true, -- whether to dim the name
            --       }
            --     })
            --   end
  -- },

  {
    "b0o/incline.nvim",
    dependencies = { "lewis6991/gitsigns.nvim" },
    config = function()
      local devicons = require 'nvim-web-devicons'
      require('incline').setup {
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
          if filename == '' then
            filename = '[No Name]'
          end
          local ft_icon, ft_color = devicons.get_icon_color(filename)

          local function get_git_diff()
            local icons = { removed = '', changed = '', added = '' }
            local signs = vim.b[props.buf].gitsigns_status_dict
            local labels = {}
            if signs == nil then
              return labels
            end
            for name, icon in pairs(icons) do
              if tonumber(signs[name]) and signs[name] > 0 then
                table.insert(labels, { icon .. signs[name] .. ' ', group = 'Diff' .. name })
              end
            end
            if #labels > 0 then
              table.insert(labels, { '┊ ' })
            end
            return labels
          end

          local function get_diagnostic_label()
            local icons = { error = '', warn = '', info = '', hint = '' }
            local label = {}

            for severity, icon in pairs(icons) do
              local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
              if n > 0 then
                table.insert(label, { icon .. n .. ' ', group = 'DiagnosticSign' .. severity })
              end
            end
            if #label > 0 then
              table.insert(label, { '┊ ' })
            end
            return label
          end

          return {
            { get_diagnostic_label() },
            { get_git_diff() },
            { (ft_icon or '') .. ' ', guifg = ft_color, guibg = 'none' },
            { filename .. ' ', gui = vim.bo[props.buf].modified and 'bold,italic' or 'bold' },
            { '┊  ' .. vim.api.nvim_win_get_number(props.win), group = 'DevIconWindows' },
          }
        end,
      }
    end
  },
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      dim = {
        ---@type snacks.scope.Config
        scope = {
          min_size = 5,
          max_size = 20,
          siblings = true,
        },
        -- animate scopes. Enabled by default for Neovim >= 0.10
        -- Works on older versions but has to trigger redraws during animation.
        ---@type snacks.animate.Config|{enabled?: boolean}
        animate = {
          enabled = vim.fn.has("nvim-0.10") == 1,
          easing = "outQuad",
          duration = {
            step = 20, -- ms per step
            total = 300, -- maximum duration
          },
        },
        -- what buffers to dim
        filter = function(buf)
          return vim.g.snacks_dim ~= false and vim.b[buf].snacks_dim ~= false and vim.bo[buf].buftype == ""
        end,
      },
      bufdelete = { enabled = true },
      bigfile = { enabled = true },
      input = { enabled = true },
      indent = {
        animate = {
          duration = { step = 5, total = 50 },
        },
      },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scroll = {
        animate = {
          duration = { step = 5, total = 50 },
          easing = "inOutQuad",
        },
        -- faster animation when repeating scroll after delay
        animate_repeat = {
          delay = 100, -- delay in ms before using the repeat animation
          duration = { step = 5, total = 50 },
          easing = "linear",
        },
        -- what buffers to animate
        filter = function(buf)
          return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and vim.bo[buf].buftype ~= "terminal"
        end,
      },
      statuscolumn = { enabled = true },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      lazygit = { enabled = true },
      toggle = {
        {
          map = vim.keymap.set, -- keymap.set function to use
          which_key = true, -- integrate with which-key to show enabled/disabled icons and colors
          notify = true, -- show a notification when toggling
          -- icons for enabled/disabled states
          icon = {
            enabled = " ",
            disabled = " ",
          },
          -- colors for enabled/disabled states
          -- color = {
            --   enabled = "green",
            --   disabled = "yellow",
            -- },
            -- wk_desc = {
              --   enabled = "Disable ",
              --   disabled = "Enable ",
              -- },
            }
          },
          dashboard = { enabled = false },
          explorer = { enabled = false },
          picker = { enabled = false },
          scope = { enabled = false },
          words = { enabled = false },
        }
      },
      {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
          -- configuration goes here
        },
        -- Just adding them in keymaps.lua
        keys = {},
        config = function()
          keymaps.setup()
        end
      }
    }
