local UiKeyGraph = require("scripts.ui.key-graph")
local UiSounds = require("scripts.ui.sounds")

local mod = {}

mod.ROOT = "__TREE_CHOOSER_ROOT__"

-- All tree transitions play the same sound; sharing one vtable avoids allocating a closure per
-- transition per render.
---@type fa.ui.graph.TransitionVtable
local MOVE_TRANSITION_VTAB = {
   play_sound = function(ctx)
      UiSounds.play_menu_move(ctx.pindex)
   end,
}

---@class fa.ui.tree.Node
---@field key string
---@field parent string
---@field vtable fa.ui.graph.NodeVtable
---@field children string[]
---@field child_set table<string, true>

---@class fa.ui.tree.TreeChooserBuilder
---@field nodes table<string, fa.ui.tree.Node>
local TreeChooserBuilder = {}
local TreeChooserBuilder_meta = { __index = TreeChooserBuilder }

function TreeChooserBuilder.new()
   return setmetatable({
      nodes = {},
   }, TreeChooserBuilder_meta)
end

---@param key string
---@param parent string Use mod.ROOT for top-level nodes
---@param vtable fa.ui.graph.NodeVtable
---@return fa.ui.tree.TreeChooserBuilder
function TreeChooserBuilder:add_node(key, parent, vtable)
   assert(key ~= mod.ROOT, "Cannot add node with ROOT key")

   if not self.nodes[key] then
      self.nodes[key] = {
         key = key,
         parent = parent,
         vtable = vtable,
         children = {},
         child_set = {},
      }
   else
      self.nodes[key].parent = parent
      self.nodes[key].vtable = vtable
   end

   if parent ~= mod.ROOT then
      if not self.nodes[parent] then
         self.nodes[parent] = {
            key = parent,
            parent = mod.ROOT,
            vtable = {
               label = function(ctx) end,
            },
            children = {},
            child_set = {},
         }
      end

      local parent_node = self.nodes[parent]
      if not parent_node.child_set[key] then
         parent_node.child_set[key] = true
         table.insert(parent_node.children, key)
      end
   end

   return self
end

---@return fa.ui.graph.Render?
function TreeChooserBuilder:build()
   local root_children = {}
   for key, node in pairs(self.nodes) do
      if node.parent == mod.ROOT then table.insert(root_children, key) end
   end

   if #root_children == 0 then return nil end

   ---@type fa.ui.graph.Render
   local render = {
      nodes = {},
      start_key = root_children[1],
   }

   -- Precompute each key's position among its siblings.  Scanning the sibling array from inside
   -- the per-node loop below would be quadratic in the size of large categories.  A node can
   -- linger in a former parent's children after reparenting, so only trust entries whose child
   -- still points back at that parent.
   ---@type table<string, integer>
   local sibling_index = {}
   for parent_key, node in pairs(self.nodes) do
      for i, child in ipairs(node.children) do
         local child_node = self.nodes[child]
         if child_node and child_node.parent == parent_key then sibling_index[child] = i end
      end
   end
   for i, key in ipairs(root_children) do
      sibling_index[key] = i
   end

   for key, node in pairs(self.nodes) do
      local transitions = {}

      if node.parent ~= mod.ROOT then
         transitions[UiKeyGraph.TRANSITION_DIR.UP] = {
            destination = node.parent,
            vtable = MOVE_TRANSITION_VTAB,
         }
      end

      if #node.children > 0 then
         transitions[UiKeyGraph.TRANSITION_DIR.DOWN] = {
            destination = node.children[1],
            vtable = MOVE_TRANSITION_VTAB,
         }
      end

      local siblings = {}
      if node.parent == mod.ROOT then
         siblings = root_children
      else
         -- add_node creates every parent it is given
         siblings = self.nodes[node.parent].children
      end

      local my_index = sibling_index[key] or 1

      if #siblings > 1 then
         -- Only add left transition if not at the first sibling
         if my_index > 1 then
            transitions[UiKeyGraph.TRANSITION_DIR.LEFT] = {
               destination = siblings[my_index - 1],
               vtable = MOVE_TRANSITION_VTAB,
            }
         end

         -- Only add right transition if not at the last sibling
         if my_index < #siblings then
            transitions[UiKeyGraph.TRANSITION_DIR.RIGHT] = {
               destination = siblings[my_index + 1],
               vtable = MOVE_TRANSITION_VTAB,
            }
         end
      end

      render.nodes[key] = {
         vtable = node.vtable,
         transitions = transitions,
      }
   end

   return render
end

mod.TreeChooserBuilder = TreeChooserBuilder

return mod
