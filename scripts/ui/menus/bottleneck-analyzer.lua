--[[
The bottleneck analyzer, from the mod menu: which ingredients the force's crafting machines have been waiting for
(scripts/bottlenecks.lua samples them).

A row is an ingredient, the one keeping the most machines waiting first. Its machines are the columns: on the surface
the player views, nearest the cursor first; on other surfaces after those, nearest the surface's origin first.
Ctrl+Tab picks the time range and Tab the scope: all surfaces, the area under the cursor when the cursor is bigger
than one tile, then each surface.

The numbers are read when the analyzer opens and stay as they are until it is opened again: a statistic that changes
while being read cannot be compared with the one before it. Where a machine is, though, is said from the cursor as it
is now.
]]

local Bottlenecks = require("scripts.bottlenecks")
local CategoryRows = require("scripts.ui.category-rows")
local FaInfo = require("scripts.fa-info")
local FaUtils = require("scripts.fa-utils")
local Help = require("scripts.ui.help")
local Localising = require("scripts.localising")
local RemoteView = require("scripts.remote-view")
local StorageManager = require("scripts.storage-manager")
local TabList = require("scripts.ui.tab-list")
local TravelTools = require("scripts.travel-tools")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---@class fa.ui.bottlenecks.TimeWindow
---@field name string
---@field seconds integer
---@field title LocalisedString

---@param window fa.ui.bottlenecks.TimeWindow
---@return integer
local function window_passes(window)
   return math.floor(window.seconds * 60 / Bottlenecks.SAMPLE_TICKS)
end

---@type fa.ui.bottlenecks.TimeWindow[]
local WINDOWS = {
   { name = "30s", seconds = 30, title = { "fa.bottlenecks-window-seconds", 30 } },
   { name = "1m", seconds = 60, title = { "fa.bottlenecks-window-minute" } },
   { name = "10m", seconds = 600, title = { "fa.bottlenecks-window-minutes", 10 } },
}

---@class fa.ui.bottlenecks.Machine
---@field unit integer
---@field entity LuaEntity
---@field surface_index integer
---@field position MapPosition.struct
---@field short integer Passes it was short in
---@field sampled integer
---@field missing number Total missing over those passes
---@field under_cursor boolean
---@field on_view boolean On the surface the player viewed at the time
---@field distance number From the cursor if on_view, else from the origin

---@class fa.ui.bottlenecks.Snapshot
---@field cursor_area boolean The cursor was bigger than one tile
---@field surfaces integer[] Surfaces with a shortage in the longest window, the viewed one first
---@field passes table<string, integer?> Completed passes each window found, by window name
---@field windows table<string, table<string, fa.ui.bottlenecks.Machine[]>> By window name, then shortage key

---@type table<integer, fa.ui.bottlenecks.Snapshot>
local snapshots = StorageManager.declare_storage_module("bottleneck_analyzer", {
   cursor_area = false,
   surfaces = {},
   passes = {},
   windows = {},
})

-- Renders already built from the current snapshot, so moving around does not rebuild hundreds of machines a key.
-- Lost on load, and rebuilt the same from storage.
---@type table<integer, { snapshot: fa.ui.bottlenecks.Snapshot, renders: table<string, fa.ui.CategoryRows.Render> }>
local render_cache = {}

---@param pindex integer
local function take_snapshot(pindex)
   local player = assert(game.get_player(pindex))
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor = vp:get_cursor_pos()
   local size = vp:get_cursor_size()
   local viewed = player.surface.index
   local left, top = math.floor(cursor.x) - size, math.floor(cursor.y) - size
   local right, bottom = math.floor(cursor.x) + size + 1, math.floor(cursor.y) + size + 1

   ---@type table<integer, true>
   local surfaces_seen = {}
   ---@type fa.ui.bottlenecks.Snapshot
   local snapshot = { cursor_area = size > 0, surfaces = {}, passes = {}, windows = {} }

   -- Where each machine is, read once for all the windows it is in
   ---@type table<integer, { position: MapPosition.struct, under_cursor: boolean, on_view: boolean, distance: number }>
   local places = {}
   ---@param stat fa.bottlenecks.MachineStat
   local function locate(stat)
      local entity = stat.entity
      local position = entity.position --[[@as MapPosition.struct]]
      local on_view = stat.surface_index == viewed
      local under_cursor = false
      if size > 0 and on_view then
         local box = entity.bounding_box --[[@as BoundingBox.struct]]
         local lt, rb =
            box.left_top, --[[@as MapPosition.struct]]
            box.right_bottom --[[@as MapPosition.struct]]
         under_cursor = lt.x < right and rb.x > left and lt.y < bottom and rb.y > top
      end
      local dx, dy = position.x, position.y
      if on_view then
         dx, dy = dx - cursor.x, dy - cursor.y
      end
      return {
         position = { x = position.x, y = position.y },
         under_cursor = under_cursor,
         on_view = on_view,
         distance = dx * dx + dy * dy,
      }
   end

   for _, window in ipairs(WINDOWS) do
      local aggregated = Bottlenecks.aggregate(player.force.index --[[@as integer]], window_passes(window))
      snapshot.passes[window.name] = aggregated.passes
      local by_key = {}
      for key, stats in pairs(aggregated.shortages) do
         ---@type fa.ui.bottlenecks.Machine[]
         local machines = {}
         for _, stat in ipairs(stats) do
            local place = places[stat.unit]
            if not place then
               place = locate(stat)
               places[stat.unit] = place
            end
            table.insert(machines, {
               unit = stat.unit,
               entity = stat.entity,
               surface_index = stat.surface_index,
               position = place.position,
               short = stat.short,
               sampled = stat.sampled,
               missing = stat.missing,
               under_cursor = place.under_cursor,
               on_view = place.on_view,
               distance = place.distance,
            })
            surfaces_seen[stat.surface_index] = true
         end
         table.sort(machines, function(a, b)
            if a.on_view ~= b.on_view then return a.on_view end
            if a.distance ~= b.distance then return a.distance < b.distance end
            return a.unit < b.unit
         end)
         by_key[key] = machines
      end
      snapshot.windows[window.name] = by_key
   end

   for index in pairs(surfaces_seen) do
      table.insert(snapshot.surfaces, index)
   end
   table.sort(snapshot.surfaces, function(a, b)
      if (a == viewed) ~= (b == viewed) then return a == viewed end
      return a < b
   end)

   snapshots[pindex] = snapshot
   render_cache[pindex] = nil
