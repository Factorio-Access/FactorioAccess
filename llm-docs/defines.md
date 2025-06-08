# Factorio Defines

These are constant values used throughout the API.

## alert_type



**Values:**

- `collector_path_blocked`: 
- `custom`: 
- `entity_destroyed`: 
- `entity_under_attack`: 
- `no_material_for_construction`: 
- `no_platform_storage`: 
- `no_roboport_storage`: 
- `no_storage`: 
- `not_enough_construction_robots`: 
- `not_enough_repair_packs`: 
- `pipeline_overextended`: 
- `platform_tile_building_blocked`: 
- `train_no_path`: 
- `train_out_of_fuel`: 
- `turret_fire`: 
- `turret_out_of_ammo`: 
- `unclaimed_cargo`: 

## behavior_result

AI command exit status. See [LuaEntity::set_command](runtime:LuaEntity::set_command)

**Values:**

- `deleted`: 
- `fail`: 
- `in_progress`: 
- `success`: 

## build_check_type



**Values:**

- `blueprint_ghost`: 
- `ghost_revive`: 
- `manual`: 
- `manual_ghost`: 
- `script`: 
- `script_ghost`: 

## build_mode



**Values:**

- `forced`: 
- `normal`: 
- `superforced`: 

## cargo_destination



**Values:**

- `invalid`: The default destination type of a cargo pod when created runtime. Setting its destination to any other type will instantly launch it.
- `orbit`: Cargo pods with orbit destination are destroyed when ascent is completed.
- `space_platform`: Only used for sending a space platform starter pack to a platform that is waiting for one. Regular deliveries to space platform hubs use [station](runtime:defines.cargo_destination.station) destination type instead.
- `station`: Any cargo landing pad or space platform hub.
- `surface`: Cargo pods will switch destination type from surface to station before starting descent if there is a station available and [CargoDestination::position](runtime:CargoDestination::position) has not been specified. Note, setting the destination to "surface" when the surface is the same as the one the pod is on forces it to find and set a landing position.

## chain_signal_state

State of a chain signal.

**Values:**

- `all_open`: 
- `none`: 
- `none_open`: 
- `partially_open`: 

## chunk_generated_status



**Values:**

- `basic_tiles`: 
- `corrected_tiles`: 
- `custom_tiles`: 
- `entities`: 
- `nothing`: 
- `tiles`: 

## command

Command given to units describing what they should do.

**Values:**

- `attack`: Attack another entity.
- `attack_area`: Go to a place and attack what you see.
- `build_base`: Go to a position and build a base there.
- `compound`: Chain commands together, see [defines.compound_command](runtime:defines.compound_command).
- `flee`: Flee from another entity.
- `go_to_location`: Go to a specific position.
- `group`: Do what your group wants you to do.
- `stop`: Stop moving and stay where you are.
- `wander`: Chill.

## compound_command

How commands are joined together in a compound command (see [defines.command.compound](runtime:defines.command.compound)).

**Values:**

- `logical_and`: Fail on first failure. Only succeeds if all commands (executed one after another) succeed.
- `logical_or`: Succeed on first success. Only fails if all commands (executed one after another) fail.
- `return_last`: Execute all commands in sequence and fail or succeed depending on the return status of the last command.

## control_behavior



## controllers



**Values:**

- `character`: The controller controls a character. This is the default controller in freeplay.
- `cutscene`: The player can't interact with the world, and the camera pans around in a predefined manner.
- `editor`: The Editor Controller near ultimate power to do almost anything in the game.
- `ghost`: Can't interact with the world, can only observe. Used in the multiplayer waiting-to-respawn screen.
- `god`: The controller isn't tied to a character. This is the default controller in sandbox.
- `remote`: Can't move/change items but can build ghosts/change settings.
- `spectator`: Can't change anything in the world but can view anything.

## deconstruction_item



## default_icon_size



## difficulty



**Values:**

- `easy`: 
- `hard`: 
- `normal`: 

## direction



**Values:**

- `east`: 
- `eastnortheast`: 
- `eastsoutheast`: 
- `north`: 
- `northeast`: 
- `northnortheast`: 
- `northnorthwest`: 
- `northwest`: 
- `south`: 
- `southeast`: 
- `southsoutheast`: 
- `southsouthwest`: 
- `southwest`: 
- `west`: 
- `westnorthwest`: 
- `westsouthwest`: 

## disconnect_reason



**Values:**

- `afk`: 
- `banned`: 
- `cannot_keep_up`: 
- `desync_limit_reached`: 
- `dropped`: 
- `kicked`: 
- `kicked_and_deleted`: 
- `quit`: 
- `reconnect`: 
- `switching_servers`: 
- `wrong_input`: 

## distraction



**Values:**

- `by_anything`: Attack closer enemy entities, including entities "built" by player (belts, inserters, chests).
- `by_damage`: Attack when attacked.
- `by_enemy`: Attack closer enemy entities with force.
- `none`: Perform command even if someone attacks the unit.

## entity_status



**Values:**

