# LuaLogisticPoint

Logistic point of a particular [LuaEntity](runtime:LuaEntity). A "Logistic point" is the name given for settings and properties used by requester, provider, and storage points in a given logistic network. These "points" don't have to be a logistic container but often are. One other entity that can own several points is the "character" character type entity.

## Attributes

### owner

The [LuaEntity](runtime:LuaEntity) owner of this LuaLogisticPoint.

**Read type:** `LuaEntity`

### logistic_network

**Read type:** `LuaLogisticNetwork`

### logistic_member_index

The Logistic member index of this logistic point.

**Read type:** `defines.logistic_member_index`

### filters

The logistic filters for this logistic point, if this uses any.

The returned array will always have an entry for each filter and will be indexed in sequence when not `nil`.

**Read type:** Array[`CompiledLogisticFilter`]

**Optional:** Yes

### mode

The logistic mode.

**Read type:** `defines.logistic_mode`

### force

The force of this logistic point.

This will always be the same as the [LuaLogisticPoint::owner](runtime:LuaLogisticPoint::owner) force.

**Read type:** `LuaForce`

### targeted_items_pickup

Items targeted to be picked up from this logistic point by robots.

**Read type:** `ItemWithQualityCounts`

### targeted_items_deliver

Items targeted to be dropped off into this logistic point by robots.

**Read type:** `ItemWithQualityCounts`

### exact

If this logistic point is using the exact mode. In exact mode robots never over-deliver requests.

**Read type:** `boolean`

### trash_not_requested

Whether this logistic point is set to trash unrequested items.

**Read type:** `boolean`

**Write type:** `boolean`

### enabled

Whether this logistic point is active, related to disabling logistics on player/spidertron.

When the logistic point is disabled it won't request and auto trash will do nothing.

**Read type:** `boolean`

**Write type:** `boolean`

### sections

All logistic sections of this logistic point.

**Read type:** Array[`LuaLogisticSection`]

### sections_count

Amount of logistic sections this logistic point has.

**Read type:** `uint32`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### add_section

Adds a new logistic section to this logistic point if possible.

**Parameters:**

- `group` `string` *(optional)* - The group to assign this section to.

**Returns:**

- `LuaLogisticSection` *(optional)* - The added logistic section.

### remove_section

Removes the given logistic section if possible. Removal may fail if the section index is out of range or the section is not [manual](runtime:LuaLogisticSection::is_manual).

**Parameters:**

- `section_index` `uint32` - Index of the section

**Returns:**

- `boolean` - Whether section was removed.

### get_section

Gets section on the selected index, if it exists

**Parameters:**

- `section_index` `uint32` - Index of the section

**Returns:**

- `LuaLogisticSection`

