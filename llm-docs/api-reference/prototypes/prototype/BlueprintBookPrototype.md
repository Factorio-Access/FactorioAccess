# BlueprintBookPrototype

A [blueprint book](https://wiki.factorio.com/Blueprint_book).

**Parent:** [ItemWithInventoryPrototype](ItemWithInventoryPrototype.md)
**Type name:** `blueprint-book`

## Properties

### inventory_size

The inventory size of the item.

**Type:** `ItemStackIndex` | `"dynamic"`

**Required:** Yes

**Overrides parent:** Yes

### stack_size

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

**Type:** `1`

**Required:** Yes

**Overrides parent:** Yes

**Examples:**

```
stack_size = 1
```

### draw_label_for_cursor_render

If the item will draw its label when held in the cursor in place of the item count.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

**Overrides parent:** Yes

