# LuaTilePrototype

Prototype of a tile.

**Parent:** `LuaPrototypeBase`

## Attributes

### absorptions_per_second

**Type:** `dictionary<`string`, `double`>` _(read-only)_

A table of pollution emissions per second this tile will absorb, indexed by the name of each absorbed pollution type.

### allowed_neighbors

**Type:** `dictionary<`string`, `LuaTilePrototype`>` _(read-only)_



### allows_being_covered

**Type:** `boolean` _(read-only)_

True if this tile can be [hidden](runtime:LuaTile::hidden_tile) or replaced by another tile through player actions.

### ambient_sounds_group

**Type:** `LuaTilePrototype` _(read-only)_



### automatic_neighbors

**Type:** `boolean` _(read-only)_



### autoplace_specification

**Type:** `AutoplaceSpecification` _(read-only)_

Autoplace specification for this prototype, if any.

### bound_decoratives

**Type:** ``LuaDecorativePrototype`[]` _(read-only)_



### can_be_part_of_blueprint

**Type:** `boolean` _(read-only)_

False if this tile is not allowed in blueprints regardless of the ability to build it.

### check_collision_with_entities

**Type:** `boolean` _(read-only)_

True if building this tile should check for colliding entities above and prevent building if such are found. Also during mining tiles above this tile checks for entities colliding with this tile and prevents mining if such are found.

### collision_mask

**Type:** `CollisionMask` _(read-only)_

The collision mask this tile uses

### decorative_removal_probability

**Type:** `float` _(read-only)_

The probability that decorative entities will be removed from on top of this tile when this tile is generated.

### default_cover_tile

**Type:** `LuaTilePrototype` _(read-only)_



### default_destroyed_dropped_item_trigger

**Type:** ``TriggerItem`[]` _(read-only)_



### destroys_dropped_items

**Type:** `boolean` _(read-only)_



### factoriopedia_alternative

**Type:** `LuaTilePrototype` _(read-only)_

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

### fluid

**Type:** `LuaFluidPrototype` _(read-only)_

The fluid offshore pump produces on this tile, if any.

### frozen_variant

**Type:** `LuaTilePrototype` _(read-only)_



### is_foundation

**Type:** `boolean` _(read-only)_

True if this tile can be used as a foundation for other tiles, false otherwise. Foundation tiles can be [hidden](runtime:LuaTile::hidden_tile).

### items_to_place_this

**Type:** ``ItemStackDefinition`[]` _(read-only)_

Items that when placed will produce this tile, if any. Construction bots will choose the first item in the list to build this tile.

### layer

**Type:** `uint` _(read-only)_



### map_color

**Type:** `Color` _(read-only)_



### max_health

**Type:** `float` _(read-only)_



### mineable_properties

**Type:** `unknown` _(read-only)_



### needs_correction

**Type:** `boolean` _(read-only)_

If this tile needs correction logic applied when it's generated in the world.

### next_direction

**Type:** `LuaTilePrototype` _(read-only)_

The next direction of this tile, if any. Used when a tile has multiple directions (such as hazard concrete)

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### placeable_by

**Type:** ``SimpleItemStack`[]` _(read-only)_



### scorch_mark_color

**Type:** `Color` _(read-only)_



### thawed_variant

**Type:** `LuaTilePrototype` _(read-only)_



### trigger_effect

**Type:** ``TriggerEffectItem`[]` _(read-only)_



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### vehicle_friction_modifier

**Type:** `float` _(read-only)_



### walking_speed_modifier

**Type:** `float` _(read-only)_



### weight

**Type:** `double` _(read-only)_



