# ItemToPlace

Item that when placed creates this entity/tile.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### item

The item used to place this entity/tile.

**Type:** `ItemID`

**Required:** Yes

### count

How many items are used to place one of this entity/tile. Can't be larger than the stack size of the item.

**Type:** `ItemCountType`

**Required:** Yes

## Examples

```
```
{item = "iron-chest", count = 1}
```
```

