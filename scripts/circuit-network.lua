--Here: Functions relating to circuit networks and wiring buildings.
--Includes wire dragging and pure functions for signal processing and aggregation.

local localising = require("scripts.localising")
local Viewpoint = require("scripts.viewpoint")
local Speech = require("scripts.speech")
local WorkerRobots = require("scripts.worker-robots")
local FaUtils = require("scripts.fa-utils")
local Localising = require("scripts.localising")

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

   local wire_type = nil
   local wire_name = nil
   if p.cursor_stack.valid_for_read then
      wire_type = p.cursor_stack.name
      wire_name = localising.get_localised_name_with_fallback(p.cursor_stack.prototype)
      storage.players[pindex].last_wire_type = wire_type
      storage.players[pindex].last_wire_name = wire_name
   else
      wire_type = storage.players[pindex].last_wire_type
      wire_name = storage.players[pindex].last_wire_name
   end

   -- If we still don't have a wire type/name, bail out
   if not wire_type or not wire_name then
      Speech.speak(pindex, { "fa.circuit-wire-no-wire-in-hand" })
      p.play_sound({ path = "utility/cannot_build" })
      return
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

   local msg = Speech.MessageBuilder.new()

   if c_ent == nil or c_ent.valid == false then
      msg:fragment({ "fa.circuit-wire-no-entity", wire_name })
   elseif wire_type == "red-wire" or wire_type == "green-wire" then
      if drag_target ~= nil then
         local target_ent = drag_target.target_entity
         local wire_connector_id = wire_type == "red-wire" and defines.wire_connector_id.circuit_red
            or defines.wire_connector_id.circuit_green
         local locale_key = wire_type == "red-wire" and "fa.circuit-wire-connected-red"
            or "fa.circuit-wire-connected-green"

         network_found = c_ent.get_circuit_network(wire_connector_id)
         if network_found == nil or network_found.valid == false then
            network_found = "nil"
         else
            network_found = tostring(network_found.network_id)
         end
         msg:fragment({
            locale_key,
            localising.get_localised_name_with_fallback(target_ent),
            network_found,
         })
      else
         msg:fragment({ "fa.circuit-wire-disconnected", wire_name })
      end
   elseif wire_type == "copper-wire" then
      -- Copper wires can only connect to electric poles and power switches
      local is_valid_copper_target = c_ent.type == "electric-pole" or c_ent.name == "power-switch"

      if not is_valid_copper_target then
         msg:fragment({ "fa.circuit-wire-invalid-copper-target", localising.get_localised_name_with_fallback(c_ent) })
      elseif drag_target ~= nil then
         local target_ent = drag_target.target_entity
         local target_network = drag_target.target_wire_id
         network_found = c_ent.electric_network_id
         if network_found == nil then
            network_found = "nil"
         else
            network_found = tostring(network_found)
         end
         msg:fragment({
            "fa.circuit-wire-connected-copper",
            localising.get_localised_name_with_fallback(target_ent),
            network_found,
         })
      elseif
         (c_ent ~= nil and c_ent.name == "power-switch")
         or (last_c_ent ~= nil and last_c_ent.valid and last_c_ent.name == "power-switch")
      then
         msg:fragment({ "fa.circuit-wiring-power-switch" })
      else
         msg:fragment({ "fa.circuit-wire-disconnected", wire_name })
      end
   end

   Speech.speak(pindex, msg:build())
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

---Aggregate signals from a circuit network, summing across qualities
---Returns a nested table: type -> name -> quality -> count
---@param signals Signal[]?
---@return table<string, table<string, table<string, number>>>
function mod.aggregate_signals(signals)
   if not signals then return {} end

   local aggregated = {}

   for _, signal in ipairs(signals) do
      local signal_type = signal.signal.type or "item"
      local signal_name = signal.signal.name
      local quality = signal.signal.quality or "normal"

      aggregated[signal_type] = aggregated[signal_type] or {}
      aggregated[signal_type][signal_name] = aggregated[signal_type][signal_name] or {}
      aggregated[signal_type][signal_name][quality] = (aggregated[signal_type][signal_name][quality] or 0)
         + signal.count
   end

   return aggregated
end

---Sort aggregated signals by total count (descending) then by name
---Unrolls the nested table into a flat sorted array
---@param aggregated table<string, table<string, table<string, number>>>
---@return {signal_id: SignalID, total_count: number, by_quality: table<string, number>}[]
function mod.sort_aggregated_signals(aggregated)
   local sorted = {}

   for signal_type, names in pairs(aggregated) do
      for signal_name, qualities in pairs(names) do
         local total_count = 0
         for _, count in pairs(qualities) do
            total_count = total_count + count
         end

         table.insert(sorted, {
            signal_id = {
               name = signal_name,
               type = signal_type,
               quality = "normal",
            },
            total_count = total_count,
            by_quality = qualities,
         })
      end
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

