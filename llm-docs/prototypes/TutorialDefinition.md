# TutorialDefinition

The definition of the tutorial to be used in the tips and tricks, see [TipsAndTricksItem](prototype:TipsAndTricksItem). The actual tutorial scripting code is defined in the tutorial scenario. The scenario must be placed in the `tutorials` folder in the mod.

**Parent:** `PrototypeBase`

## Properties

### Mandatory Properties

#### scenario

**Type:** `string`

Name of the folder for this tutorial scenario in the [`tutorials` folder](https://wiki.factorio.com/Tutorial:Mod_structure#Subfolders).

### Optional Properties

#### order

**Type:** `Order`

Used to order prototypes in inventory, recipes and GUIs. May not exceed a length of 200 characters.

**Default:** `Value of `name``

