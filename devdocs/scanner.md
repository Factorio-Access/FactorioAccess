Last reviewed: 2024-10-21 (update this if reviewing this doc)

# Introduction

The scanner is one of the flagship features of the mod.  It determines important map
features and groups things into categories, presenting a list to the player of
what is available where.  This is controlled through `PAGE UP` and `PAGE DOWN`, plus
modifiers.  Players are presented with a 3-level list: categories,
subcategories, and entries in those subcategories.  From the player perspective,
subcategories are not currently a named concept, but they are explicitly named in the code.  
So, for example:

- An assembling machine is category Production, subcategory based off the recipe.
- Resource patches are category Resources, subcategory as the prototype type of the patch.

For the cases of water bodies and resource patches in vanilla, and compound entities in mods (not yet used as of this writing), it is possible to have more than one entity in an entry. Indeed in the case of water, it is possible to have none at all, as that is instead based off tiles.

This document covers how this is done.  There used to be a simpler variation of the scanner tool, but the modern implementation is both flexible and performant.  As a brief overview of how it works, a set of "backends" scan the surface in the background.  The player then receives a stable view over that list, refreshed with the `END` key in the default key mappings.  While from the UX perspective this appears that it is doing computation, what it is actually doing is grabbing updated versions of the list.  Unfortunately even that is expensive, so there is still some noticeable lag during refresh, as of this writing.  That can be reduced further, and some strategies as to how we have done so already are presented here.

# The Quick Version: how to perform common tasks

Read this whole section before doing anything.

If you've got a new prototype type or name, read single-entity.lua.  Copy one similar to yours and rename/modify it.  The most complex example there is furnaces, which demonstrates how one can make something which dynamically moves between categories.  Then, go to surface-scanner.lua.  At the top (almost first thing in the file) are a couple tables,.  One for prototype types and one for names.  Plug your backend in there like all the rest.

If this is for mod support (for e.g. say seablock--not our own mod) make one small change instead.  If you scroll down you can see where we add some dynamic prototypes.  Check for the presence of the mod and put them in at that spot if the mod is present.

If you need to do something more complicated, copy and modify an existing backend.  Which one doesn't matter for the most part.  Clear out the methods, leave the ones you don't need empty.  Then add it to the tables as above.

To add a new scanner category open scanner-consts.lua and add it to `CATEGORIES`.  Below, also add it to `CATEGORY_ORDER` so that the scanner knows to iterate it and where.  Then make sure a localised string of the form `scanner-categoryname` e.g. `scanner-category-production` is present.

Finally you probably need to go to surface-scanner.lua and find the declaration of storage-manager.  Increment `ephemeral_state_version` by 1.  This will wipe out and rebuild scanner information in saves as necessary.  This is not always required, but if you are unsure whether it is or not then this is always safe to do.

Scanner ignores any prototype type not in these tables.  E.g. we leave out beams and explosions.

# Bounding the Problem

Before discussing the solution, let us first discuss the bounds on the problem.  In Factorio today (Update 1.1) we have a single surface.  In a general somewhat large save --not a megabase, just winning the game-- that includes easily 10000 to 20000 player-placed objects.   In addition to that, one is looking at thousands of trees, up to and well beyond 10000 fish, and potentially tens to hundreds of thousands of water tiles.

In Space Age, this again increases because multiple surfaces are present.  As of this writing we can't know by how much, but easily by a factor of 5.

We must account for all of this in an efficient way.  We have under 16 milliseconds to do it every tick.  Significantly so, as we must also leave time for the main game to run.  This must also be done in some form which is reasonably memory efficient, or which at least has the potential to be in future.  As of this writing, the scanner is memory efficient for 1.0/2.0 vanilla, but needs some improvements for Space Age.  See later in this document about bitsets.

# The Big Idea

Let's step back and pretend that this isn't Factorio or Lua.  We are in some programming language which has all the features we might want and without the constraints of needing to be safe to store in storage.  The obvious solution in that situation is to get some sort of list of new entities or tiles, and feed them into classes.  And indeed, that's what we do.  But with some Lua-specific and Factorio-specific tricks.  This allows pushing all of the complexity to one spot, and makes extension and modification of the scanner possible without having to understand the rest.  To see this, read any of the backends-- can you implement a callback that handles one entity?  Yes.

But.  This is Lua.  So instead of classes we have closures and metatables.  And we don't get closures because we have to store in storage.  Our only hammer is metatables, and as they say if all you have is a hammer... The way that Lua does OOP is via metatable tricks.  See [Programmihng in Lua](https://www.lua.org/pil/16.html) for some information.  This is Lua 5.1, but nothing changed about metatables in Lua 5.2.

