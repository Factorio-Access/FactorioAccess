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

There are also some dev notes here: https://github.com/Factorio-Access/FactorioAccess/wiki/Info-for-Contributors

Note that it is a year old, and only 75% or so accurate.

# Completed Work

- Onboarding and global variable audit (40 h)
- fa-info prepartion for 2.0, aka `]` key (17 h).

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
