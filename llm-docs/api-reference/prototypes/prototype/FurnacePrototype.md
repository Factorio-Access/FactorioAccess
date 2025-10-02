# FurnacePrototype

A furnace. Normal furnaces only process "smelting" category recipes, but you can make furnaces that process other [recipe categories](prototype:RecipeCategory). The difference to assembling machines is that furnaces automatically choose their recipe based on input.

**Parent:** [CraftingMachinePrototype](CraftingMachinePrototype.md)
**Type name:** `furnace`

## Properties

### result_inventory_size

The number of output slots.

**Type:** `ItemStackIndex`

**Required:** Yes

### source_inventory_size

The number of input slots, but not more than 1.

**Type:** `ItemStackIndex`

**Required:** Yes

### cant_insert_at_source_message_key

The locale key of the message shown when the player attempts to insert an item into the furnace that cannot be processed by that furnace. In-game, the locale is provided the `__1__` parameter, which is the localised name of the item.

The locale key is also used with an `_until` suffix for items that cannot be processed until they recipe is unlocked by a technology.

**Type:** `string`

**Optional:** Yes

**Default:** "inventory-restriction.cant-be-smelted"

### custom_input_slot_tooltip_key

The locale key of the tooltip to be shown in the input slot instead of the automatically generated list of items that fit there

**Type:** `string`

**Optional:** Yes

**Default:** ""

### circuit_connector

**Type:** (`CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`)

**Optional:** Yes

### circuit_connector_flipped

**Type:** (`CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`)

**Optional:** Yes

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

