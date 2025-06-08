# ItemWithInventoryPrototype

The inventory allows setting player defined filters similar to cargo wagon inventories.

**Parent:** `ItemWithLabelPrototype`

## Properties

### Mandatory Properties

#### inventory_size

**Type:** `ItemStackIndex`

The inventory size of the item.

#### stack_size

**Type:** `1`

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

### Optional Properties

#### filter_message_key

**Type:** `string`

The locale key used when the player attempts to put an item that doesn't match the filter rules into the item-with-inventory.

**Default:** `{'complex_type': 'literal', 'value': 'item-limitation.item-not-allowed-in-this-container-item'}`

#### filter_mode

**Type:** 

This determines how filters are applied. If no filters are defined this is automatically set to "none".

**Default:** `{'complex_type': 'literal', 'value': 'whitelist'}`

#### item_filters

**Type:** ``ItemID`[]`

A list of explicit item names to be used as filters.

#### item_group_filters

**Type:** ``ItemGroupID`[]`

A list of explicit item group names to be used as filters.

#### item_subgroup_filters

**Type:** ``ItemSubGroupID`[]`

A list of explicit [item subgroup](prototype:ItemSubGroup) names to be used as filters.

