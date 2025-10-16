# BlueprintItemPrototype

A [blueprint](https://wiki.factorio.com/Blueprint).

**Parent:** [SelectionToolPrototype](SelectionToolPrototype.md)
**Type name:** `blueprint`

## Properties

### stack_size

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

**Type:** `1`

**Required:** Yes

**Overrides parent:** Yes

**Examples:**

```
stack_size = 1
```

### draw_label_for_cursor_render

Whether the item will draw its label when held in the cursor in place of the item count.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

**Overrides parent:** Yes

### select

The [SelectionModeData::mode](prototype:SelectionModeData::mode) is hardcoded to `"blueprint"`.

The filters are parsed, but then ignored and forced to be empty.

**Type:** `SelectionModeData`

**Required:** Yes

**Overrides parent:** Yes

### alt_select

The [SelectionModeData::mode](prototype:SelectionModeData::mode) is hardcoded to `"blueprint"`.

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

