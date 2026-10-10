# LuaDebugAdapter

Factorio provides a [Debug Adapter](https://microsoft.github.io/debug-adapter-protocol/overview) for compatible tools in single-session mode on stdin/stdout when launched with the `--dap` command line argument.

The Debug Adapter supports a Launch request with the following arguments:

- `factorioArgs` :: array[[string](runtime:string)]? : Command line arguments for the debug session

- `followSymlinks` :: [boolean](runtime:boolean)? : Follow symlinks when emitting locations (stack traces, etc) (default: true)

- `hookDebugConsole` :: [boolean](runtime:boolean)? : Enable catching errors and breakpoints/stepping in code called from the Debug Console (Evaluate context="repl") (default: false)

- `trace` :: [boolean](runtime:boolean)? : Trace DAP messages to a `dap-trace.log` (default: false)

- `tags` :: [Any](runtime:Any)? : Extra debug session tags, see also [tags](runtime:LuaDebugAdapter::tags)

---

For mod objects that appear in debug listing, the following optional metatable methods may be used to customize their display:

- `__tostring`(`self`) -> [string](runtime:string) : Called when the object appears as a value, to format it for inline display.

- `__debugcounts`(`self`) -> `indexedVariables` :: [int32](runtime:int32) , `namedVariables` :: [int32](runtime:int32) : Called when the object appears as a value, to estimate the size of this object's children, and enabled paged listing for large indexed objects. If either count is returned as 0, the client may skip listing that section entirely. If the indexed count is non-zero, the client may choose to request the values in pages. The Indexed count should indicate the highest index present, to properly range paged fetch windows, even if not all keys will be filled when fetched.

- `__debugchildren`(`self`, `filters` :: [DebugVariablesFilter](runtime:DebugVariablesFilter)) -> array([DebugVariable](runtime:DebugVariable)) : Called when the object is expanded to list its children. If `__debugcounts` was implemented, the client may choose to fetch Indexed and Named children sections separately, and Indexed children in 0-based pages on-demand for display. If not all values in the requested page exist (such as a key `0`), they may be omitted from output entirely. See also [describe_field](runtime:LuaDebugAdapter::describe_field).

---

This class also provides debug session APIs, as the global object `debugadapter` in all stages.

## Attributes

### tags

The value from the `tags` property of the current session's launch request

**Read type:** `AnyBasic`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### start_profile

Start recording profiler timings. If there is a previous recording session running, it will be stopped first. This function is also available to the DAP client as the request `startProfile`, with the parameter in `argument`. A DAP event `profileRunning` will be emitted regardless of how it was called.

**Parameters:**

- `show_hook_events` `boolean` *(optional)* - Include events to indicate time spent in hooks

### stop_profile

Stop recording profiler timings and save to script_output. This function is also available to the DAP client as the  request `stopProfile`. A DAP event `profileComplete` will be emitted with the path to the saved file, regardless of stop was called.

### describe_field

Prepare a default debug view entry for a field, to assist in preparing custom listings.

**Parameters:**

- `name` `string` - The name of the field
- `value` `Any` - The value of the field

**Returns:**

- `DebugVariable`

### breakpoint

Pause execution as if a breakpoint was hit.

**Parameters:**

- `mesg` `Any` *(optional)* - If specified, this value is displayed as if it was thrown as an error.

### print

Print values to the debug console. This function also replaces the Lua builtin `print` during debug sessions.

