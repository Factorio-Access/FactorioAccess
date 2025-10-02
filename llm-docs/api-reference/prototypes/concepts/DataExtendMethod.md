# DataExtendMethod

The data.extend method. It's the primary way to add prototypes to the data table.

The method has two positional function parameters:

- `self` :: [Data](prototype:Data)?: Usually provided by calling `data:extend(otherdata)`, which is syntax sugar for `data.extend(data, otherdata)`.

- `otherdata` :: array[[AnyPrototype](prototype:AnyPrototype)]: A continuous array of non-abstract prototypes.

The data.extend method can also be called with only the `otherdata` argument by calling it directly on data: `data.extend(otherdata)`.

**Type:** `builtin`

## Examples

```
```
data:extend({
  {
    type = "item",
    name = "a-thing",
    icon = "__base__/graphics/icons/coal.png",
    icon_size = 64,
    stack_size = 2
  }
})
```
```

```
```
local recipe_cat =
{
  type = "recipe-category",
  name = "my-category"
}
local assembler =
{
  type = "assembling-machine",
  name = "cool-assembler",
  energy_usage = "30kW",
  energy_source = {type = "void"},
  crafting_speed = 1,
  crafting_categories = {"crafting"}
}

data:extend({recipe_cat, assembler})
```
```

