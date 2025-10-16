# FluidBox

Used to set the fluid amount an entity can hold, as well as the connection points for pipes leading into and out of the entity.

Entities can have multiple fluidboxes. These can be part of a [FluidEnergySource](prototype:FluidEnergySource), or be specified directly in the entity prototype.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### volume

Must be greater than 0.

**Type:** `FluidAmount`

**Required:** Yes

### pipe_connections

Connection points to connect to other fluidboxes. This is also marked as blue arrows in alt mode. Fluid may flow in or out depending on the `type` field of each connection.

Connection points may depend on the direction the entity is facing. These connection points cannot share positions with one another or the connection points of another fluid box belonging to the same entity.

Can't have more than 255 connections.

**Type:** Array[`PipeConnectionDefinition`]

**Required:** Yes

### filter

Can be used to specify which fluid is allowed to enter this fluid box. See [here](https://forums.factorio.com/viewtopic.php?f=28&t=46302).

**Type:** `FluidID`

**Optional:** Yes

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### draw_only_when_connected

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### hide_connection_info

Hides the blue input/output arrows and icons at each connection point.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### volume_reservation_fraction

A fraction of the volume that will be "reserved" and cannot be removed by flow operations. This does nothing if the fluidbox is part of a fluid segment.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### pipe_covers

The pictures to show when no fluid box is connected to this one.

**Type:** `Sprite4Way`

**Optional:** Yes

### pipe_covers_frozen

**Type:** `Sprite4Way`

**Optional:** Yes

### pipe_picture

**Type:** `Sprite4Way`

**Optional:** Yes

### pipe_picture_frozen

**Type:** `Sprite4Way`

**Optional:** Yes

### mirrored_pipe_picture

Pipe picture variation used when owner machine is flipped. If no picture is loaded, pipe_picture is used instead.

**Type:** `Sprite4Way`

**Optional:** Yes

### mirrored_pipe_picture_frozen

Frozen pipe picture variation used when owner machine is flipped. If no picture is loaded, pipe_picture_frozen is used instead.

**Type:** `Sprite4Way`

**Optional:** Yes

### minimum_temperature

The minimum temperature allowed into the fluidbox. Only applied if a `filter` is specified.

**Type:** `float`

**Optional:** Yes

### maximum_temperature

The maximum temperature allowed into the fluidbox. Only applied if a `filter` is specified.

**Type:** `float`

**Optional:** Yes

### max_pipeline_extent

The max extent that a pipeline with this fluidbox can span. A given pipeline's extent is calculated as the min extent of all the fluidboxes that comprise it.

**Type:** `uint32`

**Optional:** Yes

**Default:** "Value of `UtilityConstants::default_pipeline_extent`"

### production_type

**Type:** `ProductionType`

**Optional:** Yes

**Default:** "none"

### secondary_draw_order

Set the secondary draw order for all orientations. Used to determine render order for sprites with the same `render_layer` in the same position. Sprites with a higher `secondary_draw_order` are drawn on top.

**Type:** `int8`

**Optional:** Yes

**Default:** 1

### secondary_draw_orders

Set the secondary draw order for each orientation. Used to determine render order for sprites with the same `render_layer` in the same position. Sprites with a higher `secondary_draw_order` are drawn on top.

The individual directions default to the value of `secondary_draw_order`.

**Type:** `FluidBoxSecondaryDrawOrders`

**Optional:** Yes

### always_draw_covers

Defaults to true if `pipe_picture` is not defined, otherwise defaults to false.

**Type:** `boolean`

**Optional:** Yes

### enable_working_visualisations

Array of the [WorkingVisualisation::name](prototype:WorkingVisualisation::name) of working visualisations to enable when this fluidbox is present.

If `draw_only_when_connected` is `true`, then the working visualisation are only enabled when this is *connected*.

**Type:** Array[`string`]

**Optional:** Yes

## Examples

```
```
fluid_box =
{
  volume = 200,
  pipe_covers = pipecoverspictures(),
  pipe_connections =
  {
    {flow_direction = "input-output", direction = defines.direction.west, position = {-1, 0.5}},
    {flow_direction = "input-output", direction = defines.direction.east, position = {1, 0.5}}
  },
  production_type = "input-output",
  filter = "water"
}
```
```

