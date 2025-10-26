local FaUtils = require("scripts.fa-utils")
local Functools = require("scripts.functools")
local Geometry = require("scripts.geometry")
local ItemInfo = require("scripts.item-info")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local TH = require("scripts.table-helpers")
local TransportBelts = require("scripts.transport-belts")
local Grid = require("scripts.ui.grid")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local TabList = require("scripts.ui.tab-list")
local circuit_network_tab = require("scripts.ui.tabs.circuit-network")

local mod = {}

---@alias fa.BeltAnalyzer.SortedEntries ({ name: string, quality: string, count: number })[]

---@class fa.BeltAnalyzer.SortedAnalysisData
---@field upstream fa.BeltAnalyzer.SortedEntries[]
---@field downstream fa.BeltAnalyzer.SortedEntries[]
---@field total fa.BeltAnalyzer.SortedEntries[]
---@field upstream_length number
---@field downstream_length number
---@field total_length number

---@class fa.ui.BeltAnalyzer.SharedState
---@field node fa.TransportBelts.Node
---@field analysis fa.BeltAnalyzer.SortedAnalysisData

---@class fa.ui.BeltAnalyzer.Parameters
---@field entity LuaEntity

---@class fa.ui.BeltAnalyzer.Context: fa.ui.graph.Ctx
---@field global_parameters fa.ui.BeltAnalyzer.Parameters
---@field tablist_shared_state fa.ui.BeltAnalyzer.SharedState

---@param ctx fa.ui.BeltAnalyzer.Context
---@return LocalisedString
local function name_col(ctx, x)
   local ent = ctx.global_parameters.entity

   local facing = ent.direction
   local left = Geometry.dir_counterclockwise_90(facing)
   local right = Geometry.dir_clockwise_90(facing)
   local index = x

   local which = ({ left, right })[index]
   return { "fa.ui-belt-analyzer-lane", FaUtils.direction_lookup(which) }
end

local function name_row(y)
   assert(y >= 1 and y <= 4)
   return { "fa.ui-belt-analyzer-slot", y }
end

---@param ctx fa.ui.BeltAnalyzer.Context
---@param x number
---@param y number
local function local_dim_namer(ctx, x, y)
   local col = name_col(ctx, x)
   local row = name_row(y)
   ctx.message:fragment({ "fa.ui-belt-analyzer-local-pos", row, col })
end

---@param ctx fa.ui.BeltAnalyzer.Context
---@param x number
---@param y number
local function label_local_cell(ctx, x, y)
   -- x is lane. y is cell.
   local node = ctx.tablist_shared_state.node

   local contents = node:get_all_contents()

   local bucket = contents[x] and contents[x][y]
   if not bucket then return { "fa.ui-belt-analyzer-empty" } end

   if not next(bucket.items) then return { "fa.ui-belt-analyzer-empty" } end

   local builder = MessageBuilder.new()

   for name, quals in pairs(bucket.items) do
      for quality, count in pairs(quals) do
         local item = ItemInfo.item_info({
            name = name,
            quality = quality,
            count = count,
         })
         builder:list_item(item)
      end
   end

   return builder:build()
end

local function local_renderer(ctx)
   local builder = Grid.grid_builder()

   for x = 1, 2 do
      for y = 1, 4 do
         builder:add_simple_label(x, y, label_local_cell(ctx, x, y))
      end
   end

   return builder:set_dimension_labeler(local_dim_namer):build()
end

-- The only difference between the upstream/total/downstream tabs is which field of the analysis they reference, so this
-- returns the grids referencing the proper field.  All other logic is 100% identical.
---@param field "upstream"|"downstream"|"total"
---@param length_field "upstream_length" | "downstream_length" | "total_length"
local function aggregate_grid_builder(field, length_field)
   ---@param ctx fa.ui.BeltAnalyzer.Context
   ---@return fa.ui.graph.Render?
   return function(ctx)
      local ent = ctx.global_parameters.entity
      if not ent.valid then return nil end

      local builder = Grid.grid_builder()
      local analysis = ctx.tablist_shared_state.analysis
      local state = analysis[field]

      -- Give the player a special message if the belt is empty.
      if not next(state[1]) and not next(state[2]) then
         return {
            nodes = {
               ["empty-belt"] = {
                  transitions = {},
                  vtable = {
                     label = function(ctx)
                        ctx.message:fragment({ "fa.ui-belt-analyzer-no-contents" })
                     end,
                  },
               },
            },
            start_key = "empty-belt",
         }
      end

      for col = 1, 2 do
         for row, bucket in pairs(state[col]) do
            local percent = string.format("%.1f", 100 * bucket.count / analysis[length_field])
            builder:add_simple_label(
               col,
               row,
               { "fa.ui-belt-analyzer-aggregation", ItemInfo.item_info(bucket), percent }
            )
         end
      end

      return builder:build()
   end
end

local total_renderer = aggregate_grid_builder("total", "total_length")
local upstream_renderer = aggregate_grid_builder("upstream", "upstream_length")
local downstream_renderer = aggregate_grid_builder("downstream", "downstream_length")

---@param params fa.ui.BeltAnalyzer.Parameters
---@return fa.ui.BeltAnalyzer.SharedState
local function state_setup(_pindex, params)
   local node = TransportBelts.Node.create(params.entity)
   local ad = node:belt_analyzer_algo()
   local up_left = TH.nqc_to_sorted_descending(ad.left.upstream)
   local up_right = TH.nqc_to_sorted_descending(ad.right.upstream)
   local down_left = TH.nqc_to_sorted_descending(ad.left.downstream)
   local down_right = TH.nqc_to_sorted_descending(ad.right.downstream)
   local tot_left = TH.nqc_to_sorted_descending(ad.left.total)
   local tot_right = TH.nqc_to_sorted_descending(ad.right.total)

   return {
      node = node,
      analysis = {
         upstream = { up_left, up_right },
         total = { tot_left, tot_right },
         downstream = { down_left, down_right },
         upstream_length = ad.upstream_length,
         downstream_length = ad.downstream_length,
         total_length = ad.total_length,
      },
   }
end

mod.belt_analyzer = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.BELT,
   resets_to_first_tab_on_open = true,
   shared_state_setup = state_setup,
   tabs_callback = function(pindex, parameters)
      local sections = {}

      -- Belt analyzer tabs
      table.insert(sections, {
         name = "main",
         tabs = {
            UiKeyGraph.declare_graph({
               title = { "fa.ui-belt-analyzer-tab-local" },
               render_callback = local_renderer,
               name = "local",
            }),
            UiKeyGraph.declare_graph({
               name = "total",
               title = { "fa.ui-belt-analyzer-tab-total" },
               render_callback = total_renderer,
            }),
            UiKeyGraph.declare_graph({
               name = "upstream",
               title = { "fa.ui-belt-analyzer-tab-upstream" },
               render_callback = upstream_renderer,
            }),
            UiKeyGraph.declare_graph({
               name = "downstream",
               title = { "fa.ui-belt-analyzer-tab-downstream" },
               render_callback = downstream_renderer,
            }),
         },
      })

      -- Add circuit network section if available
      local entity = parameters and parameters.entity
      if entity and circuit_network_tab.is_available(entity) then
         table.insert(sections, {
            name = "circuit-network",
            title = { "fa.section-circuit-network" },
            tabs = { circuit_network_tab.get_tab() },
         })
      end

      return sections
   end,
})

-- Register with the UI event routing system for event interception
UiRouter.register_ui(mod.belt_analyzer)

return mod
