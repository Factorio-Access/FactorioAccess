# Tags

A dictionary of string to the four basic Lua types: `string`, `boolean`, `number`, `table`.

Note that the API returns tags as a simple table, meaning any modifications to it will not propagate back to the game. Thus, to modify a set of tags, the whole table needs to be written back to the respective property.

Tables inside Tags that have numeric keys but are not sequences (e.g. `tags = {foo = {nil, "something"}}` or `tags = {bar = {[4] = "cat"}}`) will have their keys converted to strings when read back from the game (e.g. `{foo = {["2"] = "something"}}` or `{bar = {["4"] = "cat"}}`). Only sequences without gaps will have their keys maintained as numeric.

**Type:** Dictionary[`string`, `AnyBasic`]

## Examples

```
```
{a = 1, b = true, c = "three", d = {e = "f"}}
```
```

