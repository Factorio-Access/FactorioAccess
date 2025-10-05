# script_raised_destroy_segmented_unit

A static event that mods can use to tell other mods they destroyed a segmented unit by script. This event is only raised if a mod does so with [LuaBootstrap::raise_event](runtime:LuaBootstrap::raise_event), or [LuaBootstrap::raise_script_destroy_segmented_unit](runtime:LuaBootstrap::raise_script_destroy_segmented_unit), or when `raise_destroy` is passed to [LuaSegmentedUnit::destroy](runtime:LuaSegmentedUnit::destroy).

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### segmented_unit

**Type:** `LuaSegmentedUnit`

The segmented unit that was destroyed.

### tick

**Type:** `uint32`

Tick the event was generated.

