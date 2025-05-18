# Introduction

This is a list of pending work items for our contractor(s) which will have items removed as they are completed.  This
does not correspond one-to-one for git issues, but each section mentions issues where appropriate.

If you aren't contracting with us *do *not* try to take work from this file because you want to help us out.  Insteadd,
consider the issue tracker directly or ask us if you can take something.  We have plenty of things and are happy to have
you contribute, but work in this file should be considered assigned to a paid contractor, so PRs may or may not get
reviewed and landed but will certainly get closed if we are already paying for work in that area.

Each task below has a motivation and plan section.  Some have more than that.

There is an assumption of some in person/via Discord mod onboarding.  Probably a couple hours.  Tasks are ordered in an
onboarding-friendly fashion at the cost of early ones being boring.  This isn't all the work we have.  Tasks fall off
the top of the file as they complete and new work gets added to the bottom.

There are also some dev notes here: https://github.com/Factorio-Access/FactorioAccess/wiki/Info-for-Contributors

Note that it is a year old, and only 75% or so accurate.

# Completed Work

- Onboarding and global variable audit (40 h)
- fa-info preparation for 2.0, aka `]` key (17 h, 57h total).
- Refactor cursor handling to a new viewpoint module to allow for space age and remote view enhancements (15h give or
  take a bit, total 75 h).


# Tasks

## Move cursor-related global state to viewpoint.lua