Factorio allows registering metatables by name with some boilerplate ceremony.  We already use this in e.g. rulers.  One invents a name which must never change, and then registers it at the top level.  This makes a number of things complicated, most notably inheritance.  For the sake of simplicity therefore we just drop empty methods in when a backend doesn't need them.  For the most part that means exactly one: `on_new_entity` or `on_new_chunk`.

The elephant in the room of course is that single-entity.lua does in fact appear to be using callgbacks.  This is true, but that too is a trick.  In table-helpers.lua, a helper function called `nested_indexer` exists which knows how to chain metatables together.  By using this, we can write the function at the bottom of backends/simple.lua which is able to hide away the complexity of packing callbacks and other things that can't safely store into storage behind metatable tricks.  The restriction is that one must do all of this at the top level of the code so that it loads when control.lua does, not after.  This is fine for scanner, and indeed as can be seen in single-entity.lua works quite well.

The result of all of this is that one needs to know barely anything to add to it.  While Lua OOP isn't really friendly to new Lua users, copying code around and changing some strings is enough.

The real complexity happens in two places plus some dependencies.  Here is an overview list.  We will not cover all of these in detail, because in many cases the code is commented with how to use the interface:

- In data.lua, we use some tricks to use a not-well-documented feature to hook into creation of all entities regardless of how they are created.  This works "most of the time".
- In surface-scanner.lua, we incrementally iterate over surfaces. to catch missed entities, process incoming new entities from the effect trigger in the above, and find and categorize new chunks.
- In entrypoint.lua, we handle the extremely complicated cursor management, which is able to deal with invalidation of entries, and drive the actual refresh by asking surface-scanner what it can offer and filtering it down.
- In ds/* we have a number of dependent data structures, two of which will be covered below.
- What we won't cover is worker-queue.lua and ds/deque.lua, because those are commented and simple enough.  They together form a system for running per-tick background work in a more complex config than simply running `on_tick`: one submits things to them and gets called via a callback, and it is also able to say when it is idle and ready for more work.

# What's in a Backend

A backend has three responsibilities, spread amongst a few interface methods.  It must categorize features to expose, tell the scanner code how to announce said features, and know how to tell the scanner if a feature has sinhce become invalid.  To break this down:

- `on_new_entity` and `on_new_chunk` get information on new entities and chunks.  As of this writing, these are guaranteed to be new entities or newly generated chunks, but Space Age and 2.0 may necessitate changing this slightly.  That is TBD.
- `dump_entries_to_callback` must call a callback with tables representing all entries.  This format is documented in entrypoint.llua as the type `fa.scanner.ScanEntry` with self-explanatory fields.
- `readout_entry` must return a string, preferrably localised, which will announce the information.  The scanner itself handles positional information "2 west and 5 north".  For simple backends this is actually just `fa-info`.
- `validate_entry` must return false when entries are no longer valid.  For example, water completelyu covered with landfill, no trees left in an area, or an invalid entity.
- `update_entry` is a callback which is called just before announcement.  It should update the entry with a new position if necessary, as well as changing subcategories etc.  This is the chance to do expensive checks for precision, for example recounting trees or finding a precise bounding box.
- `get_aabb` must return the bounding box of an entry.  This is not paert of the entry itself for performance, and also for performance must return the AABB as 4 return values: `left_top.x, left_top.y, right_bottom.x, right_bottom.y`.  This is because creation of tables in Lua is expensive even if they are immediately thrown away, but returning values like that instead pushes them on the stack.  IMPORTANT: reading `entity.bounding_box` etc. does create a table.  It's fine for this to be apoproximated as long as it is reasonably accurate and the position is updated precisely in `update_entry`.
- `is_huge` must return true if the entry is "huge".  This is somewhat subjective.  When it returns true, it enables a more expensive set of checks to determine whether or not an entry is charted.  For an example of a subjective decision, see trees.lua, which only tells scanner that forests are huge if over a specific size.  Water is always huge, though mostly for simplicity; single entities never are.  The enhanced check can deal with cases such as having a position and 4 corners which are all in uncharted chunks, but still having the player in the middle and needing to show the entry, for example the player being on an island.


# Stop Here

If all you need to do is modify scanner backends and tweak how things are categorized, congrats!  You can probably stop here and save yourself headaches.  If you need to dig into the code more deeply, read on.

# An Aside: bitsets and unique entity ids

As alluded to earlier, the scanner must be memory efficient.  This is a good point to discuss how that can be done.

The first thing to know is that Factorio does not reliably have a way to ask a simple question: "give me all new entities since tixck x" or similar.  That's on us.  We can use the effect trigger trick to wire a callback in, but that doesn't always fire, and we must therefore crawl the surface to make sure we are in sync.  As an example of when it doesn't, initial surface generation spawns a surface with resource entities already in place.

To get around that, it's important to maintain a set of unique entity ids.  Factorio does not currently have a way of doing this either, not directly.  Instead, we can register entities for destruction.  When we do so, we get a u64 integer id which remains the same across duplicate calls.  At first it appears that we could use unit_number instead, but that is only found on entities placed by the player, e.g. resources and rocks and trees don't have it.  The destruction trick works no matter what it is, and given that we have figured out how to do background work incrementally it's fast enough.  Also, we can benefit anyway by using it to delete entities from sets when we know they are no longer around.

The typical Lua idiom for a set is to create a table whose keys are the set members and whose value is always a truthy value.  In our codebase thjis is mostly the boolean `truje`, though sometimes people use other things.  For example, `set[new_item] = true` is insertion, and `if set[item] then ...` is membership testing.

That's fine as far as it goes, but very not fine when we have hundreds of thousands or more.  But, there is an alternative.  Lua does have bitwise operators, and Lua numbers can hold 32-bit integers loisslessly.  This thus gives us ds/bitset.lua, which is able to specifically hold a set of numbers all the way up to `2^53 - 1` at around one bit per number, for an over 32 times space savings.  This falls into the category of "things you know if you've done C".

This can be extended one more place.  As will be discussed briefly later, water and tree handling do use sets like this containing tiles.  Today that's just two nested tables, as it's fast enough and small enough.  But because the bitset can handle larger than 32-bit integers and the size of Factorio surfaces are bounded, it is possible to perform the transformation `y * 2e6 + x`, and undo it with `x = n - floor(n/2e67)` and `y = floor(n/2e6)`.  This enables storing 2D sets of surface tiles in these bitsets.  In spacec age this will become necessary; in vanilla/2.0 it is not, and so wasn't done as of this writing.

# surface-scanner

Surface-scanner is pretty explanatory but important enough to deserve at least a brief section.  It maintains two sets: a set of seen chunks and a set of seen entities.  When it gets a new chunk or entity, it calls the callbacks on the backends in the tables at the top.

"seen" here means either:

- An effect trigger fired.  For what little documentation exists see `EntityPrototype`'s `ccreated_effect` field.  I got this from the modding Discord via justarandomgeek.  THis is the trick that lets it appear low latency.
- A new entity was found crawling the surface chunk by chunk.  E.g. initial resourcews.
- Crawling the surface hit a new chunk for the first time.  We don't bother hooking into chunk generation or charting, we just grab them on the next iteration and maintain a set.

The low latency aspect is a "lie" in a sense.  The fact of it being low latency comes from two factors: the above mentioned effect triggers, and smartly dispatching chunks when we start a new round of work.  To make sure that things near the player are always updated, we sort chunks by the distance from the player.  This means that the player must find a way to place entities without triggering effects, which can't happen with normal building etc., or generate and try to explore chunks faster than the map scan can keep up (over 1 per second minimum, but in practice more than that).  In theory these are possible.  In practice no one will be able to notice for a variety of reasons.  It also helps that chunks are generated before charting in any case.

# Clustering: handling water, trees, and resources

We introduce two kinds of clusterer data structures, both able to cluster entities and tiles in slightly different ways.  We may drop the first in favor of a well-tuned tile clusterer in 2.0.

## Resources (ds/resource-clusterer.lua)

Factorio doesn't exactly have the concept of a resource patch.  It instead has the concept of a bunch of resource entities close together.  If patches are maintained, they're either in the frrontend only or are just computed on demand.  My suspicion is that they are computed on demand because if one has access to the underlying map data structure in C++ performing the query in realtime is trivial.  Unfortunately we are in Lua, so it's not for us.  How this works is that the prototypes set a search radius, and any pair of resources close together combine into one patch, repeat recursively.

We can do that but it's tricky because we instead have to do it in a streaming fashion, otherwise it's way too much work.  To do so, we use a basic spatial hash and recursively combine overlapping buckets.  By carefully tuning the bucket size based on the search radius and carefully computing some bounding boxes, we can guarantee that all pairs in the same patch land in the same buckets.  Then, we can recursively combine the buckets.

That's complicated but effectively 100% accurate.  It's also somewhat slow thus doing it incrementally.  In 2.0 we can probably instead use the tree trick, discussed in a moment, though it should be noted that this kind of clusterer can be used for other things, for example detecting "bases" by clustering non-resource entities like assembling machines.

## The Tile Clusterer: waters and forests (ds/tile-clusterer.lua)

NOTE: a much more detailed comment on the data structure is in the lua file.

Tile clustering for water is floodfill on paper.  That is to say that you grab a water tile, check tghe adjacents, repeat until you run out of adjacents.  Factorio does have a method to let us just ask.  It doesn't have a method to check that two tiles are in different clusterers. Therefore all simple algorithms have to build some giant sets and filter them down by iterating in Lua, AKA a big fat no.  It may be possible to explore this approach with sufficient cleverness, but as shall be seen the following also works with trees and changing it to something eager probably requires the same amount of clever.

What we do instead is a trick.  We can do incremental floodfills.  It's complicated, but the idea is that we keep a set of tiles as we see them for the first time (thus `on_new_chunk`).  As this set grows, tiles eventually touch other tiles.  So, when the first tile comes in, what we do is place it in the set, mark it as an edge, and record that it has 4 unchecked adjacents.  As more tiles come in, we can decrement the count of adjacent tiles we've seen and, when it hits 0, we know that the tile is now an interior tile and "frozen" because no new adjacents can come in.  This, plus subtleties explained in the lua that make it much more complex, lets one reliably get the edge tiles of "clusters" like water.  Primarily, the subtleties arise because we can't control the order we get tiles, and so subgroups can have to merge--but we can't  go modify every single tile because that is at minimum `O(N^2)` but I think actually outright exponential-class complexity.

The "tree trick" and the way we can probably eventually migrate to this for resources is this.  Take the coordinates of a tree.  Divide them out by a fixed number, currently 8, and take the floor.  This is an 8x8 chunk, with coordinates in the 8x8 chunk space.  So, why not call it a tile?  And why not throw it in the tile clusterer?  And that is exactly what we do.  In practice, this means that trees "around" 16 tiles apart cluster together into one forest, repeat recursively.  In our backend, we compute more updated bounding boxes and tree counts on refreshes, so that mining trees slowly shrinks them down, the cursor always places on a tree, and the bounding boxes are right.

To use this for resources we can give up on perfection, tune the chunk-like size based on the search radius, and do the same.  By iterating edge tiles we can get a bounding box for an efficient surface query.  The fact that we didn't is basically just that I (ahicks) did resources first, then found out the resource algorithm doesn't scale to 10000 tile lakes.

# Lua Microoptimizing

NOTE: you should write code for clarity.  This is an exception because scanner is pushing the limits of what Lua itself is capable of.

We should document this somewhere but mostly they're relevant to scanner and at least they're written down.

When using a global variable in Lua it is translated to `_ENV.globalname` which is a hashtable lookup.  Note that lua files are the bodies of functions.  Yes changing what `_ENV` is does in fact change what globals are available; never do this even though you can, it's terrible code.  This means that:

```
local thing = thing
```

(as in the same variable on both sides) invisibly optimizes lookups.  This does not work if the global is assigned to.  What it does work for though is:

```
local insert = table.insert
```

And similar: functions which are never reassigned.  Indeed `math.x` is very bad because it is `_ENV.math.x` e.g. two hashtable lookups every single time.

This works at the top level of a Lua file as well because Lua files are functions and the functions inside Lua files are actually closurees.

This also applies to locals, e.g. `local field = self.field` if field is a table or something.  And intermediate values in nested lookups.  Lua is "dumb" and cannot optimize any of this at all.  What happens in a local referred  to by the immediate block or even a nested closure is that it is instead a fixed index to an array.

Lua can't optimize tables well.  All table creations are a heap allocation.  Getting into just how that works is beyond the scope of this document.  Suffice it to say it's not exactly malloc/free, but it's not cheap.  That means code like:

```
local point = { x= 4, y = 5 }
-- Do stuff with point
-- Now ignore point forever
```

Is inefficient unless there is some reason to actually use the point as a table.  Instead, better to:

```
local x = 4
local y = 5
```

Which is a pattern commonly seen in the scanner.

As an extension of that, Factorio-style bounding boxes are 3 tables total.  That's also very bad.  As in it was a 2x performance increase or so to compute the boxes lazily as 4 return values on the stack.  Therefore scanner is full of variables like `ltx` for bounding box points.

When working with global-manager you also commonly want:

```
local gstate = global_thiung[pindex]
```

Or similar, both for the above reasons and because that is also going through metatable magic at the same time.

This does imply that `function mod.func = function() ... end` and later `mod.func()` in the same module is slower than declaring func as a local function and assigning it to mod.func later, then caling it as the local.  This is indeed correct, though for the scanner we don't have to go that far fortunately.

Not much investigation was done on this, but PUC Lua can optimize table constants written out, rather than code like `local t = {} t.field = 5` by allocating up front.  Whether this is true of Factorio's fork is unknown, but may deserve looking into.  Since it can't hurt and avoids some double lookups, parts of scanner do go out of their way for it.

Table.remove in the middle of tables is bad, though not for Lua specific reasons.  Instead we introduce table-helpers.retain_unordered.  This will destroy the order of the array, but can efficiently delete in `O(N)` instead of `O(N^2)` when doing a single-pass remove invalid items type thing.

We also introduce `memosort.lua`, for similar reasons as retain.  It's cheaper to cache the results of some comparisons and easier in many cases to just return a score value.  This is useful for sorting say an array of arrays where the inner arrays are points, by the closest point in the inner array.
