# ItemStackDefinition

**Type:** Table

## Parameters

### ammo

Amount of ammo in the ammo items in the stack.

**Type:** `float`

**Optional:** Yes

### count

Number of items the stack holds. Defaults to `1`.

**Type:** `ItemCountType`

**Optional:** Yes

### custom_description

Description of the items with tags in the stack.

**Type:** `LocalisedString`

**Optional:** Yes

### durability

Durability of the tool items in the stack.

**Type:** `double`

**Optional:** Yes

### health

Health of the items in the stack. Defaults to `1.0`.

**Type:** `float`

**Optional:** Yes

### name

Prototype name of the item the stack holds.

**Type:** `string`

**Required:** Yes

### quality

Quality of the item the stack holds. Defaults to `"normal"`.

**Type:** `string`

**Optional:** Yes

### spoil_percent

The spoil percent for this item if the item can spoil. Defaults to `0`.

**Type:** `double`

**Optional:** Yes

### tags

Tags of the items with tags in the stack.

**Type:** Array[`string`]

**Optional:** Yes

