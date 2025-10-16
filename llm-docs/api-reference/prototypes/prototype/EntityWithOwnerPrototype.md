# EntityWithOwnerPrototype

Abstract base of all entities with a force in the game. These entities have a [LuaEntity::unit_number](runtime:LuaEntity::unit_number) during runtime. Can be high priority [military targets](https://wiki.factorio.com/Military_units_and_structures).

**Parent:** [EntityWithHealthPrototype](EntityWithHealthPrototype.md)
**Abstract:** Yes

## Properties

### is_military_target

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### allow_run_time_change_of_is_military_target

If this is true, this entity's `is_military_target` property can be changed during runtime (on the entity, not on the prototype itself).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### quality_indicator_shift

The shift from the bottom left corner of the selection box.

**Type:** `Vector`

**Optional:** Yes

### quality_indicator_scale

The default scale is based on the tile distance of the shorter dimension. Where size 3 results into scale 1. The default minimum is 0.5 and maximum 1.0.

**Type:** `double`

**Optional:** Yes

**Default:** "Calculated based on entity tile_width and height"

