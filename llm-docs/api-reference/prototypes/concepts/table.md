# table

A simple [Lua table](http://www.lua.org/pil/2.5.html). An array is a table that uses continuous integer keys starting at `1`, while a dictionary can use numeric or string keys in any order or combination.

Tables used by prototypes may be parsed via an internal class called "property tree". Errors that reference this class treat tables as 0-indexed. For example `Value must be a number in property tree at ROOT.technology.steel-plate-productivity.effects[0].change` refers to element 0 of the property tree array which in Lua is at index 1.

**Type:** `builtin`

