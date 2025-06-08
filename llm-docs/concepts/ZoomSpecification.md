# ZoomSpecification

A table specifying a fixed or dynamically-computed zoom level using one of the supported methods. Used by [ZoomLimits](runtime:ZoomLimits).

Method 1 only uses the `zoom` field. The zoom level is fixed and will not change at runtime. Directly correlates to the perceived size of objects in the game world.

Method 2 only uses `distance` and optionally `max_distance`. The zoom level is computed dynamically based on the player's window dimensions and aspect ratio. This method is ideal for limiting how far the player can see.

If there is ambiguity in which method should be used (i.e. both `zoom` and `distance` fields are provided), an error will be thrown during parsing.

