# UI System

Last reviewed: 2025-12-23

# The TLDRs

## TLDR: I just want to make a menu

Great!  Find a mod UI close to yours, find the lua file for it, copy/paste.

blueprints-menu.lua is a simple one-tab menu.

The bottom of the file will be a bunch of registration stuff. Change it in the obvious manner to match your UI names.

In router.lua add a new `UI_NAMES` name for it and make sure your new lua file matches.

**IMPORTANT**: next import it at the top of control.lua `require(myui)` so that it registers. Even though control.lua
won't use it directly, this lets the file run, which runs the registration.

You just got all our standard keyboard interaction and search.

## Slightly bigger TLDR: I want to do something complicated, but I don't want to know how all this works

You just built a menu. That's a tab inside a tab list.  Build more menus and put them in the same tab list and now
you've got tabs.

Broadly speaking you want to choose from:

- chooser-tree: a tree of items, for selecting things like signals.
- menu-builder: for vertical menus, sometimes with horizontal actions
- grid: the inventory grid, etc.
- category-rows: like the crafting menu. Each row is a category, items are in the categories.
- One of the above, plus opening another UI that knows how to send you a result as a child (e.g. item-chooser).

# The Long Version

## Introduction to the Problem

Factorio has a GUI system which is entirely graphical and (to some extent) declarative. There is no concept of an action
for example, beyond GUI clicks and confirmation. We also do not have access to this GUI accessibly.  If we want a GUI
for the blind, we must write our own spoken UIs.

In a normal world we would simply define some sort of virtual interface and implement it.  In the Factorio world however
we must account for some stuff:

- Events, which are shared with non-UI components
- the save-load cycle, which doesn't let one store closures anywhere and only has limited support for metatables
- localisation, which has a few limitations, most notably a 1-tick delay on converting a table-format localised string
  to a plain string.
- Entity invalidation, world state changes, and config changes underneath the GUI. For example death, changing item in
  hand, whatever.

On top of that, whatever we do should be easy to code for.

## Introduction to the Solution

I (ahicks) call this continuation-returning style.  I think it's sort of otherwise nameless.

If you look at a GUI framework like React, what they do is have you rebuild the GUI every update, then they put some
intelligent stuff on top.  You can capture whatever you want in your closures, and it's basically "if you can write some
HTML once, you're done" rather than the older model of declarative GUI actions where you manually write 50 different
handlers for changes yourself.  There's some quick intelligent diffing and that's it.  In the JS world, that's fine
because the GUI (usually) owns app state, and restarts aren't a concern.  Your closures just sit there quietly until
things need them and all is well and you get frontend devs who don't even have to fully understand the magic of `() => {
... }` and JSX.

In Factorio we have an issue though.  Every GUI may need to close itself at any time for any reason, and every GUI must
survive the save-load cycle.  SO, we can't just do that.

Ideally we want something like this:

```
local function build_the_menu()
   builder:menu_item("label", action)...
end
```

And then you have actions or whatever that go around doing things when you hit them.  You get some nice intelligent
diffing or whatever and everything is fast and smooth.

The good news is: we can get this.  The bad news is: not efficiently.  But the good news is: it's O(N) on at most a few
hundred items and nothing compared to sending to the launcher for speech. So, let's be inefficient.

Let's step back from UI for a second.  Here is some boring code.


```
if condition then
   do_the_magic()
else
   do_the_other_magic()
end
```


We can transform it like this:

```
local if_statement = {
    condition = function () evaluate_the_condition() end,
    if_true = function() do_the_magic() end,
    if_false = function() do_the_other_magic() end,
}
if_runner(if_statement)
```

Where `if_runner` is just:

```
function if_runner(c)
    if c.condition() then c.if_true() else c.if_false() end
end
```

that is, sort of, continuations.

So...why?  let's add a rule.  If a function returns a table of closures, we will never, ever do anything between that
return and calling the closures.  That means you can do one more code transformation:

```
function delayed_evaluator()
    -- Pretend this first bit is a bunch of complicated code.
    local foo = 5

    return {
        condition = function() return foo == 5 end,
        if_true =function() print("Yes!") end,
        if_false = function() print("No!") end,
    }
