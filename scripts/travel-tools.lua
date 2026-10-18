--[[
Fast travel points: per player, each on a surface and in at most one category.

Points are kept apart from their order. `points` holds them by ID; `order` holds, per surface, the IDs in the order
the player arranged them (new points go in by name, dragging moves them); `categories` holds category names by ID, and
`category_order` their IDs in the order the player arranged them (a new category goes last). A category exists while a
point is in it. A surface's points go with the surface (on_pre_surface_deleted), so a stored surface index never
outlives its surface and can safely be reused by the game.

The storage format changed in migrations/2026-10-13-fast-travel-surfaces-and-categories.lua and
migrations/2026-10-17-fast-travel-category-order.lua.
]]
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Localising = require("scripts.localising")
local RemoteView = require("scripts.remote-view")
local SettingDecls = require("scripts.settings-decls")
local Speech = require("scripts.speech")
local StorageManager = require("scripts.storage-manager")
local Teleport = require("scripts.teleport")
local UID = require("scripts.uid")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---@class fa.travel.TravelPoint
---@field id integer
---@field label string
---@field description string
---@field surface_index integer
---@field position fa.Point
---@field category integer? A key of categories; nil is uncategorized

---@class fa.travel.TravelStorage
---@field points table<integer, fa.travel.TravelPoint>
---@field categories table<integer, string>
---@field category_order integer[] Category IDs
---@field order table<integer, integer[]> Surface index to point IDs

---@type table<integer, fa.travel.TravelStorage>
local travel_storage = StorageManager.declare_storage_module("fast_travel", {
   points = {},
   categories = {},
   category_order = {},
   order = {},
})

---Which points: every one, those without a category, or one category's
---@alias fa.travel.Filter "all"|"uncategorized"|integer

-- The base game's planets, in the order the game lists them; other surfaces follow by name
local BASE_PLANETS = { nauvis = 1, vulcanus = 2, gleba = 3, fulgora = 4, aquilo = 5 }

function mod.fast_travel_menu_open(pindex)
   local p = game.get_player(pindex)
   if p.ticks_to_respawn ~= nil then return end
   p.selected = nil
   UiRouter.get_router(pindex):open_ui(UiRouter.UI_NAMES.TRAVEL)
end

---@param pindex integer
---@return boolean
local function sorted_by_name(pindex)
   return settings.get_player_settings(pindex)[SettingDecls.SETTING_NAMES.FAST_TRAVEL_SORT_BY_NAME].value --[[@as boolean]]
end

---@param state fa.travel.TravelStorage
local function forget_empty_categories(state)
   local used = {}
   for _, point in pairs(state.points) do
      if point.category then used[point.category] = true end
   end
   for id in pairs(state.categories) do
      if not used[id] then state.categories[id] = nil end
   end
   for i = #state.category_order, 1, -1 do
      if not state.categories[state.category_order[i]] then table.remove(state.category_order, i) end
   end
end

---Move `id` to just before (direction -1) or after (1) `neighbour` in `ids`.
---@param ids integer[]
---@param id integer
---@param neighbour integer
---@param direction 1|-1
local function move_next_to(ids, id, neighbour, direction)
   for i, other in ipairs(ids) do
      if other == id then
         table.remove(ids, i)
         break
      end
   end
   for i, other in ipairs(ids) do
      if other == neighbour then
         table.insert(ids, direction == -1 and i or i + 1, id)
         return
      end
   end
   error("the neighbour is in the same list")
end

---Where a point named `label` goes: the first place between a name before it and a name after it.
---@param state fa.travel.TravelStorage
---@param ids integer[]
---@param label string
---@return integer
local function insertion_index(state, ids, label)
   for i = 1, #ids + 1 do
      local before = ids[i - 1] and state.points[ids[i - 1]].label
      local after = ids[i] and state.points[ids[i]].label
      if (not before or before < label) and (not after or label < after) then return i end
   end
   return #ids + 1
end

---@param state fa.travel.TravelStorage
---@param point fa.travel.TravelPoint
local function insert_by_name(state, point)
   local ids = state.order[point.surface_index] or {}
   state.order[point.surface_index] = ids
   table.insert(ids, insertion_index(state, ids, point.label), point.id)
end

---@param state fa.travel.TravelStorage
---@param point fa.travel.TravelPoint
local function remove_from_order(state, point)
   local ids = state.order[point.surface_index]
   for i, id in ipairs(ids) do
      if id == point.id then
         table.remove(ids, i)
         break
      end
   end
   if #ids == 0 then state.order[point.surface_index] = nil end
end

---@param pindex integer
---@param id integer
---@return fa.travel.TravelPoint
function mod.get_point(pindex, id)
   return travel_storage[pindex].points[id]
end

---@param pindex integer
---@param id integer?
---@return string?
function mod.category_name(pindex, id)
   return id and travel_storage[pindex].categories[id]
end

---@param point fa.travel.TravelPoint
---@param filter fa.travel.Filter
---@return boolean
local function passes(point, filter)
   if filter == "all" then return true end
   if filter == "uncategorized" then return point.category == nil end
   return point.category == filter
end