---Get aggregated signals from an entity's circuit networks
---Returns signals already aggregated and sorted, ready for display
---@param entity LuaEntity
---@param both_wires boolean If true, combine red and green networks
---@param wire_connector_id defines.wire_connector_id? If both_wires is false, which wire to use
---@return {signal_id: SignalID, total_count: number, by_quality: table<string, number>}[]?
function mod.get_aggregated_signals_from_entity(entity, both_wires, wire_connector_id)
   local signals = mod.get_signals_from_entity(entity, both_wires, wire_connector_id)
   if not signals then return nil end

   local aggregated = mod.aggregate_signals(signals)
   return mod.sort_aggregated_signals(aggregated)
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

---Get circuit network info for fa-info display
---Returns info about all networks this entity is connected to
---@param entity LuaEntity
---@param msg fa.MessageBuilder Message builder to add info to
function mod.add_circuit_network_info(entity, msg)
   local networks = {}

   -- Check red wire
   local red_network = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
   if red_network then
      table.insert(networks, {
         id = red_network.network_id,
         count = red_network.connected_circuit_count,
         color = "red",
      })
   end

   -- Check green wire
   local green_network = entity.get_circuit_network(defines.wire_connector_id.circuit_green)
   if green_network then
      table.insert(networks, {
         id = green_network.network_id,
         count = green_network.connected_circuit_count,
         color = "green",
      })
   end

   if #networks == 0 then return end

   -- Build message with list_item for each network
   for _, network_info in ipairs(networks) do
      local others = network_info.count - 1
      msg:list_item()
      if network_info.color == "red" then
         msg:fragment({ "fa.circuit-network-info-red", tostring(network_info.id), tostring(others) })
      else
         msg:fragment({ "fa.circuit-network-info-green", tostring(network_info.id), tostring(others) })
      end
   end
end

---Get copper wire neighbor count for fa-info display (electric poles)
---@param entity LuaEntity
---@param msg fa.MessageBuilder Message builder to add info to
function mod.add_copper_wire_info(entity, msg)
   -- Count unique neighbors via copper wires
   local neighbor_count = 0
   local seen = {}

   local connectors = entity.get_wire_connectors(false)
   for _, connector in pairs(connectors) do
      if connector.wire_type == defines.wire_type.copper then
         for _, connection in pairs(connector.connections) do
            local other = connection.target.owner
            if other.valid and not seen[other.unit_number] then
               seen[other.unit_number] = true
               neighbor_count = neighbor_count + 1
            end
         end
      end
   end

   if neighbor_count > 0 then
      msg:list_item()
      msg:fragment({ "fa.copper-wire-neighbors", tostring(neighbor_count) })
   end
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

   for _, signal_info in ipairs(all_signals) do
      msg:list_item()
      msg:fragment(mod.localise_signal(signal_info.signal))
      if signal_info.count > 0 then
         msg:fragment("x")
         msg:fragment(tostring(signal_info.count))
      end
   end

   return msg:build()
end

---Get immediate neighbors via copper wires (electric poles)
---Returns grouped and formatted string for display
---@param entity LuaEntity
---@param pindex number
---@return LocalisedString
function mod.get_copper_wire_neighbors_info(entity, pindex)
   local neighbors = {}

   -- Collect all directly connected entities via copper wires
   local connectors = entity.get_wire_connectors(false)
   for _, connector in pairs(connectors) do
      if connector.wire_type == defines.wire_type.copper then
         for _, connection in pairs(connector.connections) do
            local other = connection.target.owner
            if other.valid then
               local n, q = other.name, other.quality.name
               neighbors[n] = neighbors[n] or {}
               neighbors[n][q] = neighbors[n][q] or {}
               table.insert(neighbors[n][q], other)
            end
         end
      end
   end

   if not next(neighbors) then return { "", "No copper wire connections" } end

   -- Sort by distance then direction
   for t, quals in pairs(neighbors) do
      for q, ents in pairs(quals) do
         table.sort(ents, function(a, b)
            local a_dist = FaUtils.distance(a.position, entity.position)
            local b_dist = FaUtils.distance(b.position, entity.position)
            if a_dist < b_dist then return true end
            if a_dist > b_dist then return false end

            local a_dir = FaUtils.get_direction_biased(a.position, entity.position)
            local b_dir = FaUtils.get_direction_biased(b.position, entity.position)
            return a_dir < b_dir
         end)
      end
   end

   -- Build message
   local msg = Speech.MessageBuilder.new()

   for n, quals in pairs(neighbors) do
      local proto = prototypes.entity[n]
      local pname = Localising.get_localised_name_with_fallback(proto)

      for q, ents in pairs(quals) do
         msg:list_item()

         -- Add quality prefix if not normal
         if q ~= "normal" then msg:fragment(Localising.get_localised_name_with_fallback(prototypes.quality[q])) end

         msg:fragment(pname)

         -- Build list of direction/distance for each entity
         local ent_parts = {}
         for _, e in pairs(ents) do
            table.insert(ent_parts, {
               "fa.dir-dist",
               FaUtils.direction_lookup(FaUtils.get_direction_biased(e.position, entity.position)),
               FaUtils.distance_speech_friendly(entity.position, e.position),
            })
         end

         -- Use build_list with "and" for the individual entities
         msg:fragment(FaUtils.build_list(ent_parts))
      end
   end

   return msg:build()
