## Keys

### For The VirtualTrain

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

### For the Schedule Editor

Set the first parameter of a schedule condition to a signal or item: m

Set the first parameter of a schedule condition to a typed value (number or station name): shift + m

Set the second parameter of a schedule condition to an item or signal: dot

Set the second parameter of a schedule condition to a typed value: shift + dot

Toggle the comparison operator for a schedule condition when applicable: ciomma and shift + comma

Delete a schedule condition: backspace on the condition

Delete a schedule stop: backspace on the stop

Add a new condition separated by or: slash, either on a condition or the initial "no conditions" item of a stop.

Add a new condition, separated by and: control + slash

Toggle the logical operator joining this condition to the previous one: n

Toggle the condition type: j

## Explanation

IMPORTANT: See https://wiki.factorio.com/Railway if you don't know how rails work. This is documentation of mod
functionality, not of vanilla behavior.

### Warnings and Limitations

This is a prototype of the final trains code and the documentation you are reading is for playtesters.

The point is finding out if we like it, not finding all the bugs. Many are already known to me.

It is my belief that fixing the remaining bugs will not break your save, but we are not ready to make that promise.  My
promise right now is: if this does break your save, we can fix it but your save may have to remove all rail and train
entities.

The biggest weirdness is that we don't yet go through the building APIs so your tracks are free to place, and let's just
say that if you place over trees your train is going to be a bulldozer whenever it goes through there rather than
erroring that you can't build.  Technically tracks don't collide with trees, and we aren't invoking that logic, so you
can very much have a track with a tree on it.

Note (at least) the following:

- Tracks are free to place
- Not super tested.
- Tracks will place over water right now
- Bad verbalization around signal states and train states Primarily that they're silent unless explicitly checked.
- You type stop names directly, no list.
- No rail builder menu; if you want forks you need to use the virtual train (the point of the virtual train is that you
  can do it without, but it will come back)
- No syntrax, yet.
- No "automatic driving"/setting the active schedule record. Right now do that by removing all records, adding a record
  with wait condition passenger present or passenger not present depending on if you are in the train, and then
  rebuilding it.  This is one of the higher priorities to fix.
- "robots idle" is an exposed schedule condition which is always present but this is only used by mods that add
  equipment grids to trains.
- We don't exactly require that you remove trees and rocks
- No path warnings are gone. They have to come back in a new form, so that is tbd.
- There will be shifts in the UI and schedule editor (especially tab and element orders)
- No interrupts or wildcard interrupts yet.
- No train station previews (1.1's version of this was also sort of breaky, not sure what we're doing yet)
- Definitely lots of others.

## Overview of Track Reporting

Factorio's train system consists of 3 track shapes: straight (can be oriented 16 ways), and two kinds of curves (a and
b, hidden behind the mod).  Most of this is hidden from you.  You can place straight rails in the 8 primary directions,
but must continue building using the virtual train or syntrax, described below.

Sometimes, you will observe more than one track on a tile.  This can happen in two ways:

- If using shift + f to cycle, in which case the track may be spurious because some track pieces share tiles to connect
- When moving, in which case you are on some form of crossing where two tracks overlap.

We simplify each tile into a layout description.

You may find:

- Vertical or horizontal rails
- Diagonal rails facing northeast or southeast
- Half-diagonal rails facing in any of the secondary eastern directions, for example east northeast
- Various kinds of curves
- Various kinds of forks:
  - Fork: 3-way in a given direction
  - fork left/right of dir: fork continuing in direction dir, and also turning left/right
  - split: The track does not continue straight. It splits into left/right instead. This can also be thought of as a y.

The straight rails only ever face half of the compass because they are bidirectional. A horizontal east is also a
horizontal west.

The mod helps out with curves by abstracting where possible.  It will announce either a direction and a "left/right"
specifier, or it will announce "x and y turn" if it understands that this is part of a 90-degree turn between cardinal
directions (for example north and east).

Some examples:

- Right of southeast: curve going southeast to south southeast
- left of north: curve going from north to north northwest
- East and south turn bottom: the southernmost part of a east/south 90 degreee turn

NOTE: in Factorio 2.0 a 90 degree curve is 4 turns as the shallowest corners  are now only 22.5 degrees.

As you build more of a larger shape, the mod will recognize more of that larger shape and report it to you.  For
example, until the 4th place of a 90 degree turn is placed, it will describe the three smaller curves separately.  You
can use this to help guide you as to whether or not you have built what you wanted.

For 90 degree turns off the cardinals we use the interesting fact that all turns have a "height" and assign the 4
segments a bottom/lower half/upper half/top designation, going from southmost to northmost on the map.