end

---Whole numbers as they are, others to one decimal.
---@param n number
---@return string
local function format_number(n)
   local rounded = math.floor(n + 0.5)
   if math.abs(n - rounded) < 0.05 then return tostring(rounded) end
   return string.format("%.1f", n)
end

---@param key string
---@return LocalisedString
local function shortage_name(key)
   local kind, name, quality = Bottlenecks.parse_key(key)
   if kind == "fluid" then
      return Localising.get_localised_name_with_fallback(prototypes.fluid[name] or { name = name })
   end
   local item = Localising.get_localised_name_with_fallback(prototypes.item[name] or { name = name })
   if quality == "normal" then return item end
   local quality_prototype = prototypes.quality[quality] or { name = quality }
   return { "fa.bottlenecks-quality-item", Localising.get_localised_name_with_fallback(quality_prototype), item }
end

---Where a machine is: from the cursor on the surface the player views, else on which surface and where.
---@param pindex integer
---@param machine fa.ui.bottlenecks.Machine
---@return LocalisedString
local function location(pindex, machine)
   local position = machine.position
   if game.get_player(pindex).surface.index == machine.surface_index then
      local cursor = Viewpoint.get_viewpoint(pindex):get_cursor_pos()
      local entity = machine.entity
      if entity.valid then
         local box = entity.bounding_box --[[@as BoundingBox.struct]]
         local lt, rb =
            box.left_top, --[[@as MapPosition.struct]]
            box.right_bottom --[[@as MapPosition.struct]]
         local x, y = math.floor(cursor.x) + 0.5, math.floor(cursor.y) + 0.5
         if x > lt.x and x < rb.x and y > lt.y and y < rb.y then return { "fa.bottlenecks-at-cursor" } end
      end
      return FaUtils.dir_dist_locale(cursor, position)
   end
   local surface = game.get_surface(machine.surface_index)
   local surface_name = surface and TravelTools.surface_name(surface) or tostring(machine.surface_index)
   return { "fa.bottlenecks-on-surface", surface_name, FaUtils.format_position(position.x, position.y) }
end

---@param machine fa.ui.bottlenecks.Machine
---@param shortage string The prototype name of what it lacks
---@return fa.ui.CategoryRows.ItemVtable
local function machine_vtable(machine, shortage)
   return {
      label = function(ctx)
         local entity = machine.entity
         if not entity.valid then
            ctx.message:fragment({ "fa.bottlenecks-machine-gone" })
            return
         end
         local recipe = entity.get_recipe()
         ctx.message:fragment({
            "fa.bottlenecks-machine",
            recipe and Localising.get_localised_name_with_fallback(recipe) or { "fa.bottlenecks-no-recipe" },
            Localising.get_localised_name_with_fallback(entity),
            tostring(math.floor(100 * machine.short / machine.sampled + 0.5)),
            format_number(machine.missing / machine.short),
         })
         ctx.message:list_item_forced_comma(location(ctx.pindex, machine))
      end,
      on_click = function(ctx)
         local entity = machine.entity
         if not entity.valid then
            ctx.message:fragment({ "fa.bottlenecks-machine-gone" })
            return
         end
         local player = ctx.player
         local position = entity.position --[[@as MapPosition.struct]]
         local target = { x = math.floor(position.x) + 0.5, y = math.floor(position.y) + 0.5 }
         if entity.surface.index ~= player.surface.index then
            UiRouter.keep_open_through(ctx.pindex, function()
               RemoteView.quietly(ctx.pindex, function()
                  player.set_controller({
                     type = defines.controllers.remote,
                     surface = entity.surface,
                     position = target,
                  })
               end)
            end)
            ctx.message:fragment({ "fa.bottlenecks-viewing", TravelTools.surface_name(entity.surface) })
         else
            ctx.message:fragment({ "fa.cursor-moved" })
         end
         Viewpoint.get_viewpoint(ctx.pindex):set_cursor_pos(target)
      end,
      on_read_coords = function(ctx)
         ctx.message:fragment(location(ctx.pindex, machine))
      end,
      on_production_stats_announcement = function(ctx)
         ctx.message:fragment(
            FaInfo.selected_item_production_stats_info(ctx.pindex, shortage, game.get_surface(machine.surface_index))
         )
      end,
   }
