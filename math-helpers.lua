--[[
Additional mathematical helpers on top of Lua's built-in math library.

These are pure functions: no side effects, and return the same value out for the
same values in.
]]

local mod = {}

--[[
Computes a 1-based modulus.

In most languages, with 0-based indices, a useful way to "go in circles" such
that always increasing an index iterates over an array over and over, is to do
`i % len(array))` which, as i increments, will repeat from 0 to len(array) over
and over.  In Lua, we have one-based indices.  mod1 is the same operation as %
in a zero-based language, but offset so that it works with lua tables.

E.g. given 1, 2, 3, 4, 5,  6, and mod1(i, 3), you get 1, 2, 3, 1, 2, 3
]]
function mod.mod1(index, length)
   return ((index - 1) % length) + 1
end

---@param x number
---@param low number
---@param high number
---@return number
function mod.clamp(x, low, high)
   if x < low then
      return low
   elseif x > high then
      return high
   else
      return x
   end
end

return mod
