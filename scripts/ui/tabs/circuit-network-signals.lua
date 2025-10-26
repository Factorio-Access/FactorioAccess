--[[
Reusable circuit network signals overview tab.

Shows all signals on a circuit network, summed across qualities.
Each signal row can expand to show quality breakdown.

Can be configured to show:
- All signals (red + green combined)
- Red wire signals only
- Green wire signals only
]]

local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local CircuitNetworks = require("scripts.circuit-network")
local Localising = require("scripts.localising")
local FaInfo = require("scripts.fa-info")

local mod = {}

---Render signals overview for a circuit network
---@param ctx fa.ui.graph.Ctx
---@param title LocalisedString
---@param both_wires boolean
---@param wire_connector_id defines.wire_connector_id?
---@return fa.ui.graph.Render?
local function render_signals(ctx, title, both_wires, wire_connector_id)
   local entity = ctx.global_parameters.entity

   local menu = Menu.MenuBuilder.new()

   -- Check if network exists
   local has_network = false
   if both_wires then
      local red_network = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
      local green_network = entity.get_circuit_network(defines.wire_connector_id.circuit_green)
      has_network = (red_network ~= nil) or (green_network ~= nil)
   else
      local network = entity.get_circuit_network(wire_connector_id)
      has_network = network ~= nil
   end

   if not has_network then
      menu:add_label("not_in_network", function(ctx)
         ctx.message:fragment({ "fa.circuit-network-not-connected" })
      end)
      return menu:build()
   end

   -- Get aggregated signals from the specified wire(s)
   local sorted_signals = CircuitNetworks.get_aggregated_signals_from_entity(entity, both_wires, wire_connector_id)

   if not sorted_signals or #sorted_signals == 0 then
      menu:add_label("no_signals", function(ctx)
         ctx.message:fragment({ "fa.circuit-network-no-signals" })
      end)
      return menu:build()
   end

   -- Render each signal with expandable quality breakdown
   for i, sig_info in ipairs(sorted_signals) do
      local key_prefix = "signal_" .. i

      menu:start_row(key_prefix)

      -- Main signal summary (total across all qualities)
      menu:add_item(key_prefix .. "_summary", {
         label = function(ctx)
            local signal_name = CircuitNetworks.localise_signal(sig_info.signal_id)
            ctx.message:fragment({ "fa.circuit-network-signal-summary", signal_name, sig_info.total_count })
            ctx.message:fragment({ "fa.circuit-network-quality-hint" })
         end,
         on_production_stats_announcement = function(ctx)
            if sig_info.signal_id and sig_info.signal_id.name then
               local stats_message = FaInfo.selected_item_production_stats_info(ctx.pindex, sig_info.signal_id.name)
               ctx.message:fragment(stats_message)
            end
         end,
      })

      -- Quality breakdown (shown when moving right)
      local sorted_qualities = CircuitNetworks.get_sorted_quality_names(sig_info.by_quality)
      for q_idx, quality_name in ipairs(sorted_qualities) do
         local count = sig_info.by_quality[quality_name]
         menu:add_item(key_prefix .. "_quality_" .. q_idx, {
            label = function(ctx)
               -- Show quality name x count
               local quality_proto = prototypes.quality[quality_name]
               local quality_label = Localising.get_localised_name_with_fallback(quality_proto)
               ctx.message:fragment({ "fa.circuit-network-quality-count", quality_label, count })
            end,
         })
      end

      menu:end_row()
   end

   return menu:build()
end

---Create a circuit network signals tab
---@param title LocalisedString Tab title
---@param both_wires boolean If true, show combined red+green signals
---@param wire_connector_id defines.wire_connector_id? If both_wires is false, which wire to show
---@return fa.ui.TabDescriptor
function mod.create_signals_tab(title, both_wires, wire_connector_id)
   local tab_name = both_wires and "circuit_signals_all"
      or (
         wire_connector_id == defines.wire_connector_id.circuit_red and "circuit_signals_red"
         or "circuit_signals_green"
      )

   return KeyGraph.declare_graph({
      name = tab_name,
      title = title,
      render_callback = function(ctx)
         return render_signals(ctx, title, both_wires, wire_connector_id)
      end,
   })
end

return mod
