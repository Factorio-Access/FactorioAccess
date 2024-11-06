--[[
Announcement of information.

This file is used to build up the strings used for entity statuses and cursor
movement, which are honestlyh most of the mod's "magic".  It consists of
functions which either produce strings about entities or produce joined up
strings to send to the player.  Since the applicability conditions for each
announcement are complex and we would prefer not to centralize them, we do this
by passing around a MessageBuilder and some context as to what's going on.

The localisation is in entity-info.cfg.  We do not distinguish between cursor
level information and status level information in the localisation, because it
is not necessarily the case that things fall into one or the other, or that we
won't change our mind later or maybe even go as far as adding settings for this
stuff.
]]
local dirs = defines.direction
local util = require("util")

local Belts = require("scripts.transport-belts")
local BotLogistics = require("scripts.worker-robots")
local BuildingTools = require("scripts.building-tools")
local Circuits = require("scripts.circuit-networks")
local Driving = require("scripts.driving")
local Electrical = require("scripts.electrical")
local Equipment = require("scripts.equipment")
local FaUtils = require("scripts.fa-utils")
local Fluids = require("scripts.fluids")
local Graphics = require("scripts.graphics")
local Localising = require("scripts.localising")
local MessageBuilder = require("scripts.message-builder")
local Rails = require("scripts.rails")
local ResourceMining = require("scripts.resource-mining")
local Trains = require("scripts.trains")

local mod = {}

---@class fa.info.EntInfoContext
---@field message fa.MessageBuilder
---@field is_scanner boolean
---@field ent LuaEntity
---@field pindex number
---@field player LuaPlayer

--Ent info: Gives the distance and direction of a fluidbox connection target?
--Todo: update to clarify comments and include localization
local function get_adjacent_source(box, pos, dir)
   local result = { position = pos, direction = "" }
   ebox = table.deepcopy(box)
   if dir == 1 or dir == 3 then
      ebox.left_top.x = box.left_top.y
      ebox.left_top.y = box.left_top.x
      ebox.right_bottom.x = box.right_bottom.y
      ebox.right_bottom.y = box.right_bottom.x
   end
   --   print(ebox.left_top.x .. " " .. ebox.left_top.y)
   ebox.left_top.x = math.ceil(ebox.left_top.x * 2) / 2
   ebox.left_top.y = math.ceil(ebox.left_top.y * 2) / 2
   ebox.right_bottom.x = math.floor(ebox.right_bottom.x * 2) / 2
   ebox.right_bottom.y = math.floor(ebox.right_bottom.y * 2) / 2

   if pos.x < ebox.left_top.x then
      result.position.x = result.position.x + 1
      result.direction = "West"
   elseif pos.x > ebox.right_bottom.x then
      result.position.x = result.position.x - 1
      result.direction = "East"
   elseif pos.y < ebox.left_top.y then
      result.position.y = result.position.y + 1
      result.direction = "North"
   elseif pos.y > ebox.right_bottom.y then
      result.position.y = result.position.y - 1
      result.direction = "South"
   end
   return result
end

---@param ctx fa.info.EntInfoContext
local function ent_info_facing(ctx)
   local effective_direction
   local ent = ctx.ent
   -- Set in the case where we detect symmetry.
   local secondary_effective_direction

   if
      (ent.prototype.is_building and ent.supports_direction)
      or (ent.name == "entity-ghost" and ent.ghost_prototype.is_building and ent.ghost_prototype.supports_direction)
   then
      effective_direction = FaUtils.direction_lookup(ent.direction)
      if ent.type == "generator" then
         --For steam engines and steam turbines, north = south and east = west
         secondary_direction = FaUtils.direction_lookup(FaUtils.rotate_180(ent.direction))
      end
   elseif ent.type == "locomotive" or ent.type == "car" then
      effective_direction = (FaUtils.get_heading_info(ent))
   end

   if effective_direction and secondary_direction then
      ctx.message:fragment({ "fa.ent-info-facing-symmetric", effective_direction, secondary_direction })
   elseif effective_direction then
      ctx.message:fragment({ "fa.ent-info-facing", effective_direction })
   end
end

-- Announces if the entity is marked for upgrading or deconstruction. Folded
-- into one function, as these are mutually exclusive states as far as we know.
---@param ctx fa.info.EntInfoContext
local function ent_info_marked_for_upgrade_deconstruct(ctx)
   if ctx.ent.to_be_deconstructed() then
      ctx.message:fragment({ "fa.ent-info-marked-for-deconstruction" })
   elseif ctx.ent.to_be_upgraded() then
      ctx.message:fragment({ "fa.ent-info-marked-for-upgrading" })
   end

   -- Otherwise it is not marked.
end

-- If this entity generates electricity, tell the player how much.
---@param ctx fa.info.EntInfoContext
local function ent_info_power_production(ctx)
   local ent = ctx.ent
   if ctx.ent.prototype.type == "generator" then
      local power1 = ent.energy_generated_last_tick * 60
      local power2 = ent.prototype.get_max_energy_production(ent.quality) * 60
      local power_load_pct = math.ceil(power1 / power2 * 100)
      if power2 ~= nil then
         ctx.message:fragment(FaUtils.localise_cat_table({ "fa.ent-info-generator-load", power_load_pct })):fragment({
            "fa.ent-info-generator-production",
            Electrical.get_power_string(power1),
            Electrical.get_power_string(power2),
         })
      else
         ctx.message:fragment({ "fa.ent-info-generator-production", Electrical.get_power_string(power1) })
      end
   end
end

-- If the entity has a status which is super important, for example no power or
-- output full, tell the player.  These are things that we judge to be important
-- enough that checking status shouldn't be required.
---@param ctx fa.info.EntInfoContext
local function ent_info_important_statuses(ctx)
   local ent = ctx.ent
   local status = ent.status
   local stat = defines.entity_status
   if status ~= nil and status ~= stat.normal and status ~= stat.working then
      if
         status == stat.no_ingredients
         or status == stat.no_input_fluid
         or status == stat.no_minable_resources
         or status == stat.item_ingredient_shortage
         or status == stat.missing_required_fluid
         or status == stat.no_ammo
      then
         ctx.message:fragment({ "fa.ent-info-input-missing" })
      elseif status == stat.full_output or status == stat.full_burnt_result_output then
         ctx.message:fragment({ "fa.ent-info-output-full" })
      end
   end
end

-- "not connected to power" etc.
---@param ctx fa.info.EntInfoContext
local function ent_info_power_status(ctx)
   local ent = ctx.ent
   if ent.prototype.electric_energy_source_prototype ~= nil and ent.is_connected_to_electric_network() == false then
      ctx.message:fragment({ "fa.ent-info-no-power-connection" })
   elseif ent.prototype.electric_energy_source_prototype ~= nil and ent.energy == 0 and ent.type ~= "solar-panel" then
      ctx.message:fragment({ "fa.ent-info-no-power-empty-electric-network" })
   end
end

