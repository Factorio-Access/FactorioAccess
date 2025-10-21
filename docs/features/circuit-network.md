# circuit Network

## Keys

Get a red, green, or copper wire: `alt + r`, `alt + g`, or `alt + c` respectively

Start dragging with a wire in hand: `left bracket`

Stop connecting: `q` once

Empty hand: `q` twice

See below for an understanding of the weird hand keys.

Open the alpha circuit navigator: `ctrl + n`

Drop all red/green wires: `alt + n`, on an entity with red and/or green connections

Drop all copper wires: `alt + n`, on an entity with only copper wires

## Description

We support most of the circuit network, everything but decider, arithmetic, and selector combinators. Constant combinators are supported.

Teaching the circuit network is well beyond the scope of our documentation.  If you are new to the game, circuit network stuff is probably not for you.  Stop here and go play instead.

99% of the circuit network is configured through standard UIs which show up when you connect something to the circuit network and click it.  These show up as a tab with a number of subtabs for configuration and circuit signal analysis.  We support quality here as well.  You can explore the qualities of signals by moving left and right in the menus of the appropriate tabs.

### Connecting/dragging  Wires

What needs further explanation is dragging.  For a variety of reasons we are limited in what we can change here, so a brief explanation follows.

When you put a wire in your hand, it starts off like a loose coil.  Neither end is connected to anything yet.  If you press `q` at this point then your hand will empty as normal.

After the first click, the wire is connected to at least one entity.  If you continue to click other entities it chains from entity to entity. So to connect 3 things, a b and c, you would just click a, click b, and click c.  After the first click, the first press of `q` resets the wire so that you are starting a new chain rather than emptying your hand.  There would be a wire from a to b and a wire from b to c, but not from c to a.

If this is confusing then we suggest emptying your hand, putting a wire in it, clicking everything you want to connect, then emptying your hand before continuing so that you start with a fresh state.

To remove a wire between two entities specifically, you have to "connect" them again. So if you have a and b, the first a to b connects and the second a to b disconnects.

You can drop all wires on something with `alt + n`.  This is like vanilla shift + click: first time drops circuit network, second time drops copper if applicable.

### The Alpha Circuit Navigator
This is of limited use and may not be extended.

If you press `ctrl + n` on a circuit network connected entity then you will get a menu from which you may explore neighbors.  First, you select a network.  Then, you can see everything connected to it.

If you click an entity in the list, the menu resorts itself so that entity is at the top and so that all of the distances are relative to that entity, as if you had started there. So, you can click around quickly with it.

For the time being it ignores arithmetic, selector, and decider combinators.
