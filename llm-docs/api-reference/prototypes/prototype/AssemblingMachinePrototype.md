# AssemblingMachinePrototype

An assembling machine - like the assembling machines 1/2/3 in the game, but you can use your own recipe categories.

**Parent:** [CraftingMachinePrototype](CraftingMachinePrototype.md)
**Type name:** `assembling-machine`

## Properties

### fixed_recipe

The preset recipe of this machine. This machine does not show a recipe selection if this is set. The base game uses this for the [rocket silo](https://wiki.factorio.com/Rocket_silo).

**Type:** `RecipeID`

**Optional:** Yes

**Default:** ""

### fixed_quality

Only loaded when fixed_recipe is provided.

**Type:** `QualityID`

**Optional:** Yes

### gui_title_key

The locale key of the title of the GUI that is shown when the player opens the assembling machine. May not be longer than 200 characters.

**Type:** `string`

**Optional:** Yes

**Default:** ""

### circuit_wire_max_distance

The maximum circuit wire distance for this entity.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### draw_copper_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_circuit_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### default_recipe_finished_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_working_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### enable_logistic_control_behavior

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### ingredient_count

Sets the maximum number of ingredients this machine can craft with. Any recipe with more ingredients than this will be unavailable in this machine.

This only counts item ingredients, not fluid ingredients! This means if ingredient count is 2, and the recipe has 2 item ingredients and 1 fluid ingredient, it can still be crafted in the machine.

**Type:** `uint16`

**Optional:** Yes

**Default:** 65535

### max_item_product_count

**Type:** `uint16`

**Optional:** Yes

**Default:** 65535

### circuit_connector

**Type:** (`CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`)

**Optional:** Yes

### circuit_connector_flipped

**Type:** (`CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`)

**Optional:** Yes

### fluid_boxes_off_when_no_fluid_recipe

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### disabled_when_recipe_not_researched

Defaults to true if `fixed_recipe` is not given.

**Type:** `boolean`

**Optional:** Yes

