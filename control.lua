require("syntrax")

--Main file for mod runtime
local Logging = require("scripts.logging")
Logging.init()
-- Set logging level
--Logging.set_level("DEBUG")

-- Create logger for control.lua
local logger = Logging.Logger("control")

local util = require("util")

local AreaOperations = require("scripts.area-operations")
local AudioCues = require("scripts.audio-cues")
local Blueprints = require("scripts.blueprints")
local BuildingTools = require("scripts.building-tools")
local BuildDimensions = require("scripts.build-dimensions")
local BuildLock = require("scripts.build-lock")
-- Register build lock backends (tiles must be first to catch tile items before simple backend)
BuildLock.register_backend(require("scripts.build-lock-backends.tiles"))
BuildLock.register_backend(require("scripts.build-lock-backends.transport-belts"))
BuildLock.register_backend(require("scripts.build-lock-backends.electric-poles"))
BuildLock.register_backend(require("scripts.build-lock-backends.simple"))
local BumpDetection = require("scripts.bump-detection")
local CircuitNetworks = require("scripts.circuit-network")
local Combat = require("scripts.combat")
local Consts = require("scripts.consts")
local SettingDecls = require("scripts.settings-decls")
local SETTING_NAMES = SettingDecls.SETTING_NAMES
local Crafting = require("scripts.crafting")
local CursorChanges = require("scripts.cursor-changes")
local Driving = require("scripts.driving")
local HandMonitor = require("scripts.hand-monitor")
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
local InventoryUtils = require("scripts.inventory-utils")
local ItemInfo = require("scripts.item-info")
local KruiseKontrol = require("scripts.kruise-kontrol-wrapper")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local Mouse = require("scripts.mouse")
local MovementHistory = require("scripts.movement-history")
local PlayerInit = require("scripts.player-init")
local PlayerMiningTools = require("scripts.player-mining-tools")
local Quickbar = require("scripts.quickbar")
local Research = require("scripts.research")
require("scripts.rich-text") -- registers rich text processor with speech.lua
local Rulers = require("scripts.rulers")
local ScannerEntrypoint = require("scripts.scanner.entrypoint")
local Spidertron = require("scripts.spidertron")
local SpidertronRemote = require("scripts.spidertron-remote")
local TH = require("scripts.table-helpers")
local Teleport = require("scripts.teleport")
local TestFramework = require("scripts.test-framework")
local TileReader = require("scripts.tile-reader")
local TransportBelts = require("scripts.transport-belts")
local TravelTools = require("scripts.travel-tools")
local VirtualTrainDriving = require("scripts.rails.virtual-train-driving")
local TrainSounds = require("scripts.sonifiers.train")
local InserterSonifier = require("scripts.sonifiers.inserter")
local GridSonifier = require("scripts.sonifiers.grid-sonifier")
local CraftingBackend = require("scripts.sonifiers.grid-backends.crafting")
local EnemyRadar = require("scripts.sonifiers.combat.enemy-radar")
local Zoom = require("scripts.zoom")

-- UI modules (required for registration with router)
require("scripts.ui.belt-analyzer")
local EntityUI = require("scripts.ui.entity-ui")
require("scripts.ui.menus.blueprints-menu")
require("scripts.ui.menus.blueprint-book-menu")
require("scripts.ui.selectors.decon-selector")
require("scripts.ui.selectors.upgrade-selector")
require("scripts.ui.selectors.blueprint-selector")
require("scripts.ui.selectors.copy-paste-selector")
require("scripts.ui.menus.gun-menu")
local MainMenu = require("scripts.ui.menus.main-menu")
require("scripts.ui.menus.fast-travel-menu")
require("scripts.ui.menus.debug-menu")
require("scripts.ui.menus.settings-menu")
require("scripts.ui.menus.rail-builder")
require("scripts.ui.menus.syntrax-program")
local SpidertronRemoteSelector = require("scripts.ui.menus.spidertron-remote-selector")
require("scripts.ui.tabs.item-chooser")
require("scripts.ui.tabs.signal-chooser")
require("scripts.ui.tabs.fluid-chooser")
require("scripts.ui.tabs.equipment-selector")
local Help = require("scripts.ui.help")
local MessageLists = require("scripts.message-lists")
require("scripts.ui.logistics-config")
require("scripts.ui.selectors.logistic-group-selector")
require("scripts.ui.selectors.train-group-selector")
require("scripts.ui.selectors.interrupt-selector")
require("scripts.ui.selectors.stop-selector")
require("scripts.ui.constant-combinator")
require("scripts.ui.decider-combinator")
require("scripts.ui.power-switch")
require("scripts.ui.schedule-editor")
require("scripts.ui.programmable-speaker")
require("scripts.ui.circuit-navigator")
require("scripts.ui.selectors.spidertron-autopilot-selector")
require("scripts.ui.selectors.spidertron-follow-selector")
require("scripts.ui.menus.offshore-pump-placement")
require("scripts.ui.menus.warnings")
require("scripts.ui.generic-inventory")
require("scripts.ui.simple-textbox")
require("scripts.ui.internal.search-setter")
require("scripts.ui.internal.cursor-coordinate-input")
require("scripts.ui.internal.syntrax-input")
require("scripts.ui.help")
local GameGui = require("scripts.ui.game-gui")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")
local Wires = require("scripts.wires")
local Walking = require("scripts.walking")
local Warnings = require("scripts.warnings")
local WorkQueue = require("scripts.work-queue")
local WorkerRobots = require("scripts.worker-robots")
local sounds = require("scripts.ui.sounds")

---@meta scripts.shared-types

-- Register grid sonifier backends
GridSonifier.register_backend_factory("crafting", CraftingBackend.new, CraftingBackend.ENTITY_TYPES)

entity_types = {}
production_types = {}
building_types = {}
local dirs = defines.direction

-- Initialize players as a deny-access table to catch any direct usage
players = TH.deny_access_table()

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
         local vp = Viewpoint.get_viewpoint(pindex)
         local out = { "fa.cursor-description" }
         table.insert(out, cursor_stack.prototype.localised_name)
         local build_entity = cursor_stack.prototype.place_result
         if build_entity and build_entity.supports_direction then
            table.insert(out, 1)
            table.insert(out, { "fa.facing-direction", FaUtils.direction_lookup(vp:get_hand_direction()) })
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
      local vp = Viewpoint.get_viewpoint(pindex)
      local out = { "fa.cursor-description" }
      table.insert(out, cursor_ghost.localised_name)
      local build_entity = cursor_ghost.place_result
      if build_entity and build_entity.supports_direction then
         table.insert(out, 1)
         table.insert(out, { "fa.facing-direction", FaUtils.direction_lookup(vp:get_hand_direction()) })
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

---Local helper: Reads tile info and adds build preview info if player is holding a building
---@param pindex integer Player index
---@param start_text LocalisedString? Optional text to prepend to the result
local function read_tile_with_preview_info(pindex, start_text)
   local message = MessageBuilder.new()
   if start_text then message:fragment(start_text) end

   TileReader.read_tile_inner(pindex, message)

   -- Add build preview info if holding a building and tile is empty/has resources
   local ent = EntitySelection.get_first_ent_at_tile(pindex)
   if not ent or ent.type == "resource" then
      local stack = game.get_player(pindex).cursor_stack
      if stack and stack.valid_for_read and stack.valid and stack.prototype.place_result ~= nil then
         message:fragment(BuildingTools.build_preview_checks_info(stack, pindex))
      end
   end

   Speech.speak(pindex, message:build())
end

--Update the position info and cursor info during smooth walking.
EventManager.on_event(
   defines.events.on_player_changed_position,
   ---@param event EventData.on_player_changed_position
   ---@param pindex integer
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      local p = game.get_player(pindex)
      local old_pos = storage.players[pindex].position
      local new_pos = p.position

      -- Check for teleportation (large position jump)
      if old_pos and util.distance(old_pos, new_pos) > 10 then
         MovementHistory.reset_and_increment_generation(pindex)
      end

      storage.players[pindex].position = p.position
      local pos = p.position
      local vp = Viewpoint.get_viewpoint(pindex)

      --Update cursor graphics
      local stack = p.cursor_stack
      if stack and stack.valid_for_read and stack.valid then Graphics.sync_build_cursor_graphics(pindex) end
   end
)

--Handles a player joining into a game session.
function on_player_join(pindex)
   local playerList = {}
   for _, p in pairs(game.connected_players) do
      playerList["_" .. p.index] = p.name
   end

   --Reset the player building direction to match the vanilla behavior (Factorio 2.0)
   local vp = Viewpoint.get_viewpoint(pindex)
   vp:set_hand_direction(dirs.north)
end

EventManager.on_event(
   defines.events.on_player_joined_game,
   ---@param event EventData.on_player_joined_game
   function(event)
      if game.is_multiplayer() then on_player_join(event.player_index) end
   end
)

