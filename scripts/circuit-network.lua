--Here: Functions relating to circuit networks and wiring buildings.
--Includes wire dragging and pure functions for signal processing and aggregation.

local localising = require("scripts.localising")
local Viewpoint = require("scripts.viewpoint")
local Speech = require("scripts.speech")
local WorkerRobots = require("scripts.worker-robots")

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

-- ============================================================================
-- Signal Processing and Aggregation
-- ============================================================================

---Get the prototype dictionary for a signal type
---@param signal_type string
---@return table<string, any>
local function get_prototype_dict(signal_type)
   if signal_type == "item" or not signal_type then
      return prototypes.item
   elseif signal_type == "fluid" then
      return prototypes.fluid
   elseif signal_type == "virtual" then
      return prototypes.virtual_signal
   elseif signal_type == "entity" then
      return prototypes.entity
   elseif signal_type == "recipe" then
      return prototypes.recipe
   elseif signal_type == "space-location" then
      return prototypes.space_location
   elseif signal_type == "asteroid-chunk" then
      return prototypes.asteroid_chunk
   elseif signal_type == "quality" then
      return prototypes.quality
   else
      return {}
   end
end

---Localize a SignalID to a LocalisedString (without count)
---@param signal_id SignalID
---@return LocalisedString
function mod.localise_signal(signal_id)
   if not signal_id or not signal_id.name then return { "", "empty" } end

   local signal_type = signal_id.type or "item"
   local proto_dict = get_prototype_dict(signal_type)
   local proto = proto_dict[signal_id.name]

   if not proto then return { "", signal_id.name } end

   -- For items and fluids, use the quality-aware localisation
   if signal_type == "item" or signal_type == "fluid" then
      return localising.localise_item_or_fluid({
         name = proto,
         quality = signal_id.quality,
      }, proto_dict)
   else
      -- For other signals, just get the localised name
      return localising.get_localised_name_with_fallback(proto)
   end
end

---Localize a SignalID with count to a LocalisedString
---@param signal_id SignalID
---@param count number
---@return LocalisedString
function mod.localise_signal_with_count(signal_id, count)
   if not signal_id or not signal_id.name then return { "", "empty" } end

   local signal_type = signal_id.type or "item"
   local proto_dict = get_prototype_dict(signal_type)
   local proto = proto_dict[signal_id.name]

   if not proto then return { "", signal_id.name, " x ", tostring(count) } end

   -- For items and fluids, use the quality-aware localisation
   if signal_type == "item" or signal_type == "fluid" then
      return localising.localise_item_or_fluid({
         name = proto,
         quality = signal_id.quality,
         count = count,
      }, proto_dict)
   else
      -- For other signals, just get name and append count
      local name = localising.get_localised_name_with_fallback(proto)
      return { "", name, " x ", tostring(count) }
   end
end

---Create a key for grouping signals (ignoring quality)
---@param signal_id SignalID
---@return string
local function get_signal_group_key(signal_id)
   local signal_type = signal_id.type or "item"
   return signal_type .. ":" .. signal_id.name
end

---Aggregate signals from a circuit network, summing across qualities
---Returns a table mapping group keys to aggregated signal info
---@param signals Signal[]?
---@return table<string, {signal_id: SignalID, total_count: number, by_quality: table<string, number>}>
function mod.aggregate_signals(signals)
   if not signals then return {} end

   local aggregated = {}

   for _, signal in ipairs(signals) do
      local key = get_signal_group_key(signal.signal)
      local quality = signal.signal.quality or "normal"

      if not aggregated[key] then
         aggregated[key] = {
            signal_id = {
               name = signal.signal.name,
               type = signal.signal.type,
               quality = "normal", -- Use normal for the base signal
            },
            total_count = 0,
            by_quality = {},
         }
      end

      aggregated[key].total_count = aggregated[key].total_count + signal.count
      aggregated[key].by_quality[quality] = (aggregated[key].by_quality[quality] or 0) + signal.count
   end

   return aggregated
