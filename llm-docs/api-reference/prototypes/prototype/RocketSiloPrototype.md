# RocketSiloPrototype

A [rocket silo](https://wiki.factorio.com/Rocket_silo).

**Parent:** [AssemblingMachinePrototype](AssemblingMachinePrototype.md)
**Type name:** `rocket-silo`

## Properties

### active_energy_usage

Additional energy used during the following parts of the [launch sequence](runtime:defines.rocket_silo_status): doors_opening, rocket_rising, arms_advance, engine_starting, arms_retract, doors_closing.

**Type:** `Energy`

**Required:** Yes

### lamp_energy_usage

May be 0.

Additional energy used during the night, that is when [LuaSurface::darkness](runtime:LuaSurface::darkness) is larger than 0.3.

**Type:** `Energy`

**Required:** Yes

### rocket_entity

Name of a [RocketSiloRocketPrototype](prototype:RocketSiloRocketPrototype).

**Type:** `EntityID`

**Required:** Yes

### arm_02_right_animation

**Type:** `Animation`

**Optional:** Yes

### arm_01_back_animation

**Type:** `Animation`

**Optional:** Yes

### arm_03_front_animation

**Type:** `Animation`

**Optional:** Yes

### shadow_sprite

**Type:** `Sprite`

**Optional:** Yes

### hole_sprite

**Type:** `Sprite`

**Optional:** Yes

### hole_light_sprite

**Type:** `Sprite`

**Optional:** Yes

### rocket_shadow_overlay_sprite

**Type:** `Sprite`

**Optional:** Yes

### rocket_glow_overlay_sprite

**Type:** `Sprite`

**Optional:** Yes

### door_back_sprite

**Type:** `Sprite`

**Optional:** Yes

### door_front_sprite

**Type:** `Sprite`

**Optional:** Yes

### base_day_sprite

**Type:** `Sprite`

**Optional:** Yes

### base_front_sprite

**Type:** `Sprite`

**Optional:** Yes

### red_lights_back_sprites

Drawn from the start of the [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) state until the end of the [lights_blinking_close](runtime:defines.rocket_silo_status.lights_blinking_close) state.

**Type:** `Sprite`

**Optional:** Yes

### red_lights_front_sprites

Drawn from the start of the [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) state until the end of the [lights_blinking_close](runtime:defines.rocket_silo_status.lights_blinking_close) state.

**Type:** `Sprite`

**Optional:** Yes

### base_frozen

**Type:** `Sprite`

**Optional:** Yes

### base_front_frozen

**Type:** `Sprite`

**Optional:** Yes

### hole_frozen

**Type:** `Sprite`

**Optional:** Yes

### door_back_frozen

**Type:** `Sprite`

**Optional:** Yes

### door_front_frozen

**Type:** `Sprite`

**Optional:** Yes

### hole_clipping_box

**Type:** `BoundingBox`

**Required:** Yes

### door_back_open_offset

**Type:** `Vector`

**Required:** Yes

### door_front_open_offset

**Type:** `Vector`

**Required:** Yes

### silo_fade_out_start_distance

**Type:** `double`

**Required:** Yes

### silo_fade_out_end_distance

**Type:** `double`

**Required:** Yes

### times_to_blink

How many times the `red_lights_back_sprites` and `red_lights_front_sprites` should blink during [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) and [lights_blinking_close](runtime:defines.rocket_silo_status.lights_blinking_close).

Does not affect the duration of the launch sequence.

**Type:** `uint8`

**Required:** Yes

### light_blinking_speed

The inverse of the duration in ticks of [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) and [lights_blinking_close](runtime:defines.rocket_silo_status.lights_blinking_close).

**Type:** `double`

**Required:** Yes

**Examples:**

```
light_blinking_speed = 1 / (2 * 60) -- lights blinking takes 120 ticks
```

### door_opening_speed

The inverse of the duration in ticks of [doors_opening](runtime:defines.rocket_silo_status.doors_opening) and [closing](runtime:defines.rocket_silo_status.doors_closing).

**Type:** `double`

**Required:** Yes

**Examples:**

```
door_opening_speed = 1 / (4 * 60) -- doors opening and closing takes 4 seconds
```

### rocket_parts_required

The number of crafts that must complete to produce a rocket. This includes bonus crafts from productivity. Recipe products are ignored.

**Type:** `uint32`

**Required:** Yes

### rocket_quick_relaunch_start_offset

**Type:** `double`

**Required:** Yes

### satellite_animation

**Type:** `Animation`

**Optional:** Yes

### satellite_shadow_animation

**Type:** `Animation`

**Optional:** Yes

### base_night_sprite

Drawn instead of `base_day_sprite` during the night, that is when [LuaSurface::darkness](runtime:LuaSurface::darkness) is larger than 0.3.

**Type:** `Sprite`

**Optional:** Yes

### base_light

**Type:** `LightDefinition`

**Optional:** Yes

### base_engine_light

**Type:** `LightDefinition`

**Optional:** Yes

### rocket_rising_delay

The time to wait in the [doors_opened](runtime:defines.rocket_silo_status.doors_opened) state before switching to [rocket_rising](runtime:defines.rocket_silo_status.rocket_rising).

**Type:** `uint8`

**Optional:** Yes

**Default:** 30

### launch_wait_time

The time to wait in the [launch_started](runtime:defines.rocket_silo_status.launch_started) state before switching to [engine_starting](runtime:defines.rocket_silo_status.engine_starting).

**Type:** `uint8`

**Optional:** Yes

**Default:** 120

### render_not_in_network_icon

Whether the "no network" icon should be rendered on this entity if the entity is not within a logistics network.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### rocket_parts_storage_cap

Must be at least `rocket_parts_required`.

**Type:** `uint32`

**Optional:** Yes

**Default:** "Value of `rocket_parts_required`"

### alarm_trigger

Applied when switching into the [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) state.

**Type:** `TriggerEffect`

**Optional:** Yes

### clamps_on_trigger

Applied when switching into the [arms_advance](runtime:defines.rocket_silo_status.arms_advance) state.

**Type:** `TriggerEffect`

**Optional:** Yes

### clamps_off_trigger

Applied when switching into the [arms_retract](runtime:defines.rocket_silo_status.arms_retract) state.

**Type:** `TriggerEffect`

**Optional:** Yes

### doors_trigger

Applied when switching into the [doors_opening](runtime:defines.rocket_silo_status.doors_opening) and [doors_closing](runtime:defines.rocket_silo_status.doors_closing) states.

**Type:** `TriggerEffect`

**Optional:** Yes

### raise_rocket_trigger

Applied when switching into the [rocket_rising](runtime:defines.rocket_silo_status.rocket_rising) state.

**Type:** `TriggerEffect`

**Optional:** Yes

### alarm_sound

Played when switching into the [lights_blinking_open](runtime:defines.rocket_silo_status.lights_blinking_open) state.

**Type:** `Sound`

**Optional:** Yes

### quick_alarm_sound

Played when switching from [rocket_flying](runtime:defines.rocket_silo_status.rocket_flying) into the [doors_opened](runtime:defines.rocket_silo_status.doors_opened) state when a quick follow-up rocket is ready.

**Type:** `Sound`

**Optional:** Yes

### clamps_on_sound

Played when switching into the [arms_advance](runtime:defines.rocket_silo_status.arms_advance) state.

**Type:** `Sound`

**Optional:** Yes

### clamps_off_sound

Played when switching into the [arms_retract](runtime:defines.rocket_silo_status.arms_retract) state.

**Type:** `Sound`

**Optional:** Yes

### doors_sound

Played when switching into the [doors_opening](runtime:defines.rocket_silo_status.doors_opening) and [doors_closing](runtime:defines.rocket_silo_status.doors_closing) states.

**Type:** `Sound`

**Optional:** Yes

### raise_rocket_sound

Played when switching into the [rocket_rising](runtime:defines.rocket_silo_status.rocket_rising) state.

**Type:** `Sound`

**Optional:** Yes

### to_be_inserted_to_rocket_inventory_size

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 0

### logistic_trash_inventory_size

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 0

### cargo_station_parameters

Must have exactly one entry in [CargoStationParameters::hatch_definitions](prototype:CargoStationParameters::hatch_definitions).

**Type:** `CargoStationParameters`

**Required:** Yes

### launch_to_space_platforms

Enables 'Space Age' functionality for this rocket silo, allowing it to supply space platforms.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### can_launch_without_landing_pads

**Type:** `boolean`

**Optional:** Yes

**Default:** False

