local UiKeyGraph = require("scripts.ui.key-graph")
local UiSounds = require("scripts.ui.sounds")
local UiUtils = require("scripts.ui.ui-utils")

local mod = {}

mod.ROOT = "__TREE_CHOOSER_ROOT__"

---@class fa.ui.tree.Node
---@field key string
---@field parent string
---@field vtable fa.ui.graph.NodeVtable
---@field children string[]

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
   assert(vtable.label, "Node vtable must have a label")

   if not self.nodes[key] then
      self.nodes[key] = {
         key = key,
         parent = parent,
         vtable = vtable,
         children = {},
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
         }
      end

      local already_child = false
      for _, child in ipairs(self.nodes[parent].children) do
         if child == key then
            already_child = true
            break
         end
      end

      if not already_child then table.insert(self.nodes[parent].children, key) end
   end

   return self
end

---@return fa.ui.graph.Render?
function TreeChooserBuilder:build()
   local render = {
      nodes = {},
   }

   local root_children = {}
   for key, node in pairs(self.nodes) do
      if node.parent == mod.ROOT then table.insert(root_children, key) end
   end

   if #root_children == 0 then return nil end

   render.start_key = root_children[1]

   for key, node in pairs(self.nodes) do
      local transitions = {}

      if node.parent ~= mod.ROOT then
         transitions[UiKeyGraph.TRANSITION_DIR.UP] = {
            destination = node.parent,
            vtable = {
               play_sound = function(ctx)
                  UiSounds.play_menu_move(ctx.pindex)
               end,
            },
         }
      end

      if #node.children > 0 then
         transitions[UiKeyGraph.TRANSITION_DIR.DOWN] = {
            destination = node.children[1],
            vtable = {
               play_sound = function(ctx)
                  UiSounds.play_menu_move(ctx.pindex)
               end,
            },
         }
      end

      local siblings = {}
      if node.parent == mod.ROOT then
         siblings = root_children
      elseif self.nodes[node.parent] then
         siblings = self.nodes[node.parent].children
      end

      local my_index = 1
      for i, sibling in ipairs(siblings) do
         if sibling == key then
            my_index = i
            break
         end
      end

      if #siblings > 1 then
         -- Only add left transition if not at the first sibling
         if my_index > 1 then
            transitions[UiKeyGraph.TRANSITION_DIR.LEFT] = {
               destination = siblings[my_index - 1],
               vtable = {
                  play_sound = function(ctx)
                     UiSounds.play_menu_move(ctx.pindex)
                  end,
               },
            }
         end

         -- Only add right transition if not at the last sibling
         if my_index < #siblings then
            transitions[UiKeyGraph.TRANSITION_DIR.RIGHT] = {
               destination = siblings[my_index + 1],
               vtable = {
                  play_sound = function(ctx)
                     UiSounds.play_menu_move(ctx.pindex)
                  end,
               },
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
