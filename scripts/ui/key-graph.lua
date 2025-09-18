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

The graph can close itself (the graph context contains a controller, to tell the graph what to do).  Alternatively if
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

local mod = {}

---@alias fa.ui.graph.Modifiers { control: boolean, alt: boolean, shift: boolean }

---@class fa.ui.graph.Ctx
---@field message fa.Speech
---@field modifiers fa.ui.graph.Modifiers Set for things using the keyboard. Non-nil but garbage for all others.
---@field state any
---@field tablist_shared_state any
---@field pindex number
---@field parameters any Comes from the parent parameters, indexed by the name of the graph.
---@field global_parameters any The parent parameters, to enable "going sideways".

---@alias fa.ui.graph.SimpleCallback fun(fa.ui.GraphCtx)

---@class fa.ui.graph.NodeVtable
---@field label fa.ui.graph.SimpleCallback Required always.
---@field left_click fa.ui.graph.SimpleCallback? By default, re-say the label instead.

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

---@class fa.ui.graph.InternalTabCtx: fa.ui.TabContext
---@field state fa.ui.graph.StoredState

---@alias fa.ui.graph.RenderCallback fun(fa.ui.graph.Ctx)

---@class fa.ui.Graph: fa.ui.TabCallbacks
---@field render fa.ui.graph.Render
---@field render_callback fa.ui.graph.RenderCallback
---@field name string
local Graph = {}
local Graph_meta = { __index = Graph }

---@class fa.ui.graph.Controller
---@field graph fa.ui.Graph
---@field ctx fa.ui.graph.InternalTabCtx
local Controller = {}
local Controller_meta = { __index = Controller }

function Controller:close()
   self.ctx.force_close = true
end

---@type fa.ui.graph.Modifiers
local NO_MODIFIERS = { control = false, alt = false, shift = false }

---@param  outer_ctx fa.ui.graph.InternalTabCtx
---@param modifiers fa.ui.graph.Modifiers
---@return fa.ui.graph.Ctx
---@private
function Graph:_wrap_ctx(outer_ctx, name, modifiers)
   local controller = setmetatable({
      graph = self,
      ctx = outer_ctx,
   }, Controller_meta)

   ---@type fa.ui.graph.Ctx
   local inner_ctx = {
      message = outer_ctx.message,
      modifiers = modifiers,
      controller = controller,
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
   local render = self.render_callback(self:_wrap_ctx(ctx, self.name, NO_MODIFIERS))
   if not render then
      ctx.force_close = true
      return
   end

   self.render = render

   local state = ctx.state
   local prev_key_order = state.key_order

   -- If the key is no longer present, find the closest key to it which is, then move the focus to there.  Otherwise
   -- move the focus to the start node.
   if not render.nodes[state.cur_key] then
      if not state.key_order then
         state.cur_key = render.start_key
      else
         local old_ind = TH.find_index_of(state.key_order, state.cur_key)
         assert(old_ind, "cur_key should always have been in the previous version of the graph")
         for i = old_ind, 1, -1 do
            local k = state.key_order[i]
            if render.nodes[k] then
               state.cur_key = k
               break
            end
         end
      end

      if not state.cur_key then state.cur_key = render.start_key end
   end

   -- Perform a loop-based graph traversal to compute the new key order.
   ---@type string[]
   local down_fringe = { render.start_node }

   ---@type table<string, boolean>
   local seen = {}
   local new_order = {}

   local tins = table.insert

   local i = 1
   while i <= #down_fringe do
      local k = down_fringe[i]
      -- The fringe is always unique. Let's check that--it will find bugs if not.
      assert(not seen[k])

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
   if ctx.force_close then return end
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
   if outer_ctx.force_close then return end
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

      -- Didn't move. Behavior: play a click.
      if node == new_node then
         UiSounds.play_menu_move(ctx.pindex)
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
function Graph:on_click(ctx)
   self:_with_render(ctx, function()
      local n = self.render.nodes[ctx.state.cur_key]
      -- Right now we only have lefft click with no modifiers.
      self:_maybe_call(n, ctx, "on_click", NO_MODIFIERS)
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

---@class fa.ui.graph.Declaration
---@field title LocalisedString
---@field render_callback fa.ui.graph.RenderCallback
---@field name string

---@param declaration fa.ui.graph.Declaration
---@return fa.ui.TabDescriptor
function mod.declare_graph(declaration)
   local graph = setmetatable({
      render_callback = declaration.render_callback,
      name = declaration.name,
   }, Graph_meta)

   return {
      name = declaration.name,
      title = declaration.title,
      callbacks = graph,
   }
end

return mod
