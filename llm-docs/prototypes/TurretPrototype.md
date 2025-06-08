# TurretPrototype

A turret that needs no extra ammunition. See the children for turrets that need some kind of ammunition.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### attack_parameters

**Type:** `AttackParameters`

Requires ammo_type in attack_parameters unless this is a [AmmoTurretPrototype](prototype:AmmoTurretPrototype).

#### call_for_help_radius

**Type:** `double`



#### folded_animation

**Type:** `RotatedAnimation8Way`



#### graphics_set

**Type:** `TurretGraphicsSet`



### Optional Properties

#### alert_when_attacking

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### allow_turning_when_starting_attack

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### attack_from_start_frame

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### attack_target_mask

**Type:** `TriggerTargetMask`



**Default:** `all masks`

#### attacking_animation

**Type:** `RotatedAnimation8Way`



#### attacking_speed

**Type:** `float`

Controls the speed of the attacking_animation: `1 ÷ attacking_speed = duration of the attacking_animation`

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### can_retarget_while_starting_attack

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### circuit_connector

**Type:** ``CircuitConnectorDefinition`[]`

Set of [circuit connector definitions](prototype:CircuitConnectorDefinition) for all directions used by this turret. Required amount of elements is based on other prototype values: 8 elements if building-direction-8-way flag is set, or 16 elements if building-direction-16-way flag is set, or 4 elements if turret_base_has_direction is set to true, or 1 element.

#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### default_speed

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### default_speed_secondary

**Type:** `float`



**Default:** `Value of `default_speed``

#### default_speed_when_killed

**Type:** `float`



**Default:** `Value of `default_speed``

#### default_starting_progress_when_killed

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### dying_sound

**Type:** `Sound`



#### ending_attack_animation

**Type:** `RotatedAnimation8Way`



#### ending_attack_speed

**Type:** `float`

Controls the speed of the ending_attack_animation: `1 ÷ ending_attack_speed = duration of the ending_attack_animation`

**Default:** `Value of `default_speed``

#### ending_attack_speed_secondary

**Type:** `float`



**Default:** `Value of `default_speed_secondary``

#### ending_attack_speed_when_killed

**Type:** `float`



**Default:** `Value of `default_speed_when_killed``

#### ending_attack_starting_progress_when_killed

**Type:** `float`



**Default:** `Value of `default_starting_progress_when_killed``

#### energy_glow_animation

**Type:** `RotatedAnimation8Way`



#### energy_glow_animation_flicker_strength

**Type:** `float`

The range of the flickering of the alpha of `energy_glow_animation`. Default is range 0.2, so animation alpha can be anywhere between 0.8 and 1.0.

**Default:** `{'complex_type': 'literal', 'value': 0.2}`

#### folded_animation_is_stateless

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### folded_speed

**Type:** `float`

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the folded_animation: `1 ÷ folded_speed = duration of the folded_animation`

**Default:** `Value of `default_speed``

#### folded_speed_secondary

**Type:** `float`

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the folded_animation: `1 ÷ folded_speed_secondary = duration of the folded_animation`

**Default:** `Value of `default_speed_secondary``

#### folded_speed_when_killed

**Type:** `float`



**Default:** `Value of `default_speed_when_killed``

#### folded_starting_progress_when_killed

**Type:** `float`



**Default:** `Value of `default_starting_progress_when_killed``

#### folded_state_corpse

**Type:** 



#### folding_animation

**Type:** `RotatedAnimation8Way`



#### folding_sound

**Type:** `Sound`



#### folding_speed

**Type:** `float`

Controls the speed of the folding_animation: `1 ÷ folding_speed = duration of the folding_animation`

**Default:** `Value of `default_speed``

#### folding_speed_secondary

**Type:** `float`



**Default:** `Value of `default_speed_secondary``

#### folding_speed_when_killed

**Type:** `float`



**Default:** `Value of `default_speed_when_killed``

#### folding_starting_progress_when_killed

**Type:** `float`



**Default:** `Value of `default_starting_progress_when_killed``

#### glow_light_intensity

**Type:** `float`

The intensity of light in the form of `energy_glow_animation` drawn on top of `energy_glow_animation`.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### gun_animation_render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

#### gun_animation_secondary_draw_order

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### ignore_target_mask

**Type:** `TriggerTargetMask`



**Default:** `no masks`

#### integration

**Type:** `Sprite`



#### is_military_target

**Type:** `boolean`

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### prepare_range

**Type:** `double`



**Default:** `The range defined in the `attack_parameters``

#### prepared_alternative_animation

