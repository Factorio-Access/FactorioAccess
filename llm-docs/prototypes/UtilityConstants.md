# UtilityConstants

Constants used by the game that are not specific to certain prototypes. See [utility-constants.lua](https://github.com/wube/factorio-data/blob/master/core/prototypes/utility-constants.lua) for the values used by the base game.

**Parent:** `PrototypeBase`

## Properties

### Mandatory Properties

#### agricultural_range_visualization_color

**Type:** `Color`



#### artillery_range_visualization_color

**Type:** `Color`



#### asteroid_collector_blockage_update_tile_distance

**Type:** `uint32`



#### asteroid_collector_max_nurbs_control_point_separation

**Type:** `double`



#### asteroid_collector_navmesh_refresh_tick_interval

**Type:** `uint32`



#### asteroid_collector_static_head_swing_segment_count

**Type:** `uint32`



#### asteroid_collector_static_head_swing_strength_scale

**Type:** `double`



#### asteroid_fading_range

**Type:** `float`



#### asteroid_position_offset_to_speed_coefficient

**Type:** `double`



#### asteroid_spawning_offset

**Type:** `SimpleBoundingBox`



#### asteroid_spawning_with_random_orientation_max_speed

**Type:** `double`



#### blueprint_big_slots_per_row

**Type:** `uint8`

Will be clamped to the range [2, 100].

#### blueprint_small_slots_per_row

**Type:** `uint8`

Will be clamped to the range [2, 100].

#### bonus_gui_ordering

**Type:** `BonusGuiOrdering`

The base game uses more entries here that are applied via the ammo-category.lua file.

#### building_buildable_tint

**Type:** `Color`



#### building_buildable_too_far_tint

**Type:** `Color`



#### building_collision_mask

**Type:** `CollisionMaskConnector`



#### building_ignorable_tint

**Type:** `Color`



#### building_no_tint

**Type:** `Color`



#### building_not_buildable_tint

**Type:** `Color`



#### capsule_range_visualization_color

**Type:** `Color`



#### capture_water_mask_at_layer

**Type:** `uint8`

Layer within `ground-natural` [tile render layer](prototype:TileRenderLayer) group, before which terrain lightmap alpha channel is copied into water mask. Decals, which need to be masked by water should have their [DecorativePrototype::tile_layer](prototype:DecorativePrototype::tile_layer) set to only slightly larger value than `capture_water_mask_at_layer`, to avoid risk of undefined behavior caused by rendering tiles into layers between `capture_water_mask_at_layer` and decal's `tile_layer`.

#### chart

**Type:** `ChartUtilityConstants`

Chart means map and minimap.

#### chart_search_highlight

**Type:** `Color`



#### checkerboard_black

**Type:** `Color`



#### checkerboard_white

**Type:** `Color`



#### clear_cursor_volume_modifier

**Type:** `float`



#### clipboard_history_size

**Type:** `uint32`



#### construction_robots_use_busy_robots_queue

**Type:** `boolean`



#### count_button_size

**Type:** `int32`



#### crafting_queue_slots_per_row

**Type:** `uint8`

Will be clamped to the range [1, 100].

#### daytime_color_lookup

**Type:** `DaytimeColorLookupTable`



#### deconstruct_mark_tint

**Type:** `Color`



#### default_alert_icon_scale

**Type:** `float`



#### default_collision_masks

**Type:** `dictionary<`string`, `CollisionMaskConnector`>`

The strings can be entity types or custom strings.

#### default_enemy_force_color

**Type:** `Color`



#### default_item_weight

**Type:** `Weight`



#### default_other_force_color

**Type:** `Color`



#### default_pipeline_extent

**Type:** `double`

The default value of [FluidBox::max_pipeline_extent](prototype:FluidBox::max_pipeline_extent).

#### default_planet_procession_set

**Type:** `ProcessionSet`

Must contain arrival and departure with [procession_style](prototype:ProcessionPrototype::procession_style) containing 0.

#### default_platform_procession_set

**Type:** `ProcessionSet`

Must contain arrival and departure with [procession_style](prototype:ProcessionPrototype::procession_style) containing 0.

#### default_player_force_color

**Type:** `Color`



#### default_scorch_mark_color

**Type:** `Color`



#### disabled_recipe_slot_background_tint

**Type:** `Color`



#### disabled_recipe_slot_tint

**Type:** `Color`



#### drop_item_radius

**Type:** `float`



#### dynamic_recipe_overload_factor

**Type:** `double`



#### ejected_item_direction_variation

**Type:** `double`

Silently clamped to be between 0 and 0.99.

#### ejected_item_friction

**Type:** `double`

Silently clamped to be between 0 and 1.

#### ejected_item_lifetime

**Type:** `MapTick`

Silently clamped to be between 1 tick and 5 minutes (`5 * 60 * 60` ticks).

#### ejected_item_speed

**Type:** `double`

Silently clamped to be between 0 and 1/60.

#### enabled_recipe_slot_tint

**Type:** `Color`



#### enemies_in_simulation_volume_modifier

**Type:** `float`



#### entity_button_background_color

**Type:** `Color`



#### entity_renderer_search_box_limits

**Type:** `EntityRendererSearchBoxLimits`



#### environment_sounds_transition_fade_in_ticks

**Type:** `uint32`



#### equipment_default_background_border_color

**Type:** `Color`



#### equipment_default_background_color

**Type:** `Color`



#### equipment_default_grabbed_background_color

**Type:** `Color`



#### explosions_in_simulation_volume_modifier

**Type:** `float`



#### factoriopedia_recycling_recipe_categories

**Type:** ``RecipeCategoryID`[]`



#### feedback_screenshot_file_name

**Type:** `string`



#### feedback_screenshot_subfolder_name

**Type:** `string`



#### filter_outline_color

**Type:** `Color`



#### flying_text_ttl

**Type:** `uint32`

Must be >= 1.

#### forced_enabled_recipe_slot_background_tint

**Type:** `Color`



#### freezing_temperature

**Type:** `double`



#### frozen_color_lookup

**Type:** `ColorLookupTable`



#### ghost_layer

**Type:** `CollisionLayerID`



#### ghost_shader_tint

**Type:** `GhostTintSet`



#### ghost_shaderless_tint

**Type:** `GhostTintSet`



#### ghost_shimmer_settings

**Type:** `GhostShimmerConfig`



#### gui_remark_color

**Type:** `Color`



#### gui_search_match_background_color

**Type:** `Color`



#### gui_search_match_foreground_color

**Type:** `Color`



#### huge_platform_animation_sound_area

**Type:** `float`



#### icon_shadow_color

**Type:** `Color`



#### icon_shadow_inset

**Type:** `float`



#### icon_shadow_radius

**Type:** `float`



#### icon_shadow_sharpness

**Type:** `float`



#### inserter_hand_stack_items_per_sprite

**Type:** `ItemCountType`

Must be >= 1.

#### inserter_hand_stack_max_sprites

**Type:** `ItemCountType`

Must be >= 1.

#### inventory_width

**Type:** `uint8`

Will be clamped to the range [1, 100].

#### item_ammo_magazine_left_bar_color

**Type:** `Color`



#### item_default_random_tint_strength

**Type:** `Color`



#### item_health_bar_colors

**Type:** ``ItemHealthColorData`[]`

There must be one array item with a threshold of `0`.

#### item_outline_color

**Type:** `Color`



#### item_outline_inset

**Type:** `float`



#### item_outline_radius

**Type:** `float`



#### item_outline_sharpness

**Type:** `float`



#### item_tool_durability_bar_color

**Type:** `Color`



#### landing_area_clear_zone_radius

**Type:** `float`

Radius of area where cargo pods won't land.

#### landing_area_max_radius

**Type:** `float`

Max radius where cargo pods will land.

#### large_area_size

**Type:** `float`



#### large_blueprint_area_size

**Type:** `float`



#### light_renderer_search_distance_limit

**Type:** `uint8`

Can be set to anything from range 0 to 255, but larger values will be clamped to 160. Setting it to larger values can have performance impact (growing geometrically).

#### lightning_attractor_collection_range_color

**Type:** `Color`



#### lightning_attractor_protection_range_color

**Type:** `Color`



#### logistic_gui_selected_network_highlight_tint

**Type:** `Color`



#### logistic_gui_unselected_network_highlight_tint

**Type:** `Color`



#### logistic_robots_use_busy_robots_queue

**Type:** `boolean`



#### logistic_slots_per_row

**Type:** `uint8`

Will be clamped to the range [2, 100].

#### low_energy_robot_estimate_multiplier

**Type:** `double`



#### main_menu_background_image_location

**Type:** `FileName`



#### main_menu_background_vignette_intensity

**Type:** `float`



#### main_menu_background_vignette_sharpness

**Type:** `float`



#### manual_rail_building_reach_modifier

**Type:** `double`



#### map_editor

**Type:** `MapEditorConstants`



#### max_belt_stack_size

**Type:** `uint8`

Must be >= 1.

#### max_fluid_flow

**Type:** `FluidAmount`



#### max_logistic_filter_count

**Type:** `LogisticFilterIndex`



#### max_terrain_building_size

**Type:** `uint8`



#### maximum_recipe_overload_multiplier

**Type:** `uint32`



#### medium_area_size

**Type:** `float`



#### medium_blueprint_area_size

**Type:** `float`



#### minimap_slot_clicked_tint

**Type:** `Color`



#### minimap_slot_hovered_tint

**Type:** `Color`



#### minimum_recipe_overload_multiplier

**Type:** `uint32`



#### missing_preview_sprite_location

**Type:** `FileName`



#### module_inventory_width

**Type:** `uint8`

Will be clamped to the range [1, 100].

#### moving_sound_count_reduction_rate

**Type:** `float`

Silently clamped to be between 0 and 1.

#### player_colors

**Type:** ``PlayerColorData`[]`

The table with `name = "default"` must exist and be the first member of the array.

#### probability_product_count_tint

**Type:** `Color`



#### rail_planner_count_button_color

**Type:** `Color`



#### rail_segment_colors

**Type:** ``Color`[]`



#### recipe_step_limit

**Type:** `uint32`



#### remote_view_LPF_max_cutoff_frequency

**Type:** `float`



#### remote_view_LPF_min_cutoff_frequency

**Type:** `float`



#### rocket_lift_weight

**Type:** `Weight`



#### script_command_console_chat_color

**Type:** `Color`



#### select_group_row_count

**Type:** `uint8`

Will be clamped to the range [1, 100].

#### select_slot_row_count

**Type:** `uint8`

Will be clamped to the range [1, 100].

#### selected_chart_search_highlight

**Type:** `Color`



#### server_command_console_chat_color

**Type:** `Color`



#### show_chunk_components_collision_mask

**Type:** `CollisionMaskConnector`



#### small_area_size

**Type:** `float`



#### small_blueprint_area_size

**Type:** `float`



#### space_LPF_max_cutoff_frequency

**Type:** `float`



#### space_LPF_min_cutoff_frequency

**Type:** `float`



#### space_platform_acceleration_expression

**Type:** `MathExpression`

Variables: speed, thrust, weight, width, height

#### space_platform_asteroid_chunk_trajectory_updates_per_tick

**Type:** `uint32`

How many asteroid chunks should be processed per tick, see [space_platform_max_relative_speed_deviation_for_asteroid_chunks_update](prototype:UtilityConstants::space_platform_max_relative_speed_deviation_for_asteroid_chunks_update).

#### space_platform_dump_cooldown

**Type:** `uint32`

Determines how fast space platforms will send items in drop slots to the surface. Each item type has its own cooldown.

#### space_platform_manual_dump_cooldown

**Type:** `uint32`

Delay after manual transfer until space platform sends items in drop slots to the surface. Overrides remaining space_platform_dump_cooldown in this instance.

#### space_platform_max_relative_speed_deviation_for_asteroid_chunks_update

**Type:** `float`

Space platform remembers relative speed range which asteroids use while it moves. When the range is larger than the specified deviation, the platform will start updating cached trajectories of all asteroid chunks over multiple ticks.

#### space_platform_max_size

**Type:** `SimpleBoundingBox`



#### space_platform_relative_speed_factor

**Type:** `double`



#### space_platform_starfield_movement_vector

**Type:** `Vector`



#### spawner_evolution_factor_health_modifier

**Type:** `float`



#### starmap_orbit_clicked_color

**Type:** `Color`



#### starmap_orbit_default_color

**Type:** `Color`



#### starmap_orbit_disabled_color

**Type:** `Color`



#### starmap_orbit_hovered_color

**Type:** `Color`



#### time_to_show_full_health_bar

**Type:** `MapTick`

The number of ticks to show a segmented unit's health bar after fully regenerating.

#### tooltip_monitor_edge_border

**Type:** `int32`

Must be >= 1.

#### train_inactivity_wait_condition_default

**Type:** `uint32`



#### train_on_elevated_rail_shadow_shift_multiplier

**Type:** `Vector`



#### train_path_finding

**Type:** `TrainPathFinderConstants`



#### train_pushed_by_player_ignores_friction

**Type:** `boolean`



#### train_pushed_by_player_max_acceleration

**Type:** `double`



#### train_pushed_by_player_max_speed

**Type:** `double`



#### train_temporary_stop_wait_time

**Type:** `uint32`



#### train_time_wait_condition_default

**Type:** `uint32`



#### train_visualization

**Type:** `TrainVisualizationConstants`



#### trash_inventory_width

**Type:** `uint8`

Will be clamped to the range [1, 100].

#### tree_leaf_distortion_distortion_far

**Type:** `Vector`



#### tree_leaf_distortion_distortion_near

**Type:** `Vector`



#### tree_leaf_distortion_speed_far

**Type:** `Vector`



#### tree_leaf_distortion_speed_near

**Type:** `Vector`



#### tree_leaf_distortion_strength_far

**Type:** `Vector`



#### tree_leaf_distortion_strength_near

**Type:** `Vector`



#### tree_shadow_roughness

**Type:** `float`



#### tree_shadow_speed

**Type:** `float`



#### turret_range_visualization_color

**Type:** `Color`



#### underground_belt_max_distance_tint

**Type:** `Color`



#### underground_pipe_max_distance_tint

**Type:** `Color`



#### unit_group_max_pursue_distance

**Type:** `double`



#### unit_group_pathfind_resolution

**Type:** `int8`



#### walking_sound_count_reduction_rate

**Type:** `float`

Silently clamped to be between 0 and 1.

#### water_collision_mask

**Type:** `CollisionMaskConnector`



#### weapons_in_simulation_volume_modifier

**Type:** `float`



#### zero_count_value_tint

**Type:** `Color`



#### zoom_to_world_can_use_nightvision

**Type:** `boolean`



#### zoom_to_world_daytime_color_lookup

**Type:** `DaytimeColorLookupTable`



#### zoom_to_world_effect_strength

**Type:** `float`



### Optional Properties

#### color_filters

**Type:** ``ColorFilterData`[]`



#### default_alert_icon_scale_by_type

**Type:** `dictionary<`string`, `float`>`



#### default_alert_icon_shift_by_type

**Type:** `dictionary<`string`, `Vector`>`



#### default_trigger_target_mask_by_type

**Type:** `dictionary<`string`, `TriggerTargetMask`>`

The strings are entity types.

#### main_menu_simulations

**Type:** `dictionary<`string`, `SimulationDefinition`>`

The strings represent the names of the simulations.

