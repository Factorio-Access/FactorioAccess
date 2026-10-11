--[[
The space map, from the mod menu with space travel: every space location and whether the force has unlocked it.
Clicking a location lists its routes, the space connections to and from it.
]]

local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local Localising = require("scripts.localising")

local mod = {}

---@param a LuaPrototypeBase
---@param b LuaPrototypeBase
local function by_order(a, b)
   return a.order < b.order
end

---@param ctx fa.ui.graph.Ctx
local function build_space_map(ctx)
   local builder = Menu.MenuBuilder.new()
   local force = game.get_player(ctx.pindex).force --[[@as LuaForce]]

   local locations = {}
   for _, location in pairs(prototypes.space_location) do
      if not location.hidden then table.insert(locations, location) end
   end
   table.sort(locations, by_order)

   for _, location in ipairs(locations) do
      local name = location.name
      builder:add_clickable(name, function(label_ctx)
         local key = force.is_space_location_unlocked(name) and "fa.space-map-unlocked" or "fa.space-map-locked"
         label_ctx.message:fragment({ key, Localising.get_localised_name_with_fallback(location) })
      end, {
         on_click = function(click_ctx)
            click_ctx.controller:open_child_ui(UiRouter.UI_NAMES.SPACE_ROUTES, { location = name })
         end,
      })
   end

   return builder:build()
end

---@param ctx fa.ui.graph.Ctx
local function build_space_routes(ctx)
   local builder = Menu.MenuBuilder.new()
   local here = ctx.global_parameters.location

   ---@type { connection: LuaSpaceConnectionPrototype, other: LuaSpaceLocationPrototype }[]
   local routes = {}
   for _, connection in pairs(prototypes.space_connection) do
      local other
      if connection.from.name == here then
         other = connection.to
      elseif connection.to.name == here then
         other = connection.from
      end
      if other and not connection.hidden and not other.hidden then
         table.insert(routes, { connection = connection, other = other })
      end
   end
   table.sort(routes, function(a, b)
      if a.connection.length ~= b.connection.length then return a.connection.length < b.connection.length end
      return a.other.order < b.other.order
   end)

   if #routes == 0 then
      builder:add_label("none", { "fa.space-map-no-routes" })
      return builder:build()
   end

   local force = game.get_player(ctx.pindex).force --[[@as LuaForce]]
   for _, route in ipairs(routes) do
      local key = force.is_space_location_unlocked(route.other.name) and "fa.space-map-route"
         or "fa.space-map-route-locked"
      builder:add_label(route.connection.name, {
         key,
         Localising.get_localised_name_with_fallback(route.other),
         tostring(route.connection.length),
      })
   end

   return builder:build()
end

local space_map_tab = KeyGraph.declare_graph({
   name = "space_map",
   render_callback = build_space_map,
   title = { "fa.space-map-title" },
})

local space_routes_tab = KeyGraph.declare_graph({
   name = "space_routes",
   render_callback = build_space_routes,
   title = { "fa.space-map-routes-title" },
})

mod.space_map = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.SPACE_MAP,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "space_map",
            tabs = { space_map_tab },
         },
      }
   end,
})

mod.space_routes = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.SPACE_ROUTES,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "space_routes",
            tabs = { space_routes_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.space_map)
UiRouter.register_ui(mod.space_routes)

return mod
