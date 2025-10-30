# circuit Network

## Keys

Get a red, green, or copper wire: `alt + r`, `alt + g`, or `alt + c` respectively

Start dragging with a wire in hand: `left bracket`

Drag to an entity: `left bracket`

Drag to the left side of a power switch or input of a combinator: `m`

Drag to the right side of a power switch or output of a combinator: `dot` (`.`)

Stop connecting: `q` once

Empty hand: `q` twice

See below for an understanding of the weird hand keys.

Open the alpha circuit navigator: `ctrl + n`

Disconnect all red/green wires: `alt + n`, on an entity with red and/or green connections

Disconnect all copper wires: `alt + n`, on an entity with only copper wires

### Decider Keys

See the description for more info.

When on a condition, set the first signal: `m`

When on a condition, toggle which networks the first signal reads from: `ctrl + m`

When on a condition, change the operator: `comma`, `shift comma` to go back

When on a condition, set the second operand to a signal: `dot`

When on a condition, toggle the networks of the second operand: `ctrl dot`

When on a condition, set the second operand to a constant: `shift dot`

When on a condition, change the logical operator to the previous condition: `n`

When on a condition, add a new condition to the end separated from previous conditions by and: `/` (slash)

When on a condition, add a new condition to the end separated from previous conditions by or: `ctrl /`

When on a condition, remove it: backspace

When on an output, set the output's signal: `m`

When on an output, set the output to copy from input networks: `ctrl m` (repeated presses cycle)

When on an output, set the output to output a constant: `dot`

When on an output, add a new output: `/`

When on an output, remove the output: backspace

## Description

We support all base game features of the circuit network. We do not fully support quality.

Teaching the circuit network is well beyond the scope of our documentation.  If you are new to the game, circuit network stuff is probably not for you.  Stop here and go play instead.

99% of the circuit network is configured through standard UIs which show up when you connect something to the circuit network and click it.  These show up as a tab with a number of subtabs for configuration and circuit signal analysis.  We support quality here as well.  You can explore the qualities of signals by moving left and right in the menus of the appropriate tabs.

### Connecting/dragging  Wires

For a variety of reasons we are limited in what we can change when it comes to dragging, so a brief explanation follows.

When you put a wire in your hand, it starts off like a loose coil.  Neither end is connected to anything yet.  If you press `q` at this point then your hand will empty as normal.

After the first click, the wire is connected to at least one entity.  If you continue to click other entities it chains from entity to entity. So to connect 3 things, a b and c, you would just click a, click b, and click c.  After the first click, the first press of `q` resets the wire so that you are starting a new chain rather than emptying your hand.  There would be a wire from a to b and a wire from b to c, but not from c to a.

If this is confusing then we suggest emptying your hand, putting a wire in it, clicking everything you want to connect, then emptying your hand before continuing so that you start with a fresh state.

To remove a wire between two entities specifically, you have to "connect" them again. So if you have a and b, the first a to b connects and the second a to b disconnects.

You can drop all wires on something with `alt + n`.  This is like vanilla shift + click: first time drops circuit network, second time drops copper if applicable.

Some advanced combinators as well as power switches connect to multiple networks at once, either via a left/right side (power switches) or input/output sides (combinators).  `m` and `dot` drag to the left/input and right/output respectively.  The mod will remind you of this if you attempt to click an entity with multiple connection points.

### Decider Combinator

Firstly, if you don't know what this is consider if you want to learn something really complicated.  If you do, start at the [Factorio Wiki page](https://wiki.factorio.com/Decider_combinator) to learn what it does. The below just describes how to use it.

We present deciders as a menu of 4 items.  The first item is a summary of what it will do. The second is to set the description.  The third and fourth edit conditions and outputs respectively.

You can find the anything/everything/each signals in the signal selector under virtual signals -> signals -> virtual-signal-special, which is straight down from virtual signals at the top level.

The way to conceptualize the very complicated controls is this.  If you look at the QWERTY layout, n, m, comma, dot, and slash form a "row".  The operator is on comma.  The operands are on m and dot.  How it connects to the previous condition is on n, and how it will connect to the next condition if you add one is on slash.

Say it to yourself: n, m, comma, dot, slash.  Or, wooden chest, less, 5, next condition.

The issue we have is that a decider can have as many conditions as you want and as many outputs as you want.  If we did these as separate controls, then it'd be way too much--10 each!

Adding control always cycles through the circuit networks to read from.  So ctrl m and ctrl dot are cycle first param and cycle second param respectively.

On outputs, dot is enter constant, because the only thing you can do with the second operand on an output is set it to a constant. Cycling the first signal puts it back to copy from input, instead.

Backspace deletes.  There's no "empty condition" as such.  The UI will sometimes show "empty" but that's because initial deciders placed by the game are apparently allowed to have partially defined inputs and outputs, and so are new conditions.  So what empty really means is you haven't set this up yet, please fill it in.

The precedence in Factorio is (a and b and c) or (d and e and f), like in most programming languages.  In most cases what you want is and.  Pressing slash adds a condition to the end of the row of conditions separated by and, and automatically moves your UI focus to it.  For or, you can add ctrl.

As a result, if you start from empty conditions and know exactly what you want, you may type it without having to arrow around by just hitting the keys in sequence.

Similar logic applies to outputs, but there is no ctrl slash there since outputs don't have logical operators.

slash will add the first output or condition if needed, should it be the case that there are none.

Finally, it's worth mentioning "both".  When you set something to "both" in the combinator, we don't bother saying both. Both is implied and the default, because it is the common case. If you hear a color that means it comes from only that color, otherwise it's coming from both.

### The Alpha Circuit Navigator
This is of limited use and may not be extended.

If you press `ctrl + n` on a circuit network connected entity then you will get a menu from which you may explore neighbors.  First, you select a network.  Then, you can see everything connected to it.

If you click an entity in the list, the menu resorts itself so that entity is at the top and so that all of the distances are relative to that entity, as if you had started there. So, you can click around quickly with it.

For the time being it ignores arithmetic, selector, and decider combinators.
