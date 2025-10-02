# Order

The order property is a simple `string`. When the game needs to sort prototypes (of the same type), it looks at their order properties and sorts those alphabetically. A prototype with an order string of `"a"` will be listed before other prototypes with order string `"b"` or `"c"`. The `"-"` or `"[]"` structures that can be found in vanilla order strings do *not* have any special meaning.

The alphabetical sorting uses [lexicographical comparison](https://en.wikipedia.org/wiki/Lexicographic_order) to determine if a given prototype is shown before or after another. If the order strings are equal then the game falls back to comparing the prototype names to determine order.

**Type:** `string`

## Examples

```
```
{  -- This item will be shown after the below one
  type = "item",
  name = "item-1",
  order = "ad",
},
{  -- This item will be shown before the above one
  type = "item",
  name = "item-2",
  order = "ab",
}
```
```

```
```
-- The order of special characters can be identified by looking at a UTF-8 character list.
-- This is the order some common characters are sorted in:
"-"
"0"
"9"
"A"
"Z"
"["
"]"
"a"
"z"
-- The following order strings would be ordered thusly then:
"a"
"ab"
"azaaa"  -- "b" is sorted before "z", so "ab" comes before "az", regardless of the letters following it
"b"
"b-zzz"
"b[aaa]" -- "[" is sorted after "-" in UTF-8
"bb"  -- "b" is sorted after "[" in UTF-8
]
```
```

