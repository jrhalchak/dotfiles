local options = require("config.opts")
local autocmds = require("config.autocmds")
local statusline = require("config.statusline")
local tabline = require("config.tabline")
local keymaps = require("config.keymaps")

require("config.lazy")
require("config.lspsetup")

options.setup()
autocmds.setup()
statusline.setup()
tabline.setup()
keymaps.setup()

