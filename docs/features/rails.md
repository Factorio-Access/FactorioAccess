## Keys

### For The VirtualTrain

Lock onto a track and start driving the virtual train: left bracket on a  rail with a rail in hand

Lock on in force build mode: shift + left bracket with a rail in hand

Lock on in superforce mode: control + shift + left bracket with a rail in hand

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

Set the active stop in a schedule: right bracket

## Explanation

IMPORTANT: See https://wiki.factorio.com/Railway if you don't know how rails work. This is documentation of mod
functionality, not of vanilla behavior.

### Overview of Driving

You can run trains in two modes: manual and automatic.  In automatic mode, trains follow a schedule.  This unlocks after
you research automated rail transportation.

This section mostly exists to tell you: don't try manual driving.  To do it, you use the arrow keys (west is left, etc)
but because track layouts are very complex the train is not likely to do what you think. Additionally, it is liable to
run into other trains.

A sighted player who wants to drive a train through a complicated base, and the accessible way for you to do so, is to
use the schedule editor. You add a temporary stop for the station you want, add "passenger not present" as a condition,
then hit right bracket on the stop to set it to the active stop.

What we do offer is a radar that tells you which way and how fast a train is moving. When sitting in a moving train, you
will hear a quiet tone in the direction the train is going.  Higher pitch is "more north", and pan is east/west.  So a
high leftish tone is northwest, etc.  The tone plays when the train changes orientation, or after the train has traveled
50 tiles. This at least allows you to (1) have the sighted experience of advanced players who can't really drive trains
manually anyhow, and (2) know what's going on and roughly where and how far you have gone.

### Overview of Track Reporting

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

Ghosts are supported.  The only thing to note is that tiles containing both ghosts and non-ghosts are potentially overly
verbose.  We cannot do better here in any reasonable amount of time.

### Basic Rail Building: The Virtual Train

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

Notice that the keys are a group of 3.  To remember the controls, the train is comma and you're turning left with m
because m is left of the train.

Sometimes, you need to turn around.  To do so, you use alt + comma.  This does not turn the train 180 degrees, however.
All rail building must happen from a rail end, so you are instead grabbing the other end of the just placed rail.  For
example, a north to north northwest curve's ends are south and north northwest.

It is necessary to place signals and it is necessary sometimes to place signals at the exact position relative to a
rail's end so that you have an extra tile of space.  Adding ctrl to m or dot places a signal on that side of the track.
Using shift instead places a chain signal.  Explaining the rules of Factorio signals are beyond this document, but if
you are following them, ctrl/shift + dot is always "going this way" and ctrl/shift + m is "going against the flow".

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

The rail builder supports force and superforce building.  Add shift and control shift, respectively.

As a cheaty sort of thing, the rail builder does not actually validate that you are close enough to the rails when
placing them, and allows you to place normal rails anywhere.  This is for both implementation simplicity and
playability.  The actual rules for a sighted player are complicated. In practice, this isn't as bad as it sounds.  When
you start building networks of hundreds of rails, the inability to have enough in your inventory will force the use of
blueprints or ghosts.

### Building Larger Layouts

The mod offers two closely related ways to build extremely large layouts.

The first and simplest is the rail builder menu. To access it, hit alt left bracket while locked onto a rail.  This menu
consists of a number of rows, each containing a list of structures. So, move up and down to the category you want, the
move right and click.

In this menu, "left" and "right" are relative to the rail end you are on right now.

The only two non-obvious structures should be "intersection entrance" and "intersection exit".  These are a chain signal
on the right and signal on the left for entrances, and a chain signal on the left and signal on the right for exits. The
Factorio convention for a properly functioning rail network for those who do not know what they're doing is to build
intersections by using the "intersect entrance" pair when facing into the itnersection and the "intersection exit" pair
when facing out of it.  If you play with this, you will observe that these are actually the same thing if you turn
around.

The second is Syntrax, which is what the builder menu uses to store structures.  If you are a bit of a coder or are
willing to learn a text based format, Syntrax is documented [here](./syntrax.md). The builder menu supports saving
custom Syntrax programs for later use, which can be used to get Syntrax programs from others.  Please note that these
are saved in your save and will not follow you between games.  We do not have the ability to offer global data like that
at this time. You should keep a text file around and set them up in new games as you need them.

If you prefer, you may type Syntrax directly. To do so, you hit alt right bracket.  This jumps straight into a text box:
type your Syntrax and hit enter.

You may be wondering how to learn Syntrax.  The trick is that Syntrax matches the virtual train.  If you are not a coder
and want to write down what you did, replace m with l, comma with s, and dot with r.  The full syntax is documented in
the dedicated document, but the idea is that you start here until you are comfortable with trains, then use Syntrax when
building very large structures.


### Schedules and Stations

There is a station UI. It works like any other UI and lets you set things like any other UI, and doesn't deserve more
documentation. The only special thing about it is that train station names support rich text--see below on interrupts
for why that is important.

