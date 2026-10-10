# UtilityConstants

Constants used by the game that are not specific to certain prototypes. See [utility-constants.lua](https://github.com/wube/factorio-data/blob/master/core/prototypes/utility-constants.lua) for the values used by the base game.

Note that this is actually implemented as a [LuaCustomTable](runtime:LuaCustomTable), not a regular table.

**Type:** Table

## Parameters

### agricultural_range_visualization_color

**Type:** `Color`

**Required:** Yes

### artillery_range_visualization_color

**Type:** `Color`

**Required:** Yes

### asteroid_collector_blockage_update_tile_distance

**Type:** `uint32`

**Required:** Yes

### asteroid_collector_max_nurbs_control_point_separation

**Type:** `double`

**Required:** Yes

### asteroid_collector_navmesh_refresh_tick_interval

**Type:** `uint32`

**Required:** Yes

### asteroid_collector_static_head_swing_segment_count

**Type:** `uint32`

**Required:** Yes

### asteroid_collector_static_head_swing_strength_scale

**Type:** `float`

**Required:** Yes

### asteroid_fading_range

**Type:** `float`

**Required:** Yes

### asteroid_min_damage_modifier

Asteroid damage will be multiplied by this value when space platform speed is zero and will linearly increase until asteroid_spawning_with_random_orientation_max_speed is reached.

**Type:** `float`

**Required:** Yes

### asteroid_position_offset_to_speed_coefficient

**Type:** `double`

**Required:** Yes

### asteroid_spawning_offset

**Type:** `SimpleBoundingBox`

**Required:** Yes

### asteroid_spawning_with_random_orientation_max_speed

In km per tick.

**Type:** `double`

**Required:** Yes

### blueprint_big_slots_per_row

Will be clamped to the range [2, 100].

**Type:** `uint8`

**Required:** Yes

### blueprint_small_slots_per_row

Will be clamped to the range [2, 100].

**Type:** `uint8`

**Required:** Yes

### bonus_gui_ordering

The base game uses more entries here that are applied via the `ammo-category.lua` file.

**Type:** `BonusUtilityConstants`

**Required:** Yes

### building_buildable_tint

**Type:** `Color`

**Required:** Yes

### building_buildable_too_far_tint

**Type:** `Color`

**Required:** Yes

### building_collision_mask

**Type:** `CollisionMask`

**Required:** Yes

### building_ignorable_tint

**Type:** `Color`

**Required:** Yes

### building_no_tint

**Type:** `Color`

**Required:** Yes

### building_not_buildable_tint

**Type:** `Color`

**Required:** Yes

### capsule_range_visualization_color

**Type:** `Color`

**Required:** Yes

### capture_water_mask_at_layer

Layer within `ground-natural` [tile render layer](prototype:TileRenderLayer) group, before which terrain lightmap alpha channel is copied into water mask. Decals, which need to be masked by water should have their [DecorativePrototype::tile_layer](prototype:DecorativePrototype::tile_layer) set to only slightly larger value than `capture_water_mask_at_layer`, to avoid risk of undefined behavior caused by rendering tiles into layers between `capture_water_mask_at_layer` and decal's `tile_layer`.

**Type:** `uint8`

**Required:** Yes

### chart

Chart means map and minimap.

**Type:** `ChartUtilityConstants`

**Required:** Yes

### chart_search_highlight

**Type:** `Color`

**Required:** Yes

### checkerboard_black

**Type:** `Color`

**Required:** Yes

### checkerboard_white

**Type:** `Color`

**Required:** Yes

### clear_cursor_volume_modifier

**Type:** `float`

**Required:** Yes

### clipboard_history_size

**Type:** `uint32`

**Required:** Yes

### color_filters

**Type:** Array[`ColorFilterData`]

**Optional:** Yes

### construction_robots_use_busy_robots_queue

**Type:** `boolean`

**Required:** Yes

### count_button_size

**Type:** `int32`

**Required:** Yes

### crafting_queue_slots_per_row

Will be clamped to the range [1, 100].

**Type:** `uint8`

**Required:** Yes

### daytime_color_lookup

**Type:** `DaytimeColorLookupTable`

**Required:** Yes

### deconstruct_mark_tint

**Type:** `Color`

**Required:** Yes

### default_alert_icon_scale

**Type:** `float`

**Required:** Yes

### default_alert_icon_scale_by_type

**Type:** Dictionary[`string`, `float`]

**Optional:** Yes

### default_alert_icon_shift_by_type

**Type:** Dictionary[`string`, `Vector`]

**Optional:** Yes

### default_collision_masks

The strings can be entity types or custom strings.

**Type:** Dictionary[`string`, `CollisionMask`]

**Required:** Yes

### default_enemy_force_color

**Type:** `Color`

**Required:** Yes

### default_item_weight

**Type:** `Weight`

**Required:** Yes

### default_other_force_color

**Type:** `Color`

**Required:** Yes

### default_pipeline_extent

The default value of [FluidBox::max_pipeline_extent](prototype:FluidBox::max_pipeline_extent).

**Type:** `double`

**Required:** Yes

### default_planet_procession_set

Must contain arrival and departure with [procession_style](prototype:ProcessionPrototype::procession_style) containing 0.

**Type:** `ProcessionSet`

**Required:** Yes

### default_platform_procession_set

Must contain arrival and departure with [procession_style](prototype:ProcessionPrototype::procession_style) containing 0.

**Type:** `ProcessionSet`

**Required:** Yes

### default_platform_surface_render_parameters

**Type:** `SurfaceRenderParameters`

**Required:** Yes

### default_player_force_color

**Type:** `Color`

**Required:** Yes

### default_rocket_lift_weight

Used for "Rocket capacity" item tooltip and for comparing rocket silo lift weight in GUI to this value.

**Type:** `Weight`

**Required:** Yes

### default_scorch_mark_color

**Type:** `Color`

**Required:** Yes

### default_trigger_target_mask_by_type

The strings are entity types.

**Type:** Dictionary[`string`, `TriggerTargetMask`]

**Optional:** Yes

### disabled_recipe_slot_background_tint

**Type:** `Color`

**Required:** Yes

### disabled_recipe_slot_tint

**Type:** `Color`

**Required:** Yes

### drop_item_radius

**Type:** `double`

**Required:** Yes

### dynamic_recipe_overload_factor

**Type:** `double`

**Required:** Yes

### ejected_item_direction_variation

Silently clamped to be between 0 and 0.99.

**Type:** `double`

**Required:** Yes

### ejected_item_friction

Silently clamped to be between 0 and 1.

**Type:** `double`

**Required:** Yes

### ejected_item_lifetime

Silently clamped to be between 1 tick and 5 minutes (`5 * 60 * 60` ticks).

**Type:** `MapTick`

**Required:** Yes

### ejected_item_speed

Silently clamped to be between 0 and 1/60.

**Type:** `double`

**Required:** Yes

### enabled_recipe_slot_tint

**Type:** `Color`

**Required:** Yes

### enemies_in_simulation_volume_modifier

**Type:** `float`

**Required:** Yes

### entity_button_background_color

**Type:** `Color`

**Required:** Yes

### entity_renderer_search_box_limits

**Type:** `EntityRendererSearchBoxLimits`

**Required:** Yes

### environment_sounds_transition_fade_in_ticks

**Type:** `uint32`

**Required:** Yes

### equipment_default_background_border_color

**Type:** `Color`

**Required:** Yes

### equipment_default_background_color

**Type:** `Color`

**Required:** Yes

### equipment_default_grabbed_background_color

**Type:** `Color`

**Required:** Yes

### equipment_disabled_background_tint

**Type:** `Color`

**Required:** Yes

### equipment_disabled_tint

**Type:** `Color`

**Required:** Yes

### explosions_in_simulation_volume_modifier

**Type:** `float`

**Required:** Yes

### factoriopedia_recycling_recipe_categories

**Type:** Array[`RecipeCategoryID`]

**Required:** Yes

### far_away_chunk_generation_radius

**Type:** `uint8`

**Required:** Yes

### feedback_screenshot_file_name

**Type:** `string`

**Required:** Yes

### feedback_screenshot_subfolder_name

**Type:** `string`

**Required:** Yes

### filter_outline_color

**Type:** `Color`

**Required:** Yes

### flying_text_ttl

Must be >= 1.

**Type:** `int32`

**Required:** Yes

### forced_enabled_recipe_slot_background_tint

**Type:** `Color`

**Required:** Yes

### freezing_temperature

Will be clamped to a positive number, starting at 0.

**Type:** `double`

**Required:** Yes

### frozen_color_lookup

**Type:** `ColorLookupTable`

**Required:** Yes

### ghost_layer

**Type:** `CollisionLayerID`

**Required:** Yes

### ghost_product_count_tint

**Type:** `Color`

**Required:** Yes

### ghost_shader_tint

**Type:** `GhostTintSet`

**Required:** Yes

### ghost_shaderless_tint

**Type:** `GhostTintSet`

**Required:** Yes

### ghost_shimmer_settings

**Type:** `GhostShimmerConfig`

**Required:** Yes

### gui_remark_color

**Type:** `Color`

**Required:** Yes

### gui_search_match_background_color

**Type:** `Color`

**Required:** Yes

### gui_search_match_foreground_color

**Type:** `Color`

**Required:** Yes

### huge_area_size

**Type:** `float`

**Required:** Yes

### huge_platform_animation_sound_area

**Type:** `float`

**Required:** Yes

### icon_shadow_color

**Type:** `Color`

**Required:** Yes

### icon_shadow_inset

**Type:** `float`

**Required:** Yes

### icon_shadow_radius

**Type:** `float`

**Required:** Yes

### icon_shadow_sharpness

**Type:** `float`

**Required:** Yes

### inserter_hand_stack_items_per_sprite

Must be >= 1.

**Type:** `ItemCountType`

**Required:** Yes

### inserter_hand_stack_max_sprites

Must be >= 1.

**Type:** `ItemCountType`

**Required:** Yes

### inventory_width

Will be clamped to the range [1, 100].

**Type:** `uint8`

**Required:** Yes

### item_ammo_magazine_left_bar_color

**Type:** `Color`

**Required:** Yes

### item_default_random_tint_strength

**Type:** `Color`

**Required:** Yes

### item_health_bar_colors

There must be one array item with a threshold of `0`.

**Type:** Array[`ItemHealthColorData`]

**Required:** Yes

### item_outline_color

**Type:** `Color`

**Required:** Yes

### item_outline_inset

**Type:** `float`

**Required:** Yes

### item_outline_radius

**Type:** `float`

**Required:** Yes

### item_outline_sharpness

**Type:** `float`

**Required:** Yes

### item_tool_durability_bar_color

**Type:** `Color`

**Required:** Yes

### landing_area_clear_zone_radius

Radius of area where cargo pods won't land.

**Type:** `float`

**Required:** Yes

### landing_area_max_radius

Max radius where cargo pods will land.

**Type:** `float`

**Required:** Yes

### landing_squash_immunity

**Type:** `MapTick`

**Required:** Yes

### large_area_size

**Type:** `float`

**Required:** Yes

### large_blueprint_area_size

**Type:** `float`

**Required:** Yes

### light_renderer_search_distance_limit

Can be set to anything from range 0 to 255, but larger values will be clamped to 160. Setting it to larger values can have performance impact (growing geometrically).

**Type:** `uint8`

**Required:** Yes

### lightning_attractor_collection_range_color

**Type:** `Color`

**Required:** Yes

### lightning_attractor_protection_range_color

**Type:** `Color`

**Required:** Yes

### logistic_gui_selected_network_highlight_tint

**Type:** `Color`

**Required:** Yes

### logistic_gui_unselected_network_highlight_tint

**Type:** `Color`

**Required:** Yes

### logistic_robots_use_busy_robots_queue

**Type:** `boolean`

**Required:** Yes

### logistic_slots_per_row

Will be clamped to the range [2, 100].

**Type:** `uint8`

**Required:** Yes

### low_energy_robot_estimate_multiplier

**Type:** `double`

**Required:** Yes

### main_menu_background_image_location

**Type:** `string`

**Required:** Yes

### main_menu_background_vignette_intensity

**Type:** `float`

**Required:** Yes

### main_menu_background_vignette_sharpness

**Type:** `float`

**Required:** Yes

### main_menu_simulations

The strings represent the names of the simulations.

**Type:** Dictionary[`string`, `SimulationDefinition`]

**Optional:** Yes

### manual_rail_building_reach_modifier

**Type:** `double`

**Required:** Yes

### map_editor

**Type:** `EditorUtilityConstants`

**Required:** Yes

### max_belt_stack_size

Must be >= 1.

**Type:** `uint8`

**Required:** Yes

### max_logistic_filter_count

**Type:** `LogisticFilterIndex`

**Required:** Yes

### max_terrain_building_size

**Type:** `uint8`

**Required:** Yes

### maximum_quality_jump

Cap for how many steps of quality the output of something (miner/crafter) may be higher than the input (resource/ingredients). Must be >= 1.

**Type:** `uint8`

**Required:** Yes

### maximum_recipe_overload_multiplier

**Type:** `uint32`

**Required:** Yes

### medium_area_size

**Type:** `float`

**Required:** Yes

### medium_blueprint_area_size

**Type:** `float`

**Required:** Yes

### merge_bonus_gui_production_bonuses

If not set, defaults to `true` when modded and `false` when vanilla.

**Type:** `boolean`

**Optional:** Yes

### minimum_recipe_overload_multiplier

**Type:** `uint32`

**Required:** Yes

### missing_preview_sprite_location

**Type:** `string`

**Required:** Yes

### module_inventory_width

Will be clamped to the range [1, 100].

**Type:** `uint8`

**Required:** Yes

### moving_sound_count_reduction_rate

Silently clamped to be between 0 and 1.

**Type:** `float`

**Required:** Yes

### player_colors

The table with `name = "default"` must exist and be the first member of the array.

**Type:** Array[`PlayerColorData`]

**Required:** Yes

### probability_product_count_tint

**Type:** `Color`

**Required:** Yes

### quality_selector_dropdown_threshold

**Type:** `uint8`

**Required:** Yes

### rail_planner_count_button_color

**Type:** `Color`

**Required:** Yes

### rail_segment_colors

**Type:** Array[`Color`]

**Required:** Yes

### recipe_step_limit

**Type:** `uint32`

**Required:** Yes

### remote_view_LPF_max_cutoff_frequency

**Type:** `float`

**Required:** Yes

### remote_view_LPF_min_cutoff_frequency

**Type:** `float`

**Required:** Yes

### script_command_console_chat_color

**Type:** `Color`

**Required:** Yes

### select_group_row_count

Will be clamped to the range [1, 100].

**Type:** `uint8`

**Required:** Yes

### select_slot_row_count

Will be clamped to the range [1, 100].

**Type:** `uint8`

**Required:** Yes

### selected_chart_search_highlight

**Type:** `Color`

**Required:** Yes

### server_command_console_chat_color

**Type:** `Color`

**Required:** Yes

### show_chunk_components_collision_mask

**Type:** `CollisionMask`

**Required:** Yes

### small_area_size

**Type:** `float`

**Required:** Yes

### small_blueprint_area_size

**Type:** `float`

**Required:** Yes

### sound_fade_ticks

**Type:** `uint32`

**Required:** Yes

### space_LPF_max_cutoff_frequency

**Type:** `float`

**Required:** Yes

### space_LPF_min_cutoff_frequency

**Type:** `float`

**Required:** Yes

### space_platform_acceleration_expression

Variables: `speed, thrust, weight, width, height`

**Type:** `MathExpression`

**Required:** Yes

### space_platform_asteroid_chunk_trajectory_updates_per_tick

How many asteroid chunks should be processed per tick, see [space_platform_max_relative_speed_deviation_for_asteroid_chunks_update](prototype:UtilityConstants::space_platform_max_relative_speed_deviation_for_asteroid_chunks_update).

**Type:** `uint32`

**Required:** Yes

### space_platform_dump_cooldown

Determines how fast space platforms will send items in drop slots to the surface. Each item type has its own cooldown.

**Type:** `uint32`

**Required:** Yes

### space_platform_manual_dump_cooldown

Delay after manual transfer until space platform sends items in drop slots to the surface. Overrides remaining space_platform_dump_cooldown in this instance.

**Type:** `uint32`

**Required:** Yes

### space_platform_max_relative_speed_deviation_for_asteroid_chunks_update

Space platform remembers relative speed range which asteroids use while it moves. When the range is larger than the specified deviation, the platform will start updating cached trajectories of all asteroid chunks over multiple ticks.

**Type:** `float`

**Required:** Yes

### space_platform_max_size

**Type:** `SimpleBoundingBox`

**Required:** Yes

### space_platform_relative_speed_factor

**Type:** `double`

**Required:** Yes

### space_platform_starfield_movement_vector

**Type:** `Vector`

**Required:** Yes

### spawner_evolution_factor_health_modifier

**Type:** `float`

**Required:** Yes

### starmap_orbit_clicked_color

**Type:** `Color`

**Required:** Yes

### starmap_orbit_default_color

**Type:** `Color`

**Required:** Yes

### starmap_orbit_disabled_color

**Type:** `Color`

**Required:** Yes

### starmap_orbit_hovered_color

**Type:** `Color`

**Required:** Yes

### tall_entity_smoke_tint

All trivial smoke will be tinted with this value when "Hide tall entities" mode is active.

**Type:** `Color`

**Required:** Yes

### tall_entity_tint

Tall entities will be tinted with this value when "Hide tall entities" mode is active.

**Type:** `Color`

**Required:** Yes

### time_to_show_full_health_bar

The number of ticks to show a segmented unit's health bar after fully regenerating.

**Type:** `MapTick`

**Required:** Yes

### tooltip_monitor_edge_border

Must be >= 1.

**Type:** `int32`

**Required:** Yes

### train_inactivity_wait_condition_default

**Type:** `uint32`

**Required:** Yes

### train_on_elevated_rail_shadow_shift_multiplier

**Type:** `Vector`

**Required:** Yes

### train_path_finding

**Type:** `TrainPathFinderConstants`

**Required:** Yes

### train_pushed_by_player_ignores_friction

**Type:** `boolean`

**Required:** Yes

### train_pushed_by_player_max_acceleration

**Type:** `double`

**Required:** Yes

### train_pushed_by_player_max_speed

**Type:** `double`

**Required:** Yes

### train_temporary_stop_wait_time

**Type:** `uint32`

**Required:** Yes

### train_time_wait_condition_default

**Type:** `uint32`

**Required:** Yes

### train_visualization

**Type:** `TrainVisualizationConstants`

**Required:** Yes

### trash_inventory_width

Will be clamped to the range [1, 100].

**Type:** `uint8`

**Required:** Yes

### tree_leaf_distortion_distortion_far

**Type:** `Vector`

**Required:** Yes

### tree_leaf_distortion_distortion_near

**Type:** `Vector`

**Required:** Yes

### tree_leaf_distortion_speed_far

**Type:** `Vector`

**Required:** Yes

### tree_leaf_distortion_speed_near

**Type:** `Vector`

**Required:** Yes

### tree_leaf_distortion_strength_far

**Type:** `Vector`

**Required:** Yes

### tree_leaf_distortion_strength_near

**Type:** `Vector`

**Required:** Yes

### tree_shadow_roughness

**Type:** `float`

**Required:** Yes

### tree_shadow_speed

**Type:** `float`

**Required:** Yes

### turret_range_visualization_color

**Type:** `Color`

**Required:** Yes

### underground_belt_max_distance_tint

**Type:** `Color`

**Required:** Yes

### underground_pipe_max_distance_tint

**Type:** `Color`

**Required:** Yes

### unit_group_max_pursue_distance

**Type:** `double`

**Required:** Yes

### unit_group_pathfind_resolution

**Type:** `int8`

**Required:** Yes

### walking_sound_count_reduction_rate

Silently clamped to be between 0 and 1.

**Type:** `float`

**Required:** Yes

### water_collision_mask

**Type:** `TileCollisionMask`

**Required:** Yes

### weapons_in_simulation_volume_modifier

**Type:** `float`

**Required:** Yes

### zero_count_value_tint

**Type:** `Color`

**Required:** Yes

