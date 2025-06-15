# Task: analyze LLM-generated issue plans and execute on them.

## Character

Do this from the perspective of a senior softwaree engineer.  You care about maintainability and code quality.  This is
an open source project so it's not about what makes the most money or anything like that--elegance is encouraged.  You
understand that as an OSS project, we get fly-by contribution and people of many different experience levels, and try to
write code accordingly.  It is fair to assume a deep knowledge of Lua.

## What

This is a two-phase task. *DO NOT WRITE CODE AT THIS TIME*.  It is also open ended.  Take initiative for decision-making
but not when writing code.

The codebase has some closely related common antipatterns.  The Factorio API at LuaObject has a `.valid` property which must be checked across ticks.  Because of this, the codebase is full of code like this:

```
function do_something(whatever)
    if not whatever.valid then return nil end

    -- really do it
end

function use_the_thing(pindex)
    local player = game.get_player(pindex)
    -- Player is valid, we just got one.
    local target = player.selected
    -- Selected is valid, we just got one.
    do_something(target)
end
```

What's wrong is the extra check.  Because *every caller* of do_something gets the object from the API without crossing a tick boundary, the validity check is not required.  We also have another antipattern:

```
-- Handle mining
function kb_mine(player)
    -- Not important
end

function kb_destroy_ghosts(player)
    if player.valid and player.selected and player.selected.valid and player.selected.is_ghost then
        -- Get rid of ghosts.
    end
end

function kb_x(pindex)
    -- Player is valid.
    local player = game.get_player(pindex)

    if player.selected and player.selected.valid and player.selected.is_ghost then
        kb_destroy_ghosts(player)
    else
        kb_mine(player)
    end
end
```

In this case we have two problems: the player is known top be valid (it came from the factorio API), player.selected is valid if not nil (it also came from the Factorio API, and no ticks have gone by), and the top-level function duplicates the checks

there are other similar antipatterns.

## Deliverables

Evaluate the codebase.  Ultrathink might be required.  Prepare a report that:

- Identifies other similar antipatterns
- Identifies functions whose parents all have duplicate checks
- Proposes small, atomic changes in a list.
- For each change, provides a way to mark whether or not the change should be made.


Once the report is prepared and I have evaluated it, and only after this point, we will proceed to coding.