- `broken`: Only used if set through [ContainerPrototype::default_status](prototype:ContainerPrototype::default_status).
- `cant_divide_segments`: Used by rail signals.
- `charging`: Used by accumulators.
- `closed_by_circuit_network`: 
- `computing_navigation`: Used by asteroid collectors.
- `destination_stop_full`: Used by trains.
- `disabled`: Used by constant combinators: Combinator is turned off via switch in GUI.
- `disabled_by_control_behavior`: 
- `disabled_by_script`: 
- `discharging`: Used by accumulators.
- `fluid_ingredient_shortage`: Used by crafting machines.
- `frozen`: 
- `full_burnt_result_output`: Used by burner energy sources.
- `full_output`: Used by crafting machines, boilers, burner energy sources and reactors: Reactor/burner has full burnt result inventory, boiler has full output fluidbox.
- `fully_charged`: Used by accumulators.
- `ghost`: Used by ghosts.
- `item_ingredient_shortage`: Used by crafting machines.
- `launching_rocket`: Used by the rocket silo.
- `low_input_fluid`: Used by boilers and fluid turrets: Boiler still has some fluid but is about to run out.
- `low_power`: 
- `low_temperature`: Used by heat energy sources.
- `marked_for_deconstruction`: 
- `missing_required_fluid`: Used by mining drills when the mining fluid is missing.
- `missing_science_packs`: Used by labs.
- `networks_connected`: Used by power switches.
- `networks_disconnected`: Used by power switches.
- `no_ammo`: Used by ammo turrets.
- `no_filter`: Used by filter inserters.
- `no_fuel`: 
- `no_ingredients`: Used by furnaces.
- `no_input_fluid`: Used by boilers, fluid turrets and fluid energy sources: Boiler has no fluid to work with.
- `no_minable_resources`: Used by mining drills.
- `no_modules_to_transmit`: Used by beacons.
- `no_path`: Used by trains and space platform hubs.
- `no_power`: 
- `no_recipe`: Used by assembling machines.
- `no_research_in_progress`: Used by labs.
- `no_spot_seedable_by_inputs`: Used by agricultural towers.
- `normal`: 
- `not_connected_to_hub_or_pad`: Used by cargo bays.
- `not_connected_to_rail`: Used by rail signals.
- `not_enough_space_in_output`: Used by agricultural towers.
- `not_enough_thrust`: Used by space platform hubs.
- `not_plugged_in_electric_network`: Used by generators and solar panels.
- `on_the_way`: Used by space platform hubs.
- `opened_by_circuit_network`: 
- `out_of_logistic_network`: Used by logistic containers.
- `paused`: Used by space platform hubs.
- `pipeline_overextended`: Used by pipes, pipes to ground and storage tanks.
- `preparing_rocket_for_launch`: Used by the rocket silo.
- `recharging_after_power_outage`: Used by roboports.
- `recipe_is_parameter`: Used by assembling machines.
- `recipe_not_researched`: Used by assembling machines.
- `thrust_not_required`: Used by thrusters.
- `turned_off_during_daytime`: Used by lamps.
- `waiting_at_stop`: Used by trains.
- `waiting_for_more_items`: Used by inserters when wait_for_full_hand is set.
- `waiting_for_plants_to_grow`: Used by agricultural towers.
- `waiting_for_rockets_to_arrive`: Used by space platform hubs.
- `waiting_for_source_items`: Used by inserters.
- `waiting_for_space_in_destination`: Used by inserters and mining drills.
- `waiting_for_space_in_platform_hub`: Used by the rocket silo.
- `waiting_for_target_to_be_built`: Used by inserters targeting entity ghosts.
- `waiting_for_train`: Used by inserters targeting rails.
- `waiting_in_orbit`: Used by space platform hubs.
- `waiting_to_launch_rocket`: Used by the rocket silo.
- `working`: 

## entity_status_diode



**Values:**

- `green`: 
- `red`: 
- `yellow`: 

## events

See the [events page](runtime:events) for more info on what events contain and when they get raised.

**Values:**