-- Announces if the entity is a wall and a point at which the player may connect
-- the circuit network to control a gate.
---@param ctx fa.info.EntInfoContext
local function ent_info_gate_connection_point(ctx)
   if ctx.ent.type == "wall" and ctx.ent.get_control_behavior() ~= nil then
      ctx.message:fragment({ "fa.ent-info-gate-circuit-network-connection" })
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_accumulator(ctx)
   local ent = ctx.ent
   if ent.type == "accumulator" then
      local level = math.ceil(ent.energy / ent.electric_buffer_size * 100) --In percentage
      local charge = math.ceil(ent.energy)
      ctx.message:fragment({ "fa.ent-info-accumulator-charge", level, Electrical.get_power_string(charge) })
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_solar(ctx)
   local ent = ctx.ent

   if ent.type == "solar-panel" then
      local s_time = ent.surface.daytime * 24 --We observed 18 = peak solar start, 6 = peak solar end, 11 = night start, 13 = night end
      local solar_status = ""
      if s_time > 13 and s_time <= 18 then
         ctx.message:fragment({ "fa.ent-info-solar-increasing" })
      elseif s_time > 18 or s_time < 6 then
         ctx.message:fragment({ "fa.ent-info-solar-full-production" })
      elseif s_time > 6 and s_time <= 11 then
         ctx.message:fragment({ "fa.ent-info-solar-evening" })
      elseif s_time > 11 and s_time <= 13 then
         ctx.message:fragment({ "fa.ent-info-solar-night" })
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_rocket_silo(ctx)
   local ent = ctx.ent
   if ent.name == "rocket-silo" then
      if ent.rocket_parts ~= nil and ent.rocket_parts < 100 then
         ctx.message:fragment({ "fa.ent-info-silo-partial", ent.rocket_parts })
      elseif ent.rocket_parts ~= nil then
         ctx.message:fragment({ "fa.ent-info-silo-complete" })
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_beacon_status(ctx)
   local ent = ctx.ent
   if ent.name == "beacon" then
      local modules = ent.get_module_inventory()
      if modules.get_item_count() == 0 then
         ctx.message:fragment({ "fa.ent-info-beacon-modules-0" })
      elseif modules.get_item_count() == 1 then
         ctx.message:fragment({ "fa.ent-info-beacon-modules-1", modules[1].name })
      elseif modules.get_item_count() == 2 then
         ctx.message:fragment({ "fa.ent-info-beacon-modules-2", modules[1].name, modules[2].name })
      elseif modules.get_item_count() > 2 then
         ctx.message:fragment({ "fa.ent-info-beacon-modules-more", modules[1].name, modules[2].name })
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_constant_combinator(ctx)
   local ent = ctx.ent
   if ent.type == "constant-combinator" then
      ctx.message:fragment(Circuits.constant_combinator_signals_info(ent, pindex))
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_resource(ctx)
   local ent = ctx.ent
   if ent.type == "resource" then
      if not ent.initial_amount then
         -- initial_amount is nil for non-infinite resources.
         ctx.message:fragment({ "fa.ent-info-resource-noninfinite", ent.amount })
      else
         -- The game computes it this way then displays it as 403% or w/e.
         local percentage = ent.prototype.normal_resource_amount / 100
         ctx.message:fragment({ "fa.ent-info-resource-infinite", percentage })
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_ghost(ctx)
   local ent = ctx.ent
   if ent.name == "entity-ghost" then
      ctx.message:fragment({
         "fa.ent-info-ghost",
         Localising.get_localised_name_with_fallback(ent.ghost_prototype),
         Localising.get_localised_name_with_fallback(ent.prototype),
      })
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_rail(ctx)
   local ent = ctx.ent
   -- TODO: really we shouldn't need pindex here, but for now rails aren't
   -- localised properly.
   if ent.name == "straight-rail" or ent.name == "curved-rail" then return Rails.rail_ent_info(ctx.pindex, ent) end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_character(ctx)
   local ent = ctx.ent
   if ent.name == "character" then
      local p = ent.player
      local p2 = ent.associated_player
      if p ~= nil and p.valid and p.name ~= nil and p.name ~= "" then
         ctx.message:fragment(p.name)
      elseif p2 ~= nil and p2.valid and p2.name ~= nil and p2.name ~= "" then
         ctx.message:fragment(p2.name)
      elseif p ~= nil and p.valid and p.index == ctx.pindex then
         ctx.message:fragment({ "fa.ent-info-self-character" })
      elseif pindex ~= nil then
         ctx.message:fragment(tostring(pindex))
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_character_corpse(ctx)
   local ent = ctx.ent
   if ent.name == "character-corpse" then
      if ent.character_corpse_player_index == ctx.pindex then
         ctx.message:fragment({ "fa.ent-info-corpse-is-self" })
      elseif ent.character_corpse_player_index ~= nil then
         ctx.message:fragment({ "fa.ent-info-corpse-of-other" })
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_container(ctx)
   local ent = ctx.ent
   if ent.type == "container" or ent.type == "logistic-container" or ent.type == "infinity-container" then
      --Chests etc: Report the most common item and say "and other items" if there are other types.
      local itemset = ent.get_inventory(defines.inventory.chest).get_contents()
      local itemtable = {}
      for _, info in pairs(itemset) do
         table.insert(itemtable, { name = info.name, count = info.count })
      end
      table.sort(itemtable, function(k1, k2)
         return k1.count > k2.count
      end)

      if #itemtable == 0 then
         ctx.message:fragment({ "fa.ent-info-container-empty" })
      elseif #itemtable == 1 then
         ctx.message:fragment({
            "fa.ent-info-container-with-1",
            Localising.get_item_from_name(itemtable[1].name, ctx.pindex),
            itemtable[1].count,
         })
      elseif #itemtable == 2 then
         ctx.message:fragment({
            "fa.ent-info-container-with-2",
            Localising.get_item_from_name(itemtable[1].name, ctx.pindex),
            itemtable[1].count,
            Localising.get_item_from_name(itemtable[2].name, ctx.pindex),
            itemtable[2].count,
         })
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_logistic_network(ctx)
   local ent = ctx.ent
   -- very unclear: isn't this just entity.logistic_network?  To revisit after
   -- this file is refactored.
   if ent.type == "logistic-container" then
      local network = ent.surface.find_logistic_network_by_position(ent.position, ent.force)
      if network == nil then
         local nearest_roboport = FaUtils.find_nearest_roboport(ent.surface, ent.position, 5000)
         if nearest_roboport == nil then
            ctx.message:fragment({ "ent-info-logistic-not-in-network", 5000 })
         else
            local dist = math.ceil(util.distance(ent.position, nearest_roboport.position) - 25)
            local dir = FaUtils.direction_lookup(FaUtils.get_direction_biased(nearest_roboport.position, ent.position))
            ctx.message:fragment({
               "fa.ent-info-logistic-not-in-network-with-near",
               nearest_roboport.backer_name,
               dist,
               dir,
            })
         end
      else
         local network_name = network.cells[1].owner.backer_name
         ctx.message:fragment({ "fa.ent-info-logistic-in-network", network_name })
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_infinity_pipe(ctx)
   local ent = ctx.ent
   if ent.name == "infinity-pipe" then
      local filter = ent.get_infinity_pipe_filter()
      if filter == nil then
         ctx.message:fragment({ "fa.ent-info-infinity-pipe-draining" })
      else
         ctx.message:fragment({ "fa.ent-info-infinity-pipe-producing", filter.name })
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_pipe_shape(ctx)
   if ctx.ent.type == "pipe" then
      local shape_info = Fluids.get_pipe_shape(ctx.ent)
      local s, d = shape_info.shape, shape_info.direction
      local d_str = FaUtils.direction_lookup(d)
      local conns = ctx.ent.fluidbox.get_pipe_connections(1)
      local conn_count = 0
      for _, c in pairs(conns) do
         if c.target then conn_count = conn_count + 1 end
      end

      -- We must be careful.  Pipe shapes do not account for other kinds of
      -- connection, so we must compare with the expected count as well.
      -- Otherwise we will say that a pipe is both connected and not connected
      -- at the same time.

      -- This is just a boring if table which appends fragments.  no special
      -- logic here.
      if s == Fluids.PIPE_SHAPE.END and conn_count == 1 then
         ctx.message:fragment({ "fa.ent-info-pipe-end", FaUtils.direction_lookup(FaUtils.rotate_180(d)) })
      elseif s == Fluids.PIPE_SHAPE.ALONE and conn_count == 0 then
         ctx.message:fragment({ "fa.ent-info-pipe-alone" })
      elseif s == Fluids.PIPE_SHAPE.STRAIT and conn_count == 2 then
         local key = d == defines.direction.north and "fa.ent-info-pipe-vertical" or "fa.ent-info-pipe-horizontal"
         ctx.message:fragment({ key })
      elseif s == Fluids.PIPE_SHAPE.CORNER and conn_count == 2 then
         local c1, c2
         if d == defines.direction.northwest then
            c1 = defines.direction.south
            c2 = defines.direction.east
         elseif d == defines.direction.northeast then
            c1 = defines.direction.south
            c2 = defines.direction.west
         elseif d == defines.direction.southwest then
            c1 = defines.direction.north
            c2 = defines.direction.east
         elseif d == defines.direction.southeast then
            c1 = defines.direction.north
            c2 = defines.direction.west
         else
            error("unreachable! " .. serpent.line({ s = s, d = d }))
         end

         ctx.message:fragment({ "fa.ent-info-pipe-corner", FaUtils.direction_lookup(c1), FaUtils.direction_lookup(c2) })
      elseif s == Fluids.PIPE_SHAPE.CROSS and conn_count == 4 then
         ctx.message:fragment({ "fa.ent-info-pipe-cross" })
      elseif s == Fluids.PIPE_SHAPE.T then
         local key = "fa.ent-info-pipe-t-vertical"
         if d == defines.direction.north or d == defines.direction.south then key = "fa.ent-info-pipe-t-horizontal" end
         ctx.message:fragment({ key, FaUtils.direction_lookup(FaUtils.rotate_180(d)) })
      end
   end
