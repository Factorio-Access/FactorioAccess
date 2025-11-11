## Keys

Lock onto a track and start driving the virtual train: left bracket on a  rail with a rail in hand


Move the virtual train forward: comma

Move the virtual train left: m

Move the virtual train right: dot

Flip the virtual train to the other end of this rail: alt + comma

Place a signal to the left or right: control + m or dot

Place a chain signal to the left or right: shift + m or dot

Toggle speculation: slash

Push a bookmark to the bookmark stack: shift + b

Pop a bookmark from the bookmark stack: b

Undo the most recent move, deleting a rail if you placed one: backspace



## Explanation

### Warning: here there be prototyping

This is a prototype of the final trains code and the documentation you are reading is for playtesters.

In particular there are a ton of limitations and also tracks are free to place.

## Overview of Track Reporting

Factorio's train system consists of 3 track shapes: straight (can be oriented 16 ways), and two kinds of curves (a and
b, hidden behind the mod).  Most of this is hidden from you.  You can place straight rails in the 8 primary directions, but must continue building using the virtual train or syntrax, described below.

Sometimes, you will observe more than one track on a tile.  This can happen in two ways:

- If using shift + f to cycle, in which case the track may be spurious because some track pieces share tiles to connect
- When moving, in which case you are on some form of crossing where two tracks overlap.

We simplify each tile into a layout description.  NOTE: forks are described but not listed in this doc because they're WIP, I'm making it better.

You may find:

- Vertical or horizontal rails
- Diagonal rails facing northeast or southeast
- Half-diagonal rails facing in any of the secondary eastern directions, for example east northeast
- Various kinds of curves

The straight rails only ever face half of the compass because they are bidirectional. A horizontal east is also a horizontal west.

The mod helps out with curves by abstracting where possible.  It will announce either a direction and a "left/right" specifier, or it will announce "x and y turn".

Some examples:

- Right of southeast: curve going southeast to south southeast
- left of north: curve going from north to north northwest
- East and south turn bottom: the southernmost part of a east/south 90 degreee turn

NOTE: in Factorio 2.0 a 90 degree curve is 4 turns as the shallowest corners  are now only 22.5 degrees.

As you build more of a larger shape, the mod will recognize more of that larger shape and report it to you.  For example, until the 4th place of a 90 degree turn is placed, it will describe the three smaller curves separately.

For 90 degree turns off the cardinals we use the interesting fact that all turns have a "height" and assign the 4 segments a bottom/lower half/upper half/top designation, going from southmost to northmost on the map.


## Basic Rail Building: The Virtual Train

The sighted user of Factorio does not place most rails directly, and instead uses a rail planner, which lets them draw
the path they want.  You also do not place most rails directly, and use the virtual train, which lets you draw the path
you want.


To lay tracks, you use m, comma, dot, and slash as well as a few other keys.  To get started, put a rail in your hand and build a straight rail.  Then, with the rail still in your hand, click the rail.  This connects the virtual train to it.
To get out, empty your hand.

The virtual train builds tracks as you drive it.  You turn it left with m, move it forward with comma, and turn it right with dot.  For example, a 90 degree left turn is pressing m 4 times.

Sometimes, you need to turn around.  To do so, you use alt + comma.  This does not turn the train 180 degrees, however.  All rail building must happen from a rail end, so you are instead grabbing the other end of the just placed rail.  For example, a north to north northwest curve's ends are south and north northwest.

It is necessary to place signals and it is necessary sometimes to place signals at the exact position relative to a
rail's end so that you have an extra tile of space.  Adding ctrl to m or dot places a signal on that side of the track.
Using shift instead places a chain signal  Explaining the rules of Factorio signals are beyond this document, but if you
are following them, ctrl/shift + dot is always "going this way" and ctrl/shift + comma is "going against the flow".

The virtual train moves over but does not replace perfectly matching tracks.  For example, if you build the exact same
structure from the exact same starting point twice, the second time succeeds but doesn't place anything.  This solves a
problem from the 1.1 version of the mod: you no longer need to mine up pieces to build track merges.

Building tracks can be tricky, so the virtual train offers a few more functions.

First, you can temporarily disable building by entering speculation mode.  To do so,press slash.  In this mode, the train moves as if it would build, but doesn't place anything.  When you exit speculation, you are returned to the position and direction you entered it from.  This lets you see what is at the target positions of rails, or for example check whether or not an s-bend would merge tracks properly.

If you make a mistake, you can press backspace.  This undoes one move, and removes anything that move built including signals.  It leaves other rails on the same tile alone.

Finally, the virtual train changes the meaning of bookmarks and uses the bookmark keys.  It maintains a historical list of states.  When you set a bookmark, you are pushing a bookmark to the list of bookmarks for this speculation, which saves the history, direction, and position of the virtual train.  When you then press b, you move to and clear the last bookmark.

A concrete example may help. Here is how you build a 3-way fork:

- Place a rail facing north
- Lock onto the rail
- Press shift + b
- Press m 4 times
- Press b, which returns and clears the bookmark
- Press shift + b again
- Press dot 4 times
- Press b, to return and clear the bookmark
- Press shift + b again
- Press comma 4 times to build the straight section
- Press b, to get back and clear the bookmark
- Add some signals: press shift dot (chain in) and control comma (regular out)

Bookmarks may seem awkward, but the use is for more complex layouts.  For example, this representation lets you build forks on the ends of other forks, or even type 4-way intersections (hint: each fork is part of another fork).
