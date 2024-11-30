local FaUtils = require("scripts.fa-utils")
local Geometry = require("scripts.geometry")
local Grid = require("scripts.ui.grid")
local Localising = require("scripts.localising")
local MessageBuilder = require("scripts.message-builder")
local TabList = require("scripts.ui.tab-list")
local TransportBelts = require("scripts.transport-belts")

local mod = {}

---@class fa.ui.BeltAnalyzer.State
---@field node fa.TransportBelts.Node

---@class fa.ui.BeltAnalyzer.Parameters
---@field entity LuaEntity

---@class fa.ui.BeltAnalyzer.Context: fa.ui.TabContext
---@field parameters fa.ui.BeltAnalyzer.Parameters
---@field state fa.ui.BeltAnalyzer.State

---@class fa.ui.BeltAnalyzer.LocalBeltGridCallbacks: fa.ui.GridCallbacks
local LocalGrid = {}

---@param context fa.ui.BeltAnalyzer.Context
function LocalGrid:col_names(context, index)
   local ent = context.parameters.entity
   if not ent.valid then
      context.force_close = true
      return
   end

   local facing = ent.direction
   local left = Geometry.dir_counterclockwise_90(facing)
   local right = Geometry.dir_clockwise_90(facing)

   local which = ({ left, right })[index]
   return { "fa.ui-belt-analyzer-lane", FaUtils.direction_lookup(which) }
end

---@param context fa.ui.BeltAnalyzer.Context
function LocalGrid:row_names(context, index)
   local ent = context.parameters.entity
   if not ent.valid then
      context.force_close = true
      return
   end

   return { "fa.ui-belt-analyzer-slot", index }
end

---@param context fa.ui.BeltAnalyzer.Context
---@param x number
---@param y number
function LocalGrid:read_cell(context, x, y)
   -- x is lane. y is cell.
   local node = context.state.node

   local contents = node:get_all_contents()
   local bucket = contents[x][y]
   assert(bucket)

   if not next(bucket.items) then return { "fa.ui-belt-analyzer-empty" } end

   local builder = MessageBuilder.MessageBuilder.new()

   for name, quals in pairs(bucket.items) do
      for quality, count in pairs(quals) do
         local item = Localising.localise_item({
            name = name,
            quality = quality,
            count = count,
         })
         builder:list_item(item)
      end
   end

   return builder:build()
end

local LocalTab = Grid.declare_grid(LocalGrid)

mod.belt_analyzer = TabList.declare_tablist({
   -- Till we get everything over this needs to match legacy, and we just called
   -- it belt.
   menu_name = "belt",
   tabs = {
      {
         name = "local",
         title = { "fa.ui-belt-analyzer-tab-local" },
         callbacks = LocalTab,
      },
   },
})

return mod
