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

--Reads the selected fast travel menu slot
function mod.read_fast_travel_slot(pindex)
   if #storage.players[pindex].travel == 0 then
      Speech.speak(pindex, { "fa.travel-move-right-create" })
   else
      local vp = Viewpoint.get_viewpoint(pindex)
      local entry = storage.players[pindex].travel[storage.players[pindex].travel.index.y]
      Speech.speak(
         pindex,
         entry.name
            .. " at "
            .. math.floor(entry.position.x)
            .. ", "
            .. math.floor(entry.position.y)
            .. ", cursor moved."
      )
      vp:set_cursor_pos(FaUtils.center_of_tile(entry.position))
      Graphics.draw_cursor_highlight(pindex, nil, "train-visualization")
   end
end

function mod.fast_travel_menu_click(pindex)
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   if #storage.players[pindex].travel == 0 and storage.players[pindex].travel.index.x < TRAVEL_MENU_LENGTH then
      Speech.speak(pindex, { "fa.travel-move-right-create-new" })
   elseif
      storage.players[pindex].travel.index.y == 0 and storage.players[pindex].travel.index.x < TRAVEL_MENU_LENGTH
   then
      Speech.speak(
         pindex,
         "Navigate up and down to select a fast travel point, then press LEFT BRACKET to get there quickly."
      )
   elseif storage.players[pindex].travel.index.x == 1 then --Travel
      if p.vehicle then
         Speech.speak(pindex, { "fa.travel-cannot-teleport-vehicle" })
         return
      end
      local success = Teleport.teleport_to_closest(
         pindex,
         storage.players[pindex].travel[storage.players[pindex].travel.index.y].position,
         false,
         false
      )
      if success and vp:get_cursor_enabled() then
         vp:set_cursor_pos(
            table.deepcopy(storage.players[pindex].travel[storage.players[pindex].travel.index.y].position)
         )
      else
         vp:set_cursor_pos(
            FaUtils.offset_position_legacy(
               storage.players[pindex].position,
               storage.players[pindex].player_direction,
               1
            )
         )
      end
      Graphics.sync_build_cursor_graphics(pindex)
      game.get_player(pindex).opened = nil

      if not EntitySelection.refresh_player_tile(pindex) then
         Speech.speak(pindex, { "fa.travel-tile-out-of-range" })
         return
      end

      --Update cursor highlight
      local ent = game.get_player(pindex).selected
      if ent and ent.valid then
         Graphics.draw_cursor_highlight(pindex, ent, nil)
      else
         Graphics.draw_cursor_highlight(pindex, nil, nil)
      end
   elseif storage.players[pindex].travel.index.x == 2 then --Read description
      local desc = storage.players[pindex].travel[storage.players[pindex].travel.index.y].description
      if desc == nil or desc == "" then
         desc = "No description"
         storage.players[pindex].travel[storage.players[pindex].travel.index.y].description = desc
      end
      Speech.speak(pindex, desc)
   elseif storage.players[pindex].travel.index.x == 3 then --Rename
      Speech.speak(
         pindex,
         "Travel point renaming is temporarily unavailable while the text input system is being redesigned."
      )
   elseif storage.players[pindex].travel.index.x == 4 then --Rewrite description
      Speech.speak(
         pindex,
         "Travel point description editing is temporarily unavailable while the text input system is being redesigned."
      )
   elseif storage.players[pindex].travel.index.x == 5 then --Relocate to current character position
      storage.players[pindex].travel[storage.players[pindex].travel.index.y].position =
         FaUtils.center_of_tile(storage.players[pindex].position)
      Speech.speak(pindex, {
         "fa.travel-relocated-point",
         storage.players[pindex].travel[storage.players[pindex].travel.index.y].name,
         tostring(math.floor(storage.players[pindex].position.x)),
         tostring(math.floor(storage.players[pindex].position.y)),
      })
      local position = storage.players[pindex].position
      vp:set_cursor_pos({ x = position.x, y = position.y })
      Graphics.draw_cursor_highlight(pindex)
   elseif storage.players[pindex].travel.index.x == 6 then --Broadcast
      --Prevent duplicating by checking if this point was last broadcasted
      local this_point = storage.players[pindex].travel[storage.players[pindex].travel.index.y]
      if
         this_point.name == storage.players[pindex].travel.last_broadcasted_name
         and this_point.description == storage.players[pindex].travel.last_broadcasted_description
         and this_point.position == storage.players[pindex].travel.last_broadcasted_position
      then
         Speech.speak(pindex, { "fa.travel-error-cancelled-broadcast" })
         return
      end
      --Broadcast it by adding a copy of it to all players in the same force (except for repeating this player)
      local players = storage.players
      for other_pindex, player in pairs(players) do
         if
            game.get_player(pindex).force.name == game.get_player(other_pindex).force.name and pindex ~= other_pindex
         then
            table.insert(players[other_pindex].travel, {
               name = this_point.name,
               position = this_point.position,
               description = this_point.description,
            })
            table.sort(players[other_pindex].travel, function(k1, k2)
               return k1.name < k2.name
            end)
         end
      end
      --Report the action and note the last broadcasted point
      Speech.speak(pindex, { "fa.travel-broadcasted-point", this_point.name })
      storage.players[pindex].travel.last_broadcasted_name = this_point.name
      storage.players[pindex].travel.last_broadcasted_description = this_point.description
      storage.players[pindex].travel.last_broadcasted_position = this_point.position
   elseif storage.players[pindex].travel.index.x == 7 then --Delete
      Speech.speak(
         pindex,
         { "fa.travel-deleted-point", storage.players[pindex].travel[storage.players[pindex].travel.index.y].name }
      )
      table.remove(storage.players[pindex].travel, storage.players[pindex].travel.index.y)
      storage.players[pindex].travel.x = 1
      storage.players[pindex].travel.index.y = storage.players[pindex].travel.index.y - 1
   elseif storage.players[pindex].travel.index.x == 8 then --Create new
      Speech.speak(
         pindex,
         "Creating new travel points is temporarily unavailable while the text input system is being redesigned."
      )
   end
