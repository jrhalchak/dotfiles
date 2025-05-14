return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    -- build = "make tiktoken", -- Only on MacOS or Linux
    -- opts = {
    --   -- See Configuration section for options
    -- },
    -- See Commands section for default commands if you want to lazy load on them
    config = function()
      require"copilot".setup{}
      require"CopilotChat".setup{}
    end
  },
  {
    "zbirenbaum/copilot.lua",
    -- Remove once https://github.com/LazyVim/LazyVim/pull/5900 is released
    opts = function()
      require("copilot.api").status = require("copilot.status")
    end,
  },
}

