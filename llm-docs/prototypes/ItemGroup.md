# ItemGroup

An item group. Item groups are the tabs shown above the list of craftable items in the player's inventory GUI. The built-in groups are "logistics", "production", "intermediate-products" and "combat" but mods can define their own.

Items are sorted into item groups by sorting them into a [subgroup](prototype:ItemPrototype::subgroup) which then belongs to an [item group](prototype:ItemSubGroup::group).

**Parent:** `Prototype`

## Properties

### Optional Properties

#### icon

**Type:** `FileName`

Path to the icon that is shown to represent this item group.

Mandatory if `icons` is not defined.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

The base game uses 128px icons for item groups.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

The icon that is shown to represent this item group. Can't be an empty array.

#### order_in_recipe

**Type:** `Order`

Item ingredients in recipes are ordered by item group. The `order_in_recipe` property can be used to specify the ordering in recipes without affecting the inventory order.

**Default:** `The `order` of this item group.`