Teaching how train schedules work is beyond the scope of mod documentation.  See the wiki for that.

The schedule editor now exposes all functionality.  To get to it, click a locomotive and find the schedule editor on the
second row to the right of manual mode.  The typical flow is to put the train in manual mode, edit the schedule, then
turn the train back to automatic.

The controls are at the top of this document, but they borrow the controls of the decider combinator. M is parameter 1,
comma is the operator, and dot is parameter two.  What these are changes based on the schedule condition type, toggled
with j.  For example, "wait" only has one parameter and it is always a constant integer, so you set it with shift + m.
Rather than shifting whether or not m and dot open text boxes, we instead require you to add shift if the parameter can
only be set from a text box.  In future that will basically just be numbers, but for today we do require you to enter
stop names manually--there is no stop selector yet.

Just like with the decider, n controls how the condition joins with the previous (and/or) and slash adds a new one and
moves you to it (combined using or, add ctrl for and).  The key that we add to this is j, to toggle through the
condition types (wait, passenger present, cargo has a specific thing, etc).

The game does not care if stops are present when you add them to a schedule, so we will always support typing stop
names.  Indeed, for some 2.0 functionality typing the stop name is mandatory even for the sighted.  For now, for
simplicity and to get off the ground, you must type your stop names yourself.

Like with the decider combinator, the idea is that you view these controls like reading text or similar (j doesn't fit
the analogy, but it needed one more key and b is too important).  If we put braille on your keyboard with one "field"
per key, it would "fit" on n m comma dot, and then slash adds to the "end" of the row as a whole.

Train groups are supported and are set at the locomotive config level, that is outside the schedule editor.  As with
other vanilla functionality, see the regular Factorio wiki for information on how to use them. To cover the one unclear
point, groups are created by just deciding to use their name (press m instead of clicking into the group selector) and
are destroyed by destroying the last train (or ghost) using the group.  This slightly unintuitive behavior matches
vanilla.  It's more like channels than groups: any train "tuned" to the same name "receives" the schedule.

### Interrupts and Rich Text

The mod has support for reading properly formatted rich text globally.  In the train related text fields, it also
supports some shorthands.

This is relevant to trains (and pretty much only trains) so it is documented here.  In the interrupt system, it is
possible to put icons into station names and then make an interrupt condition like "any cargo > 5".  The train will then
go to (for example) "copper plate item dropoff" if it happens to be copper plates and there is a station with that name,
or "iron plate item dropoff" if it is iron plates.  As with other game mechanics, see the Factorio wiki's railway page
to learn the power of this system--here we just explain how it currently works with the mod.  The two wiki pages you
need are:

- For railways: https://wiki.factorio.com/Railway
- For rich text: https://wiki.factorio.com/rich_text
- For prototype names (see below): https://wiki.factorio.com/Data.raw#half-diagonal-rail

If you are reading this document and don't know what an interrupt does, start by reading those pages.

To start with how to get to and make interrupts, the train schedule GUI has an add interrupt button; like with groups,
to make a new one or type the name of an existing one, press m.  Also like groups, there is no explicit create or
delete.  If a train is using an interrupt it exists, otherwise it does not. So to create one just start using the name.
Interrupts can be dragged like stops to change their priority, and are edited by pressing tab, which will cycle through
child schedule editors for all of your interrupts.

This brings us to the stuff about rich text.  There are two places you may wish to use a wildcard:

- In conditions. To find this, it is in the item selector signals -> unsorted -> parameters.
- In station names.  For that, use what we are about to explain.

There are two ways to enter rich text when typing into train-related text fields. One is to use `[item=prototypename]`.
The other is to use our shorthands.  In order to make it feasible to type rich text, we have introduced a few shorthands
starting with `:`.  They take the form `:t.name`.  For example, `:i.iron-plate` is iron plates.  To find the iron-plate
part, that is the prototype name from the above wiki page. We will be making this better in future.

The full list of shorthands is as follows:

- `:i.x`: item icon of prototype x
- `:f.x`: fluid of prototype x
- ` :s.x`: virtual signal icon of type x.
- `:*` followed by i (item), f (fluid), s (signal), or fu (fuel): the wildcard icon for that type. For example `:*i` is
  "any item".

These are not stored in your save.  We will likely simplify them in future.  What gets stored in the train stop name is
the corresponding official long form.

### The Global Trains Overview

One unique problem with trains is that they move around and do not stay still long enough for you to click them.  To
solve this problem, a trains menu is available under `e`, past the equipment tab.

This menu lets you open the train by clicking the name, but only if close enough; move your cursor to the train; and
toggle the train to manual mode.

A typical workflow (for now):

- Find the train you can't find and toggle it to manual
- Use the menu to move your cursor to it
- Get close enough, and
- reconfigure it

Well-designed train layouts with proper signal placement are robust against trains suddenly switching to manual at any
time.  Figuring out what well-designed means is the point of the game, however, and so not covered further here.