--Called for every player on every tick, to manage automatic walking and enforcing mouse pointer position syncs.
--Todo: create a new function for all mouse pointer related updates within this function
local function move_characters(event)
   for pindex, player in pairs(storage.players) do
      local router = UiRouter.get_router(pindex)
      local vp = Viewpoint.get_viewpoint(pindex)
      local cursor_pos = vp:get_cursor_pos()

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

--Called every tick.
function on_tick(event)
   ScannerEntrypoint.on_tick()
   MovementHistory.update_all_players()
   Rulers.update_all_players()
   TrainSounds.on_tick()
   InserterSonifier.on_tick()

   move_characters(event)

   -- Check alerts via AudioCues
   AudioCues.check_cues(event.tick, players)

   -- Check bump detection every tick for all players
   for _, player in pairs(game.players) do
      if player.connected then
         BumpDetection.check_and_play_bump_alert_sound(player.index, event.tick)
         BumpDetection.check_and_play_stuck_alert_sound(player.index, event.tick)
         -- Process build lock for walking movement
         BuildLock.process_walking_movement(player.index)
         -- Process walking announcements (anchored cursor or entity detection)
         Walking.process_walking_announcements(player.index)
         -- Check for pending logistics announcements
         WorkerRobots.on_tick(player.index)
         -- Grid-based sonification (crafting machines etc)
         if settings.get_player_settings(player.index)[SETTING_NAMES.SONIFICATION_CRAFTING].value then
            GridSonifier.tick(player.index)
         end
         -- Enemy radar sonification (combat)
         EnemyRadar.tick(player.index)
      end
   end

   if event.tick % 15 == 0 then
      for pindex, player in pairs(players) do
         -- Other periodic checks can go here
      end
   elseif event.tick % 61 == 0 then
      -- Refresh search cache periodically (coprime with other updates)
      for pindex, player in pairs(players) do
         if player.connected then UiRouter.on_inventory_changed(pindex) end
      end
   elseif event.tick % 90 == 13 then
      for pindex, player in pairs(players) do
         --Fix running speed bug (toggle walk also fixes it)
         fix_walk(pindex)
      end
   elseif event.tick % 450 == 14 then
      --Run regular reminders every 7.5 seconds
      for pindex, player in pairs(players) do
         if game.get_player(pindex).ticks_to_respawn ~= nil then
            Speech.speak(
               pindex,
               { "fa.respawn-countdown", tostring(math.floor(game.get_player(pindex).ticks_to_respawn / 60)) }
            )
         end
         --Report the KK state, if any.
         KruiseKontrol.status_read(pindex, false)
      end
   end
end

EventManager.on_event(
   defines.events.on_tick,
   ---@param event EventData.on_tick
   function(event)
      on_tick(event)
      WorkQueue.on_tick()
      TestFramework.on_tick(event)
      HandMonitor.on_tick()
   end
)

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
EventManager.on_event(
   defines.events.on_player_driving_changed_state,
   ---@param event EventData.on_player_driving_changed_state
   ---@param pindex integer
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      BumpDetection.reset_bump_stats(pindex)
      MovementHistory.reset_and_increment_generation(pindex)
      game.get_player(pindex).clear_cursor()
      if game.get_player(pindex).driving then
         storage.players[pindex].last_vehicle = game.get_player(pindex).vehicle
         Speech.speak(
            pindex,
            { "fa.vehicle-entered", Localising.get_localised_name_with_fallback(game.get_player(pindex).vehicle) }
         )
      elseif storage.players[pindex].last_vehicle ~= nil then
         Speech.speak(
            pindex,
            { "fa.vehicle-exited", Localising.get_localised_name_with_fallback(storage.players[pindex].last_vehicle) }
         )
         Teleport.teleport_to_closest(pindex, storage.players[pindex].last_vehicle.position, true, true)
      else
         Speech.speak(pindex, { "fa.driving-state-changed" })
      end
   end
)

--Called when a player changes surface
EventManager.on_event(
   defines.events.on_player_changed_surface,
   ---@param event EventData.on_player_changed_surface
   ---@param pindex integer
   function(event, pindex)
      MovementHistory.reset_and_increment_generation(pindex)
   end
)

--Save info about last item pickup and draw radius
EventManager.on_event(
   defines.events.on_picked_up_item,
   ---@param event EventData.on_picked_up_item
   ---@param pindex integer
   function(event, pindex)
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
   end
)

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
   if EntityUI.maybe_open_entity(pindex, ent) then
      -- UI opened successfully
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
EventManager.on_event(
   defines.events.on_player_cursor_stack_changed,
   ---@param event EventData.on_player_cursor_stack_changed
   ---@param pindex integer
   function(event, pindex)
      -- Skip if suppressed (e.g., during rail building hand swaps)
      if not HandMonitor.is_enabled(pindex) then return end

      CursorChanges.on_cursor_stack_changed(event, pindex, read_hand)
      VirtualTrainDriving.on_cursor_stack_changed(event)
   end
)

EventManager.on_event(
   defines.events.on_player_mined_item,
   ---@param event EventData.on_player_mined_item
   ---@param pindex integer
   function(event, pindex)
      --Play item pickup sound
      sounds.play_picked_up_item(pindex)
      sounds.play_close_inventory(pindex)
   end
)

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

EventManager.on_event(
   defines.events.on_cutscene_cancelled,
   ---@param event EventData.on_cutscene_cancelled
   ---@param pindex integer
   function(event, pindex) end
)

EventManager.on_event(
   defines.events.on_cutscene_finished,
   ---@param event EventData.on_cutscene_finished
   ---@param pindex integer
   function(event, pindex)
      --Speech.speak(pindex, "Press TAB to continue")
   end
)

EventManager.on_event(
   defines.events.on_cutscene_started,
   ---@param event EventData.on_cutscene_started
   ---@param pindex integer
   function(event, pindex)
      --Speech.speak(pindex, "Press TAB to continue")
   end
)

EventManager.on_event(
   defines.events.on_player_created,
   ---@param event EventData.on_player_created
   function(event)
      PlayerInit.initialize(game.players[event.player_index])
      --if not game.is_multiplayer() then Speech.speak(pindex, "Press 'TAB' to continue") end
   end
)

EventManager.on_event(
   defines.events.on_gui_closed,
   ---@param event EventData.on_gui_closed
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      print(serpent.line(event, { nocode = true }))
      --Other resets - now executed unconditionally
      if event.element ~= nil then event.element.destroy() end
      router:close_ui()
   end
)

function fix_walk(pindex)
   local player = game.get_player(pindex)
   if not player.character then return end
   -- Always use normal walking speed
   player.character_running_speed_modifier = 0 -- 100% + 0 = 100%
   storage.players[pindex].position = player.position
end

EventManager.on_event(
   defines.events.on_gui_opened,
   ---@param event EventData.on_gui_opened
   ---@param pindex integer
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      local p = game.get_player(pindex)

      --Stop any enabled mouse entity selection
      if storage.players[pindex].vanilla_mode ~= true then
         game.get_player(pindex).game_view_settings.update_entity_selection = false
      end
   end
)

EventManager.on_event(
   defines.events.on_object_destroyed,
   ---@param event EventData.on_object_destroyed
   function(event) --DOES NOT HAVE THE KEY PLAYER_INDEX
      ScannerEntrypoint.on_entity_destroyed(event)
   end
)

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

--Alerts a force's players when their structures are destroyed. 300 ticks of cooldown.
EventManager.on_event(
   defines.events.on_entity_damaged,
   ---@param event EventData.on_entity_damaged
   function(event)
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
   end
)

--Alerts a force's players when their structures are destroyed. No cooldown.
EventManager.on_event(
   defines.events.on_entity_died,
   ---@param event EventData.on_entity_died
   function(event)
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
   end
)

--Notify all players when a player character dies
EventManager.on_event(
   defines.events.on_player_died,
   ---@param event EventData.on_player_died
   ---@param pindex integer
   function(event, pindex)
      local p = game.get_player(pindex)
      local causer = event.cause
      local bodies = p.surface.find_entities_filtered({ name = "character-corpse" })
      local latest_body = nil
      local latest_death_tick = 0
      local name = p.name
      if name == nil then name = " " end
      --Find the most recent character corpse
      for i, body in ipairs(bodies) do
         if
            body.character_corpse_player_index == pindex and body.character_corpse_tick_of_death > latest_death_tick
         then
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
   end
)

EventManager.on_event(
   defines.events.on_player_display_resolution_changed,
   ---@param event EventData.on_player_display_resolution_changed
   ---@param pindex integer
   function(event, pindex)
      local new_res = game.get_player(pindex).display_resolution
      if players and storage.players[pindex] then storage.players[pindex].display_resolution = new_res end
      game
         .get_player(pindex)
         .print("Display resolution changed: " .. new_res.width .. " x " .. new_res.height, { volume_modifier = 0 })
      Zoom.clear_cache(pindex)
   end
)