end

-- For everything that contains a fluid but isn't a crafting machine, say what
-- it is.
---@param ctx fa.info.EntInfoContext
local function ent_info_fluid_transport(ctx)
   -- TODO: needs cleanup for 2.0
end

---@param ctx fa.info.EntInfoContext
local function ent_info_underground_belt_type(ctx)
   local ent = ctx.ent
   if ent.type == "underground-belt" then
      if ent.belt_to_ground_type == "input" then
         ctx.message:fragment({ "fa.ent-info-underground-belt-entrance" })
      elseif ent.belt_to_ground_type == "output" then
         ctx.message:fragment({ "fa.ent-info-underground-belt-exit" })
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_train_stop(ctx)
   local ent = ctx.ent
   if ent.name == "train-stop" then
      local limit = ent.trains_limit or 0
      ctx.message:fragment({ "fa.ent-info-train-stop", ent.backer_name, limit })
   end
end

-- Returns train name announcement with id fallback.
---@param ctx fa.info.EntInfoContext
local function ent_info_train_owner(ctx)
   local ent = ctx.ent
   if ent.name == "locomotive" or ent.name == "cargo-wagon" or ent.name == "fluid-wagon" then
      ctx.message:fragment({ "fa.ent-info-of-train", Trains.get_train_name(ent.train) })
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_rail_signal_state(ctx)
   -- TODO: this should be folded into basic entity state where it belongs.
   local ent = ctx.ent
   if ent.name == "rail-signal" or ent.name == "rail-chain-signal" then
      if ent.status == defines.entity_status.not_connected_to_rail then
         ctx.message:fragment({ "fa.ent-info-rail-signal-not-connected" })
      elseif ent.status == defines.entity_status.cant_divide_segments then
         ctx.message:fragment({ "fa.ent-info-rail-signal-not-dividing" })
      else
         ctx.message:fragment(Rails.get_signal_state_info(ent))
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_rail_signal_heading(ctx)
   local ent = ctx.ent
   if ent.name == "rail-signal" or ent.name == "rail-chain-signal" then
      ctx.message:fragment({
         "fa.ent-info-rail-signal-heading",
         FaUtils.direction_lookup(FaUtils.rotate_180(ent.direction)),
      })
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_temperature(ctx)
   local ent = ctx.ent
   if ent.temperature ~= nil then ctx.message:fragment({ "fa.ent-info-temperature", math.floor(ent.temperature) }) end
end

-- NOTE: pushes multiple list items.
---@param ctx fa.info.EntInfoContext
local function ent_info_nuclear_neighbor_bonus(ctx)
   local ent = ctx.ent
   if ent.name == "nuclear-reactor" then
      if ent.temperature > 900 then ctx.message:list_item({ "fa.ent-info-nuclear-reactor-explodes" }) end
      if ent.energy > 0 then ctx.message:list_item({ "fa.ent-info-nuclear-reactor-consuming" }) end
      ctx.message:list_item({ "fa.ent-info-nuclear-reactor-neighbor-bonus", math.floor(ent.neighbour_bonus * 100) })
   end
end

-- Name of item for items on the ground.
---@param ctx fa.info.EntInfoContext
local function ent_info_item_on_ground(ctx)
   local ent = ctx.ent
   if ent.name == "item-on-ground" then
      ctx.message:fragment(Localising.get_localised_name_with_fallback(ent.stack.prototype))
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_heat_neighbors(ctx)
   local ent = ctx.ent
   if ent.prototype.heat_buffer_prototype ~= nil and next(ent.prototype.heat_buffer_prototype.connections) then
      local con_targets = BuildingTools.get_heat_connection_target_positions(ent.name, ent.position, ent.direction)
      local con_count = 0
      local con_counts = { 0, 0, 0, 0, 0, 0, 0, 0 }
      con_counts[dirs.north + 1] = 0
      con_counts[dirs.south + 1] = 0
      con_counts[dirs.east + 1] = 0
      con_counts[dirs.west + 1] = 0
      if #con_targets > 0 then
         for i, con_target_pos in ipairs(con_targets) do
            --For each heat connection target position, mark it and check for target ents
            rendering.draw_circle({
               color = { 1.0, 0.0, 0.5 },
               radius = 0.1,
               width = 2,
               target = con_target_pos,
               surface = ent.surface,
               time_to_live = 30,
            })
            local target_ents = ent.surface.find_entities_filtered({ position = con_target_pos })
            for j, target_ent in ipairs(target_ents) do
               if
                  target_ent.valid
                  and #BuildingTools.get_heat_connection_positions(
                        target_ent.name,
                        target_ent.position,
                        target_ent.direction
                     )
                     > 0
               then
                  for k, spot in
                     ipairs(
                        BuildingTools.get_heat_connection_positions(
                           target_ent.name,
                           target_ent.position,
                           target_ent.direction
                        )
                     )
                  do
                     --For each heat connection of the found target entity, mark it and check for a match
                     rendering.draw_circle({
                        color = { 1.0, 1.0, 0.5 },
                        radius = 0.2,
                        width = 2,
                        target = spot,
                        surface = ent.surface,
                        time_to_live = 30,
                     })
                     if util.distance(con_target_pos, spot) < 0.2 then
                        --For each match, mark it and count it
                        rendering.draw_circle({
                           color = { 0.5, 1.0, 0.5 },
                           radius = 0.3,
                           width = 2,
                           target = spot,
                           surface = ent.surface,
                           time_to_live = 30,
                        })
                        con_count = con_count + 1
                        local con_dir = FaUtils.get_direction_biased(con_target_pos, ent.position)
                        if con_count > 1 then ctx.message:fragment("and") end
                        ctx.message:fragment(FaUtils.direction_lookup(con_dir))
                     end
                  end
               end
            end
         end
      else
         ctx.message:fragment({ "fa.ent-info-heat-neighbors-none" })
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_underground_belt_connection(ctx)
   local ent = ctx.ent
   if ent.type == "underground-belt" then
      if ent.neighbours ~= nil then
         ctx.message:fragment({
            "fa.ent-info-underground-belt-connection",
            FaUtils.direction(ent.position, ent.neighbours.position),
            math.floor(FaUtils.distance(ent.position, ent.neighbours.position)) - 1,
         })
      else
         ctx.message:fragment({ "fa.ent-info-underground-belt-not-connected" })
      end
   end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_splitter_states(ctx)
   local ent = ctx.ent
   if ent.type == "splitter" then ctx.message:fragment(Belts.splitter_priority_info(ent)) end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_radar(ctx)
   local ent = ctx.ent
   if ent.type == "radar" then ctx.message:fragment(mod.radar_charting_info(ent)) end
