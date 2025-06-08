# StorageTankPrototype

A [storage tank](https://wiki.factorio.com/Storage_tank).

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### flow_length_in_ticks

**Type:** `uint32`

Must be positive.

Used for determining the x position inside the `flow_sprite` when drawing the storage tank. Does not affect gameplay.

The x position of the sprite will be `((game.tick % flow_length_in_ticks) ÷ flow_length_in_ticks) × (flow_sprite.width - 32)`. This means, that over `flow_length_in_ticks` ticks, the part of the `flow_sprite` that is drawn in-game is incrementally moved from most-left to most-right inside the actual sprite, that part always has a width of 32px. After `flow_length_in_ticks`, the part of the `flow_sprite` that is drawn will start from the left again.

#### fluid_box

**Type:** `FluidBox`



#### window_bounding_box

**Type:** `BoundingBox`

The location of the window showing the contents. Note that for `window_background` the width and height are determined by the sprite and window_bounding_box only determines the drawing location. For `fluid_background` the width is determined by the sprite and the height and drawing location are determined by window_bounding_box.

### Optional Properties

#### circuit_connector

**Type:** `[]`



#### circuit_wire_max_distance

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### pictures

**Type:** `StorageTankPictures`



#### show_fluid_icon

**Type:** `boolean`

Whether the "alt-mode icon" should be drawn at all.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### two_direction_only

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

