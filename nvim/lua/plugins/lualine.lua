return {
  "nvim-lualine/lualine.nvim",
  lazy = false,
  priority = 1000,
  dependencies = {
    "kyazdani42/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
  },
  config = function()
    local noice = require"noice"

    require"lualine".setup {
      options = {
        icons_enabled = true,
        component_separators = { left = "", right = ""},
        section_separators = { left = "", right = ""},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = {"mode"},
        lualine_b = {"branch", "diff", "diagnostics"},
        lualine_c = {
          {
            noice.api.statusline.mode.get,
            cond = noice.api.statusline.mode.has,
            color = { fg = '#ff0000' },
          },
          "filename"
        },
        lualine_x = {"encoding", "fileformat", "filetype"},
        lualine_y = {"progress"},
        lualine_z = {"location"}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {"filename"},
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = { lualine_z = {"tabs"} },
      -- tabline = { lualine_a = {"buffers"}, lualine_z = {"tabs"} },
      winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {"filename"},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
      },
      inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {"filename"},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
      },
      extensions = {}
    }
  end,
}