end

---Get immediate circuit network neighbors (directly connected entities)
---Returns grouped and formatted string for display
---@param entity LuaEntity
---@param pindex number
---@return LocalisedString
function mod.get_circuit_neighbors_info(entity, pindex)
   local neighbors = {}

   -- Collect all directly connected entities via circuit wires
   local connectors = entity.get_wire_connectors(false)
   for _, connector in pairs(connectors) do
      if connector.wire_type == defines.wire_type.red or connector.wire_type == defines.wire_type.green then
         for _, connection in pairs(connector.connections) do
            local other = connection.target.owner
            if other.valid then
               local n, q = other.name, other.quality.name
               neighbors[n] = neighbors[n] or {}
               neighbors[n][q] = neighbors[n][q] or {}
               table.insert(neighbors[n][q], other)
            end
         end
      end
   end

   if not next(neighbors) then return { "", "No circuit network connections" } end

   -- Sort by distance then direction
   for t, quals in pairs(neighbors) do
      for q, ents in pairs(quals) do
         table.sort(ents, function(a, b)
            local a_dist = FaUtils.distance(a.position, entity.position)
            local b_dist = FaUtils.distance(b.position, entity.position)
            if a_dist < b_dist then return true end
            if a_dist > b_dist then return false end

            local a_dir = FaUtils.get_direction_biased(a.position, entity.position)
            local b_dir = FaUtils.get_direction_biased(b.position, entity.position)
            return a_dir < b_dir
         end)
      end
   end

   -- Build message
   local msg = Speech.MessageBuilder.new()

   for n, quals in pairs(neighbors) do
      local proto = prototypes.entity[n]
      local pname = Localising.get_localised_name_with_fallback(proto)

      for q, ents in pairs(quals) do
         msg:list_item()

         -- Add quality prefix if not normal
         if q ~= "normal" then msg:fragment(Localising.get_localised_name_with_fallback(prototypes.quality[q])) end

         msg:fragment(pname)

         -- Build list of direction/distance for each entity
         local ent_parts = {}
         for _, e in pairs(ents) do
            table.insert(ent_parts, {
               "fa.dir-dist",
               FaUtils.direction_lookup(FaUtils.get_direction_biased(e.position, entity.position)),
               FaUtils.distance_speech_friendly(entity.position, e.position),
            })
         end

         -- Use build_list with "and" for the individual entities
         msg:fragment(FaUtils.build_list(ent_parts))
      end
   end

   return msg:build()
end

---Find all entities in a circuit network using BFS, sorted by hop distance
---@param start_entity LuaEntity The entity to start from
---@param wire_connector_id defines.wire_connector_id Which wire connector to follow
---@return table[] Array of {entity: LuaEntity, hops: number} sorted by hops
function mod.find_entities_in_network_by_hops(start_entity, wire_connector_id)
   local network = start_entity.get_circuit_network(wire_connector_id)
   if not network then return {} end

   local target_network_id = network.network_id
   local visited = {}
   local queue = { { entity = start_entity, hops = 0 } }
   local head = 1
   local results = {}

   while head <= #queue do
      local current = queue[head]
      head = head + 1

      local unit_number = current.entity.unit_number
      if not visited[unit_number] then
         visited[unit_number] = true
         table.insert(results, current)

         -- Find all neighbors via circuit wires
         local connectors = current.entity.get_wire_connectors(false)
         for _, connector in pairs(connectors) do
            if connector.wire_type == defines.wire_type.red or connector.wire_type == defines.wire_type.green then
               -- Check if this connector is in our target network
               if connector.network_id == target_network_id then
                  -- Add all connected entities to queue
                  for _, connection in pairs(connector.connections) do
                     local neighbor = connection.target.owner
                     if neighbor.valid and not visited[neighbor.unit_number] then
                        table.insert(queue, { entity = neighbor, hops = current.hops + 1 })
                     end
                  end
               end
            end
         end
      end
   end

   -- Sort by hops (already mostly sorted due to BFS, but ensure it)
   table.sort(results, function(a, b)
      if a.hops ~= b.hops then return a.hops < b.hops end
      return a.entity.unit_number < b.entity.unit_number
   end)

   return results
end

return mod
