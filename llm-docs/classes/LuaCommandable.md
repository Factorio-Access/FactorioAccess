# LuaCommandable

AI object which can be ordered commands. This can represent a UnitGroup (a set of multiple commandables) or can be a single Unit, SpiderUnit or other commandable entity.

## Methods

### add_member

Adds a member to this UnitGroup. Has the same effect as setting defines.command.group command on the member to join the group.

The member must have the same force be on the same surface as the group.

**Parameters:**

- `member` : 

### destroy

Destroys this commandable. If it is a unit group, members will not be destroyed, they will be merely unlinked from the group.

### release_from_spawner

Release the commandable from the spawner. This allows the spawner to continue spawning additional units.

### set_autonomous

Make this group autonomous. Autonomous groups will automatically attack polluted areas. Autonomous groups aren't considered to be [script-driven](runtime:LuaCommandable::is_script_driven).

### set_command

Give this commandable a command.

**Parameters:**

- `command` `Command`: 

### set_distraction_command

Give this commandable a distraction command.

**Parameters:**

- `command` `Command`: 

### start_moving

Make the group start moving even if some of its members haven't yet arrived.

## Attributes

### command

**Type:** `Command` _(read-only)_

The command of this commandable, if any.

### commandable_members

**Type:** ``LuaCommandable`[]` _(read-only)_

Non recursively returns all members of this unit group.

### distraction_command

**Type:** `Command` _(read-only)_

The distraction command of this commandable, if any.

### entity

**Type:** `LuaEntity` _(read-only)_

Returns entity object for this commandable.

### force

**Type:** `LuaForce` _(read-only)_

The force of this commandable.

### has_command

**Type:** `boolean` _(read-only)_

If this commandable has a command assigned.

### is_entity

**Type:** `boolean` _(read-only)_

If this commandable is Entity.

### is_script_driven

**Type:** `boolean` _(read-only)_

Whether this unit group is controlled by a script or by the game engine. This can be changed using [LuaCommandable::set_autonomous](runtime:LuaCommandable::set_autonomous). Units created by [LuaSurface::create_unit_group](runtime:LuaSurface::create_unit_group) are considered script-driven.

### is_unit_group

**Type:** `boolean` _(read-only)_

If this commandable is UnitGroup.

### members

**Type:** ``LuaEntity`[]` _(read-only)_

All entity members of this unit group, recursive (if unit group is member of this unit group, its members will be returned here).

### moving_state

**Type:** `defines.moving_state` _(read-only)_

Current moving state of the commandable's behavior

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### parent_group

**Type:** `LuaCommandable` _(read-only)_

The unit group this commandable is a member of, if any.

### position

**Type:** `MapPosition` _(read-only)_

Current position of this commandable.

If commandable is a UnitGroup, this can have different meanings depending on the group state. When the group is gathering, the position is the place of gathering. When the group is moving, the position is the expected position of its members along the path. When the group is attacking, it is the average position of its members.

### spawner

**Type:** `LuaEntity` _(read-only)_

The spawner associated with this commandable, if any.

### state

**Type:** `defines.group_state` _(read-only)_

Whether this group is gathering, moving or attacking.

### surface

**Type:** `LuaSurface` _(read-only)_

Surface this commandable is on.

### unique_id

**Type:** `uint` _(read-only)_

Unique identifier of this commandable.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

