--Here: Functions for building with the mod, both basics and advanced tools.
local BuildDimensions = require("scripts.build-dimensions")
local Consts = require("scripts.consts")
local Electrical = require("scripts.electrical")
local FaUtils = require("scripts.fa-utils")
local localising = require("scripts.localising")
local dirs = defines.direction
local Graphics = require("scripts.graphics")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local PlayerMiningTools = require("scripts.player-mining-tools")
local Teleport = require("scripts.teleport")
local TransportBelts = require("scripts.transport-belts")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---@class fa.BuildingTools.BuildDecision
---@field entity_name? string Name of entity to build (nil for tiles)
---@field tile_name? string Name of tile to build (nil for entities)
---@field position MapPosition Final build position
---@field direction defines.direction Final build direction
---@field flip_horizontal boolean
---@field flip_vertical boolean
---@field footprint_left_top MapPosition
---@field footprint_right_bottom MapPosition
---@field is_tile boolean
---@field terrain_building_size? integer For tiles only
---@field skip_reason? LocalisedString If build should be skipped

---Calculate what to build and where, without actually building it.
---This is the "decider" function that determines all build parameters.
---Includes some side effects: graphics sync, storage updates, turn_to_cursor_direction_cardinal.
---@param params fa.BuildingTools.BuildItemParams
---@return fa.BuildingTools.BuildDecision? decision nil if should skip
function mod.calculate_build_params(params)
   local pindex = params.pindex
   local building_direction = params.building_direction
   local flip_horizontal = params.flip_horizontal or false
   local flip_vertical = params.flip_vertical or false

   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   local vp = Viewpoint.get_viewpoint(pindex)
   local pos = vp:get_cursor_pos()

   -- Ensure building footprint is up to date
   Graphics.sync_build_cursor_graphics(pindex)

   -- Handle entities
   if stack.prototype.place_result ~= nil then
      local ent = stack.prototype.place_result
      local placing_underground_belt = stack.prototype.place_result.type == "underground-belt"

      -- Calculate footprint using centralized function
      local footprint = FaUtils.calculate_building_footprint({
         entity_prototype = stack.prototype.place_result,
         position = pos,
         building_direction = building_direction,
         player_direction = storage.players[pindex].player_direction,
         is_rail_vehicle = false,
      })

      turn_to_cursor_direction_cardinal(pindex)

      local position = footprint.center

      -- Store the calculated footprint for later use
      storage.players[pindex].building_footprint_left_top = footprint.left_top
      storage.players[pindex].building_footprint_right_bottom = footprint.right_bottom

      local actual_build_direction = building_direction
      if placing_underground_belt then
         -- Auto-detect if placing would form an exit
         local would_auto_exit =
            TransportBelts.would_form_underground_exit(p.surface, ent, position, building_direction)
         if would_auto_exit then
            --Flip the chute by 180 degrees
            actual_build_direction = (building_direction + dirs.south) % (2 * dirs.south)
         end
      end

      return {
         entity_name = stack.prototype.place_result.name,
         tile_name = nil,
         position = position,
         direction = actual_build_direction,
         flip_horizontal = flip_horizontal,
         flip_vertical = flip_vertical,
         footprint_left_top = footprint.left_top,
         footprint_right_bottom = footprint.right_bottom,
         is_tile = false,
      }
   elseif stack and stack.valid_for_read and stack.valid and stack.prototype.place_as_tile_result ~= nil then
      -- Tile placement
      local cursor_size = vp:get_cursor_size()
      local t_size = cursor_size * 2 + 1

      pos.x = pos.x - cursor_size
      pos.y = pos.y - cursor_size
      vp:set_cursor_pos(pos)

      return {
         entity_name = nil,
         tile_name = stack.prototype.place_as_tile_result.name,
         position = pos,
         direction = building_direction,
         flip_horizontal = false,
         flip_vertical = false,
         footprint_left_top = pos,
         footprint_right_bottom = { x = pos.x + t_size, y = pos.y + t_size },
         is_tile = true,
         terrain_building_size = t_size,
      }
   else
      -- Empty hand or invalid item
      return nil
   end
end

