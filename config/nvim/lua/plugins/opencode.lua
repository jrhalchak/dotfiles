return {
  {
    'NickvanDyke/opencode.nvim',
    dependencies = {
      -- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
      { 'folke/snacks.nvim', opts = { input = { enabled = true } } },
    },
    config = function()
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`
      }

      -- Required for `opts.auto_reload`
      vim.opt.autoread = true
    end,
  }
}