**Type:** `RotatedAnimation8Way`



#### prepared_alternative_chance

**Type:** `float`

The chance for `prepared_alternative_animation` to be used.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### prepared_alternative_sound

**Type:** `Sound`



#### prepared_alternative_speed

**Type:** `float`

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the prepared_alternative_animation: `1 ÷ prepared_alternative_speed = duration of the prepared_alternative_animation`

**Default:** `Value of `default_speed``

#### prepared_alternative_speed_secondary

**Type:** `float`

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the prepared_alternative_animation: `1 ÷ prepared_alternative_speed_secondary = duration of the prepared_alternative_animation`

**Default:** `Value of `default_speed_secondary``

#### prepared_alternative_speed_when_killed

**Type:** `float`



**Default:** `Value of `default_speed_when_killed``

#### prepared_alternative_starting_progress_when_killed

**Type:** `float`



**Default:** `Value of `default_starting_progress_when_killed``

#### prepared_animation

**Type:** `RotatedAnimation8Way`



#### prepared_sound

**Type:** `Sound`



#### prepared_speed

**Type:** `float`

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the prepared_animation: `1 ÷ prepared_speed = duration of the prepared_animation`

**Default:** `Value of `default_speed``

#### prepared_speed_secondary

**Type:** `float`

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the prepared_animation: `1 ÷ prepared_speed_secondary = duration of the prepared_animation`

**Default:** `Value of `default_speed_secondary``

#### prepared_speed_when_killed

**Type:** `float`



**Default:** `Value of `default_speed_when_killed``

#### prepared_starting_progress_when_killed

**Type:** `float`



**Default:** `Value of `default_starting_progress_when_killed``

#### preparing_animation

**Type:** `RotatedAnimation8Way`



#### preparing_sound

**Type:** `Sound`



#### preparing_speed

**Type:** `float`

Controls the speed of the preparing_animation: `1 ÷ preparing_speed = duration of the preparing_animation`

**Default:** `Value of `default_speed``

#### preparing_speed_secondary

**Type:** `float`



**Default:** `Value of `default_speed_secondary``

#### preparing_speed_when_killed

**Type:** `float`



**Default:** `Value of `default_speed_when_killed``

#### preparing_starting_progress_when_killed

**Type:** `float`



**Default:** `Value of `default_starting_progress_when_killed``

#### random_animation_offset

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### resource_indicator_animation

**Type:** `RotatedAnimation8Way`



#### rotating_sound

**Type:** `InterruptibleSound`



#### rotation_speed

**Type:** `float`



**Default:** `Value of `default_speed``

#### rotation_speed_secondary

**Type:** `float`



**Default:** `Value of `default_speed_secondary``

#### rotation_speed_when_killed

**Type:** `float`



**Default:** `Value of `default_speed_when_killed``

#### rotation_starting_progress_when_killed

**Type:** `float`



**Default:** `Value of `default_starting_progress_when_killed``

#### shoot_in_prepare_state

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### spawn_decoration

**Type:** ``CreateDecorativesTriggerEffectItem`[]`

Decoratives to be created when the spawner is created by the [map generator](https://wiki.factorio.com/Map_generator). Placed when enemies expand if `spawn_decorations_on_expansion` is set to true.

#### spawn_decorations_on_expansion

**Type:** `boolean`

Whether `spawn_decoration` should be spawned when this turret is created through [enemy expansion](https://wiki.factorio.com/Enemies#Expansions).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### special_effect

**Type:** `TurretSpecialEffect`



#### start_attacking_only_when_can_shoot

**Type:** `boolean`

When `false` the turret will enter `starting_attack` state without checking its ammo or energy levels. [FluidTurretPrototype](prototype:FluidTurretPrototype) forces this to `true`.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### starting_attack_animation

**Type:** `RotatedAnimation8Way`



#### starting_attack_sound

**Type:** `Sound`



#### starting_attack_speed

**Type:** `float`

Controls the speed of the starting_attack_animation: `1 ÷ starting_attack_speed = duration of the starting_attack_animation`

**Default:** `Value of `default_speed``

#### starting_attack_speed_secondary

**Type:** `float`



**Default:** `Value of `default_speed_secondary``

#### starting_attack_speed_when_killed

**Type:** `float`



**Default:** `Value of `default_speed_when_killed``

#### starting_attack_starting_progress_when_killed

**Type:** `float`



**Default:** `Value of `default_starting_progress_when_killed``

#### turret_base_has_direction

**Type:** `boolean`

When `true` the turret's collision box will affected by its rotation.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### unfolds_before_dying

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

