# TutorialDefinition

The definition of the tutorial to be used in the tips and tricks, see [TipsAndTricksItem](prototype:TipsAndTricksItem). The actual tutorial scripting code is defined in the tutorial scenario. The scenario must be placed in the `tutorials` folder in the mod.

**Parent:** [PrototypeBase](PrototypeBase.md)
**Type name:** `tutorial`

## Properties

### scenario

Name of the folder for this tutorial scenario in the [`tutorials` folder](runtime:mod-structure).

**Type:** `string`

**Required:** Yes

### order

Used to order prototypes in inventory, recipes and GUIs. May not exceed a length of 200 characters.

**Type:** `Order`

**Optional:** Yes

**Default:** "Value of `name`"

**Overrides parent:** Yes

