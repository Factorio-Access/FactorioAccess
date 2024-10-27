--[[
Some common table helping algorithms.

there's a number of table things like removing invalid entities which we need
everywhere efficienhtly; this file does that.
]]

local mod = {}

--[[
Remove all items from a given array where the given callback returns true by
shuffling to the end and then deleting them.  The order of the returned array is
unspecified.

The name comes from Rust's standard library; they do an ordered variant called
retain.

Complexity: fast O(N)
]]
---@param a any[]
---@param filter function(any): boolean
function mod.retain_unordered(a, filter)
   -- a is a sequence. For loops only evaluate the length once. We will be
   -- decreasing the length as we go.  We must "hold" at a given index until we
   -- find an invalid entity as well.  We are done when we get to the point of
   -- hitting a nil.  The initial back is (because lua) the length of the array.
   -- This decreases every time an invalid entry is found.
   local back = #a
   local i = 1

   while true do
      local ent = a[i]
      if ent == nil then
         return
      elseif filter(ent) then
         -- It's good, we aren't going to be getting rid of it, move on.
         i = i + 1
      else
         -- If i = back and this is invalid, then it'll swap with itself and
         -- remain even though it shouldn't.  Also, that means we're done.
         if i == back then
            a[i] = nil
            return
         end
         local back_ent = a[back]
         a[back] = nil
         a[i] = back_ent
         back = back - 1
         -- Don't increment i because what i is pointing at just changed and
         -- may, itself, be invalid.
      end
   end
end

-- Same as table.insert(x), except taking multiple arguments and pushing them to
-- the back left to right. Behavior is incredibly undefined is nil is passed
-- (LuaLS helps guard against it)
--
---@param destination any[]
---@param ... any
function mod.multipush(destination, ...)
   local packed = table.pack(...)
   mod.merge_arrays(destination, packed)
end

-- Merges two arrays.  The second array is pushed into the first.  That is, it
-- is *modified* in place.
--
---@param destination any[]
---@param array any[]
function mod.merge_arrays(destination, array)
   -- faster: table.insert is a hashtable lookup.
   local tins = table.insert

   for i = 1, #array do
      tins(destination, array[i])
   end
end

-- Takes an array { a, b, c } and writes to to a set { a = true, b = true, c =
-- true }.
---@param set table<any, true>
---@param array any[]
function mod.array_to_set(set, array)
   for i = 1, #array do
      set[array[i]] = true
   end
end

-- Merge the second mapping into the first (e.g. table of non-array keys)
---@param dest table<any, any>
---@param src table<any, any>
function mod.merge_mappings(dest, src)
   for k, v in pairs(src) do
      dest[k] = v
   end
end

local empty_table_defaulter = {
   __index = function(t, i)
      rawset(t, i, {})
      return t[i]
   end,
}
if script then script.register_metatable("fa.TableHelpers.EmptyTableDefaulter", empty_table_defaulter) end

--[[
Returnn an empty table.  When an index not yet present in the table is accessed,
fill it in with an empty table as well.  If the optional argument initial is
provided, wrap that instead and return it.

This means code like `a[5][4]` does not need to check if 5 is present.  This is
very useful for making sets of 2d points and objects, but the cost is that a
check like `if set[x][y]` will fill in x with an empty table even if the item is
not present (but that's usually fine, because the most common operation is to
then add it).

IMPORTANT: the obvious extension is to allow changing ther default value.  That
doesn't work because storage cannot hold unregistered metatables.  There'd need
to be a unique name each.  Other methods result in losing the benefit or are
much more complex and should be avoided.
]]
function mod.defaulting_table(initial)
   local r = initial or {}
   assert(type(r) == "table")
   setmetatable(r, empty_table_defaulter)
   return r
end

--[[
Return a metatable which will, when an index is not found, iterate over all of
the tables specified, left to right, before giving up.

There is a particularly useful trick which allows us to provide options to
functions which aren't safe for storage, usually callbacks.  To do it, we make
the outermost table storage-safe and store that.  Then, we hide the
non-storage-safe things away in tables which are consulted by the metatable,
since that never "pulls values up".  This comes with a negligible performance
hit, but it's usually only a couple levels and for a function, which means in
context that's not too bad (plus, anything truly performance sensitive will
cache in a local anyway).  See e.g. ds.work_queue, scanner.backends.simple.

At least one table must be specified.
]]
function mod.nested_indexer(...)
   local args = table.pack(...)
   assert(#args > 0, "At least one table must be specified")
   local cache = {}

   return {
      __index = function(tab, key)
         local c = cache[key]
         if c then return c end

         for i = #args, 1, -1 do
            local attempt = args[i][key]
            if attempt then
               cache[key] = attempt
               return attempt
            end
         end

         return nil
      end,
   }
end

-- Find the index of a given element in a list. Return nil for not found.
function mod.find_index_of(array, element)
   for i = 1, #array do
      if array[i] == element then return i end
   end

   -- Not found.
   return nil
end

-- Convert a key-value table to an array of 2-tuples (k, v) then sort that by
-- k.
function mod.set_to_sorted_array(set)
   local array = {}
   for k, v in pairs(set) do
      table.insert(array, { k, v })
   end
   table.sort(array, function(a, b)
      return a[1] < b[1]
   end)
   return array
end

return mod
