local Combat = require("scripts.combat")
local EntitySelection = require("scripts.entity-selection")
local KruiseKontrol = require("scripts.kruise-kontrol-wrapper")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---Synchronize player.selected with the entity at cursor position.
---Called every tick to ensure player.selected is always correct.
---@param pindex integer
local function sync_player_selected(pindex)
   local player = game.get_player(pindex)
   if not player or not player.connected then return end

   -- KruiseKontrol owns the selection, don't interfere
   if KruiseKontrol.is_active(pindex) then return end

   -- Combat mode holds selection to nil
   if Combat.is_combat_mode(pindex) then
      player.selected = nil
      return
   end

   -- Get the entity at cursor and set player.selected
   local ent = EntitySelection.get_first_ent_at_tile(pindex)
   if ent and ent.valid then
      -- Don't select the player's own character
      if player.character and player.character.unit_number == ent.unit_number then
         player.selected = nil
      else
         player.selected = ent
      end
   else
      player.selected = nil
   end
end

---Called every tick to keep player.selected in sync with cursor position.
function mod.on_tick()
   for _, player in pairs(game.players) do
      if player.connected then sync_player_selected(player.index) end
   end
end

return mod
