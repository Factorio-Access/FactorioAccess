--Here: Fast travel, structure travel, etc.
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Mouse = require("scripts.mouse")
local Teleport = require("scripts.teleport")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")
local EntitySelection = require("scripts.entity-selection")
local Speech = require("scripts.speech")
local StorageManager = require("scripts.storage-manager")
local UID = require("scripts.uid")

local mod = {}
local TRAVEL_MENU_LENGTH = 8

function mod.fast_travel_menu_open(pindex)
   local router = UiRouter.get_router(pindex)

   local p = game.get_player(pindex)
   if p.ticks_to_respawn ~= nil then return end
   game.get_player(pindex).selected = nil

   -- Use the new UI system
   router:open_ui(UiRouter.UI_NAMES.TRAVEL)
end

---@class fa.travel.TravelPoint
---@field id number Unique ID from uid.lua
---@field label string User-provided name
---@field position fa.Point Teleport position
---@field description string? Optional description

---@class fa.travel.TravelStorage
---@field points fa.travel.TravelPoint[]

---@type table<number, fa.travel.TravelStorage>
local travel_storage = StorageManager.declare_storage_module("fast_travel", {
   points = {},
})

---@class fa.FastTravelController
---@field pindex number
local FastTravelController = {}
local FastTravelController_meta = { __index = FastTravelController }

---Get number of travel points
---@return number
function FastTravelController:get_num_travel_points()
   return #travel_storage[self.pindex].points
end

---Get travel point by index (1-based, for iteration)
---@param index number
---@return fa.travel.TravelPoint?
function FastTravelController:get_point_by_index(index)
   return travel_storage[self.pindex].points[index]
end

---Get travel point by ID
---@param id number
---@return fa.travel.TravelPoint?
function FastTravelController:get_point_by_id(id)
   for _, point in ipairs(travel_storage[self.pindex].points) do
      if point.id == id then return point end
   end
   return nil
end

---Teleport to a travel point
---@param id number
---@return boolean success
function FastTravelController:travel_to_point(id)
   local point = self:get_point_by_id(id)
   if not point then return false end

   local p = game.get_player(self.pindex)
   if not p then return false end

   if p.vehicle then
      Speech.speak(self.pindex, { "fa.travel-cannot-teleport-vehicle" })
      return false
   end

   local vp = Viewpoint.get_viewpoint(self.pindex)
   local success = Teleport.teleport_to_closest(self.pindex, point.position, false, false)

   if success and vp:get_cursor_anchored() then
      vp:set_cursor_pos(table.deepcopy(point.position))
   else
      vp:set_cursor_pos(p.position)
   end

   Graphics.sync_build_cursor_graphics(self.pindex)

   if not EntitySelection.reset_entity_index(self.pindex) then
      Speech.speak(self.pindex, { "fa.travel-tile-out-of-range" })
      return false
   end

   -- Update cursor highlight
   local ent = p.selected
   if ent and ent.valid then
      Graphics.draw_cursor_highlight(self.pindex, ent, nil)
   else
      Graphics.draw_cursor_highlight(self.pindex, nil, nil)
   end

   return success
end

---Delete a travel point
---@param id number
---@return boolean success
function FastTravelController:delete_point(id)
   local points = travel_storage[self.pindex].points
   for i, point in ipairs(points) do
      if point.id == id then
         table.remove(points, i)
         return true
      end
   end
   return false
end

---Relocate a travel point to given position
---@param id number
---@param position fa.Point
---@return boolean success
function FastTravelController:relocate_point(id, position)
   local point = self:get_point_by_id(id)
   if not point then return false end

   point.position = FaUtils.center_of_tile(position)
   return true
end

---Create a new travel point
---@param label string
---@param position fa.Point
---@param description string?
---@return number id The ID of the created point
function FastTravelController:create_point(label, position, description)
   local id = UID.uid()
   local point = {
      id = id,
      label = label,
      position = FaUtils.center_of_tile(position),
      description = description or "",
   }
   table.insert(travel_storage[self.pindex].points, point)

   -- Sort by label
   table.sort(travel_storage[self.pindex].points, function(a, b)
      return a.label < b.label
   end)

   return id
end

---Update travel point label
---@param id number
---@param label string
---@return boolean success
function FastTravelController:update_point_label(id, label)
   local point = self:get_point_by_id(id)
   if not point then return false end

   point.label = label

   -- Resort by label
   table.sort(travel_storage[self.pindex].points, function(a, b)
      return a.label < b.label
   end)

   return true
end

---Update travel point description
---@param id number
---@param description string
---@return boolean success
function FastTravelController:update_point_description(id, description)
   local point = self:get_point_by_id(id)
   if not point then return false end

   point.description = description
   return true
end

-- Controller cache
local controller_cache = {}

---Get or create FastTravelController for player
---@param pindex number
---@return fa.FastTravelController
function mod.get_controller(pindex)
   local cached = controller_cache[pindex]
   if not cached then
      cached = setmetatable({ pindex = pindex }, FastTravelController_meta)
      controller_cache[pindex] = cached
   end
   return cached
end

return mod