---Prepare the build area by clearing obstacles and teleporting player.
---This is shared between cursor building and ghost placement.
---@param pindex integer
---@param decision fa.BuildingTools.BuildDecision
---@param teleport_player boolean
function mod.prepare_build_area(pindex, decision, teleport_player)
   -- Clear build area obstacles
   PlayerMiningTools.clear_obstacles_in_rectangle(decision.footprint_left_top, decision.footprint_right_bottom, pindex)

   -- Teleport player out of build area (if enabled)
   if teleport_player then
      mod.teleport_player_out_of_build_area(decision.footprint_left_top, decision.footprint_right_bottom, pindex)
   end
end

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
---@field flip_horizontal? boolean Whether to flip the blueprint horizontally (default false)
---@field flip_vertical? boolean Whether to flip the blueprint vertically (default false)
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
   local teleport_player = params.teleport_player ~= false -- default true
   local play_error_sound = params.play_error_sound ~= false -- default true
   local speak_errors = params.speak_errors ~= false -- default true

   local p = game.get_player(pindex)
   local stack = p.cursor_stack

   -- Calculate what to build (includes graphics sync, storage updates, underground belt logic, etc)
   local decision = mod.calculate_build_params(params)
   if not decision then
      -- Empty hand or invalid item
      p.play_sound({ path = "utility/cannot_build" })
      return false
   end

   -- Prepare build area (clear obstacles, teleport player)
   mod.prepare_build_area(pindex, decision, teleport_player)

   -- Execute the build
   if decision.is_tile then
      -- Tile placement
      if
         p.can_build_from_cursor({
            position = decision.position,
            terrain_building_size = decision.terrain_building_size,
         })
      then
         p.build_from_cursor({ position = decision.position, terrain_building_size = decision.terrain_building_size })
         return true
      else
         if play_error_sound then p.play_sound({ path = "utility/cannot_build" }) end
         return false
      end
   else
      -- Entity placement
      local building = {
         position = decision.position,
         direction = decision.direction,
         alt = false,
         flip_horizontal = decision.flip_horizontal,
         flip_vertical = decision.flip_vertical,
      }

      if p.can_build_from_cursor(building) then
         p.build_from_cursor(building)
         return true
      else
         -- Report errors (if enabled)
         if play_error_sound then p.play_sound({ path = "utility/cannot_build" }) end

         -- Explain build error (if enabled)
         if speak_errors then
            local build_area = { decision.footprint_left_top, decision.footprint_right_bottom }
            local result = mod.identify_building_obstacle(pindex, build_area, nil)
            Speech.speak(pindex, result)
         end
         return false
      end
   end
end

---Build a blueprint or blueprint book
---@param pindex integer Player index
---@param flip_horizontal? boolean Whether to flip horizontally
---@param flip_vertical? boolean Whether to flip vertically
---@return boolean success True if blueprint was placed successfully
function mod.build_blueprint(pindex, flip_horizontal, flip_vertical)
   local p = game.get_player(pindex)
   local cursor_stack = p.cursor_stack
   local vp = Viewpoint.get_viewpoint(pindex)
   local pos = vp:get_cursor_pos()

   -- Verify we have a blueprint or blueprint book
   if not cursor_stack or not cursor_stack.valid_for_read then return false end
   if not cursor_stack.is_blueprint and not cursor_stack.is_blueprint_book then return false end

   local is_book = cursor_stack.is_blueprint_book
   local temp_inv = nil

   -- Handle blueprint books: temporarily swap to active blueprint
   if is_book then
      local book_inv = cursor_stack.get_inventory(defines.inventory.item_main)
      if not book_inv or not cursor_stack.active_index then return false end

      local active_bp = book_inv[cursor_stack.active_index]
      if not active_bp or not active_bp.valid_for_read or not active_bp.is_blueprint_setup() then return false end

      -- Create temporary script inventory to hold the book
      temp_inv = game.create_inventory(1)

      -- Move book to temp_inv, set cursor to active blueprint (clones it)
      temp_inv[1].swap_stack(cursor_stack)
      cursor_stack.set_stack(active_bp)
   else
      -- Regular blueprint
      if not cursor_stack.is_blueprint_setup() then return false end
   end

   -- Get the build dimensions and position
   local dir = vp:get_hand_direction()
   local width, height = BuildDimensions.get_stack_build_dimensions(cursor_stack, dir)
   local left_top = { x = math.floor(pos.x), y = math.floor(pos.y) }
   local right_bottom = { x = math.ceil(pos.x + width), y = math.ceil(pos.y + height) }
   local build_pos = { x = pos.x + width / 2, y = pos.y + height / 2 }

   -- Clear build area
   PlayerMiningTools.clear_obstacles_in_rectangle(left_top, right_bottom, pindex, 99)

   -- Try to build
   local can_build = p.can_build_from_cursor({
      position = build_pos,
      direction = dir,
      flip_horizontal = flip_horizontal or false,
      flip_vertical = flip_vertical or false,
   })

   local success = false
   if can_build then
      p.build_from_cursor({
         position = build_pos,
         direction = dir,
         flip_horizontal = flip_horizontal or false,
         flip_vertical = flip_vertical or false,
      })
      p.play_sound({ path = "Close-Inventory-Sound" })

      -- Get label for feedback
      local label = cursor_stack.label or "unnamed"
      Speech.speak(pindex, { "fa.blueprints-placed", label })
      success = true
   else
      p.play_sound({ path = "utility/cannot_build" })
      -- Explain build error
      local build_area = { left_top, right_bottom }
      local result = mod.identify_building_obstacle(pindex, build_area, nil)
      Speech.speak(pindex, result)
      success = false
   end

   -- Restore book to cursor if we were using a blueprint book
   if is_book and temp_inv then
      temp_inv[1].swap_stack(p.cursor_stack)
      temp_inv.destroy()
   end

   return success
