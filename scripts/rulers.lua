--[[
Audio rulers.

A ruler triggers when the cursor touches or crosses its boundaries and plays a
sound.  Right now there is one ruler per player and no interaction with cursor
skipping.  Both of these will change later.  For the sake of the prototype,
players place a ruler with alt+b and clear with alt+shift+b.  If they want to
also have a bookmark there, we make them do so themselves.

We return an opaque handle which may safely be stored in storage, and we (for
now) use that ourselves.  The long term plan as of 2024-08-02 is to integrate
this functionality with fast travel, so in future a handle will simply go live
over there with fast travel points.
]]
local StorageManager = require("scripts.storage-manager")
local uid = require("scripts.uid").uid
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---@class fa.Ruler
---@field x number
---@field y number

---@class fa.RulerStorageState
---@field rulers fa.Ruler[]
---@field handle fa.RulerHandle? temporary, see comments below on how handles work.

-- How far from the ruler do we give the boundary sound?
local RULER_SIDE_DIST = 1

--- When using a handle to a ruler which was deleted, this message is thrown.
local DELETED_MSG = "Attempt to use a ruler handle which was previously deleted"

---@type table<number, fa.RulerStorageState>
local module_state = StorageManager.declare_storage_module("rulers", {
   -- For now only ever holds one; this is future proofing.
   rulers = {},
})

--[[
As promised in uid.lua, an explanation of the handle:

- Rulers are in a table<number, Ruler>
- Handles hold a pindex (so we know which player it was for), the reference to
  the table (so that we need not take the overhead of looking it up, and so that
  code is simpler) and this unique id.
- When deleting, the handle clears out it's table reference, then uses the
  unique id to go   delete the ruler from storage.
- Then the ruler handle switches itself off effectively by just asserting that
  the table reference is still there.  This gives users of the API a clear
  message if they are trying to use rulers they deleted by throwing an error,
  rather than let them hold a reference this module knows nothing about.

For now this is a demonstrational prototype, which means that all handles do is
delete.  Once they get integrated into fast travel, however, they will need to
support being reconfigured--functions on this "class" is where that belongs.

In practice right now it is one ruler per player; the handle is stashed in the
`handle` field of our stored per-player state.

You can think of this like a Java class except with some ceremony that lets it
live in storage.
]]
---@class fa.RulerHandle
---@field pindex number
---@field id number
---@field ruler fa.Ruler?  Nil if deleted already.
local handle_class = {}
local handle_meta = { __index = handle_class }

script.register_metatable("RulerHandle", handle_meta)

function handle_class:delete()
   assert(self.ruler, DELETED_MSG)
   module_state[self.pindex].rulers[self.id] = nil
   self.ruler = nil
end

-- Return the manhattan distance from a point.
--
-- Imagine a right triangle.  The manhattan distance between the two non-right
-- angles is the length of the other two sides. E.g. "3 blocks east and 2 blocks
-- north".
--
-- This, slightly cleaned up and more clearly explained, is also a good function
-- for a math helper module in future.  It solves a great number of alignment
-- problems which we have been solving using extremely complex if trees.
--
---@param pos_x number
---@param pos_y number
---@param ruler_x number
---@param ruler_y number
---@returns number, numbre
local function manhattan(pos_x, pos_y, ruler_x, ruler_y)
   return ruler_x - pos_x, ruler_y - pos_y
end

---@enum fa.RulerAlignmentResult
local ALIGNMENT = {
   NOT_ALIGNED = 0,
   CLOSE = 1,

   -- The player is on the centerline.
   CENTERED = 2,

   -- The player is at the point which defines the ruler.
   AT_DEFINITION = 3,

   -- The cursor is on a corner around the center where the two alignments meet.
   ON_AMBIGUOUS_CORNER = 4,
}

---@returns fa.RulerAlignmentResult
local function determine_alignment(pos_x, pos_y, ruler_x, ruler_y)
   local m_x, m_y = manhattan(pos_x, pos_y, ruler_x, ruler_y)

   local x_aligned = math.abs(m_x) <= RULER_SIDE_DIST
   local y_aligned = math.abs(m_y) <= RULER_SIDE_DIST

   -- Easy and common case first. This helps performance in future when we look
   -- at cursor skipping modes, since it executes over 99% of the time.
   if not (x_aligned or y_aligned) then return ALIGNMENT.NOT_ALIGNED end

   -- While the next-most common case is the edges, we are at the point where we
   -- do not need to care about that since the above is the 99% case.  First we
   -- will determine if the player is at the center.
   if m_x == 0 and m_y == 0 then return ALIGNMENT.AT_DEFINITION end

   -- We may use an un-aligned direction to determine which part of the ruler
   -- the player is on.  If both are aligned and nonzero, then it's an ambiguous
   -- corner.
   if x_aligned and y_aligned and m_x > 0 and m_y > 0 then return ALIGNMENT.ON_AMBIGUOUS_CORNER end

   if m_x == 0 or m_y == 0 then return ALIGNMENT.CENTERED end

   return ALIGNMENT.CLOSE
