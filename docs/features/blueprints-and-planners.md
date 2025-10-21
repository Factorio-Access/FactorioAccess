# Blueprint and Planner support

## Keys

These use all the normal keys, with only a few changes:

Start selecting a blueprint, upgrade, or deconstruction planner's area: `left bracket`

Finish selecting: `left bracket` on a second point

Cancel upgrade or deconstruction: replace the second click with `alt + left bracket`

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

Due to API limitations, blueprints always take an inventory slot.  We cannot get access to the blueprint library, which is how sighted players work around this.  See the next section.

### Blueprint Books

A blueprint book is a bunch of blueprints grouped together.  Like blueprints API limitations means that it takes an inventory slot, but only one no matter how many blueprints are in it.

In terms of building, blueprint books work almost identically to blueprints.  The difference is that a blueprint book has a concept of active blueprint.  There are two ways to change the active blueprint:

- Hit `right bracket` and select the one you want, or
- Use `m` and `dot` to cycle to the one you want without opening a GUI

Blueprint books also have blueprint book level config. To get to it press `tab` as with other UIs.

To get a blueprint into a book, put the blueprint in your hand and the book in your inventory. Find the book and hit `ctrl + shift + left bracket`.  We will hopefully be adding more convenient ways to do this in future.

### Planners

The upgrade and deconstruction planners are pending better support.  For now, you can mark everything in an area for deconstruction or upgrade.  To do so, get the planner, then click the corners of the box.

You can "undo" or "cancel" by getting the same kind of planner in the hand, reselecting the same box, but replacing the second click with `alt + left bracket`.

Better support for these is coming in the near future.
