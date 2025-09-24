require("syntrax")

--Main file for mod runtime
local Logging = require("scripts.logging")
Logging.init()

-- Create logger for control.lua
local logger = Logging.Logger("control")

local util = require("util")

local AreaOperations = require("scripts.area-operations")
local AudioCues = require("scripts.audio-cues")
local Blueprints = require("scripts.blueprints")
local BuildingTools = require("scripts.building-tools")
-- Removed BuildingVehicleSectors - migrating to capability-based UI
local BumpDetection = require("scripts.bump-detection")
local CircuitNetworks = require("scripts.circuit-networks")
local Combat = require("scripts.combat")
local Consts = require("scripts.consts")
local Crafting = require("scripts.crafting")
local Driving = require("scripts.driving")
local Electrical = require("scripts.electrical")
local EntitySelection = require("scripts.entity-selection")
local Equipment = require("scripts.equipment")
local EventManager = require("scripts.event-manager")
local FaCommands = require("scripts.fa-commands")
local FaInfo = require("scripts.fa-info")
local FaUtils = require("scripts.fa-utils")
local F = require("scripts.field-ref")
local Filters = require("scripts.filters")
local Graphics = require("scripts.graphics")
local InventoryTransfers = require("scripts.inventory-transfers")
local ItemDescriptions = require("scripts.item-descriptions")
local KruiseKontrol = require("scripts.kruise-kontrol-wrapper")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local Mouse = require("scripts.mouse")
local PlayerInit = require("scripts.player-init")
local PlayerMiningTools = require("scripts.player-mining-tools")
local Quickbar = require("scripts.quickbar")
local Research = require("scripts.research")
local Rulers = require("scripts.rulers")
local ScannerEntrypoint = require("scripts.scanner.entrypoint")
local Spidertron = require("scripts.spidertron")
local TH = require("scripts.table-helpers")
local Teleport = require("scripts.teleport")
local TestFramework = require("scripts.test-framework")
local TransportBelts = require("scripts.transport-belts")
local TravelTools = require("scripts.travel-tools")
local TutorialSystem = require("scripts.tutorial-system")
-- UI modules (required for registration with router)
require("scripts.ui.belt-analyzer")
local EntityUI = require("scripts.ui.entity-ui")
require("scripts.ui.menus.blueprints-menu")
require("scripts.ui.menus.gun-menu")
require("scripts.ui.menus.main-menu")
require("scripts.ui.menus.roboport-menu")
require("scripts.ui.menus.spidertron-menu")
require("scripts.ui.generic-inventory")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")
local Warnings = require("scripts.warnings")
local WorkQueue = require("scripts.work-queue")
local WorkerRobots = require("scripts.worker-robots")
local Zoom = require("scripts.zoom")
local sounds = require("scripts.ui.sounds")

---@meta scripts.shared-types

groups = {}
entity_types = {}
production_types = {}
building_types = {}
local dirs = defines.direction

-- Initialize players as a deny-access table to catch any direct usage
players = TH.deny_access_table()

--This function gets scheduled.
function call_to_fix_zoom(pindex)
   Zoom.fix_zoom(pindex)
end

--This function gets scheduled.
function call_to_sync_graphics(pindex)
   Graphics.sync_build_cursor_graphics(pindex)
end

--This function gets scheduled.
function call_to_restore_equipped_atomic_bombs(pindex)
   Equipment.restore_equipped_atomic_bombs(pindex)
end

--???
function prune_item_groups(array)
   if #groups == 0 then
      local dict = prototypes.item
      local a = FaUtils.get_iterable_array(dict)
      for i, v in ipairs(a) do
         local check1 = true
         local check2 = true

         for i1, v1 in ipairs(groups) do
            if v1.name == v.group.name then check1 = false end
            if v1.name == v.subgroup.name then check2 = false end
         end
         if check1 then table.insert(groups, v.group) end
         if check2 then table.insert(groups, v.subgroup) end
      end
   end
   local i = 1
   while i < #array and array ~= nil and array[i] ~= nil do
      local check = true
      for i1, v in ipairs(groups) do
         if v ~= nil and array[i].name == v.name then
            i = i + 1
            check = false
            break
         end
      end
      if check then table.remove(array, i) end
   end
end

function read_item_selector_slot(pindex, start_phrase)
   start_phrase = start_phrase or ""
   local item_name = storage.players[pindex].item_cache[storage.players[pindex].item_selector.index].name
   if start_phrase == "" then
      Speech.speak(pindex, { "item-name." .. item_name })
   else
      Speech.speak(pindex, { "", start_phrase, { "item-name." .. item_name } })
   end
end

--Reads the selected player inventory's selected menu slot. Default is to read the main inventory.
function read_inventory_slot(pindex, start_phrase_in, inv_in)
   local p = game.get_player(pindex)
   local result = start_phrase_in or ""
   local index = storage.players[pindex].inventory.index
   local inv = inv_in or storage.players[pindex].inventory.lua_inventory
   if index < 1 then
      index = 1
   elseif index > #inv then
      index = #inv
   end
   storage.players[pindex].inventory.index = index
   local stack = inv[index]
   if stack == nil or not stack.valid_for_read then
      --Label it as an empty slot
      result = result .. "Empty Slot"
      --Check if the empty slot has a filter set
      local main_inv = p.get_main_inventory()
      local filter_name = main_inv and Filters.get_filter_prototype(main_inv, index) or nil
      if filter_name ~= nil then
         result = result .. " filtered for " .. filter_name --laterdo localise this name
      end
      Speech.speak(pindex, result)
      return
   end
   if stack.is_blueprint then
      Speech.speak(pindex, Blueprints.get_blueprint_info(stack, false, pindex))
   elseif stack.is_blueprint_book then
      Speech.speak(pindex, Blueprints.get_blueprint_book_info(stack, false))
   elseif stack.valid_for_read then
      --Check if the slot is filtered
      local main_inv = p.get_main_inventory()
      local filter_name = main_inv and Filters.get_filter_prototype(main_inv, index) or nil
      if filter_name ~= nil then result = result .. " filtered " end
      --Check if the stack has damage
      if stack.health < 1 then result = result .. " damaged " end
      result = {
         "",
         result,
         Localising.get_localised_name_with_fallback(stack),
         " x ",
         tostring(stack.count),
         " ",
         stack.prototype.subgroup.name,
      }
      Speech.speak(pindex, result)
   end
end

--Reads the item in hand, its facing direction if applicable, its count, and its total count including units in the main inventory.
---@param pindex number
local function read_hand(pindex)
   if storage.players[pindex].skip_read_hand == true then
      storage.players[pindex].skip_read_hand = false
      return
   end
   local cursor_stack = game.get_player(pindex).cursor_stack
   local cursor_ghost = game.get_player(pindex).cursor_ghost
   if cursor_stack and cursor_stack.valid_for_read then
      if cursor_stack.is_blueprint then
         --Blueprint extra info
         Speech.speak(pindex, Blueprints.get_blueprint_info(cursor_stack, true, pindex))
      elseif cursor_stack.is_blueprint_book then
         Speech.speak(pindex, Blueprints.get_blueprint_book_info(cursor_stack, true))
      else
         --Any other valid item
         local out = { "fa.cursor-description" }
         table.insert(out, cursor_stack.prototype.localised_name)
         local build_entity = cursor_stack.prototype.place_result
         if build_entity and build_entity.supports_direction then
            table.insert(out, 1)
            table.insert(
               out,
               { "fa.facing-direction", FaUtils.direction_lookup(storage.players[pindex].building_direction) }
            )
         else
            table.insert(out, 0)
            table.insert(out, "")
         end
         table.insert(out, cursor_stack.count)
         local extra = game.get_player(pindex).get_main_inventory().get_item_count(cursor_stack.name)
         if extra > 0 then
            table.insert(out, cursor_stack.count + extra)
         else
            table.insert(out, 0)
         end
         Speech.speak(pindex, out)
      end
   elseif cursor_ghost ~= nil then
      --Any ghost
      local out = { "fa.cursor-description" }
      table.insert(out, cursor_ghost.localised_name)
      local build_entity = cursor_ghost.place_result
      if build_entity and build_entity.supports_direction then
         table.insert(out, 1)
         table.insert(
            out,
            { "fa.facing-direction", FaUtils.direction_lookup(storage.players[pindex].building_direction) }
         )
      else
         table.insert(out, 0)
         table.insert(out, "")
      end
      table.insert(out, 0)
      local extra = 0
      if extra > 0 then
         table.insert(out, cursor_stack.count + extra)
      else
         table.insert(out, 0)
      end
      Speech.speak(pindex, out)
   else
      Speech.speak(pindex, { "fa.empty_cursor" })
   end
end

--Clears the item in hand and then locates it from the first found player inventory slot. laterdo can use API:player.hand_location in the future if it has advantages
function locate_hand_in_player_inventory(pindex)
   local p = game.get_player(pindex)
   local inv = p.get_main_inventory()
   local stack = p.cursor_stack
   if p.cursor_stack_temporary then
      Speech.speak(pindex, { "fa.this-item-is-temporary" })
      return
   end

   local router = UiRouter.get_router(pindex)
   local ui_name = router:get_open_ui_name()

   --Check if stack empty and menu supported
   if stack == nil or not stack.valid_for_read or not stack.valid then
      --Hand is empty
      return
   end
   if ui_name then
      --Another menu is open, cannot Q from hand
      Speech.speak(pindex, { "fa.another-menu-is-open" })
      return
   end
   if not ui_name then
      --Open the main menu if nothing is open
      router:open_ui(
         UiRouter.UI_NAMES.MAIN,
         { player_inventory = { entity = p.character, inventory_index = defines.inventory.character_main } }
      )
      p.opened = p.get_inventory(defines.inventory.character_main)
   end
   --Save the hand stack item name
   local item_name = stack.name
   --Empty hand stack (clear cursor stack)
   storage.players[pindex].skip_read_hand = true
   local successful = p.clear_cursor()
   if not successful then
      local message = "Unable to empty hand"
      if inv.count_empty_stacks() == 0 then message = message .. ", inventory full" end
      Speech.speak(pindex, message)
      return
   end

   --Iterate the inventory until you find the matching item name's index
   local found = false
   local i = 0
   while not found and i < #inv do
      i = i + 1
      if inv[i] and inv[i].valid_for_read and inv[i].name == item_name then found = true end
   end
   --If found, read it from the inventory
   if not found then
      Speech.speak(pindex, { "fa.error-item-not-found-inventory", Localising.get_localised_name_with_fallback(stack) })
      return
   else
      storage.players[pindex].inventory.index = i
      read_inventory_slot(pindex, "inventory ")
   end
end

--Clears the item in hand and then locates it from the first found building output slot
function locate_hand_in_building_output_inventory(pindex)
   local p = game.get_player(pindex)
   local inv = nil
   local stack = p.cursor_stack
   local pb = storage.players[pindex].building
   if p.cursor_stack_temporary then
      Speech.speak(pindex, { "fa.this-item-is-temporary" })
      return
   end
   if stack.is_blueprint or stack.is_blueprint_book or stack.is_deconstruction_item or stack.is_upgrade_item then
      return
   end

   local router = UiRouter.get_router(pindex)

   --Check if stack empty and menu supported
   if stack == nil or not stack.valid_for_read or not stack.valid then
      --Hand is empty
      return
   end
   if pb.sectors and pb.sectors[pb.sector] and pb.sectors[pb.sector].name == "Output" then
      inv = p.opened.get_output_inventory()
   else
      --Unsupported menu type
      return
   end

   --Save the hand stack item name
   local item_name = stack.name
   --Empty hand stack (clear cursor stack)
   storage.players[pindex].skip_read_hand = true
   local successful = p.clear_cursor()
   if not successful then
      local message = "Unable to empty hand"
      if inv.count_empty_stacks() == 0 then message = message .. ", inventory full" end
      Speech.speak(pindex, message)
      return
   end

   --Iterate the inventory until you find the matching item name's index
   local found = false
   local i = 0
   while not found and i < #inv do
      i = i + 1
      if inv[i] and inv[i].valid_for_read and inv[i].name == item_name then found = true end
   end
   --If found, read it from the inventory
   if not found then
      Speech.speak(pindex, { "fa.item-not-found-in-output", Localising.get_localised_name_with_fallback(stack) })
      return
   else
      storage.players[pindex].building.index = i
      -- Removed: BuildingVehicleSectors.read_sector_slot(pindex, false)
      -- TODO: Replace with new capability-based UI
   end
end

--If there is an entity at the cursor, moves the mouse pointer to it, else moves to the cursor tile.
--TODO: remove this, by calling the appropriate mouse module functions instead.
function target_mouse_pointer_deprecated(pindex)
   if storage.players[pindex].vanilla_mode then return end
   local vp = Viewpoint.get_viewpoint(pindex)
   local surf = game.get_player(pindex).surface
   local ents = surf.find_entities_filtered({ position = vp:get_cursor_pos() })
   if ents and ents[1] and ents[1].valid then
      Mouse.move_mouse_pointer(ents[1].position, pindex)
   else
      Mouse.move_mouse_pointer(vp:get_cursor_pos(), pindex)
   end
end

--Checks if the storage players table has been created, and if the table entry for this player exists. Otherwise it is initialized.
function check_for_player(index)
   if storage.players[index] == nil then
      local player = game.get_player(index)
      if player then PlayerInit.initialize(player) end
      return false
   else
      return true
   end
end

---Teleports the player character to the nearest tile center position to allow grid aligned cursor movement.
---@param pindex number
local function center_player_character(pindex)
   local p = game.get_player(pindex)
   local can_port = p.surface.can_place_entity({ name = "character", position = FaUtils.center_of_tile(p.position) })
   local ents = p.surface.find_entities_filtered({
      position = FaUtils.center_of_tile(p.position),
      radius = 0.1,
      type = { "character" },
      invert = true,
   })
   if #ents > 0 and ents[1].valid then
      local ent = ents[1]
      --Ignore ents you can walk through, laterdo better collision checks**
      can_port = can_port and all_ents_are_walkable(p.position)
   end
   if can_port then p.teleport(FaUtils.center_of_tile(p.position)) end
   storage.players[pindex].position = p.position
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   cursor_pos = FaUtils.center_of_tile(cursor_pos)
   vp:set_cursor_pos(cursor_pos)
   Mouse.move_mouse_pointer(cursor_pos, pindex)
end

--Toggles remote view on or off. Appropriately affects build lock or remote view.
local function toggle_remote_view(pindex, force_true, force_false, muted)
   --TODO issue #282, calls for remote view changed.
   do
      return
   end
   if (storage.players[pindex].remote_view ~= true or force_true == true) and force_false ~= true then
      storage.players[pindex].remote_view = true
      local vp = Viewpoint.get_viewpoint(pindex)
      vp:set_cursor_enabled(true)
      storage.players[pindex].build_lock = false
      center_player_character(pindex)
      if muted ~= true then read_tile(pindex, "Remote view opened, ") end
   else
      storage.players[pindex].remote_view = false
      storage.players[pindex].build_lock = false
      if muted ~= true then read_tile(pindex, "Remote view closed, ") end
      --game.get_player(pindex).close_map()
   end

   --Fix zoom
   Zoom.fix_zoom(pindex)
end

-- Force the mod to disable/reset nall cursor modes. Useful for KK.
function force_cursor_off(pindex)
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)

   --Disable
   vp:set_cursor_enabled(false)
   local pos = FaUtils.to_neighboring_tile(storage.players[pindex].position, storage.players[pindex].player_direction)
   pos = FaUtils.center_of_tile(pos)
   vp:set_cursor_pos(pos)
   Mouse.move_mouse_pointer(pos, pindex)
   Graphics.sync_build_cursor_graphics(pindex)
   storage.players[pindex].plr_direction = p.character.direction
   storage.players[pindex].build_lock = false

   --Close Remote view
   toggle_remote_view(pindex, false, true, true)
   --p.close_map()
end

--refresh_player_tile has been moved to EntitySelection module

-- Lua's version of a forward declaration.
local read_tile_inner

--Reads the cursor tile and reads out the result. If an entity is found, its ent info is read. Otherwise info about the tile itself is read.
function read_tile(pindex, start_text)
   local res = read_tile_inner(pindex)
   if start_text then table.insert(res, 1, start_text) end
   Speech.speak(pindex, FaUtils.localise_cat_table(res))
end

read_tile_inner = function(pindex, start_text)
   local result = {}

   if not EntitySelection.refresh_player_tile(pindex) then return { "Tile uncharted and out of range" } end
   local ent = EntitySelection.get_first_ent_at_tile(pindex)
   if not (ent and ent.valid) then
      --If there is no ent, read the tile instead
      local tile_cache = EntitySelection.get_tile_cache(pindex)
      tile_cache.previous = nil
      local tile = tile_cache.tile
      table.insert(result, Localising.get_localised_name_with_fallback(tile_cache.tile_object))
      if
         tile == "water"
         or tile == "deepwater"
         or tile == "water-green"
         or tile == "deepwater-green"
         or tile == "water-shallow"
         or tile == "water-mud"
         or tile == "water-wube"
      then
         --Identify shores and crevices and so on for water tiles
         table.insert(result, FaUtils.identify_water_shores(pindex))
      end
      Graphics.draw_cursor_highlight(pindex, nil, nil)
      game.get_player(pindex).selected = nil
   else --laterdo tackle the issue here where entities such as tree stumps block preview info
      table.insert(result, FaInfo.ent_info(pindex, ent))
      Graphics.draw_cursor_highlight(pindex, ent, nil)
      game.get_player(pindex).selected = ent

      --game.get_player(pindex).print(result)--
      EntitySelection.get_tile_cache(pindex).previous = ent
   end
   if not ent or ent.type == "resource" then --possible bug here with the h box being a new tile ent
      local stack = game.get_player(pindex).cursor_stack
      --Run build preview checks
      if stack and stack.valid_for_read and stack.valid and stack.prototype.place_result ~= nil then
         table.insert(result, BuildingTools.build_preview_checks_info(stack, pindex))
         --game.get_player(pindex).print(result)--
      end
   end

   --If the player is holding a cut-paste tool, every entity being read gets mined as soon as you read a new tile.
   local stack = game.get_player(pindex).cursor_stack
   if
      stack
      and stack.valid_for_read
      and stack.name == "cut-paste-tool"
      and not storage.players[pindex].vanilla_mode
   then
      if ent and ent.valid then --not while loop, because it causes crashes
         local name = ent.name
         sounds.play_mine(pindex)
         if PlayerMiningTools.try_to_mine_with_soun(ent, pindex) then result = result .. name .. " mined, " end
         --Second round, in case two entities are there. While loops do not work!
         ent = EntitySelection.get_first_ent_at_tile(pindex)
         if ent and ent.valid then --not while
            local name = ent.name
            sounds.play_mine(pindex)
            if PlayerMiningTools.try_to_mine_with_soun(ent, pindex) then result = result .. name .. " mined, " end
         end
      end
   end

   --Add info on whether the tile is uncharted or blurred or distant
   table.insert(result, Mouse.cursor_visibility_info(pindex))
   return result
end

