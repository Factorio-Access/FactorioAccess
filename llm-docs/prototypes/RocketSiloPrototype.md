# RocketSiloPrototype

A [rocket silo](https://wiki.factorio.com/Rocket_silo).

**Parent:** `AssemblingMachinePrototype`

## Properties

### Mandatory Properties

#### active_energy_usage

**Type:** `Energy`

Additional energy used during the following parts of the [launch sequence](runtime:defines.rocket_silo_status): doors_opening, rocket_rising, arms_advance, engine_starting, arms_retract, doors_closing.

#### cargo_station_parameters

**Type:** `CargoStationParameters`

Must have exactly one entry in [CargoStationParameters::hatch_definitions](prototype:CargoStationParameters::hatch_definitions).

#### door_back_open_offset

**Type:** `Vector`



#### door_front_open_offset

**Type:** `Vector`



#### door_opening_speed

**Type:** `double`

The inverse of the duration in ticks of [doors_opening](runtime:defines.rocket_silo_status.doors_opening) and [closing](runtime:defines.rocket_silo_status.doors_closing).

#### hole_clipping_box

**Type:** `BoundingBox`



#### lamp_energy_usage

**Type:** `Energy`

May be 0.

Additional energy used during the night, that is when [LuaSurface::darkness](runtime:LuaSurface::darkness) is larger than 0.3.

#### light_blinking_speed

**Type:** `double`

The inverse of the duration in ticks of [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) and [lights_blinking_close](runtime:defines.rocket_silo_status.lights_blinking_close).

#### rocket_entity

**Type:** `EntityID`

Name of a [RocketSiloRocketPrototype](prototype:RocketSiloRocketPrototype).

#### rocket_parts_required

**Type:** `uint32`

The number of crafts that must complete to produce a rocket. This includes bonus crafts from productivity. Recipe products are ignored.

#### rocket_quick_relaunch_start_offset

**Type:** `double`



#### silo_fade_out_end_distance

**Type:** `double`



#### silo_fade_out_start_distance

**Type:** `double`



#### times_to_blink

**Type:** `uint8`

How many times the `red_lights_back_sprites` and `red_lights_front_sprites` should blink during [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) and [lights_blinking_close](runtime:defines.rocket_silo_status.lights_blinking_close).

Does not affect the duration of the launch sequence.

### Optional Properties

#### alarm_sound

**Type:** `Sound`

Played when switching into the [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) state.

#### alarm_trigger

**Type:** `TriggerEffect`

Applied when switching into the [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) state.

#### arm_01_back_animation

**Type:** `Animation`



#### arm_02_right_animation

**Type:** `Animation`



#### arm_03_front_animation

**Type:** `Animation`



#### base_day_sprite

**Type:** `Sprite`



#### base_engine_light

**Type:** `LightDefinition`



#### base_front_frozen

**Type:** `Sprite`



#### base_front_sprite

**Type:** `Sprite`



#### base_frozen

**Type:** `Sprite`



#### base_light

**Type:** `LightDefinition`



#### base_night_sprite

**Type:** `Sprite`

Drawn instead of `base_day_sprite` during the night, that is when [LuaSurface::darkness](runtime:LuaSurface::darkness) is larger than 0.3.

#### can_launch_without_landing_pads

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### clamps_off_sound

**Type:** `Sound`

Played when switching into the [arms_retract](runtime:defines.rocket_silo_status.arms_retract) state.

#### clamps_off_trigger

**Type:** `TriggerEffect`

Applied when switching into the [arms_retract](runtime:defines.rocket_silo_status.arms_retract) state.

#### clamps_on_sound

**Type:** `Sound`

Played when switching into the [arms_advance](runtime:defines.rocket_silo_status.arms_advance) state.

#### clamps_on_trigger

**Type:** `TriggerEffect`

Applied when switching into the [arms_advance](runtime:defines.rocket_silo_status.arms_advance) state.

#### door_back_frozen

**Type:** `Sprite`



#### door_back_sprite

**Type:** `Sprite`



#### door_front_frozen

**Type:** `Sprite`



#### door_front_sprite

**Type:** `Sprite`



#### doors_sound

**Type:** `Sound`

Played when switching into the [doors_opening](runtime:defines.rocket_silo_status.doors_opening) and [doors_closing](runtime:defines.rocket_silo_status.doors_closing) states.

#### doors_trigger

**Type:** `TriggerEffect`

Applied when switching into the [doors_opening](runtime:defines.rocket_silo_status.doors_opening) and [doors_closing](runtime:defines.rocket_silo_status.doors_closing) states.

#### hole_frozen

**Type:** `Sprite`



#### hole_light_sprite

**Type:** `Sprite`



#### hole_sprite

**Type:** `Sprite`



#### launch_to_space_platforms

**Type:** `boolean`

Enables 'Space Age' functionality for this rocket silo, allowing it to supply space platforms.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### launch_wait_time

**Type:** `uint8`

The time to wait in the [launch_started](runtime:defines.rocket_silo_status.launch_started) state before switching to [engine_starting](runtime:defines.rocket_silo_status.engine_starting).

**Default:** `{'complex_type': 'literal', 'value': 120}`

#### logistic_trash_inventory_size

**Type:** `ItemStackIndex`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### quick_alarm_sound

**Type:** `Sound`

Played when switching from [rocket_flying](runtime:defines.rocket_silo_status.rocket_flying) into the [doors_opened](runtime:defines.rocket_silo_status.doors_opened) state when a quick follow-up rocket is ready.

#### raise_rocket_sound

**Type:** `Sound`

Played when switching into the [rocket_rising](runtime:defines.rocket_silo_status.rocket_rising) state.

#### raise_rocket_trigger

**Type:** `TriggerEffect`

Applied when switching into the [rocket_rising](runtime:defines.rocket_silo_status.rocket_rising) state.

#### red_lights_back_sprites

**Type:** `Sprite`

Drawn from the start of the [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) state until the end of the [lights_blinking_close](runtime:defines.rocket_silo_status.lights_blinking_close) state.

#### red_lights_front_sprites

**Type:** `Sprite`

Drawn from the start of the [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) state until the end of the [lights_blinking_close](runtime:defines.rocket_silo_status.lights_blinking_close) state.

#### render_not_in_network_icon

**Type:** `boolean`

Whether the "no network" icon should be rendered on this entity if the entity is not within a logistics network.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### rocket_glow_overlay_sprite

**Type:** `Sprite`



#### rocket_parts_storage_cap

**Type:** `uint32`

Must be at least `rocket_parts_required`.

**Default:** `Value of `rocket_parts_required``

#### rocket_rising_delay

**Type:** `uint8`

The time to wait in the [doors_opened](runtime:defines.rocket_silo_status.doors_opened) state before switching to [rocket_rising](runtime:defines.rocket_silo_status.rocket_rising).

**Default:** `{'complex_type': 'literal', 'value': 30}`

#### rocket_shadow_overlay_sprite

**Type:** `Sprite`



#### satellite_animation

**Type:** `Animation`



#### satellite_shadow_animation

**Type:** `Animation`



#### shadow_sprite

**Type:** `Sprite`



#### to_be_inserted_to_rocket_inventory_size

**Type:** `ItemStackIndex`



**Default:** `{'complex_type': 'literal', 'value': 0}`

