# LuaSegmentedUnit

A surface-level object composed of one [SegmentedUnitPrototype](prototype:SegmentedUnitPrototype) followed by up to 63 [SegmentPrototype](prototype:SegmentPrototype)s.

This object is not an entity, and can exist on chunks that do not exist. Instead, the individual segments that compose its body will be destroyed as the unit's body crosses into un-generated or void terrain, and will be re-created when the body crosses into generated, non-void terrain.

Use [LuaSurface::get_segmented_units](runtime:LuaSurface::get_segmented_units) to iterate over all units on a surface, [LuaTerritory::get_segmented_units](runtime:LuaTerritory::get_segmented_units) to iterate over all units that guard a territory, or [LuaEntity::segmented_unit](runtime:LuaEntity::segmented_unit) to get the unit that controls any given segment entity.

## Attributes

### prototype

The prototype of the `segmented-unit` entity that defines the traits and behaviors of the unit.

**Read type:** `LuaEntityPrototype`

### surface

The surface on which the unit is located.

**Read type:** `LuaSurface`

### territory

The territory that the unit is protecting.

**Read type:** `LuaTerritory`

**Write type:** `LuaTerritory`

**Optional:** Yes

### segments

The segments that compose the unit.

**Read type:** Array[`LuaSegment`]

### force

The force that the unit belongs to. Changing this also changes the force of all segment entities.

Always returns a [LuaForce](runtime:LuaForce), but may be assigned to any [ForceID](runtime:ForceID) type.

**Read type:** `LuaForce`

**Write type:** `ForceID`

### unit_number

A unique number identifying this unit for the lifetime of the save. These are allocated sequentially and not re-used (until overflow). These numbers are allocated from the same pool as [LuaEntity::unit_number](runtime:LuaEntity::unit_number), so segmented unit numbers are unique among all segmented units and all entities with owners.

**Read type:** `uint64`

### health

The current health of the unit. Health is automatically clamped to be between `0` and [LuaSegmentedUnit::max_health](runtime:LuaSegmentedUnit::max_health).

**Read type:** `float`

**Write type:** `float`

### max_health

The maximum health of the unit.

**Read type:** `float`

### health_ratio

The ratio of [LuaSegmentedUnit::health](runtime:LuaSegmentedUnit::health) to [LuaSegmentedUnit::max_health](runtime:LuaSegmentedUnit::max_health). Values are clamped between `0` (no health) and `1` (full health) inclusive.

**Read type:** `float`

**Write type:** `float`

### speed

The current instantaneous speed in tiles per map tick. Must always be greater than or equal to 0; segmented units are currently incapable of naturally moving in reverse.

When setting this value, note that unless the unit's AI is similarly overridden by a script, the unit's speed will continuously accelerate or decelerate to match [LuaSegmentedUnit::target_speed](runtime:LuaSegmentedUnit::target_speed).

**Read type:** `double`

**Write type:** `double`

### target_speed

The speed in tiles per tick that the unit is currently attempting to reach, as determined by its AI. Must always be greater than or equal to 0.

**Read type:** `double`

### acceleration

The rate at which [LuaSegmentedUnit::speed](runtime:LuaSegmentedUnit::speed) is changing over time, in tiles per tick per tick.

This value represents unit's most recent change in speed. If its speed is not changing, the acceleration value will be 0. If it is gaining speed, the value will be positive. If it is losing speed, the value will be negative.

**Read type:** `double`

### max_body_nodes

The maximum length of [LuaSegmentedUnit::get_body_nodes](runtime:LuaSegmentedUnit::get_body_nodes).

**Read type:** `uint32`

### activity_mode

The current activity mode of the unit. Setting this field can cause the segmented unit to "wake up" or force it into a lower activity mode, but not permanently. Segmented units will generally try to update their activity mode so that they are fully active whenever they are potentially being observed by players, minimally active when relevant to gameplay but not likely observed, and asleep when not relevant to gameplay.

Will never be lower than [LuaSegmentedUnit::minimum_activity_mode](runtime:LuaSegmentedUnit::minimum_activity_mode).

**Read type:** `defines.segmented_unit_activity_mode`

**Write type:** `defines.segmented_unit_activity_mode`

### minimum_activity_mode

The lowest-level activity mode that the unit is allowed to be in. Set this field to prevent the segmented unit from falling asleep or entering minimal mode. Set this field to `nil` or [asleep](runtime:defines.segmented_unit_activity_mode) to reset this to the default and allow the engine to use whatever activity mode is appropriate.

Performance note: it is NOT recommended to force many segmented units to be fully active or minimally active simultaneously, as they can significantly impact performance depending on how they are configured. When using this feature, remember to reset this field to allow irrelevant units to go back to sleep.

