return {
  {
    "stevearc/oil.nvim",
    ---@module "oil"
    ---@type oil.SetupOpts
    opts = {
      lsp_file_methods = {
        enabled = true,
      },
      show_hidden = false,
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["<C-r>"] = "actions.refresh",
        ["<C-s>"] = { "actions.select", opts = { horizontal = true }},
        ["<C-v>"] = { "actions.select", opts = { vertical = true }},
      },
      is_hidden_file = function(name, bufnr)
        -- Debug: uncomment this line temporarily to see what names are being passed
        -- print("Oil is_hidden_file called with:", vim.inspect(name))

        -- Hide node_modules directories
        if name == "node_modules" then
          return true
        end

        -- You can also try matching the end of paths in case full paths are passed
        if name:match("/node_modules$") or name:match("\\node_modules$") then
          return true
        end

        -- Don't hide dotfiles - you need to see them as an engineer
        return false
      end,
      -- Alternative: try using the view_options instead
      view_options = {
        is_hidden_file = function(name, bufnr)
          -- Debug: uncomment this line temporarily to see what names are being passed
          -- print("Oil view_options is_hidden_file called with:", vim.inspect(name))

          if name == "node_modules" then
            return true
          end

          -- Try both forward and backslash patterns
          if name:match("/node_modules$") or name:match("\\node_modules$") then
            return true
          end

          return false
        end,
      },
      default_file_explorer = true,
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function(_, opts)
      require("oil").setup(opts)
    end,
    priority = 100,
  }
}
