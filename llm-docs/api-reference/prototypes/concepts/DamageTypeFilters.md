# DamageTypeFilters

**Type:** `Struct` (see below for attributes) | `DamageTypeID` | Array[`DamageTypeID`]

## Properties

*These properties apply when the value is a struct/table.*

### types

The damage types to filter for.

**Type:** `DamageTypeID` | Array[`DamageTypeID`]

**Required:** Yes

### whitelist

Whether this is a whitelist or a blacklist of damage types. Defaults to being a blacklist.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

## Examples

```
```
damage_type_filters = "fire"
```
```

```
```
damage_type_filters = { "fire" } -- more damage types could be specified here
```
```

```
```
damage_type_filters =
{
  whitelist = false, -- optional
  types = "fire"
}
```
```

```
```
damage_type_filters =
{
  whitelist = false, -- optional
  types = { "fire" } -- more damage types could be specified here
}
```
```

