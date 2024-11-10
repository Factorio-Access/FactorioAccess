--[[
Transport belt graph crawling and analysis.

This is long. That's because the official docs are weak here.

# Our Model

Before we get into what Factorio does, let's get into our model.  In our model,
each belt segment, splitter, etc. is a node in a graph.  At each node in this
graph, one may ask for:

- The parent belt entity.
- Any sideloading belt entities.
- The child belt entity.
- The contents of the belt segment if it is a belt or underground exit.
- The contents of the left or right side if it is a splitter.
- The contents of the underground belt part if it is an underground belt
  entrance.

Off this, we then implement a variety of heuristics.  Each node is a class-like
metatable (storage-safe, per usual), and on that are methods which can tell one
various heuristic things, for example "is this belt carrying something even
though the focused segment is empty".  This is all done by crawling the graph.
The heuristics which are available are documented on the methods--this comment
itself is already quite a lot.

This module exposes a function `node_from_entity` which  takes a belt
connectable entity and converts it to a node.  Note that calling it twice does
*not* return the same object.  Due to various API limitations and the like, we
can't do that conveniently so for now we don't.

To find out if two nodes are the same thing, call `is_same_node(other)` on the
node.  Under the hood, that's unit number comparisons.

Like with Factorio objects nodes may invalidate.  To check for this, use
`:valid()` like other Factorio objects, except in our case it's a function
because we have to check the underlying.  Nodes validate this: using an invalid
node crashes reliably.

# The Engine API

The engine separates things into transport lines.  Each line is what we call a
lane.  There is a defines.transport_line  which itslef documented, but the fact
of it going with get_transport_line isn't.  If on a given entity type, the
relevant defines there are always available.  The rules are as follows:

- For transport belts, the left and right lane get a line.
- For underground belt exits, we get a half-length line containing the contents,
  like it's a transportr belt but short, and a second set of lanes which seem to
  always be unused.
- For underground belt entrances, we get a half-length line for each incoming
  lane for the tile of the underground belt itself, then two more lanes whose
  length is the number of tiles underground.
- For splitters, we get 8 (!). Two each for the 2 inputs and 2 outputs.  That is
  4 incoming to process the input side, left/right/left/right, and then 4
  outgoing in the same way.
- For loaders, we get 2 like it's a belt.

All of the above are known as "belt connectable entities" in the official docs.
Belt connectable entities are entities which, when placed near belts, will join
up with each other to form the belt network.

LuaEntity has two fields: neighbours, and belt_neighbours.  If you are blind
note that neighbours is spelled with a u.  For everything but underground belts,
the belt_neighbours field shows us the neighbours.  For underground belts, one
must consult neighbours.  By consulting these two, it becomes possible to figure
out what's around the belt, but not to figure out the shape.

For the "shape", the first place we can look is belt_shape.  This tells us if it
is a corner.  That's the cheap version: if it's a corner we're done, there's no
sideloading going on.  For sideloading, we must infer that by looking at the
directions.  If a belt is going east and we have a north,  that is left
sideloading.  We can get this without tables with modulus tricks: in general at
this point it's probably safe to assume the engine won't add new directions, so
we'll always be at 16, and a shift is then +-4.  This is available in
geometry.lua.

There is an API on LuaTransportLine `input_lines` and `output_lines`.  Do not
use this without care.  They will skip until the line changes, e.g. they can go
50 or 100 belt entities before hitting a change.  There are two reasons one may
wish to play with this.  The first and simplest is that it does provide a veiw
of all sideloads on a long segment regardless of how far away they are.

The second reason brings us to splitters.  As mentioned above, the splitter has
8 lines.  It happens that these lines are given precise indexes and that the
inputs never move beyond the splitter's immediate parent.  That is, the input
side and output side of a splitter are both "walls" in the traversal.  This gets
rid of the need to do geometry.  Instead, we may ask for the inputs of the left
input line of the left side, and that'll always be the left input.

So, in conclusion the complex part is the recursion.  Once we have an entity and
the shape of it everything else is "assk the API".  All the complexity here then
shifts into the function which can let one recurse inputs and outputs, and then
the checks to make sure that loops aren't crawled indefinitely.