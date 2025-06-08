# EnemySpawnerPrototype

Can spawn entities. Used for biter/spitter nests.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### call_for_help_radius

**Type:** `double`



#### graphics_set

**Type:** `EnemySpawnerGraphicsSet`



#### max_count_of_owned_units

**Type:** `uint32`

Count of enemies this spawner can sustain.

#### max_friends_around_to_spawn

**Type:** `uint32`

How many friendly units are required within the [EnemySpawnerPrototype::spawning_radius](prototype:EnemySpawnerPrototype::spawning_radius) of this spawner for it to stop producing more units.

#### max_richness_for_spawn_shift

**Type:** `double`

Max richness to determine spawn shift. Spawn shift is linear interpolation between 0 and max_spawn_shift.

#### max_spawn_shift

**Type:** `double`

Caps how much richness can be added on top of evolution when spawning units. [See also](https://www.reddit.com/r/factorio/comments/8pjscm/friday_facts_246_the_gui_update_part_3/e0bttnp/)

#### result_units

**Type:** ``UnitSpawnDefinition`[]`

Array of the [entities](prototype:EntityPrototype) that this spawner can spawn and their spawn probabilities. The sum of probabilities is expected to be 1.0. The array must not be empty.

#### spawning_cooldown

**Type:** `[]`

Ticks for cooldown after unit is spawned. The first member of the tuple is min, the second member of the tuple is max.

#### spawning_radius

**Type:** `double`

How far from the spawner can the units be spawned.

#### spawning_spacing

**Type:** `double`

What spaces should be between the spawned units.

### Optional Properties

#### absorptions_per_second

**Type:** `dictionary<`AirbornePollutantID`, `EnemySpawnerAbsorption`>`



#### allow_run_time_change_of_is_military_target

**Type:** `False`

If this is true, this entities `is_military_target property` can be changed runtime (on the entity, not on the prototype itself).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### captured_spawner_entity

**Type:** `EntityID`



#### dying_sound

**Type:** `Sound`



#### is_military_target

**Type:** `True`

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### max_count_of_owned_defensive_units

**Type:** `uint32`

Count of defensive enemies this spawner can sustain. Defensive units are units with [UnitAISettings::join_attacks](prototype:UnitAISettings::join_attacks) set to false. If set below [EnemySpawnerPrototype::max_count_of_owned_units](prototype:EnemySpawnerPrototype::max_count_of_owned_units), the difference will be the space reserved for non-defensive units.

**Default:** `Value of `max_count_of_owned_units``

#### max_darkness_to_spawn

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### max_defensive_friends_around_to_spawn

**Type:** `uint32`

How many friendly defensive units are required within the [EnemySpawnerPrototype::spawning_radius](prototype:EnemySpawnerPrototype::spawning_radius) of this spawner for it to stop producing more units. Defensive units are units with [UnitAISettings::join_attacks](prototype:UnitAISettings::join_attacks) set to false. If set below [EnemySpawnerPrototype::max_friends_around_to_spawn](prototype:EnemySpawnerPrototype::max_friends_around_to_spawn), the difference will be the space reserved for non-defensive units.

**Default:** `Value of `max_friends_around_to_spawn``

#### min_darkness_to_spawn

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### spawn_decoration

**Type:** ``CreateDecorativesTriggerEffectItem`[]`

Decoratives to be created when the spawner is created by the [map generator](https://wiki.factorio.com/Map_generator). Placed when enemies expand if `spawn_decorations_on_expansion` is set to true.

#### spawn_decorations_on_expansion

**Type:** `boolean`

Whether `spawn_decoration` should be spawned when enemies [expand](https://wiki.factorio.com/Enemies#Expansions).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### time_to_capture

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

