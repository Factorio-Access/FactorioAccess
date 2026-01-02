--[[
Walking module - handles cursor announcements during player movement.

When cursor is anchored:
- Updates cursor to one tile ahead of player on tile border crossing
- Announces entities and unwalkable tiles

When cursor is not anchored:
- Checks for entities/obstacles at cursor position
- Announces entities and unwalkable tiles

Uses movement history to detect:
- Tile border crossings (comparing floored positions)
- Discontinuities (teleports, respawns via generation tracking)
]]

local StorageManager = require("scripts.storage-manager")
local MovementHistory = require("scripts.movement-history")
local Viewpoint = require("scripts.viewpoint")
local FaUtils = require("scripts.fa-utils")
local EntitySelection = require("scripts.entity-selection")
local Graphics = require("scripts.graphics")
local Sounds = require("scripts.ui.sounds")
local TileReader = require("scripts.tile-reader")
local Combat = require("scripts.combat")
local KruiseKontrol = require("scripts.kruise-kontrol-wrapper")
local VanillaMode = require("scripts.vanilla-mode")

local mod = {}

---@class fa.Walking.State
---@field last_generation number? Last movement history generation we processed

local walking_storage = StorageManager.declare_storage_module("walking", {
   last_generation = nil,
})

---Process walking announcements for a player
---@param pindex number
function mod.process_walking_announcements(pindex)
   local player = game.get_player(pindex)
   if not player or not player.character then return end

   local reader = MovementHistory.get_movement_history_reader(pindex)
   local current_generation = reader:get_generation()
   local vp = Viewpoint.get_viewpoint(pindex)
   local state = walking_storage[pindex]

   -- Detect discontinuities (teleport, respawn, surface change, etc.)
   local had_discontinuity = false
   if state.last_generation ~= current_generation then
      state.last_generation = current_generation
      had_discontinuity = true
   end

   -- Detect tile border crossing
   local current = reader:get(0)
   local previous = reader:get(1)
   local crossed_tile = false

   if not previous then
      -- First movement entry, char teleported or started walking.
      had_discontinuity = true
   elseif current then
      local current_tile = { x = math.floor(current.position.x), y = math.floor(current.position.y) }
      local previous_tile = { x = math.floor(previous.position.x), y = math.floor(previous.position.y) }
      if current_tile.x ~= previous_tile.x or current_tile.y ~= previous_tile.y then crossed_tile = true end
   end

   -- Only process if we crossed a tile. Do not process for discontinuity! Teleport isn't walking.
   if had_discontinuity or not crossed_tile then return end

   -- In combat mode, treat cursor as unanchored (don't update cursor position while walking)
   if vp:get_cursor_anchored() and not Combat.is_combat_mode(pindex) then
      -- ANCHORED MODE: Update cursor ahead and announce if notable
      local char_pos = player.character.position
      local direction = current and current.direction or defines.direction.north
      vp:set_cursor_pos(FaUtils.to_neighboring_tile(char_pos, direction))

      -- Only announce if there's an entity or the tile is unwalkable
      local ent = EntitySelection.get_first_ent_at_tile(pindex)
      if
         not VanillaMode.is_enabled(pindex)
         and (
            (ent ~= nil and ent.valid)
            or (player.surface.can_place_entity({ name = "character", position = vp:get_cursor_pos() }) == false)
         )
      then
         Graphics.draw_cursor_highlight(pindex, ent, nil)
         if player.driving then return end

         -- In combat mode or during KK, don't set selected entity
         local skip_selection = Combat.is_combat_mode(pindex) or KruiseKontrol.is_active(pindex)

         if
            ent ~= nil
            and ent.valid
            and (
               player.character == nil or (player.character ~= nil and player.character.unit_number ~= ent.unit_number)
            )
         then
            Graphics.draw_cursor_highlight(pindex, ent, nil)
            if not skip_selection then player.selected = ent end
            Sounds.play_close_inventory(pindex)
         else
            Graphics.draw_cursor_highlight(pindex, nil, nil)
            if not skip_selection then player.selected = nil end
         end

         TileReader.read_tile(pindex)
      else
         Graphics.draw_cursor_highlight(pindex, nil, nil)
         if not Combat.is_combat_mode(pindex) and not KruiseKontrol.is_active(pindex) then player.selected = nil end
      end
   else
      -- NON-ANCHORED MODE: Don't announce while walking
      -- Cursor stays in place, so no need to read tile on every player movement
   end
end

return mod
