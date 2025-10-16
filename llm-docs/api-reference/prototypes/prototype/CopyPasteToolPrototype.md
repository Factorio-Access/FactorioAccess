# CopyPasteToolPrototype

A copy-paste or cut-paste tool.

**Parent:** [SelectionToolPrototype](SelectionToolPrototype.md)
**Type name:** `copy-paste-tool`

## Properties

### cuts

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### stack_size

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

**Type:** `1`

**Required:** Yes

**Overrides parent:** Yes

**Examples:**

```
stack_size = 1
```

### always_include_tiles

This property is hardcoded to `false`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Overrides parent:** Yes

### select

The filters are parsed, but then ignored and forced to be empty.

**Type:** `SelectionModeData`

**Required:** Yes

**Overrides parent:** Yes

### alt_select

The filters are parsed, but then ignored and forced to be empty.

**Type:** `SelectionModeData`

**Required:** Yes

**Overrides parent:** Yes

