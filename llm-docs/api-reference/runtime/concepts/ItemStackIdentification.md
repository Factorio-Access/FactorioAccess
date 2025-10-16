# ItemStackIdentification

An item may be specified in one of three ways.

**Type:** `string` | `ItemStackDefinition` | `LuaItemStack`

## Examples

```
```
-- All of these lines specify an item stack of one iron plate
{name="iron-plate"}
{name="iron-plate", count=1}
{name="iron-plate", count=1, quality="normal"}
```
```

```
```
-- This is a stack of 47 copper plates
{name="copper-plate", count=47}
```
```

```
```
--These are both full stacks of iron plates (for iron-plate, a full stack is 100 plates)
"iron-plate"
{name="iron-plate", count=100}
```
```