EventManager.on_event(
   defines.events.on_player_display_scale_changed,
   ---@param event EventData.on_player_display_scale_changed
   ---@param pindex integer
   function(event, pindex)
      local new_sc = game.get_player(pindex).display_scale
      if players and storage.players[pindex] then storage.players[pindex].display_resolution = new_sc end
      game.get_player(pindex).print("Display scale changed: " .. new_sc, { volume_modifier = 0 })
      Zoom.clear_cache(pindex)
   end
)

EventManager.on_event(
   defines.events.on_player_display_density_scale_changed,
   ---@param event EventData.on_player_display_density_scale_changed
   ---@param pindex integer
   function(event, pindex)
      Zoom.clear_cache(pindex)
   end
)

EventManager.on_event(defines.events.on_string_translated, Localising.handler)

EventManager.on_event(
   defines.events.on_player_respawned,
   ---@param event EventData.on_player_respawned
   ---@param pindex integer
   function(event, pindex)
      local vp = Viewpoint.get_viewpoint(pindex)
      local position = game.get_player(pindex).position
      storage.players[pindex].position = position
      vp:set_cursor_pos({ x = position.x, y = position.y })
      MovementHistory.reset_and_increment_generation(pindex)
   end
)

EventManager.on_event(
   defines.events.on_player_main_inventory_changed,
   ---@param event EventData.on_player_main_inventory_changed
   ---@param pindex integer
   function(event, pindex)
      -- Refresh search cache if UI is open and search is active
      UiRouter.on_inventory_changed(pindex)
   end
)

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

EventManager.on_event(
   defines.events.on_console_chat,
   ---@param event EventData.on_console_chat
   function(event)
      local speaker = game.get_player(event.player_index).name
      if speaker == nil or speaker == "" then speaker = "Player" end
      local message = event.message
      for pindex, player in pairs(players) do
         Speech.speak(pindex, { "fa.chat-message", speaker, message })
      end
   end
)

EventManager.on_event(
   defines.events.on_console_command,
   ---@param event EventData.on_console_command
   function(event)
      -- For our own commands, we handle the speaking and must not read here.
      if FaCommands.COMMANDS[event.command] then return end

      local speaker = game.get_player(event.player_index).name
      if speaker == nil or speaker == "" then speaker = "Player" end
      for pindex, player in pairs(players) do
         Speech.speak(pindex, { "fa.command-message", speaker, event.command, event.parameters })
      end
   end
)

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

EventManager.on_event(
   defines.events.on_surface_created,
   ---@param event EventData.on_surface_created
   function(event)
      ScannerEntrypoint.on_new_surface(game.get_surface(event.surface_index))
   end
)

EventManager.on_event(
   defines.events.on_surface_deleted,
   ---@param event EventData.on_surface_deleted
   function(event)
      ScannerEntrypoint.on_surface_delete(event.surface_index)
   end
)

EventManager.on_event(defines.events.on_research_finished, Research.on_research_finished)
-- New input event definitions

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
            Speech.speak(pindex, { "fa.teleport-failed" })
            moved_success = false
         else
            moved_success = true
         end
         storage.players[pindex].position = new_pos
         if nudged ~= true then
            vp:set_cursor_pos(FaUtils.offset_position_legacy(storage.players[pindex].position, direction, 1))
            read_tile_with_preview_info(pindex)
         end

         local stack = first_player.cursor_stack
         if stack and stack.valid_for_read and stack.valid and stack.prototype.place_result ~= nil then
            Graphics.sync_build_cursor_graphics(pindex)
         end
      else
         Speech.speak(pindex, { "fa.tile-occupied" })
         moved_success = false
      end
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
      EntitySelection.reset_entity_index(pindex)
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
         read_tile_with_preview_info(pindex)
      end

      --Rotate belts in hand for build lock Mode
      local stack = game.get_player(pindex).cursor_stack
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
---Move a large cursor by n tiles and read the area
---@param pindex number
---@param direction defines.direction
---@param tiles number Number of tiles to move
---@param prefix_text string? Optional text to prepend to the reading
local function move_large_cursor_by(pindex, direction, tiles, prefix_text)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local cursor_size = vp:get_cursor_size()
   local p = game.get_player(pindex)

   cursor_pos = FaUtils.offset_position_legacy(cursor_pos, direction, tiles)
   vp:set_cursor_pos(cursor_pos)

   local scan_left_top = {
      x = math.floor(cursor_pos.x) - cursor_size,
      y = math.floor(cursor_pos.y) - cursor_size,
   }
   local scan_right_bottom = {
      x = math.floor(cursor_pos.x) + cursor_size + 1,
      y = math.floor(cursor_pos.y) + cursor_size + 1,
   }
   local scan_summary = FaInfo.area_scan_summary_info(pindex, scan_left_top, scan_right_bottom)
   if prefix_text and prefix_text ~= "" then scan_summary = prefix_text .. scan_summary end
   Graphics.draw_large_cursor(scan_left_top, scan_right_bottom, pindex)
   Speech.speak(pindex, scan_summary)

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

local function cursor_mode_move(direction, pindex, single_only)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local cursor_size = vp:get_cursor_size()
   local diff = cursor_size * 2 + 1
   if single_only then diff = 1 end
   local p = game.get_player(pindex)

   if cursor_size == 0 then
      -- Cursor size 0 ("1 by 1"): Read tile
      cursor_pos = FaUtils.offset_position_legacy(cursor_pos, direction, diff)
      vp:set_cursor_pos_continuous(cursor_pos, direction)

      EntitySelection.reset_entity_index(pindex)
      read_tile_with_preview_info(pindex)

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

      --Update cursor highlight
      local ent = EntitySelection.get_first_ent_at_tile(pindex)
      if ent and ent.valid then
         Graphics.draw_cursor_highlight(pindex, ent, nil)
      else
         Graphics.draw_cursor_highlight(pindex, nil, nil)
      end

      if storage.players[pindex].remote_view then
         sounds.play_building_placement(p.index, cursor_pos)
      else
         p.play_sound({
            path = "Close-Inventory-Sound",
            position = storage.players[pindex].position,
            volume_modifier = 0.75,
         })
      end
   else
      -- Use continuous movement tracking for WASD movements
      vp:set_cursor_pos_continuous(cursor_pos, direction)
      move_large_cursor_by(pindex, direction, diff)
   end

   --Update player direction to face the cursor
   turn_to_cursor_direction_precise(pindex)
end

--Chooses the function to call after a movement keypress, according to the current mode.
local function move_key(direction, event, force_single_tile)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local router = UiRouter.get_router(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)

   --Stop any enabled mouse entity selection
   if storage.players[pindex].vanilla_mode ~= true then
      game.get_player(pindex).game_view_settings.update_entity_selection = false
   end

   -- Cursor mode: Move cursor on map
   cursor_mode_move(direction, pindex, force_single_tile)
end

EventManager.on_event(
   "fa-w",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      move_key(defines.direction.north, event)
   end
)

EventManager.on_event(
   "fa-a",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      move_key(defines.direction.west, event)
   end
)

EventManager.on_event(
   "fa-s",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      move_key(defines.direction.south, event)
   end
)

