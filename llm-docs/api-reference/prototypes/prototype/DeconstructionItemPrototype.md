# DeconstructionItemPrototype

A [deconstruction planner](https://wiki.factorio.com/Deconstruction_planner).

**Parent:** [SelectionToolPrototype](SelectionToolPrototype.md)
**Type name:** `deconstruction-item`

## Properties

### entity_filter_count

Can't be > 255.

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 0

### tile_filter_count

Can't be > 255.

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 0

### stack_size

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

**Type:** `1`

**Required:** Yes

**Overrides parent:** Yes

**Examples:**

```
stack_size = 1
```

### select

The [SelectionModeData::mode](prototype:SelectionModeData::mode) is hardcoded to `"deconstruct"`.

The filters are parsed, but then ignored and forced to be empty.

**Type:** `SelectionModeData`

**Required:** Yes

**Overrides parent:** Yes

### alt_select

The [SelectionModeData::mode](prototype:SelectionModeData::mode) is hardcoded to `"cancel-deconstruct"`.

The filters are parsed, but then ignored and forced to be empty.

**Type:** `SelectionModeData`

**Required:** Yes

**Overrides parent:** Yes

### always_include_tiles

This property is hardcoded to `false`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Overrides parent:** Yes

