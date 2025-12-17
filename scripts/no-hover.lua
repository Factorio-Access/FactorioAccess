local mod = {}

function mod.on_tick()
   for _, p in pairs(game.players) do
      p.game_view_settings.update_entity_selection = false
   end
end

return mod
