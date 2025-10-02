# TurretPrototype

A turret that needs no extra ammunition. See the children for turrets that need some kind of ammunition.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `turret`

## Properties

### attack_parameters

Requires ammo_type in attack_parameters unless this is a [AmmoTurretPrototype](prototype:AmmoTurretPrototype).

**Type:** `AttackParameters`

**Required:** Yes

### folded_animation

**Type:** `RotatedAnimation8Way`

**Required:** Yes

### call_for_help_radius

**Type:** `double`

**Required:** Yes

### attack_target_mask

**Type:** `TriggerTargetMask`

**Optional:** Yes

**Default:** "all masks"

### ignore_target_mask

**Type:** `TriggerTargetMask`

**Optional:** Yes

**Default:** "no masks"

### shoot_in_prepare_state

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### start_attacking_only_when_can_shoot

When `false` the turret will enter `starting_attack` state without checking its ammo or energy levels. [FluidTurretPrototype](prototype:FluidTurretPrototype) forces this to `true`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### turret_base_has_direction

When `true` the turret's collision box will affected by its rotation.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### random_animation_offset

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### attack_from_start_frame

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### allow_turning_when_starting_attack

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### gun_animation_secondary_draw_order

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### gun_animation_render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### graphics_set

**Type:** `TurretGraphicsSet`

**Required:** Yes

### preparing_animation

**Type:** `RotatedAnimation8Way`

**Optional:** Yes

### prepared_animation

**Type:** `RotatedAnimation8Way`

**Optional:** Yes

### prepared_alternative_animation

**Type:** `RotatedAnimation8Way`

**Optional:** Yes

### starting_attack_animation

**Type:** `RotatedAnimation8Way`

**Optional:** Yes

### attacking_animation

**Type:** `RotatedAnimation8Way`

**Optional:** Yes

### energy_glow_animation

**Type:** `RotatedAnimation8Way`

**Optional:** Yes

### resource_indicator_animation

**Type:** `RotatedAnimation8Way`

**Optional:** Yes

### ending_attack_animation

**Type:** `RotatedAnimation8Way`

**Optional:** Yes

### folding_animation

**Type:** `RotatedAnimation8Way`

**Optional:** Yes

### integration

**Type:** `Sprite`

**Optional:** Yes

### special_effect

**Type:** `TurretSpecialEffect`

**Optional:** Yes

### glow_light_intensity

The intensity of light in the form of `energy_glow_animation` drawn on top of `energy_glow_animation`.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### energy_glow_animation_flicker_strength

The range of the flickering of the alpha of `energy_glow_animation`. Default is range 0.2, so animation alpha can be anywhere between 0.8 and 1.0.

**Type:** `float`

**Optional:** Yes

**Default:** 0.2

### starting_attack_sound

**Type:** `Sound`

**Optional:** Yes

### dying_sound

**Type:** `Sound`

**Optional:** Yes

### preparing_sound

**Type:** `Sound`

**Optional:** Yes

### folding_sound

**Type:** `Sound`

**Optional:** Yes

### prepared_sound

**Type:** `Sound`

**Optional:** Yes

### prepared_alternative_sound

**Type:** `Sound`

**Optional:** Yes

### rotating_sound

**Type:** `InterruptibleSound`

**Optional:** Yes

### default_speed

**Type:** `float`

**Optional:** Yes

**Default:** 1

### default_speed_secondary

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed`"

### default_speed_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed`"

### default_starting_progress_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** 0

### rotation_speed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed`"

### rotation_speed_secondary

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_secondary`"

### rotation_speed_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_when_killed`"

### rotation_starting_progress_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_starting_progress_when_killed`"

### preparing_speed

Controls the speed of the preparing_animation: `1 ÷ preparing_speed = duration of the preparing_animation`

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed`"

### preparing_speed_secondary

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_secondary`"

### preparing_speed_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_when_killed`"

### preparing_starting_progress_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_starting_progress_when_killed`"

