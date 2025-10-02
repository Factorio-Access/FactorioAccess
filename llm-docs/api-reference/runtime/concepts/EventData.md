# EventData

Information about the event that has been raised. The table can also contain other fields depending on the type of event. See [the list of Factorio events](runtime:events) for more information on these.

**Type:** Table

## Parameters

### mod_name

The name of the mod that raised the event if it was raised using [LuaBootstrap::raise_event](runtime:LuaBootstrap::raise_event).

**Type:** `string`

**Optional:** Yes

### name

The identifier of the event this handler was registered to.

**Type:** `defines.events`

**Required:** Yes

### tick

The tick during which the event happened.

**Type:** `uint`

**Required:** Yes

