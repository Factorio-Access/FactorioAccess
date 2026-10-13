-- Fast travel points gain a surface and a category: see scripts/migration-steps/fast-travel-surfaces-and-categories.lua.
-- Never rename this file: the save remembers migrations by file name and would run it again on converted data.
local convert = require("scripts.migration-steps.fast-travel-surfaces-and-categories")

local nauvis = game.get_surface("nauvis")
for _, player_data in pairs(storage.players or {}) do
   -- A player who never used fast travel has no table: the storage module makes one in the new format on first use
   if player_data.fast_travel then
      player_data.fast_travel = convert(player_data.fast_travel, nauvis and nauvis.index)
   end
end
