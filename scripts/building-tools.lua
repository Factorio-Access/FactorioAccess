--Here: Functions for building with the mod, both basics and advanced tools.
local Consts = require("scripts.consts")
local Electrical = require("scripts.electrical")
local FaUtils = require("scripts.fa-utils")
local localising = require("scripts.localising")
local dirs = defines.direction
local Graphics = require("scripts.graphics")
local Speech = require("scripts.speech")
local PlayerMiningTools = require("scripts.player-mining-tools")
-- Rail builder removed (Factorio 2.0 incompatibility)
local Teleport = require("scripts.teleport")
local TransportBelts = require("scripts.transport-belts")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

-- Helper function to check electric pole placement
local function check_electric_pole_placement(surface, position, pole_name, min_distance, max_radius)
   local poles = surface.find_entities_filtered({ position = position, radius = max_radius, name = pole_name })
   local all_beyond_min = true
   local any_connects = false
   local any_found = false

   for i, pole in ipairs(poles) do
      any_found = true
      local distance = util.distance(position, pole.position)
      if distance < min_distance then
         all_beyond_min = false
      elseif distance >= min_distance then
         any_connects = true
      end
   end

   return all_beyond_min and any_connects, any_found
end

---@class fa.BuildingTools.BuildItemParams
---@field pindex integer Player index
---@field building_direction defines.direction Direction to build in
---@field teleport_player? boolean Whether to teleport player out of build area (default true)
---@field play_error_sound? boolean Whether to play error sounds (default true)
---@field speak_errors? boolean Whether to speak error messages (default true)

--[[Attempts to build the item in hand with explicit parameters.
* Does nothing if the hand is empty or the item is not a place-able entity.
* If the item is an offshore pump, calls a different, special function for it.
* @param params fa.BuildingTools.BuildItemParams Build parameters
* @return boolean True if build was successful
]]
-- Precondition: Caller must ensure cursor_stack is valid_for_read
function mod.build_item_in_hand_with_params(params)
   local pindex = params.pindex
   local building_direction = params.building_direction
   local teleport_player = params.teleport_player ~= false -- default true
   local play_error_sound = params.play_error_sound ~= false -- default true
   local speak_errors = params.speak_errors ~= false -- default true

   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   local vp = Viewpoint.get_viewpoint(pindex)
   local pos = vp:get_cursor_pos()

   local cursor_size = vp:get_cursor_size()

   -- Ensure building footprint is up to date
   Graphics.sync_build_cursor_graphics(pindex)

   --Exceptional build cases
   if stack.name == "offshore-pump" then
      mod.build_offshore_pump_in_hand(pindex)
      return
   elseif stack.name == "rail" then
      -- Rails not supported in 2.0 yet
      Speech.speak(pindex, { "fa.trains-not-supported" })
      return
   elseif stack.name == "rail-signal" or stack.name == "rail-chain-signal" then
      -- Rail signals not supported in 2.0 yet
      Speech.speak(pindex, { "fa.trains-not-supported" })
      return
   end
   --General build cases
   if stack.prototype.place_result ~= nil then
      local ent = stack.prototype.place_result
      local dimensions = FaUtils.get_tile_dimensions(stack.prototype, building_direction)
      local position = nil
      local placing_underground_belt = stack.prototype.place_result.type == "underground-belt"

      --Cursor mode: Calculate footprint using centralized function
      local footprint = FaUtils.calculate_building_footprint({
         entity_prototype = stack.prototype.place_result,
         position = pos,
         building_direction = building_direction,
         player_direction = storage.players[pindex].player_direction,
         is_rail_vehicle = false,
      })

      turn_to_cursor_direction_cardinal(pindex)

      position = footprint.center

      -- Store the calculated footprint for later use
      storage.players[pindex].building_footprint_left_top = footprint.left_top
      storage.players[pindex].building_footprint_right_bottom = footprint.right_bottom

      local actual_build_direction = building_direction
      if placing_underground_belt and storage.players[pindex].underground_connects == true then
         --Flip the chute
         actual_build_direction = (building_direction + dirs.south) % (2 * dirs.south)
      end

      --Clear build area obstacles
      PlayerMiningTools.clear_obstacles_in_rectangle(
         storage.players[pindex].building_footprint_left_top,
         storage.players[pindex].building_footprint_right_bottom,
         pindex
      )

      --Teleport player out of build area (if enabled)
      if teleport_player then
         mod.teleport_player_out_of_build_area(
            storage.players[pindex].building_footprint_left_top,
            storage.players[pindex].building_footprint_right_bottom,
            pindex
         )
      end

      --Try to build it
      local build_successful = false
      local building = {
         position = position,
         --position = center_of_tile(position),
         direction = actual_build_direction,
         alt = false,
         flip_horizontal = vp:get_flipped_horizontal(),
         flip_vertical = vp:get_flipped_vertical(),
      }
      if building.position ~= nil and game.get_player(pindex).can_build_from_cursor(building) then
         --Build it
         game.get_player(pindex).build_from_cursor(building)
         schedule(2, "read_tile", pindex)
         build_successful = true
      else
         --Report errors (if enabled)
         if play_error_sound then game.get_player(pindex).play_sound({ path = "utility/cannot_build" }) end

         --Explain build error (if enabled)
         if speak_errors then
            local result = "Cannot place that there "
            local build_area = {
               storage.players[pindex].building_footprint_left_top,
               storage.players[pindex].building_footprint_right_bottom,
            }
            result = mod.identify_building_obstacle(pindex, build_area, nil)
            Speech.speak(pindex, result)
         end
      end
      --Note: Underground belt chute handling was removed - direction is passed directly

      --Flip pipe-to-ground direction in storage for next placement
      if
         build_successful
         and stack
         and stack.valid_for_read
         and stack.valid
         and stack.prototype.place_result ~= nil
         and stack.prototype.place_result.name == "pipe-to-ground"
      then
         local vp = Viewpoint.get_viewpoint(pindex)
         vp:set_hand_direction(FaUtils.rotate_180(vp:get_hand_direction()))
         game.get_player(pindex).play_sound({ path = "Rotate-Hand-Sound" })
      end

      return build_successful
   elseif stack and stack.valid_for_read and stack.valid and stack.prototype.place_as_tile_result ~= nil then
      --Tile placement
      local p = game.get_player(pindex)
      local t_size = cursor_size * 2 + 1

      pos.x = pos.x - cursor_size
      pos.y = pos.y - cursor_size
      vp:set_cursor_pos(pos)

      if p.can_build_from_cursor({ position = pos, terrain_building_size = t_size }) then
         p.build_from_cursor({ position = pos, terrain_building_size = t_size })
         return true
      else
         p.play_sound({ path = "utility/cannot_build" })
         return false
      end
   else
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      return false
   end

   --Update cursor highlight (end)
   local ent = game.get_player(pindex).selected
   if ent and ent.valid then
      Graphics.draw_cursor_highlight(pindex, ent, nil)
   else
      Graphics.draw_cursor_highlight(pindex, nil, nil)
   end
