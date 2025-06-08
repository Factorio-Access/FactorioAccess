# StickerPrototype

Entity that sticks to another entity, and damages/slows it. Stickers can only be attached to [UnitPrototype](prototype:UnitPrototype), [CharacterPrototype](prototype:CharacterPrototype), [CarPrototype](prototype:CarPrototype) and [SpiderVehiclePrototype](prototype:SpiderVehiclePrototype).

**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### duration_in_ticks

**Type:** `uint32`

Must be > 0.

#### hidden

**Type:** `True`

The `hidden` property of stickers is hardcoded to `true`.

#### hidden_in_factoriopedia

**Type:** `True`

The `hidden_in_factoriopedia` property of stickers is hardcoded to `true`.

### Optional Properties

#### animation

**Type:** `Animation`



#### damage_interval

**Type:** `uint32`

Interval between application of `damage_per_tick`, in ticks.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### damage_per_tick

**Type:** `DamageParameters`

Applied every `damage_interval` ticks, so may not necessarily be "per tick".

#### fire_spread_cooldown

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 30}`

#### fire_spread_radius

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### force_visibility

**Type:** `ForceCondition`



**Default:** `{'complex_type': 'literal', 'value': 'all'}`

#### ground_target

**Type:** `boolean`

If true, causes the target entity to become "grounded", disabling flight. This only applies to Character entities wearing mech armor.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### selection_box_type

**Type:** `CursorBoxType`

Using this property marks the sticker as a "selection sticker", meaning that the selection box will be rendered around the entity when the sticker is on it.

**Default:** `{'complex_type': 'literal', 'value': 'entity'}`

#### single_particle

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### spread_fire_entity

**Type:** `EntityID`

If this is given, this sticker is considered a "fire sticker" for some functions, such as [BaseAttackParameters::fire_penalty](prototype:BaseAttackParameters::fire_penalty) and [EntityPrototypeFlags::not-flammable](prototype:EntityPrototypeFlags::not_flammable).

#### stickers_per_square_meter

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 15}`

#### target_movement_max

**Type:** `float`

The maximum movement speed for the target.

Negative values are ignored.

**Default:** `{'complex_type': 'literal', 'value': -1}`

#### target_movement_max_from

**Type:** `float`

The maximum movement speed for the target when the sticker is attached. It linearly changes over time to reach `target_movement_max_to`.

Negative values are ignored.

**Default:** `Value of `target_movement_speed``

#### target_movement_max_to

**Type:** `float`

The maximum movement speed for the target when the sticker expires. It linearly changes over time starting from `target_movement_max_from`.

Negative values are ignored.

**Default:** `Value of `target_movement_speed``

#### target_movement_modifier

**Type:** `float`

Less than 1 to reduce movement speed, more than 1 to increase it.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### target_movement_modifier_from

**Type:** `float`

The modifier value when the sticker is attached. It linearly changes over time to reach `target_movement_modifier_to`.

**Default:** `Value of `target_movement_modifier``

#### target_movement_modifier_to

**Type:** `float`

The modifier value when the sticker expires. It linearly changes over time starting from `target_movement_modifier_from`.

**Default:** `Value of `target_movement_modifier``

#### update_effects

**Type:** ``TriggerEffectWithCooldown`[]`

Effects (with cooldowns) to trigger every tick.

#### use_damage_substitute

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### vehicle_friction_modifier

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### vehicle_friction_modifier_from

**Type:** `float`

Works similarly to `target_movement_modifier_from`.

**Default:** `Value of `vehicle_friction_modifier``

#### vehicle_friction_modifier_to

**Type:** `float`

Works similarly to `target_movement_modifier_to`.

**Default:** `Value of `vehicle_friction_modifier``

#### vehicle_speed_max

**Type:** `float`

The maximum movement speed for vehicles.

Negative values are ignored.

**Default:** `{'complex_type': 'literal', 'value': -1}`

#### vehicle_speed_max_from

**Type:** `float`

The maximum movement speed for vehicles when the sticker is attached. It linearly changes over time to reach `vehicle_speed_max_to`.

Negative values are ignored.

**Default:** `Value of `vehicle_speed_max``

#### vehicle_speed_max_to

**Type:** `float`

The maximum movement speed for vehicles when the sticker expires. It linearly changes over time starting from `vehicle_speed_max_from`.

Negative values are ignored.

**Default:** `Value of `vehicle_speed_max``

#### vehicle_speed_modifier

**Type:** `float`

Less than 1 to reduce vehicle speed, more than 1 to increase it.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### vehicle_speed_modifier_from

**Type:** `float`

Works similarly to `target_movement_modifier_from`.

**Default:** `Value of `vehicle_speed_modifier``

#### vehicle_speed_modifier_to

**Type:** `float`

Works similarly to `target_movement_modifier_to`.

**Default:** `Value of `vehicle_speed_modifier``

