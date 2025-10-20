# Overview of 2.0 Changes (so far)

This is a living document. Last updated 2025-10-19.

## Directions

First, note the following important warnings:

- We do not support combat yet and that is not coming soon. Play in no enemies.
- We may break your save. I mean on purpose, not by accident.  We are trying not to but getting rid of technical debt
  takes priority while we still have the opportunity to do so easily. Most breakage simply results in losing settings.
- We do not support Space Age and that is not coming soon.

Next, read this document.  It tells you briefly what has changed, which is a lot.

We now deploy automatic updates for everything.  To playtest:

- Get Factorio from factorio.com as the stand-alone zip version and extract it.
- Get the latest launcher from this page: https://github.com/factorio-access/factorio-access-launcher/releases
- Put launcher.exe in the root of your factorio install. Same folder with `bin`, `mods`, `config-path.cfg` etc.
- Run the launcher. It will offer to make config directories and apply config changes. Let it do so.
- If you bought space age, disable the elevated rails, space age, and quality mods in the launcher's mods menu.

## Reporting

We are coordinating on channel `playtesting-2`.  Drop your tracebacks or bugs there.  We will probably ping you on a
different channel if something needs to be a lengthy discussion.

For practical purposes Claude Sonnet 4.5 is our primary maintainer believe it or not.  Right now the process is manual,
but your messages may be seen by Anthropic in some form if you post to the channel. Other channels on our Discord are
not fed to AI at this time.  We may automate this process if we receive high enough volume.

At this time we are seeing mostly bugs and not crashes, so for the moment AI use is manual.

## Things that don't Work at all (if you test these we will ignore you because we already know, we're working down this list in no particular order)

- Combat. Play in no enemies.
- Trains.
- Decider, arithmetic, and selector combinators
- spidertrons and other vehicles are only partly functional

There's also a lot of roughness around the edges we're still spending down. Support for quality is intentionally sparse.
We are doing it where not doing so would cause tech debt, but quality is a space age feature and not priority at this
time.

## Basic Changes

Telestep is gone. SO is honking.

Fast travel has moved to alt+v so that `v` and `h` can match vanilla for item/blueprint flipping.

Entering cursor coordinates has moved to `CTRL + ALT + t` to not conflict with artillery remotes and because it is
rarely used.

The tutorial system is un-wired and pending replacement.

Instead of cursor mode, wasd now always moves the cursor.  Arrow keys always walk.  `i` now toggles whether or not the
cursor is anchored, which means whether or not it follows you.  These changes exist to let us support better remote view
and combat in the future, and also because most players stay in cursor mode.

Instant mining has been removed.  Instead, `ctrl+x` now supports most of the vanilla cut functionality.  Due to API
limitations, it does not support preservation of external circuit network connections.

Automatic pipe to ground rotation is gone permanently.  It only ever worked in limited circumstances.  If there is
demand, build lock support will be added instead.

To match vanilla, your hand always starts facing north when you put something in it. To repeat: that is not a bug, it is
2.0 vanilla behavior.

When placing tiles (concrete, landfill), we no longer have a math bug.  It is now properly placed with your cursor in
the center.

Steam engine snap assist is gone.  It is easy to do this with skip by preview instead.  We only ever offered this for
steam engines, but many other entities have fluid connections.  Learning how to do this by yourself is important for
midgame, late game, and space age.

Offshore pump build assist is on `alt + left bracket`, which is now the new "random building thing that doesn't apply
anywhere else" key.

You may temporarily notice increased scanner latency.  Due to API limitations, our mechanism from 1.1 which allowed us
to see all entities as they were placed is no longer available.  A new mechanism is being built.

Pausing is now on `shift + escape`. `escape` closes textboxes.  We may be able to fix this later.

## Build Lock

Build lock has a lot of changes and improvements.

It no longer clicks while you move.  This may come back but it turns out that late game you move too fast for it to
work.

Instead of having one build lock, you have two that work at the same time. One on wasd, and one on the arrows as you
walk.  That is, when build lock is on, both things run their own separate build lock.  To place long lines of belts:

- Use the cursor to teleport your character to the start
- Run your character along the belt with arrows

It is no longer fragile when moving quickly, and should always place electric poles `x` tiles after the last one even
when building near other poles.

It disables itself if you lose the line because you bumped into something.

Build lock also now fills in every tile even if running at an angle. If you run at an angle you'll get a "staircase" of
belts for example.  We don't recommend running at an angle, but the new algorithms should never leave gaps even in weird
circumstances; it's either doing the right thing or it's turned itself off, anything else should be considered a bug.

It's now better about not playing error sounds when it is actually working.

## New GUI

The biggest part of the 2.0 mod is an overhaul to the GUI system:

- ctrl+tab now moves between "tabstops". To get to the crafting menu ctrl+tab. Tab moves between smaller sections, for
  example all inventories.
- Inventories are dynamically exposed  
- To get to guns and ammo, press tab from your player inventory.
- Menus no longer wrap. Instead they stop at edges.
- Pressing ctrl+wasd moves to the edge of a menu or grid, exactly equivalent to pressing the key a bunch of times.
  - To remember this, `ctrl+w` is top in Factorio, `ctrl+home` is top outside Factorio.
- Search is now universal in all menus, respects localisation, and searches all label text.
- GUIs can be nested. When this happens, `E` closes all GUIs `alt+E` goes back one level.
- Many things you would expect to support "resetting" support being reset with backspace.  E.g. fluid flushing, clearing
  a logistic condition's max.
