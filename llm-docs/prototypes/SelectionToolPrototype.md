# SelectionToolPrototype

Used in the base game as a base for the blueprint item and the deconstruction item.

**Parent:** `ItemWithLabelPrototype`

## Properties

### Mandatory Properties

#### alt_select

**Type:** `SelectionModeData`



#### select

**Type:** `SelectionModeData`



### Optional Properties

#### alt_reverse_select

**Type:** `SelectionModeData`

Settings for how the selection tool alt-reverse-selects things in-game (using SHIFT + Right mouse button).

#### always_include_tiles

**Type:** `boolean`

If tiles should be included in the selection regardless of entities also being in the selection. This is a visual only setting.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### mouse_cursor

**Type:** `MouseCursorID`



**Default:** `{'complex_type': 'literal', 'value': 'selection-tool-cursor'}`

#### reverse_select

**Type:** `SelectionModeData`



#### skip_fog_of_war

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### super_forced_select

**Type:** `SelectionModeData`



