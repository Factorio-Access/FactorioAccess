--[[
A circular, static list of options.

This solves the problem where there's a property, it's got a few values, and
each of those values has a label or something.  The property could change at any
time out from under the mod, and it needs to be tracked.

Lists take the form:

```
{
   entries = {
      { key = defines.whatever, value = { label = "foo" } }
      ... and so on
   },
   options = {
      comparer = func, -- defaults to ==, see below.
   },
}
```

Which looks like a dictionary because it is, but a poor man's ordered one.  The
functions in this file take such lists, and can answer the question what is
previous/current/next, based on a fed-in value.

sometimes, it is the case that one wishes to use a more complex key. For
example, a tuple of items.  In this case, one may override the comparison by
setting options.comparer to a function taking two arguments, and returning true
if and only if they are equal (and otherwise false).  This module provides one
such helper, `tuples`, which is useful in the case of state machines whose state
is more than one variable.  For an example of this, see
ui/low-level/multistate-switch.lua, and also see the comments on tuples for
additional information.

A helper, kv_list, can be used like this:

```
kv_list{{ key1, value1 }, { key2, value2 }, ... }
```

To build these inline without dealing with the verbose syntax.  To do this with
a comparer:

```
kv_list({...}, comparer)
```

Note that during a single Lua call--a single event handler, in other words--the
mod "owns" the state and fields will only change because the mod did something.

This module does *not* handle the case of duplicate keys (so, no inventories;
the user won't be able to get past the second instance) and it does *not* handle
the case of missing values (it will hard crash intentionally).  It does handle
appending and reordering keys.  The point is things like circuit networks where
there are some fixed values and a property, not more complex things.  By the
fact that it doesn't handle missing values, it doesn't handle empty lists either
(no values are  found in an empty list).

Operations are all O(N).
]]
local math_helpers = require("math-helpers")

local mod = {}

mod.ANY = {}

--[[
If the keys in this list need to be tuples, this comparer will allow for that by
comparing field by field in an array. For example, { true, "value"}.

A magical constant `ANY` exposed in this module will match any value. Consider
this list of circuit network states:

```
{ false, ANY }
{ true, holding }
{ true, pulsing }
```

If the object is off (the first state) then the second field doesn't matter, and
we wish to stil move to the second entry.  `ANY` is useful in this case.  The
requirement for safe usage is that any use of `ANY` is such that the other
fields of the tuple uniquely identify the state. For example:

```
{ 1, ANY }
{ 1, 2}
```

Is a list with duplicates because `{ 1, ANY }` matches `{ 1, 2 }`.
]]

function mod.tuples(a, b)
   if #a ~= #b then return false end
   for i = 1, #a do
      if a[i] ~= b[i] and a[i] ~= mod.ANY and b[i] ~= mod.ANY then return false end
   end

   return true
end

function mod.kv_list(list, comparer)
   local vals = {}
   for i = 1, #list do
      vals[i] = { key = list[i][1], value = list[i][2] }
   end
   return {
      values = vals,
      options = { comparer = comparer },
   }
end

local function find_key_index_or_die(list, key)
   local cmp = list.options.comparer or rawequal
   for i = 1, #list.values do
      if cmp(list.values[i].key, key) then return i end
   end

   error("Key " .. serpent.block(key) .. " not in this list" .. serpent.block(list))
end

--[[
Returns the current item, as a table with fields key and value.  For
convenience, field wrapped is set to false (see prev/next for what that's for)

This is basically lookup, but so named because the key is the current
item--you're owning the place the index is stored, not this module, but it is
still an index.
]]
function mod.current(list, key)
   local i = find_key_index_or_die(list, key)
   return { key = list.values[i].key, value = list.values[i].value, wrapped = false }
end

--[[
next and prev are the movement functions, which move forward by one element or
backward by one element, respectively.  They return a table with fields key,
value, and wrapped, where key and value match the keys and values in the list,
and wrapped is true if this operation wrapped around to the other end of the
list.
]]

function mod.next(list, current_key)
   local i = find_key_index_or_die(list, current_key)
   local next_i = math_helpers.mod1(i + 1, #list.values)
   -- <= because lists of 1 item always wrap back to the same index.
   local wrapped = next_i <= i
   return { key = list.values[next_i].key, value = list.values[next_i].value, wrapped = wrapped }
end

function mod.prev(list, current_key)
   local i = find_key_index_or_die(list, current_key)
   local prev_i = math_helpers.mod1(i - 1, #list.values)
   -- >= because lists of 1 item always wrap back to the same index.
   local wrapped = prev_i >= i
   return { key = list.values[prev_i].key, value = list.values[prev_i].value, wrapped = wrapped }
end

return mod
