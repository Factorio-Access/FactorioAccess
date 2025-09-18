--[[
"pointers" to fields in tables.

Consider the circuit network.  It has a number of control behaviors of the form
[ off, or, some, other, options ], where one has a pair of fields--one for the
off/on state and one for the other options.  If we can refer to these fields in
a generic way, then we can pass references to them around and just tell the code
what labels to use this time.  Much of Factorio is like this: some set of fields
pretty similar to each other, and some labels/options that vary.

This module returns a magic table.  You use it like this:

```
local F = require('field-ref')
local reference = F.a.b.c() -- The parens are required.
-- reference may now be used to work with x.a.b.c on anything that has an a.b.c:
local example ={ a = { b = { c = 5 } } }
assert(reference.get(example) == 5)
-- Or you can set it
reference.set(10)
assert(reference.get(example) == 10)
```

An error is thrown if the path encounters a nil on any of the intermediate steps
to the final value but will return nil for the final value itself.

Field references cannot be stored in storage.

(If you just want to use it, you can stop here. Devs who want to know how it
works, read on).

# Implementation

Firstly, paths look like:

```
{ "a", "field", "indexed", "with", 5 }
-- is x.a.field.indexed.with[5]
```

Recall that lua makes no distinction between `a.b` and `a["b"]`--from the
perspective of the C API they're the same thing.  That's why this works on
Factorio objects.

The actual handling is a metatable trick.  Firstly, metatables only let one
intercept indices which are new.  The way this works is that you can put a
metatable on an empty table and that metatable can point at whatever else to
override indexing, and the empty table can just remain empty forever.

Now the problem is, since paths are tables technically the user could modify
them after the fact by trying to continue it.  To deal with this, we clone the
path on every step instead of writing a new one.  The actual indexing step is
fast, and the performance hit in creation is fine because presumably no one
wants to build these all the time.

For sanity we then just assert that the user is not trying to "compile" an empty
path.
]]

---@class FieldRef
---@field get fun(target: any): any
---@field set fun(target: any, value: any)

---@class FieldRefBuilder
---@field [string] FieldRefBuilder
---@field [number] FieldRefBuilder
---@operator call: FieldRef

-- By providing our own copy, this can be tested outside of Factorio at a shell.
local function copy(path)
   local new = {}
   for i = 1, #path do
      table.insert(new, path[i])
   end
   return new
end

-- Get a string representation of a path for error reporting purposes.
local function stringify_path(path)
   local res = ""
   for p = 1, #path do
      local seg = path[p]
      if type(seg) == "string" or type(seg) == "number" or type(seg) == "boolean" then
         res = res .. "." .. tostring(seg)
      else
         res = res .. "<a " .. type(seg) .. ">"
      end
   end

   return res
end

-- Clone and append to a path.
--
---@nodiscard
local function append_to_path(p, new_seg)
   local cloned = copy(p)
   table.insert(cloned, new_seg)
   return cloned
end

-- Make it not possible to set new indices in a table with =
local function no_setting_meta()
   error("in-progress or compiled field references cannot have new fields set on them")
end

-- Follow a path down. If the second argument to this function is true, follow
-- the path down to but not including the last segment, then return (result,
-- last_segment) instead.
local function follow_path(object, path, exclude_last)
   local length = #path
   if exclude_last then length = length - 1 end

   local ret = object
   for i = 1, length do
      ret = ret[path[i]]
      if ret == nil and i ~= #path then
         error("Attempt to follow a path, but found nil at step " .. i .. " path is " .. stringify_path(path))
      end
   end

   if exclude_last then
      return ret, path[#path]
   else
      return ret
   end
end

-- "compile" a path into the final form, then return a table which can be used
-- to manipulate it per the API docs at the top of this module.
--
-- Expects the path to already be cloned.
local function compile(path)
   assert(
      #path > 0,
      "Attempt to compile the empty/root path, e.g. `F()`.  Paths must always have at least one field on them."
   )

   local meta = {
      __newindex = no_setting_meta,
   }

   local funcs = {
      get = function(object)
         return follow_path(object, path, false)
      end,
      set = function(object, val)
         local ret, last = follow_path(object, path, true)
         ret[last] = val
      end,
   }

   return setmetatable(funcs, { __newindex = no_setting_meta })
end

-- Capture a path, then return a special empty table with a metatable that lets
-- one continue the chain, or compile.  The path must have already been cloned.
local function capture_path_and_build(path)
   local meta = {
      __index = function(_table, key)
         local cloned = append_to_path(path, key)
         return capture_path_and_build(cloned)
      end,
      __newindex = no_setting_meta,
      __call = function()
         -- We don't compile paths of length 0 and all paths after length 0 are
         -- cloned simply by being created, but an extra clone doesn't hurt on
         -- the slow, infrequent path.
         return compile(copy(path))
      end,
   }

   -- The empty table has no keys and so will always call our metatable methods.
   return setmetatable({}, meta)
end

-- This is complicated, and self tests here have no dependency on Factorio.
-- Let's just always run some when imported for lack of a proper unit testing
-- framework.  At least the mod won't load if this breaks, rather than failing
-- at some arbitrary point in some arbitrary way.

-- This variable is how it'd be imported by others, and returned at the end of
-- this file.  The root is just an empty path.
---@type FieldRefBuilder
local F = capture_path_and_build({})

local test_value = {
   f1 = "f1",
   f2 = {
      f1 = "f2.f1",
   },
}

-- No root path compilation.
local ok = pcall(function()
   F()
end)
assert(ok == false)

-- 1 field deep works.
local simple = F.f1()
assert(simple.get(test_value) == "f1")
simple.set(test_value, "new")
assert(simple.get(test_value) == "new")
assert(test_value.f1 == "new")

-- 2 fields deep works.
local deep = F.f2.f1()
assert(deep.get(test_value) == "f2.f1")
deep.set(test_value, "new2")
assert(deep.get(test_value) == "new2")
assert(test_value.f2.f1 == "new2")

-- We can work over something mixed between strings and numbers.
local mixed = {
   f = { 1, 2, 3 },
}
local mixed_ref = F.f[2]()
assert(mixed_ref.get(mixed) == 2)
mixed_ref.set(mixed, "new")
assert(mixed_ref.get(mixed) == "new")
assert(mixed.f[2] == "new")

return F