- `on_achievement_gained`: 
- `on_ai_command_completed`: 
- `on_area_cloned`: 
- `on_biter_base_built`: 
- `on_brush_cloned`: 
- `on_build_base_arrived`: 
- `on_built_entity`: 
- `on_cancelled_deconstruction`: 
- `on_cancelled_upgrade`: 
- `on_cargo_pod_delivered_cargo`: 
- `on_cargo_pod_finished_ascending`: 
- `on_cargo_pod_finished_descending`: 
- `on_character_corpse_expired`: 
- `on_chart_tag_added`: 
- `on_chart_tag_modified`: 
- `on_chart_tag_removed`: 
- `on_chunk_charted`: 
- `on_chunk_deleted`: 
- `on_chunk_generated`: 
- `on_combat_robot_expired`: 
- `on_console_chat`: 
- `on_console_command`: 
- `on_cutscene_cancelled`: 
- `on_cutscene_finished`: 
- `on_cutscene_started`: 
- `on_cutscene_waypoint_reached`: 
- `on_entity_cloned`: 
- `on_entity_color_changed`: 
- `on_entity_damaged`: 
- `on_entity_died`: 
- `on_entity_logistic_slot_changed`: 
- `on_entity_renamed`: 
- `on_entity_settings_pasted`: 
- `on_entity_spawned`: 
- `on_equipment_inserted`: 
- `on_equipment_removed`: 
- `on_force_cease_fire_changed`: 
- `on_force_created`: 
- `on_force_friends_changed`: 
- `on_force_reset`: 
- `on_forces_merged`: 
- `on_forces_merging`: 
- `on_game_created_from_scenario`: 
- `on_gui_checked_state_changed`: 
- `on_gui_click`: 
- `on_gui_closed`: 
- `on_gui_confirmed`: 
- `on_gui_elem_changed`: 
- `on_gui_hover`: 
- `on_gui_leave`: 
- `on_gui_location_changed`: 
- `on_gui_opened`: 
- `on_gui_selected_tab_changed`: 
- `on_gui_selection_state_changed`: 
- `on_gui_switch_state_changed`: 
- `on_gui_text_changed`: 
- `on_gui_value_changed`: 
- `on_land_mine_armed`: 
- `on_lua_shortcut`: 
- `on_marked_for_deconstruction`: 
- `on_marked_for_upgrade`: 
- `on_market_item_purchased`: 
- `on_mod_item_opened`: 
- `on_multiplayer_init`: 
- `on_object_destroyed`: 
- `on_permission_group_added`: 
- `on_permission_group_deleted`: 
- `on_permission_group_edited`: 
- `on_permission_string_imported`: 
- `on_picked_up_item`: 
- `on_player_alt_reverse_selected_area`: 
- `on_player_alt_selected_area`: 
- `on_player_ammo_inventory_changed`: 
- `on_player_armor_inventory_changed`: 
- `on_player_banned`: 
- `on_player_built_tile`: 
- `on_player_cancelled_crafting`: 
- `on_player_changed_force`: 
- `on_player_changed_position`: 
- `on_player_changed_surface`: 
- `on_player_cheat_mode_disabled`: 
- `on_player_cheat_mode_enabled`: 
- `on_player_clicked_gps_tag`: 
- `on_player_configured_blueprint`: 
- `on_player_controller_changed`: 
- `on_player_crafted_item`: 
- `on_player_created`: 
- `on_player_cursor_stack_changed`: 
- `on_player_deconstructed_area`: 
- `on_player_demoted`: 
- `on_player_died`: 
- `on_player_display_density_scale_changed`: 
- `on_player_display_resolution_changed`: 
- `on_player_display_scale_changed`: 
- `on_player_driving_changed_state`: 
- `on_player_dropped_item`: 
- `on_player_fast_transferred`: 
- `on_player_flipped_entity`: 
- `on_player_flushed_fluid`: 
- `on_player_gun_inventory_changed`: 
- `on_player_input_method_changed`: 
- `on_player_joined_game`: 
- `on_player_kicked`: 
- `on_player_left_game`: 
- `on_player_locale_changed`: 
- `on_player_main_inventory_changed`: 
- `on_player_mined_entity`: 
- `on_player_mined_item`: 
- `on_player_mined_tile`: 
- `on_player_muted`: 
- `on_player_pipette`: 
- `on_player_placed_equipment`: 
- `on_player_promoted`: 
- `on_player_removed`: 
- `on_player_removed_equipment`: 
- `on_player_repaired_entity`: 
- `on_player_respawned`: 
- `on_player_reverse_selected_area`: 
- `on_player_rotated_entity`: 
- `on_player_selected_area`: 
- `on_player_set_quick_bar_slot`: 
- `on_player_setup_blueprint`: 
- `on_player_toggled_alt_mode`: 
- `on_player_toggled_map_editor`: 
- `on_player_trash_inventory_changed`: 
- `on_player_unbanned`: 
- `on_player_unmuted`: 
- `on_player_used_capsule`: 
- `on_player_used_spidertron_remote`: 
- `on_post_entity_died`: 
- `on_pre_build`: 
- `on_pre_chunk_deleted`: 
- `on_pre_entity_settings_pasted`: 
- `on_pre_ghost_deconstructed`: 
- `on_pre_ghost_upgraded`: 
- `on_pre_permission_group_deleted`: 
- `on_pre_permission_string_imported`: 
- `on_pre_player_crafted_item`: 
- `on_pre_player_died`: 
- `on_pre_player_left_game`: 
- `on_pre_player_mined_item`: 
- `on_pre_player_removed`: 
- `on_pre_player_toggled_map_editor`: 
- `on_pre_robot_exploded_cliff`: 
- `on_pre_scenario_finished`: 
- `on_pre_script_inventory_resized`: 
- `on_pre_surface_cleared`: 
- `on_pre_surface_deleted`: 
- `on_redo_applied`: 
- `on_research_cancelled`: 
- `on_research_finished`: 
- `on_research_moved`: 
- `on_research_reversed`: 
- `on_research_started`: 
- `on_resource_depleted`: 
- `on_robot_built_entity`: 
- `on_robot_built_tile`: 
- `on_robot_exploded_cliff`: 
- `on_robot_mined`: 
- `on_robot_mined_entity`: 
- `on_robot_mined_tile`: 
- `on_robot_pre_mined`: 
- `on_rocket_launch_ordered`: 
- `on_rocket_launched`: 
- `on_runtime_mod_setting_changed`: 
- `on_script_inventory_resized`: 
- `on_script_path_request_finished`: 
- `on_script_trigger_effect`: 
- `on_sector_scanned`: 
- `on_segment_entity_created`: 
- `on_selected_entity_changed`: 
- `on_singleplayer_init`: 
- `on_space_platform_built_entity`: 
- `on_space_platform_built_tile`: 
- `on_space_platform_changed_state`: 
- `on_space_platform_mined_entity`: 
- `on_space_platform_mined_item`: 
- `on_space_platform_mined_tile`: 
- `on_space_platform_pre_mined`: 
- `on_spider_command_completed`: 
- `on_string_translated`: 
- `on_surface_cleared`: 
- `on_surface_created`: 
- `on_surface_deleted`: 
- `on_surface_imported`: 
- `on_surface_renamed`: 
- `on_technology_effects_reset`: 
- `on_tick`: 
- `on_train_changed_state`: 
- `on_train_created`: 
- `on_train_schedule_changed`: 
- `on_trigger_created_entity`: 
- `on_trigger_fired_artillery`: 
- `on_undo_applied`: 
- `on_unit_added_to_group`: 
- `on_unit_group_created`: 
- `on_unit_group_finished_gathering`: 
- `on_unit_removed_from_group`: 
- `on_worker_robot_expired`: 
- `script_raised_built`: 
- `script_raised_destroy`: 
- `script_raised_revive`: 
- `script_raised_set_tiles`: 
- `script_raised_teleported`: 

