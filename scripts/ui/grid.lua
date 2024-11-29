--[[
A simple grid: you give it a callback to get cell contents, dimensions, and
row/column names, and it handles figuring out all the keyboard stuff for you.

Designed to be mounted in a TabList (ui/tab-list.lua).  Callbacks should return
tablist responses to force closure.

Grid positions are 1-based, to match lua tables.

Your state will have a field `grid` injected into it; this field should be
treated as private.  This allows passing you the full tab context directly, as
if you had implemented all of this logic yourself.
]]
local Math2 = require("math-helpers")

local mod = {}

---@alias fa.ui.GridStringOrResponse LocalisedString | fa.ui.TabEventResponse
---@alias fa.ui.GridNames (LocalisedString[])|(fun(number): fa.ui.GridStringOrResponse)

---@class fa.ui.GridCallbacks
---@field title LocalisedString
---@field row_names fa.ui.GridNames
---@field col_names fa.ui.GridNames
---@field get_dims fun(self, fa.ui.TabContext): (number| fa.ui.TabEventResponse, number?)
---@field read_cell fun(self, fa.ui.TabContext, number, number): fa.ui.GridStringOrResponse

---@class fa.ui.GridState
---@field x number
---@field y number

---@class fa.ui.GridContext: fa.ui.TabContext
---@field state { grid: fa.ui.GridState }

---@class fa.ui.Grid: fa.ui.TabCallbacks
---@field callbacks fa.ui.GridCallbacks
local GridImpl = {}

---@param context fa.ui.GridContext
---@return fa.ui.TabEventResponse?
function GridImpl:_force_inbounds(context)
   local size_x, size_y = self.callbacks.get_dims(context)

   -- Forced closure.
   if type(size_x) ~= "number" then return size_x end
   assert(size_y)

   if size_x == 0 or size_y == 0 then return end

   local state = context.state.grid
   state.x = Math2.clamp(state.x, 1, size_x)
   state.y = Math2.clamp(state.y, 1, size_y)
end

function printout_if_lstring(msg, pindex)
   if type(msg) == "table" and msg.kind then return msg end
   printout(msg, pindex)
end
---@param context fa.ui.GridContext
function GridImpl:_move(context, dx, dy)
   local state = context.state.grid
   local x, y = state.x, state.y
   local old_x, old_y = x, y

   state.x = x + dx
   state.y = y + dy
   local forced_resp = self:_force_inbounds(context)
   if forced_resp then return forced_resp end

   local moved = state.x ~= old_x or state.y ~= old_y
   return printout_if_lstring(self:_read_cell_string(context), context.pindex)
end

---@return fa.ui.TabEventResponse|LocalisedString
function GridImpl:_read_cell_string(context)
   local forced_resp = self:_force_inbounds(context)
   if forced_resp then return forced_resp end
   local size_x, size_y = self.callbacks:get_dims(context)
   if type(size_x) ~= "number" then return size_x end
   assert(size_y)

   if size_x == 0 or size_y == 0 then return { "fa.ui-grid-empty" } end
   return self.callbacks:read_cell(context.state.grid.x, context.state.grid.y)
end

return mod
