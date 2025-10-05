# on_train_created

Called when a new train is created either through disconnecting/connecting an existing one or building a new one.

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### old_train_id_1

**Type:** `uint32` *(optional)*

The first old train id when splitting/merging trains.

### old_train_id_2

**Type:** `uint32` *(optional)*

The second old train id when splitting/merging trains.

### tick

**Type:** `uint32`

Tick the event was generated.

### train

**Type:** `LuaTrain`

