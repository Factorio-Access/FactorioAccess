--[[
Manager for cursor-related and "viewpoint"-related functionality.

In Factorio 1.1, the mod assumed that there was one surface and that the viewpoint was,n boradly, always on the player.
This is different in space age, where there are intrinsically multiple surfaces, and in fact players often don't have
characters at all.

There's a few things tangled together, which basically turn into a "viewpoint" because they describe what a character is
looking at and has access to:

- The position of the cursor, whether it is enabled, etc.
- The size of the cursor.
- What's in the player's hand.
- Whether the player has a character and if not where to get inventories from etc.

This module does the bookkeeping.  To avoid circular import issues, it should be a "leaf": do not import anything which
itself needs the viewpoint, which in practice kind of means nothing that wants to play with the players.  The point of
this module is to get the cursor-related state going through a central place with function-style setters.  Right now,
that's all it does: this is Space Age pre-work where various mod systems will need to hook into changes to e.g.
invalidate caches later.

IMPORTANT: make sure to shallow copy tables out so that they do not accidentally refer to the stored state.  In future
we might take that a step further and pass vectors back as multiple values on the stack.
]]
local StorageManager = require("scripts.storage-manager")

local mod = {}

---@class fa.viewpoint.ViewpointState
---@field cursor_pos fa.Point

---@type table<number, fa.viewpoint.ViewpointState>
local viewpoint_storage = StorageManager.declare_storage_module("viewpoint", {
   cursor_pos = { x = 0, y = 0 },
})

---@class fa.Viewpoint
---@field pindex number
local Viewpoint = {}
local Viewpoint_meta = { __index = Viewpoint }

function Viewpoint:get_cursor_pos()
   local pos = viewpoint_storage[pindex].cursor_pos
   return { x = pos.x, y = pos.y }
end

---@param point fa.Point
function Viewpoint:set_cursor_pos(point)
   viewpoint_storage[self.pindex].cursor_pos = { x = point.x, y = point.y }
end

local viewpoint_cache = {}

---@param pindex number
---@return fa.Viewpoint
function mod.get_viewpoint(pindex)
   local cached = viewpoint_cache[pindex]
   if not cached then
      cached = {
         pindex = pindex,
      }
      setmetatable(cached, Viewpoint_meta)
      viewpoint_cache[pindex] = cached
   end
   return viewpoint_cache[pindex]
end

return mod
