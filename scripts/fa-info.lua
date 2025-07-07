--[[
Announcement of information.

This file is used to build up the strings used for entity statuses and cursor
movement, which are honestlyh most of the mod's "magic".  It consists of
functions which either produce strings about entities or produce joined up
strings to send to the player.  Since the applicability conditions for each
announcement are complex and we would prefer not to centralize them, we do this
by passing around a Speech and some context as to what's going on.

The localisation is in entity-info.cfg.  We do not distinguish between cursor
level information and status level information in the localisation, because it
is not necessarily the case that things fall into one or the other, or that we
won't change our mind later or maybe even go as far as adding settings for this
stuff.
]]
local dirs = defines.direction
local util = require("util")
local Filters = require("scripts.filters")
local UiRouter = require("scripts.ui.router")

local BuildingTools = require("scripts.building-tools")
local Circuits = require("scripts.circuit-networks")
local Consts = require("scripts.consts")
local Driving = require("scripts.driving")
local Electrical = require("scripts.electrical")
local Equipment = require("scripts.equipment")
local FaUtils = require("scripts.fa-utils")
local F = require("scripts.field-ref")
local Fluids = require("scripts.fluids")
local Geometry = require("scripts.geometry")
local Graphics = require("scripts.graphics")
local Heat = require("scripts.heat")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local NetworkShape = require("scripts.network-shape")
local Rails = require("scripts.rails")
local ResourceMining = require("scripts.resource-mining")
local TH = require("scripts.table-helpers")
local Trains = require("scripts.trains")
local TransportBelts = require("scripts.transport-belts")
local Viewpoint = require("scripts.viewpoint")
local Wires = require("scripts.wires")
local BotLogistics = require("scripts.worker-robots")

local mod = {}

---@class fa.Info.EntInfoContext
---@field message fa.Speech
---@field is_scanner boolean
---@field ent LuaEntity
---@field pindex number
---@field player LuaPlayer
---@field cursor_pos fa.Point Not necessarily the player's actual cursor.

---@class fa.Info.EntStatusContext
---@field message fa.Speech
---@field ent LuaEntity
---@field pindex number
---@field player LuaPlayer
---@field power_rate number
---@field drain number
---@field uses_energy boolean

