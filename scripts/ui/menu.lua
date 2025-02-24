--[[
A menu.

This encapsulates the kind of menu used to configure things like blueprints:
some number of vertical controls, (todo: each with optional horizontal controls
on the same "row" like for fast travel).  What makes that different from a grid
is that the dimensions are not fixed, nor is the list of controls.  For example
non-empty blueprints have different functionality than empty blueprints, but the
menu is the same.

Really, you can build almost everything but the inventory grids with this.

To use this, create one and mount it in a tab.  ui/menus/blueprint-menu.lua is a
simple example.  At this time key routing is still not handled automatically, so
some edits to control.lua are usually necessary; again, blueprint-menu is a
simple example of that as well.

# How it works

The menu consists of two things:

- An initial state function, which returns some initial state to store in
  `storage`, e.g. a targeted entity, list of researches, whatever.
- A render function, which is called every time the menu needs to be updated,
  which should return a specification of the menu.

Each item in the menu is at minimum a label function which should append some
labels to a `MessageBuilder`, and a click function which should respond to
clicks.  It is guaranteed that the render function will always be called
immediately before using the items, and so it may do validity checks.  If the
render function ever returns nil, the menu closes.  For example, it may start
with:

```
if not state.entity.valid then return nil end
```

Each item in the menu is given a `key`.  For now this is not optional but it
will be in the future, once this grows to support more dynamic menus where it is
more than just present/not present, e.g. decider combinators which can have
multiple conditions, or train schedules.

For now, this doesn't handle text boxes or leaving the menu for things like
selecting blueprint areas.  To deal with that, those functions must
unfortunately call back into the UI and re-open the menu, setting the initial
position to their hardcoded key.  In the future, we can and will be able to
handle that better: the real answer is to temporarily open a generic text
box/select area/... UI, which knows how to "return" to where it was with the
value.  This is also a problem with item choosers and similar.  Ultimately,
though, such "delegation" can be handled by making clickable menu items.

This may seem limited, but the trick is this: menu items can be returned from
functions.  So, it is possible to for example:

```
local item = choices("key", "first choice", "second choice")...
```

And similar.  You may find some helpers in menu-items.lua.

(2025-02-06): Search is not yet handled.  If you need a menu with search,
consider extending this or pinging @ahicks on discord for help.  The UI stuff is
generally set up to do this generically already by extending the protocol for
tabs to be able to pass search filters and commands down.  The general idea is
that the search text box looks up the open UI and passes the player's input
along to tablists, which then pass it down again if the tab supports it.  Your
tricky part is searching and localisation; I recommend adding an optional
`search_key` function which (tries to) return a non-localised string, or
consults the caches in localisation.lua, or whatever.
]]
local Math2 = require("math-helpers")
local Sounds = require("scripts.ui.sounds")

local mod = {}

--[[
Tell the menu itself to do things from click handlers etc.
]]
---@class fa.MenuController
---@field close fun(self)
---@field close_because_textbox fun(self) Temporary hopefully.

---@class fa.MenuCtx
---@field pindex number
---@field message_builder fa.MessageBuilder
---@field state any Returned from the state function and maintained in `storage`.
---@field item_state table? Private to the menu item itself.
---@field controller fa.MenuController

---@alias fa.MenuEventCallback fun(fa.MenuCtx)
---@alias fa.MenuEventPredicate fun(fa.MenuCtx): boolean

---@class fa.MenuItemStorage
---@field key string

-- Stored in `storage`.
---@class fa.MenuState
---@field prev_items fa.MenuItemStorage[]
---@field position_key string?
---@field item_states table<string, table>
---@field menu_state any

---@class fa.MenuItemRender: fa.MenuItemStorage
---@field label fa.MenuEventCallback Should push to ctx.message_builder
---@field click fa.MenuEventCallback Can push to message_builder, but doesn't have to.
---@field enabled fa.MenuEventPredicate

-- Parameter to the callback for initial state.
---@class fa.MenuStateCtx
---@field pindex number

