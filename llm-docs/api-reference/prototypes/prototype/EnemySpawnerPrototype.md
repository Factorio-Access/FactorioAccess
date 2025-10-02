# EnemySpawnerPrototype

Can spawn entities. Used for biter/spitter nests.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `unit-spawner`

## Properties

### graphics_set

**Type:** `EnemySpawnerGraphicsSet`

**Required:** Yes

### max_count_of_owned_units

Count of enemies this spawner can sustain.

**Type:** `uint32`

**Required:** Yes

### max_count_of_owned_defensive_units

Count of defensive enemies this spawner can sustain. Defensive units are units with [UnitAISettings::join_attacks](prototype:UnitAISettings::join_attacks) set to false. If set below [EnemySpawnerPrototype::max_count_of_owned_units](prototype:EnemySpawnerPrototype::max_count_of_owned_units), the difference will be the space reserved for non-defensive units.

**Type:** `uint32`

**Optional:** Yes

**Default:** "Value of `max_count_of_owned_units`"

### max_friends_around_to_spawn

How many friendly units are required within the [EnemySpawnerPrototype::spawning_radius](prototype:EnemySpawnerPrototype::spawning_radius) of this spawner for it to stop producing more units.

**Type:** `uint32`

**Required:** Yes

### max_defensive_friends_around_to_spawn

How many friendly defensive units are required within the [EnemySpawnerPrototype::spawning_radius](prototype:EnemySpawnerPrototype::spawning_radius) of this spawner for it to stop producing more units. Defensive units are units with [UnitAISettings::join_attacks](prototype:UnitAISettings::join_attacks) set to false. If set below [EnemySpawnerPrototype::max_friends_around_to_spawn](prototype:EnemySpawnerPrototype::max_friends_around_to_spawn), the difference will be the space reserved for non-defensive units.

**Type:** `uint32`

**Optional:** Yes

**Default:** "Value of `max_friends_around_to_spawn`"

### spawning_cooldown

Ticks for cooldown after unit is spawned. The first member of the tuple is min, the second member of the tuple is max.

**Type:** (`double`, `double`)

**Required:** Yes

### spawning_radius

How far from the spawner can the units be spawned.

**Type:** `double`

**Required:** Yes

### spawning_spacing

What spaces should be between the spawned units.

**Type:** `double`

**Required:** Yes

### max_richness_for_spawn_shift

Max richness to determine spawn shift. Spawn shift is linear interpolation between 0 and max_spawn_shift.

**Type:** `double`

**Required:** Yes

### max_spawn_shift

Caps how much richness can be added on top of evolution when spawning units. [See also](https://www.reddit.com/r/factorio/comments/8pjscm/friday_facts_246_the_gui_update_part_3/e0bttnp/)

**Type:** `double`

**Required:** Yes

### call_for_help_radius

**Type:** `double`

**Required:** Yes

### time_to_capture

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### result_units

Array of the [entities](prototype:EntityPrototype) that this spawner can spawn and their spawn probabilities. The sum of probabilities is expected to be 1.0. The array must not be empty.

**Type:** Array[`UnitSpawnDefinition`]

**Required:** Yes

### dying_sound

**Type:** `Sound`

**Optional:** Yes

### absorptions_per_second

**Type:** Dictionary[`AirbornePollutantID`, `EnemySpawnerAbsorption`]

**Optional:** Yes

### min_darkness_to_spawn

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### max_darkness_to_spawn

**Type:** `float`

**Optional:** Yes

**Default:** 1.0

### spawn_decorations_on_expansion

Whether `spawn_decoration` should be spawned when enemies [expand](https://wiki.factorio.com/Enemies#Expansions).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### spawn_decoration

Decoratives to be created when the spawner is created by the [map generator](https://wiki.factorio.com/Map_generator). Placed when enemies expand if `spawn_decorations_on_expansion` is set to true.

**Type:** Array[`CreateDecorativesTriggerEffectItem`]

**Optional:** Yes

### captured_spawner_entity

**Type:** `EntityID`

**Optional:** Yes

### is_military_target

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Type:** `True`

**Optional:** Yes

**Default:** True

**Overrides parent:** Yes

### allow_run_time_change_of_is_military_target

If this is true, this entities `is_military_target property` can be changed runtime (on the entity, not on the prototype itself).

**Type:** `False`

**Optional:** Yes

**Default:** False

**Overrides parent:** Yes