-- Present a list like iron plate x1, transport belt legendary x2, ...
---@param list ({ name: string|LuaItemPrototype, quality: string|LuaQualityPrototype|nil, count: number})[]
---@param truncate number?
---@param protos table<string, LuaItemPrototype | LuaFluidPrototype>?
local function present_list(list, truncate, protos)
   local contents = TH.rollup2(list, F.name().get, function(i)
      return i.quality or "normal"
   end, F.count().get)

   -- Now that everything is together we must unroll it again, then sort.
   ---@type ({ count: number, name: string, quality: LuaQualityPrototype })[]
   local final = {}

   for name, quals in pairs(contents) do
      for qual, count in pairs(quals) do
         table.insert(final, { count = count, name = name, quality = prototypes.quality[qual] })
      end
   end

   -- Careful: this is actually a reverse sort.
   table.sort(final, function(a, b)
      if a.count == b.count and a.name == b.name then
         return a.quality.level > b.quality.level
      elseif a.count == b.count then
         return a.name > b.name
      else
         return a.count > b.count
      end
   end)

   local endpoint = #final
   local extra = false
   if truncate then
      extra = truncate < endpoint
      endpoint = math.min(endpoint, truncate)
   end

   if not next(final) then return { "fa.ent-info-inventory-empty" } end

   local entries = {}
   for i = 1, endpoint do
      local e = final[i]

      table.insert(
         entries,
         Localising.localise_item_or_fluid(
            { name = e.name, quality = e.quality, count = e.count },
            protos or prototypes.item
         )
      )
   end

   if extra then
      table.insert(entries, Localising.localise_item({ name = Localising.ITEM_OTHER, count = #final - truncate }))
   end
   local joined = FaUtils.localise_cat_table(entries, ", ")

   return { "fa.ent-info-inventory-presentation", joined }
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_facing(ctx)
   local ent = ctx.ent
   local effective_direction
   -- Set in the case where we detect symmetry.
   local secondary_effective_direction

   if
      (ent.prototype.is_building and ent.supports_direction)
      or (ent.type == "entity-ghost" and ent.ghost_prototype.is_building and ent.ghost_prototype.supports_direction)
   then
      effective_direction = FaUtils.direction_lookup(ent.direction)
      if ent.type == "generator" then
         --For steam engines and steam turbines, north = south and east = west
         secondary_effective_direction = FaUtils.direction_lookup(FaUtils.rotate_180(ent.direction))
      end
   elseif ent.type == "locomotive" or ent.type == "car" then
      effective_direction = (FaUtils.get_heading_info(ent))
   end

   if effective_direction and secondary_effective_direction then
      ctx.message:fragment({ "fa.ent-info-facing-symmetric", effective_direction, secondary_effective_direction })
   elseif effective_direction then
      ctx.message:fragment({ "fa.ent-info-facing", effective_direction })
   end
end

-- Announces if the entity is marked for upgrading or deconstruction. Folded
-- into one function, as these are mutually exclusive states as far as we know.
---@param ctx fa.Info.EntInfoContext
local function ent_info_marked_for_upgrade_deconstruct(ctx)
   if ctx.ent.to_be_deconstructed() then
      ctx.message:fragment({ "fa.ent-info-marked-for-deconstruction" })
   elseif ctx.ent.to_be_upgraded() then
      ctx.message:fragment({ "fa.ent-info-marked-for-upgrading" })
   end

   -- Otherwise it is not marked.
end

-- If this entity generates electricity, tell the player how much.
---@param ctx fa.Info.EntInfoContext
local function ent_info_power_production(ctx)
   local ent = ctx.ent
   if ctx.ent.prototype.type == "generator" then
      local power1 = ent.energy_generated_last_tick * 60
      local power2 = ent.prototype.get_max_energy_production(ent.quality) * 60
      local power_load_pct = math.ceil(power1 / power2 * 100)
      if power2 ~= nil then
         ctx.message:fragment({ "fa.ent-info-generator-load", power_load_pct }):fragment({
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
---@param ctx fa.Info.EntInfoContext
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
      elseif status == defines.entity_status.pipeline_overextended then
         ctx.message:fragment({ "entity-status.pipeline-overextended" })
      end
   end
end

-- "not connected to power" etc.
---@param ctx fa.Info.EntInfoContext
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
---@param ctx fa.Info.EntInfoContext
local function ent_info_gate_connection_point(ctx)
   if ctx.ent.type == "wall" and ctx.ent.get_control_behavior() ~= nil then
      ctx.message:fragment({ "fa.ent-info-gate-circuit-network-connection" })
   end
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_accumulator(ctx)
   local ent = ctx.ent
   if ent.type == "accumulator" then
      local level = math.ceil(ent.energy / ent.electric_buffer_size * 100) --In percentage
      local charge = math.ceil(ent.energy)
      ctx.message:fragment({ "fa.ent-info-accumulator-charge", level, Electrical.get_power_string(charge) })
   end
end

---@param ctx fa.Info.EntInfoContext
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

---@param ctx fa.Info.EntInfoContext
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

---@param ctx fa.Info.EntInfoContext
local function ent_info_beacon_status(ctx)
   local ent = ctx.ent
   if ent.name == "beacon" then
      local modules = ent.get_module_inventory()
      if not modules then return end
      local presenting = present_list(modules.get_contents())
      if presenting then ctx.message:fragment(presenting) end
   end
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_constant_combinator(ctx)
   local ent = ctx.ent
   if ent.type == "constant-combinator" then
      ctx.message:fragment(Circuits.constant_combinator_signals_info(ent, ctx.pindex))
   end
end

---@param ctx fa.Info.EntInfoContext
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

---@param ctx fa.Info.EntInfoContext
local function ent_info_rail(ctx)
   local ent = ctx.ent
   -- TODO: really we shouldn't need pindex here, but for now rails aren't
   -- localised properly.
   if ent.name == "straight-rail" or ent.name == "curved-rail" then return Rails.rail_ent_info(ctx.pindex, ent) end
end

---@param ctx fa.Info.EntInfoContext
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
      elseif ctx.pindex ~= nil then
         ctx.message:fragment(tostring(ctx.pindex))
      end
   end
end

---@param ctx fa.Info.EntInfoContext
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

---@param ctx fa.Info.EntInfoContext
local function ent_info_container(ctx)
   local ent = ctx.ent
   if ent.type == "container" or ent.type == "logistic-container" or ent.type == "infinity-container" then
      --Chests etc: Report the most common item and say "and other items" if there are other types.
      local inv = ent.get_inventory(defines.inventory.chest)
      assert(inv)
      local presenting = present_list(inv.get_contents(), 3)
      if presenting then ctx.message:fragment(presenting) end
   end
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_fluid_contents(ctx)
   -- Crafting machines are special, and this is folded into their readiness
   -- status.
   if Consts.CRAFTING_MACHINES[ctx.ent.type] then return end

   -- If it can't hold fluids, no point.
   if #ctx.ent.fluidbox == 0 then return end

   local fluids = ctx.ent.get_fluid_contents()

   if not next(fluids) then
      ctx.message:fragment({ "fa.ent-info-inventory-empty" })
      return
   end

   local unrolled = {}
   for f, c in pairs(fluids) do
      -- Round fluid amounts to 1 decimal place to avoid excessive decimal display
      local rounded_count = math.floor(c * 10 + 0.5) / 10
      table.insert(unrolled, { name = f, count = rounded_count })
   end

   ctx.message:fragment(present_list(unrolled, nil, prototypes.fluid))
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_logistic_network(ctx)
   local ent = ctx.ent
   -- very unclear: isn't this just entity.logistic_network?  To revisit after
   -- this file is refactored.
   if ent.type == "logistic-container" then
      local network = ent.surface.find_logistic_network_by_position(ent.position, ent.force)
      if network == nil then
         local nearest_roboport = FaUtils.find_nearest_roboport(ent.surface, ent.position, 5000)
         if nearest_roboport == nil then
            ctx.message:fragment({ "fa.ent-info-logistic-not-in-network", 5000 })
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

---@param ctx fa.Info.EntInfoContext
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

---@param ctx fa.Info.EntInfoContext
local function ent_info_belt_shape(ctx)
   local e = ctx.ent
   local t = e.type

   -- Only belts and underground belts can  have shapes, at least for right now.
   if t ~= "transport-belt" and t ~= "underground-belt" then return end

   local node = TransportBelts.Node.create(e)
   local shape_info = node:get_shape_info()

   if shape_info.corner then
      local key
      local dir

      if shape_info.corner == TransportBelts.CORNER_KINDS.LEFT then
         key = "fa.ent-info-belt-shape-left"
         -- we say "from the", so we aren't undoing it and counterclockwise for
         -- left is right.
         dir = Geometry.dir_counterclockwise_90(e.direction)
      elseif shape_info.corner == TransportBelts.CORNER_KINDS.RIGHT then
         key = "fa.ent-info-belt-shape-right"
         dir = Geometry.dir_clockwise_90(e.direction)
      end

      ctx.message:fragment({ key, FaUtils.direction_lookup(dir) })
   end

   -- Sideloads: none, left, right, or both.
   if not shape_info.merge and (shape_info.left_sideload or shape_info.right_sideload) then
      if not shape_info.right_sideload then
         -- No right sideload, must be left.
         ctx.message:fragment({ "fa.ent-info-belt-shape-left-sideload" })
      elseif not shape_info.left_sideload then
         ctx.message:fragment({ "fa.ent-info-belt-shape-right-sideload" })
      else
         ctx.message:fragment({ "fa.ent-info-belt-shape-double-sideload" })
      end
   elseif shape_info.merge then
      ctx.message:fragment({ "fa.ent-info-belt-shape-merge" })
   end

   -- First the "primary shape" if you will: corners, pouring, etc.
   if not shape_info.has_input and not shape_info.has_output then
      ctx.message:fragment({ "fa.ent-info-belt-shape-unit" })
   elseif shape_info.is_pouring then
      ctx.message:fragment({ "fa.ent-info-belt-shape-pouring" })
   elseif shape_info.has_input and not shape_info.has_output then
      ctx.message:fragment({ "fa.ent-info-belt-shape-stop" })
   elseif shape_info.has_output and not shape_info.has_input then
      ctx.message:fragment({ "fa.ent-info-belt-shape-start" })
   end
end

---@param ctx fa.Info.EntInfoContext
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

      -- We must be careful.  Pipe shapes do not account for other kinds of connection, so we must compare with the
      -- expected count as well. Otherwise we will say that a pipe is both connected and not connected at the same time.

      -- This is just a boring if table which appends fragments.  no special logic here.
      if s == NetworkShape.SHAPE.END and conn_count == 1 then
         ctx.message:fragment({ "fa.ent-info-pipe-end", FaUtils.direction_lookup(FaUtils.rotate_180(d)) })
      elseif s == NetworkShape.SHAPE.ALONE and conn_count == 0 then
         ctx.message:fragment({ "fa.ent-info-pipe-alone" })
      elseif s == NetworkShape.SHAPE.STRAIGHT and conn_count == 2 then
         local key = d == defines.direction.north and "fa.ent-info-pipe-vertical" or "fa.ent-info-pipe-horizontal"
         ctx.message:fragment({ key })
      elseif s == NetworkShape.SHAPE.CORNER and conn_count == 2 then
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
      elseif s == NetworkShape.SHAPE.CROSS and conn_count == 4 then
         ctx.message:fragment({ "fa.ent-info-pipe-cross" })
      elseif s == NetworkShape.SHAPE.T then
         local key = "fa.ent-info-pipe-t-vertical"
         if d == defines.direction.north or d == defines.direction.south then key = "fa.ent-info-pipe-t-horizontal" end
         ctx.message:fragment({ key, FaUtils.direction_lookup(FaUtils.rotate_180(d)) })
      end
   end
end

---@param ctx fa.Info.EntInfoContext
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

---@param ctx fa.Info.EntInfoContext
local function ent_info_train_stop(ctx)
   local ent = ctx.ent
   if ent.name == "train-stop" then
      local limit = ent.trains_limit or 0
      ctx.message:fragment({ "fa.ent-info-train-stop", ent.backer_name, limit })
   end
end

-- Returns train name announcement with id fallback.
---@param ctx fa.Info.EntInfoContext
local function ent_info_train_owner(ctx)
   local ent = ctx.ent
   if ent.name == "locomotive" or ent.name == "cargo-wagon" or ent.name == "fluid-wagon" then
      ctx.message:fragment({ "fa.ent-info-of-train", Trains.get_train_name(ent.train) })
   end
end

---@param ctx fa.Info.EntInfoContext
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

---@param ctx fa.Info.EntInfoContext
local function ent_info_rail_signal_heading(ctx)
   local ent = ctx.ent
   if ent.name == "rail-signal" or ent.name == "rail-chain-signal" then
      ctx.message:fragment({
         "fa.ent-info-rail-signal-heading",
         FaUtils.direction_lookup(FaUtils.rotate_180(ent.direction)),
      })
   end
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_temperature(ctx)
   local ent = ctx.ent
   if ent.temperature ~= nil then ctx.message:fragment({ "fa.ent-info-temperature", math.floor(ent.temperature) }) end
end

-- NOTE: pushes multiple list items.
---@param ctx fa.Info.EntInfoContext
local function ent_info_nuclear_neighbor_bonus(ctx)
   local ent = ctx.ent
   if ent.name == "nuclear-reactor" then
      if ent.temperature > 900 then ctx.message:list_item({ "fa.ent-info-nuclear-reactor-explodes" }) end
      if ent.energy > 0 then ctx.message:list_item({ "fa.ent-info-nuclear-reactor-consuming" }) end
      ctx.message:list_item({ "fa.ent-info-nuclear-reactor-neighbor-bonus", math.floor(ent.neighbour_bonus * 100) })
   end
end

-- Name of item for items on the ground.
---@param ctx fa.Info.EntInfoContext
local function ent_info_item_on_ground(ctx)
   local ent = ctx.ent
   if ent.name == "item-on-ground" then
      ctx.message:fragment(Localising.get_localised_name_with_fallback(ent.stack.prototype))
   end
end

local dir_names = {
   [defines.direction.north] = "north",
   [defines.direction.east] = "east",
   [defines.direction.south] = "south",
   [defines.direction.west] = "west",
}

---@param ctx fa.Info.EntInfoContext
local function ent_info_heat_pipe_shape(ctx)
   if ctx.ent.type == "heat-pipe" then
      local shape_info = Heat.get_pipe_shape(ctx.ent)
      local s, d = shape_info.shape, shape_info.direction
      local d_str = FaUtils.direction_lookup(d)
      local conn_count = Heat.get_total_heat_connections(ctx.ent)

      -- We must be careful.  Pipe shapes do not account for other kinds of connection, so we must compare with the
      -- expected count as well. Otherwise we will say that a pipe is both connected and not connected at the same time.

      -- This is just a boring if table which appends fragments.  no special logic here.
      if s == NetworkShape.SHAPE.END and conn_count == 1 then
         ctx.message:fragment({ "fa.ent-info-pipe-end", FaUtils.direction_lookup(FaUtils.rotate_180(d)) })
      elseif s == NetworkShape.SHAPE.ALONE and conn_count == 0 then
         ctx.message:fragment({ "fa.ent-info-pipe-alone" })
      elseif s == NetworkShape.SHAPE.STRAIGHT and conn_count == 2 then
         local key = d == defines.direction.north and "fa.ent-info-pipe-vertical" or "fa.ent-info-pipe-horizontal"
         ctx.message:fragment({ key })
      elseif s == NetworkShape.SHAPE.CORNER and conn_count == 2 then
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
      elseif s == NetworkShape.SHAPE.CROSS and conn_count == 4 then
         ctx.message:fragment({ "fa.ent-info-pipe-cross" })
      elseif s == NetworkShape.SHAPE.T then
         local key = "fa.ent-info-pipe-t-vertical"
         if d == defines.direction.north or d == defines.direction.south then key = "fa.ent-info-pipe-t-horizontal" end
         ctx.message:fragment({ key, FaUtils.direction_lookup(FaUtils.rotate_180(d)) })
      end
   end
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_render_heat_ports(ctx)
   local ent = ctx.ent
   if
      not (
         ent
         and ent.valid
         and ent.prototype.heat_buffer_prototype
         and next(ent.prototype.heat_buffer_prototype.connections)
      )
   then
      return
   end

   local connection_points = Heat.get_connection_points(ent)
   local found_dirs = {}

   for _, conn in ipairs(connection_points) do
      -- Draw the port itself (blue)
      rendering.draw_circle({
         color = { 0.5, 0.5, 1.0 },
         radius = 0.15,
         width = 2,
         target = conn.position,
         surface = ent.surface,
         time_to_live = 30,
      })

      -- Now, draw only the first connected neighbor per direction (green)
      local neighbors = Heat.get_connected_neighbors(ent, conn, false)
      for _, neighbor_info in ipairs(neighbors) do
         local n_ent = neighbor_info.entity
         local n_cp = neighbor_info.connection_point

         local dir
         if conn.direction then
            dir = conn.direction
         else
            dir = FaUtils.get_direction_biased(n_cp.position, ent.position)
         end

         if not found_dirs[dir] then
            found_dirs[dir] = true
            rendering.draw_circle({
               color = { 0.8, 1.0, 0.5 },
               radius = 0.18,
               width = 2,
               target = n_cp.position,
               surface = n_ent.surface,
               time_to_live = 30,
            })
         end
      end
   end
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_heat_neighbors(ctx)
   local ent = ctx.ent
   if
      not (
         ent
         and ent.valid
         and ent.prototype.heat_buffer_prototype
         and next(ent.prototype.heat_buffer_prototype.connections)
      )
   then
      return
   end

   local connection_points = Heat.get_connection_points(ent)
   if not connection_points or #connection_points == 0 then return end

   -- Gather only those ports the cursor is "on" (distance threshold)
   local relevant_ports = {}
   for _, conn in ipairs(connection_points) do
      if FaUtils.distance(conn.position, ctx.cursor_pos) < 0.5 then table.insert(relevant_ports, conn) end
   end
   if #relevant_ports == 0 then return end

   -- Gather directions of all relevant ports
   local dirs = {}
   for _, conn in ipairs(relevant_ports) do
      local dir = conn.direction
      if dir == nil then dir = FaUtils.get_direction_biased(conn.position, ent.position) end
      table.insert(dirs, dir or 16)
   end

   -- Localize heat port directions, passing raw direction constants
   local function localise_heat_ports(dirs)
      local n = #dirs
      if n == 0 then
         return nil
      elseif n == 1 then
         return { "fa.ent-info-heat-port-1", FaUtils.direction_lookup(dirs[1]) }
      elseif n == 2 then
         return { "fa.ent-info-heat-port-2", FaUtils.direction_lookup(dirs[1]), FaUtils.direction_lookup(dirs[2]) }
      elseif n == 3 then
         return {
            "fa.ent-info-heat-port-3",
            FaUtils.direction_lookup(dirs[1]),
            FaUtils.direction_lookup(dirs[2]),
            FaUtils.direction_lookup(dirs[3]),
         }
      elseif n == 4 then
         return {
            "fa.ent-info-heat-port-4",
            FaUtils.direction_lookup(dirs[1]),
            FaUtils.direction_lookup(dirs[2]),
            FaUtils.direction_lookup(dirs[3]),
            FaUtils.direction_lookup(dirs[4]),
         }
      end
   end

   if ent.type ~= "heat-pipe" then ctx.message:fragment(localise_heat_ports(dirs)) end

   -- Gather connections: name + raw direction for each neighbor
   local all_conn_info = {}
   for _, conn in ipairs(relevant_ports) do
      local neighbors = Heat.get_connected_neighbors(ent, conn, false)
      for _, neighbor_info in ipairs(neighbors) do
         local n_ent = neighbor_info.entity
         if n_ent and n_ent.valid then
            if not (ent.type == "heat-pipe" and n_ent.type == "heat-pipe") then
               -- Use direction from connection_point, fallback to position math
               local dir = neighbor_info.connection_point and neighbor_info.connection_point.direction
               if dir == nil then
                  dir = FaUtils.get_direction_biased(
                     neighbor_info.connection_point and neighbor_info.connection_point.position or n_ent.position,
                     conn.position
                  )
               else
                  dir = FaUtils.rotate_180(dir) -- to report it's pointing back at us
               end
               table.insert(all_conn_info, { n_ent.prototype.localised_name, FaUtils.direction_lookup(dir or 16) })
            end
         end
      end
   end

   local n = #all_conn_info
   if n > 0 then
      local key = "fa.ent-info-heat-conn-" .. tostring(math.min(n, 4))
      local args = { key }
      for i = 1, math.min(n, 4) do
         table.insert(args, all_conn_info[i][1]) -- name
         table.insert(args, all_conn_info[i][2]) -- direction (raw int)
      end
      ctx.message:fragment(args)
   end
end

---@param ctx fa.Info.EntInfoContext
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

---@param ctx fa.Info.EntInfoContext
local function ent_info_splitter_states(ctx)
   local ent = ctx.ent
   if ent.type == "splitter" then ctx.message:fragment(TransportBelts.splitter_priority_info(ent)) end
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_radar(ctx)
   local ent = ctx.ent
   if ent.type == "radar" then ctx.message:fragment(mod.radar_charting_info(ent)) end
end

---@param ctx fa.Info.EntInfoContext
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

---@param ctx fa.Info.EntInfoContext
local function ent_info_mining_drill_output_chute(ctx)
   local point = ResourceMining.get_solid_output_coords(ctx.ent)
   if not point then return false end

   if util.distance(point.position, ctx.cursor_pos) < 0.6 then
      ctx.message:fragment({ "fa.ent-info-mining-drill-output" })
   end
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_cargo_wagon(ctx)
   if ctx.ent.name == "cargo-wagon" then
      local inv = ctx.ent.get_inventory(defines.inventory.cargo_wagon)
      assert(inv)
      local presenting = present_list(inv.get_contents())
      if presenting then ctx.message:fragment(presenting) end
   end
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_fluid_connections(ctx)
   local points = Fluids.get_connection_points(ctx.ent)
   ---@param p fa.Fluids.ConnectionPoint
   TH.retain_unordered(points, function(p)
      -- If this entity is a pipe and the connection goes to nothing, then do
      -- not announce this connection because pipe shapes are handled elsewhere.
      if p.raw.target == nil and ctx.ent.type == "pipe" then return false end

      if p.raw.target and p.raw.target.owner.type == "pipe" and ctx.ent.type == "pipe" then return false end

      return FaUtils.distance(p.position, ctx.cursor_pos) < 0.5
   end)

   if not next(points) then return end

   -- To get convenient announcements, we will roll up into fluids and their
   -- directions rather than handling these one by one.  If any connection
   -- connects to an entity, we instead will handle it separately, so that
   -- adjacent entity connections are announced.

   -- It is an engine invariant that only one fluidbox may be at any point, in
   -- the sense that only one fluid may be handled.  Storage tanks are a weird
   -- exception which break the documented stricter rule of no fluidboxes
   -- sharing a point, as the corners are bidirectional in 2 directions.
   local out_dirs = {}
   local in_dirs = {}

   for _, c in pairs(points) do
      if c.output_direction then out_dirs[c.output_direction] = c end
      if c.input_direction then in_dirs[c.input_direction] = c end
   end

   local bidirectionals = {}

   for dir, c in pairs(in_dirs) do
      local rot = FaUtils.rotate_180(dir)
      if out_dirs[rot] then
         bidirectionals[rot] = c
         in_dirs[dir] = nil
         out_dirs[rot] = nil
      end
   end

   local none = {}
   local closed = {}

   ---@param set table<defines.direction, fa.Fluids.ConnectionPoint>
   local function present(key, set, rotate)
      local buckets = {}
      for dir, c in pairs(set) do
         local f = c.fluid or none
         if not c.open then f = closed end
         local realdir = rotate and FaUtils.rotate_180(dir) or dir
         local dist = c.distance_in_tiles
         buckets[f] = buckets[f] or {}
         buckets[f][dist] = buckets[f][dist] or {}

         table.insert(buckets[f][dist], {
            direction = realdir,
            type = c.raw.connection_type,
            has_other_side = c.raw.target,
         })
      end

      for fluid, distdirs in pairs(buckets) do
         for dist, dirs in pairs(distdirs) do
            table.sort(dirs, function(a, b)
               return a.direction < b.direction
            end)

            local dirparts = {}
            for _, dirinfo in pairs(dirs) do
               local dir = dirinfo.direction
               local type = dirinfo.type
               if type == "underground" and dirinfo.has_other_side then
                  table.insert(
                     dirparts,
                     { "fa.ent-info-fluid-connections-via-underground-not-connected", FaUtils.direction_lookup(dir) }
                  )
               else
                  table.insert(dirparts, FaUtils.direction_lookup(dir))
               end
            end

            local dirlist = FaUtils.localise_cat_table(dirparts, ", ")
            ---@type LocalisedString
            local loc_fluid = { "fa.ent-info-fluid-connections-any" }
            if fluid == closed then
               loc_fluid = { "fa.ent-info-fluid-connections-closed" }
            elseif fluid ~= none then
               loc_fluid = Localising.get_localised_name_with_fallback(prototypes.fluid[fluid])
            end

            ctx.message:list_item({ key, loc_fluid, dirlist, dist })
         end
      end
   end

   present("fa.ent-info-fluid-connections-in", in_dirs, true)
   present("fa.ent-info-fluid-connections-out", out_dirs)
   present("fa.ent-info-fluid-connections-bidirectional", bidirectionals)
end

-- "connects to small electric pole x east, y northwest"
---@param ctx fa.Info.EntInfoContext
local function ent_info_pole_neighbors(ctx)
   if ctx.ent.type ~= "electric-pole" then return end

   local neighbors = {}

   Wires.call_on_connectors(ctx.ent, defines.wire_type.copper, function(_, conn)
      ---@type LuaEntity
      local other = conn.target.owner
      local n, q = other.name, other.quality.name
      neighbors[n] = neighbors[n] or {}
      neighbors[n][q] = neighbors[n][q] or {}
      table.insert(neighbors[n][q], other)
      return true
   end)

   if not next(neighbors) then
      ctx.message:fragment({ "fa.ent-info-electrical-connections-nothing" })
      return
   end

   -- Now we have grouped entities. We must convert that to strings. To do so, sort by distance then direction, to get
   -- something consistently ordered...
   for t, quals in pairs(neighbors) do
      for q, ents in pairs(quals) do
         table.sort(ents, function(a, b)
            local a_dist = FaUtils.distance(a.position, ctx.cursor_pos)
            local b_dist = FaUtils.distance(b.position, ctx.cursor_pos)
            if a_dist < b_dist then return true end
            -- Careful: if the distances aren't equal then continuing is a bad
            -- sort function.
            if a_dist > b_dist then return false end

            -- We want the 8-way direction here, as there is little point in
            -- reporting 16-way for poles.
            local a_dir = FaUtils.get_direction_biased(a.position, ctx.cursor_pos)
            local b_dir = FaUtils.get_direction_biased(b.position, ctx.cursor_pos)
            return a_dir < b_dir
         end)
      end
   end

   -- For now, we don't care about quality sorting.
   local will_announce = {}
   for n, quals in pairs(neighbors) do
      local proto = prototypes.entity[n]
      local pname = Localising.get_localised_name_with_fallback(proto)

      for q, ents in pairs(quals) do
         local intro = pname
         if q ~= "normal" then
            intro = FaUtils.spacecat(Localising.get_localised_name_with_fallback(prototypes.quality[q]), pname)
         end

         local ent_parts = {}
         for _, e in pairs(ents) do
            table.insert(ent_parts, {
               "fa.dir-dist",
               FaUtils.direction_lookup(FaUtils.get_direction_biased(e.position, ctx.cursor_pos)),
               FaUtils.distance_speech_friendly(ctx.cursor_pos, e.position),
            })
         end

         table.insert(
            will_announce,
            { "fa.ent-info-electrical-connections-sublist", intro, FaUtils.localise_cat_table(ent_parts, ", ") }
         )
      end
   end

   ctx.message:fragment({
      "fa.ent-info-electrical-connections-connected-to",
      FaUtils.localise_cat_table(will_announce, ", "),
   })
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_belt_contents(ctx)
   if ctx.ent.type ~= "transport-belt" then return end

   local node = TransportBelts.Node.create(ctx.ent)

   local found_items = false

   local is_full = {
      left = node:is_line_full(defines.transport_line.left_line),
      right = node:is_line_full(defines.transport_line.right_line),
   }
   local carries = {
      left = node:carries_heuristic(defines.transport_line.left_line, 5),
      right = node:carries_heuristic(defines.transport_line.right_line, 5),
   }
   local empty = { left = true, right = true }
   local most_common_for_both = { left = nil, right = nil }
   local other_count_for_both = { left = nil, right = nil }

   local params = {}
   for _, side in pairs({ "left", "right" }) do
      local carries = carries[side]
      local is_full = is_full[side]
      if next(carries.results) then
         empty[side] = false
         local most_common = TH.max_counts2(carries.results, TH.max_counts2_tiebreak_quality)
         most_common_for_both[side] = most_common

         local dist = carries.distance
         local dist_dir = 1
         if dist < 0 then
            dist_dir = 1
         elseif dist > 0 then
            dist_dir = 2
         end
         local others = table_size(carries.results) - 1
         other_count_for_both[side] = others
         TH.concat_arrays(params, { most_common, dist, dist_dir, others, is_full and 1 or 0 })
      end
   end

   local key = "fa.ent-info-belt-contents-empty"
   if (not empty.left) and empty.right then
      key = "fa.ent-info-belt-contents-left"
   elseif empty.left and not empty.right then
      key = "fa.ent-info-belt-contents-right"
   elseif not (empty.left or empty.right) then
      key = "fa.ent-info-belt-contents-both"

      -- If they're the same simplify to the simpler key.
      if
         most_common_for_both.left == most_common_for_both.right
         and other_count_for_both.left == other_count_for_both.right
      then
         key = "fa.ent-info-belt-contents-both-same"
      end
   end
   table.insert(params, 1, key)
   ctx.message:fragment(params)
end

---@param ctx fa.Info.EntInfoContext
local function ent_info_filters(ctx)
   local filts = Filters.get_all_filters(ctx.ent)
   if next(filts) then
      local first = true

      for _, proto in pairs(filts) do
         ctx.message:list_item()
         if first then ctx.message:fragment("Filters for") end
         first = false
         --We seem to be getting string names in 2.0; lookup the actual prototype to use
         if type(proto) == "string" then proto = prototypes.item[proto] end
         ctx.message:fragment(Localising.get_localised_name_with_fallback(proto))
      end
   end
end

--Outputs basic entity info, usually called when the cursor selects an entity.
---@param ent LuaEntity
---@return LocalisedString
function mod.ent_info(pindex, ent, is_scanner)
   local p = game.get_player(pindex)
   assert(p)
   local vp = Viewpoint.get_viewpoint(pindex)

   ---@type fa.Info.EntInfoContext
   local ctx = {
      ent = ent,
      pindex = pindex,
      message = Speech.new(),
      is_scanner = is_scanner,
      player = p,
      cursor_pos = vp:get_cursor_pos(),
   }

   -- We need to special case ghosts, so that we can fold the "x of y" in, e.g.
   -- "entity ghost of transport belt".
   if ent.type == "entity-ghost" or ent.type == "tile-ghost" then
      ctx.message:fragment({
         "fa.ent-info-ghost",
         Localising.get_localised_name_with_fallback(ent),
         Localising.get_localised_name_with_fallback(ent.ghost_prototype),
      })
   else
      ctx.message:fragment(Localising.get_localised_name_with_fallback(ent))
   end
   local function run_handler(handler, nolist)
      handler(ctx)
      if not nolist then ctx.message:list_item() end
   end

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

   run_handler(ent_info_facing, true)
   run_handler(ent_info_underground_belt_type, true)

   run_handler(ent_info_belt_shape, true)
   run_handler(ent_info_belt_contents, true)
   run_handler(ent_info_pole_neighbors, true)

   run_handler(ent_info_resource)
   run_handler(ent_info_rail)
   run_handler(ent_info_character)
   run_handler(ent_info_character_corpse)
   run_handler(ent_info_container)
   run_handler(ent_info_fluid_contents)
   run_handler(ent_info_logistic_network)
   run_handler(ent_info_infinity_pipe)
   run_handler(ent_info_pipe_shape)
   run_handler(ent_info_fluid_connections)

   run_handler(ent_info_train_stop)
   run_handler(ent_info_train_owner)
   run_handler(ent_info_rail_signal_state)
   run_handler(ent_info_mining_drill_output_chute)
   run_handler(ent_info_rail_signal_heading)

   run_handler(ent_info_gate_connection_point)
   run_handler(ent_info_marked_for_upgrade_deconstruct)
   run_handler(ent_info_power_production)
   run_handler(ent_info_underground_belt_connection)
   run_handler(ent_info_splitter_states)
   run_handler(ent_info_cargo_wagon)
   run_handler(ent_info_radar)

   if ent.name == "roboport" then
      local cell = ent.logistic_cell
      local network = ent.logistic_cell.logistic_network

      ctx.message:fragment("of network")
      ctx.message:fragment(BotLogistics.get_network_name(ent))
      ctx.message:fragment(",")
      ctx.message:fragment(BotLogistics.roboport_contents_info(ent))
   end
   run_handler(ent_info_spidertron)
   run_handler(ent_info_filters)

   --Inserters: Explain held items, pickup and drop positions
   if ent.type == "inserter" then
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
      local fuel_inv = ent.get_fuel_inventory()
      if fuel_inv and fuel_inv.valid and fuel_inv.is_empty() then ctx.message:fragment(", Out of Fuel") end
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
   run_handler(ent_info_render_heat_ports)
   run_handler(ent_info_heat_pipe_shape)
   run_handler(ent_info_heat_neighbors)

   run_handler(ent_info_constant_combinator)

   return ctx.message:build()
end

--Reports the charting range of a radar and how much of it has been charted so far.
---@param radar LuaEntity
function mod.radar_charting_info(radar)
   local charting_range = radar.prototype.get_max_distance_of_sector_revealed(radar.quality)
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
   Speech.speak(pindex, result)
end

--Reads out the distance and direction to the nearest damaged entity within 1000 tiles.
function mod.read_nearest_damaged_ent_info(pos, pindex)
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   --Scan for ents of your force
   local ents = p.surface.find_entities_filtered({ position = vp:get_cursor_pos(), radius = 1000, force = p.force })
   --Check for entities with health
   if ents == nil or #ents == 0 then
      Speech.speak(pindex, "No damaged structures within 1000 tiles.")
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
      Speech.speak(pindex, "No damaged structures within 1000 tiles.")
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
      Speech.speak(pindex, "No damaged structures within 1000 tiles.")
      return
   else
      --Move cursor to closest
      vp:set_cursor_pos(closest.position)
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
      Speech.speak(pindex, result)
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
   if prototype == nil and storage.players[pindex].menu == "inventory" then
      item_stack = storage.players[pindex].inventory.lua_inventory[storage.players[pindex].inventory.index]
      if item_stack and item_stack.valid_for_read then prototype = item_stack.prototype end
   elseif prototype == nil and storage.players[pindex].menu == "guns" then
      item_stack = Equipment.guns_menu_get_selected_slot(pindex)
      if item_stack and item_stack.valid_for_read then prototype = item_stack.prototype end
   end

   --Try crafting menu.
   if prototype == nil and storage.players[pindex].menu == "crafting" then
      recipe =
         storage.players[pindex].crafting.lua_recipes[storage.players[pindex].crafting.category][storage.players[pindex].crafting.index]
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

--- Handles cargo wagons by reporting their top inventory contents instead of status text.
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_cargo_wagon(ctx)
   local ent = ctx.ent
   if ent.prototype.type == "cargo-wagon" then
      ctx.message:fragment(Trains.cargo_wagon_top_contents_info(ent))
      return true
   end
   return false
end

--- Handles fluid wagons by reporting their fluid contents instead of status text.
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_fluid_wagon(ctx)
   local ent = ctx.ent
   if ent.prototype.type == "fluid-wagon" then
      ctx.message:fragment(Trains.fluid_contents_info(ent))
      return true
   end
   return false
end

--- Handles status text if it exists
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_lookup(ctx)
   local ent = ctx.ent
   local status_lookup = FaUtils.into_lookup(defines.entity_status)
   status_lookup[23] = "Full burnt result output" --weird exception
   local ent_status_id = ent.status
   if ent_status_id ~= nil then
      local ent_status_text = status_lookup[ent_status_id]
      if ent_status_text == nil then
         print("Weird no entity status lookup" .. ent.name .. "-" .. ent.type .. "-" .. ent_status_id)
      end
      ctx.message:fragment({ "entity-status." .. ent_status_text:gsub("_", "-") })
      return true
   end
   return false
end

--- Handles fallback status logic when ent.status is nil
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_fallback(ctx)
   local ent = ctx.ent
   if ent.get_fuel_inventory() ~= nil then
      ctx.message:fragment(Driving.fuel_inventory_info(ent))
   elseif ent.prototype.type == "electric-pole" then
      if Electrical.get_electricity_satisfaction(ent) > 0 then
         ctx.message:fragment({
            "fa.ent-status-percent-network-satisfaction",
            Electrical.get_electricity_satisfaction(ent),
            Electrical.get_electricity_flow_info(ent),
         })
      else
         ctx.message:fragment({ "fa.ent-status-no-power", Electrical.report_nearest_supplied_electric_pole(ent) })
      end
   else
      ctx.message:fragment({ "fa.ent-status-no-status" })
   end
   return true
end

--- Reports max item throughput for belts and splitters
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_belt_speed(ctx)
   local ent = ctx.ent
   local type = ent.prototype.type
   local belt_speed = ent.prototype.belt_speed
   if belt_speed ~= nil and belt_speed > 0 then
      if type == "splitter" then
         ctx.message:fragment({ "fa.ent-status-splitter-speed", math.floor(belt_speed * 480 * 2) })
      else
         ctx.message:fragment({ "fa.ent-status-belt-speed", math.floor(belt_speed * 480) })
      end
      return true
   end
   return false
end

--- Reports crafting speed, currently for assembling-machine and furnace
--- Crafting cycles per minute based on recipe time and the STATED craft speed
--- Todo maybe extend this to all "crafting machine" types?
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_crafting_speed(ctx)
   local ent = ctx.ent
   local type = ent.prototype.type
   if type == "assembling-machine" or type == "furnace" then
      local progress = ent.crafting_progress
      local speed = ent.crafting_speed
      local recipe = ent.get_recipe()
      if recipe and recipe.valid then
         local recipe_time = recipe.energy
         local cycles = 60 / recipe_time * speed -- crafting cycles completed per minute for this recipe
         local cycles_string = string.format(" %.2f ", cycles)
         if cycles == math.floor(cycles) then cycles_string = string.format(" %d ", cycles) end
         local speed_string = string.format(" %.2f ", speed)
         if speed == math.floor(speed) then speed_string = string.format(" %d ", speed) end
         if cycles < 10 then --more than 6 seconds to craft
            ctx.message:fragment({ "fa.ent-status-recipe-progress", math.floor(progress * 100) })
         end
         if cycles > 0 then ctx.message:fragment({ "fa.ent-status-recipe-cycles", cycles_string }) end
         ctx.message:fragment({ "fa.ent-status-crafting-speed", speed_string })
         ctx.message:fragment({ "fa.ent-status-crafting-percent", math.floor(100 * (1 + ent.speed_bonus) + 0.5) })
         if ent.productivity_bonus ~= 0 then
            ctx.message:fragment({
               "fa.ent-status-productivity-bonus",
               math.floor(100 * ent.productivity_bonus + 0.5),
            })
         end
         return true
      end
   end
   return false
end

--- Reports mining speed and bonuses for mining drills
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_mining_speed(ctx)
   local ent = ctx.ent
   if ent.prototype.type == "mining-drill" then
      local speed_bonus = ent.speed_bonus
      local productivity_bonus = ent.productivity_bonus
      ctx.message:fragment({
         "fa.ent-status-mining-drill-speed",
         string.format(" %.2f ", ent.prototype.mining_speed * 60 * (1 + speed_bonus)),
      })
      if speed_bonus ~= 0 then
         ctx.message:fragment({ "fa.ent-status-speed-bonus", math.floor(100 * (1 + speed_bonus) + 0.5) })
      end
      if productivity_bonus ~= 0 then
         ctx.message:fragment({
            "fa.ent-status-productivity-bonus",
            math.floor(100 * productivity_bonus + 0.5),
         })
      end
      return true
   end
   return false
end

--- Reports lab speed and productivity bonus
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_lab_speed(ctx)
   local ent = ctx.ent
   if ent.prototype.type == "lab" then
      local speed_bonus = ent.speed_bonus
      local productivity_bonus = ent.productivity_bonus
      if speed_bonus ~= 0 then
         local base = ent.force.laboratory_speed_modifier
         local combined = 1 + base * (1 + (speed_bonus - base))
         ctx.message:fragment({ "fa.ent-status-speed-bonus", math.floor(100 * combined + 0.5) })
      end
      if productivity_bonus ~= 0 then
         local prod = productivity_bonus + ent.force.laboratory_productivity_bonus
         ctx.message:fragment({ "fa.ent-status-productivity-bonus", math.floor(100 * prod + 0.5) })
      end
      return true
   end
   return false
end

--- Generic fallback for other entity types with speed/productivity bonuses
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_generic_speed_productivity(ctx)
   local ent = ctx.ent
   local speed_bonus = ent.speed_bonus
   local productivity_bonus = ent.productivity_bonus
   if speed_bonus ~= 0 then
      ctx.message:fragment({ "fa.ent-status-speed-bonus", math.floor(100 * (1 + speed_bonus) + 0.5) })
   end
   if productivity_bonus ~= 0 then
      ctx.message:fragment({ "fa.ent-status-productivity-bonus", math.floor(100 * productivity_bonus + 0.5) })
   end
   return true
end

--- Working consumption: full power draw
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_energy_working(ctx)
   local ent = ctx.ent
   local status = ent.status
   local status_list = defines.entity_status

   if ctx.uses_energy and status == status_list.working then
      local usage = ent.prototype.get_max_energy_usage(ent.quality or 0)
      local total = (usage * 60 * ctx.power_rate) + ctx.drain
      ctx.message:fragment({
         "fa.ent-status-electrical-working",
         Electrical.get_power_string(total),
      })
      return true
   end
   return false
end

--- Low power or no power consumption: Reports estimated energy usage for low/no power status based on capacity and drain.
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_energy_low(ctx)
   local ent = ctx.ent
   local status = ent.status
   local status_list = defines.entity_status

   if ctx.uses_energy and (status == status_list.no_power or status == status_list.low_power) then
      local cap = ent.prototype.get_max_energy(ent.quality or 0) or 0
      local total = (cap * 60 * ctx.power_rate) + ctx.drain
      ctx.message:fragment({
         "fa.ent-status-electrical-low-no-power",
         Electrical.get_power_string(total),
      })
      return true
   end
   return false
end

--- Idle consumption: still drawing drain even when not active
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_energy_idle(ctx)
   local ent = ctx.ent

   local has_potential = (ent.prototype.get_max_energy_usage(ent.quality or 0) or 0) > 0

   if ctx.uses_energy or has_potential then
      ctx.message:fragment({
         "fa.ent-status-electrical-idle",
         Electrical.get_power_string(ctx.drain),
      })
      return true
   end
   return false
end

--- Burner fuel: report if relevant
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_burner_fuel(ctx)
   local ent = ctx.ent
   -- Only engines or burner‐based machines have this field
   if ctx.uses_energy and ent.prototype.burner_prototype then
      ctx.message:fragment({ "fa.ent-status-burner-fuel" })
      return true
   end
   return false
end

--- reports the entity’s health status
---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_health(ctx)
   local ent = ctx.ent
   if ent.is_entity_with_health then
      local ratio = ent.get_health_ratio()
      if ratio == 1 then
         -- Full health
         ctx.message:fragment({ "fa.ent-status-full-health" })
      else
         -- Percent health
         ctx.message:fragment({
            "fa.ent-status-percent-health",
            math.floor(ratio * 100),
         })
      end
      return true
   end
   return false
end

--- reports evolution factor for spawner entities---@param ctx fa.Info.EntStatusContext The context for the current entity.
---@return boolean handled True if this handler added information to the message.
local function ent_status_spawner_evolution(ctx)
   local ent = ctx.ent
   if ent.type == "unit-spawner" then
      local evo = math.floor(1000 * ent.force.get_evolution_factor(ent.surface)) / 1000
      ctx.message:fragment({ "fa.ent-status-spawner-evolution-factor", evo })
      return true
   end
   return false
end

---Report the status of the selected entity as well as additional dynamic info depending on the entity type
---@param pindex number The player index for whom the action is being performed.
function mod.read_selected_entity_status(pindex)
   local router = UiRouter.get_router(pindex)

   local ent = game.get_player(pindex).selected
   if not ent then return end
   -- local stack = game.get_player(pindex).cursor_stack
   if router:is_ui_open() then return end
   local status = ent.status

   local power_rate = (1 + ent.consumption_bonus)
   local drain = ent.electric_drain
   if drain ~= nil then
      drain = drain * 60
   else
      drain = 0
   end
   local uses_energy = false
   if drain > 0 or ent.prototype.get_max_energy_usage(ent.quality) > 0 then uses_energy = true end

   local p = game.get_player(pindex)
   assert(p)

   ---@type fa.Info.EntStatusContext
   local ctx = {
      ent = ent,
      pindex = pindex,
      message = Speech.new(),
      player = p,
      power_rate = power_rate,
      drain = drain,
      uses_energy = uses_energy,
   }

   local function run_handler(handler, nolist)
      -- Call the handler; expect it to return true if it “handled” the entity
      local handled = handler(ctx)
      if handled and not nolist then ctx.message:list_item() end
      return handled
   end

   -- Try each in turn, stopping on the first that returns true
   -- discard final result with `_` variable
   local _ = run_handler(ent_status_cargo_wagon)
      or run_handler(ent_status_fluid_wagon)
      or run_handler(ent_status_lookup)
      or run_handler(ent_status_fallback)

   if status ~= nil then
      --For working or normal entities, give some extra info about specific entities in terms of speeds or bonuses.
      local status_list = defines.entity_status
      if status ~= status_list.no_power and status ~= status_list.no_fuel then
         run_handler(ent_status_belt_speed)
         _ = run_handler(ent_status_crafting_speed)
            or run_handler(ent_status_mining_speed)
            or run_handler(ent_status_lab_speed)
            or run_handler(ent_status_generic_speed_productivity)
      end

      --Entity power usage
      _ = run_handler(ent_status_energy_working)
         or run_handler(ent_status_energy_low)
         or run_handler(ent_status_energy_idle)
   end

   run_handler(ent_status_burner_fuel)

   --Entity Health
   run_handler(ent_status_health)

   --Spawners: Report evolution factor
   run_handler(ent_status_spawner_evolution)
   return ctx.message:build()
end

--Returns an info string about the entities and tiles found within an area scan done by an enlarged cursor.
---@param pindex number
---@param left_top fa.Point
---@param right_bottom fa.Point
---@return LocalisedString
function mod.area_scan_summary_info(pindex, left_top, right_bottom)
   local msg = Speech.new()

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
      return { "fa.area-scan-charted-zero" }
   elseif total_chunks_covered > 0 and generated_chunk_count < total_chunks_covered then
      msg:fragment({
         "fa.area-scan-charted-percent",
         tostring(math.floor(generated_chunk_count / total_chunks_covered * 100)),
      })
   end

   ---@type { name: string, count: string, category: string }[]
   local counts = {}

   local covered_area = (right_bottom.x - left_top.x) * (right_bottom.y - left_top.y)
   assert(covered_area > 0)

   local water_count = surf.count_tiles_filtered({
      name = Consts.WATER_TILE_NAMES,
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

   -- Now using Speech to properly handle localisation
   local has_items = false
   for _, entry in pairs(counts) do
      if entry.count == 0 then break end

      if not has_items then
         msg:fragment({ "fa.area-scan-contains" })
         has_items = true
      end

      -- Create proper localised string for the name
      local localised_name
      if entry.name == "water" then
         localised_name = { "fa.area-scan-water" }
      elseif entry.name == "trees" then
         localised_name = { "fa.area-scan-trees" }
      elseif entry.name == "stone-brick-path" then
         localised_name = { "tile-name.stone-path" }
      elseif entry.name == "concrete" then
         localised_name = { "tile-name.concrete" }
      elseif entry.name == "refined-concrete" then
         localised_name = { "tile-name.refined-concrete" }
      else
         -- Try entity name first, then fall back to raw name
         if prototypes.entity[entry.name] then
            localised_name = { "entity-name." .. entry.name }
         else
            localised_name = entry.name
         end
      end

      if entry.category == "resource" or entry.category == "flooring" then
         msg:list_item({
            "fa.area-scan-item-with-percent",
            tostring(entry.count),
            localised_name,
            tostring(math.floor(entry.count / covered_area * 100)),
         })
      else
         msg:list_item({ "fa.area-scan-item", tostring(entry.count), localised_name })
      end
   end

   if has_items then
      msg:fragment({ "fa.area-scan-total-occupied", tostring(math.floor(count_total / covered_area * 100)) })
   else
      msg:fragment({ "fa.area-scan-empty" })
   end

   return msg:build()
end

return mod
