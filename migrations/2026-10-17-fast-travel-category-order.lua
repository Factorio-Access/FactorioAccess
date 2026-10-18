-- Fast travel categories gain an order: see scripts/migration-steps/fast-travel-category-order.lua.
-- Never rename this file: the save remembers migrations by file name and would run it again on converted data.
local convert = require("scripts.migration-steps.fast-travel-category-order")

for _, player_data in pairs(storage.players or {}) do
   -- A player who never used fast travel has no table: the storage module makes one in the new format on first use
   if player_data.fast_travel then player_data.fast_travel = convert(player_data.fast_travel) end
end