## flow_precision_index



**Values:**

- `fifty_hours`: 
- `five_seconds`: 
- `one_hour`: 
- `one_minute`: 
- `one_thousand_hours`: 
- `ten_hours`: 
- `ten_minutes`: 
- `two_hundred_fifty_hours`: 

## game_controller_interaction



**Values:**

- `always`: Game controller will always hover this element regardless of type or state.
- `never`: Never hover this element with a game controller.
- `normal`: Hover according to the element type and implementation.

## group_state



**Values:**

- `attacking_distraction`: 
- `attacking_target`: 
- `finished`: 
- `gathering`: 
- `moving`: 
- `pathfinding`: 
- `wander_in_group`: 

## gui_type



**Values:**

- `achievement`: 
- `blueprint_library`: 
- `bonus`: 
- `controller`: 
- `custom`: 
- `entity`: 
- `equipment`: 
- `global_electric_network`: 
- `item`: 
- `logistic`: 
- `none`: 
- `opened_entity_grid`: 
- `other_player`: 
- `permissions`: 
- `player_management`: 
- `production`: 
- `script_inventory`: 
- `server_management`: 
- `tile`: 
- `trains`: 

## input_action



**Values:**

- `activate_interrupt`: 
- `activate_paste`: 
- `add_decider_combinator_condition`: 
- `add_decider_combinator_output`: 
- `add_logistic_section`: 
- `add_permission_group`: 
- `add_pin`: 
- `add_train_interrupt`: 
- `add_train_station`: 
- `adjust_blueprint_snapping`: 
- `admin_action`: 
- `alt_reverse_select_area`: 
- `alt_select_area`: 
- `alt_select_blueprint_entities`: 
- `alternative_copy`: 
- `begin_mining`: 
- `begin_mining_terrain`: 
- `build`: 
- `build_rail`: 
- `build_terrain`: 
- `cancel_craft`: 
- `cancel_deconstruct`: 
- `cancel_delete_space_platform`: 
- `cancel_new_blueprint`: 
- `cancel_research`: 
- `cancel_upgrade`: 
- `change_active_character_tab`: 
- `change_active_item_group_for_crafting`: 
- `change_active_item_group_for_filters`: 
- `change_active_quick_bar`: 
- `change_arithmetic_combinator_parameters`: 
- `change_entity_label`: 
- `change_heading_riding_state`: 
- `change_item_label`: 
- `change_logistic_point_group`: 
- `change_multiplayer_config`: 
- `change_picking_state`: 
- `change_programmable_speaker_alert_parameters`: 
- `change_programmable_speaker_circuit_parameters`: 
- `change_programmable_speaker_parameters`: 
- `change_riding_state`: 
- `change_selector_combinator_parameters`: 
- `change_shooting_state`: 
- `change_train_name`: 
- `change_train_stop_station`: 
- `change_train_wait_condition`: 
- `change_train_wait_condition_data`: 
- `clear_cursor`: 
- `connect_rolling_stock`: 
- `copy`: 
- `copy_entity_settings`: 
- `copy_large_opened_blueprint`: 
- `copy_large_opened_item`: 
- `copy_opened_blueprint`: 
- `copy_opened_item`: 
- `craft`: 
- `create_space_platform`: 
- `cursor_split`: 
- `cursor_transfer`: 
- `custom_input`: 
- `cycle_blueprint_book_backwards`: 
- `cycle_blueprint_book_forwards`: 
- `cycle_quality_down`: 
- `cycle_quality_up`: 
- `deconstruct`: 
- `delete_blueprint_library`: 
- `delete_blueprint_record`: 
- `delete_custom_tag`: 
- `delete_logistic_group`: 
- `delete_permission_group`: 
- `delete_space_platform`: 
- `destroy_item`: 
- `destroy_opened_item`: 
- `disconnect_rolling_stock`: 
- `drag_decider_combinator_condition`: 
- `drag_decider_combinator_output`: 
- `drag_train_schedule`: 
- `drag_train_schedule_interrupt`: 
- `drag_train_wait_condition`: 
- `drop_blueprint_record`: 
- `drop_item`: 
- `edit_blueprint_tool_preview`: 
- `edit_custom_tag`: 
- `edit_display_panel`: 
- `edit_display_panel_always_show`: 
- `edit_display_panel_icon`: 
- `edit_display_panel_parameters`: 
- `edit_display_panel_show_in_chart`: 
- `edit_interrupt`: 
- `edit_permission_group`: 
- `edit_pin`: 
- `export_blueprint`: 
- `fast_entity_split`: 
- `fast_entity_transfer`: 
- `flip_entity`: 
- `flush_opened_entity_fluid`: 
- `flush_opened_entity_specific_fluid`: 
- `go_to_train_station`: 
- `grab_blueprint_record`: 
- `gui_checked_state_changed`: 
- `gui_click`: 
- `gui_confirmed`: 
- `gui_elem_changed`: 
- `gui_hover`: 
- `gui_leave`: 
- `gui_location_changed`: 
- `gui_selected_tab_changed`: 
- `gui_selection_state_changed`: 
- `gui_switch_state_changed`: 
- `gui_text_changed`: 
- `gui_value_changed`: 
- `import_blueprint`: 
- `import_blueprint_string`: 
- `import_blueprints_filtered`: 
- `import_permissions_string`: 
- `instantly_create_space_platform`: 
- `inventory_split`: 
- `inventory_transfer`: 
- `land_at_planet`: 
- `launch_rocket`: 
- `lua_shortcut`: 
- `map_editor_action`: 
- `market_offer`: 
- `mod_settings_changed`: 
- `modify_decider_combinator_condition`: 
- `modify_decider_combinator_output`: 
- `move_pin`: 
- `move_research`: 
- `open_achievements_gui`: 
- `open_blueprint_library_gui`: 
- `open_blueprint_record`: 
- `open_bonus_gui`: 
- `open_character_gui`: 
- `open_current_vehicle_gui`: 
- `open_equipment`: 
- `open_global_electric_network_gui`: 
- `open_gui`: 
- `open_item`: 
- `open_logistics_gui`: 
- `open_mod_item`: 
- `open_new_platform_button_from_rocket_silo`: 
- `open_opened_entity_grid`: 
- `open_parent_of_opened_item`: 
- `open_production_gui`: 
- `open_train_gui`: 
- `open_train_station_gui`: 
- `open_trains_gui`: 
- `parametrise_blueprint`: 
- `paste_entity_settings`: 
- `pin_alert_group`: 
- `pin_custom_alert`: 
- `pin_search_result`: 
- `pipette`: 
- `place_equipment`: 
- `quick_bar_pick_slot`: 
- `quick_bar_set_selected_page`: 
- `quick_bar_set_slot`: 
- `reassign_blueprint`: 
- `redo`: 
- `remote_view_entity`: 
- `remote_view_surface`: 
- `remove_cables`: 
- `remove_decider_combinator_condition`: 
- `remove_decider_combinator_output`: 
- `remove_logistic_section`: 
- `remove_pin`: 
- `remove_train_interrupt`: 
- `remove_train_station`: 
- `rename_interrupt`: 
- `rename_space_platform`: 
- `reorder_logistic_section`: 
- `request_missing_construction_materials`: 
- `reset_assembling_machine`: 
- `reverse_select_area`: 
- `rotate_entity`: 
- `select_area`: 
- `select_asteroid_chunk_slot`: 
- `select_blueprint_entities`: 
- `select_entity_filter_slot`: 
- `select_entity_slot`: 
- `select_item_filter`: 
- `select_mapper_slot_from`: 
- `select_mapper_slot_to`: 
- `select_next_valid_gun`: 
- `select_tile_slot`: 
- `send_spidertron`: 
- `send_stack_to_trash`: 
- `send_stacks_to_trash`: 
- `send_train_to_pin_target`: 
- `set_behavior_mode`: 
- `set_car_weapons_control`: 
- `set_cheat_mode_quality`: 
- `set_circuit_condition`: 
- `set_circuit_mode_of_operation`: 
- `set_combinator_description`: 
- `set_copy_color_from_train_stop`: 
- `set_deconstruction_item_tile_selection_mode`: 
- `set_deconstruction_item_trees_and_rocks_only`: 
- `set_entity_color`: 
- `set_entity_energy_property`: 
- `set_filter`: 
- `set_ghost_cursor`: 
- `set_heat_interface_mode`: 
- `set_heat_interface_temperature`: 
- `set_infinity_container_filter_item`: 
- `set_infinity_container_remove_unfiltered_items`: 
- `set_infinity_pipe_filter`: 
- `set_inserter_max_stack_size`: 
- `set_inventory_bar`: 
- `set_lamp_always_on`: 
- `set_linked_container_link_i_d`: 
- `set_loader_belt_stack_size_override`: 
- `set_logistic_filter_item`: 
- `set_logistic_network_name`: 
- `set_logistic_section_active`: 
- `set_player_color`: 
- `set_pump_fluid_filter`: 
- `set_request_from_buffers`: 
- `set_research_finished_stops_game`: 
- `set_rocket_silo_send_to_orbit_automated_mode`: 
- `set_schedule_record_allow_unloading`: 
- `set_signal`: 
- `set_splitter_priority`: 
- `set_spoil_priority`: 
- `set_train_stop_priority`: 
- `set_train_stopped`: 
- `set_trains_limit`: 
- `set_turret_ignore_unlisted`: 
- `set_use_inserter_filters`: 
- `set_vehicle_automatic_targeting_parameters`: 
- `setup_assembling_machine`: 
- `setup_blueprint`: 
- `setup_single_blueprint_record`: 
- `spawn_item`: 
- `spectator_change_surface`: 
- `stack_split`: 
- `stack_transfer`: 
- `start_repair`: 
- `start_research`: 
- `start_walking`: 
- `stop_drag_build`: 
- `swap_asteroid_chunk_slots`: 
- `swap_entity_filter_slots`: 
- `swap_entity_slots`: 
- `swap_infinity_container_filter_items`: 
- `swap_item_filters`: 
- `swap_logistic_filter_items`: 
- `swap_mappers`: 
- `swap_tile_slots`: 
- `switch_connect_to_logistic_network`: 
- `switch_constant_combinator_state`: 
- `switch_inserter_filter_mode_state`: 
- `switch_loader_filter_mode`: 
- `switch_mining_drill_filter_mode_state`: 
- `switch_power_switch_state`: 
- `take_equipment`: 
- `toggle_artillery_auto_targeting`: 
- `toggle_deconstruction_item_entity_filter_mode`: 
- `toggle_deconstruction_item_tile_filter_mode`: 
- `toggle_driving`: 
- `toggle_enable_vehicle_logistics_while_moving`: 
- `toggle_entity_logistic_requests`: 
- `toggle_equipment_movement_bonus`: 
- `toggle_map_editor`: 
- `toggle_personal_logistic_requests`: 
- `toggle_personal_roboport`: 
- `toggle_selected_entity`: 
- `toggle_show_entity_info`: 
- `translate_string`: 
- `trash_not_requested_items`: 
- `undo`: 
- `upgrade`: 
- `upgrade_opened_blueprint_by_item`: 
- `upgrade_opened_blueprint_by_record`: 
- `use_item`: 
- `wire_dragging`: 
- `write_to_console`: 

