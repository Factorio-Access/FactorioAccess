# EquipmentPrototype

Abstract base of all equipment modules. Equipment modules can be inserted into [equipment grids](prototype:EquipmentGridPrototype).

**Parent:** [Prototype](Prototype.md)
**Abstract:** Yes

## Properties

### sprite

The graphics to use when this equipment is shown inside an equipment grid.

**Type:** `Sprite`

**Required:** Yes

### shape

How big this equipment should be in the grid and whether it should be one solid rectangle or of a custom shape.

**Type:** `EquipmentShape`

**Required:** Yes

### categories

Sets the categories of the equipment. It can only be inserted into [grids](prototype:EquipmentGridPrototype::equipment_categories) with at least one matching category.

**Type:** Array[`EquipmentCategoryID`]

**Required:** Yes

### energy_source

**Type:** `ElectricEnergySource`

**Required:** Yes

### take_result

Name of the item prototype that should be returned to the player when they remove this equipment from an equipment grid.

**Type:** `ItemID`

**Optional:** Yes

**Default:** "`name` of this prototype"

### background_color

The color that the background of this equipment should have when shown inside an equipment grid.

**Type:** `Color`

**Optional:** Yes

**Default:** "equipment_default_background_color in utility constants"

### background_border_color

The color that the border of the background of this equipment should have when shown inside an equipment grid.

**Type:** `Color`

**Optional:** Yes

**Default:** "equipment_default_background_border_color in utility constants"

### grabbed_background_color

The color that the background of this equipment should have when held in the players hand and hovering over an equipment grid.

**Type:** `Color`

**Optional:** Yes

**Default:** "equipment_default_grabbed_background_color in utility constants"

