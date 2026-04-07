-- Load URI patch first, before anything else
require("jrh.uri_patch")

local options = require("config.opts")
local statusline = require("config.statusline")
local tabline = require("config.tabline")

require("config.lazy")

options.setup()
statusline.setup()
tabline.setup()

