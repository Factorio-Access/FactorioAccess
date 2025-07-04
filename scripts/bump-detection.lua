--[[
Bump Detection System
Provides audio feedback when the player collides with obstacles while walking.
Detects different types of collisions (entities, cliffs, tiles) and plays appropriate sounds.
]]

local StorageManager = require("scripts.storage-manager")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")
local sounds = require("scripts.ui.sounds")
local directions = defines.direction

local mod = {}

---@class fa.BumpDetection.BumpState
---@field last_bump_tick number
---@field last_dir_key_tick number
---@field last_dir_key_1st defines.direction?
---@field last_dir_key_2nd defines.direction?
---@field last_pos_1 MapPosition?
---@field last_pos_2 MapPosition?
---@field last_pos_3 MapPosition?
---@field last_pos_4 MapPosition?
---@field last_dir_1 defines.direction?
---@field last_dir_2 defines.direction?
---@field filled boolean

---@type table<number, fa.BumpDetection.BumpState>
local bump_storage = StorageManager.declare_storage_module("bump_detection", {
   last_bump_tick = 1,
   last_dir_key_tick = 1,
   last_dir_key_1st = nil,
   last_dir_key_2nd = nil,
   last_pos_1 = nil,
   last_pos_2 = nil,
   last_pos_3 = nil,
   last_pos_4 = nil,
   last_dir_2 = nil,
   last_dir_1 = nil,
   filled = false,
})

---Resets bump detection statistics for a player
---@param pindex number
function mod.reset_bump_stats(pindex)
   bump_storage[pindex] = {
      last_bump_tick = 1,
      last_dir_key_tick = 1,
      last_dir_key_1st = nil,
      last_dir_key_2nd = nil,
      last_pos_1 = nil,
      last_pos_2 = nil,
      last_pos_3 = nil,
      last_pos_4 = nil,
      last_dir_2 = nil,
      last_dir_1 = nil,
      filled = false,
   }
end

---Updates the last direction key pressed
---@param pindex number
---@param direction defines.direction
---@param tick number
function mod.update_last_direction_key(pindex, direction, tick)
   local bump = bump_storage[pindex]
   bump.last_dir_key_2nd = bump.last_dir_key_1st
   bump.last_dir_key_1st = direction
   bump.last_dir_key_tick = tick
end

---Checks if an entity type is walkable
---@param entity_type string
---@return boolean
local function is_walkable_entity_type(entity_type)
   return entity_type == "resource"
      or entity_type == "transport-belt"
      or entity_type == "item-entity"
      or entity_type == "entity-ghost"
      or entity_type == "character"
end

