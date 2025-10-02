--Here: Functions relating to circuit networks and wiring buildings.
--Most circuit network configuration features have been removed - only wire dragging remains.
--Circuit network configuration will be rebuilt in future using modern UI architecture.

local localising = require("scripts.localising")
local Viewpoint = require("scripts.viewpoint")
local Speech = require("scripts.speech")

local mod = {}

---Handles dragging wires (circuit red/green and electrical copper) between entities
---@param pindex integer
function mod.drag_wire_and_read(pindex)
   --Start/end dragging wire
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local something_happened = p.drag_wire({ position = vp:get_cursor_pos() })
   --Comment on it
   if not something_happened then
      p.play_sound({ path = "utility/cannot_build" })
      return
   end
   local result = ""
   local wire_type = nil
   local wire_name = { "item-name.wire" }
   if p.cursor_stack.valid_for_read then
      wire_type = p.cursor_stack.name
      wire_name = localising.get_localised_name_with_fallback(p.cursor_stack.prototype)
      storage.players[pindex].last_wire_type = wire_type
      storage.players[pindex].last_wire_name = wire_name
   else
      wire_type = storage.players[pindex].last_wire_type
      wire_name = storage.players[pindex].last_wire_name
   end

   local drag_target = p.drag_target
   local ents_at_position = p.surface.find_entities_filtered({
      position = vp:get_cursor_pos(),
      radius = 0.2,
      type = {
         "transport-belt",
         "inserter",
         "container",
         "logistic-container",
         "storage-tank",
         "gate",
         "rail-signal",
         "rail-chain-signal",
         "train-stop",
         "accumulator",
         "roboport",
         "mining-drill",
         "pumpjack",
         "power-switch",
         "programmable-speaker",
         "lamp",
         "offshore-pump",
         "pump",
         "electric-pole",
      },
   })
   local c_ent = ents_at_position[1]
   local last_c_ent = storage.players[pindex].last_wire_ent
   local network_found = nil
   if c_ent == nil or c_ent.valid == false then c_ent = p.selected end
   if c_ent == nil or c_ent.valid == false then
      result = wire_name .. " , " .. " no ent "
   elseif wire_type == "red-wire" then
      if drag_target ~= nil then
         local target_ent = drag_target.target_entity
         local target_network = drag_target.target_circuit_id
         network_found = c_ent.get_circuit_network(defines.wire_connector_id.circuit_red)
         if network_found == nil or network_found.valid == false then
            network_found = "nil"
         else
            network_found = network_found.network_id
         end
         result = {
            "",
            " Connected ",
            localising.get_localised_name_with_fallback(target_ent),
            " to red circuit network ID ",
            network_found,
         }
      else
         result = { "", " Disconnected ", wire_name }
      end
   elseif wire_type == "green-wire" then
      if drag_target ~= nil then
         local target_ent = drag_target.target_entity
         local target_network = drag_target.target_circuit_id
         network_found = c_ent.get_circuit_network(defines.wire_connector_id.circuit_green)
         if network_found == nil or network_found.valid == false then
            network_found = "nil"
         else
            network_found = network_found.network_id
         end
         result = {
            "",
            " Connected ",
            localising.get_localised_name_with_fallback(target_ent),
            " to green circuit network ID ",
            network_found,
         }
      else
         result = { "", " Disconnected ", wire_name }
      end
   elseif wire_type == "copper-cable" then
      if drag_target ~= nil then
         local target_ent = drag_target.target_entity
         local target_network = drag_target.target_wire_id
         network_found = c_ent.electric_network_id
         if network_found == nil then network_found = "nil" end
         result = {
            "",
            " Connected ",
            localising.get_localised_name_with_fallback(target_ent),
            " to electric network ID ",
            network_found,
         }
      elseif
         (c_ent ~= nil and c_ent.name == "power-switch")
         or (last_c_ent ~= nil and last_c_ent.valid and last_c_ent.name == "power-switch")
      then
         network_found = c_ent.electric_network_id
         if network_found == nil then network_found = "nil" end
         result = { "fa.circuit-wiring-power-switch" }
         --result = " Connected " .. localising.get(c_ent,pindex) .. " to electric network ID " .. network_found
      else
         result = { "", " Disconnected ", wire_name }
      end
   end
   --p.print(result,{volume_modifier=0})--**
   Speech.speak(pindex, result)
   storage.players[pindex].last_wire_ent = c_ent
end

return mod
