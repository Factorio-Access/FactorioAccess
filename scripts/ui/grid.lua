--[[
A simple grid: you give it a callback to get cell contents, dimensions, and
row/column names, and it handles figuring out all the keyboard stuff for you.

Designed to be mounted in a TabList (ui/tab-list.lua).  Callbacks can force
closure by setting the context as usual. This just intercepts keypresses.

Grid positions are 1-based, to match lua tables. (1, 1) is the top left;
positive x is right, positive y down.

Your state will have a field `grid` injected into it; this field should be
treated as private.  This allows passing you the full tab context directly, as
if you had implemented all of this logic yourself.
]]
local FaUtils = require("scripts.fa-utils")
local Math2 = require("math-helpers")
local TH = require("scripts.table-helpers")

local mod = {}

---@alias fa.ui.GridNames (LocalisedString[])|(fun(fa.ui.TabContext, number): LocalisedString?)

---@class fa.ui.GridCallbacks: fa.ui.TabCallbacks
---@field title LocalisedString
---@field row_names fa.ui.GridNames
---@field col_names fa.ui.GridNames
---@field get_dims fun(self, fa.ui.TabContext): (number, number)?
---@field read_cell fun(self, fa.ui.TabContext, number, number): LocalisedString?

---@class fa.ui.GridState
---@field x number
---@field y number

---@class fa.ui.GridContext: fa.ui.TabContext
---@field state { grid: fa.ui.GridState }

---@class fa.ui.Grid: fa.ui.TabCallbacks
---@field callbacks fa.ui.GridCallbacks
local GridImpl = {}

---@param context fa.ui.GridContext
---@return LocalisedString?
function GridImpl:_force_inbounds(context)
   local size_x, size_y = self.callbacks:get_dims(context)

   if size_x == nil then
      assert(context.force_close)
      return
   end

   if size_x == 0 or size_y == 0 then return { "Fa.ui-grid-empty" } end

   local state = context.state.grid
   state.x = Math2.clamp(state.x, 1, size_x)
   state.y = Math2.clamp(state.y, 1, size_y)
end

---@param names fa.ui.GridNames
---@return LocalisedString?
function GridImpl:_resolve_name(names, context, index)
   if type(names) == "table" then return names[index] end
   return names(self.callbacks, context, index)
end

-- Only one of dx or dy should be set; the other must be zero.
---@paramn dx number
---@param dy number
---@param context fa.ui.GridContext
function GridImpl:_move(context, dx, dy)
   assert(dx == 0 or dy == 0)

   local state = context.state.grid
   local x, y = state.x, state.y
   local old_x, old_y = x, y

   state.x = x + dx
   state.y = y + dy
   local resp = self:_force_inbounds(context)
   if resp then return resp end

   -- If closure was forced, stop now.
   if context.force_close == true then return end
   self:_read_current_cell(context, dx ~= 0, dy ~= 0)
end

---@param context fa.ui.GridContext
---@param include_xname boolean
---@param include_yname boolean
---@return LocalisedString?
function GridImpl:_read_current_cell(context, include_xname, include_yname)
   local empty_resp = self:_force_inbounds(context)
   if empty_resp then return empty_resp end

   local state = context.state.grid

   local cell = self.callbacks:read_cell(context, state.x, state.y)
   if context.force_close then return end
   assert(cell)

   local parts = {}

   if include_xname then
      local xname = self:_resolve_name(self.callbacks.col_names, context, state.x)
      if xname then table.insert(parts, xname) end
   end

   if include_yname then
      local yname = self:_resolve_name(self.callbacks.row_names, context, state.y)
      if yname then table.insert(parts, yname) end
   end

   local res = cell
   if next(parts) then res = { "fa.ui-grid-cell-with-pos", cell, FaUtils.localise_cat_table(parts) } end
   context.message:fragment(res)
end

-- All of our up/down/etc. event handlers are the same thing: move, then read the cell.
local function move_handler(dx, dy)
   ---@param self fa.ui.Grid
   return function(self, context)
      self:_move(context, dx, dy)
   end
end

GridImpl.on_up = move_handler(0, -1)
GridImpl.on_down = move_handler(0, 1)
GridImpl.on_left = move_handler(-1, 0)
GridImpl.on_right = move_handler(1, 0)

---@param context fa.ui.GridContext
function GridImpl:on_tab_list_opened(context)
   if self.callbacks.on_tab_list_opened then
      self.callbacks:on_tab_list_opened(context)
      if context.force_close then return end
   end

   context.state.grid = { x = 1, y = 1 }

   self:_read_current_cell(context, true, true)
end

---@param callbacks fa.ui.GridCallbacks
function mod.declare_grid(callbacks)
   -- The grid shadows the callbacks it needs to intercept, then forwards those
   -- by hand.
   return setmetatable({ callbacks = callbacks }, TH.nested_indexer(GridImpl, callbacks))
end

return mod
