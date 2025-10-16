# TrainFilter

**Type:** Table

## Parameters

### force

Train must contain at least one rolling stock of this force to pass

**Type:** `ForceID`

**Optional:** Yes

### group

Train must belong to a group of a given name.

**Type:** `string`

**Optional:** Yes

### has_passenger

Checks if train has a passenger.

**Type:** `boolean`

**Optional:** Yes

### is_manual

Checks if train is in manual controller.

**Type:** `boolean`

**Optional:** Yes

### is_moving

Checks if train is moving (has speed != 0) or not moving.

**Type:** `boolean`

**Optional:** Yes

### max_stocks

Train must have at most that many stocks to pass

**Type:** `uint32`

**Optional:** Yes

### min_stocks

Train must have at least that many stocks to pass

**Type:** `uint32`

**Optional:** Yes

### stock

Train must contain a rolling stock of any of provided prototype to pass

**Type:** `EntityID` | Array[`EntityID`]

**Optional:** Yes

### surface

Surface the train must be on in order to pass

**Type:** `SurfaceIdentification`

**Optional:** Yes

### train_id

Train ID filter

**Type:** `uint32`

**Optional:** Yes

