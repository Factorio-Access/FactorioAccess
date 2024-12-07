local FaUtils = require("scripts.fa-utils")
local Geometry = require("scripts.geometry")
local Grid = require("scripts.ui.grid")
local Localising = require("scripts.localising")
local MessageBuilder = require("scripts.message-builder")
local TabList = require("scripts.ui.tab-list")
local TH = require("scripts.table-helpers")
local TransportBelts = require("scripts.transport-belts")

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

---@class fa.ui.BeltAnalyzer.Context: fa.ui.TabContext
---@field parameters fa.ui.BeltAnalyzer.Parameters
---@field shared_state fa.ui.BeltAnalyzer.SharedState

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

function LocalGrid:get_dims(context)
   -- 2 lanes, 4 slots.
   return 2, 4
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
   local node = context.shared_state.node

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

-- The only difference between the upstream/total/downstream tabs is which
-- field of the analysis they reference, so this returns the grids referencing
-- the proper field.  All other logic is 100% identical.
---@param field "upstream"|"downstream"|"total"
---@param length_field "upstream_length" | "downstream_length" | "total_length"
local function aggregate_grid_builder(field, length_field)
   ---@class fa.BeltAnalyzer.AggregateTabCallbacks:  fa.ui.GridCallbacks
   local TabCallbacks = {}

   ---@param ctx fa.ui.BeltAnalyzer.Context
   function TabCallbacks:get_dims(ctx)
      local state = ctx.shared_state.analysis[field]
      local height = math.max(#state[1], #state[2])
      if height == 0 then return 0, 0 end
      return 2, height
   end

   TabCallbacks.col_names = {
      { "fa.ui-belt-analyzer-left-lane" },
      { "fa.ui-belt-analyzer-right-lane" },
   }

   ---@param ctx fa.ui.BeltAnalyzer.Context
   function TabCallbacks:read_cell(ctx, x, y)
      local ent = ctx.shared_state.analysis[field][x][y]
      if not ent then return { "fa.ui-belt-analyzer-empty" } end

      local percent = string.format("%.1f", 100 * ent.count / ctx.shared_state.analysis[length_field])

      return { "fa.ui-belt-analyzer-aggregation", Localising.localise_item(ent), percent }
   end

   return Grid.declare_grid(TabCallbacks)
end

local TotalTab = aggregate_grid_builder("total", "total_length")
local UpstreamTab = aggregate_grid_builder("upstream", "upstream_length")
local DownstreamTab = aggregate_grid_builder("downstream", "downstream_length")

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
   -- Till we get everything over this needs to match legacy, and we just called
   -- it belt.
   menu_name = "belt",
   resets_to_first_tab_on_open = true,

   shared_state_setup = state_setup,

   tabs = {
      {
         name = "local",
         title = { "fa.ui-belt-analyzer-tab-local" },
         callbacks = LocalTab,
      },
      {
         name = "total",
         title = { "fa.ui-belt-analyzer-tab-total" },
         callbacks = TotalTab,
      },
      {
         name = "upstream",
         title = { "fa.ui-belt-analyzer-tab-upstream" },
         callbacks = UpstreamTab,
      },
      {
         name = "downstream",
         title = { "fa.ui-belt-analyzer-tab-downstream" },
         callbacks = DownstreamTab,
      },
   },
})

return mod
