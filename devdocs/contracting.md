# Introduction

This is a list of pending work items for our contractor(s) which will have items removed as they are completed.  This does not
correspond one-to-one for git issues, but each section mentions issues where appropriate.

If you aren't contracting with us *do *not* try to take work from this file because you want to help us out.  Insteadd,
consider the issue tracker directly or ask us if you can take something.  We have plenty of things and are happy to have
you contribute, but work in this file should be considered assigned to a paid contractor, so PRs may or may not get
reviewed and landed but will certainly get closed if we are already paying for work in that area.

Each task below has a motivation and plan section.  Some have more than that.

There is an assumption of some in person/via Discord mod onboarding.  Probably a couple hours.  Tasks are ordered in an
onboarding-friendly fashion at the cost of early ones being boring.  This isn't all the work we have.  Tasks fall off
the top of the file as they complete and new work gets added to the bottom.

# Tasks

## Audit the Codebase for Accidental Global Variables

Git Issue: None, but it needs to get done and makes for a good reason to read everything

### Motivation

The original version of the codebase was written without much care to code quality or style.  This has left us with th
occasional accidental declaration and sometimes use of a global variable where it was intended to be local.  This
happens most often with pindex, the variable representing the index of the currently "active" player e.g. who just
pressed a hotkey.

In single-player this is kind of okay.  Kind of.  Mostly the variabels get set and used in such a way that them
"jumping" through globals doesn't show up.  In multiplayer however, they can vary.  While we  don't have reported bugs
around this, we also wouldn't get them; it would manifest from the end user's perspective as weird mystical failures.

We keep thinking these are gone.  Then we find another one.  Apparently LuaLS cannot warn reliably about it, since it
doesn't know if the global is from another file or not.

### Plan

We don't know how many of these are lefdt.  Could be none.  Could be 100.  So it's fine not to find any.

