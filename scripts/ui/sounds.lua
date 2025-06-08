--[[
Wraps common sounds in a way which lets us put them in one place.  You call e.g.
`sounds.play_menu_moved(pindex)` and get whatever the menu movement sound is.

This module is not pointless because prior to it, we had one-off play calls all
over the codebase.  One had to find an example of the sound they wanted, hunt
down where it was played from, and copy/paste it.  Let's not and say we did.
]]

local mod = {}

-- Test mode flag - when enabled, sounds are logged instead of played
local test_mode = false

-- Sound history for testing
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
      if _G.Logger then Logger.debug("Sounds", "Sound played: " .. serpent.line(sound_spec)) end
   else
      -- Normal mode - play the sound
      local player = game.get_player(pindex)
      if player and player.valid then player.play_sound(sound_spec) end
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

-- Close inventory sound
function mod.play_close_inventory(pindex)
   play_sound_internal(pindex, { path = "Close-Inventory-Sound", volume_modifier = 0.75 })
end

-- Scanner sounds
function mod.play_scanner_pulse(pindex)
   play_sound_internal(pindex, { path = "scanner-pulse" })
end

-- Player movement/action sounds
function mod.play_player_walk(pindex)
   play_sound_internal(pindex, { path = "player-walk" })
end

function mod.play_player_turn(pindex)
   play_sound_internal(pindex, { path = "player-turned" })
end

function mod.play_player_teleport(pindex)
   play_sound_internal(pindex, { path = "player-teleported" })
end

function mod.play_player_bump_alert(pindex)
   play_sound_internal(pindex, { path = "player-bump-alert" })
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

-- Combat sounds
function mod.play_player_damaged_character(pindex)
   play_sound_internal(pindex, { path = "player-damaged-character" })
end

function mod.play_player_damaged_shield(pindex)
   play_sound_internal(pindex, { path = "player-damaged-shield" })
end

function mod.play_aim_locked(pindex)
   play_sound_internal(pindex, { path = "player-aim-locked" })
end

-- Alert sounds
function mod.play_enemy_presence_high(pindex)
   play_sound_internal(pindex, { path = "alert-enemy-presence-high" })
end

function mod.play_enemy_presence_low(pindex)
   play_sound_internal(pindex, { path = "alert-enemy-presence-low" })
end

function mod.play_structure_damaged(pindex)
   play_sound_internal(pindex, { path = "alert-structure-damaged" })
end

-- Vehicle sounds
function mod.play_car_horn(pindex)
   play_sound_internal(pindex, { path = "car-horn" })
end

function mod.play_tank_horn(pindex)
   play_sound_internal(pindex, { path = "tank-horn" })
end

-- Train sounds
function mod.play_train_alert_high(pindex)
   play_sound_internal(pindex, { path = "train-alert-high" })
end

function mod.play_train_alert_low(pindex)
   play_sound_internal(pindex, { path = "train-alert-low" })
end

function mod.play_train_clack(pindex)
   play_sound_internal(pindex, { path = "train-clack" })
end

function mod.play_train_honk_long(pindex)
   play_sound_internal(pindex, { path = "train-honk-long" })
end

function mod.play_train_honk_short(pindex)
   play_sound_internal(pindex, { path = "train-honk-short-2x" })
end

-- Crafting sounds
function mod.play_crafting(pindex)
   play_sound_internal(pindex, { path = "player-crafting" })
end

-- Generic play_sound wrapper for custom sounds
function mod.play_sound(pindex, sound_spec)
   play_sound_internal(pindex, sound_spec)
end

return mod
