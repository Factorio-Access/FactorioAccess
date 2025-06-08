# BlueprintBookPrototype

A [blueprint book](https://wiki.factorio.com/Blueprint_book).

**Parent:** `ItemWithInventoryPrototype`

## Properties

### Mandatory Properties

#### inventory_size

**Type:** 

The inventory size of the item.

#### stack_size

**Type:** `1`

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

### Optional Properties

#### draw_label_for_cursor_render

**Type:** `boolean`

If the item will draw its label when held in the cursor in place of the item count.

**Default:** `{'complex_type': 'literal', 'value': True}`

