--[[
Manager for cursor-related and "viewpoint"-related functionality.

In Factorio 1.1, the mod assumed that there was one surface and that the viewpoint was,n boradly, always on the player.
This is different in space age, where there are intrinsically multiple surfaces, and in fact players often don't have
characters at all.

There's a few things tangled together, which basically turn into a "viewpoint" because they describe what a character is
looking at and has access to:

- The position of the cursor
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
---@field cursor_size number
---@field cursor_anchored boolean
---@field cursor_hidden boolean
---@field cursor_bookmark fa.Point
---@field cursor_ent_highlight_box  LuaEntity?
---@field cursor_tile_highlight_box LuaRenderObject?
---@field cursor_rotation_offset  number
---@field cursor_jumping boolean

---@type table<number, fa.viewpoint.ViewpointState>
local viewpoint_storage = StorageManager.declare_storage_module("viewpoint", {
   cursor_pos = { x = 0, y = 0 },
   cursor_size = 0,
   cursor_anchored = true,
   cursor_hidden = false,
   cursor_bookmark = { x = 0, y = 0 },
   cursor_ent_highlight_box = nil,
   cursor_tile_highlight_box = nil,
})

---@class fa.Viewpoint
---@field pindex number
local Viewpoint = {}
local Viewpoint_meta = { __index = Viewpoint }

-- Get the cursor position, which is always integral.
---@return fa.Point
function Viewpoint:get_cursor_pos()
   local pos = viewpoint_storage[self.pindex].cursor_pos
   -- Old saves can have fractionals here, so just floor again to deal with it.
   return { x = math.floor(pos.x), y = math.floor(pos.y) }
end

-- Set the cursor position. Floors the incoming coordinates.
---@param point fa.Point
function Viewpoint:set_cursor_pos(point)
   assert(point and point.x and point.y)
   viewpoint_storage[self.pindex].cursor_pos = { x = math.floor(point.x), y = math.floor(point.y) }
end

---@return number
function Viewpoint:get_cursor_size()
   return viewpoint_storage[self.pindex].cursor_size
end

---@param size number
function Viewpoint:set_cursor_size(size)
   assert(size)
   viewpoint_storage[self.pindex].cursor_size = size
end

---@return boolean
function Viewpoint:get_cursor_anchored()
   return viewpoint_storage[self.pindex].cursor_anchored
end

---@param val boolean
function Viewpoint:set_cursor_anchored(val)
   assert(type(val) == "boolean")
   viewpoint_storage[self.pindex].cursor_anchored = val
end

---@return boolean
function Viewpoint:get_cursor_hidden()
   return viewpoint_storage[self.pindex].cursor_hidden
end

---@param hidden boolean
function Viewpoint:set_cursor_hidden(hidden)
   assert(hidden ~= nil)
   viewpoint_storage[self.pindex].cursor_hidden = hidden
end

---@return fa.Point
function Viewpoint:get_cursor_bookmark()
   local point = viewpoint_storage[self.pindex].cursor_bookmark
   return { x = point.x, y = point.y }
end

---@param point fa.Point
function Viewpoint:set_cursor_bookmark(point)
   assert(point and point.x and point.y)
   viewpoint_storage[self.pindex].cursor_bookmark = { x = point.x, y = point.y }
end

---@return LuaEntity?
function Viewpoint:get_cursor_ent_highlight_box()
   return viewpoint_storage[self.pindex].cursor_ent_highlight_box
end

---@param ent_highlight_box LuaEntity?
function Viewpoint:set_cursor_ent_highlight_box(ent_highlight_box)
   viewpoint_storage[self.pindex].cursor_ent_highlight_box = ent_highlight_box
end

---@return  LuaRenderObject?
function Viewpoint:get_cursor_tile_highlight_box()
   return viewpoint_storage[self.pindex].cursor_tile_highlight_box
end

---@param tile_highlight_box  LuaRenderObject?
function Viewpoint:set_cursor_tile_highlight_box(tile_highlight_box)
   viewpoint_storage[self.pindex].cursor_tile_highlight_box = tile_highlight_box
end

---@return number
function Viewpoint:get_cursor_rotation_offset()
   return viewpoint_storage[self.pindex].cursor_rotation_offset
end

---@param rotation_offset  number
function Viewpoint:set_cursor_rotation_offset(rotation_offset)
   assert(rotation_offset)
   viewpoint_storage[self.pindex].cursor_rotation_offset = rotation_offset
end

---@return boolean
function Viewpoint:get_cursor_jumping()
   return viewpoint_storage[self.pindex].cursor_jumping
end

---@param jumping boolean
function Viewpoint:set_cursor_jumping(jumping)
   assert(jumping ~= nil)
   viewpoint_storage[self.pindex].cursor_jumping = jumping
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

-- Listener system for cursor events
---@type table<string, function[]>
local listeners = {}

---Register a listener for cursor events
---@param event_name string "cursor_moved_continuous" or "cursor_jumped"
---@param callback function
function mod.register_listener(event_name, callback)
   if not listeners[event_name] then listeners[event_name] = {} end
   table.insert(listeners[event_name], callback)
end

---Notify listeners of an event
---@param event_name string
---@param pindex number
---@param data table?
local function notify_listeners(event_name, pindex, data)
   if listeners[event_name] then
      for _, callback in ipairs(listeners[event_name]) do
         callback(pindex, data)
      end
   end
end

---Set cursor position for continuous movement (called only from WASD handlers)
---This tracks continuous cursor movement and notifies listeners
---@param point fa.Point
---@param direction defines.direction
function Viewpoint:set_cursor_pos_continuous(point, direction)
   assert(point and point.x and point.y)
   assert(direction ~= nil)

   local old_pos = self:get_cursor_pos()
   viewpoint_storage[self.pindex].cursor_pos = { x = math.floor(point.x), y = math.floor(point.y) }

   -- Notify listeners of continuous movement
   notify_listeners("cursor_moved_continuous", self.pindex, {
      old_position = old_pos,
      new_position = { x = math.floor(point.x), y = math.floor(point.y) },
      direction = direction,
   })
end

return mod
