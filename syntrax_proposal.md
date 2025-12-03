# Overview

NOTE: this was the initial proposal, not necessarily what's implemented; docs to come later.  Notably the name Syntrax came well after it.

We have a very very complicated internal mechanism to build rail stuff.  It's hard to work with today, can't be maintained by blind devs, and Factorio 2.0 is going to break the entire thing.

As users we  don't have a good, quick way to build complicated rail pieces.

We may be able to support the rail plannere via the mouse, but the fun with the rail planner is that we have to figure out what it did after the fact, unless all it does is perfectly straight lines and turns only where the user asks.  But if we expose it that way, we might as well not bother--you can already do straight lines and turns in specific spots today.

I therefore propose trainstrings, a tiny language to specify rail placements.  There are two versions of trainstrings.  The first is a minimal set which can build everything we build in the rail builder menu today.  The larger set "compiles" to the minimal set, while including nice features such as repetition that make it useful to humans.

All invocations of trainstrings must start at an end rail, to establish the initial direction.  Each trainstring primitive will push a new rail onto the back of a list, and then "pretend" the new rail is an end rail.

Trainstrings is designed to be easy to parse with a recursive descent parser.  Parsing the full version and "compiling it" should be under 500 lines and unlike other Factorio problems this is all standard simple academic college homework type stuff, e.g. "no surprises".  We know that's true because trainstrings don't interact with Factorio until they are run, by which time they are the basic set.

As an immediate motivation, this is a 3-way fork:

```
ls
reset
rs
reset
ss
```

Or, providing an easier to type shorthand, `ls;rs;ss` where ; is reset (we might pick a different character, but ; makes a good "separate programs" thing I guess).

This seems complicated. But it's not!  The "one neat trick" is that this is driving an invisible train.  Reset is just "start over at the beginning" and all the other bits are as if you were sitting in a locomotive!  Consequently the user-facing model is super easy to teach to those power users who might want to use the whole thing.

There's also a second neat trick!  If we replace all left/right with the opposite we can "flip" lots of (but maybe not all) structures around the axis of the rail, even on diagonals.  This works for all forks we build and I can additionally visualize train station structures etc. which are just one variation, flipped depending if you want it on the left or right.

In Factorio 2.0, all we then change is the primitives described below and the trainstrings, since all that changes in a trainstring is an additional set of `ls` or `rs` where appropriate.  Unless they do something weird to the API, that's an almost day one solution to migrate us: someone sighted works out the new lookup tables, and then we take say an hour minutes to amend and test the trainstrings.

# How

We need three primitives to make the basic version of trainstrings work:

- A function which given any rail (not necessarily an end rail) knows how to extend it with a second rail.  Both in Factorio today and 2.0 this is a set of three: straight+straight, straight+left, straight+right.  Then permuted for all directions, which is probably a lookup table.
- A function which given any straight rail and a direction, can place a train stop.
- A function which given any straight rail and a direction, can place a signal/chain signal.

To make this work, we will remember, at each step, which way the rail was going when it is an end rail, and reuse that information rather than asking if the rail is still an end rail.  This allows us to "reuse" locations inside the trainstrings vm.

The one thing about these primitives: they must take and return arguments/return values which are not actual Factorio manipulations, e.g.:

```
build_left(x, y, direction)
{ "curved-rail", x, y }
```

# Today's Problem Solving

Today, we don't necessarily even need a parser. We could represent these as a table `{"leftt", "straight"}` or whatever.  It's the same idea but"pre-parsed".  That gets us off the ground very quickly.

For our forks and turns, we need exactly 4 primitives `l` (left), `r` (right), `s` (straight), and `reset` (go back to end rail).  The first 3 push a rail of the given type to the list of rails to place.  The last preserves that list and then "starts over" at the initial rail.  We thus end up with something like this:

```
{
	{ "left", "straight" },
	{ "right", "straight" }
}
```

Where the outer table gets a new row every time reset is called.

Reset is also `;` so that users may type small trainstrings quickly.

It is an error to start or end a invocation of trainstrings with a curved rail.  As a result it is also an error to reset with a curved rail at the end of the list.

For our train stations and signals, we will need `chainleft`, `chainright`, `sigleft`, `sigright`, and `stationleft`/`stopright`.

I will now use shorthand from here.

We have some structures today. I always forget how long the center rail is of a 3-way fork and I don't know bypass junctions offhand.  This minimal set is able to build sets of diverging and merging parallel rails in any case.  However for all the others:

- Left 45: ls
- Right 45: rs
- Fork: ls;rs
- 3-way fork: ls;rs;ss
- left 90: lsls
- right 90: rsrs
- Train station. Compute `ceil(cars/7) + 1` and divide that by 2, then run `sigleft chainright `, repeat s the number of times computed before, and run `stopright`.  For a single car train this would be `sigleft chainright ssss stopright` (each car of a train takes 7 tiles, but is actually 4 rails because you have to round up).

The rest of this does not apply to today's problem of internal code.  It does let us add more though, and is what we would want to expose this to the user.

# The Full Model

