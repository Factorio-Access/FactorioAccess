# on_market_item_purchased

Called after a player purchases some offer from a `market` entity.

## Event Data

### count

**Type:** `uint32`

The amount of offers purchased.

### market

**Type:** `LuaEntity`

The market entity.

### name

**Type:** `defines.events`

Identifier of the event

### offer_index

**Type:** `uint32`

The index of the offer purchased.

### player_index

**Type:** `uint32`

The player who did the purchasing.

### tick

**Type:** `uint32`

Tick the event was generated.

