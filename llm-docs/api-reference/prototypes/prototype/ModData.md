# ModData

Block of arbitrary data set by mods in data stage.

**Parent:** [Prototype](Prototype.md)
**Type name:** `mod-data`

## Properties

### data_type

Arbitrary string that mods can use to declare type of data. Can be used for mod compatibility when one mod declares block of data that is expected to be discovered by another mod.

**Type:** `string`

**Optional:** Yes

**Examples:**

```
data_type = "my-mod.my_structure"
```

### data

**Type:** Dictionary[`string`, `AnyBasic`]

**Required:** Yes

