local keymaps = require("config.keymaps")

return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  config = function()
    local smart_splits = require("smart-splits")
    smart_splits.setup({
      default_amount = 5,
    })
    keymaps.setup_splits()
  end,
}