--Update the position info and cursor info during smooth walking.
EventManager.on_event(defines.events.on_player_changed_position, function(event, pindex)
   local router = UiRouter.get_router(pindex)

   local p = game.get_player(pindex)
   storage.players[pindex].position = p.position
   local pos = p.position
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_enabled = vp:get_cursor_enabled()
   if p.walking_state.direction ~= storage.players[pindex].player_direction and cursor_enabled == false then
      --Directions mismatch. Turn to new direction --turn (Note, this code handles diagonal turns and other direction changes)
      if p.character ~= nil then
         storage.players[pindex].player_direction = p.character.direction
      else
         storage.players[pindex].player_direction = p.walking_state.direction
         if p.walking_state.direction == nil then storage.players[pindex].player_direction = dirs.north end
      end
      local new_pos = (FaUtils.offset_position_legacy(pos, storage.players[pindex].player_direction, 1.0))
      vp:set_cursor_pos(new_pos)

      --Build lock building + rotate belts in hand unless cursor mode
      local stack = p.cursor_stack
      if
         storage.players[pindex].build_lock
         and stack.valid_for_read
         and stack.valid
         and stack.prototype.place_result ~= nil
         and (stack.prototype.place_result.type == "transport-belt" or stack.name == "rail")
      then
         turn_to_cursor_direction_cardinal(pindex)
         storage.players[pindex].building_direction = storage.players[pindex].player_direction
         BuildingTools.build_item_in_hand(pindex) --build extra belt when turning
      end
   elseif cursor_enabled == false then
      --Directions same: Walk straight
      local new_pos = (FaUtils.offset_position_legacy(pos, storage.players[pindex].player_direction, 1))
      vp:set_cursor_pos(new_pos)

      --Build lock building + rotate belts in hand unless cursor mode
      if storage.players[pindex].build_lock then
         local stack = p.cursor_stack
         if stack and stack.valid_for_read and stack.valid then
            if stack.prototype.place_result ~= nil and stack.prototype.place_result.type == "transport-belt" then
               turn_to_cursor_direction_cardinal(pindex)
               storage.players[pindex].building_direction = storage.players[pindex].player_direction
            end
            BuildingTools.build_item_in_hand(pindex)
         end
      end
   end

   --Update cursor graphics
   local stack = p.cursor_stack
   if stack and stack.valid_for_read and stack.valid then Graphics.sync_build_cursor_graphics(pindex) end

   --Name a detected entity that you can or cannot walk on, or a tile you cannot walk on, and play a sound to indicate multiple consecutive detections
   EntitySelection.refresh_player_tile(pindex)
   local ent = EntitySelection.get_first_ent_at_tile(pindex)
   if
      not storage.players[pindex].vanilla_mode
      and (
         (ent ~= nil and ent.valid)
         or (p.surface.can_place_entity({ name = "character", position = vp:get_cursor_pos() }) == false)
      )
   then
      Graphics.draw_cursor_highlight(pindex, ent, nil)
      if p.driving then return end

      if
         ent ~= nil
         and ent.valid
         and (p.character == nil or (p.character ~= nil and p.character.unit_number ~= ent.unit_number))
      then
         Graphics.draw_cursor_highlight(pindex, ent, nil)
         p.selected = ent
         sounds.play_close_inventory(p.index)
      else
         Graphics.draw_cursor_highlight(pindex, nil, nil)
         p.selected = nil
      end

      read_tile(pindex)
   else
      Graphics.draw_cursor_highlight(pindex, nil, nil)
      p.selected = nil
   end
   --Play a sound for audio ruler alignment (smooth walk)
   Rulers.update_from_cursor(pindex)
end)

--Calls the appropriate menu movement function for a player and the input direction.
local function menu_cursor_move(direction, pindex)
   storage.players[pindex].preferences.inventory_wraps_around = true --laterdo make this a setting to toggle
   if direction == defines.direction.north then
      menu_cursor_up(pindex)
   elseif direction == defines.direction.south then
      menu_cursor_down(pindex)
   elseif direction == defines.direction.east then
      menu_cursor_right(pindex)
   elseif direction == defines.direction.west then
      menu_cursor_left(pindex)
   end
end

--Moves upwards in a menu. Todo: split by menu. "menu_up"
function menu_cursor_up(pindex)
   local router = UiRouter.get_router(pindex)

   if storage.players[pindex].item_selection then
      if storage.players[pindex].item_selector.group == 0 then
         Speech.speak(pindex, { "fa.blank" })
      elseif storage.players[pindex].item_selector.subgroup == 0 then
         storage.players[pindex].item_cache = FaUtils.get_iterable_array(prototypes.item_group)
         prune_item_groups(storage.players[pindex].item_cache)
         storage.players[pindex].item_selector.index = storage.players[pindex].item_selector.group
         storage.players[pindex].item_selector.group = 0
         read_item_selector_slot(pindex)
      else
         local group = storage.players[pindex].item_cache[storage.players[pindex].item_selector.index].group
         storage.players[pindex].item_cache = FaUtils.get_iterable_array(group.subgroups)
         prune_item_groups(storage.players[pindex].item_cache)

         storage.players[pindex].item_selector.index = storage.players[pindex].item_selector.subgroup
         storage.players[pindex].item_selector.subgroup = 0
         read_item_selector_slot(pindex)
      end
   end
end

--Moves downwards in a menu. Todo: split by menu."menu_down"
function menu_cursor_down(pindex)
   local router = UiRouter.get_router(pindex)

   if storage.players[pindex].item_selection then
      if storage.players[pindex].item_selector.group == 0 then
         storage.players[pindex].item_selector.group = storage.players[pindex].item_selector.index
         storage.players[pindex].item_cache = FaUtils.get_iterable_array(
            storage.players[pindex].item_cache[storage.players[pindex].item_selector.group].subgroups
         )
         prune_item_groups(storage.players[pindex].item_cache)

         storage.players[pindex].item_selector.index = 1
         read_item_selector_slot(pindex)
      elseif storage.players[pindex].item_selector.subgroup == 0 then
         storage.players[pindex].item_selector.subgroup = storage.players[pindex].item_selector.index
         local prototypes = prototypes.get_item_filtered({
            {
               filter = "subgroup",
               subgroup = storage.players[pindex].item_cache[storage.players[pindex].item_selector.index].name,
            },
         })
         storage.players[pindex].item_cache = FaUtils.get_iterable_array(prototypes)
         storage.players[pindex].item_selector.index = 1
         read_item_selector_slot(pindex)
      else
         Speech.speak(pindex, { "fa.press-left-bracket-to-confirm" })
      end
   end
end

--Moves to the left in a menu. Todo: split by menu."menu_left"
function menu_cursor_left(pindex)
   local router = UiRouter.get_router(pindex)

   if storage.players[pindex].item_selection then
      storage.players[pindex].item_selector.index = math.max(1, storage.players[pindex].item_selector.index - 1)
      read_item_selector_slot(pindex)
   end
end

----Moves to the right  in a menu. Todo: split by menu. "menu_right"
function menu_cursor_right(pindex)
   local router = UiRouter.get_router(pindex)

   if storage.players[pindex].item_selection then
      storage.players[pindex].item_selector.index =
         math.min(#storage.players[pindex].item_cache, storage.players[pindex].item_selector.index + 1)
      read_item_selector_slot(pindex)
   end
end

--Schedules a function to be called after a certain number of ticks.
function schedule(ticks_in_the_future, func_to_call, data_to_pass_1, data_to_pass_2, data_to_pass_3)
   if type(_G[func_to_call]) ~= "function" then error(func_to_call .. " is not a function") end
   if ticks_in_the_future <= 0 then
      _G[func_to_call](data_to_pass_1, data_to_pass_2, data_to_pass_3)
      return
   end
   local tick = game.tick + ticks_in_the_future
   local schedule = storage.scheduled_events
   schedule[tick] = schedule[tick] or {}
   table.insert(schedule[tick], { func_to_call, data_to_pass_1, data_to_pass_2, data_to_pass_3 })
end

--Handles a player joining into a game session.
function on_player_join(pindex)
   schedule(3, "call_to_fix_zoom", pindex)
   schedule(4, "call_to_sync_graphics", pindex)
   Localising.check_player(pindex)
   local playerList = {}
   for _, p in pairs(game.connected_players) do
      playerList["_" .. p.index] = p.name
   end
   print("playerList " .. game.table_to_json(playerList))

   --Reset the player building direction to match the vanilla behavior.
   storage.players[pindex].building_direction = dirs.north --
end

EventManager.on_event(defines.events.on_player_joined_game, function(event)
   if game.is_multiplayer() then on_player_join(event.player_index) end
end)

function on_initial_joining_tick(event)
   if not game.is_multiplayer() then on_player_join(game.connected_storage.players[1].index) end
   on_tick(event)
end

--Called for every player on every tick, to manage automatic walking and enforcing mouse pointer position syncs.
--Todo: create a new function for all mouse pointer related updates within this function
local function move_characters(event)
   for pindex, player in pairs(storage.players) do
      local router = UiRouter.get_router(pindex)
      local vp = Viewpoint.get_viewpoint(pindex)
      local cursor_pos = vp:get_cursor_pos()

      if vp:get_cursor_enabled() then
         local p = game.get_player(pindex)
         -- Careful! You have to write a table for the game to pick it up.
         if p.character then
            local ws = p.character.walking_state
            ws.walking = false
            p.character.walking_state = ws
         end
      end

      if player.vanilla_mode == true then
         player.player.game_view_settings.update_entity_selection = true
      elseif player.player.game_view_settings.update_entity_selection == false then
         --Force the mouse pointer to the mod cursor if there is an item in hand
         --(so that the game does not make a mess when you left click while the cursor is actually locked)
         local stack = game.get_player(pindex).cursor_stack
         if stack and stack.valid_for_read then
            if
               stack.prototype.place_result ~= nil
               or stack.prototype.place_as_tile_result ~= nil
               or stack.is_blueprint
               or stack.is_deconstruction_item
               or stack.is_upgrade_item
               or stack.prototype.type == "selection-tool"
               or stack.prototype.type == "copy-paste-tool"
            then
               --Force the pointer to the build preview location (and draw selection tool boxes)
               Graphics.sync_build_cursor_graphics(pindex)
            else
               --Force the pointer to the cursor location (if on screen)
               Mouse.move_mouse_pointer(vp:get_cursor_pos(), pindex)
            end
         end
      end
   end
end

--Called every tick. Used to call scheduled and repeated functions.
function on_tick(event)
   ScannerEntrypoint.on_tick()

   if storage.scheduled_events[event.tick] then
      for _, to_call in pairs(storage.scheduled_events[event.tick]) do
         _G[to_call[1]](to_call[2], to_call[3], to_call[4])
      end
      storage.scheduled_events[event.tick] = nil
   end
   move_characters(event)

   -- Check alerts via AudioCues
   AudioCues.check_cues(event.tick, players)

   --The elseifs can schedule up to 16 events.
   if event.tick % 15 == 0 then
      for pindex, player in pairs(players) do
         --Bump checks
         BumpDetection.check_and_play_bump_alert_sound(pindex, event.tick)
         BumpDetection.check_and_play_stuck_alert_sound(pindex, event.tick)
      end
   elseif event.tick % 15 == 3 then
      --Adjust camera if in remote view
      for pindex, player in pairs(players) do
         storage.players[pindex].closed_map_count = storage.players[pindex].closed_map_count or 0
         if storage.players[pindex].remote_view == true then
            sync_remote_view(pindex)
            storage.players[pindex].closed_map_count = 0
         elseif storage.players[pindex].vanilla_mode ~= true and storage.players[pindex].closed_map_count < 1 then
            --game.get_player(pindex).close_map()
            storage.players[pindex].closed_map_count = storage.players[pindex].closed_map_count + 1
         end
      end
   elseif event.tick % 30 == 7 then
      --Update menu visuals
      Graphics.update_menu_visuals()
   elseif event.tick % 90 == 13 then
      for pindex, player in pairs(players) do
         --Fix running speed bug (toggle walk also fixes it)
         fix_walk(pindex)
      end
   elseif event.tick % 450 == 14 then
      --Run regular reminders every 7.5 seconds
      for pindex, player in pairs(players) do
         --Tutorial reminder every 10 seconds until you open it
         if storage.players[pindex].started ~= true then
            Speech.speak(pindex, { "fa.press-tab-to-begin" })
         elseif storage.players[pindex].tutorial == nil then
            Speech.speak(pindex, { "fa.press-h-for-tutorial" })
         elseif game.get_player(pindex).ticks_to_respawn ~= nil then
            Speech.speak(
               pindex,
               { "fa.respawn-countdown", tostring(math.floor(game.get_player(pindex).ticks_to_respawn / 60)) }
            )
         end
         --Report the KK state, if any.
         KruiseKontrol.status_read(pindex, false)
         --Clear unwanted GUI remnants
         --Graphics.clear_player_GUI_remnants(pindex)
      end
   end
end

EventManager.on_event(defines.events.on_tick, function(event)
   on_tick(event)
   WorkQueue.on_tick()
   TestFramework.on_tick(event)
end)

--Focuses camera on the cursor position.
function sync_remote_view(pindex)
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   p.zoom_to_world(vp:get_cursor_pos())
   Graphics.sync_build_cursor_graphics(pindex)
end

--Makes the character face the cursor, choosing the nearest of 4 cardinal directions. Can be overwriten by vanilla move keys.
function turn_to_cursor_direction_cardinal(pindex)
   local p = game.get_player(pindex)
   if p.character == nil then return end
   local pex = storage.players[pindex]
   local vp = Viewpoint.get_viewpoint(pindex)
   local dir = FaUtils.get_direction_precise(vp:get_cursor_pos(), p.position)
   if dir == dirs.northwest or dir == dirs.north or dir == dirs.northeast then
      p.character.direction = dirs.north
      pex.player_direction = dirs.north
   elseif dir == dirs.southwest or dir == dirs.south or dir == dirs.southeast then
      p.character.direction = dirs.south
      pex.player_direction = dirs.south
   else
      --p.character.direction = dir
      pex.player_direction = dir
   end
   --game.print("set cardinal pindex_dir: " .. direction_lookup(pex.player_direction))--
   --game.print("set cardinal charct_dir: " .. direction_lookup(p.character.direction))--
end

--Makes the character face the cursor, choosing the nearest of 8 directions. Can be overwriten by vanilla move keys.
function turn_to_cursor_direction_precise(pindex)
   local p = game.get_player(pindex)
   if p.character == nil then return end
   local pex = storage.players[pindex]
   local vp = Viewpoint.get_viewpoint(pindex)
   local dir = FaUtils.get_direction_precise(vp:get_cursor_pos(), p.position)
   pex.player_direction = dir
   --game.print("set precise pindex_dir: " .. direction_lookup(pex.player_direction))--
   --game.print("set precise charct_dir: " .. direction_lookup(p.character.direction))--
end

--Called when a player enters or exits a vehicle
EventManager.on_event(defines.events.on_player_driving_changed_state, function(event, pindex)
   local router = UiRouter.get_router(pindex)

   BumpDetection.reset_bump_stats(pindex)
   game.get_player(pindex).clear_cursor()
   storage.players[pindex].last_train_orientation = nil
   if game.get_player(pindex).driving then
      storage.players[pindex].last_vehicle = game.get_player(pindex).vehicle
      Speech.speak(
         pindex,
         { "fa.vehicle-entered", Localising.get_localised_name_with_fallback(game.get_player(pindex).vehicle) }
      )
      if
         storage.players[pindex].last_vehicle.train ~= nil
         and storage.players[pindex].last_vehicle.train.schedule == nil
      then
         storage.players[pindex].last_vehicle.train.manual_mode = true
      end
   elseif storage.players[pindex].last_vehicle ~= nil then
      Speech.speak(
         pindex,
         { "fa.vehicle-exited", Localising.get_localised_name_with_fallback(storage.players[pindex].last_vehicle) }
      )
      if
         storage.players[pindex].last_vehicle.train ~= nil
         and storage.players[pindex].last_vehicle.train.schedule == nil
      then
         storage.players[pindex].last_vehicle.train.manual_mode = true
      end
      Teleport.teleport_to_closest(pindex, storage.players[pindex].last_vehicle.position, true, true)
      SpidertronMenuUi.spidertron_menu:close(pindex, false)
   else
      Speech.speak(pindex, { "fa.driving-state-changed" })
   end
end)

--Save info about last item pickup and draw radius
EventManager.on_event(defines.events.on_picked_up_item, function(event, pindex)
   local p = game.get_player(pindex)
   --Draw the pickup range
   rendering.draw_circle({
      color = { 0.3, 1, 0.3 },
      radius = 1.25,
      width = 1,
      target = p.position,
      surface = p.surface,
      time_to_live = 10,
      draw_on_ground = true,
   })
   storage.players[pindex].last_pickup_tick = event.tick
   storage.players[pindex].last_item_picked_up = event.item_stack.name
end)

--Quickbar event handlers
local quickbar_get_events = {}
local quickbar_set_events = {}
local quickbar_page_events = {}
for i = 1, 10 do
   local key = tostring(i % 10)
   table.insert(quickbar_get_events, "fa-" .. key)
   table.insert(quickbar_set_events, "fa-c-" .. key)
   table.insert(quickbar_page_events, "fa-s-" .. key)
end

EventManager.on_event(quickbar_get_events, Quickbar.quickbar_get_handler)

EventManager.on_event(quickbar_set_events, Quickbar.quickbar_set_handler)

EventManager.on_event(quickbar_page_events, Quickbar.quickbar_page_handler)

function swap_weapon_forward(pindex, write_to_character)
   local p = game.get_player(pindex)
   if p.character == nil then
      return 0 --This is an intentionally selected error code
   end
   local gun_index = p.character.selected_gun_index
   if gun_index == nil then
      return 0 --This is an intentionally selected error code
   end
   local guns_inv = p.character.get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).character.get_inventory(defines.inventory.character_ammo)

   --Simple index increment (not needed)
   gun_index = gun_index + 1
   if gun_index > 3 then gun_index = 1 end
   --game.print("start " .. gun_index)--
   assert(ammo_inv)

   --Increment again if the new index has no guns or no ammo
   local ammo_stack = ammo_inv[gun_index]
   local gun_stack = guns_inv[gun_index]
   local tries = 0
   while
      tries < 4
      and (
         ammo_stack == nil
         or not ammo_stack.valid_for_read
         or not ammo_stack.valid
         or gun_stack == nil
         or not gun_stack.valid_for_read
         or not gun_stack.valid
      )
   do
      gun_index = gun_index + 1
      if gun_index > 3 then gun_index = 1 end
      ammo_stack = ammo_inv[gun_index]
      gun_stack = guns_inv[gun_index]
      tries = tries + 1
   end

   if tries > 3 then
      --game.print("error " .. gun_index)--
      return -1
   end

   if write_to_character then p.character.selected_gun_index = gun_index end
   --game.print("end " .. gun_index)--
   return gun_index
end

function swap_weapon_backward(pindex, write_to_character)
   local p = game.get_player(pindex)
   if p.character == nil then
      return 0 --This is an intentionally selected error code
   end
   local gun_index = p.character.selected_gun_index
   if gun_index == nil then
      return 0 --This is an intentionally selected error code
   end
   local guns_inv = p.get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)

   --Simple index increment (not needed)
   gun_index = gun_index - 1
   if gun_index < 1 then gun_index = 3 end

   --Increment again if the new index has no guns or no ammo
   local ammo_stack = ammo_inv[gun_index]
   local gun_stack = guns_inv[gun_index]
   local tries = 0
   while
      tries < 4
      and (
         ammo_stack == nil
         or not ammo_stack.valid_for_read
         or not ammo_stack.valid
         or gun_stack == nil
         or not gun_stack.valid_for_read
         or not gun_stack.valid
      )
   do
      gun_index = gun_index - 1
      if gun_index < 1 then gun_index = 3 end
      ammo_stack = ammo_inv[gun_index]
      gun_stack = guns_inv[gun_index]
      tries = tries + 1
   end

   if tries > 3 then return -1 end

   if write_to_character then p.character.selected_gun_index = gun_index end
   return gun_index
end

function player_inventory_click(pindex, left_click)
   local click_is_left = left_click or true
   local p = game.get_player(pindex)
   local stack_cur = p.cursor_stack
   local stack_inv = storage.players[pindex].inventory.lua_inventory[storage.players[pindex].inventory.index]

   if stack_cur and stack_cur.valid_for_read then
      --Full hand
      if stack_inv and stack_inv.valid_for_read and stack_inv.name ~= stack_cur.name then
      else
      end
   else
      --Empty hand
   end

   --Play sound and update known inv size
   sounds.play_menu_click(p.index)
   storage.players[pindex].inventory.max = #storage.players[pindex].inventory.lua_inventory
end