---A surface's points that pass the filter, in the player's order (or by name, with the legacy setting).
---@param pindex integer
---@param surface_index integer
---@param filter fa.travel.Filter
---@return fa.travel.TravelPoint[]
function mod.points(pindex, surface_index, filter)
   local state = travel_storage[pindex]
   local out = {}
   for _, id in ipairs(state.order[surface_index] or {}) do
      local point = state.points[id]
      if passes(point, filter) then table.insert(out, point) end
   end
   if sorted_by_name(pindex) then table.sort(out, function(a, b)
      return a.label < b.label
   end) end
   return out
end

---Every category's ID in the player's order (or by name, with the legacy setting).
---@param pindex integer
---@return integer[]
local function ordered_categories(pindex)
   local state = travel_storage[pindex]
   local ids = {}
   for _, id in ipairs(state.category_order) do
      table.insert(ids, id)
   end
   if sorted_by_name(pindex) then
      table.sort(ids, function(a, b)
         return state.categories[a] < state.categories[b]
      end)
   end
   return ids
end

---The categories with points on a surface, in the player's order.
---@param pindex integer
---@param surface_index integer
---@return { id: integer, name: string }[]
function mod.categories_on(pindex, surface_index)
   local state = travel_storage[pindex]
   local used, out = {}, {}
   for _, id in ipairs(state.order[surface_index] or {}) do
      local category = state.points[id].category
      if category then used[category] = true end
   end
   for _, id in ipairs(ordered_categories(pindex)) do
      if used[id] then table.insert(out, { id = id, name = state.categories[id] }) end
   end
   return out
end

---Every category's name, in the player's order, for choosing one.
---@param pindex integer
---@return string[]
function mod.all_category_names(pindex)
   local state = travel_storage[pindex]
   local out = {}
   for _, id in ipairs(ordered_categories(pindex)) do
      table.insert(out, state.categories[id])
   end
   return out
end

