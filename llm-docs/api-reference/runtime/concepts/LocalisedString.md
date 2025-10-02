# LocalisedString

Localised strings are a way to support translation of in-game text. It is an array where the first element is the key and the remaining elements are parameters that will be substituted for placeholders in the template designated by the key.

The key identifies the string template. For example, `"gui-alert-tooltip.attack"` (for the template `"__1__ objects are being damaged"`; see the file `data/core/locale/en.cfg`).

The template can contain placeholders such as `__1__` or `__2__`. These will be replaced by the respective parameter in the LocalisedString. The parameters themselves can be other localised strings, which will be processed recursively in the same fashion. Localised strings can not be recursed deeper than 20 levels and can not have more than 20 parameters.

There are two special flags for the localised string, indicated by the key being a particular string. First, if the key is the empty string (`""`), then all parameters will be concatenated (after processing, if any are localised strings themselves). Second, if the key is a question mark (`"?"`), then the first valid parameter will be used. A parameter can be invalid if its name doesn't match any string template. If no parameters are valid, the last one is returned. This is useful to implement a fallback for missing locale templates.

Furthermore, when an API function expects a localised string, it will also accept a regular string (i.e. not a table) which will not be translated, as well as a number, boolean or `nil`, which will be converted to their textual representation.

**Type:** `string` | `number` | `boolean` | `LuaObject` | `nil` | Array[`LocalisedString`]

## Examples

```
```
-- In the English translation, this will print "No ammo"; in the Czech translation, it will print "Bez munice":
game.player.print({"description.no-ammo"})
-- The 'description.no-ammo' template contains no placeholders, so no further parameters are necessary.
```
```

```
```
-- In the English translation, this will print "Durability: 5/9"; in the Japanese one, it will print "耐久度: 5/9":
game.player.print({"description.durability", 5, 9})
```
```

```
```
-- This will print "hello" in all translations:
game.player.print({"", "hello"})
```
```

```
```
-- This will print "Iron plate: 60" in the English translation and "Eisenplatte: 60" in the German translation.
game.print({"", {"item-name.iron-plate"}, ": ", 60})
```
```

```
```
-- As an example of a localised string with fallback, consider this:
{"?", {"", {"entity-description.furnace"}, "\n"}, {"item-description.furnace"}, "optional fallback"}
-- If 'entity-description.furnace' exists, it is concatenated with "\n" and returned. Otherwise, if 'item-description.furnace'
--  exists, it is returned as-is. Otherwise, "optional fallback" is returned. If this value wasn't specified, the
--  translation result would be "Unknown key: 'item-description.furnace'".
```
```

