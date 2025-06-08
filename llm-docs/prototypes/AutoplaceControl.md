# AutoplaceControl

A setting in the map creation GUI. Used by the [autoplace system](prototype:AutoplaceSpecification::control).

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### category

**Type:** 

Controls in what tab the autoplace is shown in the map generator GUI.

### Optional Properties

#### can_be_disabled

**Type:** `boolean`

Whether there is an "enable" checkbox for the autoplace control in the map generator GUI. If this is false, the autoplace control cannot be disabled from the GUI.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### related_to_fight_achievements

**Type:** `boolean`

Whether this settings being lower than default disables fight related achievements

**Default:** `{'complex_type': 'literal', 'value': False}`

#### richness

**Type:** `boolean`

Sets whether this control's richness can be changed. The map generator GUI will only show the richness slider when the `category` is `"resource"`.

If the autoplace control is used to generate ores, you probably want this to be true.

**Default:** `{'complex_type': 'literal', 'value': False}`