end

function mod.fast_travel_menu_up(pindex)
   if storage.players[pindex].travel.index.y > 1 then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      storage.players[pindex].travel.index.y = storage.players[pindex].travel.index.y - 1
   else
      storage.players[pindex].travel.index.y = 1
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   storage.players[pindex].travel.index.x = 1
   mod.read_fast_travel_slot(pindex)
end

function mod.fast_travel_menu_down(pindex)
   if storage.players[pindex].travel.index.y < #storage.players[pindex].travel then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      storage.players[pindex].travel.index.y = storage.players[pindex].travel.index.y + 1
   else
      storage.players[pindex].travel.index.y = #storage.players[pindex].travel
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   storage.players[pindex].travel.index.x = 1
   mod.read_fast_travel_slot(pindex)
end

function mod.fast_travel_menu_right(pindex)
   if storage.players[pindex].travel.index.x < TRAVEL_MENU_LENGTH then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      storage.players[pindex].travel.index.x = storage.players[pindex].travel.index.x + 1
   else
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   if storage.players[pindex].travel.index.x == 1 then
      Speech.speak(pindex, { "fa.travel-menu-travel" })
   elseif storage.players[pindex].travel.index.x == 2 then
      Speech.speak(pindex, { "fa.travel-menu-read-description" })
   elseif storage.players[pindex].travel.index.x == 3 then
      Speech.speak(pindex, { "fa.travel-menu-rename" })
   elseif storage.players[pindex].travel.index.x == 4 then
      Speech.speak(pindex, { "fa.travel-menu-rewrite-description" })
   elseif storage.players[pindex].travel.index.x == 5 then
      Speech.speak(pindex, { "fa.travel-menu-relocate" })
   elseif storage.players[pindex].travel.index.x == 6 then
      Speech.speak(pindex, { "fa.travel-menu-broadcast" })
   elseif storage.players[pindex].travel.index.x == 7 then
      Speech.speak(pindex, { "fa.travel-menu-delete" })
   elseif storage.players[pindex].travel.index.x == 8 then
      Speech.speak(pindex, { "fa.travel-menu-create-new" })
   end
end

function mod.fast_travel_menu_left(pindex)
   if storage.players[pindex].travel.index.x > 1 then
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
      storage.players[pindex].travel.index.x = storage.players[pindex].travel.index.x - 1
   else
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   if storage.players[pindex].travel.index.x == 1 then
      Speech.speak(pindex, { "fa.travel-menu-travel" })
   elseif storage.players[pindex].travel.index.x == 2 then
      Speech.speak(pindex, { "fa.travel-menu-read-description" })
   elseif storage.players[pindex].travel.index.x == 3 then
      Speech.speak(pindex, { "fa.travel-menu-rename" })
   elseif storage.players[pindex].travel.index.x == 4 then
      Speech.speak(pindex, { "fa.travel-menu-rewrite-description" })
   elseif storage.players[pindex].travel.index.x == 5 then
      Speech.speak(pindex, { "fa.travel-menu-relocate" })
   elseif storage.players[pindex].travel.index.x == 6 then
      Speech.speak(pindex, { "fa.travel-menu-broadcast" })
   elseif storage.players[pindex].travel.index.x == 7 then
      Speech.speak(pindex, { "fa.travel-menu-delete" })
   elseif storage.players[pindex].travel.index.x == 8 then
      Speech.speak(pindex, { "fa.travel-menu-create-new" })
   end
end

function mod.fast_travel_menu_close(pindex)
   local router = UiRouter.get_router(pindex)

   if game.get_player(pindex).gui.screen["travel"] then game.get_player(pindex).gui.screen["travel"].destroy() end
   router:close_ui()
end

-- FastTravelController using new storage format with UIDs

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

   if success and vp:get_cursor_enabled() then
      vp:set_cursor_pos(table.deepcopy(point.position))
   else
      vp:set_cursor_pos(
         FaUtils.offset_position_legacy(
            storage.players[self.pindex].position,
            storage.players[self.pindex].player_direction,
            1
         )
      )
   end

   Graphics.sync_build_cursor_graphics(self.pindex)

   if not EntitySelection.refresh_player_tile(self.pindex) then
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