---Checks and plays bump alert sounds when collision is detected
---@param pindex number
---@param this_tick number
function mod.check_and_play_bump_alert_sound(pindex, this_tick)
   local router = UiRouter.get_router(pindex)

   if not game.get_player(pindex) or router:is_ui_open(UiRouter.UI_NAMES.PROMPT) then return end
   local p = game.get_player(pindex)
   if p == nil or p.character == nil then return end
   local face_dir = p.character.direction

   --Initialize
   local bump = bump_storage[pindex]
   bump.filled = false

   --Return and reset if in a menu or a vehicle
   if router:is_ui_open() or p.vehicle ~= nil then
      bump.last_pos_4 = nil
      bump.last_pos_3 = nil
      bump.last_pos_2 = nil
      bump.last_pos_1 = nil
      bump.last_dir_2 = nil
      bump.last_dir_1 = nil
      return
   end

   --Update Positions and directions since last check
   bump.last_pos_4 = bump.last_pos_3
   bump.last_pos_3 = bump.last_pos_2
   bump.last_pos_2 = bump.last_pos_1
   bump.last_pos_1 = p.position

   bump.last_dir_2 = bump.last_dir_1
   bump.last_dir_1 = face_dir

   --Return if not walking
   if p.walking_state.walking == false then return end

   --Return if not enough positions filled (trying 4 for now)
   if bump.last_pos_4 == nil then
      bump.filled = false
      return
   else
      bump.filled = true
   end

   --Return if bump sounded recently
   if this_tick - bump.last_bump_tick < 15 then return end

   --Return if player changed direction recently
   if this_tick - bump.last_dir_key_tick < 30 and bump.last_dir_key_1st ~= bump.last_dir_key_2nd then return end

   --Return if current running direction is not equal to the last (e.g. letting go of a key)
   if face_dir ~= bump.last_dir_key_1st then return end

   --Return if no last key info filled (rare)
   if bump.last_dir_key_1st == nil then return end

   --Return if no last dir info filled (rare)
   if bump.last_dir_2 == nil then return end

   --Return if not walking in a cardinal direction
   if
      face_dir ~= directions.north
      and face_dir ~= directions.east
      and face_dir ~= directions.south
      and face_dir ~= directions.west
   then
      return
   end

   --Return if last dir is different
   if bump.last_dir_1 ~= bump.last_dir_2 then return end

   --Prepare analysis data
   local TOLERANCE = 0.05
   local was_going_straight = false

   local diff_x1 = bump.last_pos_1.x - bump.last_pos_2.x
   local diff_x2 = bump.last_pos_2.x - bump.last_pos_3.x
   local diff_x3 = bump.last_pos_3.x - bump.last_pos_4.x

   local diff_y1 = bump.last_pos_1.y - bump.last_pos_2.y
   local diff_y2 = bump.last_pos_2.y - bump.last_pos_3.y
   local diff_y3 = bump.last_pos_3.y - bump.last_pos_4.y

   --Check if earlier movement has been straight
   if bump.last_dir_key_1st == bump.last_dir_key_2nd then
      was_going_straight = true
   else
      if face_dir == directions.north or face_dir == directions.south then
         if math.abs(diff_x2) < TOLERANCE and math.abs(diff_x3) < TOLERANCE then was_going_straight = true end
      elseif face_dir == directions.east or face_dir == directions.west then
         if math.abs(diff_y2) < TOLERANCE and math.abs(diff_y3) < TOLERANCE then was_going_straight = true end
      end
   end

   --Return if was not going straight earlier (like was running diagonally, as confirmed by last positions)
   if not was_going_straight then return end

   --Check if latest movement has been straight
   local is_going_straight = false
   if face_dir == directions.north or face_dir == directions.south then
      if math.abs(diff_x1) < TOLERANCE then is_going_straight = true end
   elseif face_dir == directions.east or face_dir == directions.west then
      if math.abs(diff_y1) < TOLERANCE then is_going_straight = true end
   end

   --Return if going straight now
   if is_going_straight then return end

   --Now we can confirm that there is a sudden lateral movement
   bump.last_bump_tick = this_tick

   --Check if there is an ent in front of the player
   local found_ent = p.selected
   local ent = nil
   if found_ent and found_ent.valid and not is_walkable_entity_type(found_ent.type) then ent = found_ent end

   if ent == nil or ent.valid == false then
      local ents = p.surface.find_entities_filtered({ position = p.position, radius = 0.75 })
      for i, found_ent in ipairs(ents) do
         --Ignore ents you can walk through
         if not is_walkable_entity_type(found_ent.type) then ent = found_ent end
      end
   end

   local bump_was_ent = (ent ~= nil and ent.valid)

   if bump_was_ent then
      if ent.type == "cliff" then
         sounds.play_player_bump_slide(pindex)
      else
         sounds.play_player_bump_trip(pindex)
      end
      return
   end

   --Check if there is a cliff nearby (the weird size can make it affect the player without being read)
   local ents = p.surface.find_entities_filtered({ position = p.position, radius = 2, type = "cliff" })
   local bump_was_cliff = (#ents > 0)
   if bump_was_cliff then
      sounds.play_player_bump_slide(pindex)
      return
   end

   --Check if there is a tile that was bumped into
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local tile = p.surface.get_tile(cursor_pos.x, cursor_pos.y)
   local bump_was_tile = (tile ~= nil and tile.valid and tile.collides_with("player"))

   if bump_was_tile then
      sounds.play_player_bump_slide(pindex)
      return
   end

   --The bump was something else, probably missed it...
   return
end

---If walking but recently position has been unchanged, play alert
---@param pindex number
---@param this_tick number
function mod.check_and_play_stuck_alert_sound(pindex, this_tick)
   local router = UiRouter.get_router(pindex)

   if not game.get_player(pindex) or router:is_ui_open(UiRouter.UI_NAMES.PROMPT) then return end

   local p = game.get_player(pindex)

   --Initialize
   local bump = bump_storage[pindex]

   --Return if in a menu or a vehicle
   if router:is_ui_open() or p.vehicle ~= nil then return end

   --Return if not walking
   if p.walking_state.walking == false then return end

   --Return if not enough positions filled (trying 3 for now)
   if bump.last_pos_3 == nil then return end

   --Return if no last dir info filled (rare)
   if bump.last_dir_2 == nil then return end

   --Prepare analysis data
   local diff_x1 = bump.last_pos_1.x - bump.last_pos_2.x
   local diff_x2 = bump.last_pos_2.x - bump.last_pos_3.x

   local diff_y1 = bump.last_pos_1.y - bump.last_pos_2.y
   local diff_y2 = bump.last_pos_2.y - bump.last_pos_3.y

   --Check if movement has been stuck
   if diff_x1 == 0 and diff_y1 == 0 and diff_x2 == 0 and diff_y2 == 0 then sounds.play_player_bump_stuck(pindex) end
end

return mod
