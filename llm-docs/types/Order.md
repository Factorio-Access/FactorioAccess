# Order

The order property is a simple `string`. When the game needs to sort prototypes (of the same type), it looks at their order properties and sorts those alphabetically. A prototype with an order string of `"a"` will be listed before other prototypes with order string `"b"` or `"c"`. The `"-"` or `"[]"` structures that can be found in vanilla order strings do *not* have any special meaning.

The alphabetical sorting uses [lexicographical comparison](https://en.wikipedia.org/wiki/Lexicographic_order) to determine if a given prototype is shown before or after another. If the order strings are equal then the game falls back to comparing the prototype names to determine order.