function clicked_on_entity(ent, pindex)
   local p = game.get_player(pindex)
   if ent == nil then
      --No entity clicked
      p.selected = nil
      return
   elseif not ent.valid then
      --Invalid entity clicked
      p.print("Invalid entity clicked", { volume_modifier = 0 })
      if p.opened ~= nil and p.opened.object_name == "LuaEntity" and p.opened.valid then
         p.print("Opened " .. p.opened.name, { volume_modifier = 0 })
         ent = p.opened
         return
      else
         p.selected = nil
         return
      end
   end
   if p.character and p.character.unit_number == ent.unit_number then
      --Self click
      return
   end

   p.selected = ent
   if ent.name == "roboport" then
      --For a roboport, open roboport menu
      local router = UiRouter.get_router(pindex)
      router:open_ui(UiRouter.UI_NAMES.ROBOPORT)
   elseif ent.type == "power-switch" then
      --Toggle it, if in manual mode
      if (#ent.neighbours.red + #ent.neighbours.green) > 0 then
         Speech.speak(pindex, { "fa.observes-circuit-condition" })
      else
         ent.power_switch_state = not ent.power_switch_state
         if ent.power_switch_state == true then
            Speech.speak(pindex, { "fa.switched-on" })
         elseif ent.power_switch_state == false then
            Speech.speak(pindex, { "fa.switched-off" })
         end
      end
   elseif ent.type == "constant-combinator" then
      --Toggle it
      ent.get_control_behavior().enabled = not ent.get_control_behavior().enabled
      local enabled = ent.get_control_behavior().enabled
      if enabled == true then
         Speech.speak(pindex, { "fa.switched-on" })
      elseif enabled == false then
         Speech.speak(pindex, { "fa.switched-off" })
      end
   elseif ent.operable and ent.prototype.is_building then
      -- Open capability-based entity UI
      EntityUI.open_entity_ui(pindex, ent)
   elseif ent.type == "car" or ent.type == "spider-vehicle" or ent.train ~= nil then
      -- Open capability-based entity UI for vehicles
      EntityUI.open_entity_ui(pindex, ent)
   elseif ent.type == "spider-leg" then
      --Find and open the spider
      local spiders =
         ent.surface.find_entities_filtered({ position = ent.position, radius = 5, type = "spider-vehicle" })
      local spider = ent.surface.get_closest(ent.position, spiders)
      if spider and spider.valid then
         -- Open capability-based entity UI for the spider
         EntityUI.open_entity_ui(pindex, spider)
      end
   elseif ent.name == "rocket-silo-rocket-shadow" or ent.name == "rocket-silo-rocket" then
      --Find and open the silo
      local silos = ent.surface.find_entities_filtered({ position = ent.position, radius = 5, type = "rocket-silo" })
      local silo = ent.surface.get_closest(ent.position, silos)
      if silo and silo.valid then
         -- Open capability-based entity UI for the rocket silo
         EntityUI.open_entity_ui(pindex, silo)
      end
   elseif ent.operable then
      if ent then Speech.speak(pindex, { "fa.no-menu-for", Localising.get_localised_name_with_fallback(ent) }) end
   elseif ent.type == "resource" and ent.name ~= "crude-oil" and ent.name ~= "uranium-ore" then
      if ent then
         Speech.speak(pindex, { "fa.no-menu-for-mineable", Localising.get_localised_name_with_fallback(ent) })
      end
   else
      if ent then Speech.speak(pindex, { "fa.no-menu-for", Localising.get_localised_name_with_fallback(ent) }) end
   end
end

--[[Manages inventory transfers that are bigger than one stack. 
* Has checks and speech output!
]]

--When the item in hand changes
EventManager.on_event(defines.events.on_player_cursor_stack_changed, function(event, pindex)
   local router = UiRouter.get_router(pindex)

   local stack = game.get_player(pindex).cursor_stack
   local new_item_name = ""
   if stack and stack.valid_for_read then
      new_item_name = stack.name
      if stack.is_blueprint and storage.players[pindex].blueprint_hand_direction ~= dirs.north then
         --Reset blueprint rotation (unless it is a temporary blueprint)
         storage.players[pindex].blueprint_hand_direction = dirs.north
         if game.get_player(pindex).cursor_stack_temporary == false then
            Blueprints.refresh_blueprint_in_hand(pindex)
         end
         --Use this opportunity to update saved information about the blueprint's corners (used when drawing the footprint)
         local width, height = Blueprints.get_blueprint_width_and_height(pindex)
         if width == nil or height == nil then return end
         storage.players[pindex].blueprint_width_in_hand = width + 1
         storage.players[pindex].blueprint_height_in_hand = height + 1
      end
   end

   -- As a special case: blueprint menus will end up pointing at the wrong
   -- blueprint if not closed here, since the only real unique identifier right
   -- now is the player's hand.
   local router = UiRouter.get_router(pindex)
   if router:is_ui_open(UiRouter.UI_NAMES.BLUEPRINT) then router:close_ui() end

   if storage.players[pindex].previous_hand_item_name ~= new_item_name then
      storage.players[pindex].previous_hand_item_name = new_item_name
      --storage.players[pindex].lag_building_direction = true
      read_hand(pindex)
   end
   BuildingTools.delete_empty_planners_in_inventory(pindex)
   storage.players[pindex].bp_selecting = false
   storage.players[pindex].blueprint_reselecting = false
   storage.players[pindex].ghost_rail_planning = false
   Graphics.sync_build_cursor_graphics(pindex)
end)

EventManager.on_event(defines.events.on_player_mined_item, function(event, pindex)
   --Play item pickup sound
   sounds.play_picked_up_item(pindex)
   sounds.play_close_inventory(pindex)
end)

function ensure_storage_structures_are_up_to_date()
   storage.forces = storage.forces or {}
   storage.players = storage.players or {}
   for pindex, player in pairs(game.players) do
      PlayerInit.initialize(player)
   end

   storage.entity_types = {}
   entity_types = storage.entity_types

   local types = {}

   for _, ent in pairs(prototypes.entity) do
      if
         types[ent.type] == nil
         and ent.weight == nil
         and (
            ent.burner_prototype ~= nil
            or ent.electric_energy_source_prototype ~= nil
            or ent.automated_ammo_count ~= nil
         )
      then
         types[ent.type] = true
      end
   end

   for i, type in pairs(types) do
      table.insert(entity_types, i)
   end
   table.insert(entity_types, "container")

   storage.production_types = {}
   production_types = storage.production_types

   -- TODO: reimplement production types. Seems only to be the warnings menu
   -- using it.

   storage.building_types = {}
   building_types = storage.building_types

   local ents = prototypes.entity
   local types = {}
   for i, ent in pairs(ents) do
      if ent.is_building then types[ent.type] = true end
   end
   types["transport-belt"] = nil
   for i, type in pairs(types) do
      table.insert(building_types, i)
   end
   table.insert(building_types, "character")

   storage.scheduled_events = storage.scheduled_events or {}
end

EventManager.on_load(function()
   entity_types = storage.entity_types
   production_types = storage.production_types
   building_types = storage.building_types
end)

EventManager.on_configuration_changed(ensure_storage_structures_are_up_to_date)

EventManager.on_init(function()
   ---@type any
   local skip_intro_message = remote.interfaces["freeplay"]
   skip_intro_message = skip_intro_message and skip_intro_message["set_skip_intro"]
   if skip_intro_message then remote.call("freeplay", "set_skip_intro", true) end
   ensure_storage_structures_are_up_to_date()
   TestFramework.on_init()
   AudioCues.on_init()
end)

EventManager.on_event(defines.events.on_cutscene_cancelled, function(event, pindex)
   schedule(3, "call_to_fix_zoom", pindex)
   schedule(4, "call_to_sync_graphics", pindex)
end)

EventManager.on_event(defines.events.on_cutscene_finished, function(event, pindex)
   schedule(3, "call_to_fix_zoom", pindex)
   schedule(4, "call_to_sync_graphics", pindex)
   --Speech.speak(pindex, "Press TAB to continue")
end)

EventManager.on_event(defines.events.on_cutscene_started, function(event, pindex)
   --Speech.speak(pindex, "Press TAB to continue")
end)

EventManager.on_event(defines.events.on_player_created, function(event)
   PlayerInit.initialize(game.players[event.player_index])
   --if not game.is_multiplayer() then Speech.speak(pindex, "Press 'TAB' to continue") end
end)

EventManager.on_event(
   defines.events.on_gui_closed,
   ---@param event EventData.on_gui_closed
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      print(serpent.line(event, { nocode = true }))
      --Other resets - now executed unconditionally
      if event.element ~= nil then event.element.destroy() end
      router:close_ui()
      storage.players[pindex].item_selection = false
      storage.players[pindex].item_cache = {}
      storage.players[pindex].item_selector = {
         index = 0,
         group = 0,
         subgroup = 0,
      }
      storage.players[pindex].building.item_selection = false
   end
)

function fix_walk(pindex)
   local player = game.get_player(pindex)
   if not player.character then return end
   -- Always use normal walking speed
   player.character_running_speed_modifier = 0 -- 100% + 0 = 100%
   storage.players[pindex].position = player.position
end

--GUI action confirmed, such as by pressing ENTER
EventManager.on_event(defines.events.on_gui_confirmed, function(event, pindex)
   local router = UiRouter.get_router(pindex)

   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   if vp:get_cursor_jumping() == true then
      --Jump the cursor
      vp:set_cursor_jumping(false)
      local result = event.element.text
      jump_cursor_to_typed_coordinates(result, pindex)
      event.element.destroy()
      router:close_ui()
      --play sound
      sounds.play_close_inventory(p.index)

      --Destroy text fields
      if p.gui.screen["cursor-jump"] ~= nil then p.gui.screen["cursor-jump"].destroy() end
      if p.opened ~= nil then p.opened = nil end
   elseif storage.players[pindex].train_limit_editing == true then
      --Apply the limit
      storage.players[pindex].train_limit_editing = false
      local result = event.element.text
      if result ~= nil and result ~= "" then
         local constant = tonumber(result)
         ---@cast constant  number
         local valid_number = constant ~= nil
         if valid_number and p.selected and p.selected.valid and p.selected.name == "train-stop" then
            if constant >= 0 then
               p.selected.trains_limit = constant
               Speech.speak(pindex, { "fa.train-limit-set", tostring(constant) })
            else
               p.selected.trains_limit = nil
               Speech.speak(pindex, { "fa.cleared-trains-limit" })
            end
         else
            Speech.speak(pindex, { "fa.invalid-input" })
         end
      else
         Speech.speak(pindex, { "fa.invalid-input" })
      end
      event.element.destroy()
      router:close_ui()
      --play sound
      sounds.play_close_inventory(p.index)

      --Destroy text fields
      if p.gui.screen["train-limit-edit"] ~= nil then p.gui.screen["train-limit-edit"].destroy() end
      if p.opened ~= nil then p.opened = nil end
   elseif storage.players[pindex].roboport_menu.renaming == true then
      storage.players[pindex].roboport_menu.renaming = false
      local result = event.element.text
      if result == nil or result == "" then result = "unknown" end
      WorkerRobots.set_network_name(storage.players[pindex].roboport_menu.port, result)
      Speech.speak(pindex, { "fa.network-renamed", result })
      event.element.destroy()
      RoboportMenuUi.roboport_menu:close(pindex, false)
   elseif storage.players[pindex].blueprint_menu.edit_label == true then
      --Apply the new label
      storage.players[pindex].blueprint_menu.edit_label = false
      local result = event.element.text
      if result == nil or result == "" then result = "unknown" end
      if p.cursor_stack.is_blueprint then
         Blueprints.set_blueprint_label(p.cursor_stack, result)
      elseif p.cursor_stack.is_blueprint_book then
         Blueprints.blueprint_book_set_label(pindex, result)
      end
      Speech.speak(pindex, { "fa.blueprint-label-changed", result })
      event.element.destroy()
      if p.gui.screen["blueprint-edit-label"] ~= nil then p.gui.screen["blueprint-edit-label"].destroy() end
   elseif storage.players[pindex].blueprint_menu.edit_description == true then
      --Apply the new desc
      storage.players[pindex].blueprint_menu.edit_description = false
      local result = event.element.text
      if result == nil or result == "" then result = "unknown" end
      if p.cursor_stack.is_blueprint then
         Blueprints.set_blueprint_description(p.cursor_stack, result)
      elseif p.cursor_stack.is_blueprint_book then
         Blueprints.set_blueprint_book_description(pindex, result)
      end
      Speech.speak(pindex, { "fa.blueprint-description-changed" })
      event.element.destroy()
      if p.gui.screen["blueprint-edit-description"] ~= nil then p.gui.screen["blueprint-edit-description"].destroy() end
   elseif storage.players[pindex].blueprint_menu.edit_import == true then
      --Apply the new import
      storage.players[pindex].blueprint_menu.edit_import = false
      local result = event.element.text
      if result == nil or result == "" then result = "unknown" end
      Blueprints.apply_blueprint_import(pindex, result)
      event.element.destroy()
      if p.gui.screen["blueprint-edit-import"] ~= nil then p.gui.screen["blueprint-edit-import"].destroy() end
   elseif storage.players[pindex].blueprint_menu.edit_export == true then
      --Instruct export
      storage.players[pindex].blueprint_menu.edit_export = false
      local result = event.element.text
      if result == nil or result == "" then result = "unknown" end
      Speech.speak(pindex, "Text box closed")
      event.element.destroy()
      if p.gui.screen["blueprint-edit-export"] ~= nil then p.gui.screen["blueprint-edit-export"].destroy() end
   else
      --Stray text box, so do nothing and destroy it
      if event.element.parent then
         event.element.parent.destroy()
      else
         event.element.destroy()
      end
   end
   storage.players[pindex].text_field_open = false
end)

--Read the correct inventory slot based on the current menu, optionally with a start phrase in
local function read_selected_inventory_and_slot(pindex, start_phrase_in)
   local start_phrase_in = start_phrase_in or ""
   local menu = storage.players[pindex].menu
   if menu == "inventory" then
      read_inventory_slot(pindex, start_phrase_in)
   elseif menu == "building" or menu == "vehicle" then
      -- TODO: Replace with capability-based UI
      Speech.speak(pindex, start_phrase_in .. "Building/vehicle menus temporarily disabled")
   else
      Speech.speak(pindex, start_phrase_in)
   end
end

--Returns the currently selected entity inventory based on the current mod menu and mod sector.
local function get_selected_inventory_and_slot(pindex)
   local p = game.get_player(pindex)
   local c = p.character
   if not c then return nil end
   local inv = nil
   local index = nil
   local menu = storage.players[pindex].menu
   if menu == "inventory" then
      inv = c.get_main_inventory()
      index = storage.players[pindex].inventory.index
   elseif menu == "building" or menu == "vehicle" then
      -- TODO: Replace with capability-based UI
      -- For now, return player inventory as fallback
      inv = c.get_main_inventory()
      index = storage.players[pindex].inventory.index
   end
   return inv, index
end

--Sets inventory slot filters
local function set_selected_inventory_slot_filter(pindex)
   local p = game.get_player(pindex)
   --Determine the inventory selected
   local inv, index = get_selected_inventory_and_slot(pindex)
   --Check if it supports filters
   if inv == nil or (inv.valid and not inv.supports_filters()) then
      Speech.speak(pindex, "This menu or sector does not support slot filters")
      return
   end
   index = index or 1
   --Act according to the situation defined by the filter slot, slot item, and hand item.
   local menu = storage.players[pindex].menu
   local filter = Filters.get_filter_prototype(inv, index)
   local slot_item = inv[index]
   local hand_item = p.cursor_stack

   --1. If a  filter is set then clear it
   if filter ~= nil then
      Filters.set_filter(inv, index, nil)
      read_selected_inventory_and_slot(pindex, "Slot filter cleared, ")
      return
   --2. If no filter is set and both the slot and hand are full, then choose the slot item (because otherwise it needs to be moved)
   elseif slot_item and slot_item.valid_for_read and hand_item and hand_item.valid_for_read then
      if inv.can_set_filter(index, slot_item.name) then
         Filters.set_filter(inv, index, slot_item.name)
         read_selected_inventory_and_slot(pindex, "Slot filter set, ")
      else
         Speech.speak(pindex, "Error: Unable to set the slot filter for this item")
      end
      return
   --3. If no filter is set and the slot is full and the hand is empty (implied), then set the slot item as the filter
   elseif slot_item and slot_item.valid_for_read then
      if inv.can_set_filter(index, slot_item.name) then
         Filters.set_filter(inv, index, slot_item.name)
         read_selected_inventory_and_slot(pindex, "Slot filter set, ")
      else
         Speech.speak(pindex, "Error: Unable to set the slot filter for this item")
      end
      return
   --4. If no filter is set and the slot is empty (implied) and the hand is full, then set the hand item as the filter
   elseif hand_item and hand_item.valid_for_read then
      if inv.can_set_filter(index, hand_item.name) then
         Filters.set_filter(inv, index, hand_item.name)
         read_selected_inventory_and_slot(pindex, "Slot filter set, ")
      else
         Speech.speak(pindex, "Error: Unable to set the slot filter for this item")
      end
      return
   --5. If no filter is set and the hand is empty and the slot is empty, then open the filter selector to set the filter
   else --(implied)
      Speech.speak(pindex, "Error: No item specified for setting a slot filter")
      return
   end
end

EventManager.on_event(defines.events.on_gui_opened, function(event, pindex)
   local router = UiRouter.get_router(pindex)

   local p = game.get_player(pindex)

   --Stop any enabled mouse entity selection
   if storage.players[pindex].vanilla_mode ~= true then
      game.get_player(pindex).game_view_settings.update_entity_selection = false
   end
end)

EventManager.on_event(defines.events.on_object_destroyed, function(event) --DOES NOT HAVE THE KEY PLAYER_INDEX
   ScannerEntrypoint.on_entity_destroyed(event)
end)

--Scripts regarding train state changes. NOTE: NO PINDEX
EventManager.on_event(defines.events.on_train_changed_state, function(event)
   if event.train.state == defines.train_state.no_schedule then
      --Trains with no schedule are set back to manual mode
      event.train.manual_mode = true
   elseif event.train.state == defines.train_state.arrive_station then
      --Announce arriving station to players on the train
      for i, player in ipairs(event.train.passengers) do
         local stop = event.train.path_end_stop
         if stop ~= nil then Speech.speak(player.index, { "fa.train-arriving-at-station", stop.backer_name }) end
      end
   elseif event.train.state == defines.train_state.on_the_path then --laterdo make this announce only when near another trainstop.
      --Announce heading station to players on the train
      for i, player in ipairs(event.train.passengers) do
         local stop = event.train.path_end_stop
         if stop ~= nil then Speech.speak(player.index, { "fa.train-heading-to-station", stop.backer_name }) end
      end
   elseif event.train.state == defines.train_state.wait_signal then
      --Announce the wait to players on the train
      for i, player in ipairs(event.train.passengers) do
         local stop = event.train.path_end_stop
         if stop ~= nil then
            local str = " Waiting at signal. "
            Speech.speak(player.index, str)
         end
      end
   end
end)

--If a filter inserter is selected, the item in hand is set as its output filter item.
function set_inserter_filter_by_hand(pindex, ent)
   local stack = game.get_player(pindex).cursor_stack
   if ent.filter_slot_count == 0 then return "This inserter has no filters to set" end
   if stack == nil or stack.valid_for_read == false then
      --Delete last filter
      for i = ent.filter_slot_count, 1, -1 do
         local filt = Filters.get_filter_prototype(ent, i)
         if filt ~= nil then
            Filters.set_filter(ent, i, nil)
            return "Last filter cleared"
         end
      end
      return "All filters cleared"
   else
      --Add item in hand as next filter
      for i = 1, ent.filter_slot_count, 1 do
         local filt = Filters.get_filter_prototype(ent, i)
         if filt == nil then
            Filters.set_filter(ent, i, stack.name)
            if Filters.get_filter_prototype(ent, i) == stack.name then
               return "Added filter"
            else
               return "Filter setting failed"
            end
         end
      end
      return "All filters full"
   end
end

--If an infinity chest is selected, the item in hand is set as its filter item.
function set_infinity_chest_filter_by_hand(pindex, ent)
   local stack = game.get_player(pindex).cursor_stack
   ent.remove_unfiltered_items = false
   if stack == nil or stack.valid_for_read == false or stack.valid == false then
      --Delete filters
      ent.infinity_container_filters = {}
      ent.remove_unfiltered_items = true
      return "All filters cleared"
   else
      --Set item in hand as the filter
      ent.infinity_container_filters = {}
      ent.set_infinity_container_filter(1, { name = stack.name, count = stack.prototype.stack_size, mode = "exactly" })
      ent.remove_unfiltered_items = true
      return "Set filter to item in hand"
   end
end

function set_infinity_pipe_filter_by_hand(pindex, ent)
   local stack = game.get_player(pindex).cursor_stack
   if stack == nil or stack.valid_for_read == false or stack.valid == false then
      --Delete filters
      ent.set_infinity_pipe_filter(nil)
      return "All filters cleared"
   else
      --Get the fluid from the barrel in hand
      local name = stack.name
      local first, last = string.find(name, "-barrel")
      if first then
         local fluid_name = string.sub(name, 1, first - 1)
         local temp = 25
         if fluid_name == "water" then
            temp = 15
         elseif fluid_name == "empty" then
            --Special case: Empty barrel sets steam
            fluid_name = "steam"
            temp = 500
         end
         if prototypes.fluid[fluid_name] then
            ent.set_infinity_pipe_filter({ name = fluid_name, temperature = temp, percentage = 1.00, mode = "exactly" })
            return "Set filter to fluid in hand"
         end
         return "Error: Unknown fluid in hand " .. fluid_name
      end
      return "Error: Not a fluid barrel in hand"
   end
   return "Error setting fluid"
end

--Feature for typing in coordinates for moving the mod cursor.
function type_cursor_position(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   Speech.speak(pindex, "Enter new co-ordinates for the cursor, separated by a space")
   vp:set_cursor_jumping(true)
   local frame = Graphics.create_text_field_frame(pindex, "cursor-jump")
   return frame
end

--Result is a string of two numbers separated by a space
function jump_cursor_to_typed_coordinates(result, pindex)
   if result ~= nil and result ~= "" then
      local new_x = tonumber(FaUtils.get_substring_before_space(result))
      local new_y = tonumber(FaUtils.get_substring_after_space(result))
      --Check if valid numbers
      local valid_coords = new_x ~= nil and new_y ~= nil
      --Change cursor position or return error
      if valid_coords then
         local vp = Viewpoint.get_viewpoint(pindex)
         vp:set_cursor_pos(FaUtils.center_of_tile({ x = new_x + 0.01, y = new_y + 0.01 }))
         Speech.speak(pindex, { "fa.cursor-jumped-to", tostring(new_x), tostring(new_y) })
         Graphics.draw_cursor_highlight(pindex)
         Graphics.sync_build_cursor_graphics(pindex)
      else
         Speech.speak(pindex, { "fa.invalid-input" })
      end
   else
      Speech.speak(pindex, "Invalid input")
   end
end

--Alerts a force's players when their structures are destroyed. 300 ticks of cooldown.
EventManager.on_event(defines.events.on_entity_damaged, function(event)
   local ent = event.entity
   local tick = event.tick
   if ent == nil or not ent.valid then
      return
   elseif ent.name == "character" then
      --Check character has any energy shield health remaining
      if ent.player == nil or not ent.player.valid then return end
      local shield_left = nil
      local armor_inv = ent.player.get_inventory(defines.inventory.character_armor)
      if
         armor_inv[1]
         and armor_inv[1].valid_for_read
         and armor_inv[1].valid
         and armor_inv[1].grid
         and armor_inv[1].grid.valid
      then
         local grid = armor_inv[1].grid
         if grid.shield > 0 then
            shield_left = grid.shield
            --game.print(armor_inv[1].grid.shield,{volume_modifier=0})
         end
      end
      --Play shield and/or character damaged sound
      if shield_left ~= nil then sounds.play_player_damaged_shield(ent.player.index) end
      if shield_left == nil or (shield_left < 1.0 and ent.get_health_ratio() < 1.0) then
         sounds.play_player_damaged_character(ent.player.index)
      end
      return
   elseif ent.get_health_ratio() == 1.0 then
      --Ignore alerts if an entity has full health despite being damaged
      return
   elseif tick < 3600 and tick > 600 then
      --No alerts for the first 10th to 60th seconds (because of the alert spam from spaceship fire damage)
      return
   end

   local attacker_force = event.force
   local damaged_force = ent.force
   --Alert all players of the damaged force
   for pindex, player in pairs(players) do
      if
         storage.players[pindex] ~= nil
         and game.get_player(pindex).force.name == damaged_force.name
         and (
            storage.players[pindex].last_damage_alert_tick == nil
            or (tick - storage.players[pindex].last_damage_alert_tick) > 300
         )
      then
         storage.players[pindex].last_damage_alert_tick = tick
         storage.players[pindex].last_damage_alert_pos = ent.position
         local dist = math.ceil(util.distance(storage.players[pindex].position, ent.position))
         local dir =
            FaUtils.direction_lookup(FaUtils.get_direction_biased(ent.position, storage.players[pindex].position))
         local result = ent.name .. " damaged by " .. attacker_force.name .. " forces at " .. dist .. " " .. dir
         Speech.speak(pindex, result)
         --game.get_player(pindex).print(result,{volume_modifier=0})--**
         sounds.play_structure_damaged(pindex)
      end
   end
end)

--Alerts a force's players when their structures are destroyed. No cooldown.
EventManager.on_event(defines.events.on_entity_died, function(event)
   local ent = event.entity
   local causer = event.cause
   if ent == nil then
      return
   elseif ent.name == "character" then
      return
   end
   local attacker_force = event.force
   local damaged_force = ent.force
   --Alert all players of the damaged force
   for pindex, player in pairs(players) do
      if storage.players[pindex] ~= nil and game.get_player(pindex).force.name == damaged_force.name then
         storage.players[pindex].last_damage_alert_tick = event.tick
         storage.players[pindex].last_damage_alert_pos = ent.position
         local dist = math.ceil(util.distance(storage.players[pindex].position, ent.position))
         local dir =
            FaUtils.direction_lookup(FaUtils.get_direction_biased(ent.position, storage.players[pindex].position))
         local result = ent.name .. " destroyed by " .. attacker_force.name .. " forces at " .. dist .. " " .. dir
         Speech.speak(pindex, result)
         --game.get_player(pindex).print(result,{volume_modifier=0})--**
         sounds.play_alert_destroyed(pindex)
      end
   end
end)

--Notify all players when a player character dies
EventManager.on_event(defines.events.on_player_died, function(event, pindex)
   local p = game.get_player(pindex)
   local causer = event.cause
   local bodies = p.surface.find_entities_filtered({ name = "character-corpse" })
   local latest_body = nil
   local latest_death_tick = 0
   local name = p.name
   if name == nil then name = " " end
   --Find the most recent character corpse
   for i, body in ipairs(bodies) do
      if body.character_corpse_player_index == pindex and body.character_corpse_tick_of_death > latest_death_tick then
         latest_body = body
         latest_death_tick = latest_body.character_corpse_tick_of_death
      end
   end
   --Verify the latest death
   if event.tick - latest_death_tick > 120 then latest_body = nil end
   --Generate death message
   local result = "Player " .. name
   if causer == nil or not causer.valid then
      result = result .. " died "
   elseif causer.name == "character" and causer.player ~= nil and causer.player.valid then
      local other_name = causer.player.name
      if other_name == nil then other_name = "" end
      result = result .. " was killed by player " .. other_name
   else
      result = result .. " was killed by " .. causer.name
   end
   if latest_body ~= nil and latest_body.valid then
      result = result
         .. " at "
         .. math.floor(0.5 + latest_body.position.x)
         .. ", "
         .. math.floor(0.5 + latest_body.position.y)
         .. "."
   end
   --Notify all players
   for pindex, player in pairs(players) do
      storage.players[pindex].last_damage_alert_tick = event.tick
      Speech.speak(pindex, result)
      game.get_player(pindex).print(result) --**laterdo unique sound, for now use console sound
   end
end)

EventManager.on_event(defines.events.on_player_display_resolution_changed, function(event, pindex)
   local new_res = game.get_player(pindex).display_resolution
   if players and storage.players[pindex] then storage.players[pindex].display_resolution = new_res end
   game
      .get_player(pindex)
      .print("Display resolution changed: " .. new_res.width .. " x " .. new_res.height, { volume_modifier = 0 })
   schedule(3, "call_to_fix_zoom", pindex)
   schedule(4, "call_to_sync_graphics", pindex)
end)

EventManager.on_event(defines.events.on_player_display_scale_changed, function(event, pindex)
   local new_sc = game.get_player(pindex).display_scale
   if players and storage.players[pindex] then storage.players[pindex].display_resolution = new_sc end
   game.get_player(pindex).print("Display scale changed: " .. new_sc, { volume_modifier = 0 })
   schedule(3, "call_to_fix_zoom", pindex)
   schedule(4, "call_to_sync_graphics", pindex)
end)

EventManager.on_event(defines.events.on_string_translated, Localising.handler)

EventManager.on_event(defines.events.on_player_respawned, function(event, pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local position = game.get_player(pindex).position
   storage.players[pindex].position = position
   vp:set_cursor_pos({ x = position.x, y = position.y })
end)

--If the player has unexpected lateral movement while smooth running in a cardinal direction, like from bumping into an entity or being at the edge of water, play a sound.

function all_ents_are_walkable(pos)
   local ents = game.surfaces[1].find_entities_filtered({
      position = FaUtils.center_of_tile(pos),
      radius = 0.4,
      invert = true,
      type = Consts.ENT_TYPES_YOU_CAN_WALK_OVER,
   })
   for i, ent in ipairs(ents) do
      return false
   end
   return true
end

EventManager.on_event(defines.events.on_console_chat, function(event)
   local speaker = game.get_player(event.player_index).name
   if speaker == nil or speaker == "" then speaker = "Player" end
   local message = event.message
   for pindex, player in pairs(players) do
      Speech.speak(pindex, { "fa.chat-message", speaker, message })
   end
end)

EventManager.on_event(defines.events.on_console_command, function(event)
   -- For our own commands, we handle the speaking and must not read here.
   if FaCommands.COMMANDS[event.command] then return end

   local speaker = game.get_player(event.player_index).name
   if speaker == nil or speaker == "" then speaker = "Player" end
   for pindex, player in pairs(players) do
      Speech.speak(pindex, { "fa.command-message", speaker, event.command, event.parameters })
   end
end)

function general_mod_menu_up(pindex, menu, lower_limit_in) --todo*** use
   local lower_limit = lower_limit_in or 0
   menu.index = menu.index - 1
   if menu.index < lower_limit then
      menu.index = lower_limit
      sounds.play_ui_edge(pindex)
   else
      --Play sound
      sounds.play_menu_move(pindex)
   end
end

function general_mod_menu_down(pindex, menu, upper_limit)
   menu.index = menu.index + 1
   if menu.index > upper_limit then
      menu.index = upper_limit
      sounds.play_ui_edge(pindex)
   else
      --Play sound
      sounds.play_menu_move(pindex)
   end
end

EventManager.on_event(defines.events.on_script_trigger_effect, function(event)
   if event.effect_id == Consts.NEW_ENTITY_SUBSCRIBER_TRIGGER_ID then
      ScannerEntrypoint.on_new_entity(event.surface_index, event.source_entity)
   end
end)

EventManager.on_event(defines.events.on_surface_created, function(event)
   ScannerEntrypoint.on_new_surface(game.get_surface(event.surface_index))
end)

EventManager.on_event(defines.events.on_surface_deleted, function(event)
   ScannerEntrypoint.on_surface_delete(event.surface_index)
end)

EventManager.on_event(defines.events.on_research_finished, Research.on_research_finished)
-- New input event definitions

---@param pindex number
local function clear_fa_gui(pindex)
   local player = game.get_player(pindex)
   for _, elem in ipairs(FaUtils.get_iterable_array(player.gui.children)) do
      if elem.get_mod() == "FactorioAccess" or elem.get_mod() == nil then elem.clear() end
   end
end

--Pause / resume the game. If a menu GUI is open, ESC makes it close the menu instead
---@param event EventData
local function kb_pause_menu(event)
   local pindex = event.player_index
   local player = game.get_player(pindex)

   -- Play UI close sound
   sounds.play_close_inventory(player.index)

   -- Close remote view if open
   if storage.players[pindex].remote_view then
      toggle_remote_view(pindex, false, true)
      Speech.speak(pindex, "Remote view closed")
   end

   -- Close mod GUIs
   clear_fa_gui(pindex)
end

EventManager.on_event("fa-escape", function(event)
   kb_pause_menu(event)
end)

--Move the player character (or adapt the cursor to smooth walking)
--Returns false if failed to move
local function move(direction, pindex, nudged)
   local router = UiRouter.get_router(pindex)

   local p = game.get_player(pindex)
   if p.character == nil then return false end
   if p.vehicle then return true end
   local first_player = game.get_player(pindex)
   local pos = storage.players[pindex].position
   local new_pos = FaUtils.offset_position_legacy(pos, direction, 1)
   local moved_success = false
   local vp = Viewpoint.get_viewpoint(pindex)

   --Compare the input direction and facing direction
   if storage.players[pindex].player_direction == direction or nudged == true then
      --Same direction or nudging: For smooth walking, just return as Factorio handles movement
      if nudged ~= true then return end
      new_pos = FaUtils.center_of_tile(new_pos)
      can_port = first_player.surface.can_place_entity({ name = "character", position = new_pos })
      if can_port then
         --If nudged then teleport now
         teleported = first_player.teleport(new_pos)
         if not teleported then
            Speech.speak(pindex, "Teleport Failed")
            moved_success = false
         else
            moved_success = true
         end
         storage.players[pindex].position = new_pos
         if nudged ~= true then
            vp:set_cursor_pos(FaUtils.offset_position_legacy(storage.players[pindex].position, direction, 1))
         end
         --Telestep walking sounds
         if
            EntitySelection.get_tile_cache(pindex).previous ~= nil
            and EntitySelection.get_tile_cache(pindex).previous.valid
            and EntitySelection.get_tile_cache(pindex).previous.type == "transport-belt"
         then
            sounds.play_metal_walking(pindex)
         else
            local tile = game.get_player(pindex).surface.get_tile(new_pos.x, new_pos.y)
            local sound_path = "tile-walking/" .. tile.name
            if helpers.is_valid_sound_path(sound_path) then
               sounds.play_tile_walking(pindex, tile.name)
            else
               sounds.play_tile_walking(pindex)
            end
         end
         if nudged ~= true then read_tile(pindex) end

         local stack = first_player.cursor_stack
         if stack and stack.valid_for_read and stack.valid and stack.prototype.place_result ~= nil then
            Graphics.sync_build_cursor_graphics(pindex)
         end

         if storage.players[pindex].build_lock then BuildingTools.build_item_in_hand(pindex) end
      else
         Speech.speak(pindex, "Tile Occupied")
         moved_success = false
      end

      --Play a sound for audio ruler alignment (telestep moved)
      Rulers.update_from_cursor(pindex)
   else
      --New direction: Turn character for smooth walking
      storage.players[pindex].player_direction = direction
      vp:set_cursor_pos(new_pos)
      moved_success = true

      local stack = first_player.cursor_stack
      if stack and stack.valid_for_read and stack.valid and stack.prototype.place_result ~= nil then
         Graphics.sync_build_cursor_graphics(pindex)
      end

      --Read the new entity or unwalkable surface found upon turning
      EntitySelection.refresh_player_tile(pindex)
      local ent = EntitySelection.get_first_ent_at_tile(pindex)
      if
         not storage.players[pindex].vanilla_mode
         and (
            (ent ~= nil and ent.valid)
            or not game
               .get_player(pindex).surface
               .can_place_entity({ name = "character", position = vp:get_cursor_pos() })
         )
      then
         target_mouse_pointer_deprecated(pindex)
         read_tile(pindex)
      end

      --Rotate belts in hand for build lock Mode
      local stack = game.get_player(pindex).cursor_stack
      if
         storage.players[pindex].build_lock
         and stack.valid_for_read
         and stack.valid
         and stack.prototype.place_result ~= nil
         and stack.prototype.place_result.type == "transport-belt"
      then
         storage.players[pindex].building_direction = storage.players[pindex].player_direction
      end

      --Play a sound for audio ruler alignment (telestep turned)
      Rulers.update_from_cursor(pindex)
   end

   --Update cursor highlight
   local ent = EntitySelection.get_first_ent_at_tile(pindex)
   if ent and ent.valid then
      Graphics.draw_cursor_highlight(pindex, ent, nil)
   else
      Graphics.draw_cursor_highlight(pindex, nil, nil)
   end

   return moved_success
end

--Moves the cursor, and conducts an area scan for larger cursors. If the player is in a slow moving vehicle, it is stopped.
local function cursor_mode_move(direction, pindex, single_only)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local cursor_size = vp:get_cursor_size()
   local diff = cursor_size * 2 + 1
   if single_only then diff = 1 end
   local p = game.get_player(pindex)

   cursor_pos = FaUtils.center_of_tile(FaUtils.offset_position_legacy(cursor_pos, direction, diff))
   vp:set_cursor_pos(cursor_pos)

   if cursor_size == 0 then
      -- Cursor size 0 ("1 by 1"): Read tile
      read_tile(pindex)

      --Update drawn cursor
      local stack = p.cursor_stack
      if
         stack
         and stack.valid_for_read
         and stack.valid
         and (stack.prototype.place_result ~= nil or stack.is_blueprint)
      then
         Graphics.sync_build_cursor_graphics(pindex)
      end

      --Apply build lock if active
      if storage.players[pindex].build_lock and stack and stack.valid_for_read and stack.valid then
         BuildingTools.build_item_in_hand(pindex)
      end

      --Update cursor highlight
      local ent = EntitySelection.get_first_ent_at_tile(pindex)
      if ent and ent.valid then
         Graphics.draw_cursor_highlight(pindex, ent, nil)
      else
         Graphics.draw_cursor_highlight(pindex, nil, nil)
      end
   else
      -- Larger cursor sizes: scan area
      local scan_left_top = {
         x = math.floor(cursor_pos.x) - cursor_size,
         y = math.floor(cursor_pos.y) - cursor_size,
      }
      local scan_right_bottom = {
         x = math.floor(cursor_pos.x) + cursor_size + 1,
         y = math.floor(cursor_pos.y) + cursor_size + 1,
      }
      local scan_summary = FaInfo.area_scan_summary_info(pindex, scan_left_top, scan_right_bottom)
      Graphics.draw_large_cursor(scan_left_top, scan_right_bottom, pindex)
      Speech.speak(pindex, scan_summary)
   end

   --Update player direction to face the cursor (after the vanilla move event that turns the character too, and only ends when the movement key is released)
   turn_to_cursor_direction_precise(pindex)

   --Play Sound
   if storage.players[pindex].remote_view then
      sounds.play_building_placement(p.index, cursor_pos)
   else
      p.play_sound({
         path = "Close-Inventory-Sound",
         position = storage.players[pindex].position,
         volume_modifier = 0.75,
      })
   end
end

--Chooses the function to call after a movement keypress, according to the current mode.
local function move_key(direction, event, force_single_tile)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local router = UiRouter.get_router(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_enabled = vp:get_cursor_enabled()

   --Stop any enabled mouse entity selection
   if storage.players[pindex].vanilla_mode ~= true then
      game.get_player(pindex).game_view_settings.update_entity_selection = false
   end

   --Reset unconfirmed actions
   storage.players[pindex].confirm_action_tick = 0

   --Save the key press event
   BumpDetection.save_key_press(event.player_index, direction, event.tick)

   if cursor_enabled then
      -- Cursor mode: Move cursor on map
      cursor_mode_move(direction, pindex, force_single_tile)
   else
      -- General case: Move character
      move(direction, pindex)
   end

   --Play a sound to indicate ongoing selection
   if storage.players[pindex].bp_selecting then sounds.play_cursor_moved_while_selecting(pindex) end

   --Play a sound for audio ruler alignment (cursor mode moved)
   if cursor_enabled then Rulers.update_from_cursor(pindex) end

   --Handle vehicle behavior
   if p.vehicle then
      if p.vehicle.type == "car" then
         --Deactivate (and stop) cars when in a menu
         if cursor_enabled then p.vehicle.active = false end
         --Re-activate inactive cars when in no menu
         if not cursor_enabled and p.vehicle.active == false then
            p.vehicle.active = true
            p.vehicle.speed = 0
         end
         --Re-activate inactive cars if in Kruise Kontrol
         if KruiseKontrol.is_active(pindex) then
            p.vehicle.active = true
            p.vehicle.speed = 0
         end
      end
   end
end

EventManager.on_event(
   "fa-w",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      move_key(defines.direction.north, event)
   end
)

EventManager.on_event(
   "fa-a",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      move_key(defines.direction.west, event)
   end
)

EventManager.on_event(
   "fa-s",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      move_key(defines.direction.south, event)
   end
)

EventManager.on_event(
   "fa-d",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      move_key(defines.direction.east, event)
   end
)

EventManager.on_event(
   "fa-up",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      local vp = Viewpoint.get_viewpoint(pindex)
      if vp:get_cursor_enabled() then move_key(dirs.north, event, true) end
   end
)

EventManager.on_event(
   "fa-left",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      local vp = Viewpoint.get_viewpoint(pindex)
      if vp:get_cursor_enabled() then move_key(dirs.west, event, true) end
   end
)

EventManager.on_event(
   "fa-down",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      local vp = Viewpoint.get_viewpoint(pindex)
      if vp:get_cursor_enabled() then move_key(dirs.south, event, true) end
   end
)

EventManager.on_event(
   "fa-right",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      local vp = Viewpoint.get_viewpoint(pindex)
      if vp:get_cursor_enabled() then move_key(dirs.east, event, true) end
   end
)

--Moves the cursor in the same direction multiple times until the reported entity changes. Change includes: new entity name or new direction for entites with the same name, or changing between nil and ent. Returns move count.
local function cursor_skip_iteration(pindex, direction, iteration_limit)
   local p = game.get_player(pindex)
   local start = nil
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local start_tile_is_water = FaUtils.tile_is_water(p.surface, cursor_pos)
   local start_tile_is_ruler_aligned = Rulers.is_any_ruler_aligned(pindex, cursor_pos)
   local current = nil
   local limit = iteration_limit or 100
   local moved = 1
   local comment = ""

   -- Returns a new value for current or nil, ignoring a list of entities.
   --
   ---@returns LuaEntity?
   local function compute_current()
      EntitySelection.refresh_player_tile(pindex)
      for ent in EntitySelection.iterate_selected_ents(pindex) do
         local bad = ent.type == "logistic-robot"
            or ent.type == "construction-robot"
            or ent.type == "combat-robot"
            or ent.type == "corpse"
         if not bad then return ent end
      end

      return nil
   end

   start = compute_current()

   --For pipes to ground, apply a special case where you jump to the underground neighbour
   if start ~= nil and start.valid and start.type == "pipe-to-ground" then
      local connections = start.fluidbox.get_pipe_connections(1)
      for i, con in ipairs(connections) do
         if con.target ~= nil then
            local dist = math.ceil(util.distance(start.position, con.target.get_pipe_connections(1)[1].position))
            local dir_neighbor = FaUtils.get_direction_biased(con.target_position, start.position)
            if con.connection_type == "underground" and dir_neighbor == direction then
               vp:set_cursor_pos(con.target.get_pipe_connections(1)[1].position)
               EntitySelection.refresh_player_tile(pindex)
               current = EntitySelection.get_first_ent_at_tile(pindex)
               return dist
            end
         end
      end
   --For underground belts, apply a special case where you jump to the underground neighbour
   elseif start ~= nil and start.valid and start.type == "underground-belt" then
      local neighbour = start.neighbours
      if neighbour then
         local other_end = neighbour
         local dist = math.ceil(util.distance(start.position, other_end.position))
         local dir_neighbor = FaUtils.get_direction_biased(other_end.position, start.position)
         if dir_neighbor == direction then
            vp:set_cursor_pos(other_end.position)
            EntitySelection.refresh_player_tile(pindex)
            current = EntitySelection.get_first_ent_at_tile(pindex)
            return dist
         end
      end
   --For water start, find the first non-water tile
   elseif start_tile_is_water then
      local selected_tile_is_water = nil
      --Iterate first_tile
      cursor_pos = FaUtils.offset_position_legacy(cursor_pos, direction, 1)
      vp:set_cursor_pos(cursor_pos)
      selected_tile_is_water = FaUtils.tile_is_water(p.surface, cursor_pos)

      --Run checks and skip when needed
      while moved < limit do
         if selected_tile_is_water == false then
            --Water tile -> non-water tile found
            return moved
         else
            --For audio rulers, stop if crossing into or out of alignment with any rulers
            local current_tile_is_ruler_aligned = Rulers.is_any_ruler_aligned(pindex, cursor_pos)
            if start_tile_is_ruler_aligned ~= current_tile_is_ruler_aligned then
               Rulers.update_from_cursor(pindex)
               return moved
            --Also for rulers, stop if at the definiton point of any ruler
            elseif Rulers.is_at_any_ruler_definition(pindex, cursor_pos) then
               Rulers.update_from_cursor(pindex)
               return moved
            end
            --Iterate again
            cursor_pos = FaUtils.offset_position_legacy(cursor_pos, direction, 1)
            vp:set_cursor_pos(cursor_pos)
            selected_tile_is_water = FaUtils.tile_is_water(p.surface, cursor_pos)
            moved = moved + 1
         end
      end
      --Reached limit
      return -1
   end
   --Iterate first tile
   cursor_pos = FaUtils.offset_position_legacy(cursor_pos, direction, 1)
   vp:set_cursor_pos(cursor_pos)

   current = compute_current()

   --Run checks and skip when needed
   while moved < limit do
      --For audio rulers, stop if crossing into or out of alignment with any rulers
      local current_tile_is_ruler_aligned = Rulers.is_any_ruler_aligned(pindex, cursor_pos)
      if start_tile_is_ruler_aligned ~= current_tile_is_ruler_aligned then
         Rulers.update_from_cursor(pindex)
         return moved
      --Also for rulers, stop if at the definiton point of any ruler
      elseif Rulers.is_at_any_ruler_definition(pindex, cursor_pos) then
         Rulers.update_from_cursor(pindex)
         return moved
      end
      --Check the current entity or tile against the starting one
      if current == nil then
         if start == nil then
            --Both are nil: check if water, else skip
            local selected_tile_is_water = FaUtils.tile_is_water(p.surface, cursor_pos)
            if selected_tile_is_water then
               --Non-water tile -> water tile found
               return moved
            else
               --skip
            end
         else
            --Valid start ent -> nil found
            return moved
         end
      else
         if start == nil or start.valid == false then
            --Nil entity start -> valid entity found
            return moved
         else
            --Both are valid
            if start.unit_number == current.unit_number and current.type ~= "resource" then
               --They are the same ent: skip
            else
               --They are different ents OR they are resource ents (which can have the same unit number despite being different ents)
               if start.name ~= current.name then
                  --They have different names: return
                  --p.print("RET 1, start: " .. start.name .. ", current: " .. current.name .. ", comment:" .. comment)--
                  return moved
               else
                  --They have the same name
                  if current.supports_direction == false then
                     --They both do not support direction: skip
                  else
                     --They support direction
                     if current.direction ~= start.direction then
                        --They have different directions: return
                        --p.print("RET 2, start: " .. start.name .. ", current: " .. current.name .. ", comment:" .. comment)--
                        return moved
                     else
                        --They have same direction: skip

                        --Exception for transport belts facing the same direction: Return if neighbor counts or shapes are different
                        if start.type == "transport-belt" then
                           local start_input_neighbors = #start.belt_neighbours["inputs"]
                           local start_output_neighbors = #start.belt_neighbours["outputs"]
                           local current_input_neighbors = #current.belt_neighbours["inputs"]
                           local current_output_neighbors = #current.belt_neighbours["outputs"]
                           if
                              start_input_neighbors ~= current_input_neighbors
                              or start_output_neighbors ~= current_output_neighbors
                              or start.belt_shape ~= current.belt_shape
                           then
                              --p.print("RET 3, start: " .. start.name .. ", current: " .. current.name .. ", comment:" .. comment)--
                              return moved
                           end
                        end
                     end
                  end
               end
            end
            --p.print("start: " .. start.name .. ", current: " .. current.name .. ", comment:" .. comment)--
         end
      end
      --Skip case: Move 1 more tile
      cursor_pos = FaUtils.offset_position_legacy(cursor_pos, direction, 1)
      vp:set_cursor_pos(cursor_pos)
      moved = moved + 1
      current = compute_current()
   end
   --Reached limit
   return -1
end

--Shift the cursor by the size of the preview in hand or otherwise by the size of the cursor.
local function apply_skip_by_preview_size(pindex, direction)
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()

   --Check the moved count against the dimensions of the preview in hand
   local stack = p.cursor_stack
   if stack and stack.valid_for_read then
      if stack.is_blueprint and stack.is_blueprint_setup() then
         local width, height = Blueprints.get_blueprint_width_and_height(pindex)
         if width and height and (width + height > 2) then
            --For blueprints larger than 1x1, check if the height/width has been travelled.
            if direction == dirs.east or direction == dirs.west then
               vp:set_cursor_pos(FaUtils.offset_position_legacy(cursor_pos, direction, width + 1))
               return width
            elseif direction == dirs.north or direction == dirs.south then
               vp:set_cursor_pos(FaUtils.offset_position_legacy(cursor_pos, direction, height + 1))
               return height
            end
         end
      elseif stack.prototype.place_result then
         local width = stack.prototype.place_result.tile_width
         local height = stack.prototype.place_result.tile_height
         if width and height and (width + height > 2) then
            --For entities larger than 1x1, check if the height/width has been travelled.
            if direction == dirs.east or direction == dirs.west then
               vp:set_cursor_pos(FaUtils.offset_position_legacy(cursor_pos, direction, width))
               return width
            elseif direction == dirs.north or direction == dirs.south then
               vp:set_cursor_pos(FaUtils.offset_position_legacy(cursor_pos, direction, height))
               return height
            end
         end
      end
   end

   --Offset by cursor size if not something else
   local shift = (vp:get_cursor_size() * 2 + 1)
   vp:set_cursor_pos(FaUtils.offset_position_legacy(cursor_pos, direction, shift))
   return shift
end

--Runs the cursor skip actions and reads out results
local function cursor_skip(pindex, direction, iteration_limit, use_preview_size)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local cursor_size = vp:get_cursor_size()
   local p = game.get_player(pindex)
   local limit = iteration_limit or 100
   local result = ""
   local skip_by_preview_size = use_preview_size or false

   --Run the iteration and play sound
   local moved_count = 0
   if skip_by_preview_size == true then
      moved_count = apply_skip_by_preview_size(pindex, direction)
      result = "Skipped by preview size " .. moved_count .. ", "
   else
      moved_count = cursor_skip_iteration(pindex, direction, limit)
      result = "Skipped "
   end
   if skip_by_preview_size then
      --Rolling always plays the regular moving sound
      if storage.players[pindex].remote_view then
         sounds.play_building_placement(p.index, cursor_pos)
      else
         p.play_sound({
            path = "Close-Inventory-Sound",
            position = storage.players[pindex].position,
            volume_modifier = 1,
         })
      end
   elseif moved_count < 0 then
      --No change found within the limit
      result = result .. limit .. " tiles without a change, "
      --Play Sound
      if storage.players[pindex].remote_view then
         sounds.play_sound_at_position({ path = "inventory-wrap-around", volume_modifier = 1 }, cursor_pos)
      else
         p.play_sound({
            path = "inventory-wrap-around",
            position = storage.players[pindex].position,
            volume_modifier = 1,
         })
      end
   elseif moved_count == 1 then
      result = ""
      --Play Sound
      if storage.players[pindex].remote_view then
         sounds.play_building_placement(p.index, cursor_pos)
      else
         p.play_sound({
            path = "Close-Inventory-Sound",
            position = storage.players[pindex].position,
            volume_modifier = 1,
         })
      end
   elseif moved_count > 1 then
      --Change found, with more than 1 tile moved
      result = result .. moved_count .. " tiles, "
      --Play Sound
      if storage.players[pindex].remote_view then
         sounds.play_sound_at_position({ path = "inventory-wrap-around", volume_modifier = 1 }, cursor_pos)
      else
         p.play_sound({
            path = "inventory-wrap-around",
            position = storage.players[pindex].position,
            volume_modifier = 1,
         })
      end
   end

   --Read the tile reached
   read_tile(pindex, result)
   Graphics.sync_build_cursor_graphics(pindex)

   --Draw large cursor boxes if present
   if cursor_size > 0 then
      local left_top = {
         math.floor(cursor_pos.x) - cursor_size,
         math.floor(cursor_pos.y) - cursor_size,
      }
      local right_bottom = {
         math.floor(cursor_pos.x) + cursor_size + 1,
         math.floor(cursor_pos.y) + cursor_size + 1,
      }
      Graphics.draw_large_cursor(left_top, right_bottom, pindex)
   end
end

EventManager.on_event(
   "fa-s-w",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].vanilla_mode or Viewpoint.get_viewpoint(pindex):get_cursor_enabled() == false then
         return
      end

      cursor_skip(pindex, defines.direction.north)
   end
)

EventManager.on_event(
   "fa-s-a",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].vanilla_mode or Viewpoint.get_viewpoint(pindex):get_cursor_enabled() == false then
         return
      end

      cursor_skip(pindex, defines.direction.west)
   end
)

EventManager.on_event(
   "fa-s-s",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].vanilla_mode or Viewpoint.get_viewpoint(pindex):get_cursor_enabled() == false then
         return
      end

      cursor_skip(pindex, defines.direction.south)
   end
)

EventManager.on_event(
   "fa-s-d",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].vanilla_mode or Viewpoint.get_viewpoint(pindex):get_cursor_enabled() == false then
         return
      end

      cursor_skip(pindex, defines.direction.east)
   end
)

