--[[
Power switch UI for Factorio 2.0.

Provides a TabList UI for power switches with:
- Main tabstop: Switch control + Circuit network signals
- Circuit network tabstop: Standard circuit network configuration
]]

local TabList = require("scripts.ui.tab-list")
local Router = require("scripts.ui.router")
local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local CircuitNetworkSignals = require("scripts.ui.tabs.circuit-network-signals")
local CircuitNetwork = require("scripts.ui.tabs.circuit-network")
local Wires = require("scripts.wires")
local Speech = require("scripts.speech")

local mod = {}

---Render the power switch control tab
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_power_switch_control(ctx)
   local entity = ctx.global_parameters and ctx.global_parameters.entity
   assert(entity and entity.valid, "render_power_switch_control: entity is nil or invalid")
   assert(entity.type == "power-switch", "render_power_switch_control: entity is not a power-switch")

   local cb = entity.get_control_behavior()
   local menu = Menu.MenuBuilder.new()

   -- Row 1: Switch toggle
   menu:start_row("switch_row")
   menu:add_item("switch_toggle", {
      label = function(ctx)
         local is_circuit_controlled = cb and (cb.circuit_enable_disable or cb.connect_to_logistic_network)

         if is_circuit_controlled then
            if entity.power_switch_state then
               ctx.message:fragment({ "fa.power-switch-on-in-circuit-network" })
            else
               ctx.message:fragment({ "fa.power-switch-off-in-circuit-network" })
            end
         else
            if entity.power_switch_state then
               ctx.message:fragment({ "fa.power-switch-on" })
            else
               ctx.message:fragment({ "fa.power-switch-off" })
            end
         end
      end,
      on_click = function(ctx)
         local is_circuit_controlled = cb and (cb.circuit_enable_disable or cb.connect_to_logistic_network)

         if is_circuit_controlled then
            ctx.controller.message:fragment({ "fa.power-switch-circuit-controlled" })
         else
            entity.power_switch_state = not entity.power_switch_state
            if entity.power_switch_state then
               ctx.controller.message:fragment({ "fa.power-switch-on" })
            else
               ctx.controller.message:fragment({ "fa.power-switch-off" })
            end
         end
      end,
   })
   menu:end_row()

   -- Row 2: Static label
   menu:add_label("circuit_config_label", function(ctx)
      ctx.message:fragment({ "fa.power-switch-circuit-config-label" })
   end)

   return menu:build()
end

---Build tabs for the power switch
---@param pindex number
---@param parameters any
---@return fa.ui.TabstopDescriptor[]
local function build_power_switch_tabs(pindex, parameters)
   assert(parameters, "build_power_switch_tabs: parameters is nil")
   local entity = parameters.entity
   assert(entity, "build_power_switch_tabs: entity is nil")
   assert(entity.valid, "build_power_switch_tabs: entity is not valid")
   assert(entity.type == "power-switch", "build_power_switch_tabs: entity is not a power-switch")

   -- Tabstop 1: Main (Control + Circuit signals)
   local main_tabs = {}

   -- Control tab
   table.insert(
      main_tabs,
      KeyGraph.declare_graph({
         name = "control",
         title = { "fa.power-switch-control-title" },
         render_callback = render_power_switch_control,
      })
   )

   -- Circuit network signals tabs (red and green)
   table.insert(
      main_tabs,
      CircuitNetworkSignals.create_signals_tab(
         { "fa.circuit-network-signals-red" },
         false,
         defines.wire_connector_id.circuit_red
      )
   )
   table.insert(
      main_tabs,
      CircuitNetworkSignals.create_signals_tab(
         { "fa.circuit-network-signals-green" },
         false,
         defines.wire_connector_id.circuit_green
      )
   )

   -- Tabstop 2: Circuit network configuration (if available)
   local circuit_tabs = {}
   if CircuitNetwork.is_available(entity) then table.insert(circuit_tabs, CircuitNetwork.get_tab()) end

   return {
      {
         name = "main",
         tabs = main_tabs,
      },
      {
         name = "circuit_network",
         title = { "fa.section-circuit-network" },
         tabs = circuit_tabs,
      },
   }
end

---Create and register the power switch UI
mod.power_switch_ui = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.POWER_SWITCH,
   resets_to_first_tab_on_open = true,
   tabs_callback = build_power_switch_tabs,
})

Router.register_ui(mod.power_switch_ui)

return mod