**Read type:** `defines.segmented_unit_activity_mode`

**Write type:** `defines.segmented_unit_activity_mode`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### destroy

Destroys the segmented unit.

**Parameters:**

- `raise_destroy` `boolean` *(optional)* - If `true`, [script_raised_destroy_segmented_unit](runtime:script_raised_destroy_segmented_unit) will be called. Defaults to `false`.

### die

Immediately kills the unit.

Unlike [LuaSegmentedUnit::destroy](runtime:LuaSegmentedUnit::destroy), `die` will trigger the [on_segmented_unit_died](runtime:on_segmented_unit_died) event and the unit's individual segments will produce a corpse and drop loot if they have any, and if the segment entities exist at the moment of death (are not in non-generated chunks or out-of-map tiles).

**Parameters:**

- `cause` `LuaEntity` *(optional)* - The cause to attribute the kill to.
- `damage_type` `DamageTypeID` *(optional)* - The final damage type that caused the unit to die.
- `force` `ForceID` *(optional)* - The force to attribute the kill to. Defaults to the `"neutral"` force.

### damage

Damages the unit.

**Parameters:**

- `cause` `LuaEntity` *(optional)* - The entity that originally triggered the events that led to this damage being dealt. This can be the player character, turret, unit, etc. that pulled the trigger. Does not need to be on the same surface as the segmented unit being damaged.
- `damage` `float` - The amount of damage to be done.
- `force` `ForceID` - The force that is doing the damage.
- `source` `LuaEntity` *(optional)* - The entity that is directly dealing the damage. This is the projectile, flame, sticker, grenade, laster beam, etc. Must be on the same surface as the entity being damaged.
- `type` `DamageTypeID` *(optional)* - The type of damage being done. Defaults to `"impact"`.

**Returns:**

- `float` - The total damage actually applied after resistances.

### move_forward

Moves the unit forward by a fixed distance according to its natural movement patterns and AI configuration. This movement occurs in addition to the unit's current speed, but affects neither [LuaSegmentedUnit::speed](runtime:LuaSegmentedUnit::speed) nor [LuaSegmentedUnit::acceleration](runtime:LuaSegmentedUnit::acceleration).

**Parameters:**

- `distance` `double` - The distance in tiles to move the segmented unit forward.

### clone

Clones this unit.

**Parameters:**

- `force` `ForceID` *(optional)* - The new unit's force.
- `position` `MapPosition` - The destination position of the head segment. The rest of the body nodes will be copied relative to this.
- `surface` `LuaSurface` *(optional)* - The destination surface. If different from this unit's surface, then the clone will not copy the original unit's territory.
- `territory` `LuaTerritory` *(optional)* - The territory that the clone should guard. Must be on the same surface as the destination surface.

**Returns:**

- `LuaSegmentedUnit` *(optional)* - The cloned unit or `nil` if the unit cannot be cloned.

### get_body_nodes

Gets the nodes that define the shape of the unit's body from front to back. Segments are moved along the path these nodes create.

The returned array will always contain at least 1 position, but will not contain more than [LuaSegmentedUnit::max_body_nodes](runtime:LuaSegmentedUnit::max_body_nodes).

The returned table is a copy of the unit's actual body nodes.

**Returns:**

- Array[`MapPosition`]

### set_body_nodes

Overwrites the segmented unit's body nodes, which are a series of points that make up the general shape of the unit. Segments are moved along the path these nodes create. For best results, adjacent nodes should be approximately 1.0 tile apart from each other.

This array must contain at least 1 position. Positions at indexes greater than [LuaSegmentedUnit::max_body_nodes](runtime:LuaSegmentedUnit::max_body_nodes) will be ignored.

Segment entities may be created, destroyed, or moved as a result of setting this field's value. Any segment entities that have a [TriggerEffectWithCooldown](prototype:TriggerEffectWithCooldown)s will reduce that effect's distance cooldown. However, any effects that go off cooldown as a result will not trigger until the next game update.

**Parameters:**

- `nodes` Array[`MapPosition`] - The new positions that make up the segmented unit's body nodes. Must not be empty.

### get_ai_state

Gets the state of the unit's AI.

This method returns a copy of the internal AI state. Modifying the returned table will not affect the unit's AI.

**Returns:**

- `SegmentedUnitAIState`

### set_ai_state

Sets the segmented unit's AI.

**Parameters:**

- `state` `SegmentedUnitAIState` - The new AI state. A copy of this table used, so you can read or write to this table after calling this function without being affected by or affecting the unit's AI.