EventManager.on_event(
   "fa-c-w",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].vanilla_mode or Viewpoint.get_viewpoint(pindex):get_cursor_enabled() == false then
         return
      end

      cursor_skip(pindex, defines.direction.north, 1000, true)
   end
)

EventManager.on_event(
   "fa-c-a",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].vanilla_mode or Viewpoint.get_viewpoint(pindex):get_cursor_enabled() == false then
         return
      end

      cursor_skip(pindex, defines.direction.west, 1000, true)
   end
)

EventManager.on_event(
   "fa-c-s",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].vanilla_mode or Viewpoint.get_viewpoint(pindex):get_cursor_enabled() == false then
         return
      end

      cursor_skip(pindex, defines.direction.south, 1000, true)
   end
)

EventManager.on_event(
   "fa-c-d",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].vanilla_mode or Viewpoint.get_viewpoint(pindex):get_cursor_enabled() == false then
         return
      end

      cursor_skip(pindex, defines.direction.east, 1000, true)
   end
)

EventManager.on_event(
   "fa-s-up",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      BuildingTools.nudge_key(defines.direction.north, event)
   end
)

EventManager.on_event(
   "fa-s-left",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      BuildingTools.nudge_key(defines.direction.west, event)
   end
)

EventManager.on_event(
   "fa-s-down",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      BuildingTools.nudge_key(defines.direction.south, event)
   end
)