end
```

Which is still the same, because we're promising that the caller won't put any code in between.  Notably though, what we
are not promising is that the caller will continue running.

So, this is all nice functional programming theory.  But what's the point?  In essence, this is a button:

```
local function button(ent)
    -- We couldn't build our actions, o no, the entity died.
    if not ent.valid then return nil end

    return {
        label = function() return "a button" end,
        on_click = function() say("Clicked me!") end,
    }
end
```

Now if the weird complex action tables are behind builders that just let you go `:add_item(name, label, action)`, it
doesn't even look like FP:

```
function the_menu()
    local builder = MenuBuilder.new()

    return builder:add_item("unique-key", "the label", function ()
        -- do it
    end)
    :build()
end
```

So.  If you can write that, you're free to capture.  Just return nil if you can't do any actions all the way at the top.
`x.valid` checks go in one place. There's mostly no mutable state.

And from the external UI implementor's perspective, that's what's going on--though real code goes beyond these examples.
There isn't a worked example here because at time of writing this framework is new, and any such example would get
stale.

## The Basic Hierarchy

There are 3 levels to the UI system:

- The router, which maintains a mapping of names to callbacks that go with the name, and a stack of what's open.
- The TabList, which could be named better, that implements the callbacks and handles things like tab and ctrl+tab.
- Things built on top of the TabList, which are menus etc.

Text boxes and other "small" UIs are sometimes TabList and sometimes not; what you need to know mostly is that there's a
box selector and a generic textbox both of which you can reuse easily. Both are demonstrated in the blueprint menu.

To make this work, we amend the event system of Factorio, sending all control.lua events through an EventManager module.
A second layer of events registers in ui/router.lua, which block further event processing if a UI is open.  Do not use
this generally without more thought, as tempting as it might be; one of the old tech debt issues in the codebase was
overuse of duplicated event handlers. As a user this is all hidden away.

Basically, as far as this goes your choice is: either use TabList/reimplement TabList to do something else, or use
something built on top of tabList. The right answer is almost always the latter, but not always (for example box
selectors are simplified callbacks implementing the interface as laid out in router.lua's type annotations).  The higher
you go, the less you have to know.

## Search Handling

This deserves a brief section because it's important.  Search is handled for you if you use anything high level. if you
don't you will need to poke at how other high level things do it. Briefly, they must implement 3 callbacks: one saying
whether it supports searching, one to feed out all the strings that search might need to handle, and a couple to move to
the next/prev search result.  Generally this means flattening the list of items to a deterministic order.

The reason this is weird is because Factorio localisation does not let you get a string as a searchable block of text
without waiting one tick. This is to play nice with the multiplayer use case, but doesn't help us.  The mod has always
split searching into `ctrl+f` to set the pattern then `shift+enter` and `ctrl+enter` to move between items (next/prev
respectively).  So in the multiplayer case there might be a delay, but in the single player case we will have the
translations within 1 tick e.g. 16ms, e.g. faster than a human can get to the other key.

We maintain a large-capacity LRU of these conversions, so after the first time they become known to us and there is a 0
tick delay, as well.  How that LRU specifically works is complicated, but it is robust to the tables being different and
does some value-based comparison magic.  Read the code if you really want to know. Very very briefly the trick is that
you can replace the table start/end with unique strings containing `=`, then you can flatten the whole thing to just
strings and numbers.

This is all handled for you in router.lua. Your implementation even at the lowest level need only know how to pass
localised strings to callbacks, and doesn't even do sounds.

## State and controllers

Every GUI gets a controller from the router to open other GUIs and the like. GUIs are a stack, so you can open children
and send results to parents.

GUIs not built on TabList must maintain their own state with storage-manager.

GUIs built on TabList are additionally given state management, both shared and per tab, via a context parameter to all
of the things TabList wants to use.

The important thing to remember is that GUI code itself is pure most of the time, you're either writing to state or
building a message but almost never saying it or playing the sound--those are handled by the framework.

For the case where you just want to pass data in e.g. for initial open, we also pass around parameters, which are
supposed to be static.  Parameters are stored like state, but readonly.

Two patterns broadly exist:

- The "linked" pattern: your "state" is an entity, the player's hand, whatever. Your state object is empty.
- The "computed" pattern, like belt analyzer: you compute something expensive and store it in state and it gets
  refreshed on next open.

A vast majority of GUI stuff is the former. Like 99%.

## The Flagship: key-graph

This is the big thing all of this builds to, and with few exceptions it is what is going on under the hood.  What we
actually want for our GUI stuff is a graph of nodes with edges.  Movements are always an edge, and interactions are
always at a node.  For example a grid is a node for each cel and then vertical/horizontal edges, and a chooser tree is a
tree with a root etc etc.  Menus, grids, etc. are all built on this, and it is where we make the scalability tradeoffs
that lock us into GUIs of only a few hundred items or less: the graph is rebuilt on every keypress.

That seems bad, but Lua precompiles closures, exactly allocates table literals, all that. SO even for something like the
item chooser for every prototype in the game, there's not that much noticeable lag.

But even then that's not enough to justify it perhaps.  What does move it from "nice" to "needed": the key graph knows
how to intelligently deal with graph changes.  For example, if you delete a fast travel point and rebuild the menu, the
user will be put on the one above it; if you resize a grid the user will be bumped to the left/up, etc.  The trick is
that most GUIs are planar graphs.  We don't explicitly encode positions, but if we start at the start node we can define
a total order of nodes by just going right until we can't, then going down and going right until we can't again.  So for
a grid the order is left-to-right top-to-bottom, etc.  We compute this behind the scenes. Then we can check to see what
was "closest" in this order when something disappears at the next render.

This also lets us get ctrl+wasd to move to the leftmost/uppermost/etc. like home/end but also including beginning/end of
"row".  In the 2.0 version of the mod, this replaces wrapping as of this writing.  It is possible to reintroduce
wrapping, and it will be if there is demand, so it may come back by the time you read this (if you are the one who has
to readd it: add `is_wrap = true` support to key-graph connections with Claude).

The higher level builders mentioned at the top of this document are all built on this, except for category-rows which is
special cased so that it can remember the position per category, and other things like textboxes and box selection which
are flat out not menus.


## Overlay Functionality

UIs can opt into being an overlay by adding a `is_overlay` callback.  This does a few things:

- passes everything but clicks to control.lua
- Prevents closing when opening a UI, so that you can e.g. open fast travel while setting up a blueprint.
- Closes to the overlay instead of the map on e, so that people can conveniently get back out of fast travel menus etc.

Basically, in limited circumstances we need the cyclical behavior because the user needs to manipulate things with the
cursor contextually, where the context is "I am making a  list of things by clicking them".  this lets them do that with
all of their normal cursor tools.

## UI Binds

UIs often depend on game state that can become invalid while the UI is open, for example the player changing their hand
or an entity being destroyed. This is because the backing game objects become invalid.

Binds tie a UI to its underlying state. When that state becomes invalid, the entire UI stack closes automatically, as if
the player had closed it.

There are two bind types: entity destruction and hand contents changes. Entity binds use Factorio's
`register_on_object_destroyed` mechanism. Hand binds watch `on_player_cursor_stack_changed`.

UIs declare binds via a `get_binds` callback. The return value has three meanings:

- Return nil to signal invalid state and close immediately. Use this when the UI can't even open, like if the entity is
  already gone.
- Return an empty table to signal valid state with no binds. The UI stays open and nothing watches for invalidation.
- Return a table of binds to register them. The UI closes when any bind is violated.

The nil-vs-empty distinction matters for child UIs. Consider blueprint selection: the parent blueprint-setup UI binds to
hand contents, then opens a child box selector for area selection. The child doesn't need its own bind since it's
protected by the parent. If the hand changes, the whole stack closes. But the child must return empty, not nil. Nil
would close it immediately on open.

This is a subtle point for anyone implementing low-level UI components. If your component class defines `get_binds` at
all, it must return empty when there's no declaration-level callback. The method existing but returning nil means "I
tried to compute binds and failed" not "I have no binds".

It is important to implement your UI without binds first.  That is, you still need to perform validation.  The bind
system is not a mechanism to prevent errors, it is a mechanism to prevent players from seeing errors.  If binds wer
removed, the following flow would be possible (and is the flow that prompted binds):

- Player starts selecting a blueprint
- Player puts transport belt in hand
- Player clicks to place belt
- UI system goes but a UI is open, let's handle it
- Blueprint selector goes not a blueprint
- Player gets a "wrong planner" error instead

In particular docs are not very specific on if we get on_object_destroyed at the exact instance an object is destroyed,
or if there is a small window of invalidity.