end

---Place a ghost entity using the calculated build parameters.
---This is a stub that will be implemented to support ghost placement without cursor interaction.
---@param params fa.BuildingTools.BuildItemParams Build parameters
---@return boolean success True if ghost was placed successfully
function mod.place_ghost_with_params(params)
   local pindex = params.pindex
   local p = game.get_player(pindex)
   local stack = p.cursor_stack

   -- Calculate what to build
   local decision = mod.calculate_build_params(params)
   if not decision then
      p.play_sound({ path = "utility/cannot_build" })
      return false
   end

   -- Skip tiles for now (ghosts are primarily for entities)
   if decision.is_tile then
      Speech.speak(pindex, { "fa.building-ghost-tiles-not-supported" })
      return false
   end

   -- Create the ghost entity (no obstacle clearing or teleportation for ghosts)
   local ghost = p.surface.create_entity({
      name = "entity-ghost",
      inner_name = decision.entity_name,
      position = decision.position,
      direction = decision.direction,
      force = p.force,
      player = pindex,
      quality = stack.quality,
   })

   if ghost then
      Speech.speak(pindex, { "fa.building-placed-ghost", { "entity-name." .. decision.entity_name } })
      return true
   else
      -- Ghost placement failed
      if params.play_error_sound ~= false then p.play_sound({ path = "utility/cannot_build" }) end
      if params.speak_errors ~= false then
         local build_area = { decision.footprint_left_top, decision.footprint_right_bottom }
         local result = mod.identify_building_obstacle(pindex, build_area, nil)
         Speech.speak(pindex, result)
      end
      return false
   end
end

--[[Assisted building function for offshore pumps.
* Called as a special case by build_item_in_hand_with_params
]]
function mod.build_offshore_pump_in_hand(pindex)
   local p = game.get_player(pindex)
   local stack = p.cursor_stack

   if stack and stack.valid and stack.valid_for_read and stack.name == "offshore-pump" then
      local positions = {}
      local initial_position = p.position
      initial_position.x = math.floor(initial_position.x)
      initial_position.y = math.floor(initial_position.y)
      for i1 = -10, 10 do
         for i2 = -10, 10 do
            for i3 = 0, 3 do
               local position = { x = initial_position.x + i1, y = initial_position.y + i2 }
               -- BUG: factorio 2.0 plays a sound for can_build_from_cursor if pointed at out of reach tiles
               if FaUtils.distance(position, p.position) > p.build_distance then goto continue end

               ---@type defines.direction
               local dir_3 = i3 * dirs.east
               if p.can_build_from_cursor({ name = "offshore-pump", position = position, direction = dir_3 }) then
                  table.insert(positions, { position = position, direction = dir_3 })
               end
            end

            ::continue::
         end
      end
      if #positions == 0 then
         Speech.speak(pindex, { "fa.building-pump-no-positions" })
      else
         table.sort(positions, function(k1, k2)
            return util.distance(initial_position, k1.position) < util.distance(initial_position, k2.position)
         end)
         UiRouter.get_router(pindex):open_ui(UiRouter.UI_NAMES.PUMP, { positions = positions })
      end
   end