EventManager.on_event(
   "fa-s-right",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      BuildingTools.nudge_key(defines.direction.east, event)
   end
)

---@param event EventData.CustomInputEvent
---@param direction defines.direction
---@param name string
local function nudge_self(event, direction, name)
   local pindex = event.player_index
   if move(direction, pindex, true) then
      Speech.speak(pindex, { "fa.nudged-self", name })
      turn_to_cursor_direction_precise(pindex)
   else
      Speech.speak(pindex, "Failed to nudge self")
   end
end

EventManager.on_event(
   "fa-c-up",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      nudge_self(event, defines.direction.north, "north")
   end
)

EventManager.on_event(
   "fa-c-left",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      nudge_self(event, defines.direction.west, "west")
   end
)

EventManager.on_event(
   "fa-c-down",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      nudge_self(event, defines.direction.south, "south")
   end
)

EventManager.on_event(
   "fa-c-right",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      nudge_self(event, defines.direction.east, "east")
   end
)

--Read the current co-ordinates of the cursor on the map or in a menu. For crafting recipe and technology menus, it reads the ingredients / requirements instead.
--Todo: split this function by menu.
local function read_coords(pindex, start_phrase)
   local vp = Viewpoint.get_viewpoint(pindex)

   start_phrase = start_phrase or ""
   local result = start_phrase
   local ent = storage.players[pindex].building.ent
   local offset = 0

   local router = UiRouter.get_router(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)

   if storage.players[pindex].building.recipe_list ~= nil then offset = 1 end

   local position = game.get_player(pindex).position
   local marked_pos = { x = position.x, y = position.y }
   if storage.players[pindex].vanilla_mode then vp:set_cursor_pos(marked_pos) end
   if game.get_player(pindex).driving then
      --Give vehicle coords and orientation and speed --laterdo find exact speed coefficient
      local vehicle = game.get_player(pindex).vehicle
      assert(vehicle ~= nil) -- When driving is true, vehicle is guaranteed to exist
      local speed = vehicle.speed * 215
      local message = Speech.new()

      if start_phrase then message:fragment(start_phrase) end

      if vehicle.type ~= "spider-vehicle" then
         if speed > 0 then
            message:fragment({
               "fa.vehicle-heading",
               Localising.get_localised_name_with_fallback(vehicle),
               FaUtils.get_heading_info(vehicle),
               tostring(math.floor(speed)),
            })
         elseif speed < 0 then
            message:fragment({
               "fa.vehicle-reversing",
               Localising.get_localised_name_with_fallback(vehicle),
               FaUtils.get_heading_info(vehicle),
               tostring(math.floor(-speed)),
            })
         else
            message:fragment({
               "fa.vehicle-parked",
               Localising.get_localised_name_with_fallback(vehicle),
               FaUtils.get_heading_info(vehicle),
            })
         end
      else
         message:fragment({
            "fa.vehicle-spider-moving",
            Localising.get_localised_name_with_fallback(vehicle),
            tostring(math.floor(speed)),
         })
      end

      message:fragment({
         "fa.vehicle-position-in",
         Localising.get_localised_name_with_fallback(vehicle),
         tostring(math.floor(vehicle.position.x)),
         tostring(math.floor(vehicle.position.y)),
      })

      Speech.speak(pindex, message:build())
   else
      --Simply give coords (floored for the readout, extra precision for the console)
      local location = FaUtils.get_entity_part_at_cursor(pindex)
      local message = Speech.new()

      if start_phrase then message:fragment(start_phrase) end

      if location and location ~= " " then
         message:fragment({
            "fa.coordinates-at-with-location",
            "",
            location,
            tostring(math.floor(marked_pos.x)),
            tostring(math.floor(marked_pos.y)),
         })
      else
         message:fragment({
            "fa.coordinates-at",
            "",
            tostring(math.floor(marked_pos.x)),
            tostring(math.floor(marked_pos.y)),
         })
      end

      -- Also print to console with extra precision
      game.get_player(pindex).print(
         (start_phrase or "")
            .. " at "
            .. math.floor(marked_pos.x)
            .. ", "
            .. math.floor(marked_pos.y)
            .. "\n ("
            .. math.floor(marked_pos.x * 10) / 10
            .. ", "
            .. math.floor(marked_pos.y * 10) / 10
            .. ")",
         { volume_modifier = 0 }
      )
      --Draw the point
      rendering.draw_circle({
         color = { 1.0, 0.2, 0.0 },
         radius = 0.1,
         width = 5,
         target = marked_pos,
         surface = game.get_player(pindex).surface,
         time_to_live = 180,
      })

      --If there is a build preview, give its dimensions and which way they extend
      local stack = game.get_player(pindex).cursor_stack
      local cursor_enabled = vp:get_cursor_enabled()
      if
         stack
         and stack.valid_for_read
         and stack.valid
         and stack.prototype.place_result ~= nil
         and (stack.prototype.place_result.tile_height > 1 or stack.prototype.place_result.tile_width > 1)
      then
         local dir = storage.players[pindex].building_direction
         turn_to_cursor_direction_cardinal(pindex)
         local p_dir = storage.players[pindex].player_direction

         message:fragment({ "fa.build-preview-intro" })

         -- Width dimension
         local width_tiles
         if dir == dirs.north or dir == dirs.south then
            width_tiles = stack.prototype.place_result.tile_width
         else
            width_tiles = stack.prototype.place_result.tile_height
         end
         message:fragment({ "fa.build-preview-wide", tostring(width_tiles) })

         -- Width direction
         if cursor_enabled or p_dir == dirs.east or p_dir == dirs.south or p_dir == dirs.north then
            message:fragment({ "fa.build-preview-east" })
         elseif not cursor_enabled and p_dir == dirs.west then
            message:fragment({ "fa.build-preview-west" })
         end

         message:fragment({ "fa.build-preview-and" })

         -- Height dimension
         local height_tiles
         if dir == dirs.north or dir == dirs.south then
            height_tiles = stack.prototype.place_result.tile_height
         else
            height_tiles = stack.prototype.place_result.tile_width
         end
         message:fragment({ "fa.build-preview-high", tostring(height_tiles) })

         -- Height direction
         if cursor_enabled or p_dir == dirs.east or p_dir == dirs.south or p_dir == dirs.west then
            message:fragment({ "fa.build-preview-south" })
         elseif not cursor_enabled and p_dir == dirs.north then
            message:fragment({ "fa.build-preview-north" })
         end
      elseif stack and stack.valid_for_read and stack.valid and stack.is_blueprint and stack.is_blueprint_setup() then
         --Blueprints have their own data
         local left_top, right_bottom, build_pos = Blueprints.get_blueprint_corners(pindex, false)
         local bp_dim_1 = right_bottom.x - left_top.x
         local bp_dim_2 = right_bottom.y - left_top.y
         message:fragment({ "fa.blueprint-preview", tostring(bp_dim_1), tostring(bp_dim_2) })
      elseif stack and stack.valid_for_read and stack.valid and stack.prototype.place_as_tile_result ~= nil then
         --Paving preview size
         local size = vp:get_cursor_size() * 2 + 1
         if cursor_enabled and storage.players[pindex].preferences.tiles_placed_from_northwest_corner then
            message:fragment({ "fa.paving-preview-northwest", tostring(size), tostring(size) })
         else
            message:fragment({ "fa.paving-preview-centered", tostring(size), tostring(size) })
         end
      end
      Speech.speak(pindex, message:build())
   end
   if storage.players[pindex].building.recipe_selection == false then
      --Give slot coords (chest/building inventory)
      local x = -1 --Col number
      local y = -1 --Row number
      local row_length = storage.players[pindex].preferences.building_inventory_row_length
      x = storage.players[pindex].building.index % row_length
      y = math.floor(storage.players[pindex].building.index / row_length) + 1
      if x == 0 then
         x = x + row_length
         y = y - 1
      end
      local msg = Speech.new()
      if result then msg:fragment(result) end
      msg:fragment({ "fa.building-slot-position", tostring(x), tostring(y) })
      Speech.speak(pindex, msg:build())
   end
   if storage.players[pindex].building.recipe_selection then
      --Read recipe ingredients / products (building recipe selection)
      local recipe =
         storage.players[pindex].building.recipe_list[storage.players[pindex].building.category][storage.players[pindex].building.index]
      local msg = Speech.new()
      if result then msg:fragment(result) end
      msg:fragment("Ingredients: ")
      for i, v in pairs(recipe.ingredients) do
         ---@type LuaItemPrototype | LuaFluidPrototype
         local proto = prototypes.item[v.name]
         if proto == nil then proto = prototypes.fluid[v.name] end
         local name = Localising.get_localised_name_with_fallback(proto)
         msg:fragment(", ")
         msg:fragment(name)
         msg:fragment(" x")
         msg:fragment(tostring(v.amount))
         msg:fragment(" per cycle ")
      end
      msg:fragment(", products: ")
      for i, v in pairs(recipe.products) do
         ---@type LuaItemPrototype | LuaFluidPrototype
         local proto = prototypes.item[v.name]
         if proto == nil then proto = prototypes.fluid[v.name] end
         local name = Localising.get_localised_name_with_fallback(proto)
         msg:fragment(", ")
         msg:fragment(name)
         msg:fragment(" x")
         msg:fragment(tostring(v.amount))
         msg:fragment(" per cycle ")
      end
      msg:fragment(", craft time ")
      msg:fragment(tostring(recipe.energy))
      msg:fragment(" seconds at default speed.")
      Speech.speak(pindex, msg:build())
   end