## input_method



**Values:**

- `game_controller`: 
- `keyboard_and_mouse`: 

## inventory



**Values:**

- `agricultural_tower_input`: 
- `agricultural_tower_output`: 
- `artillery_turret_ammo`: 
- `artillery_wagon_ammo`: 
- `assembling_machine_dump`: Used for ejected items, or items held by inserters that can't be inserted due the recipe being changed with the circuit network.
- `assembling_machine_input`: Deprecated, replaced by `"crafter_input"`.
- `assembling_machine_modules`: Deprecated, replaced by `"crafter_modules"`.
- `assembling_machine_output`: Deprecated, replaced by `"crafter_output"`.
- `assembling_machine_trash`: Deprecated, replaced by `"crafter_trash"`.
- `asteroid_collector_output`: 
- `beacon_modules`: 
- `burnt_result`: 
- `car_ammo`: 
- `car_trash`: 
- `car_trunk`: 
- `cargo_landing_pad_main`: 
- `cargo_landing_pad_trash`: 
- `cargo_unit`: 
- `cargo_wagon`: 
- `character_ammo`: 
- `character_armor`: 
- `character_corpse`: 
- `character_guns`: 
- `character_main`: 
- `character_trash`: 
- `character_vehicle`: 
- `chest`: 
- `crafter_input`: 
- `crafter_modules`: 
- `crafter_output`: 
- `crafter_trash`: Used for spoil result items that do not fit into the recipe slots, and for items that are ejected when changing the recipe via remote view.
- `editor_ammo`: 
- `editor_armor`: 
- `editor_guns`: 
- `editor_main`: 
- `fuel`: 
- `furnace_modules`: Deprecated, replaced by `"crafter_modules"`.
- `furnace_result`: Deprecated, replaced by `"crafter_output"`.
- `furnace_source`: Deprecated, replaced by `"crafter_input"`.
- `furnace_trash`: Deprecated, replaced by `"crafter_trash"`.
- `god_main`: 
- `hub_main`: 
- `hub_trash`: 
- `item_main`: 
- `lab_input`: 
- `lab_modules`: 
- `lab_trash`: 
- `linked_container_main`: 
- `logistic_container_trash`: 
- `mining_drill_modules`: 
- `proxy_main`: 
- `roboport_material`: 
- `roboport_robot`: 
- `robot_cargo`: 
- `robot_repair`: 
- `rocket_silo_input`: Deprecated, replaced by `"crafter_input"`.
- `rocket_silo_modules`: Deprecated, replaced by `"crafter_modules"`.
- `rocket_silo_output`: Deprecated, replaced by `"crafter_output"`.
- `rocket_silo_rocket`: 
- `rocket_silo_trash`: 
- `spider_ammo`: 
- `spider_trash`: 
- `spider_trunk`: 
- `turret_ammo`: 

