# PipeConnectionDefinition

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### flow_direction

Allowed direction of fluid flow at this connection. Pipeline entities (`pipe`, `pipe-to-ground`, and `storage-tank`) do not support this property.

**Type:** `FluidFlowDirection`

**Optional:** Yes

**Default:** "input-output"

### connection_type

Selects set of rules to follow when looking for other FluidBox this connection should connect to.

**Type:** `PipeConnectionType`

**Optional:** Yes

**Default:** "normal"

### enable_working_visualisations

Array of the [WorkingVisualisation::name](prototype:WorkingVisualisation::name) of working visualisations to enable when this pipe connection is present.

If the owning fluidbox has [draw_only_when_connected](prototype:FluidBox::draw_only_when_connected) set to `true`, then the working visualisation is only enabled if this pipe connection is *connected*.

**Type:** Array[`string`]

**Optional:** Yes

### direction

Primary direction this connection points to when entity direction is north and the entity is not mirrored. When entity is rotated or mirrored, effective direction will be computed based on this value.

Only loaded, and mandatory if `connection_type` is `"normal"` or `"underground"`.

**Type:** `Direction`

**Optional:** Yes

### position

Position relative to entity's center where pipes can connect to this fluidbox regardless the directions of entity.

Only loaded if `connection_type` is `"normal"` or `"underground"`.

**Type:** `MapPosition`

**Optional:** Yes

### positions

The 4 separate positions corresponding to the 4 main directions of entity. Positions must correspond to directions going one after another.

This is used for example by "pumpjack" where connections are consistently near bottom-left corner (2 directions) or near top-right corner (2 directions).

Only loaded, and mandatory if `position` is not defined and if `connection_type` is `"normal"` or `"underground"`.

**Type:** (`MapPosition`, `MapPosition`, `MapPosition`, `MapPosition`)

**Optional:** Yes

### connection_category

Fluidboxes' pipe connections are only allowed to connect with each other if they share a connection category. For example a mod could have a "steam pipes" and "cryogenic pipes" category that should not connect with each other.

In case of a normal connection, a pipe connection can be in multiple connection categories. This allows to create a mod where pipes of different categories would not connect to each other while still making it possible for crafting machines and other entities to connect to any of the specified pipes.

By default, all pipe connections have the `"default"` category. So a pipe that should connect to a new category and standard pipes can have the `connection_category = {"my-new-pipe", "default"}`.

May have at most one category when `connection_type` is `"underground"`.

Only loaded if `connection_type` is `"normal"` or `"underground"`.

**Type:** `string` | Array[`string`]

**Optional:** Yes

**Default:** "default"

### max_underground_distance

Only loaded if `connection_type` is `"underground"`.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### max_distance_tint

Only loaded if `connection_type` is `"underground"`.

**Type:** `Color`

**Optional:** Yes

### underground_collision_mask

An underground connection may be defined as colliding with tiles in which case if any tile is placed between underground ends the connection will not be established.

In order to connect, both ends must have the same collision mask specified.

Only loaded if `connection_type` is `"underground"`.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### linked_connection_id

Expected to be unique inside of a single entity. Used to uniquely identify where a linked connection should connect to.

Only loaded, and mandatory if `connection_type` is `"linked"`.

**Type:** `FluidBoxLinkedConnectionID`

**Optional:** Yes

