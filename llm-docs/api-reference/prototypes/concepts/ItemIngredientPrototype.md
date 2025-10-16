# ItemIngredientPrototype

An item ingredient definition.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"item"`

**Required:** Yes

### name

**Type:** `ItemID`

**Required:** Yes

### amount

Cannot be `0`.

**Type:** `uint16`

**Required:** Yes

### ignored_by_stats

Amount that should not be included in the consumption statistics, typically with a matching product having the same amount set as [ignored_by_stats](prototype:ItemProductPrototype::ignored_by_stats).

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

## Examples

```
```
{type="item", name="steel-plate", amount=8}
```
```

```
```
{type="item", name="iron-plate", amount=12}
```
```