EventManager.on_event(
   "fa-d",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      move_key(defines.direction.east, event)
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
      EntitySelection.reset_entity_index(pindex)
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
               EntitySelection.reset_entity_index(pindex)
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
            EntitySelection.reset_entity_index(pindex)
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
               return moved
               --Also for rulers, stop if at the definiton point of any ruler
            elseif Rulers.is_at_any_ruler_definition(pindex, cursor_pos) then
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
         return moved
         --Also for rulers, stop if at the definiton point of any ruler
      elseif Rulers.is_at_any_ruler_definition(pindex, cursor_pos) then
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
   local width, height = BuildDimensions.get_stack_build_dimensions(stack, vp:get_hand_direction())

   --Default to cursor size if not something else
   if not width or not height or (width + height <= 2) then
      local shift = (vp:get_cursor_size() * 2 + 1)
      vp:set_cursor_pos(FaUtils.offset_position_legacy(cursor_pos, direction, shift))
      return shift
   end

   --For entities/blueprints larger than 1x1, move by the appropriate dimension
   local shift
   if direction == dirs.east or direction == dirs.west then
      shift = width
   elseif direction == dirs.north or direction == dirs.south then
      shift = height
   end

   vp:set_cursor_pos(FaUtils.offset_position_legacy(cursor_pos, direction, shift))
   return shift
end

--Runs the cursor skip actions and reads out results
local function cursor_skip(pindex, direction, iteration_limit, use_preview_size)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_size = vp:get_cursor_size()
   local p = game.get_player(pindex)
   local limit = iteration_limit or 100

   --Special case: larger cursors move by 1 tile with ctrl+WASD
   if use_preview_size and cursor_size > 0 then
      move_large_cursor_by(pindex, direction, 1)
      return
   end

   local cursor_pos = vp:get_cursor_pos()
   local result = ""
   local moved_count = 0
   if use_preview_size == true then
      moved_count = apply_skip_by_preview_size(pindex, direction)
      result = "Skipped by preview size " .. moved_count .. ", "
   else
      moved_count = cursor_skip_iteration(pindex, direction, limit)
      result = "Skipped "
   end

   cursor_pos = vp:get_cursor_pos()

   if use_preview_size then
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
   read_tile_with_preview_info(pindex, result)
   Graphics.sync_build_cursor_graphics(pindex)
end

EventManager.on_event(
   "fa-s-w",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      cursor_skip(pindex, defines.direction.north)
   end
)

EventManager.on_event(
   "fa-s-a",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      cursor_skip(pindex, defines.direction.west)
   end
)

EventManager.on_event(
   "fa-s-s",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      cursor_skip(pindex, defines.direction.south)
   end
)

EventManager.on_event(
   "fa-s-d",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      cursor_skip(pindex, defines.direction.east)
   end
)

EventManager.on_event(
   "fa-c-w",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      cursor_skip(pindex, defines.direction.north, 1000, true)
   end
)

EventManager.on_event(
   "fa-c-a",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      cursor_skip(pindex, defines.direction.west, 1000, true)
   end
)

EventManager.on_event(
   "fa-c-s",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      cursor_skip(pindex, defines.direction.south, 1000, true)
   end
)

EventManager.on_event(
   "fa-c-d",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      cursor_skip(pindex, defines.direction.east, 1000, true)
   end
)

EventManager.on_event(
   "fa-s-up",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      BuildingTools.nudge_key(defines.direction.north, event)
   end
)

EventManager.on_event(
   "fa-s-left",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      BuildingTools.nudge_key(defines.direction.west, event)
   end
)

EventManager.on_event(
   "fa-s-down",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      BuildingTools.nudge_key(defines.direction.south, event)
   end
)

EventManager.on_event(
   "fa-s-right",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
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
      Speech.speak(pindex, { "fa.nudge-failed" })
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

   local position = vp:get_cursor_pos()
   local marked_pos = { x = position.x, y = position.y }

   if game.get_player(pindex).driving then
      --Give vehicle coords and orientation and speed --laterdo find exact speed coefficient
      local vehicle = game.get_player(pindex).vehicle
      assert(vehicle ~= nil) -- When driving is true, vehicle is guaranteed to exist
      local speed = vehicle.speed * 215
      local message = MessageBuilder.new()

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
      local message = MessageBuilder.new()

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
      local p_width, p_height = BuildDimensions.get_stack_build_dimensions(stack, vp:get_hand_direction())

      -- Tiles are always 1x1, so tile case still triggers.
      if p_width and p_height and (p_width > 1 or p_height > 1) then
         local vp = Viewpoint.get_viewpoint(pindex)
         local dir = vp:get_hand_direction()
         turn_to_cursor_direction_cardinal(pindex)
         local p_dir = storage.players[pindex].player_direction

         message:fragment({ "fa.build-preview-dimensions", tostring(p_width), tostring(p_height) })
      elseif stack and stack.valid_for_read and stack.valid and stack.prototype.place_as_tile_result ~= nil then
         --Paving preview size
         local size = vp:get_cursor_size() * 2 + 1
         if storage.players[pindex].preferences.tiles_placed_from_northwest_corner then
            message:fragment({ "fa.paving-preview-northwest", tostring(size), tostring(size) })
         else
            message:fragment({ "fa.paving-preview-centered", tostring(size), tostring(size) })
         end
      end
      Speech.speak(pindex, message:build())
   end
end

--Read coordinates of the cursor. Extra info as well such as entity part if an entity is selected, and heading and speed info for vehicles.
EventManager.on_event(
   "fa-k",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      -- Check for virtual train driving (status command doesn't need TileReader.read_tile)
      if VirtualTrainDriving.on_kb_descriptive_action_name(event) then return end

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
   local cursor_location_description = { "fa.at" }
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

      if p.driving and p.vehicle.type == "car" then
         kb_read_driving_structure_ahead(event)
      else
         kb_jump_to_player(event)
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
      -- Check for virtual train driving (create bookmark)
      if VirtualTrainDriving.on_kb_descriptive_action_name(event) then return end

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
      -- Check for virtual train driving
      if VirtualTrainDriving.is_locked(pindex) then
         local success = VirtualTrainDriving.return_to_bookmark(pindex)
         if success then TileReader.read_tile(pindex) end
         return
      end

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
      Speech.speak(pindex, { "fa.rulers-cleared" })
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
   "fa-ca-t",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      UiRouter.get_router(pindex):open_ui(UiRouter.UI_NAMES.CURSOR_COORDINATE_INPUT)
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
      Speech.speak(pindex, { "fa.no-target" })
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
   EntitySelection.reset_entity_index(pindex)
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
      vp:set_cursor_anchored(false)
      Speech.speak(pindex, { "fa.cannot-anchor-no-character" })
      return
   end

   if not vp:get_cursor_anchored() then
      --Enable
      vp:set_cursor_anchored(true)

      --Finally, read the new tile
      Speech.speak(pindex, { "fa.anchored-cursor" })
   else
      --Finally, read the new tile
      vp:set_cursor_anchored(false)
      -- For the unanchored case it's worth reading the tile the cursor ended up on.
      if muted ~= true then read_tile_with_preview_info(pindex, { "fa.unanchored-cursor" }) end
   end
end

EventManager.on_event(
   "fa-i",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      toggle_cursor_mode(pindex, false)
   end
)

-- Handle escape key: close textbox if open (sending nil to parent), otherwise give pause hint
EventManager.on_event(
   "fa-escape",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if GameGui.is_textbox_open(pindex) then
         local router = UiRouter.get_router(pindex)
         local top_ui_name = router:get_open_ui_name()

         -- Send nil result to parent UI to signal cancellation
         if top_ui_name then
            local registered_uis = UiRouter.get_registered_uis()
            local ui = registered_uis[top_ui_name]
            if ui and ui.on_child_result then
               local context = GameGui.get_textbox_context(pindex)
               -- Use close_with_result to properly notify parent and clean up
               GameGui.close_textbox(pindex)
               router:close_with_result(nil)
               return
            end
         end

         -- Fallback: just close textbox and pop UI
         GameGui.close_textbox(pindex)
         router:close_ui()
      else
         Speech.speak(pindex, { "fa.escape-to-pause" })
      end
   end
)

---Valid cursor sizes
---@type integer[]
local CURSOR_SIZES = { 0, 1, 2, 5, 10, 25, 50, 125 }

---Adjusts the cursor size for a given player by stepping through predefined cursor size options.
---Direction +1 increases the size to the next larger value, -1 decreases it.
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
      -- For remote view toggle, but remote view is currently not working in Factorio 2.0.
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

EventManager.on_event("fa-s-slash", function(event)
   local pindex = event.player_index
   local player = game.get_player(pindex)

   local help_items = {}

   -- Add hand status message
   local cursor_stack = player.cursor_stack
   if cursor_stack and cursor_stack.valid_for_read then
      local item_name = Localising.get_localised_name_with_fallback(cursor_stack.prototype)
      local msg = MessageBuilder.new():fragment({ "fa.hand-contains", item_name }):build()
      table.insert(help_items, Help.message(msg))
   else
      table.insert(help_items, Help.message({ "fa.hand-empty" }))
   end

   -- If hand has item, check for prototype-specific help
   if cursor_stack and cursor_stack.valid_for_read then
      local prototype_type = cursor_stack.prototype.type
      local help_list_name = prototype_type .. "-protohelp"
      if MessageLists.has_list(help_list_name) then table.insert(help_items, Help.message_list(help_list_name)) end
   end

   -- Add map help
   table.insert(help_items, Help.message_list("map-help"))

   -- Open help UI
   local router = UiRouter.get_router(pindex)
   local help_params = Help.create_parameters(help_items)
   router:open_ui(UiRouter.UI_NAMES.HELP, help_params)
end)

-- Circuit/copper network neighbors (N key)
EventManager.on_event(
   "fa-n",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local player = game.get_player(pindex)
      local ent = player.selected

      if ent and ent.valid then
         -- Check for combinators (multi-connection circuit entities)
         if
            ent.type == "arithmetic-combinator"
            or ent.type == "decider-combinator"
            or ent.type == "selector-combinator"
         then
            local msg = CircuitNetworks.get_combinator_neighbors_info(ent, pindex)
            Speech.speak(pindex, msg)
            return
         end

         -- Check for power switch (multi-connection entity with both copper and circuit)
         if ent.type == "power-switch" then
            local msg = CircuitNetworks.get_power_switch_neighbors_info(ent, pindex)
            Speech.speak(pindex, msg)
            return
         end

         -- Check for electric pole (copper wires)
         if ent.type == "electric-pole" then
            local msg = CircuitNetworks.get_copper_wire_neighbors_info(ent, pindex)
            Speech.speak(pindex, msg)
            return
         end

         -- Check if entity has circuit network capability
         local cb = ent.get_control_behavior()
         if cb then
            local msg = CircuitNetworks.get_circuit_neighbors_info(ent, pindex)
            Speech.speak(pindex, msg)
            return
         end
      end

      Speech.speak(pindex, { "", "Not in a network" })
   end
)

-- Remove wires (Alt+N key)
EventManager.on_event(
   "fa-a-n",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      CircuitNetworks.remove_wires(pindex)
   end
)

-- Circuit network navigator (Ctrl+Alt+N key)
EventManager.on_event(
   "fa-c-n",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local player = game.get_player(pindex)
      local ent = player.selected

      -- Check if entity has circuit network capability
      if ent and ent.valid then
         local cb = ent.get_control_behavior()
         if cb then
            UiRouter.get_router(pindex):open_ui(UiRouter.UI_NAMES.CIRCUIT_NAVIGATOR, { entity = ent })
            return
         end
      end

      Speech.speak(pindex, { "", "No circuit network capable entity selected" })
   end
)

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
      local tile_name = EntitySelection.get_player_tile(pindex)
      Speech.speak(pindex, tile_name)
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

   -- Open the main menu
   MainMenu.open_main_menu(pindex)
end

EventManager.on_event(
   "fa-e",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      -- Always open inventory - closing is handled by the UI event system
      kb_open_player_inventory(event)
   end
)

-- Now handled by router.lua
---@param event EventData
local function kb_read_menu_name(event)
   ---@cast event EventData.CustomInputEvent
   local pindex = event.player_index

   Speech.speak(pindex, { "fa.not-in-menu" })
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
      Speech.speak(pindex, { "fa.collecting-items" })
   end
end

EventManager.on_event(
   "fa-x",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      if not storage.players[pindex].vanilla_mode then
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

--Mines groups of entities depending on the name or type. Includes trees and rocks.

EventManager.on_event(
   "fa-cs-x",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      local ent = game.get_player(pindex).selected
      if ent and ent.valid then AreaOperations.super_mine_area(pindex) end
   end
)

---Left click actions with items in hand
---@param event EventData.CustomInputEvent
local function kb_click_hand(event)
   local pindex = event.player_index
   storage.players[pindex].last_click_tick = event.tick

   local player = game.get_player(pindex)
   local stack = player.cursor_stack

   -- Check if the item in hand can be built
   if stack and stack.valid_for_read then
      if (stack.is_blueprint and stack.is_blueprint_setup()) or stack.is_blueprint_book then
         -- Blueprint or blueprint book building
         local vp = Viewpoint.get_viewpoint(pindex)
         BuildingTools.build_blueprint(pindex, vp:get_flipped_horizontal(), vp:get_flipped_vertical())
      elseif stack.name == "red-wire" or stack.name == "green-wire" or stack.name == "copper-wire" then
         -- Wire dragging - red/green circuit wires or copper electrical wire
         CircuitNetworks.drag_wire_and_read(pindex)
      else
         local proto = stack.prototype
         local capsule_action = proto.capsule_action
         if capsule_action then
            -- Handle capsules and grenades
            if capsule_action.type == "use-on-self" then
               -- Use capsule on the player
               player.use_from_cursor(player.position)
            elseif capsule_action.type == "throw" then
               -- Use smart aiming for throwable capsules
               local target_pos = Combat.smart_aim_grenades_and_capsules(pindex, false)
               if target_pos then player.use_from_cursor(target_pos) end
            else
               -- For other capsule types (artillery-remote, destroy-cliffs, etc.), use at cursor
               local vp = Viewpoint.get_viewpoint(pindex)
               player.use_from_cursor(vp:get_cursor_pos())
            end
         elseif proto.place_result or proto.place_as_tile_result then
            -- Item can be placed/built
            local vp = Viewpoint.get_viewpoint(pindex)
            local success = BuildingTools.build_item_in_hand_with_params({
               pindex = pindex,
               building_direction = vp:get_hand_direction(),
               flip_horizontal = vp:get_flipped_horizontal(),
               flip_vertical = vp:get_flipped_vertical(),
            })
            if success then TileReader.read_tile(pindex) end
         else
            -- Item cannot be built (e.g., intermediate products, tools, etc.)
            -- Could add a message or different action here if needed
            Speech.speak(pindex, { "fa.cannot-build-item" })
         end
      end
   elseif player.cursor_ghost then
      -- Ghost building
      local vp = Viewpoint.get_viewpoint(pindex)
      local success = BuildingTools.build_item_in_hand_with_params({
         pindex = pindex,
         building_direction = vp:get_hand_direction(),
         flip_horizontal = vp:get_flipped_horizontal(),
         flip_vertical = vp:get_flipped_vertical(),
      })
      if success then TileReader.read_tile(pindex) end
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
      local p = game.get_player(pindex)
      local stack = p.cursor_stack
      local ghost = p.cursor_ghost

      -- Handle planners specially
      if stack and stack.valid_for_read then
         if stack.is_deconstruction_item then
            -- Start selection for deconstruction (action determined by alt modifier on second click)
            local vp = Viewpoint.get_viewpoint(pindex)
            local cursor_pos = vp:get_cursor_pos()
            router:open_ui(UiRouter.UI_NAMES.DECON_AREA_SELECTOR, {
               first_point = { x = cursor_pos.x, y = cursor_pos.y },
               intro_message = {
                  "fa.planner-deconstruct-first-point",
                  math.floor(cursor_pos.x),
                  math.floor(cursor_pos.y),
               },
               second_message = { "fa.planner-select-second-point" },
            })
            return
         elseif stack.is_upgrade_item then
            -- Start selection for upgrade (action determined by alt modifier on second click)
            local vp = Viewpoint.get_viewpoint(pindex)
            local cursor_pos = vp:get_cursor_pos()
            router:open_ui(UiRouter.UI_NAMES.UPGRADE_AREA_SELECTOR, {
               first_point = { x = cursor_pos.x, y = cursor_pos.y },
               intro_message = { "fa.planner-upgrade-first-point", math.floor(cursor_pos.x), math.floor(cursor_pos.y) },
               second_message = { "fa.planner-select-second-point" },
            })
            return
         elseif stack.is_blueprint then
            -- Only start selection for empty blueprints
            if not stack.is_blueprint_setup() then
               -- Start selection for empty blueprint
               local vp = Viewpoint.get_viewpoint(pindex)
               local cursor_pos = vp:get_cursor_pos()
               router:open_ui(UiRouter.UI_NAMES.BLUEPRINT_AREA_SELECTOR, {
                  first_point = { x = cursor_pos.x, y = cursor_pos.y },
                  intro_message = {
                     "fa.planner-blueprint-first-point",
                     math.floor(cursor_pos.x),
                     math.floor(cursor_pos.y),
                  },
                  second_message = { "fa.planner-blueprint-second-point" },
                  permanent = true,
               })
               return
            end
            -- Blueprint is set up - fall through to normal click behavior
         elseif stack.is_blueprint_book then
            -- Check if book has an active blueprint that is set up
            local book_inv = stack.get_inventory(defines.inventory.item_main)
            if book_inv and stack.active_index then
               local active_bp = book_inv[stack.active_index]
               if
                  active_bp
                  and active_bp.valid_for_read
                  and active_bp.is_blueprint
                  and active_bp.is_blueprint_setup()
               then
                  -- Active blueprint is set up - fall through to normal click behavior to place it
               else
                  -- Active blueprint not set up or invalid
                  Speech.speak(pindex, { "fa.blueprint-book-no-active-blueprint" })
                  return
               end
            else
               -- No active blueprint or empty book
               Speech.speak(pindex, { "fa.blueprint-book-no-active-blueprint" })
               return
            end
         elseif stack.name == "copy-paste-tool" or stack.name == "cut-paste-tool" then
            -- Start selection for copy/cut
            local vp = Viewpoint.get_viewpoint(pindex)
            local cursor_pos = vp:get_cursor_pos()
            local is_cut = stack.name == "cut-paste-tool"
            router:open_ui(UiRouter.UI_NAMES.COPY_PASTE_AREA_SELECTOR, {
               first_point = { x = cursor_pos.x, y = cursor_pos.y },
               intro_message = {
                  is_cut and "fa.planner-cut-first-point" or "fa.planner-copy-first-point",
                  math.floor(cursor_pos.x),
                  math.floor(cursor_pos.y),
               },
               second_message = false,
            })
            return
         elseif stack.prototype.type == "spidertron-remote" then
            -- Add autopilot point for spidertron remote (enqueue, don't clear)
            local vp = Viewpoint.get_viewpoint(pindex)
            local cursor_pos = vp:get_cursor_pos()
            SpidertronRemote.add_to_autopilot(p, cursor_pos, false)
            return
         elseif stack.prototype.rails then
            -- Rail planner: check if there's a rail at cursor to lock onto
            local ent = EntitySelection.get_first_ent_at_tile(pindex)
            if ent and ent.valid and Consts.RAIL_TYPES_SET[ent.type] then
               VirtualTrainDriving.lock_on_to_rail(pindex, ent)
               return
            end
            -- No rail at cursor, fall through to normal click behavior
         end
      end

      -- Normal left-click behavior
      if ghost or (stack and stack.valid_for_read and stack.valid) then
         kb_click_hand(event)
      elseif storage.players[pindex].vanilla_mode == false then
         kb_click_entity(event)
      end
   end
)

EventManager.on_event(
   "fa-a-l",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      WorkerRobots.logistics_request_toggle_handler(pindex)
   end
)

EventManager.on_event(
   "fa-a-f",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      WorkerRobots.announce_robot_dispatch_status(pindex)
   end
)

EventManager.on_event(
   "fa-a-leftbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      -- Handle rail builder when locked to rails in VTD mode
      if VirtualTrainDriving.is_locked(pindex) then
         UiRouter.get_router(pindex):open_ui(UiRouter.UI_NAMES.RAIL_BUILDER)
         return
      end

      local p = game.get_player(pindex)
      local stack = p.cursor_stack

      -- Handle offshore pumps with alt+[
      if stack and stack.valid_for_read and stack.name == "offshore-pump" then
         BuildingTools.build_offshore_pump_in_hand(pindex)
         return
      end

      -- Handle splitter filter set/clear
      local selected = p.selected
      if selected and selected.valid and selected.type == "splitter" then
         local result
         if stack and stack.valid_for_read then
            -- Set filter to item in hand
            result = TransportBelts.set_splitter_priority(selected, nil, nil, stack, false)
         else
            -- Clear filter with empty hand
            result = TransportBelts.set_splitter_priority(selected, nil, nil, nil, true)
         end
         Speech.speak(pindex, result)
         return
      end

      -- Handle inserter filter set/clear
      if selected and selected.valid and selected.type == "inserter" then
         -- Check if this inserter supports filters
         if selected.filter_slot_count == 0 then
            Speech.speak(pindex, { "fa.inserter-filters-not-supported" })
            return
         end

         if stack and stack.valid_for_read then
            -- Set filter to item in hand
            -- Clear all existing filters first
            for i = 1, selected.filter_slot_count do
               Filters.set_filter(selected, i, nil)
            end

            -- Set to whitelist mode
            selected.inserter_filter_mode = "whitelist"

            -- Set the first filter to the item in hand
            Filters.set_filter(selected, 1, { name = stack.name })

            Speech.speak(pindex, {
               "fa.inserter-filter-set",
               stack.prototype.localised_name,
            })
         else
            -- Clear all filters with empty hand
            for i = 1, selected.filter_slot_count do
               Filters.set_filter(selected, i, nil)
            end

            Speech.speak(pindex, { "fa.inserter-filter-cleared" })
         end
      end
   end
)

---@param event EventData.CustomInputEvent
---@param ent LuaEntity
local function kb_launch_rocket(event, ent)
   local pindex = event.player_index
   local try_launch = ent.launch_rocket({
      type = defines.cargo_destination.surface,
      surface = ent.surface,
      transform_launch_products = true,
   })
   if try_launch then
      Speech.speak(pindex, { "fa.launch-successful" })
   else
      Speech.speak(pindex, { "fa.not-ready-to-launch" })
   end
end

EventManager.on_event(
   "fa-s-enter",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local p = game.get_player(pindex)
      local ent = p.selected

      if not ent or not ent.valid then return end

      if ent.type == "rocket-silo" then
         kb_launch_rocket(event, ent)
      elseif ent.type == "constant-combinator" then
         local cb = ent.get_control_behavior()
         ---@cast cb LuaConstantCombinatorControlBehavior?
         if cb then
            cb.enabled = not cb.enabled
            if cb.enabled then
               Speech.speak(pindex, { "fa.switched-on" })
            else
               Speech.speak(pindex, { "fa.switched-off" })
            end
         end
         return
      end

      if ent.type == "power-switch" then
         local cb = ent.get_control_behavior()
         if cb and (cb.circuit_enable_disable or cb.connect_to_logistic_network) then
            Speech.speak(pindex, { "fa.power-switch-circuit-controlled" })
         else
            ent.power_switch_state = not ent.power_switch_state
            if ent.power_switch_state then
               Speech.speak(pindex, { "fa.switched-on" })
            else
               Speech.speak(pindex, { "fa.switched-off" })
            end
         end
         return
      end
   end
)

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
   then
      --Laterdo here: build as ghost
      kb_read_entity_status(event)
   elseif stack.is_blueprint then
      local router = UiRouter.get_router(pindex)
      router:open_ui(UiRouter.UI_NAMES.BLUEPRINT)
   elseif stack.is_blueprint_book then
      local router = UiRouter.get_router(pindex)
      router:open_ui(UiRouter.UI_NAMES.BLUEPRINT_BOOK)
   elseif stack.is_deconstruction_item or stack.is_upgrade_item then
      -- Deconstruction and upgrade planners are now handled via left-click and alt+left-click
      Speech.speak(pindex, { "fa.planner-use-leftbracket" })
   else
      -- Regular item in hand (including spidertron remote) - read entity status as fallback
      kb_read_entity_status(event)
   end
end

EventManager.on_event(
   "fa-rightbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].last_click_tick == event.tick then return end
      local router = UiRouter.get_router(pindex)
      local p = game.get_player(pindex)
      local stack = p.cursor_stack

      if stack and stack.valid_for_read and stack.valid then
         if stack.prototype.type == "spidertron-remote" then
            -- Toggle selected spidertron on remote
            local entity = EntitySelection.get_first_ent_at_tile(pindex)
            if entity and entity.type == "spider-vehicle" then
               SpidertronRemote.toggle_spidertron(p, entity)
            else
               Speech.speak(pindex, { "fa.spidertron-remote-no-spidertron-selected" })
            end
         else
            kb_click_hand_right(event)
         end
      else
         -- Empty hand case - read entity status

         kb_read_entity_status(event)
      end
   end
)

EventManager.on_event(
   "fa-a-rightbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      -- Handle syntrax input when locked to rails in VTD mode
      if VirtualTrainDriving.open_syntrax_input(pindex) then return end

      local p = game.get_player(pindex)
      local stack = p.cursor_stack

      if stack and stack.valid_for_read and stack.prototype.type == "spidertron-remote" then
         SpidertronRemoteSelector.open_spidertron_selector(pindex)
      end
   end
)

EventManager.on_event(
   "fa-s-leftbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].last_click_tick == event.tick then return end
      storage.players[pindex].last_click_tick = event.tick

      local p = game.get_player(pindex)
      local stack = p.cursor_stack

      -- Place ghost if item in hand can be built
      if stack and stack.valid_for_read then
         if stack.prototype.type == "spidertron-remote" then
            -- Clear autopilot and set new destination for spidertron remote
            local vp = Viewpoint.get_viewpoint(pindex)
            local cursor_pos = vp:get_cursor_pos()
            SpidertronRemote.add_to_autopilot(p, cursor_pos, true)
            return
         end

         -- Rail planner: lock on with force mode (real or ghost rails)
         if stack.prototype.rails then
            local ent = EntitySelection.get_first_ent_at_tile(pindex)
            local is_rail = ent and ent.valid and Consts.RAIL_TYPES_SET[ent.type]
            local is_ghost_rail = ent
               and ent.valid
               and ent.type == "entity-ghost"
               and Consts.RAIL_TYPES_SET[ent.ghost_type]
            if is_rail or is_ghost_rail then
               VirtualTrainDriving.lock_on_to_rail(pindex, ent, defines.build_mode.forced)
               return
            end
         end

         local proto = stack.prototype
         if proto.place_result or proto.place_as_tile_result then
            -- Item can be placed as a ghost
            local vp = Viewpoint.get_viewpoint(pindex)
            local success = BuildingTools.place_ghost_with_params({
               pindex = pindex,
               building_direction = vp:get_hand_direction(),
               flip_horizontal = vp:get_flipped_horizontal(),
               flip_vertical = vp:get_flipped_vertical(),
            })
            if success then TileReader.read_tile(pindex) end
         else
            -- Item cannot be built
            Speech.speak(pindex, { "fa.cannot-build-item" })
         end
      end
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
   "fa-ca-rightbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      KruiseKontrol.activate_kk(pindex)
   end
)

EventManager.on_event(
   "fa-cs-leftbracket",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local player = game.players[pindex]
      if not player.cursor_stack.valid_for_read then return end

      -- Rail planner: lock on with superforce mode (real or ghost rails)
      if player.cursor_stack.prototype.rails then
         local ent = EntitySelection.get_first_ent_at_tile(pindex)
         local is_rail = ent and ent.valid and Consts.RAIL_TYPES_SET[ent.type]
         local is_ghost_rail = ent
            and ent.valid
            and ent.type == "entity-ghost"
            and Consts.RAIL_TYPES_SET[ent.ghost_type]
         if is_rail or is_ghost_rail then
            VirtualTrainDriving.lock_on_to_rail(pindex, ent, defines.build_mode.superforced)
            return
         end
      end

      if player.cursor_stack.is_repair_tool then kb_repair_area(event) end
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

EventManager.on_event(
   "fa-h",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      BuildingTools.flip_item_in_hand_horizontal(event)
   end
)

EventManager.on_event(
   "fa-f",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_read_item_pickup_state(event)
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

EventManager.on_event(
   "fa-v",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      BuildingTools.flip_item_in_hand_vertical(event)
   end
)

EventManager.on_event(
   "fa-g",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      kb_read_health_and_armor_stats(event)
   end
)

EventManager.on_event(
   "fa-r",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)
      ---From event rotate-building
      BuildingTools.rotate_item_in_hand(event, true)
   end
)

EventManager.on_event(
   "fa-s-r",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      BuildingTools.rotate_item_in_hand(event, false)
   end
)

--Called when player rotates an entity on the map
EventManager.on_event(
   defines.events.on_player_rotated_entity,
   ---@param event EventData.on_player_rotated_entity
   function(event)
      BuildingTools.on_entity_rotated(event)
   end
)

--Called when player flips an entity on the map
EventManager.on_event(
   defines.events.on_player_flipped_entity,
   ---@param event EventData.on_player_flipped_entity
   function(event)
      BuildingTools.on_entity_flipped(event)
   end
)

--Reads detailed item info for the item in hand (router handles UI cases via on_read_info)
EventManager.on_event(
   "fa-y",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      -- UI routing is handled automatically by router.lua (line 485)
      -- This is the fallback for when no UI is open
      ItemInfo.read_item_in_hand(pindex)
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
   "fa-f1",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      game.auto_save("manual")
      Speech.speak(pindex, { "fa.saving-game-wait" })
   end
)

---@param event EventData.CustomInputEvent
local function kb_toggle_build_lock(event)
   local pindex = event.player_index
   BuildLock.toggle(pindex)
end

--Toggle building while walking
EventManager.on_event(
   "fa-c-b",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
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

      if p.character then p.character_running_speed_modifier = 0 end
      vp:set_cursor_hidden(true)
      Speech.speak(pindex, { "fa.vanilla-mode-enabled" })
      storage.players[pindex].vanilla_mode = true
   else
      p.print("Vanilla mode : OFF")
      vp:set_cursor_hidden(false)
      storage.players[pindex].vanilla_mode = false
      Speech.speak(pindex, { "fa.vanilla-mode-disabled" })
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

EventManager.on_event(
   "fa-mouse-button-3",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      game.get_player(pindex).game_view_settings.update_entity_selection = true
   end
)

EventManager.on_event("fa-q", CursorChanges.kb_pipette_tool)

EventManager.on_event(
   "fa-s-q",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      read_hand(pindex)
   end
)

EventManager.on_event(
   "fa-p",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      if storage.players[pindex].vanilla_mode then return end
      local router = UiRouter.get_router(pindex)
      router:open_ui(UiRouter.UI_NAMES.WARNINGS)
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
   "fa-a-v",
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

local function kb_inventory_read_equipment_list(event)
   local pindex = event.player_index
   local result = Equipment.read_equipment_list(pindex)
   Speech.speak(pindex, result)
end

EventManager.on_event(
   "fa-s-g",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local router = UiRouter.get_router(pindex)

      kb_inventory_read_equipment_list(event)
   end
)

--Runs before shooting a weapon to check for selected atomic bombs and the target distance
EventManager.on_event(
   "fa-space",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      local pindex = event.player_index

      Combat.run_atomic_bomb_checks(pindex)
   end
)

--Toggle whether rockets are launched automatically when they have cargo
EventManager.on_event(
   "fa-c-space",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      Speech.speak(pindex, { "fa.not-implemented-factorio-2" })
   end
)

--Help key and tutorial system DISABLED (tutorial content nonfunctional)
-- Tutorial system module and data left in place as dead code for future work

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

EventManager.on_event("fa-c-o", function(event)
   Speech.speak(
      event.player_index,
      "Type in the new cruise control speed and press 'ENTER' and then 'E' to confirm, or press 'ESC' to exit"
   )
end)

EventManager.on_event("fa-cas-d", function(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   router:open_ui(UiRouter.UI_NAMES.DEBUG)
end)

EventManager.on_event("fa-cas-m", function(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   router:open_ui(UiRouter.UI_NAMES.SETTINGS)
end)

-- Blueprint book navigation at world level (when not in a menu)
---@param pindex integer
---@param offset integer 1 for next, -1 for previous
local function cycle_blueprint_book(pindex, offset)
   local player = game.get_player(pindex)
   if not player then return end

   local cursor_stack = player.cursor_stack
   if not cursor_stack or not cursor_stack.valid_for_read or not cursor_stack.is_blueprint_book then return end

   local book_inv = cursor_stack.get_inventory(defines.inventory.item_main)
   if not book_inv or #book_inv == 0 then
      Speech.speak(pindex, { "fa.blueprint-book-empty" })
      return
   end

   local current = cursor_stack.active_index or 1
   local new_idx = current + offset
   if new_idx < 1 then
      new_idx = #book_inv
   elseif new_idx > #book_inv then
      new_idx = 1
   end

   cursor_stack.active_index = new_idx
   local active_bp = book_inv[new_idx]
   if active_bp and active_bp.valid_for_read then
      local bp_info = Blueprints.get_blueprint_info(active_bp, false, pindex)
      Speech.speak(pindex, { "", { "fa.blueprint-book-switched" }, " ", bp_info })
   end
end

EventManager.on_event("fa-comma", function(event)
   -- Check for virtual train driving
   local handled, should_read = VirtualTrainDriving.on_kb_descriptive_action_name(event)
   if handled then
      if should_read then TileReader.read_tile(event.player_index) end
      return
   end

   local pindex = event.player_index
   local player = game.get_player(pindex)
   if not player then return end

   local cursor_stack = player.cursor_stack
   if not cursor_stack or not cursor_stack.valid_for_read or not cursor_stack.is_blueprint_book then return end

   local book_inv = cursor_stack.get_inventory(defines.inventory.item_main)
   if not book_inv or #book_inv == 0 then
      Speech.speak(pindex, { "fa.blueprint-book-empty" })
      return
   end

   if not cursor_stack.active_index then
      Speech.speak(pindex, { "fa.blueprint-book-no-active" })
      return
   end

   local active_bp = book_inv[cursor_stack.active_index]
   if active_bp and active_bp.valid_for_read then
      local bp_info = Blueprints.get_blueprint_info(active_bp, false, pindex)
      Speech.speak(pindex, { "", { "fa.blueprint-book-active" }, " ", bp_info })
   else
      Speech.speak(pindex, { "fa.blueprint-book-empty-active" })
   end
end, EventManager.EVENT_KIND.WORLD)

EventManager.on_event("fa-m", function(event)
   -- Check for virtual train driving
   local handled, should_read = VirtualTrainDriving.on_kb_descriptive_action_name(event)
   if handled then
      if should_read then TileReader.read_tile(event.player_index) end
      return
   end

   local pindex = event.player_index
   local player = game.get_player(pindex)
   local stack = player.cursor_stack

   -- Check if wire is in hand
   if stack and stack.valid_for_read then
      local wire_type = stack.name
      if wire_type == "red-wire" or wire_type == "green-wire" or wire_type == "copper-wire" then
         -- Wire in hand - select input/left side
         CircuitNetworks.drag_wire_and_read(pindex, "input")
         return
      elseif stack.prototype.type == "spidertron-remote" then
         SpidertronRemote.cycle_spidertrons(player, -1)
         TileReader.read_tile(pindex)
         return
      end
   end

   cycle_blueprint_book(pindex, -1)
end, EventManager.EVENT_KIND.WORLD)

EventManager.on_event("fa-dot", function(event)
   -- Check for virtual train driving
   local handled, should_read = VirtualTrainDriving.on_kb_descriptive_action_name(event)
   if handled then
      if should_read then TileReader.read_tile(event.player_index) end
      return
   end

   local pindex = event.player_index
   local player = game.get_player(pindex)
   local stack = player.cursor_stack

   -- Check if wire is in hand
   if stack and stack.valid_for_read then
      local wire_type = stack.name
      if wire_type == "red-wire" or wire_type == "green-wire" or wire_type == "copper-wire" then
         -- Wire in hand - select output/right side
         CircuitNetworks.drag_wire_and_read(pindex, "output")
         return
      elseif stack.prototype.type == "spidertron-remote" then
         SpidertronRemote.cycle_spidertrons(player, 1)
         TileReader.read_tile(pindex)
         return
      end
   end

   cycle_blueprint_book(pindex, 1)
end, EventManager.EVENT_KIND.WORLD)

EventManager.on_event("fa-a-comma", function(event)
   -- Check for virtual train driving
   if VirtualTrainDriving.on_kb_descriptive_action_name(event) then return end
end, EventManager.EVENT_KIND.WORLD)

EventManager.on_event("fa-slash", function(event)
   -- Check for virtual train driving first
   if VirtualTrainDriving.on_kb_descriptive_action_name(event) then return end

   -- Otherwise, fall through to UI handling (handled by router)
end, EventManager.EVENT_KIND.WORLD)

-- Virtual train signal placement keybindings
EventManager.on_event("fa-c-m", function(event)
   local handled, should_read = VirtualTrainDriving.on_kb_descriptive_action_name(event)
   if handled then
      if should_read then TileReader.read_tile(event.player_index) end
      return
   end
end, EventManager.EVENT_KIND.WORLD)

EventManager.on_event("fa-s-m", function(event)
   local handled, should_read = VirtualTrainDriving.on_kb_descriptive_action_name(event)
   if handled then
      if should_read then TileReader.read_tile(event.player_index) end
      return
   end
end, EventManager.EVENT_KIND.WORLD)

EventManager.on_event("fa-c-dot", function(event)
   local handled, should_read = VirtualTrainDriving.on_kb_descriptive_action_name(event)
   if handled then
      if should_read then TileReader.read_tile(event.player_index) end
      return
   end
end, EventManager.EVENT_KIND.WORLD)

EventManager.on_event("fa-s-dot", function(event)
   local handled, should_read = VirtualTrainDriving.on_kb_descriptive_action_name(event)
   if handled then
      if should_read then TileReader.read_tile(event.player_index) end
      return
   end
end, EventManager.EVENT_KIND.WORLD)

-- Dangerous delete: Delete blueprint/decon/upgrade planner from hand, or clear spidertron remote list
EventManager.on_event("fa-c-backspace", function(event)
   local pindex = event.player_index
   local player = game.get_player(pindex)
   if not player then return end

   local cursor_stack = player.cursor_stack
   if not cursor_stack or not cursor_stack.valid_for_read then
      Speech.speak(pindex, { "fa.dangerous-delete-nothing-to-delete" })
      return
   end

   -- Check for spidertron remote
   if cursor_stack.prototype.type == "spidertron-remote" then
      SpidertronRemote.clear_remote(player)
      return
   end

   -- Check if it's a planner item using API flags
   if
      cursor_stack.is_blueprint
      or cursor_stack.is_blueprint_book
      or cursor_stack.is_deconstruction_item
      or cursor_stack.is_upgrade_item
   then
      local item_description = ItemInfo.item_info({
         name = cursor_stack.name,
         count = cursor_stack.count,
         quality = cursor_stack.quality and cursor_stack.quality.name or nil,
      })

      -- Clear the cursor
      cursor_stack.clear()

      Speech.speak(pindex, { "fa.dangerous-delete-deleted", item_description })
   else
      Speech.speak(pindex, { "fa.dangerous-delete-not-planner" })
   end
end, EventManager.EVENT_KIND.WORLD)

-- Clear autopilot for spidertron remote
EventManager.on_event("fa-backspace", function(event)
   -- Check for virtual train driving
   local handled, should_read = VirtualTrainDriving.on_kb_descriptive_action_name(event)
   if handled then
      if should_read then TileReader.read_tile(event.player_index) end
      return
   end

   local pindex = event.player_index
   local player = game.get_player(pindex)
   if not player then return end

   local cursor_stack = player.cursor_stack
   if cursor_stack and cursor_stack.valid_for_read and cursor_stack.prototype.type == "spidertron-remote" then
      SpidertronRemote.clear_autopilot(player)
   end
end, EventManager.EVENT_KIND.WORLD)

EventManager.on_event("fa-ca-l", function(event)
   local pindex = event.player_index
   local player = game.get_player(pindex)
   if not player then return end

   local entity = player.selected
   if not entity or not entity.valid then
      Speech.speak(pindex, { "fa.entity-invalid" })
      return
   end

   -- Check if entity has any logistics support
   local points = entity.get_logistic_point()
   if not points then
      Speech.speak(pindex, { "fa.entity-no-logistics" })
      return
   end

   local router = UiRouter.get_router(pindex)
   router:open_ui(UiRouter.UI_NAMES.LOGISTICS_CONFIG, { entity = entity })
end)

EventManager.on_event("fa-cas-l", function(event)
   local pindex = event.player_index
   local player = game.get_player(pindex)
   if not player or not player.character then return end

   local router = UiRouter.get_router(pindex)
   router:open_ui(UiRouter.UI_NAMES.LOGISTICS_CONFIG, { entity = player.character })
end)

EventManager.on_event(
   "fa-kk-cancel",
   ---@param event EventData.CustomInputEvent
   function(event, pindex)
      KruiseKontrol.cancel_kk(pindex)
   end
)

-- Send hand contents to trash: O key
EventManager.on_event("fa-o", function(event)
   local pindex = event.player_index
   local player = game.get_player(pindex)
   if not player or not player.character then return end

   local cursor_stack = player.cursor_stack
   if not cursor_stack or not cursor_stack.valid_for_read then
      Speech.speak(pindex, { "fa.trash-nothing-in-hand" })
      return
   end

   -- Get character's trash inventory
   local trash_inventory = InventoryUtils.find_trash_inventory(player.character)
   if not trash_inventory then
      Speech.speak(pindex, { "fa.trash-not-available" })
      return
   end

   -- Try to insert into trash
   local item_name = cursor_stack.name
   local item_count = cursor_stack.count
   local item_quality = cursor_stack.quality and cursor_stack.quality.name or nil

   local inserted = trash_inventory.insert({ name = item_name, count = item_count, quality = item_quality })

   if inserted > 0 then
      -- Remove from hand
      cursor_stack.count = cursor_stack.count - inserted

      -- Announce success
      local item_description = ItemInfo.item_info({
         name = item_name,
         count = inserted,
         quality = item_quality,
      })
      Speech.speak(pindex, { "fa.trash-sent-to-trash", item_description })

      if inserted < item_count then Speech.speak(pindex, { "fa.trash-full", tostring(item_count - inserted) }) end
   else
      Speech.speak(pindex, { "fa.trash-full-none-inserted" })
   end
end, EventManager.EVENT_KIND.WORLD)

-- Virtual train driving keys
-- TODO: Add these key definitions to data.lua
-- EventManager.on_event("fa-slash", function(event)
--    VirtualTrainDriving.on_kb_descriptive_action_name(event)
-- end, EventManager.EVENT_KIND.WORLD)

-- EventManager.on_event("fa-alt-comma", function(event)
--    VirtualTrainDriving.on_kb_descriptive_action_name(event)
-- end, EventManager.EVENT_KIND.WORLD)

-- EventManager.on_event("fa-shift-b", function(event)
--    VirtualTrainDriving.on_kb_descriptive_action_name(event)
-- end, EventManager.EVENT_KIND.WORLD)

-- EventManager.on_event("fa-ctrl-m", function(event)
--    VirtualTrainDriving.on_kb_descriptive_action_name(event)
-- end, EventManager.EVENT_KIND.WORLD)

-- EventManager.on_event("fa-ctrl-dot", function(event)
--    VirtualTrainDriving.on_kb_descriptive_action_name(event)
-- end, EventManager.EVENT_KIND.WORLD)

-- EventManager.on_event("fa-shift-m", function(event)
--    VirtualTrainDriving.on_kb_descriptive_action_name(event)
-- end, EventManager.EVENT_KIND.WORLD)

-- EventManager.on_event("fa-shift-dot", function(event)
--    VirtualTrainDriving.on_kb_descriptive_action_name(event)
-- end, EventManager.EVENT_KIND.WORLD)

-- Zoom controls (WORLD priority so UI bar handlers take precedence)
EventManager.on_event("fa-minus", function(event, pindex)
   Zoom.zoom_out(pindex)
end, EventManager.EVENT_KIND.WORLD)

EventManager.on_event("fa-equals", function(event, pindex)
   Zoom.zoom_in(pindex)
end, EventManager.EVENT_KIND.WORLD)

EventManager.on_event("fa-a-z", function(event, pindex)
   Zoom.announce_zoom(pindex)
end, EventManager.EVENT_KIND.WORLD)
