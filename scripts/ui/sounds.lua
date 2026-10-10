--[[
Wraps common sounds in a way which lets us put them in one place.  You call e.g.
`sounds.play_menu_moved(pindex)` and get whatever the menu movement sound is.

This module is not pointless because prior to it, we had one-off play calls all
over the codebase.  One had to find an example of the sound they wanted, hunt
down where it was played from, and copy/paste it.  Let's not and say we did.
]]

local Logging = require("scripts.logging")
local logger = Logging.Logger("Sounds")

local mod = {}

-- Test mode flag - when enabled, sounds are logged instead of played
local test_mode = false

---@class fa.ui.Sounds.PlayedSound
---@field pindex integer
---@field sound PlaySoundSpecification
---@field tick integer

-- Sound history for testing
---@type fa.ui.Sounds.PlayedSound[]
local sound_history = {}

-- Internal function to handle sound playing
local function play_sound_internal(pindex, sound_spec)
   if test_mode then
      -- In test mode, log the sound instead of playing it
      table.insert(sound_history, {
         pindex = pindex,
         sound = sound_spec,
         tick = game and game.tick or 0,
      })
      logger:debug("Sound played: " .. serpent.line(sound_spec))
   else
      -- Normal mode - play the sound
      local player = game.get_player(pindex)
      assert(player)
      player.play_sound(sound_spec)
   end
end

-- Enable test mode
function mod.enable_test_mode()
   test_mode = true
   sound_history = {}
end

-- Disable test mode
function mod.disable_test_mode()
   test_mode = false
   sound_history = {}
end

-- Get sound history (for testing)
---@return fa.ui.Sounds.PlayedSound[]
function mod.get_sound_history()
   return sound_history
end

-- Clear sound history
function mod.clear_sound_history()
   sound_history = {}
end

-- Call to play the sound for moving in a menu, e.g. inventory, belt analyzer,
-- pretty much all of them.
function mod.play_menu_move(pindex)
   play_sound_internal(pindex, { path = "Inventory-Move" })
end

function mod.play_menu_click(pindex)
   play_sound_internal(pindex, { path = "utility/inventory_click" })
end

function mod.play_menu_wrap(pindex)
   play_sound_internal(pindex, { path = "inventory-wrap-around" })
end

-- Reached the edge of the menu, the end or beginning of a slider, etc.
function mod.play_ui_edge(pindex)
   play_sound_internal(pindex, { path = "inventory-edge" })
end

-- Mining/interaction sounds
function mod.play_mine(pindex)
   play_sound_internal(pindex, { path = "player-mine" })
end

-- Inventory sounds
function mod.play_close_inventory(pindex)
   play_sound_internal(pindex, { path = "Close-Inventory-Sound", volume_modifier = 0.75 })
end

function mod.play_open_inventory(pindex)
   play_sound_internal(pindex, { path = "Open-Inventory-Sound" })
end

function mod.play_inventory_move(pindex)
   play_sound_internal(pindex, { path = "utility/inventory_move" })
end

-- Menu tab sound
function mod.play_change_menu_tab(pindex)
   play_sound_internal(pindex, { path = "Change-Menu-Tab-Sound" })
end

function mod.play_player_bump_stuck(pindex)
   play_sound_internal(pindex, { path = "player-bump-stuck-alert" })
end

function mod.play_player_bump_slide(pindex)
   play_sound_internal(pindex, { path = "player-bump-slide" })
end

function mod.play_player_bump_trip(pindex)
   play_sound_internal(pindex, { path = "player-bump-trip" })
end

-- Utility sounds
-- Note: play_inventory_click removed - use play_menu_click instead
-- Note: play_inventory_move removed - not used anywhere

function mod.play_cannot_build(pindex)
   play_sound_internal(pindex, { path = "utility/cannot_build" })
end

function mod.play_ui_error(pindex)
   play_sound_internal(pindex, { path = "utility/cannot_build" })
end

function mod.play_confirm(pindex)
   play_sound_internal(pindex, { path = "utility/confirm" })
end

function mod.play_picked_up_item(pindex)
   play_sound_internal(pindex, { path = "utility/picked_up_item", volume_modifier = 1 })
end

-- Mining/entity sounds
function mod.play_entity_mined(pindex, entity_type)
   -- Default to stone-furnace sound if no specific type given
   local sound_path = entity_type and ("entity-mined/" .. entity_type) or "entity-mined/stone-furnace"
   play_sound_internal(pindex, { path = sound_path })
end

-- Wire connection sounds
function mod.play_wire_disconnect(pindex)
   play_sound_internal(pindex, { path = "utility/wire_disconnect" })
end

-- Building sounds
function mod.play_building_placement(pindex, position)
   -- Special handling for positioned sounds
   local player = game.get_player(pindex)
   if position then
      player.play_sound({ path = "Close-Inventory-Sound", position = position, volume_modifier = 0.75 })
   else
      play_sound_internal(pindex, { path = "Close-Inventory-Sound", volume_modifier = 0.75 })
   end
end

-- Generic play_sound wrapper for custom sounds
function mod.play_sound(pindex, sound_spec)
   play_sound_internal(pindex, sound_spec)
end

-- Play sound at position (not player-specific)
---@param sound_spec PlaySoundSpecification
---@param position MapPosition
function mod.play_sound_at_position(sound_spec, position)
   if test_mode then
      table.insert(sound_history, {
         pindex = nil,
         sound = sound_spec,
         position = position,
         tick = game and game.tick or 0,
      })
      logger:debug("Sound played at position: " .. serpent.line(sound_spec))
   else
      local spec = table.deepcopy(sound_spec)
      spec.position = position
      game.play_sound(spec)
   end
end

return mod