- Use ctrl+backspace for "dangerous" deletes such as fast travel points and planners.
- Menus now support horizontal rows "row of 3 items", which is used for a variety of purposes to avoid for example
  having 3 menu items for every circuit condition. Move through a row with `a` and `d`.
- Inventory bars have moved to `-` and `=` with modifiers: ctrl for all or none, shift for moving by 5.
- In crafting, craft all has moved to `ctrl + shift + left bracket`.
- The only way to do research is through the research queue. `left bracket` to add to the front, `ctrl + left bracket`
  to add to the back.

This necessitated a number of compromises.  Most notably `e` no longer opens the vanilla character GUI. That has been
moved to `ctrl+alt+shift+e`.  You shouldn't need it unless playing with someone sighted.  We also no longer make any
attempt to respect escape save for textboxes.

GUIs do not sync to their graphical counterparts at all at the current time. This will be revisited after the initial
2.0 release, or possibly never depending on demand and availability of sighted contributors.

## Circuit Network and Power

We now hide neighbors for electric poles behind `n`.  Press `n` on an electric pole to hear specific neighbors.
Otherwise, you will just get "connects to 2".  If you haven't been keeping up, scanning is now fast enough that you can
just re-scan instead of re-sorting a current scan (that has been true for a long time).

Circuit network neighbors are hidden behind the same mechanism.

Circuit network GUIs are now exposed. `ctrl+tab` once or twice depending on the entity to reach the circuit network
tabstop, then tab through it.  You may use this to see all signals broken down by quality, for red green or both.  You
can now configure most entities.

Note that the circuit network tab does not always show up due to API oddities. It is guaranteed to be present if the
entity is in a circuit network.

Constant combinators fully support the 2.0 model in which they are sending the contents of logistic sections. See below.
It's the same UI as for the logistic network.

All signal types are supported, chosen through a multi-level tree selector. You can in fact configure an assembler
through the circuit network if you want.

An experimental circuit network navigator GUI is available via `ctrl + n`.  It exposes the structure of the graph.  As
you click items, your cursor moves to them and the menu updates to be from that items perspective. It does not yet
support combinators which connect to multiple networks.

Constant versus signal for the second parameter of circuit conditions are now controlled via an accelerators mechanism:
hit ctrl+alt+s to select a signal, ctrl+alt+c for constant.

It is now possible to remove all wires from an entity with `alt + n`.  The first press removes red and green wires if
any, and the second removes copper wires if any.

## Logistics 2.0

Logistics in 2.0 have changed significantly from the sighted perspective as well as from ours. If you are a player
exploring this document, read the [Factorio Wiki page](https://wiki.factorio.com/Logistic_network) to learn about the
mechanics. This explains what we support.

To get to the logistics GUI for an entity, press `ctrl + alt + l`.  To get to your own logistics, "personal logistics",
press `ctrl + alt + shift + l`. Constant combinators are a special case because their logistic sections are for the
circuit network, and you can get to it via a normal click.

It is arranged like this:

- the first tab is an overview of that item with several rows to configure it.
- To get your first section, use the horizontal controls on the sections row.
- Ctrl+tab moves you to sections, one control for each. Tab between sections.

You can find the controls to add a group to a section at the bottom of the section.  That is, make an empty section then
set a group to it.  You can have multiple empty sections on one entity and you can have multiple grouped sections on one
entity.

We do not support editing groups independent of their entity and we do not yet support deletion. To make a new group,
use ctrl+alt+t to type it while on the group control, or find it in the groups menu.  To work around the lack of
editing, temporarily or permanently place a section in the group, change that section, then remove it.

Requests are no longer bound to items in your hand.  Instead, you choose them from the item chooser tree on addition.
You also now directly type numbers rather than adjusting by stack size.

An overview of all logistic requests is available on the summary tab, accounting for all sections. Note that enabling
trash unrequested forces maxes of infinity to be the same as their min, and due to API limitations it will be reported
to you this way.

Ex: "Wooden chest, 1 to infinity" with trash unrequested enabled shows up as "Wooden chest, min 1, max 1". That's not
wrong, it will actually move out the second chest if you had 2.  your requests wil still have infinity in the sections.

`backspace` clears min (to 0) or max (to infinity). To delete, use the rightmost item in the row.

This interface is the same for constant combinators which also can be in logistic groups; to that end the constant
combinators do let you edit the max even though they don't use them. As above though you get to constant combinators
with a normal click because they are circuit network, not logistics.  They just happen to share controls.

Constant combinator logistic sections also allow setting non-item values.

We support section config on roboports in the same fashion. Note that roboport sections only allow robots and use
different logistic groups.  If you have a group "foo" on roboports, it will not show up for requester chests, and a
group "foo" on requester chests is different than a group "foo" on a roboport.

## Belts, Fluids, and heat

The GUI here is completely familiar, but there are a number of notable changes.

For belts, information is now provided on:

- Things ahead or behind of your belt segment
- Where turns come from, not just that there is one

The belt analyzer now matches vanilla  behavior for the most part. Your belt analysis no longer includes everything it
can possibly find, but only what is on the current belt.  Among other things, this prevents it from falsely reporting
that your belt is mixed when it is not.  It is also significantly faster.

The current belt tab of the belt analyzer no longer rotates. The "top" is always the outgoing direction, and it is
always 4 rows by 2 columns.

You can configure belt read modes in the circuit network tab, including the new 2.0 read whole belt mode.

Belt announcement is now somewhat more verbose. Depending on feedback and available time, we hope to make it less chatty
in the near future.

Pipe announcement has been completely reworked to be based off shapes. For example, "connects north and south and east
and west" is now "cross".  Build various pipe shapes to see how they are now announced.

We are now briefer about bidirectional pipe connections.
