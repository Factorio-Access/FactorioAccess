# ItemIDAndQualityIDPair

An item prototype with optional quality specification.

**Type:** Table

## Parameters

### name

Item prototype. Returns `LuaItemPrototype` when read.

**Type:** `ItemID`

**Required:** Yes

### quality

Quality prototype. Normal quality will be used if not specified. Returns `LuaQualityPrototype` when read.

**Type:** `QualityID`

**Optional:** Yes