---@class fa.MenuSpec
---@field tab_name string
---@field title LocalisedString?
---@field state_callback fun(fa.MenuStateCtx): any?
---@field render_callback fun(fa.MenuCtx): fa.MenuRender

---@class fa.MenuRender
---@field items fa.MenuItemRender[]

--[[
The magic.

This whole system is "magical" from the user's perspective: make a menu, and if
it changes we magically just handle anything you might do.  This function is the
meat of it, and basically the entire trick.

We aren't really doing performance, and we aren't really doing complex updates.
All we really care about is the menu items being drawn, and the position of the
player's cursor in the menu.  For today we discard drawing, but in practice that
is just a repaint; no need to be fancy like e.g. React.

There are a few cases that can happen, much less than you might think:

- The menu may be empty.  In that case, we'll hand out nil.
- The player's cursor may be on an item which exists, but items before and after
  it were shuffled or removed.  We're storing position by key though, so that's
  fine: it's not a numeric index which would need updating.
- Anything after the player's cursor can change (the "suffix"), effectively
  covered by the first case above, bu worth calling out.  Again there's nothing
  special to do there.
- Leaving removing the item under the cursor itself as our only real weird case,
  since the player no longer has a position.

To handle that, we remember (if any) the previous keys.  We can then iterate
backward on the previous keys until we find one that's valid; if we don't, just
give them the start.  If we have previous keys the current key *must* have been
in it, as every menu use goes via this function, so we assert that.

`menu_state` is modified in place.  `menu_render` is untouched.
]]
---@param menu_state fa.MenuState
---@param menu_render fa.MenuRender
---@return fa.MenuItemRender?
local function reconcile(menu_state, menu_render)
   local function find_pos()
      -- If there's nothing, return nil.
      if not next(menu_render.items) then return nil end

      -- If there is no key yet, set it and return the first item.
      if not menu_state.position_key then
         menu_state.position_key = menu_render.items[1].key
         return menu_render.items[1]
      end

      -- Next: if the key is still present, we just want that one.
      for _, item in ipairs(menu_render.items) do
         if item.key == menu_state.position_key then return item end
      end

      -- Okay, so now things get complicated.  Find the index of the key in the previous keys in menu_state.
      local prev_index = nil
      for i, prev_item in ipairs(menu_state.prev_items) do
         if prev_item.key == menu_state.position_key then
            prev_index = i
            break
         end
      end
      assert(prev_index, "We must find the key from last time")

      -- Now, iterate backward until we find a valid key.
      for i = prev_index - 1, 1, -1 do
         for _, item in ipairs(menu_render.items) do
            if item.key == menu_state.prev_items[i].key then
               menu_state.position_key = item.key
               return item
            end
         end
      end

      -- If still nothing, it's just the first one; we can't do better than that.
      menu_state.position_key = menu_render.items[1].key
      return menu_render.items[1]
   end

   local pos = find_pos()
   -- And then copy the keys over.
   menu_state.prev_items = {}
   for _, item in ipairs(menu_render.items) do
      table.insert(menu_state.prev_items, { key = item.key })
   end

   return pos
end

-- Internal to this module.
---@class fa.MenuTabCtxInternal: fa.ui.TabContext
---@field state fa.MenuState

