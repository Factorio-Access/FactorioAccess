--Here: Functions relating to circuit networks and wiring buildings.
--Includes wire dragging and pure functions for signal processing and aggregation.

local CombinatorBoundingBoxes = require("scripts.combinator-bounding-boxes")
local Geometry = require("scripts.geometry")
local Viewpoint = require("scripts.viewpoint")
local Speech = require("scripts.speech")
local Sounds = require("scripts.ui.sounds")
local WorkerRobots = require("scripts.worker-robots")
local FaUtils = require("scripts.fa-utils")
local Localising = require("scripts.localising")
local ItemInfo = require("scripts.item-info")

local mod = {}

---Calculate world position for a connection point from an AABB
---@param entity LuaEntity
---@param aabb fa.AABB Connection point AABB
---@return MapPosition
local function aabb_to_world_pos(entity, aabb)
   -- Get center of the AABB in entity-local coordinates
   local local_x = (aabb.left_top.x + aabb.right_bottom.x) / 2
   local local_y = (aabb.left_top.y + aabb.right_bottom.y) / 2

   -- Rotate to world coordinates
   local world_x, world_y = Geometry.rotate_vec(local_x, local_y, entity.direction)

   -- Add entity position
   return {
      x = entity.position.x + world_x,
      y = entity.position.y + world_y,
   }
end

---Calculate world position for a connection point from a position vector
---@param entity LuaEntity
---@param pos Vector Connection point position
---@return MapPosition
local function vec_to_world_pos(entity, pos)
   -- Rotate to world coordinates
   local world_x, world_y = Geometry.rotate_vec(pos.x, pos.y, entity.direction)

   -- Add entity position
   return {
      x = entity.position.x + world_x,
      y = entity.position.y + world_y,
   }
end

---Remove wires from the selected entity
---Removes circuit wires first (red+green), then copper wires on subsequent presses
---@param pindex integer
function mod.remove_wires(pindex)
   local p = game.get_player(pindex)
   local ent = p.selected

   if not ent or not ent.valid then
      Speech.speak(pindex, { "fa.circuit-wires-no-wires-found" })
      Sounds.play_cannot_build(pindex)
      return
   end

   local connectors = ent.get_wire_connectors(false)

   -- Try to remove circuit wires first (both red and green)
   local removed_circuit = false
   for _, connector in pairs(connectors) do
      if
         (connector.wire_type == defines.wire_type.red or connector.wire_type == defines.wire_type.green)
         and connector.connection_count > 0
      then
         connector.disconnect_all()
         removed_circuit = true
      end
   end

   if removed_circuit then
      Speech.speak(pindex, { "fa.circuit-wires-removed-red-green" })
      Sounds.play_wire_disconnect(pindex)
      return
   end

   -- No circuit wires, try copper wires
   for _, connector in pairs(connectors) do
      if connector.wire_type == defines.wire_type.copper and connector.connection_count > 0 then
         connector.disconnect_all()
         Speech.speak(pindex, { "fa.circuit-wires-removed-copper" })
         Sounds.play_wire_disconnect(pindex)
         return
      end
   end

   -- No wires found
   Speech.speak(pindex, { "fa.circuit-wires-no-wires-found" })
   Sounds.play_cannot_build(pindex)
end

