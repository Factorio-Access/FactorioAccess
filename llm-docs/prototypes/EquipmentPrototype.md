# EquipmentPrototype

Abstract base of all equipment modules. Equipment modules can be inserted into [equipment grids](prototype:EquipmentGridPrototype).

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### categories

**Type:** ``EquipmentCategoryID`[]`

Sets the categories of the equipment. It can only be inserted into [grids](prototype:EquipmentGridPrototype::equipment_categories) with at least one matching category.

#### energy_source

**Type:** `ElectricEnergySource`



#### shape

**Type:** `EquipmentShape`

How big this equipment should be in the grid and whether it should be one solid rectangle or of a custom shape.

#### sprite

**Type:** `Sprite`

The graphics to use when this equipment is shown inside an equipment grid.

### Optional Properties

#### background_border_color

**Type:** `Color`

The color that the border of the background of this equipment should have when shown inside an equipment grid.

**Default:** `equipment_default_background_border_color in utility constants`

#### background_color

**Type:** `Color`

The color that the background of this equipment should have when shown inside an equipment grid.

**Default:** `equipment_default_background_color in utility constants`

#### grabbed_background_color

**Type:** `Color`

The color that the background of this equipment should have when held in the players hand and hovering over an equipment grid.

**Default:** `equipment_default_grabbed_background_color in utility constants`

#### take_result

**Type:** `ItemID`

Name of the item prototype that should be returned to the player when they remove this equipment from an equipment grid.

**Default:** ``name` of this prototype`

