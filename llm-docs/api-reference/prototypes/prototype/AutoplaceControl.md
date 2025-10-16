# AutoplaceControl

A setting in the map creation GUI. Used by the [autoplace system](prototype:AutoplaceSpecification::control).

**Parent:** [Prototype](Prototype.md)
**Type name:** `autoplace-control`
**Instance limit:** 255

## Properties

### category

Controls in what tab the autoplace is shown in the map generator GUI.

**Type:** `"resource"` | `"terrain"` | `"cliff"` | `"enemy"`

**Required:** Yes

### richness

Sets whether this control's richness can be changed. The map generator GUI will only show the richness slider when the `category` is `"resource"`.

If the autoplace control is used to generate ores, you probably want this to be true.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### can_be_disabled

Whether there is an "enable" checkbox for the autoplace control in the map generator GUI. If this is false, the autoplace control cannot be disabled from the GUI.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### related_to_fight_achievements

Whether this settings being lower than default disables fight related achievements.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### hidden

Hides the autoplace control from the map generation screen.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Overrides parent:** Yes

