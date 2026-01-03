local VanillaMode = require("scripts.vanilla-mode")

local mod = {}

function mod.on_tick()
   for _, p in pairs(game.players) do
      if not VanillaMode.is_enabled(p.index) then p.game_view_settings.update_entity_selection = false end
   end
end

return mod
