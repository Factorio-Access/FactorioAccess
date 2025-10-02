# StorageTankPrototype

A [storage tank](https://wiki.factorio.com/Storage_tank).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `storage-tank`

## Properties

### fluid_box

**Type:** `FluidBox`

**Required:** Yes

### window_bounding_box

The location of the window showing the contents. Note that for `window_background` the width and height are determined by the sprite and window_bounding_box only determines the drawing location. For `fluid_background` the width is determined by the sprite and the height and drawing location are determined by window_bounding_box.

**Type:** `BoundingBox`

**Required:** Yes

### pictures

**Type:** `StorageTankPictures`

**Optional:** Yes

### flow_length_in_ticks

Must be positive.

Used for determining the x position inside the `flow_sprite` when drawing the storage tank. Does not affect gameplay.

The x position of the sprite will be `((game.tick % flow_length_in_ticks) ÷ flow_length_in_ticks) × (flow_sprite.width - 32)`. This means, that over `flow_length_in_ticks` ticks, the part of the `flow_sprite` that is drawn in-game is incrementally moved from most-left to most-right inside the actual sprite, that part always has a width of 32px. After `flow_length_in_ticks`, the part of the `flow_sprite` that is drawn will start from the left again.

**Type:** `uint32`

**Required:** Yes

### two_direction_only

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### show_fluid_icon

Whether the "alt-mode icon" should be drawn at all.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### circuit_wire_max_distance

**Type:** `double`

**Optional:** Yes

**Default:** 0

### draw_copper_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_circuit_wires

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### circuit_connector

**Type:** (`CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`)

**Optional:** Yes