end

--[[Assisted building function for offshore pumps.
* Called as a special case by build_item_in_hand_with_params
]]
function mod.build_offshore_pump_in_hand(pindex)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack

   if stack and stack.valid and stack.valid_for_read and stack.name == "offshore-pump" then
      local ent = stack.prototype.place_result
      storage.players[pindex].pump.positions = {}
      local initial_position = p.position
      initial_position.x = math.floor(initial_position.x)
      initial_position.y = math.floor(initial_position.y)
      for i1 = -10, 10 do
         for i2 = -10, 10 do
            for i3 = 0, 3 do
               local position = { x = initial_position.x + i1, y = initial_position.y + i2 }
               ---@type defines.direction
               local dir_3 = i3 * dirs.east
               if p.can_build_from_cursor({ name = "offshore-pump", position = position, direction = dir_3 }) then
                  table.insert(storage.players[pindex].pump.positions, { position = position, direction = dir_3 })
               end
            end
         end
      end
      if #storage.players[pindex].pump.positions == 0 then
         Speech.speak(pindex, { "fa.building-pump-no-positions" })
      else
         UiRouter.get_router(pindex):open_ui(UiRouter.UI_NAMES.PUMP)
         storage.players[pindex].move_queue = {}
         Speech.speak(pindex, { "fa.building-pump-positions-available", #storage.players[pindex].pump.positions })
         table.sort(storage.players[pindex].pump.positions, function(k1, k2)
            return util.distance(initial_position, k1.position) < util.distance(initial_position, k2.position)
         end)

         storage.players[pindex].pump.index = 0
      end
   end
end

--Reads the result of trying to rotate a building, which is a vanilla action.
function mod.rotate_building_info_read(event, forward)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)

   local p = game.get_player(pindex)
   if not check_for_player(pindex) then return end
   local mult = 1
   if forward == false then mult = -1 end
   local ent = p.selected
   local stack = game.get_player(pindex).cursor_stack
   local vp = Viewpoint.get_viewpoint(pindex)
   local build_dir = vp:get_hand_direction()
   if stack and stack.valid_for_read and stack.valid and stack.prototype.place_result ~= nil then
      local placed = stack.prototype.place_result
      if
         placed.supports_direction
         or placed.type == "car"
         or placed.type == "locomotive"
         or placed.type == "artillery-wagon"
      then
         --Locomotives and artillery wagons in hand are rotated 180 degrees
         if placed.type == "locomotive" or placed.type == "artillery-wagon" then mult = mult * 2 end

         --Update the assumed hand direction
         game.get_player(pindex).play_sound({ path = "Rotate-Hand-Sound" })
         build_dir = (build_dir + dirs.east * mult) % (2 * dirs.south)
      else
         Speech.speak(pindex, { "fa.building-no-rotate-support", { "item-name." .. stack.name } })
      end
   elseif stack ~= nil and stack.valid_for_read and stack.is_blueprint and stack.is_blueprint_setup() then
      --Rotate blueprints: They are tracked separately, and we reset them to north when cursor stack changes
      game.get_player(pindex).play_sound({ path = "Rotate-Hand-Sound" })
      storage.players[pindex].blueprint_hand_direction = (
         storage.players[pindex].blueprint_hand_direction + dirs.east * mult
      ) % (2 * dirs.south)
      Speech.speak(pindex, FaUtils.direction_lookup(storage.players[pindex].blueprint_hand_direction))

      --Flip the saved bp width and height
      local temp = storage.players[pindex].blueprint_height_in_hand
      storage.players[pindex].blueprint_height_in_hand = storage.players[pindex].blueprint_width_in_hand
      storage.players[pindex].blueprint_width_in_hand = temp

      --Call graphics update
      --Graphics.sync_build_cursor_graphics(pindex)
   elseif ent and ent.valid then
      if ent.supports_direction then
         --Assuming that the vanilla rotate event will now rotate the ent
         local new_dir = (ent.direction + dirs.east * mult) % (2 * dirs.south)

         if
            ent.name == "steam-engine"
            or ent.name == "steam-turbine"
            or ent.name == "rail"
            or ent.name == "straight-rail"
            or ent.name == "curved-rail"
            or ent.name == "character"
         then
            --Exception: These ents do not rotate
            new_dir = (new_dir - dirs.east * mult) % (2 * dirs.south)
         elseif (ent.tile_width ~= ent.tile_height and ent.supports_direction) or ent.type == "underground-belt" then
            --Exceptions: None-square ents rotate 2x , while underground belts simply flip instead
            --Examples, boiler, pump, flamethrower, heat exchanger,
            new_dir = (new_dir + dirs.east * mult) % (2 * dirs.south)
         end

         Speech.speak(pindex, FaUtils.direction_lookup(new_dir))

         --
      else
         Speech.speak(pindex, { "fa.building-no-rotate-support", { "entity-name." .. ent.name } })
      end
   else
      Speech.speak(pindex, { "fa.building-cannot-rotate" })
   end
end

--Does everything to handle the nudging feature, taking the keypress event and the nudge direction as the input. Nothing happens if an entity cannot be selected.
function mod.nudge_key(direction, event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local ent = p.selected
   local vp = Viewpoint.get_viewpoint(pindex)
   if ent and ent.valid then
      if ent.force == game.get_player(pindex).force then
         local old_pos = ent.position
         local new_pos = FaUtils.offset_position_legacy(ent.position, direction, 1)
         local temporary_teleported = false
         local actually_teleported = false

         --Clear the new build location using centralized footprint calculation
         local footprint = FaUtils.calculate_building_footprint({
            width = ent.tile_width,
            height = ent.tile_height,
            position = FaUtils.offset_position_legacy(ent.position, direction, 1),
            building_direction = ent.direction,
            player_direction = dirs.north, -- Not relevant for nudging
            is_rail_vehicle = false,
         })
         local left_top = footprint.left_top
         local right_bottom = footprint.right_bottom
         PlayerMiningTools.clear_obstacles_in_rectangle(left_top, right_bottom, pindex)

         --First teleport the ent to 0,0 temporarily
         temporary_teleported = ent.teleport({ 0, 0 })
         if not temporary_teleported then
            game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
            Speech.speak(pindex, { "fa.failed-to-nudge" })
            return
         end

         --Now check if the ent can be placed at its new location, and proceed or revert accordingly
         local check_name = ent.name
         if check_name == "entity-ghost" then check_name = ent.ghost_name end
         if ent.surface.can_place_entity({ name = check_name, position = new_pos, direction = ent.direction }) then
            actually_teleported = ent.teleport(new_pos)
         else
            --Cannot build in new location, so send it back
            actually_teleported = ent.teleport(old_pos)
            game.get_player(pindex).play_sound({ path = "utility/cannot_build" })

            --Explain build error
            local result = { "", "Cannot nudge, " }
            local build_area = { left_top, right_bottom }
            local obstacle_info = mod.identify_building_obstacle(pindex, build_area, ent)
            for i, v in ipairs(obstacle_info) do
               if i > 1 then -- Skip the empty string at index 1
                  table.insert(result, v)
               end
            end
            Speech.speak(pindex, result)
            return
         end
         if not actually_teleported then
            --Failed to teleport
            Speech.speak(pindex, { "fa.failed-to-nudge" })
            return
         else
            --Successfully teleported and so nudged
            Speech.speak(pindex, { "fa.nudged-one-direction", { "fa.direction", direction } })

            vp:set_cursor_pos(FaUtils.offset_position_legacy(vp:get_cursor_pos(), direction, 1))

            if ent.type == "electric-pole" then
               -- laterdo **bugfix when nudged electric poles have extra wire reach, cut wires
               -- if ent.clone{position = new_pos, surface = ent.surface, force = ent.force, create_build_effect_smoke = false} == true then
               -- ent.destroy{}
               -- end
            end
         end
      end

      --Update ent connections after teleporting it
      ent.update_connections()
   else
      Speech.speak(pindex, { "fa.building-nudged-nothing" })
   end
end

--Returns a list of positions for this entity where it has its heat pipe connections.
function mod.get_heat_connection_positions(ent_name, ent_position, ent_direction)
   local pos = ent_position
   local positions = {}
   if ent_name == "heat-pipe" then
      table.insert(positions, { x = pos.x, y = pos.y })
   elseif ent_name == "heat-exchanger" then
      table.insert(positions, FaUtils.offset_position_legacy(pos, FaUtils.rotate_180(ent_direction), 0.5))
   elseif ent_name == "nuclear-reactor" then
      table.insert(positions, { x = pos.x - 2, y = pos.y - 2 })
      table.insert(positions, { x = pos.x - 0, y = pos.y - 2 })
      table.insert(positions, { x = pos.x + 2, y = pos.y - 2 })

      table.insert(positions, { x = pos.x - 2, y = pos.y - 0 })
      table.insert(positions, { x = pos.x + 2, y = pos.y - 0 })

      table.insert(positions, { x = pos.x - 2, y = pos.y + 2 })
      table.insert(positions, { x = pos.x - 0, y = pos.y + 2 })
      table.insert(positions, { x = pos.x + 2, y = pos.y + 2 })
   end
   return positions
end

--Returns a list of positions for this entity where it expects to find other heat pipe interfaces that it can connect to.
function mod.get_heat_connection_target_positions(ent_name, ent_position, ent_direction)
   local pos = ent_position
   local positions = {}
   if ent_name == "heat-pipe" then
      table.insert(positions, { x = pos.x - 1, y = pos.y - 0 })
      table.insert(positions, { x = pos.x + 1, y = pos.y - 0 })
      table.insert(positions, { x = pos.x - 0, y = pos.y - 1 })
      table.insert(positions, { x = pos.x - 0, y = pos.y + 1 })
   elseif ent_name == "heat-exchanger" then
      table.insert(positions, FaUtils.offset_position_legacy(pos, FaUtils.rotate_180(ent_direction), 1.5))
   elseif ent_name == "nuclear-reactor" then
      table.insert(positions, { x = pos.x - 2, y = pos.y - 3 })
      table.insert(positions, { x = pos.x - 0, y = pos.y - 3 })
      table.insert(positions, { x = pos.x + 2, y = pos.y - 3 })

      table.insert(positions, { x = pos.x - 3, y = pos.y - 2 })
      table.insert(positions, { x = pos.x + 3, y = pos.y - 2 })

      table.insert(positions, { x = pos.x - 3, y = pos.y - 0 })
      table.insert(positions, { x = pos.x + 3, y = pos.y - 0 })

      table.insert(positions, { x = pos.x - 3, y = pos.y + 2 })
      table.insert(positions, { x = pos.x + 3, y = pos.y + 2 })

      table.insert(positions, { x = pos.x - 2, y = pos.y + 3 })
      table.insert(positions, { x = pos.x - 0, y = pos.y + 3 })
      table.insert(positions, { x = pos.x + 2, y = pos.y + 3 })
   end
   return positions
end

--Returns an info string about trying to build the entity in hand. The info type depends on the entity. Note: Limited usefulness for entities with sizes greater than 1 by 1.
---@param stack LuaItemStack
function mod.build_preview_checks_info(stack, pindex)
   local p = game.get_player(pindex)
   local surf = game.get_player(pindex).surface
   local vp = Viewpoint.get_viewpoint(pindex)
   local pos = vp:get_cursor_pos()

   local result = { "" }
   local build_dir = vp:get_hand_direction()
   local ent_p = stack.prototype.place_result --it is an entity prototype!
   if ent_p == nil or not ent_p.valid then return "invalid entity" end

   --Notify before all else if surface/player cannot place this entity. laterdo extend this valid placement check by copying over build offset stuff
   if
      ent_p.tile_width <= 1
      and ent_p.tile_height <= 1
      and not surf.can_place_entity({ name = ent_p.name, position = pos, direction = build_dir })
   then
      return " cannot place this here "
   end

   --For underground belts, state the potential neighbor: any neighborless matching underground of the same name and same/opposite direction, and along the correct axis
   if ent_p.type == "underground-belt" then
      local connected = false
      local check_dist = 5
      if stack.name == "fast-underground-belt" then
         check_dist = 7
      elseif stack.name == "express-underground-belt" then
         check_dist = 9
      end
      local candidates = game
         .get_player(pindex).surface
         .find_entities_filtered({ name = stack.name, position = pos, radius = check_dist, direction = build_dir })
      if #candidates > 0 then
         for i, cand in ipairs(candidates) do
            rendering.draw_circle({
               color = { 1, 1, 0 },
               radius = 0.5,
               width = 3,
               target = cand.position,
               surface = cand.surface,
               time_to_live = 60,
            })
            local dist_x = cand.position.x - pos.x
            local dist_y = cand.position.y - pos.y
            if
               cand.direction == build_dir
               and cand.neighbours == nil
               and cand.belt_to_ground_type == "input"
               and (FaUtils.get_direction_biased(cand.position, pos) == FaUtils.rotate_180(build_dir))
               and (dist_x == 0 or dist_y == 0)
            then
               rendering.draw_circle({
                  color = { 0, 1, 0 },
                  radius = 1.0,
                  width = 3,
                  target = cand.position,
                  surface = cand.surface,
                  time_to_live = 60,
               })
               table.insert(result, {
                  "fa.connection-connects-underground",
                  { "fa.direction", build_dir },
                  tostring(math.floor(util.distance(cand.position, pos)) - 1),
               })
               connected = true
               storage.players[pindex].underground_connects = true
            end
         end
      end
      if not connected then
         table.insert(result, { "fa.connection-not-connected-pipe" })
         storage.players[pindex].underground_connects = false
      end
   end

   --For pipes to ground, state when connected
   if stack.name == "pipe-to-ground" then
      local connected = false
      local check_dist = 10
      local closest_dist = 11
      local closest_cand = nil
      local candidates = game.get_player(pindex).surface.find_entities_filtered({
         name = stack.name,
         position = pos,
         radius = check_dist,
         direction = FaUtils.rotate_180(build_dir),
      })
      if #candidates > 0 then
         for i, cand in ipairs(candidates) do
            rendering.draw_circle({
               color = { 1, 1, 0 },
               radius = 0.5,
               width = 3,
               target = cand.position,
               surface = cand.surface,
               time_to_live = 60,
            })
            local dist_x = cand.position.x - pos.x
            local dist_y = cand.position.y - pos.y
            if
               cand.direction == FaUtils.rotate_180(build_dir)
               and (FaUtils.get_direction_biased(pos, cand.position) == build_dir)
               and (dist_x == 0 or dist_y == 0)
            then
               rendering.draw_circle({
                  color = { 0, 1, 0 },
                  radius = 1.0,
                  width = 3,
                  target = cand.position,
                  surface = cand.surface,
                  time_to_live = 60,
               })
               connected = true
               --Check if closest cand
               local cand_dist = util.distance(cand.position, pos)
               if cand_dist <= closest_dist then
                  closest_dist = cand_dist
                  closest_cand = cand
               end
            end
         end
         --Report the closest candidate (therefore the correct one)
         if closest_cand ~= nil then
            table.insert(result, {
               "fa.connection-connects-underground",
               { "fa.direction", FaUtils.rotate_180(build_dir) },
               tostring(math.floor(util.distance(closest_cand.position, pos)) - 1),
            })
         end
      end
      if not connected then table.insert(result, { "fa.connection-not-connected-underground" }) end
   end

   --For pipes, read the fluids in fluidboxes of surrounding entities, if any. Also warn if there are multiple fluids, hence a mixing error. Pipe preview
   if stack.name == "pipe" then
      rendering.draw_circle({
         color = { 1, 0.0, 0.5 },
         radius = 0.1,
         width = 2,
         target = { x = pos.x + 0, y = pos.y - 1 },
         surface = p.surface,
         time_to_live = 30,
      })
      rendering.draw_circle({
         color = { 1, 0.0, 0.5 },
         radius = 0.1,
         width = 2,
         target = { x = pos.x + 0, y = pos.y + 1 },
         surface = p.surface,
         time_to_live = 30,
      })
      rendering.draw_circle({
         color = { 1, 0.0, 0.5 },
         radius = 0.1,
         width = 2,
         target = { x = pos.x - 1, y = pos.y - 0 },
         surface = p.surface,
         time_to_live = 30,
      })
      rendering.draw_circle({
         color = { 1, 0.0, 0.5 },
         radius = 0.1,
         width = 2,
         target = { x = pos.x + 1, y = pos.y - 0 },
         surface = p.surface,
         time_to_live = 30,
      })
      local ents_north = p.surface.find_entities_filtered({ position = { x = pos.x + 0, y = pos.y - 1 } })
      local ents_south = p.surface.find_entities_filtered({ position = { x = pos.x + 0, y = pos.y + 1 } })
      local ents_east = p.surface.find_entities_filtered({ position = { x = pos.x + 1, y = pos.y + 0 } })
      local ents_west = p.surface.find_entities_filtered({ position = { x = pos.x - 1, y = pos.y + 0 } })
      local relevant_fluid_north = nil
      local relevant_fluid_east = nil
      local relevant_fluid_south = nil
      local relevant_fluid_west = nil
      local box = nil
      local dir_from_pos = nil

      local north_ent = nil
      for i, ent_cand in ipairs(ents_north) do
         if ent_cand.valid and ent_cand.fluidbox ~= nil then north_ent = ent_cand end
      end
      local south_ent = nil
      for i, ent_cand in ipairs(ents_south) do
         if ent_cand.valid and ent_cand.fluidbox ~= nil then south_ent = ent_cand end
      end
      local east_ent = nil
      for i, ent_cand in ipairs(ents_east) do
         if ent_cand.valid and ent_cand.fluidbox ~= nil then east_ent = ent_cand end
      end
      local west_ent = nil
      for i, ent_cand in ipairs(ents_west) do
         if ent_cand.valid and ent_cand.fluidbox ~= nil then west_ent = ent_cand end
      end
      box, relevant_fluid_north, dir_from_pos = mod.get_relevant_fluidbox_and_fluid_name(north_ent, pos, dirs.north)
      box, relevant_fluid_south, dir_from_pos = mod.get_relevant_fluidbox_and_fluid_name(south_ent, pos, dirs.south)
      box, relevant_fluid_east, dir_from_pos = mod.get_relevant_fluidbox_and_fluid_name(east_ent, pos, dirs.east)
      box, relevant_fluid_west, dir_from_pos = mod.get_relevant_fluidbox_and_fluid_name(west_ent, pos, dirs.west)

      --Prepare result string
      if
         relevant_fluid_north ~= nil
         or relevant_fluid_east ~= nil
         or relevant_fluid_south ~= nil
         or relevant_fluid_west ~= nil
      then
         local count = 0
         table.insert(result, { "fa.connection-pipe-can-connect" })

         if relevant_fluid_north ~= nil then
            table.insert(result, {
               "fa.connection-fluid-at-direction",
               localising.get_localised_name_with_fallback(prototypes.fluid[relevant_fluid_north]),
               { "fa.direction", dirs.north },
            })
            count = count + 1
         end
         if relevant_fluid_east ~= nil then
            table.insert(result, {
               "fa.connection-fluid-at-direction",
               localising.get_localised_name_with_fallback(prototypes.fluid[relevant_fluid_east]),
               { "fa.direction", dirs.east },
            })
            count = count + 1
         end
         if relevant_fluid_south ~= nil then
            table.insert(result, {
               "fa.connection-fluid-at-direction",
               localising.get_localised_name_with_fallback(prototypes.fluid[relevant_fluid_south]),
               { "fa.direction", dirs.south },
            })
            count = count + 1
         end
         if relevant_fluid_west ~= nil then
            table.insert(result, {
               "fa.connection-fluid-at-direction",
               localising.get_localised_name_with_fallback(prototypes.fluid[relevant_fluid_west]),
               { "fa.direction", dirs.west },
            })
            count = count + 1
         end

         --Check which fluids are empty or equal (and thus not mixing invalidly). "Empty" counts too because sometimes a pipe itself is empty but it is still part of a network...
         if
            relevant_fluid_north ~= nil
            and (
               relevant_fluid_north == relevant_fluid_south
               or relevant_fluid_north == relevant_fluid_east
               or relevant_fluid_north == relevant_fluid_west
            )
         then
            count = count - 1
         end
         if
            relevant_fluid_east ~= nil
            and (relevant_fluid_east == relevant_fluid_south or relevant_fluid_east == relevant_fluid_west)
         then
            count = count - 1
         end
         if relevant_fluid_south ~= nil and (relevant_fluid_south == relevant_fluid_west) then count = count - 1 end

         if count > 1 then table.insert(result, { "fa.connection-warning-mixing-fluids" }) end
      end
      --Same as pipe preview but for the faced direction only
   elseif stack.name == "pipe-to-ground" then
      local vp = Viewpoint.get_viewpoint(pindex)
      local face_dir = vp:get_hand_direction()
      local ent_pos = FaUtils.offset_position_legacy(pos, face_dir, 1)
      rendering.draw_circle({
         color = { 1, 0.0, 0.5 },
         radius = 0.1,
         width = 2,
         target = ent_pos,
         surface = p.surface,
         time_to_live = 30,
      })

      local ents_faced = p.surface.find_entities_filtered({ position = ent_pos })
      local relevant_fluid_faced = nil
      local box = nil
      local dir_from_pos = nil

      local faced_ent = nil
      for i, ent_cand in ipairs(ents_faced) do
         if ent_cand.valid and ent_cand.fluidbox ~= nil then faced_ent = ent_cand end
      end

      box, relevant_fluid_faced, dir_from_pos = mod.get_relevant_fluidbox_and_fluid_name(faced_ent, pos, face_dir)
      --Prepare result string
      if relevant_fluid_faced ~= nil then
         local count = 0
         table.insert(result, {
            "fa.connection-connects-directly",
            { "fa.direction", face_dir },
            localising.get_localised_name_with_fallback(prototypes.fluid[relevant_fluid_faced]),
         })
      else
         table.insert(result, { "fa.connection-not-above-ground" })
      end
   end

   --For heat pipes, preview the connection directions
   if ent_p.type == "heat-pipe" then
      table.insert(result, { "fa.connection-heat-pipe-can-connect" })
      local con_targets = mod.get_heat_connection_target_positions("heat-pipe", pos, dirs.north)
      local con_count = 0
      if #con_targets > 0 then
         for i, con_target_pos in ipairs(con_targets) do
            --For each heat connection target position
            rendering.draw_circle({
               color = { 1.0, 0.0, 0.5 },
               radius = 0.1,
               width = 2,
               target = con_target_pos,
               surface = p.surface,
               time_to_live = 30,
            })
            local target_ents = p.surface.find_entities_filtered({ position = con_target_pos })
            for j, target_ent in ipairs(target_ents) do
               if
                  target_ent.valid
                  and #mod.get_heat_connection_positions(target_ent.name, target_ent.position, target_ent.direction)
                     > 0
               then
                  for k, spot in
                     ipairs(
                        mod.get_heat_connection_positions(target_ent.name, target_ent.position, target_ent.direction)
                     )
                  do
                     --For each heat connection of the found target entity
                     rendering.draw_circle({
                        color = { 1.0, 1.0, 0.5 },
                        radius = 0.2,
                        width = 2,
                        target = spot,
                        surface = p.surface,
                        time_to_live = 30,
                     })
                     if util.distance(con_target_pos, spot) < 0.2 then
                        --For each match
                        rendering.draw_circle({
                           color = { 0.5, 1.0, 0.5 },
                           radius = 0.3,
                           width = 2,
                           target = spot,
                           surface = p.surface,
                           time_to_live = 30,
                        })
                        con_count = con_count + 1
                        local con_dir = FaUtils.get_direction_biased(con_target_pos, pos)
                        if con_count > 1 then table.insert(result, { "fa.connection-heat-pipe-and" }) end
                        table.insert(result, { "fa.direction", con_dir })
                     end
                  end
               end
            end
         end
      end
      if con_count == 0 then table.insert(result, { "fa.connection-heat-pipe-to-nothing" }) end
   end
   --For electric poles, report the directions of up to 5 wire-connectible
   -- electric poles that can connect TODO: we can actually just ask now, but
   -- I'm just getting this running enough to limp along for 2.0.
   if ent_p.type == "electric-pole" then
      local pole_dict = surf.find_entities_filtered({
         type = "electric-pole",
         position = pos,
         radius = ent_p.get_max_wire_distance(stack.quality),
      })
      local poles = {}
      for i, v in pairs(pole_dict) do
         local ent_p_mwd = ent_p.get_max_wire_distance(stack.quality)
         local pole_mwd = v.prototype.get_max_wire_distance(v.quality)
         if pole_mwd >= ent_p_mwd or pole_mwd >= util.distance(v.position, pos) then table.insert(poles, v) end
      end
      if #poles > 0 then
         --List the first 4 poles within range
         table.insert(result, { "fa.connection-connecting" })
         for i, pole in ipairs(poles) do
            if i < 5 then
               local dist = math.ceil(util.distance(pole.position, pos))
               local dir = FaUtils.get_direction_biased(pole.position, pos)
               table.insert(result, FaUtils.format_distance_with_direction(dist, helpers.direction_to_string(dir)))
               table.insert(result, ", ")
            end
         end
      else
         --Notify if no connections and state nearest electric pole
         table.insert(result, { "fa.connection-not-connected" })
         local nearest_pole, min_dist = Electrical.find_nearest_electric_pole(nil, false, 50, surf, pos)
         if min_dist == nil or min_dist >= 1000 then
            table.insert(result, { "fa.connection-no-poles-within" })
         else
            local dir = FaUtils.get_direction_biased(nearest_pole.position, pos)
            table.insert(result, {
               "fa.connection-to-nearest-pole",
               FaUtils.format_distance_with_direction(math.ceil(min_dist), helpers.direction_to_string(dir)),
            })
         end
      end
   end

   --For roboports, like electric poles, list possible neighbors (anything within 100 distx or 100 disty will be a neighbor
   if ent_p.name == "roboport" then
      local reach = 48.5
      local top_left = { x = math.floor(pos.x - reach), y = math.floor(pos.y - reach) }
      local bottom_right = { x = math.ceil(pos.x + reach), y = math.ceil(pos.y + reach) }
      local port_dict = surf.find_entities_filtered({ type = "roboport", area = { top_left, bottom_right } })
      local ports = {}
      for i, v in pairs(port_dict) do
         table.insert(ports, v)
      end
      if #ports > 0 then
         --List the first 5 poles within range
         table.insert(result, { "fa.connection-connecting" })
         for i, port in ipairs(ports) do
            if i <= 5 then
               local dist = math.ceil(util.distance(port.position, pos))
               local dir = FaUtils.get_direction_biased(port.position, pos)
               table.insert(result, FaUtils.format_distance_with_direction(dist, helpers.direction_to_string(dir)))
               table.insert(result, ", ")
            end
         end
      else
         --Notify if no connections and state nearest roboport
         table.insert(result, { "fa.connection-not-connected" })
         local max_dist = 2000
         local nearest_port, min_dist = FaUtils.find_nearest_roboport(p.surface, p.position, max_dist)
         if min_dist == nil or min_dist >= max_dist then
            table.insert(result, { "fa.connection-no-roboports-within" })
         else
            local dir = FaUtils.get_direction_biased(nearest_port.position, pos)
            table.insert(result, {
               "fa.connection-to-nearest-roboport",
               FaUtils.format_distance_with_direction(math.ceil(min_dist), helpers.direction_to_string(dir)),
            })
         end
      end
   end

   --For logistic chests, list whether there is a network nearby
   if ent_p.type == "logistic-container" then
      local network = p.surface.find_logistic_network_by_position(pos, p.force)
      if network == nil then
         local nearest_roboport = FaUtils.find_nearest_roboport(p.surface, pos, 5000)
         if nearest_roboport == nil then
            table.insert(result, { "fa.connection-not-in-network" })
         else
            local dist = math.ceil(util.distance(pos, nearest_roboport.position) - 25)
            local dir = FaUtils.direction_lookup(FaUtils.get_direction_biased(nearest_roboport.position, pos))
            table.insert(
               result,
               { "fa.connection-not-in-network-nearest", FaUtils.format_distance_with_direction(dist, dir) }
            )
         end
      else
         local network_name = network.cells[1].owner.backer_name
         table.insert(result, { "fa.connection-in-network", network_name })
      end
   end

   --For rail signals, check for valid placement
   if ent_p.name == "rail-signal" or ent_p.name == "rail-chain-signal" then
      -- Rail signals not supported in 2.0 yet
      table.insert(result, { "fa.trains-not-supported" })
   end

   --For all electric powered entities, note whether powered, and from which direction. Otherwise report the nearest power pole.
   if ent_p.electric_energy_source_prototype ~= nil then
      local vp = Viewpoint.get_viewpoint(pindex)
      local position = pos
      local build_dir = vp:get_hand_direction()

      position.x = position.x + math.ceil(2 * ent_p.selection_box.right_bottom.x) / 2 - 0.5
      position.y = position.y + math.ceil(2 * ent_p.selection_box.right_bottom.y) / 2 - 0.5

      local dict = prototypes.get_entity_filtered({ { filter = "type", type = "electric-pole" } })
      local poles = {}
      for i, v in pairs(dict) do
         table.insert(poles, v)
      end
      table.sort(poles, function(k1, k2)
         return k1.get_supply_area_distance() < k2.get_supply_area_distance()
      end)
      local check = false
      ---@type LuaEntity
      local found_pole = nil
      for i, pole in ipairs(poles) do
         local names = {}
         for i1 = i, #poles, 1 do
            table.insert(names, poles[i1].name)
         end
         local supply_dist = pole.get_supply_area_distance()
         if supply_dist > 15 then supply_dist = supply_dist - 2 end
         local area = {
            left_top = {
               (position.x + math.ceil(ent_p.selection_box.left_top.x) - supply_dist),
               (position.y + math.ceil(ent_p.selection_box.left_top.y) - supply_dist),
            },
            right_bottom = {
               (position.x + math.floor(ent_p.selection_box.right_bottom.x) + supply_dist),
               (position.y + math.floor(ent_p.selection_box.right_bottom.y) + supply_dist),
            },
            orientation = build_dir / (2 * dirs.south),
         } --**laterdo "connected" check is a little buggy at the supply area edges, need to trim and tune, maybe re-enable direction based offset? The offset could be due to the pole width: 1 vs 2, maybe just make it more conservative?
         local T = {
            area = area,
            name = names,
         }
         local supplier_poles = surf.find_entities_filtered(T)
         if #supplier_poles > 0 then
            check = true
            found_pole = supplier_poles[1]
            break
         end
      end
      if check then
         table.insert(result, { "fa.connection-power-connected" })
         if found_pole.valid then
            local dist = math.ceil(util.distance(found_pole.position, pos))
            local dir = FaUtils.get_direction_biased(found_pole.position, pos)
            table.insert(result, {
               "fa.connection-from-direction",
               FaUtils.format_distance_with_direction(dist, helpers.direction_to_string(dir)),
            })
         end
      else
         table.insert(result, { "fa.connection-power-not-connected" })
         --Notify if no connections and state nearest electric pole
         local nearest_pole, min_dist = Electrical.find_nearest_electric_pole(nil, false, 50, surf, pos)
         if min_dist == nil or min_dist >= 1000 then
            table.insert(result, { "fa.connection-no-poles-within" })
         else
            local dir = FaUtils.get_direction_biased(nearest_pole.position, pos)
            table.insert(result, {
               "fa.connection-to-nearest-pole",
               FaUtils.format_distance_with_direction(math.ceil(min_dist), helpers.direction_to_string(dir)),
            })
         end
      end
   end

   if util.distance(pos, storage.players[pindex].position) > p.reach_distance + 2 then
      table.insert(result, { "fa.connection-cursor-out-of-reach" })
   end
   return result
end

--For a building with fluidboxes, returns the external fluidbox and fluid name that would connect to one of the building's own fluidboxes at a particular position, from a particular direction. Importantly, ignores fluidboxes that are positioned correctly but would not connect, such as a pipe to ground facing a perpebdicular direction.
function mod.get_relevant_fluidbox_and_fluid_name(building, pos, dir_from_pos)
   local relevant_box = nil
   local relevant_fluid_name = nil
   if building ~= nil and building.valid and building.fluidbox ~= nil then
      rendering.draw_circle({
         color = { 1, 1, 0 },
         radius = 0.2,
         width = 2,
         target = building.position,
         surface = building.surface,
         time_to_live = 30,
      })
      --Run checks to see if we have any fluidboxes that are relevant
      for i = 1, #building.fluidbox, 1 do
         for j, con in ipairs(building.fluidbox.get_pipe_connections(i)) do
            local target_pos = con.target_position
            local con_pos = con.position
            rendering.draw_circle({
               color = { 1, 0, 0 },
               radius = 0.2,
               width = 2,
               target = target_pos,
               surface = building.surface,
               time_to_live = 30,
            })
            if
               util.distance(target_pos, pos) < 0.3
               and FaUtils.get_direction_biased(con_pos, pos) == dir_from_pos
               and not (building.name == "pipe-to-ground" and building.direction == dir_from_pos)
            then --Note: We correctly ignore the backside of a pipe to ground.
               rendering.draw_circle({
                  color = { 0, 1, 0 },
                  radius = 0.3,
                  width = 2,
                  target = target_pos,
                  surface = building.surface,
                  time_to_live = 30,
               })
               relevant_box = building.fluidbox[i]
               if building.fluidbox[i] ~= nil then
                  relevant_fluid_name = building.fluidbox[i].name
               elseif building.fluidbox.get_locked_fluid(i) ~= nil then
                  relevant_fluid_name = building.fluidbox.get_locked_fluid(i)
               else
                  relevant_fluid_name = nil -- Empty pipe, no fluid
               end
            end
         end
      end
   end
   return relevant_box, relevant_fluid_name, dir_from_pos
end

--If the player is standing within the build area, they are teleported out.
function mod.teleport_player_out_of_build_area(left_top, right_bottom, pindex)
   local p = game.get_player(pindex)
   if not p.character then return end
   if not left_top or not right_bottom then return end
   local pos = p.character.position
   if pos.x < left_top.x or pos.x > right_bottom.x or pos.y < left_top.y or pos.y > right_bottom.y then return end
   if p.walking_state.walking == true then return end

   local exits = {}
   exits[1] = { x = left_top.x - 1, y = left_top.y - 0 }
   exits[2] = { x = left_top.x - 0, y = left_top.y - 1 }
   exits[3] = { x = left_top.x - 1, y = left_top.y - 1 }
   exits[4] = { x = left_top.x - 2, y = left_top.y - 0 }
   exits[5] = { x = left_top.x - 0, y = left_top.y - 2 }
   exits[6] = { x = left_top.x - 2, y = left_top.y - 2 }

   --Teleport to exit spots if possible
   for i, pos in ipairs(exits) do
      if p.surface.can_place_entity({ name = "character", position = pos }) then
         Teleport.teleport_to_closest(pindex, pos, false, true)
         return
      end
   end

   --Teleport best effort to -2, -2
   Teleport.teleport_to_closest(pindex, exits[6], false, true)
end

--Assuming there is a steam engine in hand, this function will automatically build it next to a suitable boiler.
function mod.snap_place_steam_engine_to_a_boiler(pindex)
   local p = game.get_player(pindex)
   local found_empty_spot = false
   local found_valid_spot = false
   --Locate all boilers within 10m
   local boilers = p.surface.find_entities_filtered({ name = "boiler", position = p.position, radius = 10 })

   --If none then locate all boilers within 25m
   if boilers == nil or #boilers == 0 then
      boilers = p.surface.find_entities_filtered({ name = "boiler", position = p.position, radius = 25 })
   end

   if boilers == nil or #boilers == 0 then
      p.play_sound({ path = "utility/cannot_build" })
      Speech.speak(pindex, { "fa.building-error-no-boilers" })
      return
   end

   --For each boiler found:
   for i, boiler in ipairs(boilers) do
      --Check if there is any entity in front of it
      local output_location = FaUtils.offset_position_legacy(boiler.position, boiler.direction, 1.5)
      rendering.draw_circle({
         color = { 1, 1, 0.25 },
         radius = 0.25,
         width = 2,
         target = output_location,
         surface = p.surface,
         time_to_live = 60,
         draw_on_ground = false,
      })
      local output_ents = p.surface.find_entities_filtered({
         position = output_location,
         radius = 0.25,
         type = { "resource", "generator" },
         invert = true,
      })
      if output_ents == nil or #output_ents == 0 then
         --Determine engine position based on boiler direction
         found_empty_spot = true
         local engine_position = output_location
         local dir = boiler.direction
         local vp = Viewpoint.get_viewpoint(pindex)
         local old_building_dir = vp:get_hand_direction()
         vp:set_hand_direction(dir)
         if dir == dirs.east then
            engine_position = FaUtils.offset_position_legacy(engine_position, dirs.east, 2)
         elseif dir == dirs.south then
            engine_position = FaUtils.offset_position_legacy(engine_position, dirs.south, 2)
         elseif dir == dirs.west then
            engine_position = FaUtils.offset_position_legacy(engine_position, dirs.west, 2)
         elseif dir == dirs.north then
            engine_position = FaUtils.offset_position_legacy(engine_position, dirs.north, 2)
         end
         rendering.draw_circle({
            color = { 0.25, 1, 0.25 },
            radius = 0.5,
            width = 2,
            target = engine_position,
            surface = p.surface,
            time_to_live = 60,
            draw_on_ground = false,
         })
         PlayerMiningTools.clear_obstacles_in_circle(engine_position, 4, pindex)
         --Check if can build from cursor to the relative position
         if p.can_build_from_cursor({ position = engine_position, direction = dir }) then
            p.build_from_cursor({ position = engine_position, direction = dir })
            found_valid_spot = true
            Speech.speak(
               pindex,
               "Placed steam engine near boiler at "
                  .. math.floor(boiler.position.x)
                  .. ","
                  .. math.floor(boiler.position.y)
            )
            return
         end
      end
   end
   --If all have been skipped and none were found then play error
   if found_empty_spot == false then
      p.play_sound({ path = "utility/cannot_build" })
      Speech.speak(pindex, { "fa.building-error-boilers-blocked" })
      return
   elseif found_valid_spot == false then
      p.play_sound({ path = "utility/cannot_build" })
      Speech.speak(pindex, { "fa.building-error-boilers-obstacles" })
      return
   end
end

--Identifies if a pipe is a pipe end, so that it can be singled out. The motivation is that pipe ends generally should not exist because the pipes should connect to something.
---@param ent LuaEntity
function mod.is_a_pipe_end(ent)
   local boxes = ent.fluidbox
   local connections = 0
   for i = 1, #boxes do
      local outgoing = boxes.get_pipe_connections(i)
      for j = 1, #outgoing do
         if outgoing[j].target then connections = connections + 1 end
         if connections > 1 then return false end
      end
   end

   return connections == 1
end

--Scans an area to identify obstacles for building there
function mod.identify_building_obstacle(pindex, area, ent_to_ignore)
   local p = game.get_player(pindex)
   local ent_ignored = ent_to_ignore or nil
   local result = { "", "Cannot build" }
   --Check for an entity in the way
   local ents_in_area = p.surface.find_entities_filtered({
      area = area,
      invert = true,
      type = Consts.ENT_TYPES_YOU_CAN_BUILD_OVER,
   })
   local obstacle_ent = nil
   for i, area_ent in ipairs(ents_in_area) do
      if
         area_ent.valid
         and area_ent.prototype.tile_width
         and area_ent.prototype.tile_width > 0
         and area_ent.prototype.tile_height
         and area_ent.prototype.tile_height > 0
         and (ent_ignored == nil or ent_ignored.unit_number ~= area_ent.unit_number)
      then
         obstacle_ent = area_ent
      end
   end
   --Check for water in the area
   local water_tiles_in_area = p.surface.find_tiles_filtered({
      area = area,
      invert = false,
      name = {
         "water",
         "deepwater",
         "water-green",
         "deepwater-green",
         "water-shallow",
         "water-mud",
         "water-wube",
      },
   })
   --Report obstacles
   if obstacle_ent ~= nil then
      table.insert(result, ", ")
      table.insert(result, localising.get_localised_name_with_fallback(obstacle_ent))
      table.insert(result, " in the way, at ")
      table.insert(result, tostring(math.floor(obstacle_ent.position.x)))
      table.insert(result, ", ")
      table.insert(result, tostring(math.floor(obstacle_ent.position.y)))
   elseif #water_tiles_in_area > 0 then
      local water = water_tiles_in_area[1]
      table.insert(result, ", water ")
      table.insert(result, " in the way, at ")
      table.insert(result, tostring(math.floor(water.position.x)))
      table.insert(result, ", ")
      table.insert(result, tostring(math.floor(water.position.y)))
   end
   return result
end

return mod
