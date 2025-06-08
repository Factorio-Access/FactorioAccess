# AssemblingMachinePrototype

An assembling machine - like the assembling machines 1/2/3 in the game, but you can use your own recipe categories.

**Parent:** `CraftingMachinePrototype`

## Properties

### Optional Properties

#### circuit_connector

**Type:** `[]`



#### circuit_connector_flipped

**Type:** `[]`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### default_recipe_finished_signal

**Type:** `SignalIDConnector`



#### default_working_signal

**Type:** `SignalIDConnector`



#### disabled_when_recipe_not_researched

**Type:** `boolean`

Defaults to true if fixed_recipe is not given.

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### enable_logistic_control_behavior

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### fixed_quality

**Type:** `QualityID`

Only loaded when fixed_recipe is provided.

#### fixed_recipe

**Type:** `RecipeID`

The preset recipe of this machine. This machine does not show a recipe selection if this is set. The base game uses this for the [rocket silo](https://wiki.factorio.com/Rocket_silo).

**Default:** `{'complex_type': 'literal', 'value': ''}`

#### fluid_boxes_off_when_no_fluid_recipe

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### gui_title_key

**Type:** `string`

The locale key of the title of the GUI that is shown when the player opens the assembling machine. May not be longer than 200 characters.

**Default:** `{'complex_type': 'literal', 'value': ''}`

#### ingredient_count

**Type:** `uint16`

Sets the maximum number of ingredients this machine can craft with. Any recipe with more ingredients than this will be unavailable in this machine.

This only counts item ingredients, not fluid ingredients! This means if ingredient count is 2, and the recipe has 2 item ingredients and 1 fluid ingredient, it can still be crafted in the machine.

**Default:** `{'complex_type': 'literal', 'value': 65535}`

#### max_item_product_count

**Type:** `uint16`



**Default:** `{'complex_type': 'literal', 'value': 65535}`

