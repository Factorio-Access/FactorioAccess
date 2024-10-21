--[[
The ability to add methods to something, while keeping it safe to save in
storage.

This is how one gets nice APIs like the Factorio entities, where one can
`thing.whatever()`.  Inheritance is not supported, and at least for now fields
on the table must not have the same name as methods, or the field takes
priority.

This is a hard problem because Factorio cannot pass functions through storage,
nor can it restore metatables, unless those metatables are registerd during
control.lua startup.

This module exposes one function, `link`.  It is called like:

```
-- A table of functions. They will be called as f(instance, user, supplied, arguments)
--
-- They must be declared exactly once at module level. They cannot thus contain
-- closures.
local method_table = {}

-- We can use the Lua method declaration syntax and self, to add methods to
-- this table.
function method_table:a_method(an_arg)
   -- Lua adds self for you, this is actually function(self, a_method).
   -- self is a valid variable here, referring to the "instance" (like Python).
end

-- Somewhere, at the top level, make this call, though probably
-- with better naming:
local linker = link_methods('a_unique_string', methods_table)

-- And then to make a "instance", in a function or wherever.  This is the magic.
return linker(instance)
```

Where a_unique_string is unique for the lifetime of the *save*, and the method
table is unique for the lifetime of this run.  That is, the unique string
"names" the methods, but the methods can change (e.g. adding new ones,
renaming...).  This doesn't care whether or not the code moves, or if it's in
the module it was in, or anything--that string just has to be fixed.

There are some minor catches:

- The implementation uses a field _methods_private for itself. This is opaque;
  do not access it.
- As above, no closures, and methods need to be registered at module top level.
- And again as above, no fields with the same names as methods.
- Also, there is a slight perf impact. It shouldn't matter, just don't use this
  in tight math loops.

# Implementation

This is actually just a metatable trick: register new metatables with factorio
on declaration of methods, capturing the methods so declared.  The wrapper then
just installs the unique metatable.
]]

local mod = {}

-- This cache prevents us from having to make unique closures every time, by
-- making the closure only once and then consulting it here.  Keys are unique
-- instances and values sets of bound methods. See the note in Lua 5.2's manual
-- on ephemeron tables, in section 2.5.2.
local bound_cache = {}
setmetatable(bound_cache, {
   __mode = "k",
})

local seenh_unique_names = {}

-- This registers a metatable if and only if running in factorio.
--
-- This is useful because we have self-tests near the end of this file, and
-- those can be run from a shell.
local function maybe_register(name, metatable)
   if script ~= nil and script.register_metatable ~= nil then script.register_metatable(name, metatable) end
end

function mod.link(unique_name, methods_table)
   if seenh_unique_names[unique_name] then error("Attempt to double-register " .. unique_name) end
   seenh_unique_names[unique_name] = true

   local meta_name = unique_name .. "-methods"

   local meta = {
      __index = function(table, key)
         if not methods_table[key] then return nil end

         local cached = bound_cache[table]
         if not cached then
            bound_cache[table] = {}
            cached = bound_cache[table]
         end

         local candidate = cached[key]
         if candidate then return candidate end

         -- Okay, fine, closure time.
         local closed = function(...)
            return methods_table[key](table, ...)
         end
         -- Since the top-level cache is ephemeron, Lua says  it will drop the
         -- values.
         cached[key] = closed
         return closed
      end,
   }

   maybe_register(meta_name, meta)
   return function(instance)
      return setmetatable(instance, meta)
   end
end

-- These self-tests have to play with the gc to verify that the ephemeron table
-- does what we want.
if script == nil then
   print("methods.lua: outside factorio so Running self-tests...")
   -- a simple counter with inc and dec.
   local counter_methods = {}
   function counter_methods:inc(by)
      self.count = self.count + by
   end

   function counter_methods:dec(by)
      self.count = self.count - by
   end

   local linker = mod.link("methods_self_test", counter_methods)
   local instance = { count = 0 }
   linker(instance)

   instance.inc(5)
   assert(instance.count == 5)
   instance.dec(3)
   assert(instance.count == 2)
   -- Make sure this isn't an empty function; that was a bug during development.
   assert(instance.not_a_field == nil)

   -- there should currently be one key in our methods table before gc.
   local count = 0
   for k, v in pairs(bound_cache) do
      count = count + 1
      assert(k == instance)
   end
   assert(count == 1)

   -- Finally verify that ephemeron tables work how we expect.
   instance = nil
   collectgarbage()
   count = 0

   for k, v in pairs(bound_cache) do
      count = count + 1
   end

   assert(count == 0)
end

return mod
