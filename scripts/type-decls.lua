--[[
Shared type declarations for things we commonly need everywhere.  Note that old
code may not follow these.

Where possible these are compatible with the *input* to the Factorio API, but
the choice is more clearly made to match our current usage since we have 20k
lines already.  This means that Factorio might return for example a point in `{
2, 3 }` form.  In theory it does not, however, so these should generally match.
]]

---@alias fa.Point { x: number, y: number }

-- If this isn't an alias LuaLS gets mad about trying to use our otherwikse
-- valid boxes in the Factorio API.
---@alias fa.AABB BoundingBox.0
