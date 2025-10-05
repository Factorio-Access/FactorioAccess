# Overview of 2.0 Changes (so far)

This is a living document. Last updated 2025-10-05.

## Directions

You need to:

- Not be using Steam. Get it from factorio.com
- Be running from git on f2.0-dev.
- Use sample-config.ini in the root of this repo as your config file.
- min version is 2.0.69.  Expect this to increase rapidly.
- Only our mod and KK are supported. For a variety of reasons other dependent mods we used to package are not currently applicable.

Very important warnings:

- We do not support space age.
- We are not guaranteeing save compatibility until a release.  We will try to preserve it at this point but that is not a guarantee, and code cleanup takes priority.
- Play in peaceful.

## Things that don't Work at all (if you test these we will ignore you because we already know, we're working down this list in no particular order)

- Combat. Play in no enemies.
- Trains.
- Decider, arithmetic, and selector combinators
- manipulating fluids
- spidertrons
- personal logistics (but logistic entities are fine)
- blueprint books
- roboport configuration
- inserter filters
- Underground belt exit assistance. To work around it, rotate the exit by 180 degrees before placing (getting this back is priority--expect it very soon).

There's also a lot of roughness around the edges we're still spending down.
Support for quality is intentionally sparse.  We are doing it where not doing so would cause tech debt, but quality is a space age feature and not priority at this time.

## Basic Changes

Telestep is gone. SO is honking.

Fast travel has moved to alt+v so that `v` and `h` can match vanilla for item/blueprint flipping.

The tutorial system is un-wired and pending replacement.

Instead of cursor mode, wasd now always moves the cursor.  Arrow keys always walk.  `i` now toggles whether or not the cursor is anchored, which means whether or not it follows you.  These changes exist to let us support better remote view and combat in the future, and also because most players stay in cursor mode.

Build lock no longer clicks while you move.  This may come back but it turns out that late game you move too fast for it to work.  Instead of having one build lock, you have two that work at the same time. One on wasd, and one on the arrows as you walk.  That is, when build lock is on, both things run their own separate build lock.  To place long lines of belts:

- Use the cursor to teleport your character to the start
- Run your character along the belt

Build lock is no longer fragile when moving quickly, and should always place electric poles `x` tiles after the last one even when building near other poles.

Build lock disables itself if you lose the line because you bumped into something.

Build lock also now fills in every tile of transport belts always. This means that running at an angle will give you a "staircase" of belts.  That is almost never what you want, but is better than leaving  aton of junk belts around that do nothing.

Build lock is now better about not playing error sounds when it is actually working.

Instant mining has been removed.  Instead, `ctrl+x` now supports most of the vanilla cut functionality.  Due to API limitations, it does not support preservation of external circuit network connections.

Underground belt exit assistance is temporarily gone but will come back shortly.  Pipe to ground rotation is gone permanently.

To match vanilla, your hand always starts facing north when you put something in it.

When placing tiles (concrete, landfill), we no longer have a math bug.  It is now properly placed with your cursor in the center.

Steam engine snap assist is gone.  It is easy to do this with skip by preview instead.  We only ever offered this for steam engines, but many other entities have fluid connections.  Learning how to do this by yourself is important for midgame, late\ game, and space age.

You may temporarily notice increased scanner latency.  Due to API limitations, our mechanism from 1.1 which allowed us to see all entities as they were placed is no longer available.  A new mechanism is being built.

## New GUI

The biggest part of the 2.0 mod is an overhaul to the GUI system:

- ctrl+tab now moves between "tabstops". To get to the crafting menu ctrl+tab. Tab moves between smaller sections, for example all inventories.
- Inventories are dynamically exposed  
- To get to guns and ammo, press tab from your player inventory.
- Menus no longer wrap. Instead they stop at edges. But that's okay because...
- Pressing ctrl+wasd moves to the edge of a menu or grid or etc.
- Search is now universal in all menus now and forever.
- GUIs can be nested. When this happens, `E` closes all GUIs `alt+E` goes back one level.
- Many things you would expect to support "resetting" support being reset with backspace. Expect more things to use that as reset and/or delete in future (e.g. fluid flushing, deleting blueprint from book).
- Menus now support horizontal rows "row of 3 items", which is used for a variety of purposes to avoid for example having 3 menu items for every circuit condition. Move through a row with `a` and `d`.