### folded_speed

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the folded_animation: `1 ÷ folded_speed = duration of the folded_animation`

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed`"

### folded_speed_secondary

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the folded_animation: `1 ÷ folded_speed_secondary = duration of the folded_animation`

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_secondary`"

### folded_speed_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_when_killed`"

### folded_starting_progress_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_starting_progress_when_killed`"

### prepared_speed

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the prepared_animation: `1 ÷ prepared_speed = duration of the prepared_animation`

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed`"

### prepared_speed_secondary

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the prepared_animation: `1 ÷ prepared_speed_secondary = duration of the prepared_animation`

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_secondary`"

### prepared_speed_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_when_killed`"

### prepared_starting_progress_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_starting_progress_when_killed`"

### prepared_alternative_speed

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the prepared_alternative_animation: `1 ÷ prepared_alternative_speed = duration of the prepared_alternative_animation`

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed`"

### prepared_alternative_speed_secondary

It's randomized whether a particular turret uses the primary or the secondary speed for its animations.

Controls the speed of the prepared_alternative_animation: `1 ÷ prepared_alternative_speed_secondary = duration of the prepared_alternative_animation`

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_secondary`"

### prepared_alternative_speed_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_when_killed`"

### prepared_alternative_starting_progress_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_starting_progress_when_killed`"

### prepared_alternative_chance

The chance for `prepared_alternative_animation` to be used.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### starting_attack_speed

Controls the speed of the starting_attack_animation: `1 ÷ starting_attack_speed = duration of the starting_attack_animation`

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed`"

### starting_attack_speed_secondary

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_secondary`"

### starting_attack_speed_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_when_killed`"

### starting_attack_starting_progress_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_starting_progress_when_killed`"

### attacking_speed

Controls the speed of the attacking_animation: `1 ÷ attacking_speed = duration of the attacking_animation`

**Type:** `float`

**Optional:** Yes

**Default:** 1

### ending_attack_speed

Controls the speed of the ending_attack_animation: `1 ÷ ending_attack_speed = duration of the ending_attack_animation`

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed`"

### ending_attack_speed_secondary

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_secondary`"

### ending_attack_speed_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_when_killed`"

### ending_attack_starting_progress_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_starting_progress_when_killed`"

### folding_speed

Controls the speed of the folding_animation: `1 ÷ folding_speed = duration of the folding_animation`

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed`"

### folding_speed_secondary

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_secondary`"

### folding_speed_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_speed_when_killed`"

### folding_starting_progress_when_killed

**Type:** `float`

**Optional:** Yes

**Default:** "Value of `default_starting_progress_when_killed`"

### prepare_range

**Type:** `double`

**Optional:** Yes

**Default:** "The range defined in the `attack_parameters`"

### alert_when_attacking

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### spawn_decorations_on_expansion

Whether `spawn_decoration` should be spawned when this turret is created through [enemy expansion](https://wiki.factorio.com/Enemies#Expansions).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### folded_animation_is_stateless

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### unfolds_before_dying

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### spawn_decoration

Decoratives to be created when the spawner is created by the [map generator](https://wiki.factorio.com/Map_generator). Placed when enemies expand if `spawn_decorations_on_expansion` is set to true.

**Type:** Array[`CreateDecorativesTriggerEffectItem`]

**Optional:** Yes

### folded_state_corpse

**Type:** `EntityID` | Array[`EntityID`]

**Optional:** Yes

### can_retarget_while_starting_attack

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### is_military_target

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

**Overrides parent:** Yes

### circuit_wire_max_distance

The maximum circuit wire distance for this entity.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### draw_copper_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_circuit_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### circuit_connector

Set of [circuit connector definitions](prototype:CircuitConnectorDefinition) for all directions used by this turret. Required amount of elements is based on other prototype values: 8 elements if building-direction-8-way flag is set, or 16 elements if building-direction-16-way flag is set, or 4 elements if turret_base_has_direction is set to true, or 1 element.

**Type:** Array[`CircuitConnectorDefinition`]

**Optional:** Yes

