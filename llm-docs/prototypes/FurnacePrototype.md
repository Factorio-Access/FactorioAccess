# FurnacePrototype

A furnace. Normal furnaces only process "smelting" category recipes, but you can make furnaces that process other [recipe categories](prototype:RecipeCategory). The difference to assembling machines is that furnaces automatically choose their recipe based on input.

**Parent:** `CraftingMachinePrototype`

## Properties

### Mandatory Properties

#### result_inventory_size

**Type:** `ItemStackIndex`

The number of output slots.

#### source_inventory_size

**Type:** `ItemStackIndex`

The number of input slots, but not more than 1.

### Optional Properties

#### cant_insert_at_source_message_key

**Type:** `string`

The locale key of the message shown when the player attempts to insert an item into the furnace that cannot be processed by that furnace. In-game, the locale is provided the `__1__` parameter, which is the localised name of the item.

The locale key is also used with an `_until` suffix for items that cannot be processed until they recipe is unlocked by a technology.

**Default:** `{'complex_type': 'literal', 'value': 'inventory-restriction.cant-be-smelted'}`

#### circuit_connector

**Type:** `[]`



#### circuit_connector_flipped

**Type:** `[]`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### custom_input_slot_tooltip_key

**Type:** `string`

The locale key of the tooltip to be shown in the input slot instead of the automatically generated list of items that fit there

**Default:** `{'complex_type': 'literal', 'value': ''}`

#### default_recipe_finished_signal

**Type:** `SignalIDConnector`



#### default_working_signal

**Type:** `SignalIDConnector`



#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

