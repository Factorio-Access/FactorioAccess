# LootItem

The items generated when an [EntityWithHealthPrototype](prototype:EntityWithHealthPrototype) is killed.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### item

The item to spawn.

**Type:** `ItemID`

**Required:** Yes

### probability

`0` is 0% and `1` is 100%. Must be `> 0`.

**Type:** `double`

**Optional:** Yes

**Default:** 1

### count_min

**Type:** `double`

**Optional:** Yes

**Default:** 1

### count_max

Must be `> 0`.

**Type:** `double`

**Optional:** Yes

**Default:** 1