GitHub Issue: [Factorio-Access/FactorioAccess#265](https://github.com/Factorio-Access/FactorioAccess/issues/265) plus
some others.

### Motivation

In 1.1, the mod assumes one surface exists.  A surface is a "map".  In 1.1, this is not true in mods, but it is true in
vanilla, which was considered good enough.  1.1 also considers there to always be a character attached to a player (the
player is the user, the character is their body).  Mostly this is all true in 2.0 base, but none of it is true in space
age.

Space age adds multiple planets (one surface each), plus one surface per space platform (spaceship).  This breaks the
mod's core assumptions around basically everything.  In particular the 1.1 version of the mod stores all sorts of caches
with no proper invalidation, relies on the cursor position to be on the same surface as the player, just all sorts of
ugly.  We've managed to fix the worst cases (e.g. the scanner), but the mod's cursor is represented by a random variable
in the `storage` dictionary (explained below) without going through functions.

Much of this can be split into isolated tasks or done at a later date, but only if all cursor operations go through a
module.

### Plan

Factorio mods must run deterministically, so everything is stored in a magic global called `storage` or stored in a
non-storage variable but derived from `storage`.  Factorio has forked Lua so that if all values are stored in or derived
from storage, the scripts will run deterministically on all machines of a multiplayer game or during replays.

Start by reading this, which explains what `storage` is: https://lua-api.factorio.com/latest/auxiliary/storage.html

And note that for the rest of this ignore the hand direction because reasons (but see the next task).

In control.lua is an array called players.  This is a reference to storage.players slated to be removed.  You will find
code like `players[pindex].cursor_pos` all over the mod.  In fact the only real use of `cursor_pos` is as that field so
a ctrl+f for it can find lots of places.  There are some references that start with storage.players as well, because
using that global players array is a bad idea and we want to get rid of it.

A `viewpoint.lua` `scripts.viewpoint` has been provided.  It is not yet used.  You will replace code that references
storage directly with code more like this:

```
viewpoint = Viewpoint.get_viewpoint(pindex)
-- Do a ton of stuff with the viewpoint, which is a class...
viewpoint:set_cursor_pos({ x = 1, y = 2 })
-- etc.
```

So, this task comes with 3 steps:

- Identify the variables which represent the cursor.  `cursor_pos` is known but there are some lesser ones for things
  like cursor size (shift+i).  Probably only 2 or 3 or something, it's a small number.  Consider `/fac storage` which
  will dump the entire storage dict (yes exactly that, verbatim).
- Copy the `cursor_pos` setter in viewpoint for the other fields.  Almost copy/paste.
- Go through the codebase and replace them with the viewpoint module.  Ideally one `get_viewpoint` per function near the
  top (or at the top of a loop etc) not multiple.


This will be a bit hard to test.  It's fine if places crash, we expect that.  I'd suggest testing as follows:

- In not-cursor mode and outside of telestep (alt+w to toggle), run around.
- In cursor mode (i to toggle) arrow around a lot preferably over a bunch of entities.
- In larger cursors (shift+i) arrow around over stuff.
- Use shift+wasd to do some cursor skipping
- And finally put a furnace or something bigger than 1x1 in hand, and use ctrl+wasd to "move by preview".

## Evaluate whether or not we can get rid of our direction guessing code for the hand

Issue: none, we found out about this possibility last week.  There's a few somewhere about 8-way and 16-way rotation,
but not worth digging up.

### Motivation

The mod (even the 1.1 mod) has extremely complicated code to guess which way the item in the player's hand is facing.
This must be fixed for 2.0 either by removal or updating.

The cursor's hand only rotates when the player presses keys.

2.0 now passes the hand direction to "custom input events" which are our keys.

QED we might be able to kill everything to do with it, and just figure it out based off the value passed with the last
keypress.

### Plan

because this could get quite involved, we'll leave off actually making the change for now.  To scope this to something
reasonably quick, the goal will be to find out whether this can be done at all.  To do so:

- In data.lua, find our `r`, `shift+r`, and `[`  bindings.
- In control.lua find our on_event calls that correspond to the `name` field from data.lua.
- Hack these three to tell you what direction they got from the game.
- Figure out if r and shift+r are lagging (that is do we get the value before or after the rotation)
- Figure out if `[` matches the mod.
- Hack the code path leading to `build_from_hand` to use this direction instead of our guessed one.  Use a global or
  whatever, it's research not real code.  You may be able to just flat out not pass a direction at all, honestly.  I'd
  try that first.

Note that the mod's guessing code is *not accurate* for 2.0.

If you do all of those, then placing a transport belt on the ground will show the correct direction of the hand at any
given time.  So, compare that to what the mod has.  Directions are `defines.direction` (game-provided) and are (in the
console integers from 0 to 15 going clockwise from north.


## Input Cleanup

Issue: tons, not going to bother.  Blocks a lot.

### Background and Motivation

Factorio represents custom inputs with `CustomInputPrototype`. For example (from our mod):

```
   {
      type = "custom-input",
      name = "click-menu",
      key_sequence = "LEFTBRACKET",
      consuming = "none",
   },
```

Which means "When leftbracket is pressed, find an event handler named click-menu and call it".

These are in data.lua, and run as part of the "data lifecycle".  but there's a couple problems.

First is the small problem that data.lua is huge.  We're here so we can fix that while we do the rest (it can be split).

But the real motivating problem: Factorio allows inputs to conflict.  When this happens, all events for all related keys
will trigger in some arbitrary but deterministic order.  In the ancient past, the mod decided this was the way to handle
"overloading" a key, e.g. all the different things `[` might do each get their own prototype.

Now, in order to add new functionality, one must make sure that all of the conditions line up so that it is not possible
for any conflicting event handlers to run.  This is a potentially significant radius, because for example `[` is used to
build, drive blueprints, run menus, manage inventories...and each of these may or may not be in an event by itself.  On
top of that there are event stateful changes where keys temporarily mean something else.  This can no longer be reasoned
about.  As a result, it's not possible to clean up, centralize, or add new menus, or continue to "overload" keys.  It
may seem like overloading keys is a bad idea in the first place, but truthfully we are out of keys as it is.

What we give up (at least temporarily) is the ability for users to map individual actions to other keys.  We can bring
that back with alternate prototypes which are not mapped to any keys by default, but only if there is enough demand.  It
is suspected that no one really remaps anything.

### The Work/Plan

We have code like this:

```
script.on_event("click-menu", function(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)

   if not check_for_player(pindex) then return end
   if players[pindex].last_click_tick == event.tick then return end
   local p = game.get_player(pindex)

   if router:is_ui_open() then
      -- stuff
   end
end)
```

Where the condition is whether or not it should do anything at all, sandwiched inside an if statement. Or, code like
this:

```
---@param event EventData.CustomInputEvent
script.on_event("vanilla-toggle-personal-logistics-info", function(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)
   local c = p.character
   if not c then return end

   local p = c.get_logistic_point(defines.logistic_member_index.character_requester)
   if not p then return end

   -- Ok we can do it.
end)
```

Where the conditions return early if there is nothing to be done.  My preference is for the latter pattern because it
avoids the indent "waterfall".  But in any case, the problem here is that these are in event handlers by themselves.

What we want to do is get off the fun names to systemic names, and then collapse these.  The proposed scheme is
`fa-[cas]-key` for example `fa-c-leftbracket` is ctrl + leftbracket, `fa-j` is just j, etc.  The cas are "bitflags" and
always specified in that order (none for no modifiers, `c` is control, `a` alt, `s` shift).  A single prototype per key
combo covers all others that were on the key, so we drop those.  Then we can perform a mostly mechanical transformation,
just far enough out that the AI can't quite do it:

```
script.on_event("old1", function(event)
   if condition1 then
      -- do it
   end
end)


script.on_event("old2", function(event)
   if condition2  then
      -- Do it
   end
end)
```

Would become:

```
local function kb_old1(event)
   -- Code without the condition
end

local function kb_old2(event)
   -- Code without the condition
end

script.on_event("fa-newkey", function(event)
   if condition1 then kb_old1(event)
   elseif condition2 then kb_old2(event) end
   -- If we fall off the end that's fine to do nothing.
end)
```

Which ensures that only one of them runs per press.  the `kb_` prefix is kind of literal, just to let us know "this is a
block of code from the keyboard", and indeed for smaller ones (e.g which already call out to a module) not having the
intermediate function is fine.  You will want to pass the event around for now rather than deconstructing at the top,
and annotate:

```
---@param event EventData.CustomInputEvent
```

Note the following:

- We genuinely don't know the old order.  Bias UI/menu conditions toward the top but other than that it's ambiguous and
  we don't care right now because getting this far will let us see if that ever matters, since overlapping/wrong-order
  conditions won't both trigger anyhmore.
- Control.lua has a ton of code duplication.  For now that's out of scope, because most of it is being moved to modules
  and doing so was blocked by input being a problem.  For instance the menu_up/menu_left/etc. functions are very clearly
  *almost* but not quite duplicates that could be "fixed", except new UI framework wants to just plug in.
  - That said, don't add more if it's easy to avoid. If it's not easy to avoid, shrug.
- testing is a pain.  It's fine to break stuff.  The only real test is "play a full run of the game".  So do your best
  but don't freak out over that, no judgement as long as like really basic stuff works.
- Lua function order matters.  Callees must be declared before callers when using the `local function` syntax.
- Feel free to be rid of any obvious dead code.
- Feel free to mark things which are local to control.lua as locals if you find any, though going after them is out of
  scope; it's a self-resolving problem down the road.
- linked_game_control and consuming are "union".  if any of the old prototypes has them the resulting prototype should
  get them.  It happens that such a transformation shouldn't change observable behaviors.
- What to do about things like page up which don't exist on laptop keyboards is a tbd question for now.  Feel free to
  punt it.
- Alternate key mappings get dropped.
- Prototypes which are only modifiers, if any, can be dropped.  They weren't the greatest idea in the first place, but
  they're for scanner and there are other keys already.
- There are other prototype kinds in data.lua, just leave those alone.
- To "execute" a lua file, `require('otherfile)` without assigning it to anything.
- trains will come up.  If possible preserve their key handlers.  You can't test those.  If it's unclear where it should
  go in the handling, put it in the else branch for now.  Mostly these are being kept for documentation.

Concretely I recommend doing it like this.  There's other ways but this is what I'd do:

- Make data/input.lua and require it from data.lua.
- `data:extend { ... }` in it so you can start moving prototypes over.
- Find the first prototype in data.lua that's an input and make the new prototype.
- Write down all of the others from data.lua that match it and delete them from data.lua.
- Go find all the event handlers in control.lua and cut them to another file (cut, not copy).
- Paste that other file back into control.lua at the bottom.
- Deal with that set.
- Repeat until done.
