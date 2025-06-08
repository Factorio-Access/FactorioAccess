# EntityWithOwnerPrototype

Abstract base of all entities with a force in the game. These entities have a [LuaEntity::unit_number](runtime:LuaEntity::unit_number) during runtime. Can be high priority [military targets](https://wiki.factorio.com/Military_units_and_structures).

**Parent:** `EntityWithHealthPrototype`

## Properties

### Optional Properties

#### allow_run_time_change_of_is_military_target

**Type:** `boolean`

If this is true, this entity's `is_military_target` property can be changed during runtime (on the entity, not on the prototype itself).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### is_military_target

**Type:** `boolean`

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### quality_indicator_scale

**Type:** `double`

The default scale is based on the tile distance of the shorter dimension. Where size 3 results into scale 1. The default minimum is 0.5 and maximum 1.0.

**Default:** `Calculated based on entity tile_width and height`

#### quality_indicator_shift

**Type:** `Vector`

The shift from the bottom left corner of the selection box.

