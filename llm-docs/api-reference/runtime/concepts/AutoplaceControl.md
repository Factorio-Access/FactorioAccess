# AutoplaceControl

**Type:** Table

## Parameters

### frequency

For things that are placed as spots such as ores and enemy bases, frequency is generally proportional to number of spots placed per unit area. For continuous features such as forests, frequency is how compressed the probability function is over distance, i.e. the inverse of 'scale'. When the [LuaAutoplaceControlPrototype](runtime:LuaAutoplaceControlPrototype) is of the category `"terrain"`, then scale is shown in the map generator GUI instead of frequency.

**Type:** `MapGenSize`

**Required:** Yes

### richness

Has different effects for different things, but generally affects the 'health' or density of a thing that is placed without affecting where it is placed. For trees, richness affects tree health.  For ores, richness multiplies the amount of ore at any given tile in a patch. Metadata about autoplace controls (such as whether or not 'richness' does anything for them) can be found in the [LuaAutoplaceControlPrototype](runtime:LuaAutoplaceControlPrototype) by looking up `prototypes.autoplace_control[(control prototype name)]`, e.g. `prototypes.autoplace_control["enemy-base"].richness` is false, because enemy base autoplacement doesn't use richness.

**Type:** `MapGenSize`

**Required:** Yes

### size

For things that are placed as spots, size is proportional to the area of each spot. For continuous features, size affects how much of the map is covered with the thing, and is called 'coverage' in the GUI.

**Type:** `MapGenSize`

**Required:** Yes

