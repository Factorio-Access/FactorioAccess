---Vehicle cycling - find and cycle through vehicles near the player's character
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Localising = require("scripts.localising")
local Mouse = require("scripts.mouse")
local Speech = require("scripts.speech")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

-- Vehicle entity types to include (not train-related)
local VEHICLE_TYPES = {
   "car",
   "spider-vehicle",
}

local SEARCH_RADIUS = 100

---Get all vehicles within range of a position, sorted by distance
---@param surface LuaSurface
---@param center fa.Point
---@return LuaEntity[]
local function get_sorted_vehicles(surface, center)
   local vehicles = surface.find_entities_filtered({
      type = VEHICLE_TYPES,
      position = center,
      radius = SEARCH_RADIUS,
   })

   -- Sort by distance, tiebreak on unit_number
   table.sort(vehicles, function(a, b)
      local dist_a = FaUtils.squared_distance(a.position, center)
      local dist_b = FaUtils.squared_distance(b.position, center)
      if dist_a ~= dist_b then return dist_a < dist_b end
      return (a.unit_number or 0) < (b.unit_number or 0)
   end)

   return vehicles
end

---Find the index of an entity in a sorted vehicle list
---@param vehicles LuaEntity[]
---@param target LuaEntity?
---@return number? index 1-based index or nil if not found
local function find_vehicle_index(vehicles, target)
   if not target then return nil end
   for i, v in ipairs(vehicles) do
      if v.unit_number == target.unit_number then return i end
   end
   return nil
end

---Check if an entity is a vehicle we track
---@param entity LuaEntity?
---@return boolean
local function is_tracked_vehicle(entity)
   if not entity then return false end
   for _, vtype in ipairs(VEHICLE_TYPES) do
      if entity.type == vtype then return true end
   end
   return false
end

---Cycle to the next vehicle near the player's character
---@param pindex integer
function mod.cycle_to_next_vehicle(pindex)
   local player = game.get_player(pindex)
   local character = player.character

   if not character then
      Speech.speak(pindex, { "fa.vehicle-cycle-no-character" })
      return
   end

   local vp = Viewpoint.get_viewpoint(pindex)
   local vehicles = get_sorted_vehicles(player.surface, character.position)

   if #vehicles == 0 then
      Speech.speak(pindex, { "fa.vehicle-cycle-none-found" })
      return
   end

   -- Determine which vehicle to move to
   local target_index
   local current_selected = player.selected
   if is_tracked_vehicle(current_selected) then
      local current_index = find_vehicle_index(vehicles, current_selected)
      if current_index then
         target_index = current_index % #vehicles + 1
      else
         target_index = 1
      end
   else
      target_index = 1
   end

   local target = vehicles[target_index]
   local target_pos = { x = math.floor(target.position.x), y = math.floor(target.position.y) }

   -- Move cursor to the vehicle
   vp:set_cursor_pos(target_pos)
   Graphics.sync_build_cursor_graphics(pindex)
   Mouse.move_mouse_pointer(target_pos, pindex)

   -- Update selection
   player.selected = target

   -- Update cursor highlight
   Graphics.draw_cursor_highlight(pindex, target, nil)

   -- Announce
   local message = Speech.MessageBuilder.new()
   message:fragment(Localising.get_localised_name_with_fallback(target))
   message:list_item(FaUtils.dir_dist_locale(character.position, target.position))
   message:fragment({ "fa.vehicle-cycle-position", tostring(target_index), tostring(#vehicles) })
   Speech.speak(pindex, message:build())
end

return mod
