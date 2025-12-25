# Blueprint and Planner support

## Keys

These use all the normal keys, with only a few changes:

Start selecting a blueprint, upgrade, or deconstruction planner's area: `left bracket` with a 1x1 cursor

Directly apply a deconstruction or upgrade planner to what is under your cursor: `[` with a larger cursor


Finish selecting: `left bracket` on a second point

Finish selecting for a blueprint, but go to the advanced configuration menu instead of creating it: `right bracket`.

Cancel upgrade or deconstruction: replace the second click with `shift + left bracket`

Open the menu for the item: `right bracket` with the item in hand

Cycle through blueprints in a blueprint book without opening the GUI: `m` and `dot (.)`

Announce the currently active blueprint in a book: `comma (,)`

Get a blueprint: `alt + b`

Get an upgrade planner: `alt + u`

Get a deconstruction planner: `alt + d`

Get a new blueprint book: `ctrl + alt + shift + b`

Copy: `ctrl + c`

Cut: `ctrl + x`

Paste: `ctrl + v`

Destroy a planner item with the GUI closed (important! With the gui closed): `ctrl + backspace` with the item in hand

## Description

WARNING WARNING WARNING: blueprints and blueprint books are per save. We have no ability to access the blueprint library, which is the sighted version that is not per save.  To keep your blueprints, you need to export them and reimport them into future saves!  If you delete your save or otherwise lose it, they are gone forever.

### Blueprints and Copy/Paste

Blueprints are a mechanism to save a group of entities and put it somewhere else later.  There are a few ways to get one:

- `alt + b` gives you a blank blueprint. Click twice to select the corners of a box.
- `ctrl + c` gives you the copy tool. This is like a blank blueprint, but the resulting blueprint is temporary and goes away when you empty your hand.
- `ctrl + x` gives you the cut tool, which is exactly like the copy tool but marks the area selected for deconstruction as well. This is useful to move a bunch of entities by a few tiles, for example.
- `ctrl + v` gives you a temporary blueprint, whatever you copied or cut last.

To stop selecting if you change your mind, hit `e`.  Blueprint selection is a kind of UI, and so `e` closes it.

Blueprints have names, import/export functionality, descriptions, etc. This is all accessed by pressing `right bracket` with a blueprint in hand.

To build a blueprint, click with `left bracket`.  Rotation, flipping, etc. all work the same as buildings, and you are building from the top left, same as buildings.

For advanced users, Factorio allows controlling what a blueprint will contain. For example it is possible to blueprint
only tiles, even if entities are over them.  This must be done at blueprint setup time both for blind and sighted users.
To do so, end your selection with `right bracket`.  This will open the blueprint creation menu, which has checkboxes for
these options.

Due to API limitations, blueprints always take an inventory slot.  We cannot get access to the blueprint library, which is how sighted players work around this.  See the next section.

### Blueprint Books

A blueprint book is a bunch of blueprints grouped together.  Like blueprints API limitations means that it takes an inventory slot, but only one no matter how many blueprints are in it.

In terms of building, blueprint books work almost identically to blueprints.  The difference is that a blueprint book has a concept of active blueprint.  There are two ways to change the active blueprint:

- Hit `right bracket` and select the one you want, or
- Use `m` and `dot` to cycle to the one you want without opening a GUI

Blueprint books also have blueprint book level config. To get to it press `tab` as with other UIs.

To get a blueprint into a book, use the labeled row in the blueprint book's config tab to pull them from your inventory.

We do not support all blueprint books.  We only support those consisting of blueprints.  Some sighted blueprint books
contain blueprints in folders, and for a variety of reasons we cannot read those accurately, nor do we guarantee we
won't crash on it.  This is an unfortunate limitation of the API which is too big of a problem to work around given the
effort it would take.

### Planners

You can mark everything in an area for deconstruction or upgrade.  To do so, get the planner, then click the corners of the box.

If you instead click with a larger cursor, the planner will directly apply to everything under that cursor.

You can "undo" or "cancel" by getting the same kind of planner in the hand, reselecting the same box, but replacing the second click with `alt + left bracket`.

We have alpha quality support for configuring upgrade planners. When configured, the upgrade planner becomes permanent.  You can set an entity rule by clicking one of the slots, or set a module rule by pressing m on one of the slots.  We do not have the bandwidth to put significant effort into fixing bugs here, so use this at your own risk.

You can pull planners into blueprint books and use them from the book as if they were directly in your hand.
