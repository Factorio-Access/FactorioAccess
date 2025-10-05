# LuaCommandable

AI object which can be ordered commands. This can represent a UnitGroup (a set of multiple commandables) or can be a single Unit or SpiderUnit.

## Attributes

### is_unit_group

If this commandable is UnitGroup.

**Read type:** `boolean`

### is_entity

If this commandable is Entity.

**Read type:** `boolean`

### surface

Surface this commandable is on.

**Read type:** `LuaSurface`

### position

Current position of this commandable.

If commandable is a UnitGroup, this can have different meanings depending on the group state. When the group is gathering, the position is the place of gathering. When the group is moving, the position is the expected position of its members along the path. When the group is attacking, it is the average position of its members.

**Read type:** `MapPosition`

### force

The force of this commandable.

**Read type:** `LuaForce`

### unique_id

Unique identifier of this commandable.

**Read type:** `uint32`

### has_command

If this commandable has a command assigned.

**Read type:** `boolean`

### command

The command of this commandable, if any.

**Read type:** `Command`

**Optional:** Yes

### distraction_command

The distraction command of this commandable, if any.

**Read type:** `Command`

**Optional:** Yes

### parent_group

The unit group this commandable is a member of, if any.

**Read type:** `LuaCommandable`

**Optional:** Yes

### spawner

The spawner associated with this commandable, if any.

**Read type:** `LuaEntity`

**Optional:** Yes

### moving_state

Current moving state of the commandable's behavior

**Read type:** `defines.moving_state`

### state

Whether this group is gathering, moving or attacking.

**Read type:** `defines.group_state`

**Subclasses:** UnitGroup

### members

All entity members of this unit group, recursive (if unit group is member of this unit group, its members will be returned here).

**Read type:** Array[`LuaEntity`]

**Subclasses:** UnitGroup

### commandable_members

Non recursively returns all members of this unit group.

**Read type:** Array[`LuaCommandable`]

**Subclasses:** UnitGroup

### is_script_driven

Whether this unit group is controlled by a script or by the game engine. This can be changed using [LuaCommandable::set_autonomous](runtime:LuaCommandable::set_autonomous). Units created by [LuaSurface::create_unit_group](runtime:LuaSurface::create_unit_group) are considered script-driven.

**Read type:** `boolean`

**Subclasses:** UnitGroup

### entity

Returns entity object for this commandable.

**Read type:** `LuaEntity`

**Subclasses:** Entity

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### destroy

Destroys this commandable. If it is a unit group, members will not be destroyed, they will be merely unlinked from the group.

### set_command

Give this commandable a command.

**Parameters:**

- `command` `Command`

### set_distraction_command

Give this commandable a distraction command.

**Parameters:**

- `command` `Command`

### release_from_spawner

Release the commandable from the spawner. This allows the spawner to continue spawning additional units.

### add_member

Adds a member to this UnitGroup. Has the same effect as setting defines.command.group command on the member to join the group.

The member must have the same force be on the same surface as the group.

**Parameters:**

- `member` `LuaCommandable` | `LuaEntity`

### set_autonomous

Make this group autonomous. Autonomous groups will automatically attack polluted areas. Autonomous groups aren't considered to be [script-driven](runtime:LuaCommandable::is_script_driven).

### start_moving

Make the group start moving even if some of its members haven't yet arrived.