This necessitated a number of compromises.  Most notably `e` no longer opens the vanilla character GUI. That has  been moved to `ctrl+alt+shift+e`.  You shouldn't need it unless playing with someone sighted.  We also no longer make any attemp to respect escape.

GUIs do not sync to their graphical counterparts at all at the current time. This will be revisited after the initial 2.0 release, or possibly never depending on demand and availability of sighted contributors.

## Circuit Network and Power

We now hide neighbors for electric poles behind `n`.  Press `n` on an electric pole to hear specific neighbors. Otherwise, you will just get "connects to 2".  If you haven't been keeping up, scanning is now fast enough that you can just re-scan instead of re-sorting a current scan (that has been true for a long time).

Circuit network neighbors are hidden behind the same mechanism.

Circuit network GUIs are now exposed. `ctrl+tab` once or twice depending on the entity to reach the circuit network tabstop, then tab through it.  You may use this to see all signals broken down by quality, for red green or both.  You can now configure most entities.

Constant combinators fully support the 2.0 model in which they are sending the contents of logistic sections. See below.  It's the same UI as for the logistic network.

All signal types are supported, chosen through a multi-level tree selector. You can in fact configure an assembler through the circuit network if you want.

An experimental circuit network navigator GUI is available via `ctrl+alt+n`.  It exposes the structure of the graph.  As you click items, your cursor moves to them and the menu updates to be from that items perspective.

Constant versus signal for the second parameter of circuit conditions are now controlled via an accelerators mechanism: hit ctrl+alt+s to select a signal, ctrl+alt+c for constant.

## Logistics 2.0

Logistics in 2.0 have changed significantly from the sighted perspective as well as from ours. If you are a player exploring this document, read the Factorio Wiki to learn about the mechanics. This explains what we support.

Briefly, though not exposed in the UI for the sighted, every logistic entity has some number of logistic points. These represent things like the requesting part of a requestor chest.

Our GUI is based around logistic points for now. We may provide a more abstract view later.

It is arranged like this:

- The first tabstop is one tab per logistic point.
- Only one logistic point on an entity can ever have sections (as far as we know) so the second tabstop is one tab per section
- To get your first section, use the horizontal controls on the requester or buffer point.

The old keys are no longer functional.  This is because 2.0 logistics does allow for multiple sections. In particular we do support logistic groups.  You can find the controls to add a group to a section at the bottom of the section.  That is, make an empty section then set a group to it.  You can have multiple empty sections on one entity and you can have multiple grouped sections on one entity.

We do not support editing groups independent of their entity and we do not yet support deletion. To make a new group, use ctrl+alt+t to type it while on the group control, or find it in the groups menu.  To work around the lack of editing, temporarily or permanently place a section in the group, change that section, then remove it.

Requests are no longer bound to items in your hand.  Instead, you choose them from the item chooser tree on addition.  You also now directly type numbers rather than adjusting by stack size.

An overview of all logistic requests is available on the point itself, accounting for all sections.

`backspace` clears min (to 0) or max (to infinity). To delete, use the rightmost item in the row.

This interface is the same for constant combinators which also can be in logistic groups; to that end the constant combinators do let you edit the max even though they don't use them.

## Belts, Fluids, and heat

The GUI here is completely familiar, but there are a number of notable changes.

For belts, information is now provided on:

- Things ahead or behind of your belt segment
- Where turns come from, not just that there is one

The belt analyzer now matches vanilla  behavior for the most part. Your belt analysis no longer includes everything it can possibly find, but only what is on the current belt.  Among other things, this prevents it from falsely reporting that your belt is mixed when it is not.  It is also significantly faster.

The current belt tab of the belt analyzer no longer rotates. The "top" is always the outgoing direction, and it is always 4 rows by 2 columns.

Belt announcement is now somewhat more verbose. Depending on feedback and available time, we hope to make it less chatty in the near future.

Pipe announcement has been completely reworked to be based off shapes. For example, "connets north and south and east and west" is now "cross".  Build various pipe shapes to see how they are now announced.

We are now briefer about bidirectional pipe connections and have in general tightened this messaging.