end

---@param ctx fa.info.EntInfoContext
local function ent_info_spidertron(ctx)
   local ent = ctx.ent
   if ent.type == "spider-leg" then
      local spiders =
         ent.surface.find_entities_filtered({ position = ent.position, radius = 5, type = "spider-vehicle" })
      local spider = ent.surface.get_closest(ent.position, spiders)
      if not spider then return end
      ent = spider
   end

   if ent.type == "spider-vehicle" then
      local label = ent.entity_label
      if label ~= nil then ctx.message:fragment(label) end
   end
end

--Outputs basic entity info, usually called when the cursor selects an entity.
---@param ent LuaEntity
---@return LocalisedString
function mod.ent_info(pindex, ent, is_scanner)
   local p = game.get_player(pindex)
   assert(p)

   ---@type fa.info.EntInfoContext
   local ctx = {
      ent = ent,
      pindex = pindex,
      message = MessageBuilder.MessageBuilder.new(),
      is_scanner = is_scanner,
      player = p,
   }

   ctx.message:fragment(Localising.get_localised_name_with_fallback(ent))

   local function run_handler(handler)
      handler(ctx)
      ctx.message:list_item()
   end

   run_handler(ent_info_resource)
   run_handler(ent_info_ghost)
   run_handler(ent_info_rail)
   run_handler(ent_info_character)
   run_handler(ent_info_character_corpse)
   run_handler(ent_info_container)
   run_handler(ent_info_logistic_network)
   run_handler(ent_info_infinity_pipe)
   run_handler(ent_info_pipe_shape)
   run_handler(ent_info_fluid_transport)

   run_handler(ent_info_underground_belt_type)

   --Explain the recipe of a machine without pause and before the direction
   pcall(function()
      if ent.get_recipe() ~= nil then
         ctx.message:fragment("producing")
         ctx.message:list_item(Localising.get_recipe_from_name(ent.get_recipe().name, pindex))
      end
   end)
   --For furnaces (which produce only 1 output item type at a time) state how many output units are ready
   if ent.type == "furnace" then
      local output_stack = ent.get_output_inventory()[1]
      if output_stack and output_stack.valid_for_read then
         ctx.message:fragment(output_stack.count)
         ctx.message:fragment(output_stack.name)
         ctx.message:fragment("ready,")
         ctx.message:list_item()
      end
   end

   run_handler(ent_info_train_stop)
   run_handler(ent_info_train_owner)
   run_handler(ent_info_rail_signal_state)

   -- Leaving this for now: we can make it better in a few commits.
   if not is_scanner and ent.type == "mining-drill" and mod.cursor_is_at_mining_drill_output_part(pindex, ent) then
      ctx.message:list_item("drop chute")
   end

   run_handler(ent_info_facing)
   run_handler(ent_info_rail_signal_heading)

   run_handler(ent_info_gate_connection_point)
   run_handler(ent_info_marked_for_upgrade_deconstruct)
   run_handler(ent_info_power_production)
   run_handler(ent_info_underground_belt_connection)
   run_handler(ent_info_splitter_states)

   if ent.type == "transport-belt" then
      --Check whether items on the belt are stopped or moving (based on whether you can insert at the back of the belt)
      local left = ent.get_transport_line(1)
      local right = ent.get_transport_line(2)

      local left_dir = "left"
      local right_dir = "right"
      if ent.direction == dirs.north then
         left_dir = FaUtils.direction_lookup(dirs.west) or "left"
         right_dir = FaUtils.direction_lookup(dirs.east) or "right"
      elseif ent.direction == dirs.east then
         left_dir = FaUtils.direction_lookup(dirs.north) or "left"
         right_dir = FaUtils.direction_lookup(dirs.south) or "right"
      elseif ent.direction == dirs.south then
         left_dir = FaUtils.direction_lookup(dirs.east) or "left"
         right_dir = FaUtils.direction_lookup(dirs.west) or "right"
      elseif ent.direction == dirs.west then
         left_dir = FaUtils.direction_lookup(dirs.south) or "left"
         right_dir = FaUtils.direction_lookup(dirs.north) or "right"
      end

      local insert_spots_left = 0
      local insert_spots_right = 0
      if not left.can_insert_at_back() and right.can_insert_at_back() then
         ctx.message:fragment(left_dir)
         ctx.message:fragment("lane full,")
      elseif left.can_insert_at_back() and not right.can_insert_at_back() then
         ctx.message:fragment(",")
         ctx.message:fragment(right_dir)
         ctx.message:fragment("lane full,")
      elseif not left.can_insert_at_back() and not right.can_insert_at_back() then
         ctx.message:fragment(", both lanes full,")
      else
         ctx.message:fragment(", both lanes open,")
      end
   end

   if ent.name == "cargo-wagon" then
      --Explain contents
      local itemset = ent.get_inventory(defines.inventory.cargo_wagon).get_contents()
      local itemtable = {}
      for name, count in pairs(itemset) do
         table.insert(itemtable, { name = name, count = count })
      end
      table.sort(itemtable, function(k1, k2)
         return k1.count > k2.count
      end)
      if #itemtable == 0 then
         ctx.message:fragment("containing nothing")
      else
         ctx.message:fragment("containing " .. itemtable[1].name .. " times " .. itemtable[1].count .. ",")
         if #itemtable > 1 then
            ctx.message:fragment("and")
            ctx.message:fragment(itemtable[2].name)
            ctx.message:fragment("times")
            ctx.message:fragment(itemtable[2].count)
            ctx.message:fragment(",")
         end
         if #itemtable > 2 then ctx.message:fragment("and other items") end
      end
   end
   run_handler(ent_info_radar)

   if ent.type == "electric-pole" then
      --List connected wire neighbors
      ctx.message:fragment(Circuits.wire_neighbours_info(ent, false))
      --Count number of entities being supplied within supply area.
      local pos = ent.position
      local sdist = ent.prototype.get_supply_area_distance(ent.quality)
      local supply_area = { { pos.x - sdist, pos.y - sdist }, { pos.x + sdist, pos.y + sdist } }
      local supplied_ents = ent.surface.find_entities_filtered({ area = supply_area })
      local supplied_count = 0
      local producer_count = 0
      for i, ent2 in ipairs(supplied_ents) do
         if ent2.prototype.get_max_energy_usage(ent2.quality) > 0 and ent2.prototype.is_building then
            supplied_count = supplied_count + 1
         elseif ent2.prototype.get_max_energy_production(ent2.quality) > 0 and ent2.prototype.is_building then
            producer_count = producer_count + 1
         end
      end
      ctx.message:fragment("supplying")
      ctx.message:fragment(supplied_count)
      ctx.message:fragment("buildings,")
      if producer_count > 0 then
         ctx.message:fragment("drawing from")
         ctx.message:fragment(producer_count)
         ctx.message:fragment("buildings,")
      end
      ctx.message:fragment("Check status for power flow information.")
   end

   if ent.type == "power-switch" then
      if ent.power_switch_state == false then
         ctx.message:fragment("off,")
      elseif ent.power_switch_state == true then
         ctx.message:fragment("on,")
      end
      if (#ent.neighbours.red + #ent.neighbours.green) > 0 then run_handler("observes circuit condition,") end
      ctx.message:fragment(Circuits.wire_neighbours_info(ent, true))
   end

   if ent.name == "roboport" then
      local cell = ent.logistic_cell
      local network = ent.logistic_cell.logistic_network

      ctx.message:fragment("of network")
      ctx.message:fragment(BotLogistics.get_network_name(ent))
      ctx.message:fragment(",")
      ctx.message:fragment(BotLogistics.roboport_contents_info(ent))
   end
   run_handler(ent_info_spidertron)

   --Inserters: Explain held items, pickup and drop positions
   if ent.type == "inserter" then
      --Declare filters
      if ent.filter_slot_count > 0 then
         ctx.message:fragment("Filters for")
         local active_filter_count = 0
         for i = 1, ent.filter_slot_count, 1 do
            local filt = ent.get_filter(i)
            if filt ~= nil then
               active_filter_count = active_filter_count + 1
               if active_filter_count > 1 then filter_result = filter_result .. " and " end
               local local_name = Localising.get(prototypes.item[filt.name], pindex)
               if local_name == nil then local_name = tostring(filt.name) or " unknown item " end
               filter_result = filter_result .. local_name
            end
         end
         if active_filter_count > 0 then
            ctx.message:fragment(filter_result)
            run_handler(",")
         end
      end
      --Read held item
      if ent.held_stack ~= nil and ent.held_stack.valid_for_read and ent.held_stack.valid then
         ctx.message:fragment(", holding")
         ctx.message:fragment(ent.held_stack.name)
         if ent.held_stack.count > 1 then
            ctx.message:fragment("times")
            ctx.message:fragment(ent.held_stack.count)
         end
      end
      --Take note of long handed inserters
      local pickup_dist_dir = " at 1 " .. FaUtils.direction_lookup(ent.direction)
      local drop_dist_dir = " at 1 " .. FaUtils.direction_lookup(FaUtils.rotate_180(ent.direction))
      if ent.name == "long-handed-inserter" then
         pickup_dist_dir = " at 2 " .. FaUtils.direction_lookup(ent.direction)
         drop_dist_dir = " at 2 " .. FaUtils.direction_lookup(FaUtils.rotate_180(ent.direction))
      end
      --Read the pickup position
      local pickup = ent.pickup_target
      local pickup_name = nil
      if pickup ~= nil and pickup.valid then
         pickup_name = Localising.get(pickup, pindex)
      else
         pickup_name = "ground"
         local area_ents = ent.surface.find_entities_filtered({ position = ent.pickup_position })
         for i, area_ent in ipairs(area_ents) do
            if area_ent.type == "straight-rail" or area_ent.type == "curved-rail" then
               pickup_name = Localising.get(area_ent, pindex)
            end
         end
      end
      ctx.message:fragment("picks up from")
      ctx.message:fragment(pickup_name)
      ctx.message:fragment(pickup_dist_dir)
      --Read the drop position
      local drop = ent.drop_target
      local drop_name = nil
      if drop ~= nil and drop.valid then
         drop_name = Localising.get(drop, pindex)
      else
         drop_name = "ground"
         local drop_area_ents = ent.surface.find_entities_filtered({ position = ent.drop_position })
         for i, drop_area_ent in ipairs(drop_area_ents) do
            if drop_area_ent.type == "straight-rail" or drop_area_ent.type == "curved-rail" then
               drop_name = Localising.get(drop_area_ent, pindex)
            end
         end
      end
      ctx.message:fragment(", drops to")
      ctx.message:fragment(drop_name)
      ctx.message:fragment(drop_dist_dir)
   end

   if ent.type == "mining-drill" then
      local pos = ent.position
      local dict = ResourceMining.compute_resources_under_drill(ent)

      --Compute drop position
      local drop = ent.drop_target
      local drop_name = nil
      if drop ~= nil and drop.valid then
         drop_name = Localising.get(drop, pindex)
      else
         drop_name = "ground"
         local drop_area_ents = ent.surface.find_entities_filtered({ position = ent.drop_position })
         for i, drop_area_ent in ipairs(drop_area_ents) do
            if drop_area_ent.type == "straight-rail" or drop_area_ent.type == "curved-rail" then
               drop_name = Localising.get(drop_area_ent, pindex)
            end
         end
      end
      --Report info
      if drop ~= nil and drop.valid then
         ctx.message:fragment("outputs to")
         ctx.message:fragment(drop_name)
      end
      if ent.status == defines.entity_status.waiting_for_space_in_destination then
         ctx.message:fragment(", output full ")
      end
      if table_size(dict) > 0 then
         ctx.message:fragment(", Mining from")
         for i, amount in pairs(dict) do
            if i == "crude-oil" then
               ctx.message:fragment(i)
               ctx.message:fragment("times")
               ctx.message:fragment(tostring(math.floor(amount / 3000) / 10))
               ctx.message:fragment("per second")
            else
               ctx.message:fragment(i)
               ctx.message:fragment("times")
               ctx.message:fragment(FaUtils.simplify_large_number(amount))
            end
         end
      end
   end
   --Explain if no fuel
   if ent.prototype.burner_prototype ~= nil then
      if ent.energy == 0 and Driving.fuel_inventory_info(ent) == "Contains no fuel." then
         ctx.message:fragment(", Out of Fuel")
      end
   end

   run_handler(ent_info_important_statuses)
   run_handler(ent_info_power_status)

   run_handler(ent_info_accumulator)
   run_handler(ent_info_solar)
   run_handler(ent_info_rocket_silo)
   run_handler(ent_info_beacon_status)
   run_handler(ent_info_temperature)
   run_handler(ent_info_nuclear_neighbor_bonus)
   run_handler(ent_info_item_on_ground)
   run_handler(ent_info_heat_neighbors)

   run_handler(ent_info_constant_combinator)

   return ctx.message:build()
end

--Reports the charting range of a radar and how much of it has been charted so far.
function mod.radar_charting_info(radar)
   local charting_range = radar.prototype.max_distance_of_sector_revealed
   local count = 0
   local total = 0
   local centerx = math.floor(radar.position.x / 32)
   local centery = math.floor(radar.position.y / 32)
   for i = (centerx - charting_range), (centerx + charting_range), 1 do
      for j = (centery - charting_range), (centery + charting_range), 1 do
         if radar.force.is_chunk_charted(radar.surface, { i, j }) then count = count + 1 end
         total = total + 1
      end
   end
   local percent_charted = math.floor(count / total * 100)
   local result = percent_charted .. " percent charted, " .. charting_range * 32 .. " tiles charting range "
   return result
end

--Reads out the relative pollution level at the input position. The categories are based on data like map view shaders, water discoloration rates. For example, in default settings trees are damaged after pollution exceeds 60 and water is discolored after 90, and the deepest shader applies after 150.
function mod.read_pollution_level_at_position(pos, pindex)
   local p = game.get_player(pindex)
   local pol = p.surface.get_pollution(pos)
   local result = " pollution detected"
   if pol <= 0.1 then
      result = "No" .. result
   elseif pol < 10 then
      result = "Minimal" .. result
   elseif pol < 30 then
      result = "Low" .. result
   elseif pol < 60 then
      result = "Medium" .. result
   elseif pol < 100 then
      result = "High" .. result
   elseif pol < 150 then
      result = "Very high" .. result
   elseif pol < 250 then
      result = "Extremely high" .. result
   elseif pol >= 250 then
      result = "Maximal" .. result
   end
   printout(result, pindex)
end

--Reads out the distance and direction to the nearest damaged entity within 1000 tiles.
function mod.read_nearest_damaged_ent_info(pos, pindex)
   local p = game.get_player(pindex)
   --Scan for ents of your force
   local ents =
      p.surface.find_entities_filtered({ position = players[pindex].cursor_pos, radius = 1000, force = p.force })
   --Check for entities with health
   if ents == nil or #ents == 0 then
      printout("No damaged structures within 1000 tiles.", pindex)
      return
   end
   local at_least_one_has_damage = false
   local damaged_ents = {}
   for i, ent in ipairs(ents) do
      if ent.is_entity_with_health == true and ent.type ~= "character" and ent.get_health_ratio() < 1 then
         at_least_one_has_damage = true
         table.insert(damaged_ents, ent)
      end
   end
   if at_least_one_has_damage == false then
      printout("No damaged structures within 1000 tiles.", pindex)
      return
   end
   --Narrow by distance
   local closest = nil
   local min_dist = 1001
   for i, ent in ipairs(damaged_ents) do
      local dist = util.distance(pos, ent.position)
      if dist < min_dist then
         min_dist = dist
         closest = ent
         if min_dist < 2 then break end
      end
   end
   if closest == nil then
      printout("No damaged structures within 1000 tiles.", pindex)
      return
   else
      --Move cursor to closest
      players[pindex].cursor_pos = closest.position
      Graphics.draw_cursor_highlight(pindex, closest, nil, nil)

      --Report the result
      min_dist = math.floor(min_dist)
      local dir = FaUtils.get_direction_biased(closest.position, pos)
      local aligned_note = ""
      if FaUtils.is_direction_aligned(closest.position, pos) then aligned_note = "aligned " end
      local result = Localising.get(closest, pindex)
         .. "  damaged at "
         .. min_dist
         .. " "
         .. aligned_note
         .. FaUtils.direction_lookup(dir)
         .. ", cursor moved. "
      printout(result, pindex)
   end
end

--Report total produced and consumed in last minute, ten minutes,  hour,
--thousand hours for the selected item.  The selected item comes from the item
--in hand, the selected item in an inventory, or the crafting menu's current
--selection, in that order.  Since the latter two are disjunct, this can also be
--phrased as "in hand, otherwise examine menus".  Note that Factorio stores
--fluids and items in different places, and that the complicated branching below
--must also account for that.
--
-- Recipes may also produce items as well as fluids.  In vanilla, the example is
-- barrels.  We can't do the right thing in all cases, but in vanilla it happens
-- that the stats on barrels aren't super important and, additionally, there's a
-- separate recipe one can check for that.  Since this only outputs one entry
-- when selecting a recipe, we choose the first fluid if there is one, otherwise
-- the first item.  Ultimately for mods, we're going to need a GUI for it: there
-- are too many cases in the wild.
function mod.selected_item_production_stats_info(pindex)
   local p = game.get_player(pindex)
   local stats = p.force.get_item_production_statistics(p.surface)
   local item_stack = nil
   local recipe = nil
   local prototype = nil

   -- Try the cursor stack
   item_stack = p.cursor_stack
   if item_stack and item_stack.valid_for_read then prototype = item_stack.prototype end

   --Otherwise try to get it from the inventory slots
   if prototype == nil and players[pindex].menu == "inventory" then
      item_stack = players[pindex].inventory.lua_inventory[players[pindex].inventory.index]
      if item_stack and item_stack.valid_for_read then prototype = item_stack.prototype end
   elseif prototype == nil and players[pindex].menu == "guns" then
      item_stack = Equipment.guns_menu_get_selected_slot(pindex)
      if item_stack and item_stack.valid_for_read then prototype = item_stack.prototype end
   end

   --Try crafting menu.
   if prototype == nil and players[pindex].menu == "crafting" then
      recipe = players[pindex].crafting.lua_recipes[players[pindex].crafting.category][players[pindex].crafting.index]
      if recipe and recipe.valid and recipe.products then
         local first_item, first_fluid
         for i, prod in ipairs(recipe.products) do
            if first_item and first_fluid then
               break
            elseif prod.type == "item" then
               first_item = prod
            elseif prod.type == "fluid" then
               first_fluid = prod
            end
         end

         local chosen = first_fluid or first_item

         if not chosen then
            -- do nothing
         elseif chosen.type == "item" then
            --Select product item #1
            prototype = prototypes.item[chosen.name]
         elseif chosen.type == "fluid" then
            --Select product fluid #1
            stats = p.force.get_fluid_production_statistics(p.surface)
            prototype = prototypes.fluid[chosen.name]
         end
      end
   end

   -- For now, we give up.
   if not prototype then return "Error: No selected item or fluid" end

   -- We need both inputs and outputs. That's the same code, with one boolean
   -- changed.
   local get_stats = function(is_input)
      local name = prototype.name
      local category = is_input and "input" or "output"
      local interval = defines.flow_precision_index
      local last_minute = stats.get_flow_count({
         name = name,
         category = category,
         precision_index = interval.one_minute,
         count = true,
      })
      local last_10_minutes = stats.get_flow_count({
         name = name,
         category = category,
         precision_index = interval.ten_minutes,
         count = true,
      })
      local last_hour =
         stats.get_flow_count({ name = name, category = category, precision_index = interval.one_hour, count = true })
      local thousand_hours = stats.get_flow_count({
         name = name,
         category = category,
         precision_index = interval.one_thousand_hours,
         count = true,
      })
      last_minute = FaUtils.simplify_large_number(last_minute)
      last_10_minutes = FaUtils.simplify_large_number(last_10_minutes)
      last_hour = FaUtils.simplify_large_number(last_hour)
      thousand_hours = FaUtils.simplify_large_number(thousand_hours)
      return last_minute, last_10_minutes, last_hour, thousand_hours
   end

   local m1_in, m10_in, h1_in, h1000_in = get_stats(true)
   local m1_out, m10_out, h1_out, h1000_out = get_stats(false)

   return FaUtils.spacecat(
      Localising.get(prototype, pindex) .. ",",
      "Produced",
      m1_in,
      "last minute,",
      m10_in,
      "last ten min,",
      h1_in,
      "last hour,",
      h1000_in,
      "last thousand hours.",
      "Consumed",
      m1_out,
      "last minute,",
      m10_out,
      "last ten min,",
      h1_out,
      "last hour,",
      h1000_out,
      "last thousand hours."
   )
end

--Report the status of the selected entity as well as additional dynamic info depending on the entity type
function mod.read_selected_entity_status(pindex)
   local ent = game.get_player(pindex).selected
   if not ent then return end
   local stack = game.get_player(pindex).cursor_stack
   if players[pindex].in_menu then return end
   --Print out the status of a machine, if it exists.
   local result = { "" }
   local ent_status_id = ent.status
   local ent_status_text = ""
   local status_lookup = FaUtils.into_lookup(defines.entity_status)
   status_lookup[23] = "Full burnt result output" --weird exception
   if ent.name == "cargo-wagon" then
      --Instead of status, read contents
      table.insert(result, Trains.cargo_wagon_top_contents_info(ent))
   elseif ent.name == "fluid-wagon" then
      --Instead of status, read contents
      table.insert(result, Trains.fluid_contents_info(ent))
   elseif ent_status_id ~= nil then
      --Print status if it exists
      ent_status_text = status_lookup[ent_status_id]
      if ent_status_text == nil then
         print("Weird no entity status lookup" .. ent.name .. "-" .. ent.type .. "-" .. ent.status)
      end
      table.insert(result, { "entity-status." .. ent_status_text:gsub("_", "-") })
   else --There is no status
      --When there is no status, for entities with fuel inventories, read that out instead. This is typical for vehicles.
      if ent.get_fuel_inventory() ~= nil then
         table.insert(result, Driving.fuel_inventory_info(ent))
      elseif ent.type == "electric-pole" then
         --For electric poles with no power flow, report the nearest electric pole with a power flow.
         if Electrical.get_electricity_satisfaction(ent) > 0 then
            table.insert(
               result,
               Electrical.get_electricity_satisfaction(ent)
                  .. " percent network satisfaction, with "
                  .. Electrical.get_electricity_flow_info(ent)
            )
         else
            table.insert(result, "No power, " .. Electrical.report_nearest_supplied_electric_pole(ent))
         end
      else
         table.insert(result, "No status.")
      end
   end
   --For working or normal entities, give some extra info about specific entities.
   if #result == 1 then table.insert(result, "result error") end

   --For working or normal entities, give some extra info about specific entities in terms of speeds or bonuses.
   local list = defines.entity_status
   if
      ent.status ~= nil
      and ent.status ~= list.no_power
      and ent.status ~= list.no_power
      and ent.status ~= list.no_fuel
   then
      if ent.type == "inserter" then --items per minute based on rotation speed and the STATED hand capacity
         local cap = ent.force.inserter_stack_size_bonus + 1
         if ent.name == "bulk-inserter" then cap = ent.force.bulk_inserter_capacity_bonus end
         local rate = string.format(" %.1f ", cap * ent.prototype.get_inserter_rotation_speed(ent.quality) * 57.5)
         table.insert(result, ", can move " .. rate .. " items per second, with a hand capacity of " .. cap)
      end
      if ent.prototype ~= nil and ent.prototype.belt_speed ~= nil and ent.prototype.belt_speed > 0 then --items per minute by simple reading
         if ent.type == "splitter" then
            table.insert(
               result,
               ", can process " .. math.floor(ent.prototype.belt_speed * 480 * 2) .. " items per second"
            )
         else
            table.insert(result, ", can move " .. math.floor(ent.prototype.belt_speed * 480) .. " items per second")
         end
      end
      if ent.type == "assembling-machine" or ent.type == "furnace" then --Crafting cycles per minute based on recipe time and the STATED craft speed ; laterdo maybe extend this to all "crafting machine" types?
         local progress = ent.crafting_progress
         local speed = ent.crafting_speed
         local recipe_time = 0
         local cycles = 0 -- crafting cycles completed per minute for this recipe
         if ent.get_recipe() ~= nil and ent.get_recipe().valid then
            recipe_time = ent.get_recipe().energy
            cycles = 60 / recipe_time * speed
         end
         local cycles_string = string.format(" %.2f ", cycles)
         if cycles == math.floor(cycles) then cycles_string = string.format(" %d ", cycles) end
         local speed_string = string.format(" %.2f ", speed)
         if speed == math.floor(speed) then speed_string = string.format(" %d ", cycles) end
         if cycles < 10 then --more than 6 seconds to craft
            table.insert(result, ", recipe progress " .. math.floor(progress * 100) .. " percent ")
         end
         if cycles > 0 then table.insert(result, ", can complete " .. cycles_string .. " recipe cycles per minute ") end
         table.insert(
            result,
            ", with a crafting speed of "
               .. speed_string
               .. ", at "
               .. math.floor(100 * (1 + ent.speed_bonus) + 0.5)
               .. " percent "
         )
         if ent.productivity_bonus ~= 0 then
            table.insert(
               result,
               ", with productivity bonus " .. math.floor(100 * (0 + ent.productivity_bonus) + 0.5) .. " percent "
            )
         end
      elseif ent.type == "mining-drill" then
         table.insert(
            result,
            ", producing "
               .. string.format(" %.2f ", ent.prototype.mining_speed * 60 * (1 + ent.speed_bonus))
               .. " items per minute "
         )
         if ent.speed_bonus ~= 0 then
            table.insert(result, ", with speed " .. math.floor(100 * (1 + ent.speed_bonus) + 0.5) .. " percent ")
         end
         if ent.productivity_bonus ~= 0 then
            table.insert(
               result,
               ", with productivity bonus " .. math.floor(100 * (0 + ent.productivity_bonus) + 0.5) .. " percent "
            )
         end
      elseif ent.name == "lab" then
         if ent.speed_bonus ~= 0 then
            table.insert(
               result,
               ", with speed "
                  .. math.floor(
                     100
                           * (1 + ent.force.laboratory_speed_modifier * (1 + (ent.speed_bonus - ent.force.laboratory_speed_modifier)))
                        + 0.5
                  )
                  .. " percent "
            ) --laterdo fix bug**
            --game.get_player(pindex).print(result)
         end
         if ent.productivity_bonus ~= 0 then
            table.insert(
               result,
               ", with productivity bonus "
                  .. math.floor(100 * (0 + ent.productivity_bonus + ent.force.laboratory_productivity_bonus) + 0.5)
                  .. " percent "
            )
         end
      else --All other entities with the an applicable status
         if ent.speed_bonus ~= 0 then
            table.insert(result, ", with speed " .. math.floor(100 * (1 + ent.speed_bonus) + 0.5) .. " percent ")
         end
         if ent.productivity_bonus ~= 0 then
            table.insert(
               result,
               ", with productivity bonus " .. math.floor(100 * (0 + ent.productivity_bonus) + 0.5) .. " percent "
            )
         end
      end
      --laterdo maybe pump speed?
   end

   --Entity power usage
   local power_rate = (1 + ent.consumption_bonus)
   local drain = ent.electric_drain
   if drain ~= nil then
      drain = drain * 60
   else
      drain = 0
   end
   local uses_energy = false
   if drain > 0 or (ent.prototype ~= nil and ent.prototype.get_max_energy_usage(ent.quality) > 0) then
      uses_energy = true
   end
   if ent.status ~= nil and uses_energy and ent.status == list.working then
      table.insert(
         result,
         ", consuming "
            .. Electrical.get_power_string(ent.prototype.get_max_energy_usage(ent.quality) * 60 * power_rate + drain)
      )
   elseif ent.status ~= nil and uses_energy and ent.status == list.no_power or ent.status == list.low_power then
      table.insert(
         result,
         ", consuming less than "
            .. Electrical.get_power_string(ent.prototype.get_max_energy(ent.quality) * 60 * power_rate + drain)
      )
   elseif
      ent.status ~= nil and uses_energy
      or (
         ent.prototype ~= nil
         and ent.prototype.get_max_energy_usage(ent.quality) ~= nil
         and ent.prototype.get_max_energy_usage(ent.quality) > 0
      )
   then
      table.insert(result, ", idle and consuming " .. Electrical.get_power_string(drain))
   end
   if uses_energy and ent.prototype.burner_prototype ~= nil then table.insert(result, " as burner fuel ") end

   --Entity Health
   if ent.is_entity_with_health and ent.get_health_ratio() == 1 then
      table.insert(result, { "fa.full-health" })
   elseif ent.is_entity_with_health then
      table.insert(result, { "fa.percent-health", math.floor(ent.get_health_ratio() * 100) })
   end

   -- Report nearest rail intersection position -- laterdo find better keybind
   if ent.name == "straight-rail" then
      local nearest, dist = Rails.find_nearest_intersection(ent, pindex)
      if nearest == nil then
         table.insert(result, ", no rail intersections within " .. dist .. " tiles ")
      else
         table.insert(
            result,
            ", nearest rail intersection at "
               .. dist
               .. " "
               .. FaUtils.direction_lookup(FaUtils.get_direction_biased(nearest.position, ent.position))
         )
      end
   end

   --Spawners: Report evolution factor
   if ent.type == "unit-spawner" then
      table.insert(
         result,
         ", evolution factor " .. math.floor(1000 * ent.force.get_evolution_factor(ent.surface)) / 1000
      )
   end

   return result
end

function mod.cursor_is_at_mining_drill_output_part(pindex, ent)
   local point = ResourceMining.get_solid_output_coords(ent)
   if not point then return false end
   print("Point was ", serpent.line(point), serpent.line(players[pindex].cursor_pos))
   return util.distance(point.position, players[pindex].cursor_pos) < 0.6
end

--Returns an info string about the entities and tiles found within an area scan done by an enlarged cursor.
---@param pindex number
---@param left_top fa.Point
---@param right_bottom fa.Point
---@return LocalisedString
function mod.area_scan_summary_info(pindex, left_top, right_bottom)
   local result = {}

   local chunk_lt_x = math.floor(left_top.x / 32)
   local chunk_lt_y = math.floor(left_top.y / 32)
   local chunk_rb_x = math.ceil(right_bottom.x / 32)
   local chunk_rb_y = math.ceil(right_bottom.y / 32)

   local player = assert(game.get_player(pindex))
   ---@cast player LuaPlayer
   local surf = player.surface

   local generated_chunk_count = 0
   local total_chunks_covered = 0
   for cx = chunk_lt_x, chunk_rb_x do
      for cy = chunk_lt_y, chunk_rb_y do
         if surf.is_chunk_generated({ cx, cy }) then generated_chunk_count = generated_chunk_count + 1 end
         total_chunks_covered = total_chunks_covered + 1
      end
   end
   if total_chunks_covered > 0 and generated_chunk_count < 1 then
      return "Charted 0%, you need to chart this area by approaching it or using a radar."
   elseif total_chunks_covered > 0 and generated_chunk_count < total_chunks_covered then
      table.insert(result, "Charted")
      table.insert(result, math.floor(generated_chunk_count / total_chunks_covered * 100) .. "%,")
   end

   ---@type { name: string, count: string, category: string }[]
   local counts = {}

   local covered_area = (right_bottom.x - left_top.x) * (right_bottom.y - left_top.y)
   assert(covered_area > 0)

   local water_count = surf.count_tiles_filtered({
      name = { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud", "water-wube" },
      area = { left_top, right_bottom },
   })

   if water_count > 0 then table.insert(counts, { name = "water", count = water_count, category = "resource" }) end

   local path_count = surf.count_tiles_filtered({ name = "stone-path", area = { left_top, right_bottom } })
   if path_count > 0 then
      table.insert(counts, { name = "stone-brick-path", count = path_count, category = "flooring" })
   end

   local concrete_count = surf.count_tiles_filtered({
      name = { "concrete", "hazard-concrete-left", "hazard-concrete-right" },
      area = { left_top, right_bottom },
   })
   if concrete_count > 0 then
      table.insert(counts, { name = "concrete", count = concrete_count, category = "flooring" })
   end

   local refined_concrete_count = surf.count_tiles_filtered({
      name = { "refined-concrete", "refined-hazard-concrete-left", "refined-hazard-concrete-right" },
      area = { left_top, right_bottom },
   })
   if refined_concrete_count > 0 then
      table.insert(counts, { name = "refined-concrete", count = refined_concrete_count, category = "flooring" })
   end

   for _, res_proto in pairs(prototypes.entity) do
      if res_proto.type == "resource" then
         local res_count = surf.count_entities_filtered({ name = res_proto.name, area = { left_top, right_bottom } })
         table.insert(counts, { name = res_proto.name, count = res_count, category = "resource" })
      end
   end

   local tree_count = surf.count_entities_filtered({ type = "tree", area = { left_top, right_bottom } })
   if tree_count > 0 then table.insert(counts, { name = "trees", count = tree_count, category = "resource" }) end

   local others = surf.find_entities_filtered({
      type = { "resource", "tree" },
      area = { left_top, right_bottom },
      invert = true,
   })

   local others_by_proto = {}
   for _, ent in pairs(others) do
      if ent.valid then others_by_proto[ent.name] = (others_by_proto[ent.name] or 0) + 1 end
   end

   for n, c in pairs(others_by_proto) do
      if c > 0 then table.insert(counts, { name = n, count = c, category = "other" }) end
   end

   table.sort(counts, function(k1, k2)
      return k1.count > k2.count
   end)

   local count_total = 0
   for _, i in pairs(counts) do
      count_total = count_total + i.count
   end

   -- Spacecat can't help us here. Why?  We can't have spaces between words and
   -- commas, e.g. "iron ," is wrong.  The real problem isn't spacecat, it's
   -- that this should be localised and the commas should be baked into the
   -- localised strings, then those get fed to spacecat.
   local contains_list = {}
   for _, entry in pairs(counts) do
      if entry.count == 0 then break end

      local fragment = ""
      fragment = fragment .. tostring(entry.count) .. " " .. entry.name
      if entry.category == "resource" or entry.category == "flooring" then
         fragment = fragment .. " " .. math.floor(entry.count / covered_area * 100) .. " " .. "percent"
      end

      table.insert(contains_list, fragment .. ",")
   end

   if next(contains_list) then
      table.insert(result, "Area contains")
      for _, f in pairs(contains_list) do
         table.insert(result, f)
      end
      table.insert(result, "total space occupied")
      table.insert(result, math.floor(count_total / covered_area * 100))
      table.insert(result, "percent")
   else
      table.insert(result, "Area empty")
   end

   return FaUtils.localise_cat_table(result)
end

return mod
