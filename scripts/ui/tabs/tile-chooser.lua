--[[
Tile chooser for selecting tile prototypes.
Used for deconstruction planner tile filters.
Simple vertical menu of tiles that have an item which places them.
]]

local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Localising = require("scripts.localising")

local mod = {}

---Build the tile menu
---@param ctx fa.ui.graph.Ctx
local function build_tile_menu(ctx)
   local builder = Menu.MenuBuilder.new()

   -- Collect placeable tiles (tiles that have an item which places them)
   local placeable_tiles = {}
   for _, item_proto in pairs(prototypes.item) do
      local result = item_proto.place_as_tile_result
      if result then placeable_tiles[result.result.name] = result.result end
   end

   -- Sort by name
   local sorted = {}
   for _, tile_proto in pairs(placeable_tiles) do
      table.insert(sorted, tile_proto)
   end
   table.sort(sorted, function(a, b)
      return a.name < b.name
   end)

   -- Build menu
   for _, tile_proto in ipairs(sorted) do
      builder:add_clickable("tile-" .. tile_proto.name, function(label_ctx)
         label_ctx.message:fragment(Localising.get_localised_name_with_fallback(tile_proto))
      end, {
         on_click = function(click_ctx)
            click_ctx.controller:close_with_result(tile_proto.name)
         end,
      })
   end

   return builder:build()
end

local tile_chooser_tab = KeyGraph.declare_graph({
   name = "tile_chooser",
   render_callback = build_tile_menu,
   title = { "fa.tile-chooser-title" },
})

mod.tile_chooser_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.TILE_CHOOSER,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "tile_chooser",
            tabs = { tile_chooser_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.tile_chooser_menu)

return mod
