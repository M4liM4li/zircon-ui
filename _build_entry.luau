--!nolint
--!nocheck
--!optimize 2

__SH = { COMPINDEXES = {} }

local Cascade = require("@src/init")
local SaveManager = require("@modules/saveManager")

Cascade.SaveManager = SaveManager

return Cascade
