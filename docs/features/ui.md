# UIs: the mod's windows and menus

## Keys

### For interacting

Get help: shift + slash (/)

Move in a UI: `wasd`

Move as far as possible in a given direction: `ctrl + WASD`

Drag items in the rare menu that supports it: `shift + wasd`

Read information for a slot or control: `k` (e.g. recipe ingredients, kind of equipment, building dimensions, etc)


Read alt information for a control: `y` (rarely used, most notably in the crafting menus where it tells you what the products of a recipe do).

Activate an item: `left bracket`

Type a secondary value (rarely used): `m`

In an inventory, fast transfer to a related inventory: `shift + left bracket` for whole, replace with `right bracket` for half

In an inventory, set a filter on this slot: `alt + left bracket`

In an inventory, clear a slot's filter: `alt + right bracket`

In an inventory, adjust number of unlocked slots: `-` and `=`, add `shift` for 5, add `ctrl` to move to 0 or max.

In the crafting menu, craft 5: `shift + left bracket`

Craft all: `ctrl + shift + left bracket`

In the research menu, enqueue to the back of the research queue: `left bracket`

In the research menu, enqueue to the front of the research queue: `ctrl + shift + left bracket`

In inventories, use an item in the given slot: `ctrl + shift + left bracket`

In inventories, send slot to trash: `o`

Move between subtabs: `tab`, add `shift` to go backward

Move between tabs: `ctrl + tab`, add `shift` for back

Set search: `ctrl + f`

Next search item: `shift + enter`

Previous search item: `ctrl + enter`

In queues: cancel one: `left bracket`

In queues, cancel 5: `shift + left bracket`

In queues, cancel all: `ctrl + shift + left bracket`

Cancel a textbox: `escape`

Pause the game: `shift + escape`

Close the active UI: `e` with a UI open

Announce the active UI: `shift + e`

Go back one level: `alt + e`

Safe clear: `backspace` (e.g. flush fluid, reset some values to 0)

Dangerous delete: `ctrl + backspace` (e.g. destroy planners)

### Opening

Access the character UI: `e` with nothing open

Access the world menu: `alt w`

Access your logistics GUI: `ctrl + alt + shift + l`

Access the logistics GUI of the selected entity: `ctrl + alt + l`

Access the normal configuration GUIs of an entity: `left bracket`

For items supporting it, access the item's UI: `right bracket` with the item in hand

Open the warnings and alerts UI: `p`

Access the beta circuit navigator: `ctrl + n` on an entity connected to a network


## Description

The mod offers a rich UI system composed of a number of standard widgets, organized in standard fashions.  This discusses what you can expect.

Before we get started, some important rules:

- When the UI is open, what is in your hand no longer matters. You will be operating on whatever is selected instead. So for example ctrl + backspace can delete a planner from the inventory, even if your hand is empty
- Search works in literally every last menu even if you don't think it would
- UIs may close unexpectedly if the entity they are for goes away or your hand changes, because often they require that entity or item to function
- When manipulating things like equipment, you are (un)equipping the currently open entity.  This is different from 1.1.
  - Note: for now you need to drop equipment into an inventory and equip it from there. We will have proper equipment grids soon rather than the old 1.1 functions.


Most entities have UIs.  The fastest way to find out what you can do is to click things and explore!

### Tabs and subtabs

if you were to open your character/main UI and explore it as a flat list of tabs, you'd discover that it is 10+ items long!  For this reason, the mod has introduced the concept of tabs and subtabs (note to contributors: for historical reasons, this is not what they are called in the code).

A tab is something like "all inventories", "everything to do with crafting".

A subtab is a grid or a menu, etc.

You move between tabs with ctrl + tab (shift to go back) and subtabs with tab (shift to go back).  So, just like your desktop UI.  What is different is that there is no concept of controls.  instead, all subtabs use WASD for navigation and are usually some form of menu.

Not all tabs are always present. For example personal logistic trash does not show up until it is unlocked, and circuit network related tabs are only guaranteed to be present on entities connected to the circuit network (the latter is weird because of the API, parts of which only work once the item is in a network).  In some cases, UIs can change while you operate them.  For example, setting recipes sometimes changes the number of inventories an entity has.

### Standard Widgets: the Menu or Form

Used to configure things, set up the circuit network, etc., menus are standard vertical menus with occasional horizontal rows.  Rows are announced as "row of 4 items" and navigated with A and D.  To select an item click it with `left bracket`.  In rare circumstances, type a value instead with `m`.

Examples of simple menus include blueprint configuration and fast travel.  Examples of very complicated menus include the logistic section editor, which uses one row per request, and circuit network configurations, which use horizontal controls for configuring conditions.


### Standard Widgets: inventory grids

Inventory grids are things like your inventory, chests, etc. and support a variety of interactions.  In the game, inventories are not grids, but we modify it for convenience, and assume that it's always 10 columns wide.  if an inventory is not a multiple of 10, there will be some unused slots at the bottom.

The first thing to know is how to perform item specific actions: use `ctrl + shift + left bracket`.  A list follows:

- With a blueprint and on a blueprint book, add it to the book
- With a repair pack on something damaged, equip it
- On an entity with equipment selected, equip it

The second most important feature of inventories is fast transfers.  If you open an entity which is not yourself and are not in remote view, then it is possible to move things back and forth from your own inventory quickly with shift + brackets. Left moves entire stacks and right moves half stacks.  To mvoe from the item to yourself, do this on the item' s inventories.  Your inventory is always added for convenience as the last tab.  SO to move in the other direction, from yourself to the entity, go there and use the same keys.

In inventories, `k` announces information about an item if known.

### Category Rows

The category rows control shows up only in a few places, but they are important: the warnings menu, crafting, and research.  It consists of a number of stacked rows of different lengths.  Each row has some items in it.

As a concrete example, the crafting menu breaks recipes down by category, the research menu breaks research down by whether it's done, researchable, or locked, and the warnings menu makes the warning type the categories.

You switch category with `w`/`s` and move in the category with `a`/`d`.

It does still support all other operations, e.g. `ctrl + a` moves to start of category, search works, etc.

### Item Selectors

For advanced features such as the circuit network and logistics, the mod exposes the item selector.

An item selector is used when you must select an item, recipe, signal, etc. from a huge list.  It is a tree-type control with some number of rows.

You move through the current level with `a`/`d`, move to children with `s`, and move to parents with `w`.  Only the bottom-most row is selectable.

An example makes this clearer.  Suppose I wanted to select transport belt.  I would:

- Use `a`/`d` to find item, then `s` to go down
- Use `a`/`d` to find logistics, then `s` to go down
- Use `a`/`d` to find transport belt, then `left bracket` to click

The item selectors do support search just like everything else, but only on the selectable nodes.  So your search could find "logistic robot", but not "logistics" if you searched for "log".
