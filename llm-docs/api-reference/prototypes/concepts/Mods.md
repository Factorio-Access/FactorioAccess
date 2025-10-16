# Mods

A dictionary of mod names to mod versions of all active mods. It can be used to adjust mod functionality based on the presence of other mods.

**Type:** Dictionary[`string`, `string`]

## Examples

```
```
-- executes pineapple only when the pizza mod is active
if mods["pizza"] then
  pineapple()
end
```
```

```
```
-- when the only active mod is the space-age mod with version 2.0.7
-- then this logs
for name, version in pairs(mods) do
  log(name .. " version " .. version) -- => space-age version 2.0.7
end
```
```

