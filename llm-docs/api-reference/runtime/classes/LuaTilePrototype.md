# LuaTilePrototype

Prototype of a tile.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### collision_mask

The collision mask this tile uses

**Read type:** `CollisionMask`

### layer

**Read type:** `uint`

### autoplace_specification

Autoplace specification for this prototype, if any.

**Read type:** `AutoplaceSpecification`

**Optional:** Yes

### walking_speed_modifier

**Read type:** `float`

### vehicle_friction_modifier

**Read type:** `float`

### map_color

**Read type:** `Color`

### decorative_removal_probability

The probability that decorative entities will be removed from on top of this tile when this tile is generated.

**Read type:** `float`

### automatic_neighbors

**Read type:** `boolean`

### allowed_neighbors

**Read type:** Dictionary[`string`, `LuaTilePrototype`]

### needs_correction

If this tile needs correction logic applied when it's generated in the world.

**Read type:** `boolean`

### mineable_properties

**Read type:** Table (see below for parameters)

### fluid

The fluid offshore pump produces on this tile, if any.

**Read type:** `LuaFluidPrototype`

**Optional:** Yes

### next_direction

The next direction of this tile, if any. Used when a tile has multiple directions (such as hazard concrete)

**Read type:** `LuaTilePrototype`

**Optional:** Yes

### items_to_place_this

Items that when placed will produce this tile, if any. Construction bots will choose the first item in the list to build this tile.

**Read type:** Array[`ItemToPlace`]

**Optional:** Yes

### can_be_part_of_blueprint

False if this tile is not allowed in blueprints regardless of the ability to build it.

**Read type:** `boolean`

### absorptions_per_second

A table of pollution emissions per second this tile will absorb, indexed by the name of each absorbed pollution type.

**Read type:** Dictionary[`string`, `double`]

### is_foundation

True if this tile can be used as a foundation for other tiles, false otherwise. Foundation tiles can be [hidden](runtime:LuaTile::hidden_tile).

**Read type:** `boolean`

### allows_being_covered

True if this tile can be [hidden](runtime:LuaTile::hidden_tile) or replaced by another tile through player actions.

**Read type:** `boolean`

### check_collision_with_entities

True if building this tile should check for colliding entities above and prevent building if such are found. Also during mining tiles above this tile checks for entities colliding with this tile and prevents mining if such are found.

**Read type:** `boolean`

### destroys_dropped_items

**Read type:** `boolean`

### max_health

**Read type:** `float`

### weight

**Read type:** `Weight`

### default_cover_tile

**Read type:** `LuaTilePrototype`

**Optional:** Yes

### frozen_variant

**Read type:** `LuaTilePrototype`

**Optional:** Yes

### thawed_variant

**Read type:** `LuaTilePrototype`

**Optional:** Yes

### trigger_effect

**Read type:** Array[`TriggerEffectItem`]

**Optional:** Yes

### default_destroyed_dropped_item_trigger

**Read type:** Array[`TriggerItem`]

**Optional:** Yes

### scorch_mark_color

**Read type:** `Color`

**Optional:** Yes

### bound_decoratives

**Read type:** Array[`LuaDecorativePrototype`]

**Optional:** Yes

### ambient_sounds_group

**Read type:** `LuaTilePrototype`

**Optional:** Yes

### factoriopedia_alternative

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

**Read type:** `LuaTilePrototype`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

