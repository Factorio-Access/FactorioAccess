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

## Heat Pipes

We need a module for heat pipes like the module for fluids.  The differences are that heat pipes don't have fluidboxes
or underground connections.  Like this:

- Refactor the shape logic in fa-info and fluids.lua to be abstract enough to give you the shape of a pipe when it's not
  a real fluid pipe.
- Write a function which can find all heat connections on an entity.
- Special case heat pipe itself in this to always have one connection.
- When on an entity over a heat connection probe one tile in all directions to find other entities, and check if you landed on one of their heat connections.
  - It looks like floats would be an issue here but all floats for heat connections are 0.5, e.g. direct equality tests actually work out.
  - Heat pipes aren't an exception, save that their heat connection is sort of faked out.
- If it is a heat pipe, grab all other adjacent heat pipes and build the shape, then announce what it connects to that's
  not a heat pipe, e.g. "heat exchanger at south".  Fluid code already does this, so you might be able to make it
  somewhat generic again.

In 2.0 base your entities for heat are nuclear reactors and heat exchangers.  Space age adds a bunch more.  To determine
if an entity "participates" in heat, it is sort of enough to just find out if it has a heat connection.  The only
exception to that is aquilo which we will handle later because it's not something that fits in this module (indeed it
may already work).  Entities which participate in heat need to have their temperature read.  Code for this already
exists in fa-info but it may not extend to Space Age entities due to special casing off prototype types.

## Aquilo iceberg scanner backend

there are a lot of things to do with scanner that we can work on but probably the easiest is aquilo icebergs.  There
isn't much in this document because scanner is fully documented in devdocs/scanner.md.  In practice such a backend is
just an inversion of the water one, e.g. a different tile set.  Don't be fooled by the resource scanner using the
spatial hashes, which is sort of legacy; that can go in favor of tile-clusterer as well, but there's no pressing need to
rewrite so we haven't.

## Test Larger Cursors on Gleba

This is an easy one maybe.  Make a large cursor and move it over gleba and see how it crashes horribly.  Hopefully it
doesn't.  If it does we will discuss what work needs to be done.

## Script to do Releases

This needs some scoping but since we have the spare slack it'd be a good idea. What we know wrt the flow:

- It has to run locally because of Factorio creds.  So sadly no CI builds.
- Package this mod with fmtk.
- We probably just want to throw our dependency mods in a github repo or something because you copy those zips in.
- Figure out what to do about the launcher. Ideally we can grab the latest release from GitHub automatically.
- Making a GH release can be automated.

Ideally automate with Python since we already have that dependency.

We can talk about needed credentials.  You shouldn't, because you can test against your own repo for the GH side of this
and the fmtk uploading is one line.

The one weird exception to the dependency mods is that Kruise Kontrol is now maintained by us as Kruise Kontrol Remote.
That should be cloned somewhere and built.  We could put it as a submodule of the main repository no problem, and in fact that might be the best.

## Spidertrons

This is blocked on UI framework work which is in turn blocked on input refactor.

Spidertrons are broken even in 1.1.  They need to be fixed.  We don't know what this means.  Start by ignoring the new
spidertron RTS tool in 2.0, and just get the old menu working as much as possible. The RTS tool has interesting
questions around it and someone on the core team will probably have to answer them first.