---Handles dragging wires (circuit red/green and electrical copper) between entities
---@param pindex integer
---@param side fa.ConnectionSide|nil Optional side for multi-connection entities ("input"|"output"|"left"|"right")
function mod.drag_wire_and_read(pindex, side)
   --Start/end dragging wire
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)

   -- Determine the position to use for dragging
   local drag_pos = vp:get_cursor_pos()
   local c_ent = p.selected

   -- Determine wire type in hand
   local wire_type = nil
   if p.cursor_stack and p.cursor_stack.valid_for_read then wire_type = p.cursor_stack.name end

   -- Check if entity has multiple connection points and calculate appropriate position
   if c_ent and c_ent.valid then
      local metadata = CombinatorBoundingBoxes.get_metadata(c_ent.name)
      local needs_side_selection = false

      if metadata then
         -- Check if this entity needs side selection for the current wire type
         if metadata.input_aabb then
            -- Combinators always need side selection for circuit wires
            needs_side_selection = true
         elseif metadata.left_pos and wire_type == "copper-wire" then
            -- Power switches need side selection only for copper wire
            needs_side_selection = true
         end
      end

      if needs_side_selection then
         -- Entity has multiple connection points for this wire type
         if not side then
            -- No side specified, prompt user
            if metadata.input_aabb then
               -- It's a combinator
               Speech.speak(pindex, { "fa.circuit-wire-multiple-connection-points-combinator" })
            elseif metadata.left_pos then
               -- It's a power switch with copper wire
               Speech.speak(pindex, { "fa.circuit-wire-multiple-connection-points-power-switch" })
            end
            Sounds.play_cannot_build(pindex)
            return
         end

         -- Calculate position based on side
         -- Map "input" to "left" and "output" to "right" for power switches
         local actual_side = side
         if metadata.left_pos and side == "input" then
            actual_side = "left"
         elseif metadata.right_pos and side == "output" then
            actual_side = "right"
         end

         if metadata.input_aabb and actual_side == "input" then
            drag_pos = aabb_to_world_pos(c_ent, metadata.input_aabb)
         elseif metadata.output_aabb and actual_side == "output" then
            drag_pos = aabb_to_world_pos(c_ent, metadata.output_aabb)
         elseif metadata.left_pos and actual_side == "left" then
            drag_pos = vec_to_world_pos(c_ent, metadata.left_pos)
         elseif metadata.right_pos and actual_side == "right" then
            drag_pos = vec_to_world_pos(c_ent, metadata.right_pos)
         end
      else
         -- Entity doesn't have multiple connection points for this wire type, use center of tile
         drag_pos = FaUtils.center_of_tile(drag_pos)
      end
   else
      -- No entity selected, use center of tile
      drag_pos = FaUtils.center_of_tile(drag_pos)
   end

   local something_happened = p.drag_wire({ position = drag_pos })
   --Comment on it
   if not something_happened then
      p.play_sound({ path = "utility/cannot_build" })
      return
   end

   local wire_type = nil
   local wire_name = nil
   if p.cursor_stack.valid_for_read then
      wire_type = p.cursor_stack.name
      wire_name = Localising.get_localised_name_with_fallback(p.cursor_stack.prototype)
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
            Localising.get_localised_name_with_fallback(target_ent),
            network_found,
         })
      else
         msg:fragment({ "fa.circuit-wire-disconnected", wire_name })
      end
   elseif wire_type == "copper-wire" then
      -- Copper wires can only connect to electric poles and power switches
      local is_valid_copper_target = c_ent.type == "electric-pole" or c_ent.name == "power-switch"

      if not is_valid_copper_target then
         msg:fragment({ "fa.circuit-wire-invalid-copper-target", Localising.get_localised_name_with_fallback(c_ent) })
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
            Localising.get_localised_name_with_fallback(target_ent),
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

   local base_name
   -- For items and fluids, use the quality-aware localisation
   if signal_type == "item" or signal_type == "fluid" then
      base_name = ItemInfo.item_or_fluid_info({
         name = proto,
         quality = signal_id.quality,
      }, proto_dict)
   else
      -- For other signals, just get the localised name
      base_name = Localising.get_localised_name_with_fallback(proto)
   end

   -- Add type suffix for entity and recipe signals to disambiguate
   if signal_type == "entity" then
      return { "", base_name, " ", { "fa.signal-suffix-entity" } }
   elseif signal_type == "recipe" then
      return { "", base_name, " ", { "fa.signal-suffix-recipe" } }
   else
      return base_name
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
      return ItemInfo.item_or_fluid_info({
         name = proto,
         quality = signal_id.quality,
         count = count,
      }, proto_dict)
   else
      -- For other signals, just get name and append count
      local name = Localising.get_localised_name_with_fallback(proto)
      return { "", name, " x ", tostring(count) }
   end
end

---Localize a comparator symbol to a LocalisedString
---@param comparator string Comparator symbol (<, <=, =, !=, >=, >)
---@return LocalisedString
function mod.localise_comparator(comparator)
   local comp = comparator or "<"
   local key_map = {
      ["<"] = "lt",
      ["≤"] = "lte",
      ["<="] = "lte",
      ["="] = "eq",
      ["≠"] = "ne",
      ["!="] = "ne",
      ["≥"] = "gte",
      [">="] = "gte",
      [">"] = "gt",
   }
   local key = "fa.comparator-" .. (key_map[comp] or "lt")
   return { key }
end