end

-- Settings for which sounds to use for each alignment type. Nil means don't
-- play anything (e.g. just leave it out of the table)
local ALIGNMENT_SOUNDS = {
   [ALIGNMENT.AT_DEFINITION] = {
      path = "audio-ruler-at-definition",
   },
   [ALIGNMENT.ON_AMBIGUOUS_CORNER] = {
      path = "audio-ruler-close",
   },
   [ALIGNMENT.CLOSE] = {
      path = "audio-ruler-close",
   },
   [ALIGNMENT.CENTERED] = {
      path = "audio-ruler-aligned",
   },
}

local function play_ruler_alignment(pindex, alignment)
   local s = ALIGNMENT_SOUNDS[alignment]
   local p = game.get_player(pindex)
   if not p then error("No player with pindex " .. tonumber(pindex)) end

   -- Nothing to do, not aligned.
   if not s then return end

   p.play_sound(s)
end

-- If a ruler is present for this player, destroy it.  Then make a new one.
---@param pindex number
---@param x number
---@param y number
---@returns fa.RulerHandle
function mod.upsert_ruler(pindex, x, y)
   x = math.floor(x)
   y = math.floor(y)

   local state = module_state[pindex]
   if state.handle ~= nil then state.handle:delete() end
   assert(not next(module_state[pindex].rulers), "The ruler did not delete for player " .. tonumber(pindex))
   local id = uid()
   state.rulers[id] = {
      x = x,
      y = y,
   }

   local handle = {
      pindex = pindex,
      id = id,
      ruler = state.rulers[id],
   }

   setmetatable(handle, handle_meta)
   state.handle = handle
   return handle
end

-- Called every time the player moves their viewpoint.
function handle_class:play_if_needed(x, y)
   assert(self.ruler, DELETED_MSG)

   x = math.floor(x)
   y = math.floor(y)

   local alignment = determine_alignment(x, y, self.ruler.x, self.ruler.y)
   play_ruler_alignment(self.pindex, alignment)
end

-- Report how this position aligns with this ruler
---@param x number
---@param y number
---@returns fa.RulerAlignmentResult
function handle_class:report_alignment(x, y)
   assert(self.ruler, DELETED_MSG)

   x = math.floor(x)
   y = math.floor(y)

   return determine_alignment(x, y, self.ruler.x, self.ruler.y)
end

-- Must be called every time the "viewpoint" for a player moves, e.g. cursor,
-- walking, whatever.  Should be passed the coords of the tile.  Arguments are floored.
function mod.on_viewpoint_moved(pindex, x, y)
   -- For now we just tell the ruler handle to play if it has to.
   if module_state[pindex].handle then module_state[pindex].handle:play_if_needed(x, y) end
end

function mod.clear_rulers(pindex)
   local state = module_state[pindex]
   if state.handle then
      state.handle:delete()
      state.handle = nil
      assert(not next(state.rulers), "The ruler failed to delete for " .. pindex)
   end
end

-- Soorta legacy: work out the cursor position of the player and use that as the
-- "viewpoint".
--
-- Sorta legacy because I (ahicks) think that we're going to havve to eventually
-- move away from the cursor and the walking player being the same thing,
-- especially with being able to walk in cursor mode on the horizon.  But it's
-- fine to use it for now.
function mod.update_from_cursor(pindex)
   local cur = Viewpoint.get_viewpoint(pindex):get_cursor_pos()
   mod.on_viewpoint_moved(pindex, cur.x, cur.y)
end

--Checks the alignment of all rulers against the position
function mod.is_at_any_ruler_definition(pindex, position)
   if module_state[pindex].handle then
      local alignment = module_state[pindex].handle:report_alignment(position.x, position.y)
      if alignment == ALIGNMENT.AT_DEFINITION then return true end
   end
   return false
end

--Checks the alignment of all rulers against the position
function mod.is_any_ruler_aligned(pindex, position)
   if module_state[pindex].handle then
      local alignment = module_state[pindex].handle:report_alignment(position.x, position.y)
      if alignment == ALIGNMENT.CENTERED or alignment == ALIGNMENT.AT_DEFINITION then return true end
   end
   return false
end

return mod
