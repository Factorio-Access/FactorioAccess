--[[
A builder which knows how to render graphs.

You `mod.graph_builder()` then `add_label`, `set_column_header`, etc.  The dimensions of the resulting graph are the
widest dimensions needed to hold all of the set nodes.  Default nodes are "Empty" or a localisation thereof.  To
customize that,call `set_default_cell_vtable`.

The keys are "1-1" etc.

To match Lua, graphs are 1-indexed.

You may replace default dimension announcement by calling `:dimension_labeler` and giving it a callback which will
receive the graph's context, x, and y.  You should push `:fragment` only.
]]
local UiKeyGraph = require("scripts.ui.key-graph")
local UiSounds = require("scripts.ui.sounds")
local TH = require("scripts.table-helpers")

local mod = {}

---@class fa.ui.grid.GridCell
---@field vtable fa.ui.graph.NodeVtable

---@type fa.ui.graph.NodeVtable
local EMPTY_CELL_VTAB = {
   label = function(ctx)
      ctx.message:fragment({ "fa.ui-grid-empty-cell" })
   end,
}

---@type fa.ui.graph.TransitionVtable
local NORMAL_TRANSITION_VTAB = {
   play_sound = function(ctx)
      UiSounds.play_menu_move(ctx.pindex)
   end,
}

local EMPTY_GRAPH_VTAB = {
   label = function(ctx)
      ctx.message:fragment({ "fa.ui-grid-empty" })
   end,
}

---@class fa.ui.grid.GridBuilder
---@field cells table<number, table<number, fa.ui.grid.GridCell>>
---@field default_cell_vtab fa.ui.graph.NodeVtable
---@field dimension_labeler fun(fa.ui.graph.Ctx, number, number)
local GridBuilder = {}
local GridBuilder_meta = { __index = GridBuilder }

---@param x number
---@param y number
---@param cell fa.ui.grid.GridCell
---@private
function GridBuilder:_insert(x, y, cell)
   assert(x >= 1 and y >= 1)
   assert(not self.cells[x][y])
   self.cells[x][y] = cell
   self.max_x = x > self.max_x and x or self.max_x
   self.max_y = y > self.max_y and y or self.max_y
end

---@param x number
---@param y number
---@param label LocalisedString
function GridBuilder:add_simple_label(x, y, label)
   self:add_lazy_label(x, y, function(ctx)
      ctx.message:fragment(label)
   end)
   return self
end

---@param x number
---@param y number
---@param label fun(fa.ui.graph.GraphCtx)
function GridBuilder:add_lazy_label(x, y, label)
   self:_insert(x, y, {
      vtable = {
         label = label,
      },
   })
end

function GridBuilder:set_dimension_labeler(labeler)
   self.dimension_labeler = labeler
   return self
end

---@param vtab fa.ui.graph.NodeVtable
---@return fa.ui.grid.GridBuilder
function GridBuilder:set_default_cell_vtab(vtab)
   self.default_cell_vtab = vtab
   return self
end

-- Building strings is expensive!  Avoid that by caching these, since we need to use them a few times.  The cache is
-- valid up to keycache_x and keycache_y inclusive, and filled out as needed.
local keycache = TH.defaulting_table()
local keycache_x = 0
local keycache_y = 0

-- This helper table lets us iterate over all 4 directions to check for adjacent nodes.
local ADJACENT_DIRS = {
   { UiKeyGraph.TRANSITION_DIR.UP, 0, -1 },
   { UiKeyGraph.TRANSITION_DIR.DOWN, 0, 1 },
   { UiKeyGraph.TRANSITION_DIR.LEFT, -1, 0 },
   { UiKeyGraph.TRANSITION_DIR.RIGHT, 1, 0 },
}

---@return fa.ui.graph.Render
function GridBuilder:build()
   -- We must only capture the labeler, not the whole builder. Be careful of that.
   local labeler = self.dimension_labeler

   -- First, fill in all missing cells with an empty cell, and attach our node wrapper to announce locations.
   for x = 1, self.max_x do
      for y = 1, self.max_y do
         local node = self.cells[x][y]
         if not node then
            node = {
               vtable = self.default_cell_vtab,
            }
            self.cells[x][y] = node
         end

         local old_lab = node.vtable.label
         -- The vtable could be from a constant, etc. Don't break it.
         node.vtable = TH.shallow_copy(node.vtable)

         ---@param ctx fa.ui.graph.Ctx
         node.vtable.label = function(ctx)
            old_lab(ctx)
            ctx.message:list_item_forced_comma()
            labeler(ctx, x, y)
         end
      end
   end

   --- Fill out the key cache so that we have all needed keys.
   for x = keycache_x, self.max_x do
      for y = keycache_y, self.max_y do
         keycache[x][y] = string.format("%d-%d", x, y)
      end
   end

   ---@type fa.ui.graph.Render
   local render = {
      nodes = {
         -- Gets overwritten immediately, if the graph has any nodes.
         ["1-1"] = {
            transitions = {},
            vtable = EMPTY_GRAPH_VTAB,
         },
      },
      start_key = "1-1",
   }

   for x = 1, self.max_x do
      for y = 1, self.max_y do
         ---@type fa.ui.graph.Node
         local node = {
            transitions = {},
            vtable = self.cells[x][y].vtable,
         }
         local k = keycache[x][y]
         render.nodes[k] = node

         -- For all adjacencies which have a node, add a transition to it.  For all adjacencies which also have a
         -- header, add the label to announce.
         for _, adj in pairs(ADJACENT_DIRS) do
            local dir, dx, dy = adj[1], adj[2], adj[3]
            local new_x = x + dx
            local new_y = y + dy

            if not self.cells[new_x][new_y] then goto continue end

            ---@type fa.ui.graph.Transition
            local t = {
               destination = keycache[new_x][new_y],
               vtable = NORMAL_TRANSITION_VTAB,
            }

            node.transitions[dir] = t

            ::continue::
         end
      end
   end

   return render
end

function default_dim_namer(ctx, x, y)
   ctx.message:fragment({ "fa.ui-grid-cell-location", x, y })
end

---@return fa.ui.grid.GridBuilder
function mod.grid_builder()
   return setmetatable({
      cells = TH.defaulting_table({}),
      default_cell_vtab = EMPTY_CELL_VTAB,
      dimension_labeler = default_dim_namer,
      max_x = 0,
      max_y = 0,
   }, GridBuilder_meta)
end

return mod