## logistic_member_index



**Values:**

- `car_provider`: 
- `car_requester`: 
- `character_provider`: 
- `character_requester`: 
- `character_storage`: 
- `generic_on_off_behavior`: 
- `logistic_container`: 
- `logistic_container_trash_provider`: 
- `roboport_provider`: 
- `roboport_requester`: 
- `rocket_silo_provider`: 
- `rocket_silo_requester`: 
- `rocket_silo_trash_provider`: 
- `space_platform_hub_provider`: 
- `space_platform_hub_requester`: 
- `spidertron_provider`: 
- `spidertron_requester`: 
- `vehicle_storage`: 

## logistic_mode



**Values:**

- `active_provider`: 
- `buffer`: 
- `none`: 
- `passive_provider`: 
- `requester`: 
- `storage`: 

## logistic_section_type



**Values:**

- `circuit_controlled`: 
- `manual`: 
- `request_missing_materials_controlled`: Used by space platform hubs.
- `transitional_request_controlled`: Used by rocket silos.

## mouse_button_type



**Values:**

- `left`: 
- `middle`: 
- `none`: 
- `right`: 

## moving_state



**Values:**

- `adaptive`: 
- `moving`: 
- `stale`: 
- `stuck`: 

## print_skip



**Values:**

- `if_redundant`: Print will be skipped if same text was recently printed (within last 60 ticks). Used by most game messages.
- `if_visible`: Print will be skipped if same text is still visible (printed within last 1152 ticks). Used by some notifications.
- `never`: Print will not be skipped.

