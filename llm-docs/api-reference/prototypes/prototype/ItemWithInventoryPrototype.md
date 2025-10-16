# ItemWithInventoryPrototype

The inventory allows setting player defined filters similar to cargo wagon inventories.

**Parent:** [ItemWithLabelPrototype](ItemWithLabelPrototype.md)
**Type name:** `item-with-inventory`

## Properties

### inventory_size

The inventory size of the item.

**Type:** `ItemStackIndex`

**Required:** Yes

### item_filters

A list of explicit item names to be used as filters.

**Type:** Array[`ItemID`]

**Optional:** Yes

**Examples:**

```
item_filters = {"iron-ore", "copper-ore", "coal", "stone"}
```

### item_group_filters

A list of explicit item group names to be used as filters.

**Type:** Array[`ItemGroupID`]

**Optional:** Yes

**Examples:**

```
item_group_filters = {"logistics", "fluids"}
```

### item_subgroup_filters

A list of explicit [item subgroup](prototype:ItemSubGroup) names to be used as filters.

**Type:** Array[`ItemSubGroupID`]

**Optional:** Yes

**Examples:**

```
item_subgroup_filters = {"military-equipment", "tool"}
```

### filter_mode

This determines how filters are applied. If no filters are defined this is automatically set to "none".

**Type:** `"blacklist"` | `"whitelist"`

**Optional:** Yes

**Default:** "whitelist"

**Examples:**

```
filter_mode = "blacklist"
```

### filter_message_key

The locale key used when the player attempts to put an item that doesn't match the filter rules into the item-with-inventory.

**Type:** `string`

**Optional:** Yes

**Default:** "item-limitation.item-not-allowed-in-this-container-item"

### stack_size

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

**Type:** `1`

**Required:** Yes

**Overrides parent:** Yes

**Examples:**

```
stack_size = 1
```

