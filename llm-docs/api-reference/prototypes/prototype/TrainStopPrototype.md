# TrainStopPrototype

A [train stop](https://wiki.factorio.com/Train_stop).

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `train-stop`

## Properties

### animation_ticks_per_frame

**Type:** `uint32`

**Required:** Yes

### rail_overlay_animations

**Type:** `Animation4Way`

**Optional:** Yes

### animations

**Type:** `Animation4Way`

**Optional:** Yes

### top_animations

**Type:** `Animation4Way`

**Optional:** Yes

### default_train_stopped_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_trains_count_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_trains_limit_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

### default_priority_signal

**Type:** `SignalIDConnector`

**Optional:** Yes

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

### color

**Type:** `Color`

**Optional:** Yes

### chart_name

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### light1

**Type:** `TrainStopLight`

**Optional:** Yes

### light2

**Type:** `TrainStopLight`

**Optional:** Yes

### drawing_boxes

**Type:** `TrainStopDrawingBoxes`

**Optional:** Yes

### circuit_connector

**Type:** (`CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`, `CircuitConnectorDefinition`)

**Optional:** Yes

### build_grid_size

Has to be 2 for 2x2 grid.

**Type:** `2`

**Optional:** Yes

**Default:** 2

**Overrides parent:** Yes

