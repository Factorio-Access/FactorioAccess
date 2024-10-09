--[[
Table sorting with memoized scores.

Normal sort in Lua takes function(a, b) ... end and computes the order in the
function.  That's fine for things which are cheap, e.g. just `a < b`, but once
one starts doing math to figure it out it can become quite slow.

Instead, we introduce a scoring function and a function memosort().  This is
like table.sort(table, callback) but callback must return a number, representing
the "score".  For example, this might be the distance from the player.

This interface guarantees exactly one call of the scoring callback per unique
item, no more, no less.  This is to facilitate in-place processing.  For
example, the scanner uses this to sort things which are groups of other things,
while also sorting those other things.  More specifically, we use this there to
allow efficiently finding the closest item in a subcategory, while
simultaneously sorting the subcategories. To be clearer, a call on an array
like:

```
{ 1, 2, 3, 3, 4, 4 }
```

Results only in 4 calls.

A third optional argument may be used to use a cache across more than one
memosort.  This is useful if and only if there is commonality between the sorts.
Such sorts must at minimum use the same exact scoring function.  When this
functionality is used, the scoring callback is *not* called on items which are
in the cache from a previous sort (since doing so would defeat the purpose of
sharing it).
]]
local mod = {}

---@alias fa.memosort.ScoreCallback fun(any): number

---@param  tab any[]
---@param callback fa.memosort.ScoreCallback
---@param cache table?
function mod.memosort(tab, callback, cache)
   cache = cache or {}

   for i = 1, #tab do
      if cache[tab[i]] then goto continue end
      cache[tab[i]] = callback(tab[i])

      ::continue::
   end

   table.sort(tab, function(a, b)
      return cache[a] < cache[b]
   end)
end

return mod