--[[
Return a descriptor for a tab containing a menu.

The tab's name will be `menutab-menu_name`.  

Which would put the cursor in this tab on that menu item.  If the tablist is
only one tab, that makes it so that the menu opens to the right place directly;
otherwise it's where the player'll be put when they tab over to it.
]]
---@param opts fa.MenuSpec
---@return fa.ui.TabDescriptor
function mod.declare_menu(opts)
   ---@type fa.ui.TabCallbacks
   local menu_callbacks = {}

   ---@param ctx fa.MenuTabCtxInternal
   ---@return fa.MenuCtx
   local function build_user_ctx(ctx)
      local controller = {}
      ---@cast controller fa.MenuController

      function controller:close()
         ctx.force_close = true
      end

      function controller:close_because_textbox()
         ctx.force_close = true
         ctx.close_is_textbox = true
      end

      return {
         pindex = ctx.pindex,
         message = ctx.message,
         state = ctx.state.menu_state,
         item_state = nil,
         controller = controller,
      }
   end

   ---@param ctx fa.MenuTabCtxInternal
   ---@param callback fun(fa.MenuTabCtxInternal, fa.MenuRender, fa.MenuItem?)
   local function render_then_or_close(ctx, callback)
      local render = opts.render_callback(build_user_ctx(ctx))
      if not render then
         ctx.force_close = true
         return
      end

      local item = reconcile(ctx.state, render)

      callback(ctx, render, item)
   end

   ---@param ctx fa.MenuTabCtxInternal
   function menu_callbacks:on_tab_list_opened(ctx)
      ctx.state = {
         item_states = {},
         prev_items = {},
         menu_state = opts.state_callback({ pindex = ctx.pindex }),
         position_key = nil,
      }

      local rendered = opts.render_callback(build_user_ctx(ctx))
      if not rendered then
         ctx.force_close = true
         return
      end

      reconcile(ctx.state, rendered)
   end

   ---@param ctx fa.MenuTabCtxInternal
   ---@param item fa.MenuItemRender
   ---@return fa.MenuCtx
   function build_item_ctx(ctx, item)
      local u_ctx = build_user_ctx(ctx)
      u_ctx.item_state = ctx.state.item_states[item.key]
      if not u_ctx.item_state then
         u_ctx.item_state = {}
         ctx.state.item_states[item.key] = u_ctx.item_state
      end

      return u_ctx
   end

   ---@param ctx fa.MenuTabCtxInternal
   ---@param item fa.MenuItemRender?
   local function read_cur_item_postrender(ctx, item)
      if not item then
         ctx.message:fragment({ "fa.ui-menu-empty" })
         return
      end

      item.label(build_item_ctx(ctx, item))
   end

   function menu_callbacks:on_tab_focused(ctx)
      print("Before " .. serpent.line(ctx, { nocode = true }))
      render_then_or_close(ctx, function(ctx, render, item)
         read_cur_item_postrender(ctx, item)
      end)
   end

   ---@param ctx fa.MenuTabCtxInternal
   ---@param direction -1 | 1
   function do_move(ctx, direction)
      render_then_or_close(ctx, function(ctx, render, old_item)
         if not old_item then
            ctx.message:fragment({ "fa.ui-menu-empty" })
            Sounds.play_menu_move(ctx.pindex)
            return
         end

         local old_index = nil
         for i, item in ipairs(render.items) do
            if old_item.key == item.key then
               old_index = i
               break
            end
         end
         -- If reconciled and nonempty and we have a current item, then we'd
         -- better be able to find it.
         assert(old_index, "We got an item from outside the render array?")

         local new_index = Math2.mod1(old_index + direction, #render.items)
         if old_index ~= new_index and (new_index - old_index) ~= direction then
            -- We wrapped, and don't have more than one item.
            Sounds.play_menu_wrap(ctx.pindex)
         else
            Sounds.play_menu_move(ctx.pindex)
         end

         local new_item = render.items[new_index]
         ctx.state.position_key = new_item.key

         read_cur_item_postrender(ctx, new_item)
      end)
   end

   function menu_callbacks:on_up(ctx)
      do_move(ctx, -1)
   end

   function menu_callbacks:on_down(ctx)
      do_move(ctx, 1)
   end

   ---@param ctx fa.MenuTabCtxInternal
   function menu_callbacks:on_click(ctx)
      render_then_or_close(ctx, function(ctx, render, item)
         if not item then return end

         item.click(build_item_ctx(ctx, item))
         Sounds.play_menu_click(ctx.pindex)
      end)
   end

   return {
      name = opts.tab_name,
      title = opts.title,
      callbacks = menu_callbacks,
   }
end

return mod