end

---Check if the item in cursor can be rotated (has rotation support)
---@param stack LuaItemStack
---@return boolean can_rotate True if the stack can be rotated
function mod.can_rotate_item(stack)
   if not stack or not stack.valid_for_read or not stack.valid then return false end

   local rotation_count = BuildDimensions.get_rotation_count(stack)
   return rotation_count ~= nil
end

--Reads the result of rotating an item in hand
function mod.rotate_item_in_hand(event, forward)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   if not check_for_player(pindex) then return end

   local mult = 1
   if forward == false then mult = -1 end
   local stack = p.cursor_stack
   local vp = Viewpoint.get_viewpoint(pindex)

   -- Check if item in hand can rotate
   if mod.can_rotate_item(stack) then
      local rotation_count = BuildDimensions.get_rotation_count(stack)
      -- Adjust mult for 2-way rotation
      if rotation_count == 2 then mult = mult * 2 end

      -- Update the hand direction
      p.play_sound({ path = "Rotate-Hand-Sound" })
      local build_dir = vp:get_hand_direction()
      local new_dir = (build_dir + dirs.east * mult) % (2 * dirs.south)
      vp:set_hand_direction(new_dir)

      -- For blueprints and blueprint books, just announce direction
      if stack.is_blueprint or stack.is_blueprint_book then
         Speech.speak(pindex, FaUtils.direction_lookup(new_dir))
      else
         Speech.speak(pindex, { "fa.building-rotation-in-hand", FaUtils.direction_lookup(new_dir) })
      end
      return
   elseif stack and stack.valid_for_read and stack.valid and stack.prototype.place_result then
      Speech.speak(pindex, { "fa.building-no-rotate-support", { "item-name." .. stack.name } })
      return
   end

   -- Nothing in hand - entity rotation will be handled by on_player_rotated_entity event
end

--Reads the result of rotating an entity on the map (called from on_player_rotated_entity event)
function mod.on_entity_rotated(event)
   local pindex = event.player_index
   local ent = event.entity

   if not ent or not ent.valid then return end

   -- Use direction for entities that support it, orientation for vehicles and others
   local dir
   if ent.supports_direction then
      dir = ent.direction
   else
      dir = FaUtils.get_heading_value(ent)
   end

   Speech.speak(pindex, FaUtils.direction_lookup(dir))
end

