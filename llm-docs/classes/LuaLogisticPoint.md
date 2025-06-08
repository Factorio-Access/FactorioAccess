# LuaLogisticPoint

Logistic point of a particular [LuaEntity](runtime:LuaEntity). A "Logistic point" is the name given for settings and properties used by requester, provider, and storage points in a given logistic network. These "points" don't have to be a logistic container but often are. One other entity that can own several points is the "character" character type entity.

## Methods

### add_section

Adds a new logistic section to this logistic point if possible.

**Parameters:**

- `group` `string` _(optional)_: The group to assign this section to.

**Returns:**

- `LuaLogisticSection`: The added logistic section.

### get_section

Gets section on the selected index, if it exists

**Parameters:**

- `section_index` `uint`: Index of the section

**Returns:**

- `LuaLogisticSection`: 

### remove_section

Removes the given logistic section if possible. Removal may fail if the section index is out of range or the section is not [manual](runtime:LuaLogisticSection::is_manual).

**Parameters:**

- `section_index` `uint`: Index of the section

**Returns:**

- `boolean`: Whether section was removed.

## Attributes

### enabled

**Type:** `boolean`

Whether this logistic point is active, related to disabling logistics on player/spidertron.

When the logistic point is disabled it won't request and auto trash will do nothing.

### exact

**Type:** `boolean` _(read-only)_

If this logistic point is using the exact mode. In exact mode robots never over-deliver requests.

### filters

**Type:** ``CompiledLogisticFilter`[]` _(read-only)_

The logistic filters for this logistic point, if this uses any.

The returned array will always have an entry for each filter and will be indexed in sequence when not `nil`.

### force

**Type:** `LuaForce` _(read-only)_

The force of this logistic point.

This will always be the same as the [LuaLogisticPoint::owner](runtime:LuaLogisticPoint::owner) force.

### logistic_member_index

**Type:** `uint` _(read-only)_

The Logistic member index of this logistic point.

### logistic_network

**Type:** `LuaLogisticNetwork` _(read-only)_



### mode

**Type:** `defines.logistic_mode` _(read-only)_

The logistic mode.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### owner

**Type:** `LuaEntity` _(read-only)_

The [LuaEntity](runtime:LuaEntity) owner of this LuaLogisticPoint.

### sections

**Type:** ``LuaLogisticSection`[]` _(read-only)_

All logistic sections of this logistic point.

### sections_count

**Type:** `uint` _(read-only)_

Amount of logistic sections this logistic point has.

### targeted_items_deliver

**Type:** ``ItemWithQualityCounts`[]` _(read-only)_

Items targeted to be dropped off into this logistic point by robots.

### targeted_items_pickup

**Type:** ``ItemWithQualityCounts`[]` _(read-only)_

Items targeted to be picked up from this logistic point by robots.

### trash_not_requested

**Type:** `boolean`

Whether this logistic point is set to trash unrequested items.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

