# LuaRemote

Registry of interfaces between scripts. An interface is simply a dictionary mapping names to functions. A script or mod can then register an interface with [LuaRemote](runtime:LuaRemote), after that any script can call the registered functions, provided it knows the interface name and the desired function name. An instance of LuaRemote is available through the global object named `remote`.

## Attributes

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

### interfaces

List of all registered interfaces. For each interface name, `remote.interfaces[name]` is a dictionary mapping the interface's registered functions to `true`.

**Read type:** Dictionary[`string`, Dictionary[`string`, `True`]]

## Methods

### add_interface

Add a remote interface.

**Parameters:**

- `functions` Dictionary[`string`, function()] - List of functions that are members of the new interface.
- `name` `string` - Name of the interface. If the name matches any existing interface, an error is thrown.

### remove_interface

Removes an interface with the given name.

**Parameters:**

- `name` `string` - Name of the interface.

**Returns:**

- `boolean` - Whether the interface was removed. `false` if the interface didn't exist.

### call

Call a function of an interface.

Providing an unknown interface or function name will result in a script error.

**Parameters:**

- `function` `string` - Function name that belongs to the `interface`.
- `interface` `string` - Interface to look up `function` in.

**Returns:**

- `Any` *(optional)*

