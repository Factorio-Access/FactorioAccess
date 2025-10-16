# CharacterArmorAnimation

The data for one variation of [character animations](prototype:CharacterPrototype::animations).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### idle

**Type:** `RotatedAnimation`

**Optional:** Yes

### idle_with_gun

**Type:** `RotatedAnimation`

**Required:** Yes

### running

**Type:** `RotatedAnimation`

**Optional:** Yes

### running_with_gun

Must contain exactly 18 or 40 directions, so all of the combination of gun direction and moving direction can be covered. Some of these variations are used in reverse to save space. You can use the character animation in the base game for reference.

**Type:** `RotatedAnimation`

**Required:** Yes

### mining_with_tool

**Type:** `RotatedAnimation`

**Required:** Yes

### flipped_shadow_running_with_gun

flipped_shadow_running_with_gun must be nil or contain exactly 18 directions, so all of the combination of gun direction and moving direction can be covered. Some of these variations are used in reverse to save space. You can use the character animation in the base game for reference. `flipped_shadow_running_with_gun` has to have same frame count as `running_with_gun`.

**Type:** `RotatedAnimation`

**Optional:** Yes

### idle_in_air

**Type:** `RotatedAnimation`

**Optional:** Yes

### idle_with_gun_in_air

**Type:** `RotatedAnimation`

**Optional:** Yes

### flying

**Type:** `RotatedAnimation`

**Optional:** Yes

### flying_with_gun

Must contain exactly 18 or 40 directions, so all of the combination of gun direction and moving direction can be covered. Some of these variations are used in reverse to save space. You can use the character animation in the base game for reference.

**Type:** `RotatedAnimation`

**Optional:** Yes

### take_off

**Type:** `RotatedAnimation`

**Optional:** Yes

### landing

**Type:** `RotatedAnimation`

**Optional:** Yes

### armors

The names of the armors this animation data is used for. Don't define this if you want the animations to be used for the player without armor.

**Type:** Array[`ItemID`]

**Optional:** Yes

### smoke_in_air

Smoke generator for when in air.

**Type:** Array[`SmokeSource`]

**Optional:** Yes

### smoke_cycles_per_tick

Will be clamped to range [0, 1000]. When the character is flying, each [SmokeSource](prototype:SmokeSource) in `smoke_in_air` will generate `smoke_cycles_per_tick` * [SmokeSource::frequency](prototype:SmokeSource::frequency) smokes per tick on average.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### extra_smoke_cycles_per_tile

Will be clamped to range [0, 1000]. When the character is flying, each [SmokeSource](prototype:SmokeSource) in `smoke_in_air` will generate `extra_smoke_cycles_per_tile` * [SmokeSource::frequency](prototype:SmokeSource::frequency) additional smokes per tile moved.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### mining_with_tool_particles_animation_positions

List of positions in the mining with tool animation when the mining sound and mining particles are created.

Overrides [CharacterPrototype::mining_with_tool_particles_animation_positions](prototype:CharacterPrototype::mining_with_tool_particles_animation_positions) if defined

**Type:** Array[`float`]

**Optional:** Yes