Chainstrings are textual.  All of the following shorthands expand to their "basic" textual equivalents.  If the "basic" version is valid, the program is valid

We do not introduce branching, dynamic loops, or conditionals.

The trainstring vm has a user-managed stack and for clarity a set of naimed `railrefs` both of which are described below.  Railrefs are the last feature we will want to add.

# Comments

This is a useful format for explaining things.  Let's allow comments.  We'll use `--` because it's lua.  Comments extend till end of line.

#Corner shorthands

`l45` and `r45` are left/right 45 degrees.  `l90` and `r90` are left/right 90.

# Signal Shorthands

`chain&regular` is `chainleft sigright`

`chain&none` is `chainleft`

`none&chain` is `chainright`

So on.

Adding the none is useful with screen readers, for readability.

So our single car station becomes:

```
regular&chain
sss
stopright
```

# Repetitions and parens

A repetition is written `word * count`.  A repetition of multiple words is `(word word word) * count`. Repetitions nest.

AN inefficient multi-car station, therefore:

```
regular&chain
(s * 4) * 6
stopright
```

This is inefficient because it must assume that there are 4 rails per car.  Cars are 7 spaces, so that wastes a bit.

# Variables

Variables are textual substitutions.  Like bash, `$var` refers to a variable.  Programs may not set variables.  Variables come from the external environment.

The main use of variables is to set mathematical computations that trainstrings cannot do.  The variables we will provide include `t1...tn`, the length, in rails, of trains of length `1...n`.  Our inefficient station from above can be improved with these variables.  A station for one car, then:

```
regular&chain
s * $t1
stopright
```

# Flips

The keyword `flip` takes the current end rail and "turns around".  This allows building t intersections:

```
l90
reset
r90
-- Okay say the right turn faced us east. Go west.
flip
s*8 -- number is slightly off. Fill in the t.
```

Or reverse forks:

```
l90
r90
flip
l90
r90
-- Then put it back
flip
```

# The Stack

There is a stack, which is not consumed as output.  `reset` clears this stack and places one at the beginning of the invocation, e.g. the end rail selected by the user.  Without the stack, this is equivalent to how reset has already been used.  `push` pushes the most recently placed rail onto the stack, and must come after a rail placement.  `pop` pops a rail off the top of the stack and sets the trainstring to continue from that position rather than the most recently placed rail.

Why is this useful?  Combined with repetitions, it allows us to build stackers and multiple parallel train stops and so on.  This, for example, is a stacker for 5 trains of length 4:

```
-- Push the end rail we're on onto the stack.
push
-- Build one station, plus an offshoot to continue the next one.
(
	-- On the first invocation we are at the end rail we started on. On subsequent invocations, we're 3 rails after that in a straight line.
	-- The station comes first.
	l90 regular&chain s*$t8 stopright
	-- GO back to the start rail
	pop
	-- Build a little offshoot for the next station.
	s * 3
	-- Push this, then when the pop just above runs next time, we'll end up here.
	-- This is also the last placed rail, so the turn plus station is in the right place.
	push
) * 5
-- If we wanted to continue the program, popping puts us at the end of the offshoot to continue the pattern from the 5th station.
pop
```

# Railrefs

Railrefs are declared `ref @name` and referred to `@name`.

Ref takes the cursor's position and puts it into a named reference.  Invoking the reference puts the cursor back at that position.  These are `ref @name` (declaration) and `@name` (usage).

`sref` sets the top of the stack to a reference. We probably don't need it but if we have everything else we might as well code it since it's trivial.

Reference names may be reused/reset.  `ref` is more like = plus declaration if needed.

This is last because it's mostly for clarity and obscure things.  Obscure things for example being `sref @name @name` duplicating the top of the stack.

However, consider our station example that I keep using.  That's now yet simpler.

```
-- The initial offshoot for the next station.
ref @offshoot
(
	-- Stations start at the offshoot.
	@offshoot
	-- Make the station.
	regular&chain s * $t8 stopright
	-- GO back and make the offshoot.
	@offshoot
	s * 3
	-- Capture it, then next time around we're in the right place.
	ref @offshoot
) * 5
```

Which is clearer than the stack version, because it doesn't require remembering what's on the stack, and the program ends at exactly the right place to continue.

A future direction here could be to allow saving refs between programs.  If we did that, we could build "sets", for example intersections that save refs for their exits.

# Future Directions

Some things that might be fun/useful to add:

- User-defined variables from outside the program.  Would let people store constants or fragments of code to reuse.
- `powerleft(tiles)` and `powerright(tiles)` to place power poles the given number of tiles offset from the track, size set by the user.
- `parallel(tiles)` changes the rail placement shorthands to "shadow" with a parallel track always n tiles from the rails placed by the program until disabled.  `paralleloff` disables this and sets the other track's endpoint to `@p`.  Hard to do, requires some analysis and thought and probably restricting the language while parallel is on.
- Direct compilation to blueprints via a web tool.
- This is totally the kind of thing a subset of sighted Factorio users wants, so turning it into a mod for the sighted with a remote API might be fruitful.
