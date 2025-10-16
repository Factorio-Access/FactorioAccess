# ItemSubGroup

An item subgroup. Item subgroups are the rows in the recipe list in the player's inventory GUI. The subgroup of a prototype also determines its item [group](prototype:ItemGroup::group) (tab in the recipe list).

The built-in subgroups can be found [here](https://wiki.factorio.com/Data.raw#item-subgroup). See [ItemPrototype::subgroup](prototype:ItemPrototype::subgroup) for setting the subgroup of an item.

**Parent:** [Prototype](Prototype.md)
**Type name:** `item-subgroup`

## Examples

```
{
  type = "item-subgroup",
  name = "train-transport",
  group = "logistics",
  order = "e"
}
```

## Properties

### group

The item group this subgroup is located in.

**Type:** `ItemGroupID`

**Required:** Yes