---Get next comparator (cycle forward)
---@param current string Current comparator
---@return string
function mod.get_next_comparison_operator(current)
   local comparators = { "<", "≤", "=", "≥", ">", "≠" }
   local curr = current or "<"
   for i, comp in ipairs(comparators) do
      if comp == curr then return comparators[(i % #comparators) + 1] end
   end
   return "<"
end

---Get previous comparator (cycle backward)
---@param current string Current comparator
---@return string
function mod.get_prev_comparison_operator(current)
   local comparators = { "<", "≤", "=", "≥", ">", "≠" }
   local curr = current or "<"
   for i, comp in ipairs(comparators) do
      if comp == curr then
         local prev_idx = i - 1
         if prev_idx < 1 then prev_idx = #comparators end
         return comparators[prev_idx]
      end
   end
   return "<"
end

---@class fa.CircuitConditionReadOptions
---@field empty_message LocalisedString? Message to show when condition is unconfigured (defaults to generic message)

---Helper to get network text for display (red, green, or empty for both)
---@param networks CircuitNetworkSelection?
---@return LocalisedString
local function get_network_text(networks)
   if not networks then return "" end
   local red = networks.red ~= false
   local green = networks.green ~= false
   if red and not green then
      return { "fa.decider-red-network" }
   elseif green and not red then
      return { "fa.decider-green-network" }
   else
      return ""
   end
end

---Read a circuit condition into a MessageBuilder
---Unified function for reading CircuitCondition or CircuitConditionDefinition
---Network fields (first_signal_networks, second_signal_networks) are only present on DeciderCombinatorCondition
---@param mb fa.MessageBuilder MessageBuilder to write to
---@param condition CircuitCondition|CircuitConditionDefinition? The condition to read
---@param options fa.CircuitConditionReadOptions? Optional configuration
function mod.read_condition(mb, condition, options)
   options = options or {}

   -- Handle unconfigured condition
   if not condition or not condition.first_signal or not condition.first_signal.name then
      mb:fragment(options.empty_message or { "fa.condition-unconfigured" })
      return
   end

   -- First signal with optional network (only on DeciderCombinatorCondition)
   mb:fragment(mod.localise_signal(condition.first_signal))
   if condition.first_signal_networks then mb:fragment(get_network_text(condition.first_signal_networks)) end

   -- Comparator
   mb:fragment(mod.localise_comparator(condition.comparator))

   -- Second signal or constant
   if condition.second_signal and condition.second_signal.name then
      mb:fragment(mod.localise_signal(condition.second_signal))
      if condition.second_signal_networks then mb:fragment(get_network_text(condition.second_signal_networks)) end
   else
      local constant = condition.constant or 0
      mb:fragment(tostring(constant))
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

   if #all_signals == 0 then return { "fa.circuit-no-outputs" } end

   local msg = Speech.MessageBuilder.new()

   for _, signal_info in ipairs(all_signals) do
      msg:list_item()
      msg:fragment(mod.localise_signal(signal_info.signal))
      if signal_info.count ~= 0 then
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

   if not next(neighbors) then return { "fa.circuit-no-copper-connections" } end

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

   if not next(neighbors) then return { "fa.circuit-no-circuit-connections" } end

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

---Get neighbors for a specific wire connector
---@param entity LuaEntity
---@param connector_id defines.wire_connector_id
---@return table Grouped neighbors by name and quality
local function get_neighbors_for_connector(entity, connector_id)
   local neighbors = {}
   local connector = entity.get_wire_connector(connector_id, false)
   if not connector or connector.connection_count == 0 then return neighbors end

   for _, connection in pairs(connector.connections) do
      local other = connection.target.owner
      if other.valid then
         local n, q = other.name, other.quality.name
         neighbors[n] = neighbors[n] or {}
         neighbors[n][q] = neighbors[n][q] or {}
         table.insert(neighbors[n][q], other)
      end
   end

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

   return neighbors
end

---Add neighbors list to message with intro fragment
---@param msg fa.MessageBuilder
---@param entity LuaEntity
---@param neighbors table Grouped neighbors
---@param intro_key string Locale key for intro fragment
local function add_neighbors_to_message(msg, entity, neighbors, intro_key)
   if not next(neighbors) then return end

   msg:fragment({ intro_key })

   for n, quals in pairs(neighbors) do
      local proto = prototypes.entity[n]
      local pname = Localising.get_localised_name_with_fallback(proto)

      local first = true

      for q, ents in pairs(quals) do
         if not first then msg:list_item() end
         first = false

         -- Add quality prefix if not normal
         if q ~= "normal" then msg:fragment(Localising.get_localised_name_with_fallback(prototypes.quality[q])) end

         msg:fragment(pname)

         for _, e in pairs(ents) do
            msg:list_item({
               "fa.dir-dist",
               FaUtils.direction_lookup(FaUtils.get_direction_biased(e.position, entity.position)),
               FaUtils.distance_speech_friendly(entity.position, e.position),
            })
         end
      end
   end

   -- Close this section with an empty list_item
   msg:list_item()
end

---Get combinator neighbors info with separate sections for each connection point
---@param entity LuaEntity
---@param pindex number
---@return LocalisedString
function mod.get_combinator_neighbors_info(entity, pindex)
   local msg = Speech.MessageBuilder.new()
   local has_any = false

   -- Input red
   local input_red = get_neighbors_for_connector(entity, defines.wire_connector_id.combinator_input_red)
   if next(input_red) then
      add_neighbors_to_message(msg, entity, input_red, "fa.combinator-neighbors-input-red")
      has_any = true
   end

   -- Input green
   local input_green = get_neighbors_for_connector(entity, defines.wire_connector_id.combinator_input_green)
   if next(input_green) then
      add_neighbors_to_message(msg, entity, input_green, "fa.combinator-neighbors-input-green")
      has_any = true
   end

   -- Output red
   local output_red = get_neighbors_for_connector(entity, defines.wire_connector_id.combinator_output_red)
   if next(output_red) then
      add_neighbors_to_message(msg, entity, output_red, "fa.combinator-neighbors-output-red")
      has_any = true
   end

   -- Output green
   local output_green = get_neighbors_for_connector(entity, defines.wire_connector_id.combinator_output_green)
   if next(output_green) then
      add_neighbors_to_message(msg, entity, output_green, "fa.combinator-neighbors-output-green")
      has_any = true
   end

   if not has_any then return { "fa.circuit-no-circuit-connections" } end

   return msg:build()
end

---Get power switch neighbors info with separate sections for left/right copper and circuit
---@param entity LuaEntity
---@param pindex number
---@return LocalisedString
function mod.get_power_switch_neighbors_info(entity, pindex)
   local msg = Speech.MessageBuilder.new()
   local has_any = false

   -- Left copper
   local left_copper = get_neighbors_for_connector(entity, defines.wire_connector_id.power_switch_left_copper)
   if next(left_copper) then
      add_neighbors_to_message(msg, entity, left_copper, "fa.power-switch-neighbors-left")
      has_any = true
   end

   -- Right copper
   local right_copper = get_neighbors_for_connector(entity, defines.wire_connector_id.power_switch_right_copper)
   if next(right_copper) then
      add_neighbors_to_message(msg, entity, right_copper, "fa.power-switch-neighbors-right")
      has_any = true
   end

   -- Circuit wires (red and green combined)
   local circuit_neighbors = {}
   local red_connector = entity.get_wire_connector(defines.wire_connector_id.circuit_red, false)
   if red_connector and red_connector.connection_count > 0 then
      for _, connection in pairs(red_connector.connections) do
         local other = connection.target.owner
         if other.valid then
            local n, q = other.name, other.quality.name
            circuit_neighbors[n] = circuit_neighbors[n] or {}
            circuit_neighbors[n][q] = circuit_neighbors[n][q] or {}
            table.insert(circuit_neighbors[n][q], other)
         end
      end
   end

   local green_connector = entity.get_wire_connector(defines.wire_connector_id.circuit_green, false)
   if green_connector and green_connector.connection_count > 0 then
      for _, connection in pairs(green_connector.connections) do
         local other = connection.target.owner
         if other.valid then
            local n, q = other.name, other.quality.name
            circuit_neighbors[n] = circuit_neighbors[n] or {}
            circuit_neighbors[n][q] = circuit_neighbors[n][q] or {}
            -- Only add if not already present
            local already_added = false
            for _, existing in ipairs(circuit_neighbors[n][q]) do
               if existing == other then
                  already_added = true
                  break
               end
            end
            if not already_added then table.insert(circuit_neighbors[n][q], other) end
         end
      end
   end

   if next(circuit_neighbors) then
      -- Sort circuit neighbors
      for t, quals in pairs(circuit_neighbors) do
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

      add_neighbors_to_message(msg, entity, circuit_neighbors, "fa.power-switch-neighbors-circuit")
      has_any = true
   end

   if not has_any then return { "fa.circuit-no-copper-connections" } end

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