---Swap a category with its neighbour among those on a surface (the menu's tabs), in the player's order.
---@param pindex integer
---@param surface_index integer
---@param id integer
---@param direction 1|-1
---@return integer? position Its new place among the surface's categories; nil at the edge
---@return integer count How many categories the surface has
function mod.move_category(pindex, surface_index, id, direction)
   local visible = mod.categories_on(pindex, surface_index)
   for i, c in ipairs(visible) do
      if c.id == id then
         local neighbour = visible[i + direction]
         if not neighbour then return nil, #visible end
         move_next_to(travel_storage[pindex].category_order, id, neighbour.id, direction)
         return i + direction, #visible
      end
   end
   error("the category is on the surface")
end

---The surfaces to show, in a stable order: the base game's planets, other surfaces by name, then platforms by name.
---A surface is shown when it has points, and the player's own surface always.
---@param pindex integer
---@return LuaSurface[]
function mod.surfaces(pindex)
   local state = travel_storage[pindex]
   local current = assert(game.get_player(pindex)).surface
   local out = { current }
   for index in pairs(state.order) do
      if index ~= current.index then table.insert(out, assert(game.get_surface(index))) end
   end
   ---@param s LuaSurface
   local function key(s)
      if s.platform then return 3, s.platform.name end
      local planet = BASE_PLANETS[s.name]
      if planet then return 1, string.format("%02d", planet) end
      return 2, s.name
   end
   table.sort(out, function(a, b)
      local ga, na = key(a)
      local gb, nb = key(b)
      if ga ~= gb then return ga < gb end
      if na ~= nb then return na < nb end
      return a.index < b.index
   end)
   return out
end

---What a surface is called: its platform's name, its planet's, or its own.
---@param surface LuaSurface
---@return LocalisedString
function mod.surface_name(surface)
   if surface.platform then return surface.platform.name end
   if surface.planet then return Localising.get_localised_name_with_fallback(surface.planet.prototype) end
   return surface.localised_name or surface.name
end

---@param pindex integer
---@param label string
---@param surface_index integer
---@param position fa.Point
---@param category_name string? Put in this category, made if new
---@return integer id
function mod.create_point(pindex, label, surface_index, position, category_name)
   local state = travel_storage[pindex]
   ---@type fa.travel.TravelPoint
   local point = {
      id = UID.uid(),
      label = label,
      description = "",
      surface_index = surface_index,
      position = FaUtils.center_of_tile(position),
   }
   state.points[point.id] = point
   insert_by_name(state, point)
   if category_name then mod.set_category(pindex, point.id, category_name) end
   return point.id
end

---@param pindex integer
---@param id integer
function mod.delete_point(pindex, id)
   local state = travel_storage[pindex]
   remove_from_order(state, mod.get_point(pindex, id))
   state.points[id] = nil
   forget_empty_categories(state)
end

---@param pindex integer
---@param id integer
---@param label string
function mod.rename_point(pindex, id, label)
   mod.get_point(pindex, id).label = label
end

---@param pindex integer
---@param id integer
---@param description string
function mod.set_description(pindex, id, description)
   mod.get_point(pindex, id).description = description
end

---Move a point to a position, on another surface too (it then goes in by name among that surface's points).
---@param pindex integer
---@param id integer
---@param surface_index integer
---@param position fa.Point
function mod.relocate_point(pindex, id, surface_index, position)
   local state = travel_storage[pindex]
   local point = mod.get_point(pindex, id)
   point.position = FaUtils.center_of_tile(position)
   if point.surface_index ~= surface_index then
      remove_from_order(state, point)
      point.surface_index = surface_index
      insert_by_name(state, point)
   end
end

---Put a point in the category with this name, made if new; nil or "" for uncategorized.
---@param pindex integer
---@param id integer
---@param name string?
function mod.set_category(pindex, id, name)
   local state = travel_storage[pindex]
   local point = mod.get_point(pindex, id)
   if not name or name == "" then
      point.category = nil
   else
      ---@type integer?
      local found = nil
      for category_id, category_name in pairs(state.categories) do
         if category_name == name then found = category_id end
      end
      if not found then
         found = UID.uid()
         state.categories[found] = name
         table.insert(state.category_order, found)
      end
      point.category = found
   end
   forget_empty_categories(state)
end

---The categories a point steps through with shift+a/d: uncategorized, then its surface's occupied ones in order.
---This is the order of the menu's tabs.
---Returns the name it moved to, or nil at either end.
---@param pindex integer
---@param id integer
---@param direction 1|-1
---@return string|false|nil name The new category's name, false for uncategorized, nil when at the end
function mod.step_category(pindex, id, direction)
   local point = mod.get_point(pindex, id)
   local categories = mod.categories_on(pindex, point.surface_index)
   ---@type (integer|false)[]
   local steps = { false }
   for _, c in ipairs(categories) do
      table.insert(steps, c.id)
   end
   local at = 1
   for i, step in ipairs(steps) do
      if step == (point.category or false) then at = i end
   end
   local to = steps[at + direction]
   if to == nil then return nil end
   if to == false then
      mod.set_category(pindex, id, nil)
      return false
   end
   local name = travel_storage[pindex].categories[to]
   mod.set_category(pindex, id, name)
   return name
end

---Swap a point with its neighbour among `visible` (the tab's list) in its surface's order.
---@param pindex integer
---@param id integer
---@param direction 1|-1
---@param visible fa.travel.TravelPoint[]
---@return boolean moved False at the edge
function mod.drag_point(pindex, id, direction, visible)
   local state = travel_storage[pindex]
   local point = mod.get_point(pindex, id)
   local neighbour = nil
   for i, p in ipairs(visible) do
      if p.id == id then neighbour = visible[i + direction] end
   end
   if not neighbour then return false end
   move_next_to(state.order[point.surface_index], id, neighbour.id, direction)
   return true
end

---Go to a point: teleport on the character's surface, remote view of another.
---@param pindex integer
---@param id integer
---@return LocalisedString message
function mod.travel_to_point(pindex, id)
   local point = mod.get_point(pindex, id)
   local p = assert(game.get_player(pindex))
   local vp = Viewpoint.get_viewpoint(pindex)

   -- Back to the body first; this fails aboard a platform or a rocket, and the view moves instead
   if p.controller_type == defines.controllers.remote and point.surface_index == p.physical_surface_index then
      RemoteView.quietly(pindex, function()
         p.exit_remote_view()
      end)
   end
   if p.controller_type == defines.controllers.remote or point.surface_index ~= p.surface.index then
      local surface = assert(game.get_surface(point.surface_index))
      RemoteView.quietly(pindex, function()
         p.set_controller({ type = defines.controllers.remote, surface = surface, position = point.position })
      end)
      vp:set_cursor_pos(table.deepcopy(point.position))
      return { "fa.travel-remote-view-of", point.label, mod.surface_name(surface) }
   end

   if p.vehicle then return { "fa.travel-cannot-teleport-vehicle" } end

   local success = Teleport.teleport_to_closest(pindex, point.position, false, false)
   if success and vp:get_cursor_anchored() then
      vp:set_cursor_pos(table.deepcopy(point.position))
   else
      vp:set_cursor_pos(p.position --[[@as fa.Point]])
   end
   Graphics.sync_build_cursor_graphics(pindex)
   local ent = p.selected
   if ent and ent.valid then
      Graphics.draw_cursor_highlight(pindex, ent, nil)
   else
      Graphics.draw_cursor_highlight(pindex, nil, nil)
   end
   if not success then return { "fa.travel-failed" } end
   return { "fa.travel-teleported-to", point.label }
end

---A surface is going away: every player's points on it go with it.
---@param surface_index integer
function mod.on_pre_surface_deleted(surface_index)
   for _, player_data in pairs(storage.players or {}) do
      local state = player_data.fast_travel --[[@as fa.travel.TravelStorage?]]
      if state and state.order[surface_index] then
         for _, id in ipairs(state.order[surface_index]) do
            state.points[id] = nil
         end
         state.order[surface_index] = nil
         forget_empty_categories(state)
      end
   end
end

---Point IDs on a surface in the stored order, for tests.
---@param pindex integer
---@param surface_index integer
---@return integer[]
function mod._order(pindex, surface_index)
   return travel_storage[pindex].order[surface_index] or {}
end

return mod