end

---@param pindex integer
---@param window string
---@param scope "all"|"cursor"|integer A surface index for one surface
---@return fa.ui.CategoryRows.Render
local function render(pindex, window, scope)
   local snapshot = snapshots[pindex]
   local cache = render_cache[pindex]
   if not cache or cache.snapshot ~= snapshot then
      cache = { snapshot = snapshot, renders = {} }
      render_cache[pindex] = cache
   end
   local cache_key = window .. "/" .. scope
   if cache.renders[cache_key] then return cache.renders[cache_key] end

   ---@type { key: string, machines: fa.ui.bottlenecks.Machine[], waiting: number, missing: number }[]
   local rows = {}
   for key, machines in pairs(snapshot.windows[window]) do
      local kept = {}
      ---@type number, number, integer
      local waiting, missing, short = 0, 0, 0
      for _, machine in ipairs(machines) do
         if scope == "all" or (scope == "cursor" and machine.under_cursor) or machine.surface_index == scope then
            table.insert(kept, machine)
            waiting = waiting + machine.short / machine.sampled
            missing = missing + machine.missing
            short = short + machine.short
         end
      end
      if next(kept) then
         table.insert(rows, { key = key, machines = kept, waiting = waiting, missing = missing / short })
      end
   end
   table.sort(rows, function(a, b)
      if a.waiting ~= b.waiting then return a.waiting > b.waiting end
      return a.key < b.key
   end)

   local builder = CategoryRows.CategoryRowsBuilder_new()
   for _, row in ipairs(rows) do
      builder:add_category(row.key, {
         "fa.bottlenecks-row",
         shortage_name(row.key),
         format_number(row.waiting),
         #row.machines,
         format_number(row.missing),
      })
      local _, shortage = Bottlenecks.parse_key(row.key)
      for _, machine in ipairs(row.machines) do
         builder:add_item(row.key, tostring(machine.unit), machine_vtable(machine, shortage))
      end
   end
   local result = builder:build()
   if snapshot.passes[window] == 0 then
      result.empty_message = { "fa.bottlenecks-no-data" }
   else
      result.empty_message = { "fa.bottlenecks-none" }
   end
   cache.renders[cache_key] = result
   return result
end

---@param window fa.ui.bottlenecks.TimeWindow
---@param scope "all"|"cursor"|integer
---@param title LocalisedString
---@return fa.ui.TabDescriptor
local function scope_tab(window, scope, title)
   return CategoryRows.declare_category_rows({
      name = window.name .. "/" .. scope,
      title = title,
      render_callback = function(ctx)
         return render(ctx.pindex, window.name, scope)
      end,
      get_help_metadata = function()
         return { Help.message_list("bottleneck-analyzer-help") }
      end,
   })
end

---@param pindex integer
---@param window fa.ui.bottlenecks.TimeWindow
---@return LocalisedString
local function window_title(pindex, window)
   -- The router asks for the tabs before opening, so before any snapshot
   local passes = snapshots[pindex].passes[window.name]
   if not passes or passes >= window_passes(window) then return window.title end
   return { "fa.bottlenecks-window-partial", window.title, FaUtils.format_time(passes * Bottlenecks.SAMPLE_TICKS) }
end

mod.bottleneck_analyzer = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.BOTTLENECK_ANALYZER,
   resets_to_first_tab_on_open = true,
   sections_keep_tab_position = true,
   shared_state_setup = function(pindex)
      take_snapshot(pindex)
      return {}
   end,
   initial_tab = function()
      return WINDOWS[1].name .. "/all"
   end,
   tabs_callback = function(pindex)
      local snapshot = snapshots[pindex]
      ---@type fa.ui.TabstopDescriptor[]
      local tabstops = {}
      for _, window in ipairs(WINDOWS) do
         local tabs = { scope_tab(window, "all", { "fa.bottlenecks-all" }) }
         if snapshot.cursor_area then
            table.insert(tabs, scope_tab(window, "cursor", { "fa.bottlenecks-under-cursor" }))
         end
         for _, index in ipairs(snapshot.surfaces) do
            local surface = game.get_surface(index)
            if surface then table.insert(tabs, scope_tab(window, index, TravelTools.surface_name(surface))) end
         end
         table.insert(tabstops, { name = window.name, title = window_title(pindex, window), tabs = tabs })
      end
      return tabstops
   end,
})

UiRouter.register_ui(mod.bottleneck_analyzer)

return mod
