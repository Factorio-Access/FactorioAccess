Ok, so what is left is the large event manager refactor, which you have misunderstood.  It is supposed to be like this:

```
-- in control.lua
function handle_the_whatevber(event)
end

EventManager.register("fa-w", handle_the_whatever)
```

Not lifting the handlers to the other file at all.

I think this makes event-registry irrelevant, but in any case the changes to control.lua should be very minimal, and they currently are not.

Also, files are named `a-b`, not `a_b`, which you need to fix, and you should spend time using the linter to get LuaLS annotations where useful.