## print_sound



**Values:**

- `always`: 
- `never`: 
- `use_player_settings`: 

## prototypes

This define describes all top-level prototypes and their associated subtypes. It is organized as a lookup table, meaning the values of all the defines is `0`. As an example, `defines.prototypes['entity']` looks like `{furnace=0, inserter=0, container=0, ...}`.

## rail_connection_direction



**Values:**

- `left`: 
- `none`: 
- `right`: 
- `straight`: 

## rail_direction



**Values:**

- `back`: 
- `front`: 

## rail_layer



**Values:**

- `elevated`: 
- `ground`: 

## relative_gui_position



**Values:**

- `bottom`: 
- `left`: 
- `right`: 
- `top`: 

## relative_gui_type



**Values:**

- `accumulator_gui`: 
- `achievement_gui`: 
- `additional_entity_info_gui`: 
- `admin_gui`: 
- `agriculture_tower_gui`: 
- `arithmetic_combinator_gui`: 
- `armor_gui`: 
- `assembling_machine_gui`: 
- `assembling_machine_select_recipe_gui`: 
- `asteroid_collector_gui`: 
- `beacon_gui`: 
- `blueprint_book_gui`: 
- `blueprint_library_gui`: 
- `blueprint_setup_gui`: 
- `bonus_gui`: 
- `burner_equipment_gui`: 
- `car_gui`: 
- `cargo_landing_pad_gui`: 
- `constant_combinator_gui`: 
- `container_gui`: 
- `controller_gui`: 
- `decider_combinator_gui`: 
- `deconstruction_item_gui`: 
- `display_panel_gui`: 
- `electric_energy_interface_gui`: 
- `electric_network_gui`: 
- `entity_variations_gui`: 
- `entity_with_energy_source_gui`: 
- `equipment_grid_gui`: 
- `furnace_gui`: 
- `generic_on_off_entity_gui`: 
- `ghost_picker_gui`: 
- `global_electric_network_gui`: 
- `heat_interface_gui`: 
- `infinity_pipe_gui`: 
- `inserter_gui`: 
- `item_with_inventory_gui`: 
- `lab_gui`: 
- `lamp_gui`: 
- `linked_container_gui`: 
- `loader_gui`: 
- `logistic_gui`: 
- `market_gui`: 
- `mining_drill_gui`: 
- `other_player_gui`: 
- `permissions_gui`: 
- `pick_stop_gui`: 
- `pipe_gui`: 
- `power_switch_gui`: 
- `production_gui`: 
- `programmable_speaker_gui`: 
- `proxy_container_gui`: 
- `pump_gui`: 
- `rail_signal_base_gui`: 
- `reactor_gui`: 
- `resource_entity_gui`: 
- `roboport_gui`: 
- `rocket_silo_gui`: 
- `script_inventory_gui`: 
- `selector_combinator_gui`: 
- `server_config_gui`: 
- `space_platform_hub_gui`: 
- `spider_vehicle_gui`: 
- `splitter_gui`: 
- `standalone_character_gui`: 
- `storage_tank_gui`: 
- `tile_variations_gui`: 
- `tips_and_tricks_gui`: 
- `train_gui`: 
- `train_stop_gui`: 
- `trains_gui`: 
- `transport_belt_gui`: 
- `turret_gui`: 
- `upgrade_item_gui`: 
- `wall_gui`: 

## render_mode



**Values:**

- `chart`: 
- `chart_zoomed_in`: 
- `game`: 

## rich_text_setting



**Values:**

- `disabled`: 
- `enabled`: 
- `highlight`: 

## riding



## robot_order_type



**Values:**

- `construct`: Construct a ghost.
- `deconstruct`: Deconstruct an entity.
- `deliver`: Deliver an item.
- `deliver_items`: Deliver specific items to an entity (item request proxy).
- `explode_cliff`: Explode a cliff.
- `pickup`: Pickup an item.
- `pickup_items`: Pickup items from an entity (item request proxy).
- `repair`: Repair an entity.
- `upgrade`: Upgrade an entity.

