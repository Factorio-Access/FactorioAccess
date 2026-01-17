# DisplayPanelPrototype

Entity that display a signal icon and some text, either configured directly in the entity or through the circuit network.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `display-panel`

## Properties

### sprites

The display panel's graphics.

**Type:** `Sprite4Way`

**Optional:** Yes

### max_text_width

The maximum display width of the text on the display panel. If the text exceeds this width it will be wrapped so that it continues on the next line.

**Type:** `uint32`

**Optional:** Yes

**Default:** 400

### text_shift

The shift of the text on the display panel.

**Type:** `Vector`

**Optional:** Yes

### text_color

The color of the text on the display panel.

**Type:** `Color`

**Optional:** Yes

### background_color

The background color of the display panel text.

**Type:** `Color`

**Optional:** Yes

### circuit_wire_max_distance

The maximum circuit wire distance for this entity.

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

