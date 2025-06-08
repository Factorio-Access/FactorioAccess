# UpgradeItemPrototype

An [upgrade planner](https://wiki.factorio.com/Upgrade_planner).

**Parent:** `SelectionToolPrototype`

## Properties

### Mandatory Properties

#### alt_select

**Type:** `SelectionModeData`

The [SelectionModeData::mode](prototype:SelectionModeData::mode) is hardcoded to `"cancel-upgrade"`.

The filters are parsed, but then ignored and forced to be empty.

#### select

**Type:** `SelectionModeData`

The [SelectionModeData::mode](prototype:SelectionModeData::mode) is hardcoded to `"upgrade"`.

The filters are parsed, but then ignored and forced to be empty.

#### stack_size

**Type:** `1`

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

### Optional Properties

#### always_include_tiles

**Type:** `boolean`

This property is hardcoded to `false`.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### draw_label_for_cursor_render

**Type:** `boolean`

If the item will draw its label when held in the cursor in place of the item count.

**Default:** `{'complex_type': 'literal', 'value': True}`

