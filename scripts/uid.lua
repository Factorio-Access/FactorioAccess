--[[
Unique ids

Sometimes it is very useful to generate ids which are unique per save.  This is
used for example in rulers.

At first it may seem that one might simply use tables.  This works for
everything but deletion.  Usually a table is one level too deep for removal.  By
using an integral id, removal itself becomes easy.  See rulers.lua for the
pattern; that was left with extra comments for the sake of being able to see the
why of it.

]]

local mod = {}

---@returns number
function mod.uid()
   if not storage.id_counter then storage.id_counter = 0 end
   storage.id_counter = storage.id_counter + 1
   return storage.id_counter
end

return mod
