--[[
Circuit Network Navigator UI

Allows users to explore circuit networks by jumping between entities.
- Lists all available networks the entity is in
- Shows entities in selected network sorted by hop distance
- Clicking an entity jumps to it and reopens navigator
]]

local TabList = require("scripts.ui.tab-list")
local Router = require("scripts.ui.router")
local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local CircuitNetwork = require("scripts.circuit-network")
local Localising = require("scripts.localising")
local Viewpoint = require("scripts.viewpoint")
local FaUtils = require("scripts.fa-utils")
local Speech = require("scripts.speech")

local mod = {}

---Check if entity is a complex combinator (arith/selector/decider)
---@param entity LuaEntity
---@return boolean
local function is_complex_combinator(entity)
   return entity.type == "arithmetic-combinator"
      or entity.type == "selector-combinator"
      or entity.type == "decider-combinator"
end

---Render the network selection menu
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_network_selection(ctx)
   -- Initialize entity from parameters on first render
   if not ctx.state.entity then ctx.state.entity = ctx.global_parameters.entity end
   local entity = ctx.state.entity

   -- Check for complex combinators
   if is_complex_combinator(entity) then
      local menu = Menu.MenuBuilder.new()
      menu:add_label("not_supported", function(ctx)
         ctx.message:fragment({ "fa.circuit-navigator-not-supported" })
      end)
      return menu:build()
   end

   local menu = Menu.MenuBuilder.new()

   -- Check red network
   local red_network = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
   if red_network then
      menu:add_item("red_network", {
         label = function(ctx)
            local count = red_network.connected_circuit_count - 1
            ctx.message:fragment({ "fa.circuit-navigator-red", tostring(red_network.network_id), tostring(count) })
         end,
         on_click = function(ctx)
            ctx.controller:open_child_ui(
               Router.UI_NAMES.CIRCUIT_NAVIGATOR_ENTITIES,
               { entity = entity, wire_connector_id = defines.wire_connector_id.circuit_red },
               { node = "red_network" }
            )
         end,
      })
   end

   -- Check green network
   local green_network = entity.get_circuit_network(defines.wire_connector_id.circuit_green)
   if green_network then
      menu:add_item("green_network", {
         label = function(ctx)
            local count = green_network.connected_circuit_count - 1
            ctx.message:fragment({ "fa.circuit-navigator-green", tostring(green_network.network_id), tostring(count) })
         end,
         on_click = function(ctx)
            ctx.controller:open_child_ui(
               Router.UI_NAMES.CIRCUIT_NAVIGATOR_ENTITIES,
               { entity = entity, wire_connector_id = defines.wire_connector_id.circuit_green },
               { node = "green_network" }
            )
         end,
      })
   end

   if not red_network and not green_network then
      menu:add_label("no_networks", function(ctx)
         ctx.message:fragment({ "fa.circuit-network-not-connected" })
      end)
   end

   return menu:build()
end

---Render the entities list for a specific network
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_entities_list(ctx)
   -- Initialize from parameters on first render
   if not ctx.state.entity then ctx.state.entity = ctx.global_parameters.entity end
   if not ctx.state.wire_connector_id then ctx.state.wire_connector_id = ctx.global_parameters.wire_connector_id end
   local entity = ctx.state.entity
   local wire_connector_id = ctx.state.wire_connector_id

   local entities_by_hops = CircuitNetwork.find_entities_in_network_by_hops(entity, wire_connector_id)

   local menu = Menu.MenuBuilder.new()

   if #entities_by_hops == 0 then
      menu:add_label("no_entities", function(ctx)
         ctx.message:fragment({ "fa.circuit-navigator-no-entities" })
      end)
      return menu:build()
   end

   for i, entry in ipairs(entities_by_hops) do
      local ent = entry.entity
      local hops = entry.hops
      local key = "entity_" .. ent.unit_number

      menu:add_item(key, {
         label = function(ctx)
            local proto = prototypes.entity[ent.name]
            local pname = Localising.get_localised_name_with_fallback(proto)
            if ent.quality.name ~= "normal" then
               local qname = Localising.get_localised_name_with_fallback(prototypes.quality[ent.quality.name])
               pname = qname .. " " .. pname
            end
            local hops_text = hops > 0 and { "fa.circuit-navigator-hops", tostring(hops) } or ""
            ctx.message:fragment({
               "fa.circuit-navigator-entity-full",
               pname,
               FaUtils.direction_lookup(FaUtils.get_direction_biased(ent.position, entity.position)),
               FaUtils.distance_speech_friendly(entity.position, ent.position),
               hops_text,
            })
         end,
         on_click = function(ctx)
            -- Jump to entity and update state to point to new entity
            local pindex = ctx.pindex
            local player = game.get_player(pindex)
            local vp = Viewpoint.get_viewpoint(pindex)

            vp:set_cursor_pos(ent.position)
            player.selected = ent

            -- Update the entity in state for rerender
            ctx.state.entity = ent

            Speech.speak(pindex, { "fa.moved" })
         end,
      })
   end

   return menu:build()
end

---Build tabs for circuit navigator
---@param pindex number
---@param parameters any
---@return fa.ui.TabstopDescriptor[]
local function build_navigator_tabs(pindex, parameters)
   local entity = parameters.entity

   return {
      {
         name = "networks",
         tabs = {
            KeyGraph.declare_graph({
               name = "network_selection",
               title = { "fa.circuit-navigator-select-network" },
               render_callback = render_network_selection,
            }),
         },
      },
   }
end

---Create and register the circuit navigator UI
mod.circuit_navigator = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.CIRCUIT_NAVIGATOR,
   resets_to_first_tab_on_open = true,
   tabs_callback = build_navigator_tabs,
})

---Build tabs for entities list
---@param pindex number
---@param parameters any
---@return fa.ui.TabstopDescriptor[]
local function build_entities_tabs(pindex, parameters)
   return {
      {
         name = "entities",
         tabs = {
            KeyGraph.declare_graph({
               name = "circuit_navigator_entities",
               title = { "fa.circuit-navigator-entities" },
               render_callback = render_entities_list,
            }),
         },
      },
   }
end

---Create the entities list UI (opened as child UI from network selection)
local circuit_navigator_entities = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.CIRCUIT_NAVIGATOR_ENTITIES,
   resets_to_first_tab_on_open = true,
   tabs_callback = build_entities_tabs,
})

Router.register_ui(mod.circuit_navigator)
Router.register_ui(circuit_navigator_entities)

return mod