--Handles flipping an item in hand horizontally
function mod.flip_item_in_hand_horizontal(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   if not check_for_player(pindex) then return end

   local stack = p.cursor_stack
   local vp = Viewpoint.get_viewpoint(pindex)

   -- Only blueprints and blueprint books can be flipped in hand
   if stack and stack.valid_for_read and stack.valid and (stack.is_blueprint or stack.is_blueprint_book) then
      local flipped = not vp:get_flipped_horizontal()
      vp:set_flipped_horizontal(flipped)
      Speech.speak(pindex, { "fa.flipped-horizontal" })
      return
   end

   -- If there's a rotatable item in hand that's not a blueprint, error
   if mod.can_rotate_item(stack) then
      Speech.speak(pindex, { "fa.cannot-flip-non-blueprint-in-hand" })
      return
   end

   -- Nothing in hand - entity flipping will be handled by on_player_flipped_entity event
end

--Handles flipping an item in hand vertically
function mod.flip_item_in_hand_vertical(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   if not check_for_player(pindex) then return end

   local stack = p.cursor_stack
   local vp = Viewpoint.get_viewpoint(pindex)

   -- Only blueprints and blueprint books can be flipped in hand
   if stack and stack.valid_for_read and stack.valid and (stack.is_blueprint or stack.is_blueprint_book) then
      local flipped = not vp:get_flipped_vertical()
      vp:set_flipped_vertical(flipped)
      Speech.speak(pindex, { "fa.flipped-vertical" })
      return
   end

   -- If there's a rotatable item in hand that's not a blueprint, error
   if mod.can_rotate_item(stack) then
      Speech.speak(pindex, { "fa.cannot-flip-non-blueprint-in-hand" })
      return
   end

   -- Nothing in hand - entity flipping will be handled by on_player_flipped_entity event
end

--Reads the result of flipping an entity on the map (called from on_player_flipped_entity event)
function mod.on_entity_flipped(event)
   local pindex = event.player_index
   local ent = event.entity
   local horizontal = event.horizontal

   if not ent or not ent.valid then return end

   -- Announce which flip was performed
   if horizontal then
      Speech.speak(pindex, { "fa.flipped-horizontal" })
   else
      Speech.speak(pindex, { "fa.flipped-vertical" })
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
            local build_area = { left_top, right_bottom }
            local obstacle_message = mod.identify_building_obstacle(pindex, build_area, ent)
            Speech.speak(pindex, obstacle_message)
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
      return { "fa.building-cannot-place-here" }
   end

   --For underground belts, state the potential neighbor
   if ent_p.type == "underground-belt" then
      local entrance, actual_dist = TransportBelts.find_underground_entrance(surf, ent_p, pos, build_dir)
      if entrance then
         rendering.draw_circle({
            color = { 0, 1, 0 },
            radius = 1.0,
            width = 3,
            target = entrance.position,
            surface = entrance.surface,
            time_to_live = 60,
         })
         table.insert(result, {
            "fa.connection-connects-underground",
            { "fa.direction", build_dir },
            tostring(actual_dist - 1),
         })
      else
         table.insert(result, { "fa.connection-not-connected-pipe" })
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
   -- electric poles that can connect.
   if ent_p.type == "electric-pole" then
      -- Calculate center position of the entity being placed
      local footprint = FaUtils.calculate_building_footprint({
         entity_prototype = ent_p,
         position = pos,
         building_direction = build_dir,
      })
      local pole_center = footprint.center

      local pole_dict = surf.find_entities_filtered({
         type = "electric-pole",
         position = pole_center,
         radius = ent_p.get_max_wire_distance(stack.quality),
      })
      local poles = {}
      for i, v in pairs(pole_dict) do
         local ent_p_mwd = ent_p.get_max_wire_distance(stack.quality)
         local pole_mwd = v.prototype.get_max_wire_distance(v.quality)
         local max_allowed = math.min(ent_p_mwd, pole_mwd)
         -- Use center-to-center distance for accurate calculation
         if max_allowed >= util.distance(v.position, pole_center) then table.insert(poles, v) end
      end
      if #poles > 0 then
         --List the first 4 poles within range
         table.insert(result, { "fa.connection-connecting" })
         for i, pole in ipairs(poles) do
            if i < 5 then
               -- Use center-to-center distance for accurate reporting
               local dist = math.ceil(util.distance(pole.position, pole_center))
               local dir = FaUtils.get_direction_biased(pole.position, pole_center)
               table.insert(result, FaUtils.format_distance_with_direction(dist, helpers.direction_to_string(dir)))
               table.insert(result, ", ")
            end
         end
      else
         --Notify if no connections and state nearest electric pole
         table.insert(result, { "fa.connection-not-connected" })
         local nearest_pole, min_dist = Electrical.find_nearest_electric_pole(nil, false, 50, surf, pole_center)
         if min_dist == nil or min_dist >= 1000 then
            table.insert(result, { "fa.connection-no-poles-within" })
         else
            local dir = FaUtils.get_direction_biased(nearest_pole.position, pole_center)
            table.insert(result, {
               "fa.connection-to-nearest-pole",
               FaUtils.format_distance_with_direction(math.ceil(min_dist), helpers.direction_to_string(dir)),
            })
         end
      end
   end

   --For roboports, like electric poles, list possible neighbors (anything within 100 distx or 100 disty will be a neighbor
   if ent_p.type == "roboport" then
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
               { "fa.building-placed-steam-engine", math.floor(boiler.position.x), math.floor(boiler.position.y) }
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
   local message = MessageBuilder.new()
   message:fragment({ "fa.cannot-build" })

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
      message:fragment({
         "fa.building-obstacle-in-way",
         localising.get_localised_name_with_fallback(obstacle_ent),
         math.floor(obstacle_ent.position.x),
         math.floor(obstacle_ent.position.y),
      })
   elseif #water_tiles_in_area > 0 then
      local water = water_tiles_in_area[1]
      message:fragment({ "fa.building-water-in-way", math.floor(water.position.x), math.floor(water.position.y) })
   end
   return message:build()
end

return mod