We recommend building a circle (m or dot 16 times from a straight rail's end) then going around the circle to see how it
reports the 90 degree turns.

Unlike 1.1, there is no requirement that straight pieces be present anywhere.  You can now do circles with only curved
pieces.  You can do long straight paths with s-bends going back and forth like a snake.  I don't suggest either for a
variety of reasons but you can, so can the sighted, and it's your game.

## Basic Rail Building: The Virtual Train

The sighted user of Factorio does not place most rails directly, and instead uses a rail planner, which lets them draw
the path they want.  You also do not place most rails directly, and use the virtual train, which lets you draw the path
you want.  The primary difference is that you have to work out the path and the sighted do not, but the cause of the
sighted style approach is that their paths are not "clean" and will curve whenever and however they feel like when the
game decides it's best to go around the lake or zigzag through the cliffs or whatever.  The mod instead opts for control
and precision; even in vanilla advanced players eventually use grid-aligned blueprints and things instead of the rail
planner, so it's not a huge loss.

To lay tracks, you use m, comma, dot, and slash as well as a few other keys.  To get started, put a rail in your hand
and build a straight rail.  Then, with the rail still in your hand, click the rail.  This connects the virtual train to
it. To turn it off, empty your hand.  To be clear, your character does not move during this process or anything like
that.

The virtual train builds tracks as you drive it.  You turn it left with m, move it forward with comma, and turn it right
with dot.  For example, a 90 degree left turn is pressing m 4 times.

You will notice that the keys are a group of 3.  To remember the controls, the train is comma and you're turning left
with m because m is left of the train.

Sometimes, you need to turn around.  To do so, you use alt + comma.  This does not turn the train 180 degrees, however.
All rail building must happen from a rail end, so you are instead grabbing the other end of the just placed rail.  For
example, a north to north northwest curve's ends are south and north northwest.

It is necessary to place signals and it is necessary sometimes to place signals at the exact position relative to a
rail's end so that you have an extra tile of space.  Adding ctrl to m or dot places a signal on that side of the track.
Using shift instead places a chain signal.  Explaining the rules of Factorio signals are beyond this document, but if
you are following them, ctrl/shift + dot is always "going this way" and ctrl/shift + comma is "going against the flow".

The virtual train moves over but does not replace perfectly matching tracks.  For example, if you build the exact same
structure from the exact same starting point twice, the second time succeeds but doesn't place anything.  This solves a
problem from the 1.1 version of the mod: you no longer need to mine up pieces to build track merges.

Building tracks can be tricky, so the virtual train offers a few more functions.

First, you can temporarily disable building by entering speculation mode.  To do so,press slash.  In this mode, the
train moves as if it would build, but doesn't place anything.  When you exit speculation, you are returned to the
position and direction you entered it from.  This lets you see what is at the target positions of rails, or for example
check whether or not an s-bend would merge tracks properly.

If you make a mistake, you can press backspace.  This undoes one move, and removes anything that move built including
signals.  It leaves other rails on the same tile alone.

Finally, the virtual train changes the meaning of bookmarks and uses the bookmark keys.  It maintains a historical list
of states.  When you set a bookmark, you are pushing a bookmark to the list of bookmarks for this speculation, which
saves the history, direction, and position of the virtual train.  When you then press b, you move to and clear the last
bookmark.  Programmers know this as a stack; shift+b pushes, b pops.

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
- Add some signals: press shift dot (chain in) and control m (regular out)

Bookmarks may seem awkward, but the use is for more complex layouts.  For example, this representation lets you build
forks on the ends of other forks, or even type 4-way intersections (hint: each fork is part of another fork, and you can
put a bookmark at each fork as you type it).  If you don't follow the idea of a bookmark stack, I advise not using
bookmarks at all here; anything that can be accomplished without the stack part can be accomplished fine by just not
bothering.

## Schedules and Stations

There is a station UI. It works like any other UI and lets you set things like any other UI, and doesn't deserve more
documentation.

Teaching how train schedules work is beyond the scope of mod documentation.  See the wiki for that.

This covers the schedule editor.  It's over one tab from the inventories of a locomotive attached to a train (no more
"it must be at a station").  The schedule editor now exposes all 1.1 functionality.  2.0 interrupts are not yet
implemented.

The controls are at the top of this document, but they borrow the controls of the decider combinator. M is parameter 1,
comma is the operator, and dot is parameter two.  What these are changes based on the schedule condition type, toggled
with j.  For example, "wait" only has one parameter and it is always a constant integer, so you set it with shift + m.
Rather than shifting whether or not m and dot open text boxes, we instead require you to add shift if the parameter can
only be set from a text box.  In future that will basically just be numbers, but for today we do require you to enter
stop names manually--there is no stop selector yet.

Just like with the decider n controls how the condition joins with the previous (and/or) and slash adds a new one and
moves you to it (combined using or, add ctrl for and).  The key that we add to this is j, to toggle through the
condition types (wait, passenger present, cargo has a specific thing, etc).

The game does not care if stops are present when you add them to a schedule, so we will always support typing stop
names.  Indeed, for some 2.0 functionality typing the stop name is mandatory even for the sighted.  For now, for
simplicity and to get off the ground, you must type your stop names yourself.

Like with the decider combinator, the idea is that you view these controls like reading text or similar (j doesn't fit
the analogy, but it needed one more key and b is too important).  If we put braille on your keyboard with one "field"
per key, it would "fit" on n m comma dot, and then slash adds to the "end" of the row as a whole.
