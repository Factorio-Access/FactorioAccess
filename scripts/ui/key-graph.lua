--[[
This is UI "assembly language".  You probably want a higher level builder e.g. MenuBuilder, coupled with
declare_keygraph from this file.  This comment primarily talks about what this is and how it works, but how to use it is
different--see blueprints menu for a good example.  Read on if you need to add new UI kinds (not new menus, but e.g. the
concept of a menu itself).

# Overview and the Problem

Factorio Access has a problem.  Unlike most UI, we must invent a mechanism to expose fast keyboard-based navigation even
potentially at the cost of learnability.  The naive approach makes it look like you just have some sort of vertical
and/or horizontal menu, but a closer look indicates this is not the case.  To name a couple, the "signal selector"
(inserters and circuit network) is an odd sort of tree with weird rules, and the crafting and research "menus" are
actually categorized horizontal rows of different lengths.  Then the belt analyzer is a simple grid--but not, because it
has unique coordinate messaging per cell plus rules about what to say on a transition when going "sideways" from lane to
lane.  It's also trivially easy to conceptualize more that we would want if we could ghet them, but we can't so
everything gets turned into menus or non-UI hotkeys.

After much thought, one can observe that all UI can be represented as:

- Some tabs, not represented in this file (see tab-list.lua).
- A set of controls, each with a label and possible associated sounds.
- A set of transitions between controls.  The majority are silent and speechless, but some (e.g. transport belts) want
  to add text that only speaks when transitioning.
- The ability to search the menu.

# The Solution

There's lots of things one could conceive of.  Maybe you've got a "form" with "buttons".  Or a vertical menu.  ANd you
call all of these controls.  Maybe you have custom key handling that forms a "UI" with custom drawing code.

Or, you could just list all the nodes and transitions out, then write helpers that can more easily build complex
structures like menus.

To that end: this is a directed graph.  Nodes are controls.  Each node can have up to 4 transitions up/down/left/right.
Nodes and transitions each get a set of properties saying what to do.  For messaging, this is usually in the form of a
function which gets passed a `fa.ui.GraphCtx` to append to.  Others represent actions like gain_focus and left_click
([).

The graph itself comes from a function returning the graph.  This function may return a top-level constant graph or it
may return a dynamic one generated for just this call.  In the latter case, one can capture entities.  It is guaranteed
that the graph is re-rendered before the return value is used, and that the closures so returned will be thrown out.
That means that for example one can capture what's in the player's hand and pre-check validity.  That's not good enough
for all cases though, so the context also contains `parameters` and `graph_state`.  A lesser key `state` is maintained
per-node and/or per-transition so that things can be reused: things that don't need the whole thing can store there.
using parameters and states, it is possible to make graphs once and return them, communicating with the nodes via the
state.  That is how we handle more performance sensitive paths.

The graph can close itself (the graph context contains a controller from the router to close the UI).  Alternatively if
render returns nil, the graph closes.  Since it is guaranteed that render is always called before the rest and that
there is no gap between render and using the value it returns, performing checks at the top of render is sufficient and
they do not necessarily need to propagate to the rest of it.

Here is the trick for search: start at the graph's start node and then traverse outward to gather all keys and search
labels, with a heuristic that prefers right/down first over up/left.  That'll order correctly for all UIs as of
2024-04-06.

And here is the trick for graphical rendering: rendering is simpler.  If a graph supports rendering the "shape" can be
inferred from right/down connections, each as a box.  That won't capture weird up/left transitions but will capture the
case of grids, menus, categorized named rows, etc.  We just have to possibly implement a "graphical type" and tag UIs
with it.  For example, the signal selector is very complicated from the blind person's perspective, but from a graphical
perspective it's just a normal tree.

# The down-right contstraint

Graphs must support modification out from under the player e.g. because a blueprint got imported or because someone else
changed values.  They must also support search.  In both cases one must define a total order over the graph's nodes (if
it is unobvious why you need that for modification, it's because the player goes to the "most valid" key).

We define this total order as follows: go right until not possible.  Go down from everything we just found.  For each go
right until not possible...etc.  This naturally suits most UIs because it is usually up/left that get weird, e.g. a
tree's children all going up to a single parent.

*but* if there is a node which may only be reached via an up or a left, none of this works.  So the down-right
constraint is this: going down and right must visit the whole graph eventually.  It can have cycles.  Up and left can do
whatever they want.  But going down and right must visit all nodes.  Generally this "just works out" because it aligns
naturally with how the UX for a UI should be.
]]
local TH = require("scripts.table-helpers")
local UiSounds = require("scripts.ui.sounds")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local UiRouter = require("scripts.ui.router")

local mod = {}

---@alias fa.ui.graph.Modifiers { control: boolean, alt: boolean, shift: boolean }

---@class fa.ui.graph.GraphController
---@field graph_state fa.ui.graph.StoredState

---@class fa.ui.graph.Ctx
---@field message fa.MessageBuilder
---@field modifiers fa.ui.graph.Modifiers Set for things using the keyboard. Non-nil but garbage for all others.
---@field controller fa.ui.RouterController The router's controller for UI management
---@field graph_controller fa.ui.graph.GraphController Graph-specific controller with suggest_move
---@field state any
---@field tablist_shared_state any
---@field pindex number
---@field parameters any Comes from the parent parameters, indexed by the name of the graph.
---@field global_parameters any The parent parameters, to enable "going sideways".
---@field child_context any? Context from child UI result (only set in on_child_result)

---@alias fa.ui.graph.SimpleCallback fun(fa.ui.GraphCtx)
---@alias fa.ui.graph.ClickCallback fun(fa.ui.GraphCtx, fa.ui.Modifiers)
---@alias fa.ui.graph.ChildResultCallback fun(fa.ui.GraphCtx, any)

---@class fa.ui.graph.NodeVtable
---@field label fa.ui.graph.SimpleCallback Required always.
---@field on_click fa.ui.graph.ClickCallback? By default, re-say the label instead.
---@field on_right_click fa.ui.graph.ClickCallback?
---@field on_read_coords fa.ui.graph.SimpleCallback?
---@field on_read_info fa.ui.graph.SimpleCallback? Y key - read detailed info about current item
---@field on_production_stats_announcement fa.ui.graph.SimpleCallback? U key - read production stats
---@field on_child_result fa.ui.graph.ChildResultCallback?
---@field on_accelerator fun(ctx: fa.ui.graph.Ctx, accelerator_name: string)? Handler for accelerator events
---@field on_clear fa.ui.graph.SimpleCallback? Handler for clear (backspace) event
---@field on_dangerous_delete fa.ui.graph.SimpleCallback? Handler for dangerous delete (ctrl+backspace) event
---@field on_bar_min fa.ui.graph.SimpleCallback? Handler for bar min (ctrl+-)
---@field on_bar_max fa.ui.graph.SimpleCallback? Handler for bar max (ctrl++)
---@field on_bar_up_small fa.ui.graph.SimpleCallback? Handler for bar up small (+)
---@field on_bar_down_small fa.ui.graph.SimpleCallback? Handler for bar down small (-)
---@field on_bar_up_large fa.ui.graph.SimpleCallback? Handler for bar up large (shift++)
---@field on_bar_down_large fa.ui.graph.SimpleCallback? Handler for bar down large (shift+-)
---@field on_trash fa.ui.graph.SimpleCallback? Handler for trash (o key)
---@field on_action1 fa.ui.graph.SimpleCallback? Handler for action1 (m key)
---@field on_action2 fa.ui.graph.SimpleCallback? Handler for action2 (comma key)
---@field on_action3 fa.ui.graph.SimpleCallback? Handler for action3 (dot key)
---@field on_drag_up fa.ui.graph.SimpleCallback? Handler for drag up (shift+w)
---@field on_drag_down fa.ui.graph.SimpleCallback? Handler for drag down (shift+s)
---@field on_drag_left fa.ui.graph.SimpleCallback? Handler for drag left (shift+a)
---@field on_drag_right fa.ui.graph.SimpleCallback? Handler for drag right (shift+d)
---@field on_conjunction_modification fa.ui.graph.SimpleCallback? Handler for conjunction modification (n key)
---@field on_add_to_row fa.ui.graph.SimpleCallback? Handler for add to row (slash key with modifiers)
---@field on_toggle_supertype fa.ui.graph.SimpleCallback? Handler for toggling supertype (j key)
---@field exclude_from_search boolean? If true, this node won't be included in search results. Default false.

---@class fa.ui.graph.TransitionVtable
---@field label fa.ui.graph.SimpleCallback?
---@field play_sound fa.ui.graph.SimpleCallback?

---@class fa.ui.graph.Transition
---@field destination string
---@field vtable fa.ui.graph.TransitionVtable

---@enum fa.ui.graph.TransitionDir
mod.TRANSITION_DIR = {
   UP = 1,
   RIGHT = 12,
   DOWN = 3,
   LEFT = 4,
}

---@class fa.ui.graph.Node
---@field vtable fa.ui.graph.NodeVtable
---@field transitions table<fa.ui.graph.TransitionDir, fa.ui.graph.Transition>

---@class fa.ui.graph.Render
---@field nodes table<string, fa.ui.graph.Node>
---@field start_key string

---@class fa.ui.graph.StoredState
---@field cur_key string
---@field key_order string[]? Not set the first time through.
---@field next_suggested_move string? If set, silently move to this key on next render

---@class fa.ui.graph.InternalTabCtx: fa.ui.TabContext
---@field state fa.ui.graph.StoredState

---@alias fa.ui.graph.RenderCallback fun(fa.ui.graph.Ctx): fa.ui.graph.Render?

---@class fa.ui.Graph: fa.ui.TabCallbacks
---@field render fa.ui.graph.Render
---@field render_callback fa.ui.graph.RenderCallback
---@field name string
---@field on_accelerator_callback fun(ctx: fa.ui.graph.Ctx, accelerator_name: string)? Handler for accelerator events
---@field get_help_metadata_callback (fun(ctx: fa.ui.TabContext): fa.ui.help.HelpItem[]?)?
local Graph = {}
local Graph_meta = { __index = Graph }

---GraphController is a simple object with graph-specific methods
---@class fa.ui.graph.GraphController
local GraphController = {}
local GraphController_meta = { __index = GraphController }

---Suggest moving to a specific key on the next render
---@param key string The key to move to
function GraphController:suggest_move(key)
   self.graph_state.next_suggested_move = key
end

---Create a GraphController
---@param graph_state fa.ui.graph.StoredState
---@return fa.ui.graph.GraphController
local function create_graph_controller(graph_state)
   return setmetatable({
      graph_state = graph_state,
   }, GraphController_meta)
end

---@type fa.ui.graph.Modifiers
local NO_MODIFIERS = { control = false, alt = false, shift = false }

---@param  outer_ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
---@return fa.ui.graph.Ctx
---@private
function Graph:_wrap_ctx(outer_ctx, name, modifiers)
   -- Create a GraphController for graph-specific operations
   local graph_controller = create_graph_controller(outer_ctx.state)

   ---@type fa.ui.graph.Ctx
   local inner_ctx = {
      message = outer_ctx.message,
      modifiers = modifiers,
      controller = outer_ctx.controller,
      graph_controller = graph_controller,
      state = outer_ctx.state,
      tablist_shared_state = outer_ctx.shared_state,
      pindex = outer_ctx.pindex,
      parameters = outer_ctx.parameters[name],
      global_parameters = outer_ctx.parameters,
   }

   return inner_ctx
end

---@param ctx fa.ui.graph.InternalTabCtx
---@private
function Graph:_rerender(ctx)
   self.render = nil

   local render = self.render_callback(self:_wrap_ctx(ctx, self.name, NO_MODIFIERS))
   if not render then
      -- Close via controller
      ctx.controller:close()
      return
   end

   self.render = render

   local state = ctx.state
   local prev_key_order = state.key_order

   -- Check for suggested move and apply it silently if the key exists
   if state.next_suggested_move and render.nodes[state.next_suggested_move] then
      state.cur_key = state.next_suggested_move
      state.next_suggested_move = nil
   end

   -- If the key is no longer present, find the closest key to it which is, then move the focus to there.  Otherwise
   -- move the focus to the start node.
   if not render.nodes[state.cur_key] then
      if not state.key_order then
         state.cur_key = render.start_key
      else
         local old_ind = TH.find_index_of(state.key_order, state.cur_key)
         if not old_ind then
            error(
               "cur_key should always have been in the previous version of the graph: " .. serpent.line(state.cur_key)
            )
         end
         for i = old_ind, 1, -1 do
            local k = state.key_order[i]
            if render.nodes[k] then
               state.cur_key = k
               break
            end
         end
      end

      if not render.nodes[state.cur_key] then state.cur_key = render.start_key end
   end

   -- Perform a loop-based graph traversal to compute the new key order.
   ---@type string[]
   local down_fringe = { render.start_key }

   ---@type table<string, boolean>
   local seen = {}
   local new_order = {}

   local tins = table.insert

   local i = 1
   while i <= #down_fringe do
      local k = down_fringe[i]
      -- The fringe is always unique. Let's check that--it will find bugs if not.
      -- assert(not seen[k]) -- Commented out - this can fail with complex menu structures

      -- Everything to the right goes into the order.  Everything to the down goes into the fringe.  This loop started
      -- at a down, so add it now; then go right.
      while not seen[k] do
         seen[k] = true
         tins(new_order, k)

         local n = render.nodes[k]
         local t = n.transitions[mod.TRANSITION_DIR.RIGHT]
         local d = n.transitions[mod.TRANSITION_DIR.DOWN]

         -- If there is a down we must explore it later on.
         if d then tins(down_fringe, d.destination) end

         -- We've gone as far right as we can.
         if not t then break end

         local nk = t.destination

         k = nk
      end

      -- Fringe only contains downs. Move to the next "level".
      i = i + 1
   end

   state.key_order = new_order
end

-- Call the callback if and only if a re-render succeeded.
---@param ctx fa.ui.graph.InternalTabCtx
---@param callback fun(): any
---@private
function Graph:_with_render(ctx, callback)
   self:_rerender(ctx)
   -- If controller closed the UI, render will be nil
   if not self.render then return end
   return callback()
end

-- When a callback defaults to another callback it gets an entry in this table.
local CALLBACK_FALLBACKS = {
   on_click = "label",
}

---@param node { vtable: any }
---@param outer_ctx fa.ui.graph.InternalTabCtx
---@param callback_name string
---@param modifiers fa.ui.graph.Modifiers
---@param ... any
---@private
---@return any?
function Graph:_maybe_call(node, outer_ctx, callback_name, modifiers, ...)
   -- Controller will handle closing if needed
   local inner_ctx = self:_wrap_ctx(outer_ctx, self.name, modifiers)

   local fallback_callback_name = CALLBACK_FALLBACKS[callback_name]
   local sound = function() end
   local cb = node.vtable[callback_name]
   if not cb then cb = node.vtable[fallback_callback_name] end

   if cb then return cb(inner_ctx, ...) end
end

---@private
---@param ctx fa.ui.graph.InternalTabCtx
function Graph:_do_move(ctx, dir)
   self:_with_render(ctx, function()
      local state = ctx.state
      local render = self.render
      local node = render.nodes[state.cur_key]
      local t = node.transitions[dir]
      local new_node = node
      if t then
         new_node = render.nodes[t.destination]
         assert(new_node)
      end

      -- Didn't move. Behavior: play edge sound and re-read label.
      if node == new_node then
         UiSounds.play_ui_edge(ctx.pindex)
         self:_maybe_call(new_node, ctx, "label", NO_MODIFIERS)
         return
      end

      self:_maybe_call(t, ctx, "label", NO_MODIFIERS)
      self:_maybe_call(t, ctx, "play_sound", NO_MODIFIERS)
      self:_maybe_call(new_node, ctx, "label", NO_MODIFIERS)
      state.cur_key = t.destination
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_click(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_click", modifiers)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_right_click(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_right_click", modifiers)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_read_coords(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_read_coords", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_read_info(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_read_info", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_production_stats_announcement(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_production_stats_announcement", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_left(ctx)
   self:_do_move(ctx, mod.TRANSITION_DIR.LEFT)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_right(ctx)
   self:_do_move(ctx, mod.TRANSITION_DIR.RIGHT)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_up(ctx)
   self:_do_move(ctx, mod.TRANSITION_DIR.UP)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_down(ctx)
   self:_do_move(ctx, mod.TRANSITION_DIR.DOWN)
end

---@private
---@param ctx fa.ui.graph.InternalTabCtx
---@param dir number Direction from mod.TRANSITION_DIR
function Graph:_do_move_to_edge(ctx, dir)
   self:_with_render(ctx, function()
      local state = ctx.state
      local render = self.render
      local current_key = state.cur_key
      local moved = false

      -- Move in the given direction as far as possible
      while true do
         local current_node = render.nodes[current_key]
         if not current_node then break end

         local t = current_node.transitions[dir]
         if not t then break end

         local new_node = render.nodes[t.destination]
         if not new_node then break end

         current_key = t.destination
         moved = true
      end

      if moved then
         -- We moved to a new position
         state.cur_key = current_key
         local node = render.nodes[current_key]
         self:_maybe_call(node, ctx, "label", NO_MODIFIERS)
      else
         -- Already at edge, play edge sound and re-announce
         UiSounds.play_ui_edge(ctx.pindex)
         local node = render.nodes[current_key]
         self:_maybe_call(node, ctx, "label", NO_MODIFIERS)
      end
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_top(ctx)
   self:_do_move_to_edge(ctx, mod.TRANSITION_DIR.UP)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_bottom(ctx)
   self:_do_move_to_edge(ctx, mod.TRANSITION_DIR.DOWN)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_leftmost(ctx)
   self:_do_move_to_edge(ctx, mod.TRANSITION_DIR.LEFT)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_rightmost(ctx)
   self:_do_move_to_edge(ctx, mod.TRANSITION_DIR.RIGHT)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_tab_list_opened(ctx)
   self:_with_render(ctx, function()
      ctx.state.cur_key = self.render.start_key
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_tab_focused(ctx)
   self:_with_render(ctx, function()
      local node = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(node, ctx, "label", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param result any
---@param context any The context from when child UI was opened (should be {node = "key", ...})
function Graph:on_child_result(ctx, result, context)
   self:_with_render(ctx, function()
      -- Find the node that opened the child UI using the stored context
      -- Context should be a table with at least {node = "key"}
      local node_key = type(context) == "table" and context.node or context
      local node = self.render.nodes[node_key]
      if node and node.vtable.on_child_result then
         -- Call the node's on_child_result handler with the result
         local wrapped_ctx = self:_wrap_ctx(ctx, self.name, NO_MODIFIERS)
         -- Add child_context to the wrapped context for handlers to inspect
         wrapped_ctx.child_context = context
         node.vtable.on_child_result(wrapped_ctx, result)
      end
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param accelerator_name string
function Graph:on_accelerator(ctx, accelerator_name)
   -- Check if there's a graph-level on_accelerator handler
   if self.on_accelerator_callback then
      self:_with_render(ctx, function()
         local wrapped_ctx = self:_wrap_ctx(ctx, self.name, NO_MODIFIERS)
         self.on_accelerator_callback(wrapped_ctx, accelerator_name)
      end)
   else
      -- Fall back to node-level handler
      self:_with_render(ctx, function()
         local n = self.render.nodes[ctx.state.cur_key]
         if n and n.vtable.on_accelerator then
            local wrapped_ctx = self:_wrap_ctx(ctx, self.name, NO_MODIFIERS)
            n.vtable.on_accelerator(wrapped_ctx, accelerator_name)
         end
      end)
   end
end

---Get help metadata for this graph
---@param ctx fa.ui.TabContext
---@return fa.ui.help.HelpItem[]?
function Graph:get_help_metadata(ctx)
   if self.get_help_metadata_callback then return self.get_help_metadata_callback(ctx) end
   return nil
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_clear(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_clear", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_dangerous_delete(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_dangerous_delete", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_bar_min(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_bar_min", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_bar_max(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_bar_max", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_bar_up_small(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_bar_up_small", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_bar_down_small(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_bar_down_small", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_bar_up_large(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_bar_up_large", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_bar_down_large(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_bar_down_large", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
function Graph:on_trash(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_trash", NO_MODIFIERS)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_action1(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_action1", modifiers)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_action2(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_action2", modifiers)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_action3(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_action3", modifiers)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_drag_up(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_drag_up", modifiers)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_drag_down(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_drag_down", modifiers)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_drag_left(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_drag_left", modifiers)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_drag_right(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_drag_right", modifiers)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_conjunction_modification(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_conjunction_modification", modifiers)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_add_to_row(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_add_to_row", modifiers)
   end)
end

---@param ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
function Graph:on_toggle_supertype(ctx, modifiers)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      self:_maybe_call(n, ctx, "on_toggle_supertype", modifiers)
   end)
end

-- Search support

---Check if this UI supports search (always true for KeyGraph)
---@param _ctx fa.ui.TabContext
---@return boolean
function Graph:supports_search(_ctx)
   return true
end

---Hint localised strings for caching
---@param ctx fa.ui.graph.InternalTabCtx
---@param hint_callback fun(localised_string: LocalisedString)
function Graph:search_hint(ctx, hint_callback)
   self:_with_render(ctx, function()
      local render = self.render
      local key_order = ctx.state.key_order or {}

      for _, key in ipairs(key_order) do
         local node = render.nodes[key]
         if node and not node.vtable.exclude_from_search then
            -- Create a temporary message builder
            local temp_message = MessageBuilder.new()
            ---@diagnostic disable-next-line: param-type-mismatch
            local temp_ctx = self:_wrap_ctx(ctx, self.name, NO_MODIFIERS)
            temp_ctx.message = temp_message

            -- Call the label to collect localised strings
            node.vtable.label(temp_ctx)

            -- Extract localised strings from the message
            local built = temp_message:build()
            if built and type(built) == "table" then hint_callback(built) end
         end
      end
   end)
end

---Move to next/previous search result
---@param message fa.MessageBuilder Message builder to populate with announcement
---@param ctx fa.ui.graph.InternalTabCtx
---@param direction integer 1 for next, -1 for previous
---@param matcher fun(localised_string: LocalisedString): boolean Function to test if a localised string matches
---@return fa.ui.SearchResult
function Graph:search_move(message, ctx, direction, matcher)
   local result = UiRouter.SEARCH_RESULT.DIDNT_MOVE
   self:_with_render(ctx, function()
      local render = self.render
      local key_order = ctx.state.key_order or {}
      local current_key = ctx.state.cur_key

      -- Find current position
      local current_index = nil
      for i, key in ipairs(key_order) do
         if key == current_key then
            current_index = i
            break
         end
      end

      if not current_index then return end

      local start_index = current_index
      local i = current_index
      local wrapped = false

      -- Search loop
      while true do
         i = i + direction
         if direction > 0 and i > #key_order then
            i = 1
            wrapped = true
         elseif direction < 0 and i < 1 then
            i = #key_order
            wrapped = true
         end

         local key = key_order[i]
         local node = render.nodes[key]
         if node and not node.vtable.exclude_from_search then
            -- Build the label as a localised string
            local temp_msg = MessageBuilder.new()
            ---@diagnostic disable-next-line: param-type-mismatch
            local msg_ctx = self:_wrap_ctx(ctx, self.name, NO_MODIFIERS)
            msg_ctx.message = temp_msg
            node.vtable.label(msg_ctx)
            local label_localised = temp_msg:build()

            if label_localised and matcher(label_localised) then
               -- Found a match
               ctx.state.cur_key = key
               -- Build announcement into provided message
               msg_ctx.message = message
               node.vtable.label(msg_ctx)

               result = wrapped and UiRouter.SEARCH_RESULT.WRAPPED or UiRouter.SEARCH_RESULT.MOVED
               return
            end
         end

         -- If we've wrapped and returned to start, no more matches
         if i == start_index then break end
      end
   end)

   return result
end

---Search from the start and move to first match
---@param ctx fa.ui.TabContext
---@return fa.ui.SearchResult
function Graph:search_all_from_start(ctx)
   -- TODO: Implement with matcher callback pattern when needed
   return UiRouter.SEARCH_RESULT.DIDNT_MOVE
end

---@class fa.ui.graph.Declaration
---@field title LocalisedString
---@field render_callback fa.ui.graph.RenderCallback
---@field name string
---@field on_accelerator fun(ctx: fa.ui.graph.Ctx, accelerator_name: string)?
---@field get_help_metadata (fun(ctx: fa.ui.TabContext): fa.ui.help.HelpItem[]?)?

---@param declaration fa.ui.graph.Declaration
---@return fa.ui.TabDescriptor
function mod.declare_graph(declaration)
   local graph = setmetatable({
      render_callback = declaration.render_callback,
      name = declaration.name,
      on_accelerator_callback = declaration.on_accelerator,
      get_help_metadata_callback = declaration.get_help_metadata,
      -- For debugging, because otherwise it is very unclear that this is a metatable trick.
      _callbacks_are_from_metatable = "yes because this is KeyGraph",
   }, Graph_meta)

   return {
      name = declaration.name,
      title = declaration.title,
      callbacks = graph,
   }
end

return mod
