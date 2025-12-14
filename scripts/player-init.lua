--[[
Player Initialization Module
Handles initialization of player state when joining the game.
Sets up default values and data structures for each player.
]]

local FaUtils = require("scripts.fa-utils")
local TH = require("scripts.table-helpers")
local Localising = require("scripts.localising")

local dirs = defines.direction

local mod = {}

---Initialize the globally saved data tables for a specific player
---@param player LuaPlayer
function mod.initialize(player)
   local force = player.force.index
   storage.forces[force] = storage.forces[force] or {}
   local fa_force = storage.forces[force]

   storage.players[player.index] = storage.players[player.index] or {}
   local faplayer = storage.players[player.index]
   faplayer.player = player

   if not fa_force.resources then
      for pi, p in pairs(storage.players) do
         if p.player.valid and p.player.force.index == force and p.resources and p.mapped then
            fa_force.resources = p.resources
            fa_force.mapped = p.mapped
            break
         end
      end
      fa_force.resources = fa_force.resources or {}
      fa_force.mapped = fa_force.mapped or {}
   end

   local character = player.cutscene_character or player.character or player
   faplayer.num_elements = faplayer.num_elements or 0

   if type(faplayer.building_footprint) == "number" then faplayer.building_footprint = nil end

   if type(faplayer.building_dir_arrow) == "number" then faplayer.building_dir_arrow = nil end

   faplayer.overhead_sprite = nil
   faplayer.overhead_circle = nil
   faplayer.custom_GUI_frame = nil
   faplayer.custom_GUI_sprite = nil
   faplayer.direction_lag = faplayer.direction_lag or true
   faplayer.previous_hand_item_name = faplayer.previous_hand_item_name or ""
   faplayer.last = faplayer.last or ""
   faplayer.last_indexed_ent = faplayer.last_indexed_ent or nil
   faplayer.last_move_tick = faplayer.last_move_tick or 0
   faplayer.last_build_tick = faplayer.last_build_tick or 0
   faplayer.last_click_tick = faplayer.last_click_tick or 0
   faplayer.last_menu_search_tick = faplayer.last_menu_search_tick or 0
   faplayer.last_pickup_tick = faplayer.last_pickup_tick or 0
   faplayer.last_menu_toggle_tick = faplayer.last_menu_toggle_tick or 0
   faplayer.last_damage_alert_tick = faplayer.last_damage_alert_tick or 0
   faplayer.last_honk_tick = faplayer.last_honk_tick or 0
   faplayer.last_driving_alert_tick = faplayer.last_driving_alert_tick or 0
   faplayer.last_click_time = faplayer.last_click_time or 0
   faplayer.lag_building_in_hand = faplayer.lag_building_in_hand or nil
   faplayer.lag_building_selected = faplayer.lag_building_selected or nil
   faplayer.tile = faplayer.tile or character.surface.get_tile(character.position.x, character.position.y)
   faplayer.move_state = faplayer.move_state or {}
   faplayer.remote_view = faplayer.remote_view or false
   faplayer.remote_view_tiles = faplayer.remote_view_tiles or 0
   faplayer.cursor_size = faplayer.cursor_size or 0
   faplayer.ruler = faplayer.ruler or nil
   faplayer.inventory = faplayer.inventory
      or {
         lua_inventory = character.get_main_inventory(),
         index = 1,
         width = 10,
         max = #character.get_main_inventory(),
      }
   faplayer.crafting = faplayer.crafting
      or {
         lua_recipes = {},
         max = 1,
         index = 1,
         category = 1,
      }
   faplayer.crafting_queue = faplayer.crafting_queue or { index = 1, max = 0 }
   faplayer.blueprint_hand = faplayer.blueprint_hand or {}
   faplayer.blueprint_reselect = faplayer.blueprint_reselect or { bp = nil, from_inv = nil }

   faplayer.building = faplayer.building
      or {
         ent = nil,
         recipe_list = nil,
         recipe_selection = false,
         index = 1,
         sector = 1,
         item_selection = false,
         sectors = {},
         sector_name = "",
      }
   faplayer.building.sectors = faplayer.building.sectors or {} --laterdo maybe remove this, it might be redundant

   faplayer.mining = faplayer.mining or {}

   faplayer.repair = faplayer.repair or {}

   faplayer.warnings = faplayer.warnings or {}

   faplayer.walking = faplayer.walking or {}

   faplayer.combat = faplayer.combat or {}

   faplayer.guns_menu = faplayer.guns_menu or {}

   faplayer.blueprint_menu = faplayer.blueprint_menu or {}

   faplayer.menu_history = faplayer.menu_history or {}

   faplayer.menu = faplayer.menu or "character"

   faplayer.move_queue = faplayer.move_queue or {}

   faplayer.travel_queue_list = faplayer.travel_queue_list or {}

   faplayer.spidertron_remote = faplayer.spidertron_remote or { active = false, spider = nil }

   faplayer.equipment = faplayer.equipment or { index = 1, sector = 1 }

   faplayer.technology = faplayer.technology or { category = 1, index = 1 }

   faplayer.belt_lane_direction = faplayer.belt_lane_direction or nil

   faplayer.belt_side = faplayer.belt_side or nil

   faplayer.bp_selecting = faplayer.bp_selecting or false

   faplayer.bp_select_start_pos = faplayer.bp_select_start_pos or nil

   --Clear the temporary selection table
   if faplayer.selection then
      faplayer.selection.starting = nil
      faplayer.selection.ending = nil
   end

   faplayer.network_or_logistics = faplayer.network_or_logistics or "logistics"

   faplayer.circuit_network_menu = faplayer.circuit_network_menu
      or {
         network_index = nil,
         signal_index = nil,
         signal_name = nil,
         index = 1,
      }

   faplayer.skip_read_hand_on_cursor_stack_changed = faplayer.skip_read_hand_on_cursor_stack_changed or false

   faplayer.opened_inventory = faplayer.opened_inventory or nil

   --Quickbar
   faplayer.qb_index = faplayer.qb_index or 1
   faplayer.qb_slot = faplayer.qb_slot or { 1, 1 }
   faplayer.qb_page_count = faplayer.qb_page_count or 0

   --Key help
   faplayer.key_help_mode = faplayer.key_help_mode or false

   -- Mouse
   faplayer.is_selecting = faplayer.is_selecting or false

   -- Graphics and rendering
   faplayer.building_footprint = faplayer.building_footprint or nil
   faplayer.building_footprint_clear = faplayer.building_footprint_clear or nil
   faplayer.building_footprint_valid = faplayer.building_footprint_valid or true
   faplayer.building_footprint_size = faplayer.building_footprint_size or nil
   faplayer.building_dir_arrow = faplayer.building_dir_arrow or nil
   faplayer.cursor_horiz = faplayer.cursor_horiz or nil
   faplayer.cursor_verti = faplayer.cursor_verti or nil
   faplayer.cursor_round = faplayer.cursor_round or nil
   faplayer.vanilla_mode = faplayer.vanilla_mode or false
   faplayer.draw_cursor = faplayer.draw_cursor or false
   faplayer.hide_cursor = faplayer.hide_cursor or false
   faplayer.hide_line = faplayer.hide_line or false
   faplayer.hide_line_ticks = faplayer.hide_line_ticks or 0
   faplayer.draw_direction_keys_lines = faplayer.draw_direction_keys_lines or false
   faplayer.draw_1_narrow_line = faplayer.draw_1_narrow_line or false
   faplayer.draw_1_narrow_line_tick = faplayer.draw_1_narrow_line_tick or 0
   faplayer.hide_arrow = faplayer.hide_arrow or false
   faplayer.hide_arrow_ticks = faplayer.hide_arrow_ticks or 0
   faplayer.hide_footprint = faplayer.hide_footprint or false
   faplayer.hide_footprint_ticks = faplayer.hide_footprint_ticks or 0
   faplayer.hide_inv_slots = faplayer.hide_inv_slots or false
   faplayer.hide_inv_slot_ticks = faplayer.hide_inv_slot_ticks or 0
   faplayer.hide_bp = faplayer.hide_bp or false
   faplayer.hide_bp_ticks = faplayer.hide_bp_ticks or 0
   faplayer.inv_index_announcement = faplayer.inv_index_announcement or "none"
   faplayer.inv_mode_announcement = faplayer.inv_mode_announcement or "standard"
   faplayer.jump_to_text_field = faplayer.jump_to_text_field or false
   faplayer.old_drawing = faplayer.old_drawing or false
   faplayer.click_to_text_field = faplayer.click_to_text_field or false
   faplayer.draw_cursor_index = faplayer.draw_cursor_index or false
   faplayer.draw_cursor_original_index = faplayer.draw_cursor_original_index or false

   -- Player preferences
   faplayer.preferences = faplayer.preferences or {}

   faplayer.preferences.building_inventory_row_length = faplayer.preferences.building_inventory_row_length or 8
   if faplayer.preferences.inventory_wraps_around == nil then faplayer.preferences.inventory_wraps_around = true end
   if faplayer.preferences.tiles_placed_from_northwest_corner == nil then
      faplayer.preferences.tiles_placed_from_northwest_corner = false
   end

   -- Walking modes
   faplayer.smooth_walking = faplayer.smooth_walking or true

   -- Logistic slots
   faplayer.logistic_slot_counts = faplayer.logistic_slot_counts or {}
   if not (player.character == nil) then faplayer.logistic_slot_counts = faplayer.logistic_slot_counts or {} end

   -- Other
   faplayer.last_aggregate = faplayer.last_aggregate or {}
   faplayer.recent_item_name = faplayer.recent_item_name or ""
   faplayer.recent_fluid_name = faplayer.recent_fluid_name or ""
   faplayer.spider_menu = faplayer.spider_menu or {}
   faplayer.last_line_id = faplayer.last_line_id or 0
   faplayer.tutorial_mode = faplayer.tutorial_mode or false
   faplayer.launcher_version = faplayer.launcher_version or "0.0.0"
   faplayer.in_splash_sequence = faplayer.in_splash_sequence or false
   faplayer.play_cursor_sound = faplayer.play_cursor_sound or false
   faplayer.resources = fa_force.resources or {}
   faplayer.mapped = fa_force.mapped or {}
   faplayer.following = faplayer.following or nil
   faplayer.followed_by = faplayer.followed_by or {}
   faplayer.follow_id = faplayer.follow_id or nil
   faplayer.last_technology_count = faplayer.last_technology_count or 0
   faplayer.click_to_open = faplayer.click_to_open or "disabled"
   faplayer.entering_new_character_name = faplayer.entering_new_character_name or false
   faplayer.renaming_character_name = faplayer.renaming_character_name or ""
   faplayer.idle_action_todo = faplayer.idle_action_todo or ""
   faplayer.idle_action_save = faplayer.idle_action_save or nil
   faplayer.last_running_direction = faplayer.last_running_direction or dirs.north
   faplayer.lag_voice_queued = faplayer.lag_voice_queued or false
   faplayer.cursor_scanned = faplayer.cursor_scanned or false
   faplayer.warned_heavily_forested = faplayer.warned_heavily_forested or false
   faplayer.warned_mining_near_pipe = faplayer.warned_mining_near_pipe or false
   faplayer.warned_pipe_on_ground = faplayer.warned_pipe_on_ground or false
   faplayer.last_30_tile = faplayer.last_30_tile or ""
   faplayer.last_20_tile = faplayer.last_20_tile or ""
   faplayer.last_10_tile = faplayer.last_10_tile or ""
   faplayer.time_of_30 = faplayer.time_of_30 or 0
   faplayer.time_of_20 = faplayer.time_of_20 or 0
   faplayer.time_of_10 = faplayer.time_of_10 or 0
   faplayer.last_60_ent = faplayer.last_60_ent or ""
   faplayer.last_40_ent = faplayer.last_40_ent or ""
   faplayer.last_20_ent = faplayer.last_20_ent or ""
   faplayer.time_of_ent_60 = faplayer.time_of_ent_60 or 0
   faplayer.time_of_ent_40 = faplayer.time_of_ent_40 or 0
   faplayer.time_of_ent_20 = faplayer.time_of_ent_20 or 0
   faplayer.last_60_tree = faplayer.last_60_tree or ""
   faplayer.last_40_tree = faplayer.last_40_tree or ""
   faplayer.last_20_tree = faplayer.last_20_tree or ""
   faplayer.time_of_tree_60 = faplayer.time_of_tree_60 or 0
   faplayer.time_of_tree_40 = faplayer.time_of_tree_40 or 0
   faplayer.time_of_tree_20 = faplayer.time_of_tree_20 or 0
   faplayer.last_obstacle_tick = faplayer.last_obstacle_tick or 0
   faplayer.last_warned_pos = faplayer.last_warned_pos or { x = 0, y = 0 }
   faplayer.cursor_bookmark_direction = faplayer.cursor_bookmark_direction or dirs.north
   faplayer.entities_scanned = faplayer.entities_scanned or {}
   faplayer.players_distance_described = faplayer.players_distance_described or false
   faplayer.quick_bar_rows = faplayer.quick_bar_rows or 1
   -- TODO: mod_settings doesn't exist on LuaEntity - should use player.mod_settings instead
   -- if not (player.character == nil) then
   --    local quickbar_setting = player.mod_settings["fa-quickbar-rows"]
   --    if quickbar_setting then
   --       faplayer.quick_bar_rows = quickbar_setting.value
   --    end
   -- end
   faplayer.said_owner = faplayer.said_owner or {}

   -- Menu initializations

   faplayer.spider_menu = faplayer.spider_menu or {
      index = 0,
      renaming = false,
      spider = nil,
   }

   faplayer.blueprint_menu = faplayer.blueprint_menu
      or {
         index = 0,
         edit_label = false,
         edit_description = false,
         edit_export = false,
         edit_import = false,
      }

   -- Force rechart on empty map
   if table_size(faplayer.mapped) == 0 then player.force.rechart() end

   faplayer.localisations = faplayer.localisations or {}
   faplayer.translation_id_lookup = faplayer.translation_id_lookup or {}

   -- Bump detection is now self-initializing via StorageManager
end

return mod