end

---Sort aggregated signals by total count (descending) then by name
---@param aggregated table<string, {signal_id: SignalID, total_count: number, by_quality: table<string, number>}>
---@return {signal_id: SignalID, total_count: number, by_quality: table<string, number>}[]
function mod.sort_aggregated_signals(aggregated)
   local sorted = {}
   for _, info in pairs(aggregated) do
      table.insert(sorted, info)
   end

   table.sort(sorted, function(a, b)
      if a.total_count ~= b.total_count then return a.total_count > b.total_count end
      return a.signal_id.name < b.signal_id.name
   end)

   return sorted
end

---Get sorted quality names from a by_quality table
---@param by_quality table<string, number>
---@return string[]
function mod.get_sorted_quality_names(by_quality)
   local qualities = {}
   for quality_name, _ in pairs(by_quality) do
      table.insert(qualities, quality_name)
   end

   -- Sort by quality level
   table.sort(qualities, function(a, b)
      local qa = prototypes.quality[a]
      local qb = prototypes.quality[b]
      if not qa then return false end
      if not qb then return true end
      return qa.level < qb.level
   end)

   return qualities
end

---Get all signals from an entity's circuit networks
---Combines red and green if both_wires is true, otherwise uses specified wire
---@param entity LuaEntity
---@param both_wires boolean If true, combine red and green networks
---@param wire_connector_id defines.wire_connector_id? If both_wires is false, which wire to use
---@return Signal[]?
function mod.get_signals_from_entity(entity, both_wires, wire_connector_id)
   if not entity or not entity.valid then return nil end

   local all_signals = {}

   if both_wires then
      -- Combine signals from both red and green
      local red_network = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
      local green_network = entity.get_circuit_network(defines.wire_connector_id.circuit_green)

      if red_network and red_network.signals then
         for _, signal in ipairs(red_network.signals) do
            table.insert(all_signals, signal)
         end
      end

      if green_network and green_network.signals then
         for _, signal in ipairs(green_network.signals) do
            table.insert(all_signals, signal)
         end
      end
   else
      -- Get signals from specified wire
      local network = entity.get_circuit_network(wire_connector_id)

      if network and network.signals then all_signals = network.signals end
   end

   return #all_signals > 0 and all_signals or nil
end

---Get network ID for display purposes
---@param entity LuaEntity
---@param wire_connector_id defines.wire_connector_id
---@return string
function mod.get_network_id_string(entity, wire_connector_id)
   if not entity or not entity.valid then return "nil" end

   local network = entity.get_circuit_network(wire_connector_id)

   if not network or not network.valid then return "nil" end

   return tostring(network.network_id)
end

---Get all signals from a constant combinator
---Returns table of {signal=SignalID, count=number}
---@param entity LuaEntity
---@return table[] Array of signal info
function mod.get_constant_combinator_filters(entity)
   local cb = entity.get_control_behavior()
   local all_signals = {}

   for _, section in ipairs(cb.sections) do
      for i = 1, section.filters_count do
         local slot = section.get_slot(i)
         if slot.value then
            table.insert(all_signals, {
               signal = slot.value,
               count = slot.min,
            })
         end
      end
   end

   return all_signals
end

---Get info string for constant combinator signals (for fa-info)
---@param entity LuaEntity
---@param pindex number
---@return LocalisedString
function mod.constant_combinator_signals_info(entity, pindex)
   local all_signals = mod.get_constant_combinator_filters(entity)

   if #all_signals == 0 then return { "", "No outputs" } end

   local msg = Speech.MessageBuilder.new()

   for i, signal_info in ipairs(all_signals) do
      msg:fragment(mod.localise_signal(signal_info.signal))
      if signal_info.count > 0 then
         msg:fragment("x")
         msg:fragment(tostring(signal_info.count))
      end
      if i < #all_signals then msg:fragment(", ") end
   end

   return msg:build()
end

return mod