Reading the full codebase is probably best (or at least ctrl+f for =).  that said, a regex like `^\s*\w+\s*=` (untested,
make sure it's right first) should be able to find all assignments in the codebase.  Alternatively a more complex regex
that looks for something like "first = in the function" or something may help.

AI is also fine if it can help out and if you know a way to do it.

Note that the following areas are known to be clean already, because they were written after we started caring about
such things. (o) after the name indicates that reading it is useful for onboarding to the codebase:

- data-to-runtime-map.lua
- descriptors.lua
- ds/* (O): skim filenames, contents not important
- fa-commands.lua (o): useful console command for debugging
- field-ref.lua
- filters.lua
- fluids.lua (o): one of the two most important game systems.
- functools.lua (o): especially for `functionize`
- geometry.lua
- kruise-kontrol-wrapper.lua
- memosort.lua
- message-builder.lua (o): will be using this for all message building.
- methods.lua
- research.lua
- rulers.lua
- scanner/*
- storage-manager.lua (o): used by almost every file in the mod; ones that don't will in the near future.
- transport-belts.lua (o): Other most important core game system
- ui/*
- uid.lua
- work_queue.lua (o): Not very important but useful to run background work which is trickier than you'd expect.


Note that fa-info is good if it is a function taking EntInfoContext.  Those have been rewritten.  The rest have not.

## Fix pressing `]` and clean up the part of fa-info.lua related to it

Git Issue: again none. Some have issues, I promise.

### Motivation and background

When all menus are closed, `]` is the "give me more info" key.  As the user moves their cursor over things, they receive
a somewhat long but still "brief" version of the information.  To get more they press `]`, for example inserter items
per second, electric network usage, etc.

fa-info handles both cursor movement and the `]` key.  Cursor movement is prepared for 2.0, but `]` is not and will
crash the mod.  We also want to make it localisable while we are here.

This also onboards you to working on more complex mod features, Factorio API exposure, and the console.

### Plan

#### Overview

This is shorter than it seems but it is also an onboarding task, so much of the info below provides the background
information required to get it done.

Basically 2.0 changed the APIs.  LuaLS will warn about some of it but not all.

What you want to do is open 1.1 and 2.0 side by side, look down fa-info.lua starting in `function
mod.read_selected_entity_status(pindex)`, and figure out what entities it does extra things for.  Then, set up a
scenario in both 1.1 and 2.0 that will roughly match, and crash it.

The trick here to make it manageable while also removing tech debt is this.  Factorio entities have a prototype ("I am a
power generator") and name ("I am a specific kind of steam engine" of which there is only one in Vanilla).  What you
want to do is move the checks not to rely on the name (if any).  Once that's done, you only have to play with an entity
of each prototype (so e.g. just one of the assembling machines, not all 3), since while the 1.1 mod has special cases
the 2.0 mod no longer does and you only have to extract info from each.  In practice the 1.1 mod's behavior is also
per-prototype, there's just been a lot of hardcoding around lists of names.  Most info is in the factorio API.

My recommendation is to split like how `ent_info` is in the same file.  You will be able to reuse some of the `ent_info`
machinery because there is overlap, then just add a bunch more following the same pattern.  This should be obvious from
the file, but ask if it's not.

Some things won't be obvious e.g. a lot of the electric network is various surface queries and aggregation.  For those,
ask for help.  @ahicks probably knows.

#### Cheat mode and `/fac`

To get entities, press ``` to open the console, then type `/cheat all`.  The first time nothing will happen but a
warning about disabling achievements, so do it a second time.  This will do a few things:

- Add a number of un-craftable things to the inventory, most notably an electric-energy-interface and infinity-pipe,
  which provide free power and free fluids respectively.
- Make all crafting free and unlock all technologies.
- When your hand is empty and over something pressing `q` will fill your hand with a full stack of it (which is how you
  get more of the uncraftable items).

To configure infinity pipes, craft a barrel of the appropriate fluid, put it in hand, and then  press `alt+[`.

It may be easier to configure things via lua, even though cheat mode should handle most of it.  In either case this is
the appropriate place to learn about `/fac`. In vanilla one may `/c some lua here` to run arbitrary bits of lua from the
console.  The player is at `game.player` and the player's selected item at `game.player.selected`.  THe vanilla version
lets you also run in other mods via `/c __modname__ some lua`.  But it doesn't speak, nor can it be made to.  So, two
options:

- In 1.1, you can wrap your Lua in print, start the launcher with `--fa-debug`, empty your hand, and text shbows up over
  there at the bottom.
- In 2.0, use `/fac` instead which pretty prints and provides access to many pre-imported modules from the mod.  The
  downside is that it cannot run code in the environment of any mod, only inside Factorio Access.  But for this project
  that's not a huge issue.


#### The Localising Part

Note: Factorio spells localisation with s not z.  So do we, to match Factorio.

You will notice in fa-info heavy usage of `MessageBuilder`.  This is our gateway to the world of localisation.  In
Factorio, localised messages are represented like:

```
{ "mesagekey", parameter, parameter, ... }
```

In the cace of fa-info, `locale/en/entity-info` is the file of choice, and contains a ton of examples.  Also read this
tutorial: https://wiki.factorio.com/Tutorial:Localisation

Ok so where does message-builder come in.  The message builder is needed because you effectively get one printout/spoken
message per tick.  This is because speech happens in the launcher via AO2 and so messages interrupt the last one.
Consequently you've got to aim for one message per keypress, otherwise the player only reliably hears the final one.
This can be done.  Factorio has a syntax for joining localised strings together.  Unfortunately there's a bunch of
limitations around it which only show up in the complicated cases (e.g. lists of more than 10 items run against it
because there's a limit of 20 parameters and "," counts as a parameter).


What message-builder knows how to do is join strings together.  It can handle old-style Lua strings and l;ocalised
strings in any combination, and also knows how to get the commas in lsits right.  We gave up on localising word order to
the degree of list rearrangement because this mod is basically a giant string builder.  As an example (with
non-localised strings):

```
mb:fragment("a")
mb:list_item("b")
mb:list_item("c")
local printable  = mb:build()
```

Is "a b, c" (because it knows not to put the comma in at the start of a list) and you may replace any or all of them
with localised strings instead.

fa-info.lua uses it extensively so you can learn the rest from there.

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