## rocket_silo_status

The various parts of the launch sequence of the rocket silo.

**Values:**

- `arms_advance`: The next state is `rocket_ready` or if the rocket is destroyed in this state then the next state will be `lights_blinking_close`. The rocket is getting prepared for launch.
- `arms_retract`: The next state is `rocket_flying` or if the rocket is destroyed in this state then the next state will be `lights_blinking_close`. The rocket is getting launched.
- `building_rocket`: The rocket silo is crafting rocket parts. When there are enough rocket parts, the silo will switch into the `create_rocket` state.
- `create_rocket`: The next state is `lights_blinking_open`. The rocket silo rocket entity gets created.
- `doors_closing`: The next state is `building_rocket`.
- `doors_opened`: The next state is `rocket_rising` or if the rocket is destroyed in this state then the next state will be `lights_blinking_close`. The rocket is getting prepared for launch.
- `doors_opening`: The next state is `doors_opened`. The rocket is getting prepared for launch.
- `engine_starting`: The next state is `arms_retract` or if the rocket is destroyed in this state then the next state will be `lights_blinking_close`. The rocket is getting launched.
- `launch_started`: The next state is `engine_starting` or if the rocket is destroyed in this state then the next state will be `lights_blinking_close`. The rocket is getting launched.
- `launch_starting`: The next state is `launch_started`.
- `lights_blinking_close`: The next state is `doors_closing`.
- `lights_blinking_open`: The next state is `doors_opening`. The rocket is getting prepared for launch.
- `rocket_flying`: The next state is `lights_blinking_close`. The rocket is getting launched.
- `rocket_ready`: The rocket launch can be started by the player. When the launch is started, the silo switches into the `launch_starting` state.
- `rocket_rising`: The next state is `arms_advance` or if the rocket is destroyed in this state then the next state will be `lights_blinking_close`. The rocket is getting prepared for launch.

## selection_mode



**Values:**

- `alt_reverse_select`: 
- `alt_select`: 
- `reverse_select`: 
- `select`: 

## shooting



**Values:**

- `not_shooting`: 
- `shooting_enemies`: 
- `shooting_selected`: 

## signal_state

State of an ordinary rail signal.

**Values:**

- `closed`: Red.
- `open`: Green.
- `reserved`: Orange.
- `reserved_by_circuit_network`: Red - From circuit network.

## space_platform_state



**Values:**

- `no_path`: Doesn't have anywhere to go.
- `no_schedule`: Doesn't have any stations in schedule.
- `on_the_path`: Following the path.
- `paused`: Paused.
- `starter_pack_on_the_way`: Starter pack is on the way.
- `starter_pack_requested`: Starter pack was requested from the logistics system.
- `waiting_at_station`: Waiting at a station.
- `waiting_for_departure`: Platform is ready to leave this planet and does not accept deliveries.
- `waiting_for_starter_pack`: Waiting for a starter pack.

## target_type



**Values:**

- `cargo_hatch`: 
- `commandable`: 
- `custom_chart_tag`: 
- `entity`: 
- `equipment`: 
- `equipment_grid`: 
- `gui_element`: 
- `item`: 
- `logistic_cell`: 
- `logistic_network`: 
- `logistic_section`: 
- `permission_group`: 
- `planet`: 
- `player`: 
- `rail_path`: 
- `render_object`: 
- `schedule`: 
- `space_platform`: 
- `surface`: 
- `train`: 

## train_state



**Values:**

- `arrive_signal`: Braking before a rail signal.
- `arrive_station`: Braking before a station.
- `destination_full`: Same as no_path but all candidate train stops are full
- `manual_control`: Can move if user explicitly sits in and rides the train.
- `manual_control_stop`: Switched to manual control and has to stop.
- `no_path`: Has no path and is stopped.
- `no_schedule`: Doesn't have anywhere to go.
- `on_the_path`: Normal state -- following the path.
- `wait_signal`: Waiting at a signal.
- `wait_station`: Waiting at a station.

## transport_line



**Values:**

- `left_line`: 
- `left_split_line`: 
- `left_underground_line`: 
- `right_line`: 
- `right_split_line`: 
- `right_underground_line`: 
- `secondary_left_line`: 
- `secondary_left_split_line`: 
- `secondary_right_line`: 
- `secondary_right_split_line`: 

## wire_connector_id



**Values:**

- `circuit_green`: 
- `circuit_red`: 
- `combinator_input_green`: 
- `combinator_input_red`: 
- `combinator_output_green`: 
- `combinator_output_red`: 
- `pole_copper`: 
- `power_switch_left_copper`: 
- `power_switch_right_copper`: 

## wire_origin



**Values:**

- `player`: These wires can be modified by players, scripts, and the game. They are visible to the player if the entity's `draw_circuit_wires` prototype property is set to `true` and both ends of it are on the same surface.
- `radars`: These wires can only be modified by the game. They are not visible to the player, irrespective of the `draw_circuit_wires` prototype property.
- `script`: These wires can be modified by scripts and the game. They are not visible to the player, irrespective of the `draw_circuit_wires` prototype property.

## wire_type



**Values:**

- `copper`: 
- `green`: 
- `red`: 