end

--Read coordinates of the cursor. Extra info as well such as entity part if an entity is selected, and heading and speed info for vehicles.
EventManager.on_event(
   "fa-k",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      read_coords(pindex)
   end
)

--Get distance and direction of cursor from player.
---@param event EventData.CustomInputEvent
local function kb_read_cursor_distance_and_direction(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   --Read where the cursor is with respect to the player, e.g. "at 5 west"
   local dir_dist = FaUtils.dir_dist_locale(storage.players[pindex].position, cursor_pos)
   local cursor_location_description = "At"
   local cursor_production = " "
   local cursor_description_of = " "
   local result = { "fa.thing-producing-listpos-dirdist", cursor_location_description }
   table.insert(result, cursor_production) --no production
   table.insert(result, cursor_description_of) --listpos
   table.insert(result, dir_dist)
   Speech.speak(pindex, result)
   game.get_player(pindex).print(result, { volume_modifier = 0 })
   --Draw the point
   rendering.draw_circle({
      color = { 1, 0.2, 0 },
      radius = 0.1,
      width = 5,
      target = cursor_pos,
      surface = game.get_player(pindex).surface,
      time_to_live = 180,
   })
end

EventManager.on_event(
   "fa-s-k",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_read_cursor_distance_and_direction(event)
   end
)

--Get distance and direction of cursor from player as a vector with a horizontal component and vertical component.
---@param event EventData.CustomInputEvent
local function kb_read_cursor_distance_vector(event)
   local pindex = event.player_index
   local vp = Viewpoint.get_viewpoint(pindex)
   local c_pos = vp:get_cursor_pos()
   local p_pos = storage.players[pindex].position
   local diff_x = math.floor(c_pos.x) - math.floor(p_pos.x)
   local diff_y = math.floor(c_pos.y) - math.floor(p_pos.y)

   ---@type defines.direction
   local dir_x = dirs.east

   if diff_x < 0 then dir_x = dirs.west end

   ---@type defines.direction
   local dir_y = dirs.south

   if diff_y < 0 then dir_y = dirs.north end
   local result = "At "
      .. math.abs(diff_x)
      .. " "
      .. FaUtils.direction_lookup(dir_x)
      .. " and "
      .. math.abs(diff_y)
      .. " "
      .. FaUtils.direction_lookup(dir_y)
   Speech.speak(pindex, result)
   game.get_player(pindex).print(result, { volume_modifier = 0 })
   --Show cursor position
   rendering.draw_circle({
      color = { 1, 0.2, 0 },
      radius = 0.1,
      width = 5,
      target = c_pos,
      surface = game.get_player(pindex).surface,
      time_to_live = 180,
   })
end

EventManager.on_event(
   "fa-a-k",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      kb_read_cursor_distance_vector(event)
   end
)

local function kb_read_character_coords(event)
   local pindex = event.player_index
   local pos = game.get_player(pindex).position
   local result = "Character at " .. math.floor(pos.x) .. ", " .. math.floor(pos.y)
   --Report co-ordinates (floored for the readout, extra precision for the console)
   Speech.speak(pindex, result)
   game.get_player(pindex).print(
      result .. "\n (" .. math.floor(pos.x * 10) / 10 .. ", " .. math.floor(pos.y * 10) / 10 .. ")",
      { volume_modifier = 0 }
   )
end

EventManager.on_event(
   "fa-c-k",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_read_character_coords(event)
   end
)

--Teleports the cursor to the player character
---@param event EventData.CustomInputEvent
local function kb_jump_to_player(event)
   local pindex = event.player_index
   local first_player = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local cursor_size = vp:get_cursor_size()
   cursor_pos.x = math.floor(first_player.position.x) + 0.5
   cursor_pos.y = math.floor(first_player.position.y) + 0.5
   vp:set_cursor_pos(cursor_pos)
   read_coords(pindex, "Cursor returned ")
   if cursor_size < 2 then
      Graphics.draw_cursor_highlight(pindex, nil, nil)
   else
      local scan_left_top = {
         math.floor(cursor_pos.x) - cursor_size,
         math.floor(cursor_pos.y) - cursor_size,
      }
      local scan_right_bottom = {
         math.floor(cursor_pos.x) + cursor_size + 1,
         math.floor(cursor_pos.y) + cursor_size + 1,
      }
      Graphics.draw_large_cursor(scan_left_top, scan_right_bottom, pindex)
   end
end

---@param event EventData.CustomInputEvent
local function kb_read_driving_structure_ahead(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local ent = storage.players[pindex].last_driving_alert_ent
   if ent and ent.valid then
      local dir = FaUtils.get_heading_value(p.vehicle)
      local dir_ent = FaUtils.get_direction_biased(ent.position, p.vehicle.position)
      if p.vehicle.speed >= 0 and (dir_ent == dir or math.abs(dir_ent - dir) == 1 or math.abs(dir_ent - dir) == 7) then
         local dist = math.floor(util.distance(p.vehicle.position, ent.position))
         Speech.speak(
            pindex,
            { "fa.driving-structure-ahead", Localising.get_localised_name_with_fallback(ent), tostring(dist) }
         )
      elseif p.vehicle.speed <= 0 and dir_ent == FaUtils.rotate_180(dir) then
         local dist = math.floor(util.distance(p.vehicle.position, ent.position))
         Speech.speak(
            pindex,
            { "fa.driving-structure-behind", Localising.get_localised_name_with_fallback(ent), tostring(dist) }
         )
      end
   end
end

EventManager.on_event(
   "fa-j",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      local p = game.get_player(pindex)

      if router and Viewpoint.get_viewpoint(pindex):get_cursor_enabled() then
         kb_jump_to_player(event)
      elseif p.driving and (p.vehicle.train ~= nil or p.vehicle.type == "car") then
         kb_read_driving_structure_ahead(event)
      end
   end
)

---@param event EventData.CustomInputEvent
local function kb_s_b(event)
   local pindex = event.player_index
   local vp = Viewpoint.get_viewpoint(pindex)
   local pos = vp:get_cursor_pos()
   vp:set_cursor_bookmark(table.deepcopy(pos))
   Speech.speak(pindex, { "fa.cursor-bookmark-saved", tostring(math.floor(pos.x)), tostring(math.floor(pos.y)) })
   sounds.play_close_inventory(pindex)
end

EventManager.on_event(
   "fa-s-b",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_s_b(event)
   end
)

---@param event EventData.CustomInputEvent
local function kb_b(event)
   local pindex = event.player_index
   local vp = Viewpoint.get_viewpoint(pindex)
   local pos = vp:get_cursor_bookmark()
   if pos == nil or pos.x == nil or pos.y == nil then return end
   vp:set_cursor_pos(pos)
   Graphics.draw_cursor_highlight(pindex, nil, nil)
   Graphics.sync_build_cursor_graphics(pindex)
   Speech.speak(pindex, { "fa.cursor-bookmark-loaded", tostring(math.floor(pos.x)), tostring(math.floor(pos.y)) })
   sounds.play_close_inventory(pindex)
end

EventManager.on_event(
   "fa-b",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_b(event)
   end
)

---@param event EventData.CustomInputEvent
local function kb_ca_b(event)
   local pindex = event.player_index
   local vp = Viewpoint.get_viewpoint(pindex)
   local pos = vp:get_cursor_pos()
   Rulers.upsert_ruler(pindex, pos.x, pos.y)
   Speech.speak(pindex, { "fa.ruler-saved-at", tostring(math.floor(pos.x)), tostring(math.floor(pos.y)) })
   sounds.play_close_inventory(pindex)
end

EventManager.on_event(
   "fa-ca-b",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_ca_b(event)
   end
)

EventManager.on_event(
   "fa-as-b",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      Rulers.clear_rulers(pindex)
      Speech.speak(pindex, "Cleared rulers")
   end
)

EventManager.on_event(
   "fa-cas-b",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local p = game.get_player(pindex)
      if p.is_cursor_empty then p.cursor_stack.set_stack("blueprint-book") end
   end
)

EventManager.on_event(
   "fa-a-t",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      type_cursor_position(pindex)
   end
)

EventManager.on_event(
   "fa-s-t",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      Teleport.teleport_to_cursor(pindex, false, false, false)
   end
)

EventManager.on_event(
   "fa-cs-t",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      Teleport.teleport_to_cursor(pindex, false, true, false)
   end
)

---@param event EventData.CustomInputEvent
local function kb_cs_p(event)
   local pindex = event.player_index
   local vp = Viewpoint.get_viewpoint(pindex)
   local alert_pos = storage.players[pindex].last_damage_alert_pos
   if alert_pos == nil then
      Speech.speak(pindex, "No target")
      return
   end
   vp:set_cursor_pos(alert_pos)
   Teleport.teleport_to_cursor(pindex, false, true, true)
   local position = game.get_player(pindex).position
   vp:set_cursor_pos({ x = position.x, y = position.y })
   storage.players[pindex].position = position
   storage.players[pindex].last_damage_alert_pos = position
   Graphics.draw_cursor_highlight(pindex, nil, nil)
   Graphics.sync_build_cursor_graphics(pindex)
   EntitySelection.refresh_player_tile(pindex)
end

EventManager.on_event(
   "fa-cs-p",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_cs_p(event)
   end
)

---Toggles cursor mode on or off. Appropriately affects other modes such as build lock or remote view.
---@param pindex number
---@param muted boolean
local function toggle_cursor_mode(pindex, muted)
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   if p.character == nil then
      vp:set_cursor_enabled(true)
      storage.players[pindex].build_lock = false
      return
   end

   if not vp:get_cursor_enabled() and not vp:get_cursor_hidden() then
      --Enable
      vp:set_cursor_enabled(true)
      storage.players[pindex].build_lock = false

      --Teleport to the center of the nearest tile to align
      center_player_character(pindex)

      --Finally, read the new tile
      if muted ~= true then read_tile(pindex, "Cursor mode enabled, ") end
   else
      force_cursor_off(pindex)

      --Finally, read the new tile
      if muted ~= true then read_tile(pindex, "Cursor mode disabled, ") end
   end
   local cursor_pos = vp:get_cursor_pos()
   local cursor_size = vp:get_cursor_size()
   if cursor_size < 2 then
      --Update cursor highlight
      local ent = EntitySelection.get_first_ent_at_tile(pindex)
      if ent and ent.valid then
         Graphics.draw_cursor_highlight(pindex, ent, nil)
      else
         Graphics.draw_cursor_highlight(pindex, nil, nil)
      end
   else
      local left_top = {
         math.floor(cursor_pos.x) - cursor_size,
         math.floor(cursor_pos.y) - cursor_size,
      }
      local right_bottom = {
         math.floor(cursor_pos.x) + cursor_size + 1,
         math.floor(cursor_pos.y) + cursor_size + 1,
      }
      Graphics.draw_large_cursor(left_top, right_bottom, pindex)
   end
end

EventManager.on_event(
   "fa-i",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      toggle_cursor_mode(pindex, false)
   end
)

---Valid cursor sizes
---@type integer[]
local CURSOR_SIZES = { 0, 1, 2, 5, 10, 25, 50, 125 }

---Adjusts the cursor size for a given player by stepping through predefined cursor size options.
---Direction +1 increases the size to the next larger value, -1 decreases it.
---Redraws the cursor box and announces the new size with TTS and sound feedback.
---@param pindex number Player index
---@param direction number Step direction in CURSOR_SIZES (+1 to increase, -1 to decrease)
local function adjust_cursor_size(pindex, direction)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local current_size = vp:get_cursor_size()
   local index = nil

   for i, size in ipairs(CURSOR_SIZES) do
      if size == current_size then
         index = i
         break
      end
   end

   if index == nil then return end

   local new_index = index + direction
   if new_index < 1 or new_index > #CURSOR_SIZES then return end

   local new_size = CURSOR_SIZES[new_index]
   vp:set_cursor_size(new_size)

   local say_size = new_size * 2 + 1
   Speech.speak(pindex, { "fa.cursor-size", tostring(say_size), tostring(say_size) })

   local scan_left_top = {
      math.floor(cursor_pos.x) - new_size,
      math.floor(cursor_pos.y) - new_size,
   }
   local scan_right_bottom = {
      math.floor(cursor_pos.x) + new_size + 1,
      math.floor(cursor_pos.y) + new_size + 1,
   }

   Graphics.draw_large_cursor(scan_left_top, scan_right_bottom, pindex)
   sounds.play_close_inventory(pindex)
end

--We have cursor sizes 1,3,5,11,21,51,101,251
EventManager.on_event(
   "fa-s-i",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      adjust_cursor_size(pindex, 1)
   end
)

--We have cursor sizes 1,3,5,11,21,51,101,251
EventManager.on_event(
   "fa-c-i",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      adjust_cursor_size(pindex, -1)
   end
)

EventManager.on_event(
   "fa-a-i",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      toggle_remote_view(pindex)
   end
)

EventManager.on_event(
   "fa-pageup",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      local p = game.get_player(pindex)
      local ent = p.opened

      if ent and ent.type == "inserter" then
         -- TODO: Move to capability-based UI
         -- Temporarily inline the functionality
         ent.inserter_stack_size_override = ent.inserter_stack_size_override + 1
         local result = ent.inserter_stack_size_override .. " set for hand stack size"
         Speech.speak(pindex, result)
      else
         ScannerEntrypoint.move_subcategory(pindex, -1)
      end
   end
)

EventManager.on_event(
   "fa-s-pageup",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      ScannerEntrypoint.move_within_subcategory(pindex, -1)
   end
)

EventManager.on_event(
   "fa-c-pageup",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      ScannerEntrypoint.move_category(pindex, -1)
   end
)

EventManager.on_event(
   "fa-pagedown",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      local p = game.get_player(pindex)
      local ent = p.opened

      if ent and ent.type == "inserter" then
         -- TODO: Move to capability-based UI
         -- Temporarily inline the functionality
         local result = ""
         if ent.inserter_stack_size_override > 1 then
            ent.inserter_stack_size_override = ent.inserter_stack_size_override - 1
            result = ent.inserter_stack_size_override .. " set for hand stack size"
         else
            ent.inserter_stack_size_override = 0
            local cap = ent.force.inserter_stack_size_bonus + 1
            if ent.name == "stack-inserter" or ent.name == "stack-filter-inserter" then
               cap = ent.force.stack_inserter_capacity_bonus + 1
            end
            result = "restored " .. cap .. " as default hand stack size "
         end
         Speech.speak(pindex, result)
      else
         ScannerEntrypoint.move_subcategory(pindex, 1)
      end
   end
)

EventManager.on_event(
   "fa-s-pagedown",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      ScannerEntrypoint.move_within_subcategory(pindex, 1)
   end
)

EventManager.on_event(
   "fa-c-pagedown",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      ScannerEntrypoint.move_category(pindex, 1)
   end
)

EventManager.on_event(
   "fa-home",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      ScannerEntrypoint.announce_current_item(pindex)
   end
)

EventManager.on_event(
   "fa-end",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      ScannerEntrypoint.do_refresh(pindex)
   end
)

EventManager.on_event("fa-s-end", function(event)
   local player = game.get_player(event.player_index)
   local char = player.character
   if not char then return end
   ScannerEntrypoint.do_refresh(event.player_index, char.direction)
end)

--For a building, opens circuit menu
---@param event EventData.CustomInputEvent
local function kb_open_circuit_menu(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)

   local p = game.get_player(pindex)
   --In a building menu

   local ent = p.selected or EntitySelection.get_first_ent_at_tile(pindex)
   if ent == nil or ent.valid == false or (ent.get_control_behavior() == nil and ent.type ~= "electric-pole") then
      --Sort scan results instead
      return
   end
   --Building has a circuit network
   p.opened = ent
   if ent.type == "electric-pole" then
      --Open the menu
      CircuitNetworks.circuit_network_menu_open(pindex, ent)
      return
   elseif ent.type == "constant-combinator" then
      CircuitNetworks.circuit_network_menu_open(pindex, ent)
      return
   elseif ent.type == "arithmetic-combinator" or ent.type == "decider-combinator" then
      Speech.speak(pindex, "Error: This combinator is not supported")
      return
   end
   --Building has control behavior
   local control = ent.get_control_behavior()
   if control == nil then
      Speech.speak(pindex, "No control behavior for this building")
      return
   end
   --Building has a circuit network
   local nw1 = control.get_circuit_network(defines.wire_connector_id.circuit_red)
   local nw2 = control.get_circuit_network(defines.wire_connector_id.circuit_green)
   if nw1 == nil and nw2 == nil then
      Speech.speak(
         pindex,
         { "fa.entity-not-connected-circuit-network", Localising.get_localised_name_with_fallback(ent) }
      )
      return
   end
   --Open the menu
   CircuitNetworks.circuit_network_menu_open(pindex, ent)
end

EventManager.on_event(
   "fa-n",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      ---This can probably be refactored
      kb_open_circuit_menu(event)
      ScannerEntrypoint.resort(pindex)
   end
)

--Reprints the last sent string to the Factorio Access Launcher app for the vocalizer to read out.
---@param event EventData.CustomInputEvent
local function kb_repeat_last_spoken(event)
   local pindex = event.player_index
   Speech.speak(pindex, storage.players[pindex].last)
end

-- fa-c-tab is now handled by the UI router for section navigation

--Used when a tile has multiple overlapping entities. Reads out the next entity.
---@param event EventData.CustomInputEvent
local function kb_tile_cycle(event)
   local pindex = event.player_index
   local ent = EntitySelection.get_next_ent_at_tile(pindex)
   if ent and ent.valid then
      Speech.speak(pindex, FaInfo.ent_info(pindex, ent))
      game.get_player(pindex).selected = ent
   else
      Speech.speak(pindex, EntitySelection.get_tile_cache(pindex).tile)
   end
end

--Reads other entities on the same tile? Note: Possibly unneeded
EventManager.on_event(
   "fa-s-f",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      kb_tile_cycle(event)
   end
)

--Opens the main unified menu
---@param event EventData.CustomInputEvent
local function kb_open_player_inventory(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local router = UiRouter.get_router(pindex)

   if p.ticks_to_respawn ~= nil or p.character == nil then return end
   sounds.play_open_inventory(p.index)
   p.selected = nil

   -- Use the router to open the main menu
   local router = UiRouter.get_router(pindex)
   router:open_ui(
      UiRouter.UI_NAMES.MAIN,
      { player_inventory = { entity = p.character, inventory_index = defines.inventory.character_main } }
   )
end

---@param event EventData.CustomInputEvent
local function kb_close_menu(event)
   local pindex = event.player_index
   local tick = event.tick
   local router = UiRouter.get_router(pindex)

   router:close_ui()
   Speech.speak(pindex, "Menu closed.")
end

EventManager.on_event(
   "fa-e",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      local tick = event.tick

      if router:is_ui_open() then
         kb_close_menu(event)
      else
         kb_open_player_inventory(event)
      end
   end
)

---@param event EventData
local function kb_read_menu_name(event)
   ---@cast event EventData.CustomInputEvent
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)

   local msg = Speech.Speech.new()

   msg:fragment("No menu")

   msg:fragment("Unknown menu")

   Speech.speak(pindex, msg:build())
end

EventManager.on_event("fa-s-e", function(event) --read_menu_name
   local pindex = event.player_index
   kb_read_menu_name(event)
end)

---@param event EventData.CustomInputEvent
local function kb_switch_menu_or_gun(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   if storage.players[pindex].started ~= true then
      storage.players[pindex].started = true
      return
   end

   sounds.play_change_menu_tab(pindex)

   --Gun related changes (this seems to run before the actual switch happens so even when we write the new index, it will change, so we need to be predictive)
   local p = game.get_player(pindex)
   if p.character == nil then return end
   if p.vehicle ~= nil then
      --laterdo tank weapon naming ***
      return
   end
   local guns_inv = p.get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   ---@type string|LocalisedString
   local result = ""
   local switched_index = -2

   --switch_success = swap_weapon_backward(pindex,true)
   switched_index = swap_weapon_backward(pindex, true)
   return
end

---@param event EventData.CustomInputEvent
local function kb_reverse_switch_menu_or_gun(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)

   sounds.play_change_menu_tab(pindex)

   --Gun related changes (Vanilla Factorio DOES NOT have shift + tab weapon revserse switching, so we add it without prediction needed)
   local p = game.get_player(pindex)
   if p.character == nil then return end
   if p.vehicle ~= nil then
      --laterdo tank weapon naming ***
      return
   end
   local guns_inv = p.get_inventory(defines.inventory.character_guns)
   local ammo_inv = game.get_player(pindex).get_inventory(defines.inventory.character_ammo)
   ---@type string|LocalisedString
   local result = ""
   local switched_index = -2

   switched_index = swap_weapon_backward(pindex, true)

   --Declare the selected weapon
   local gun_index = switched_index
   local ammo_stack = nil
   local gun_stack = nil

   if gun_index < 1 then
      result = "No ready weapons"
   else
      local ammo_stack = ammo_inv[gun_index]
      local gun_stack = guns_inv[gun_index]
      --game.print("print " .. gun_index)--
      result = {
         "fa.gun-with-ammo",
         Localising.get_localised_name_with_fallback(gun_stack),
         tostring(ammo_stack.count),
         Localising.get_localised_name_with_fallback(ammo_stack),
      }
   end

   sounds.play_menu_move(p.index)
   Speech.speak(pindex, result)
end

EventManager.on_event(
   "fa-tab",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_switch_menu_or_gun(event)
   end
)

EventManager.on_event(
   "fa-s-tab",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_reverse_switch_menu_or_gun(event)
   end
)

---@param event EventData.CustomInputEvent
local function kb_delete(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   local p = game.get_player(pindex)
   local hand = p.cursor_stack

   if hand and hand.valid_for_read then
      local is_planner = hand.is_blueprint
         or hand.is_blueprint_book
         or hand.is_deconstruction_item
         or hand.is_upgrade_item
      if is_planner then
         if FaUtils.confirm_action(pindex, hand.export_stack(), "Press again to delete the planner in hand.") then
            p.cursor_stack_temporary = true
            p.clear_cursor()
         end
      end
   end
end
EventManager.on_event(
   "fa-delete",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_delete(event)
   end
)

---@param event EventData.CustomInputEvent
local function kb_remove_blueprint(event)
   local pindex = event.player_index
   local menu = storage.players[pindex].blueprint_book_menu
   Blueprints.remove_item_from_book(pindex, game.get_player(pindex).cursor_stack, menu.index)
end

---@param event EventData.CustomInputEvent
local function kb_flush_fluid(event)
   local pindex = event.player_index
   local pb = storage.players[pindex].building
   local sector = pb.sectors[pb.sector]
   local box = sector.inventory
   if sector.name ~= "Fluid" or not box or #box == 0 then
      Speech.speak(pindex, "No fluids to flush")
      return
   end

   local fluid = box[pb.index]
   if not (fluid and fluid.name) then
      Speech.speak(pindex, "No fluids to flush")
      return
   end

   if pb.ent and pb.ent.valid and pb.ent.type == "fluid-turret" and pb.index ~= 1 then pb.index = 1 end

   Speech.speak(pindex, { "fa.flushed-away", Localising.get_localised_name_with_fallback(fluid) })
   box.flush(pb.index)
end

---@param event EventData.CustomInputEvent
local function kb_mine_tiles(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   if not (stack and stack.valid_for_read and stack.valid and stack.prototype.place_as_tile_result) then return end

   local vp = Viewpoint.get_viewpoint(pindex)
   local c_pos = vp:get_cursor_pos()
   local c_size = vp:get_cursor_size()
   local left_top = { x = math.floor(c_pos.x - c_size), y = math.floor(c_pos.y - c_size) }
   local right_bottom = { x = math.floor(c_pos.x + 1 + c_size), y = math.floor(c_pos.y + 1 + c_size) }
   local tiles = p.surface.find_tiles_filtered({ area = { left_top, right_bottom } })

   for _, tile in ipairs(tiles) do
      if p.mine_tile(tile) then sounds.play_entity_mined(p.index, "stone-furnace") end
   end
end

---@param event EventData.CustomInputEvent
local function kb_mine_access_sounds(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local ent = p.selected
   if ent and ent.valid and ent.prototype.mineable_properties.products and ent.type ~= "resource" then
      sounds.play_mine(p.index)
   elseif ent and ent.valid and ent.name == "character-corpse" then
      Speech.speak(pindex, "Collecting items ")
   end
end

EventManager.on_event(
   "fa-x",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      -- Removed building menu fluid flush check
      -- TODO: Move to capability-based UI
      if false then
         -- kb_flush_fluid(event) -- disabled
      elseif not storage.players[pindex].vanilla_mode then
         local p = game.get_player(pindex)
         local stack = p.cursor_stack
         if stack and stack.valid_for_read and stack.valid and stack.prototype.place_as_tile_result then
            kb_mine_tiles(event)
         end
         kb_mine_access_sounds(event)
      end
   end
)

--Area mining for obstacles, trees, rocks, etc.
EventManager.on_event(
   "fa-s-x",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      AreaOperations.mine_area(pindex)
   end
)

--Mines groups of entities depending on the name or type. Includes trees and rocks, rails.

EventManager.on_event(
   "fa-cs-x",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      local ent = game.get_player(pindex).selected
      if ent and ent.valid then AreaOperations.super_mine_area(pindex) end
   end
)

--Cut-paste-tool. NOTE: This keybind needs to be the same as that for the cut paste tool (default CONTROL + X). laterdo maybe keybind to game control somehow
EventManager.on_event(
   "fa-c-x",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local stack = game.get_player(pindex).cursor_stack
      if stack and stack.valid_for_read and stack.name == "cut-paste-tool" then
         Speech.speak(pindex, "To disable this tool empty the hand, by pressing SHIFT + Q")
      end
   end
)

--Left click actions in menus (click_menu)
---@param event EventData.CustomInputEvent
local function kb_click_menu(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local p = game.get_player(pindex)

   storage.players[pindex].last_click_tick = event.tick
   --Clear temporary cursor items instead of swapping them in
   if p.cursor_stack_temporary then p.clear_cursor() end
   --Act according to the type of menu open
end
---Left click actions with items in hand
---@param event EventData.CustomInputEvent
local function kb_click_hand(event)
   local pindex = event.player_index
   storage.players[pindex].last_click_tick = event.tick

   local player = game.get_player(pindex)
   local stack = player.cursor_stack

   -- Check if the item in hand can be built
   if stack and stack.valid_for_read then
      local proto = stack.prototype
      if proto.place_result or proto.place_as_tile_result then
         -- Item can be placed/built
         BuildingTools.build_item_in_hand(pindex)
      else
         -- Item cannot be built (e.g., intermediate products, tools, etc.)
         -- Could add a message or different action here if needed
         Speech.speak(pindex, { "fa.cannot-build-item" })
      end
   elseif player.cursor_ghost then
      -- Ghost building
      BuildingTools.build_item_in_hand(pindex)
   end
end

--Left click actions with no menu and no items in hand
---@param event EventData.CustomInputEvent
local function kb_click_entity(event)
   local pindex = event.player_index
   storage.players[pindex].last_ck_tick = event.tick
   local ent = EntitySelection.get_first_ent_at_tile(pindex)
   clicked_on_entity(ent, pindex)
end

EventManager.on_event(
   "fa-leftbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      if storage.players[pindex].last_click_tick == event.tick then return end
      local stack = game.get_player(pindex).cursor_stack
      local ghost = game.get_player(pindex).cursor_ghost

      if ghost or (stack and stack.valid_for_read and stack.valid) then
         kb_click_hand(event)
      elseif storage.players[pindex].vanilla_mode == false then
         kb_click_entity(event)
      end
   end
)

--Right click actions in menus (click_menu)
---@param event EventData.CustomInputEvent
local function kb_click_menu_right(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   storage.players[pindex].last_click_tick = event.tick
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
end

--Reads the entity status but also adds on extra info depending on the entity
---@param event EventData.CustomInputEvent
local function kb_read_entity_status(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)

   local result = FaInfo.read_selected_entity_status(pindex)
   if result ~= nil and result ~= "" then Speech.speak(pindex, result) end
end

--Right click actions with items in hand
---@param event EventData.CustomInputEvent
local function kb_click_hand_right(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   local p = game.get_player(pindex)
   local stack = game.get_player(pindex).cursor_stack

   storage.players[pindex].last_click_tick = event.tick
   --If something is in hand...
   if
      stack.prototype ~= nil
      and (stack.prototype.place_result ~= nil or stack.prototype.place_as_tile_result ~= nil)
      and stack.name ~= "offshore-pump"
   then
      --Laterdo here: build as ghost
      kb_read_entity_status(event)
   elseif stack.is_blueprint then
      Blueprints.blueprint_menu_open(pindex)
      local router = UiRouter.get_router(pindex)
      router:open_ui(UiRouter.UI_NAMES.BLUEPRINT)
   elseif stack.is_blueprint_book then
      Blueprints.blueprint_book_menu_open(pindex, false)
   elseif stack.is_deconstruction_item then
      --Cancel deconstruction
      local pex = storage.players[pindex]
      local vp = Viewpoint.get_viewpoint(pindex)
      if pex.bp_selecting ~= true then
         pex.bp_selecting = true
         pex.bp_select_point_1 = vp:get_cursor_pos()
         Speech.speak(
            pindex,
            "Started deconstruction selection at "
               .. math.floor(pex.bp_select_point_1.x)
               .. ","
               .. math.floor(pex.bp_select_point_1.y)
         )
      else
         pex.bp_selecting = false
         pex.bp_select_point_2 = vp:get_cursor_pos()
         --Cancel area for deconstruction
         local left_top, right_bottom =
            FaUtils.get_top_left_and_bottom_right(pex.bp_select_point_1, pex.bp_select_point_2)
         p.surface.cancel_deconstruct_area({
            area = { left_top, right_bottom },
            force = p.force,
            player = p,
            item = p.cursor_stack,
         })
         Speech.speak(pindex, "Canceled deconstruction in selected area")
      end
   elseif stack.is_upgrade_item then
      local pex = storage.players[pindex]
      local vp = Viewpoint.get_viewpoint(pindex)
      if pex.bp_selecting ~= true then
         pex.bp_selecting = true
         pex.bp_select_point_1 = vp:get_cursor_pos()
         Speech.speak(
            pindex,
            "Started upgrading selection at "
               .. math.floor(pex.bp_select_point_1.x)
               .. ","
               .. math.floor(pex.bp_select_point_1.y)
         )
      else
         pex.bp_selecting = false
         pex.bp_select_point_2 = vp:get_cursor_pos()
         --Cancel area for upgrading
         local left_top, right_bottom =
            FaUtils.get_top_left_and_bottom_right(pex.bp_select_point_1, pex.bp_select_point_2)
         p.surface.cancel_upgrade_area({
            area = { left_top, right_bottom },
            force = p.force,
            player = p,
            item = p.cursor_stack,
         })
         Speech.speak(pindex, "Canceled upgrading in selected area")
      end
   elseif stack.name == "spidertron-remote" then
      --open spidermenu with the remote in hand
      local router = UiRouter.get_router(pindex)
      router:open_ui(UiRouter.UI_NAMES.SPIDERTRON)
   else
      -- Regular item in hand - read entity status as fallback
      kb_read_entity_status(event)
   end
end

EventManager.on_event(
   "fa-rightbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].last_click_tick == event.tick then return end
      local router = UiRouter.get_router(pindex)
      local stack = game.get_player(pindex).cursor_stack

      if stack and stack.valid_for_read and stack.valid then
         kb_click_hand_right(event)
      else
         -- Empty hand case - read entity status

         kb_read_entity_status(event)
      end
   end
)

---Handles menu actions when pressing shift+leftbracket
---Merge of old crafting-all and transfer-one-stack
---@param event EventData.CustomInputEvent
local function kb_menu_action(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
end

--You can equip armor, armor equipment, guns, ammo. You can equip from the hand, or from the inventory with an empty hand.
---@param event EventData.CustomInputEvent
local function kb_equip_item(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)

   local stack = game.get_player(pindex).cursor_stack
   --Equip item grabbed in hand, for selected menus
   local result = Equipment.equip_it(stack, pindex)

   if result ~= "" then
      --game.get_player(pindex).print(result)--**
      Speech.speak(pindex, result)
   end
end

EventManager.on_event(
   "fa-s-leftbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      local p = game.get_player(pindex)
      local stack = p.cursor_stack
      if stack ~= nil and stack.valid_for_read and stack.valid then kb_equip_item(event) end
   end
)

---@param event EventData.CustomInputEvent
local function kb_repair_area(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local stack = p.cursor_stack

   storage.players[pindex].last_click_tick = event.tick
   if stack and stack.valid_for_read and stack.valid and stack.is_repair_tool then
      Combat.repair_area(math.ceil(p.reach_distance), pindex)
   end
end

EventManager.on_event(
   "fa-cs-leftbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].last_click_tick == event.tick then return end

      kb_repair_area(event)
   end
)

--Default is control clicking
---@param event EventData.CustomInputEvent
local function kb_alternate_build(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   local stack = game.get_player(pindex).cursor_stack

   if stack.name == "rail" then
      --Straight rail free placement
      BuildingTools.build_item_in_hand(pindex, true)
   elseif stack.name == "steam-engine" then
      BuildingTools.snap_place_steam_engine_to_a_boiler(pindex)
   end
end

EventManager.on_event(
   "fa-c-leftbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      local stack = game.get_player(pindex).cursor_stack

      if stack ~= nil and stack.valid_for_read and stack.valid then kb_alternate_build(event) end
   end
)

EventManager.on_event(
   "fa-c-rightbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      --[[Imitates vanilla behavior: 
   * Control click an item in an inventory to try smart transfer HALF of it. 
   * Control click an empty slot to try to smart transfer HALF of all items from that inventory.
   ]]
   end
)

--Sets entity filters forlitters, inserters, contant combinators, infinity chests
---@param event EventData.CustomInputEvent
local function kb_set_entity_filter_from_hand(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)

   local stack = game.get_player(pindex).cursor_stack
   local ent = game.get_player(pindex).selected
   if ent == nil or ent.valid == false then return end
   if stack == nil or not stack.valid_for_read or not stack.valid then
      if ent.type == "splitter" then
         --Clear the filter
         local result = TransportBelts.set_splitter_priority(ent, nil, nil, nil, true)
         Speech.speak(pindex, result)
      elseif ent.type == "constant-combinator" then
         --Remove the last signal
         CircuitNetworks.constant_combinator_remove_last_signal(ent, pindex)
      elseif ent.type == "inserter" then
         local result = set_inserter_filter_by_hand(pindex, ent)
         Speech.speak(pindex, result)
      elseif ent.type == "infinity-container" then
         local result = set_infinity_chest_filter_by_hand(pindex, ent)
         Speech.speak(pindex, result)
      elseif ent.type == "infinity-pipe" then
         local result = set_infinity_pipe_filter_by_hand(pindex, ent)
         Speech.speak(pindex, result)
      end
   else
      if ent.type == "splitter" then
         --Set the filter
         local result = TransportBelts.set_splitter_priority(ent, nil, nil, stack)
         Speech.speak(pindex, result)
      elseif ent.type == "constant-combinator" then
         --Add a new signal
         CircuitNetworks.constant_combinator_add_stack_signal(ent, stack, pindex)
      elseif ent.type == "inserter" then
         local result = set_inserter_filter_by_hand(pindex, ent)
         Speech.speak(pindex, result)
      elseif ent.type == "infinity-container" then
         local result = set_infinity_chest_filter_by_hand(pindex, ent)
         Speech.speak(pindex, result)
      elseif ent.type == "infinity-pipe" then
         local result = set_infinity_pipe_filter_by_hand(pindex, ent)
         Speech.speak(pindex, result)
      end
   end
end

--Sets inventory slot filters
EventManager.on_event(
   "fa-a-leftbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      -- Conflicts with setting splitter filters.  Will be fixed by #262

      set_selected_inventory_slot_filter(pindex)
   end
)

EventManager.on_event(
   "fa-ca-rightbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      KruiseKontrol.activate_kk(pindex)
   end
)

--Calls function to notify if items are being picked up via vanilla F key.
---@param event EventData.CustomInputEvent
local function kb_read_item_pickup_state(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)

   local p = game.get_player(pindex)
   local result = ""
   local check_last_pickup = false
   local nearby_belts =
      p.surface.find_entities_filtered({ position = p.position, radius = 1.25, type = "transport-belt" })
   local nearby_ground_items =
      p.surface.find_entities_filtered({ position = p.position, radius = 1.25, name = "item-on-ground" })
   --Draw the pickup range
   rendering.draw_circle({
      color = { 0.3, 1, 0.3 },
      radius = 1.25,
      width = 1,
      target = p.position,
      surface = p.surface,
      time_to_live = 60,
      draw_on_ground = true,
   })
   --Check if there is a belt within n tiles
   if #nearby_belts > 0 then
      result = "Picking up "
      --Check contents being picked up
      local ent = nearby_belts[1]
      if ent == nil or not ent.valid then
         result = result .. " from nearby belts"
         Speech.speak(pindex, result)
         return
      end
      local left = TH.nqc_to_sorted_descending(
         TH.rollup2(ent.get_transport_line(1).get_contents(), F.name().get, F.quality().get, F.count().get)
      )
      local right = TH.nqc_to_sorted_descending(
         TH.rollup2(ent.get_transport_line(2).get_contents(), F.name().get, F.quality().get, F.count().get)
      )
      local all = {}
      TH.concat_arrays(left, right)
      -- Rename it, for clarity.
      local all = left
      table.sort(all, function(a, b)
         return a.count > b.count
      end)

      if all[1] then result = result .. all[1].name end
      if all[2] then result = result .. " " .. string.format("and %s", all[2].name) end
      if all[3] then result = result .. " and others" end

      result = result .. " from nearby belts"
   --Check if there are ground items within n tiles
   elseif #nearby_ground_items > 0 then
      result = "Picking up "
      if nearby_ground_items[1] and nearby_ground_items[1].valid then
         result = result .. nearby_ground_items[1].stack.name
      end
      result = result .. " from ground, and possibly more items "
   else
      result = "No items within range to pick up"
   end
   Speech.speak(pindex, result)
end

--Does not work yet
---@param event EventData.CustomInputEvent
local function kb_flip_blueprint_horizontal_info(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   Speech.speak(pindex, "Error: Flipping horizontal is not supported.")
end

EventManager.on_event(
   "fa-f",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local p = game.get_player(pindex)
      local bp = p.cursor_stack
      if bp and bp.valid_for_read and bp.is_blueprint then
         kb_flip_blueprint_horizontal_info(event)
      else
         kb_read_item_pickup_state(event)
      end
   end
)

---@param event EventData.CustomInputEvent
local function kb_read_health_and_armor_stats(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   local p = game.get_player(pindex)
   local output = { "" }

   --Player health and armor equipment stats
   local result = Equipment.read_armor_stats(pindex, nil)
   table.insert(output, result)
   Speech.speak(pindex, output)
end

--Does not work yet
---@param event EventData.CustomInputEvent
local function kb_flip_blueprint_vertical_info(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local bp = p.cursor_stack
   Speech.speak(pindex, "Error: Flipping vertical is not supported.")
end

EventManager.on_event(
   "fa-g",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      local p = game.get_player(pindex)
      local bp = p.cursor_stack
      if bp ~= nil and bp.valid_for_read and bp.is_blueprint then
         kb_flip_blueprint_vertical_info(event)
      else
         kb_read_health_and_armor_stats(event)
      end
   end
)

EventManager.on_event(
   "fa-r",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      ---From event rotate-building
      BuildingTools.rotate_building_info_read(event, true)
   end
)

EventManager.on_event(
   "fa-s-r",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      BuildingTools.rotate_building_info_read(event, false)
   end
)

---remove all weapons and ammo
EventManager.on_event(
   "fa-cs-r",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
   end
)

--Reads the custom info for an item selected. If you are driving, it returns custom vehicle info
EventManager.on_event(
   "fa-y",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      ItemDescriptions.read_item_info(event)
   end
)

--Reads the custom info for the last indexed scanner item
EventManager.on_event(
   "fa-s-y",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      ItemDescriptions.read_last_indexed_item_info(event)
   end
)

--Read production statistics info for the selected item, in the hand or else selected in the inventory menu
EventManager.on_event(
   "fa-u",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if game.get_player(pindex).driving then return end
      local str = FaInfo.selected_item_production_stats_info(pindex)
      Speech.speak(pindex, str)
   end
)

EventManager.on_event(
   "fa-s-u",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      FaInfo.read_pollution_level_at_position(Viewpoint.get_viewpoint(pindex):get_cursor_pos(), pindex)
   end
)

--Gives in-game time. The night darkness is from 11 to 13, and peak daylight hours are 18 to 6.
--For realism, if we adjust by 12 hours, we get 23 to 1 as midnight and 6 to 18 as peak solar.
---@param event EventData.CustomInputEvent
local function kb_read_time_and_research_progress(event)
   local pindex = event.player_index
   --Get local time
   local surf = game.get_player(pindex).surface
   local hour = math.floor((24 * surf.daytime + 12) % 24)
   local minute = math.floor((24 * surf.daytime - math.floor(24 * surf.daytime)) * 60)
   local time_string = { "fa.local-time", tostring(hour), string.format("%02d", minute) }

   --Get total playtime
   local total_hours = math.floor(game.tick / 216000)
   local total_minutes = math.floor((game.tick % 216000) / 3600)
   local total_time_string = { "fa.mission-time", tostring(total_hours), tostring(total_minutes) }

   --Add research progress info
   local progress_string = Research.get_progress_string(pindex)

   Speech.speak(pindex, FaUtils.spacecat(time_string, progress_string, total_time_string))
   if storage.players[pindex].vanilla_mode then game.get_player(pindex).open_technology_gui() end
end

EventManager.on_event(
   "fa-t",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_read_time_and_research_progress(event)
   end
)

EventManager.on_event(
   "fa-a-q",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      Research.queue_announce(pindex)
   end
)

--Clear the research queue
EventManager.on_event(
   "fa-cas-q",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      Research.clear_queue(pindex)
   end
)

EventManager.on_event(
   "fa-f1",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      game.auto_save("manual")
      Speech.speak(pindex, "Saving Game, please wait 3 seconds.")
   end
)

---@param event EventData.CustomInputEvent
local function kb_honk(event)
   local vehicle = game.get_player(event.player_index).vehicle
   if vehicle.type == "locomotive" or vehicle.train ~= nil then
      sounds.play_sound_at_position({ path = "train-honk-low-long" }, vehicle.position)
   elseif vehicle.name == "tank" then
      sounds.play_sound_at_position({ path = "tank-honk" }, vehicle.position)
   elseif vehicle.type == "car" then
      sounds.play_sound_at_position({ path = "car-honk" }, vehicle.position)
   end
end

EventManager.on_event(
   "fa-a-w",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local p = game.get_player(pindex)
      if p.driving == true and p.vehicle and p.vehicle.valid then kb_honk(event) end
   end
)

---@param event EventData.CustomInputEvent
local function kb_toggle_build_lock(event)
   local pindex = event.player_index
   if storage.players[pindex].build_lock == true then
      storage.players[pindex].build_lock = false
      Speech.speak(pindex, "Build lock disabled.")
   else
      storage.players[pindex].build_lock = true
      Speech.speak(pindex, "Build lock enabled")
   end
end

--Toggle building while walking
EventManager.on_event(
   "fa-c-b",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      kb_toggle_build_lock(event)
   end
)

---@param event EventData.CustomInputEvent
local function kb_toggle_vanilla_mode(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   sounds.play_confirm(p.index)
   if storage.players[pindex].vanilla_mode == false then
      p.print("Vanilla mode : ON")
      vp:set_cursor_enabled(false)
      if p.character then p.character_running_speed_modifier = 0 end
      vp:set_cursor_hidden(true)
      Speech.speak(pindex, "Vanilla mode enabled")
      storage.players[pindex].vanilla_mode = true
   else
      p.print("Vanilla mode : OFF")
      vp:set_cursor_hidden(false)
      storage.players[pindex].vanilla_mode = false
      Speech.speak(pindex, "Vanilla mode disabled")
   end
end

EventManager.on_event(
   "fa-ca-v",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_toggle_vanilla_mode(event)
   end
)

---@param event EventData.CustomInputEvent
local function kb_toggle_cursor_hiding(event)
   local pindex = event.player_index
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_hidden = vp:get_cursor_hidden()
   local p = game.get_player(pindex)
   if cursor_hidden == nil or cursor_hidden == false then
      vp:set_cursor_hidden(true)
      Speech.speak(pindex, { "fa.cursor-hiding-enabled" })
      p.print("Cursor hiding : ON")
   else
      vp:set_cursor_hidden(false)
      Speech.speak(pindex, { "fa.cursor-hiding-disabled" })
      p.print("Cursor hiding : OFF")
   end
end

EventManager.on_event(
   "fa-ca-c",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_toggle_cursor_hiding(event)
   end
)

---nothing else uses this; perhaps merge this into kb_clear_renders
local function clear_renders()
   rendering.clear("FactorioAccess")
   rendering.clear("")
end

---@param event EventData.CustomInputEvent
local function kb_clear_renders(event)
   local pindex = event.player_index
   game.get_player(pindex).gui.screen.clear()
   local vp = Viewpoint.get_viewpoint(pindex)
   vp:set_cursor_ent_highlight_box(nil)
   vp:set_cursor_tile_highlight_box(nil)
   storage.players[pindex].building_footprint = nil
   storage.players[pindex].building_dir_arrow = nil
   storage.players[pindex].overhead_sprite = nil
   storage.players[pindex].overhead_circle = nil
   storage.players[pindex].custom_GUI_frame = nil
   storage.players[pindex].custom_GUI_sprite = nil
   clear_renders()
   Speech.speak(pindex, { "fa.cleared-renders" })
end

EventManager.on_event(
   "fa-ca-r",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_clear_renders(event)
   end
)

---@param event EventData.CustomInputEvent
local function kb_recalibrate_zoom(event)
   local pindex = event.player_index
   Zoom.fix_zoom(pindex)
   Graphics.sync_build_cursor_graphics(pindex)
   Speech.speak(pindex, { "fa.recalibrated" })
end

EventManager.on_event(
   "fa-c-end",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_recalibrate_zoom(event)
   end
)

---@param event EventData.CustomInputEvent
---@param level integer 0 = furthest, 1 = standard, 2 = closest
local function kb_set_zoom_mode(event, level)
   local pindex = event.player_index
   local message
   if level == 0 then
      level = Zoom.MIN_ZOOM
      message = "Set furthest zoom."
   elseif level == 1 then
      ---level is the value we want; leave it
      message = "Set standard zoom."
   elseif level == 2 then
      level = Zoom.MAX_ZOOM
      message = "Set closest zoom."
   end

   Zoom.set_zoom(level, pindex)
   Graphics.sync_build_cursor_graphics(pindex)
   Speech.speak(pindex, message)
end

EventManager.on_event(
   "fa-a-z",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_set_zoom_mode(event, 1)
   end
)

EventManager.on_event(
   "fa-as-z",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_set_zoom_mode(event, 2)
   end
)

EventManager.on_event(
   "fa-ca-z",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_set_zoom_mode(event, 0)
   end
)

EventManager.on_event(
   "fa-mouse-button-3",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      game.get_player(pindex).game_view_settings.update_entity_selection = true
   end
)

local function kb_pipette_tool_info(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local ent = p.selected
   local vp = Viewpoint.get_viewpoint(pindex)
   if ent and ent.valid then
      if ent.supports_direction then
         storage.players[pindex].building_direction = ent.direction
         vp:set_cursor_rotation_offset(0)
      end
      if vp:get_cursor_enabled() then vp:set_cursor_pos(FaUtils.get_ent_northwest_corner_position(ent)) end
      Graphics.sync_build_cursor_graphics(pindex)
      Graphics.draw_cursor_highlight(pindex, ent, nil, nil)
   end
end

EventManager.on_event(
   "fa-q",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_pipette_tool_info(event)
   end
)

EventManager.on_event(
   "fa-s-q",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      read_hand(pindex)
   end
)

---@param event EventData.CustomInputEvent
local function kb_locate_hand_in_inventory(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)

   locate_hand_in_player_inventory(pindex)
end

--Empties hand and opens the item from the player/building inventory
EventManager.on_event(
   "fa-c-q",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_locate_hand_in_inventory(event)
   end
)

--Empties hand and opens the item from the crafting menu
EventManager.on_event(
   "fa-cs-q",
   ---@param event EventData.CustomInputEvent
   function(event, pindex) end
)

EventManager.on_event("fa-grave", function(event)
   Speech.speak(event.player_index, "Opened console")
end)

---@param event EventData.CustomInputEvent
local function kb_open_warnings_menu(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)

   storage.players[pindex].warnings.short = Warnings.scan_for_warnings(30, 30, pindex)
   storage.players[pindex].warnings.medium = Warnings.scan_for_warnings(100, 100, pindex)
   storage.players[pindex].warnings.long = Warnings.scan_for_warnings(500, 500, pindex)
   storage.players[pindex].warnings.index = 1
   storage.players[pindex].warnings.sector = 1
   storage.players[pindex].category = 1
   router:open_ui(UiRouter.UI_NAMES.WARNINGS)
   game.get_player(pindex).selected = nil
   sounds.play_open_inventory(pindex)
   Speech.speak(pindex, { "fa.warnings-menu-short-range", storage.players[pindex].warnings.short.summary })
end

EventManager.on_event(
   "fa-p",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].vanilla_mode then return end
      kb_open_warnings_menu(event)
   end
)

EventManager.on_event(
   "fa-s-p",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      FaInfo.read_nearest_damaged_ent_info(Viewpoint.get_viewpoint(pindex):get_cursor_pos(), pindex)
   end
)

EventManager.on_event(
   "fa-v",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].vanilla_mode then return end
      TravelTools.fast_travel_menu_open(pindex)
   end
)

---@param event EventData.CustomInputEvent
---@param ent LuaEntity
---@param is_input boolean
---@param is_left boolean
local function kb_set_splitter_priority(event, ent, is_input, is_left)
   local pindex = event.player_index

   local result = TransportBelts.set_splitter_priority(ent, is_input, is_left, nil)
   Speech.speak(pindex, result)
end

EventManager.on_event(
   "fa-as-left",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local ent = game.get_player(pindex).selected
      if ent and ent.valid and ent.type == "splitter" then kb_set_splitter_priority(event, ent, true, true) end
   end
)

EventManager.on_event(
   "fa-as-right",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local ent = game.get_player(pindex).selected
      if ent and ent.valid and ent.type == "splitter" then kb_set_splitter_priority(event, ent, true, false) end
   end
)

EventManager.on_event(
   "fa-ca-left",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local ent = game.get_player(pindex).selected
      if ent and ent.valid and ent.type == "splitter" then kb_set_splitter_priority(event, ent, false, true) end
   end
)

EventManager.on_event(
   "fa-ca-right",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local ent = game.get_player(pindex).selected
      if ent and ent.valid and ent.type == "splitter" then kb_set_splitter_priority(event, ent, false, false) end
   end
)

---@param event EventData.CustomInputEvent
local function kb_connect_rail_vehicles(event)
   local pindex = event.player_index
   local vehicle = nil
   local ent = game.get_player(pindex).selected
   if game.get_player(pindex).vehicle ~= nil and game.get_player(pindex).vehicle.train ~= nil then
      vehicle = game.get_player(pindex).vehicle
   elseif ent ~= nil and ent.valid and ent.train ~= nil then
      vehicle = ent
   end

   if vehicle ~= nil then
      --Connect rolling stock (or check if the default key bindings make the connection)
      local connected = 0
      if vehicle.connect_rolling_stock(defines.rail_direction.front) then connected = connected + 1 end
      if vehicle.connect_rolling_stock(defines.rail_direction.back) then connected = connected + 1 end
      if connected > 0 then
         Speech.speak(pindex, { "fa.connected-this-vehicle" })
      else
         connected = 0
         if vehicle.get_connected_rolling_stock(defines.rail_direction.front) ~= nil then connected = connected + 1 end
         if vehicle.get_connected_rolling_stock(defines.rail_direction.back) ~= nil then connected = connected + 1 end
         if connected > 0 then
            Speech.speak(pindex, { "fa.connected-this-vehicle" })
         else
            Speech.speak(pindex, { "fa.nothing-was-connected" })
         end
      end
   end
end

-- Control G is used to connect rolling stock
EventManager.on_event(
   "fa-c-g",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      kb_connect_rail_vehicles(event)
   end
)

---@param event EventData.CustomInputEvent
local function kb_disconnect_rail_vehicles(event)
   local pindex = event.player_index
   local vehicle = nil
   local ent = game.get_player(pindex).selected
   if game.get_player(pindex).vehicle ~= nil and game.get_player(pindex).vehicle.train ~= nil then
      vehicle = game.get_player(pindex).vehicle
   elseif ent ~= nil and ent.train ~= nil then
      vehicle = ent
   end

   if vehicle ~= nil then
      --Disconnect rolling stock
      local disconnected = 0
      if vehicle.disconnect_rolling_stock(defines.rail_direction.front) then disconnected = disconnected + 1 end
      if vehicle.disconnect_rolling_stock(defines.rail_direction.back) then disconnected = disconnected + 1 end
      if disconnected > 0 then
         Speech.speak(pindex, { "fa.disconnected-this-vehicle" })
      else
         local connected = 0
         if vehicle.get_connected_rolling_stock(defines.rail_direction.front) ~= nil then connected = connected + 1 end
         if vehicle.get_connected_rolling_stock(defines.rail_direction.back) ~= nil then connected = connected + 1 end
         if connected > 0 then
            Speech.speak(pindex, { "fa.disconnection-error" })
         else
            Speech.speak(pindex, { "fa.disconnected-this-vehicle" })
         end
      end
   end
end

local function kb_inventory_read_equipment_list(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   local vehicle = nil
end

--SHIFT + G is used to disconnect rolling stock
EventManager.on_event(
   "fa-s-g",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      kb_inventory_read_equipment_list(event)
   end
)

EventManager.on_event(
   "fa-cs-g",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      local vehicle = nil
   end
)

---@param pindex number
local function find_rocket_silo(pindex)
   ---@diagnostic disable: cast-local-type
   ---@diagnostic disable: assign-type-mismatch
   local p = game.get_player(pindex)
   local ent = p.selected
   if p.selected == nil or p.selected.valid == false then ent = p.opened end
   --For rocket entities, return the silo instead
   if ent and (ent.name == "rocket-silo-rocket-shadow" or ent.name == "rocket-silo-rocket") then
      local ents = ent.surface.find_entities_filtered({ position = ent.position, radius = 20, name = "rocket-silo" })
      for i, silo in ipairs(ents) do
         ent = silo
      end
   end
   return ent
end

---@param event EventData.CustomInputEvent
---@param ent LuaEntity
local function kb_launch_rocket(event, ent)
   local pindex = event.player_index
   local try_launch = ent.launch_rocket()
   if try_launch then
      Speech.speak(pindex, { "fa.launch-successful" })
   else
      Speech.speak(pindex, { "fa.not-ready-to-launch" })
   end
end

--Runs before shooting a weapon to check for selected atomic bombs and the target distance
EventManager.on_event(
   "fa-space",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local pindex = event.player_index
      local ent = find_rocket_silo(pindex)
      --Try to launch from the silo
      if ent ~= nil and ent.valid and ent.name == "rocket-silo" then
         ---@diagnostic disable-next-line: param-type-mismatch
         kb_launch_rocket(event, ent)
      else
         Combat.run_atomic_bomb_checks(pindex)
      end
   end
)

---@param event EventData.CustomInputEvent
---@param ent LuaEntity
local function kb_toggle_auto_launch_with_cargo(event, ent)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   ---@diagnostic disable-next-line: inject-field
   ent.auto_launch = not ent.auto_launch
   if ent.auto_launch then
      Speech.speak(pindex, { "fa.enabled-auto-launch" })
   else
      Speech.speak(pindex, { "fa.disabled-auto-launch" })
   end
end

--Toggle whether rockets are launched automatically when they have cargo
EventManager.on_event(
   "fa-c-space",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local ent = find_rocket_silo(pindex)
      --Try to launch from the silo
      ---@diagnostic disable-next-line: param-type-mismatch
      if ent ~= nil and ent.valid and ent.name == "rocket-silo" then kb_toggle_auto_launch_with_cargo(event, ent) end
   end
)

--Help key and tutorial system WIP
EventManager.on_event(
   "fa-h",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      TutorialSystem.read_current_step(pindex)
   end
)

EventManager.on_event(
   "fa-c-h",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      TutorialSystem.next_step(pindex)
   end
)

EventManager.on_event(
   "fa-s-h",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      TutorialSystem.prev_step(pindex)
   end
)

EventManager.on_event(
   "fa-ca-h",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      TutorialSystem.next_chapter(pindex)
   end
)

EventManager.on_event(
   "fa-as-h",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      TutorialSystem.prev_chapter(pindex)
   end
)

EventManager.on_event(
   "fa-cs-h",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      TutorialSystem.toggle_header_detail(pindex)
   end
)

EventManager.on_event(
   "fa-a-h",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      TutorialSystem.read_other_once(pindex)
   end
)

--**Use this key to test stuff (ALT + G)
EventManager.on_event(
   "fa-a-g",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local p = game.get_player(pindex)
      local pex = storage.players[pindex]
      local ent = p.selected
      local stack = game.get_player(pindex).cursor_stack

      if stack.is_blueprint_book then Blueprints.print_book_slots(stack) end
   end
)

EventManager.on_event(
   "fa-l",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local p = game.get_player(pindex)
      if p.character == nil then return end
      if p.driving == false then
         WorkerRobots.logistics_info_key_handler(pindex)
      else
         Driving.pda_read_assistant_toggled_info(pindex)
      end
   end
)

EventManager.on_event(
   "fa-s-l",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if game.get_player(pindex).character == nil then return end
      WorkerRobots.logistics_request_increment_min_handler(pindex)
   end
)

EventManager.on_event(
   "fa-c-l",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if game.get_player(pindex).character == nil then return end
      WorkerRobots.logistics_request_decrement_min_handler(pindex)
   end
)

EventManager.on_event(
   "fa-as-l",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if game.get_player(pindex).character == nil then return end
      WorkerRobots.logistics_request_increment_max_handler(pindex)
   end
)

EventManager.on_event(
   "fa-ca-l",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if game.get_player(pindex).character == nil then return end
      WorkerRobots.logistics_request_decrement_max_handler(pindex)
   end
)

EventManager.on_event(
   "fa-cas-l",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if game.get_player(pindex).character == nil then return end
      WorkerRobots.logistics_request_clear_handler(pindex)
   end
)

-- Reload mod scripts (control stage only)
-- NOTE: This does NOT reload:
-- - Localizations (locale/*.cfg files)
-- - Prototypes (data.lua, data-updates.lua, data-final-fixes.lua)
-- - Graphics/sounds
-- For a full reload including translations, Factorio must be restarted.
EventManager.on_event("fa-cas-r", function(event, pindex)
   Speech.speak(
      pindex,
      "Reloading mod scripts (control.lua). Note: This does not reload localizations or prototypes. For full reload including translations, restart Factorio."
   )
   game.reload_script()
end)

EventManager.on_event("fa-a-l", function(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local c = p.character
   if not c then return end

   local p = c.get_logistic_point(defines.logistic_member_index.character_requester)
   if not p then return end

   if p.enabled then
      Speech.speak(pindex, { "fa.resumed-personal-logistics" })
   else
      Speech.speak(pindex, { "fa.paused-personal-logistics" })
   end
end)

EventManager.on_event(
   "fa-o",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local p = game.get_player(pindex)
      if p.character == nil then return end
      if p.driving == true then Driving.pda_read_cruise_control_toggled_info(event.player_index) end
   end
)

EventManager.on_event("fa-c-o", function(event)
   Speech.speak(
      event.player_index,
      "Type in the new cruise control speed and press 'ENTER' and then 'E' to confirm, or press 'ESC' to exit"
   )
end)

EventManager.on_event(
   "fa-kk-cancel",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      KruiseKontrol.cancel_kk(pindex)
   end
)
