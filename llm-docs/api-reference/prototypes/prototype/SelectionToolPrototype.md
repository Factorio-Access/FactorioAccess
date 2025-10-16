# SelectionToolPrototype

Used in the base game as a base for the blueprint item and the deconstruction item.

**Parent:** [ItemWithLabelPrototype](ItemWithLabelPrototype.md)
**Type name:** `selection-tool`

## Properties

### select

**Type:** `SelectionModeData`

**Required:** Yes

### alt_select

**Type:** `SelectionModeData`

**Required:** Yes

### super_forced_select

**Type:** `SelectionModeData`

**Optional:** Yes

### reverse_select

**Type:** `SelectionModeData`

**Optional:** Yes

### alt_reverse_select

Settings for how the selection tool alt-reverse-selects things in-game (using SHIFT + Right mouse button).

**Type:** `SelectionModeData`

**Optional:** Yes

### always_include_tiles

If tiles should be included in the selection regardless of entities also being in the selection. This is a visual only setting.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### mouse_cursor

**Type:** `MouseCursorID`

**Optional:** Yes

**Default:** "selection-tool-cursor"

### skip_fog_of_war

**Type:** `boolean`

**Optional:** Yes

**Default:** False

