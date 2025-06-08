# DeconstructionItemPrototype

A [deconstruction planner](https://wiki.factorio.com/Deconstruction_planner).

**Parent:** `SelectionToolPrototype`

## Properties

### Mandatory Properties

#### alt_select

**Type:** `SelectionModeData`

The [SelectionModeData::mode](prototype:SelectionModeData::mode) is hardcoded to `"cancel-deconstruct"`.

The filters are parsed, but then ignored and forced to be empty.

#### select

**Type:** `SelectionModeData`

The [SelectionModeData::mode](prototype:SelectionModeData::mode) is hardcoded to `"deconstruct"`.

The filters are parsed, but then ignored and forced to be empty.

#### stack_size

**Type:** `1`

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

### Optional Properties

#### always_include_tiles

**Type:** `boolean`

This property is hardcoded to `false`.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### entity_filter_count

**Type:** `ItemStackIndex`

Can't be > 255.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### tile_filter_count

**Type:** `ItemStackIndex`

Can't be > 255.

**Default:** `{'complex_type': 'literal', 'value': 0}`

