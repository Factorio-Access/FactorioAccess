# ItemGroup

An item group. Item groups are the tabs shown above the list of craftable items in the player's inventory GUI. The built-in groups are "logistics", "production", "intermediate-products" and "combat" but mods can define their own.

Items are sorted into item groups by sorting them into a [subgroup](prototype:ItemPrototype::subgroup) which then belongs to an [item group](prototype:ItemSubGroup::group).

**Parent:** [Prototype](Prototype.md)
**Type name:** `item-group`
**Instance limit:** 255

## Examples

```
{
  type = "item-group",
  name = "logistics",
  order = "a",
  icon = "__base__/graphics/item-group/logistics.png",
  icon_size = 128,
}
```

## Properties

### icons

The icon that is shown to represent this item group. Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon that is shown to represent this item group.

Only loaded, and mandatory if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

The base game uses 128px icons for item groups.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### order_in_recipe

Item ingredients in recipes are ordered by item group. The `order_in_recipe` property can be used to specify the ordering in recipes without affecting the inventory order.

**Type:** `Order`

**Optional:** Yes

**Default:** "The `order` of this item group."

