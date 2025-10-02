# StickerPrototype

Entity that sticks to another entity, and damages/slows it. Stickers can only be attached to [UnitPrototype](prototype:UnitPrototype), [CharacterPrototype](prototype:CharacterPrototype), [CarPrototype](prototype:CarPrototype) and [SpiderVehiclePrototype](prototype:SpiderVehiclePrototype).

**Parent:** [EntityPrototype](EntityPrototype.md)
**Type name:** `sticker`

## Properties

### duration_in_ticks

Must be > 0.

**Type:** `uint32`

**Required:** Yes

### animation

**Type:** `Animation`

**Optional:** Yes

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### damage_interval

Interval between application of `damage_per_tick`, in ticks.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### spread_fire_entity

If this is given, this sticker is considered a "fire sticker" for some functions, such as [BaseAttackParameters::fire_penalty](prototype:BaseAttackParameters::fire_penalty) and [EntityPrototypeFlags::not-flammable](prototype:EntityPrototypeFlags::not_flammable).

**Type:** `EntityID`

**Optional:** Yes

### fire_spread_cooldown

**Type:** `uint8`

**Optional:** Yes

**Default:** 30

### fire_spread_radius

**Type:** `float`

**Optional:** Yes

**Default:** 1

### stickers_per_square_meter

**Type:** `float`

**Optional:** Yes

**Default:** 15

### force_visibility

**Type:** `ForceCondition`

**Optional:** Yes

**Default:** "all"

### single_particle

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### use_damage_substitute

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### damage_per_tick

Applied every `damage_interval` ticks, so may not necessarily be "per tick".

**Type:** `DamageParameters`

**Optional:** Yes

### target_movement_modifier

Less than 1 to reduce movement speed, more than 1 to increase it.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### target_movement_modifier_from

The modifier value when the sticker is attached. It linearly changes over time to reach `target_movement_modifier_to`.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `target_movement_modifier`"

### target_movement_modifier_to

The modifier value when the sticker expires. It linearly changes over time starting from `target_movement_modifier_from`.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `target_movement_modifier`"

### target_movement_max

The maximum movement speed for the target.

Negative values are ignored.

**Type:** `float`

**Optional:** Yes

**Default:** -1

### target_movement_max_from

The maximum movement speed for the target when the sticker is attached. It linearly changes over time to reach `target_movement_max_to`.

Negative values are ignored.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `target_movement_speed`"

### target_movement_max_to

The maximum movement speed for the target when the sticker expires. It linearly changes over time starting from `target_movement_max_from`.

Negative values are ignored.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `target_movement_speed`"

### ground_target

If true, causes the target entity to become "grounded", disabling flight. This only applies to Character entities wearing mech armor.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### vehicle_speed_modifier

Less than 1 to reduce vehicle speed, more than 1 to increase it.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### vehicle_speed_modifier_from

Works similarly to `target_movement_modifier_from`.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `vehicle_speed_modifier`"

### vehicle_speed_modifier_to

Works similarly to `target_movement_modifier_to`.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `vehicle_speed_modifier`"

### vehicle_speed_max

The maximum movement speed for vehicles.

Negative values are ignored.

**Type:** `float`

**Optional:** Yes

**Default:** -1

### vehicle_speed_max_from

The maximum movement speed for vehicles when the sticker is attached. It linearly changes over time to reach `vehicle_speed_max_to`.

Negative values are ignored.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `vehicle_speed_max`"

### vehicle_speed_max_to

The maximum movement speed for vehicles when the sticker expires. It linearly changes over time starting from `vehicle_speed_max_from`.

Negative values are ignored.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `vehicle_speed_max`"

### vehicle_friction_modifier

**Type:** `float`

**Optional:** Yes

**Default:** 1

### vehicle_friction_modifier_from

Works similarly to `target_movement_modifier_from`.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `vehicle_friction_modifier`"

### vehicle_friction_modifier_to

Works similarly to `target_movement_modifier_to`.

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `vehicle_friction_modifier`"

### selection_box_type

Using this property marks the sticker as a "selection sticker", meaning that the selection box will be rendered around the entity when the sticker is on it.

**Type:** `CursorBoxType`

**Optional:** Yes

**Default:** "entity"

### update_effects

Effects (with cooldowns) to trigger every tick.

**Type:** Array[`TriggerEffectWithCooldown`]

**Optional:** Yes

### hidden

The `hidden` property of stickers is hardcoded to `true`.

**Type:** `True`

**Required:** Yes

**Overrides parent:** Yes

### hidden_in_factoriopedia

The `hidden_in_factoriopedia` property of stickers is hardcoded to `true`.

**Type:** `True`

**Required:** Yes

**Overrides parent:** Yes

