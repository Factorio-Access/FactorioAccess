# LuaGui

The root of the GUI. This type houses the root elements, `top`, `left`, `center`,  `goal`, and `screen`, to which other elements can be added to be displayed on screen.

Every player can have a different GUI state.

## Attributes

### player

The player who owns this gui.

**Read type:** `LuaPlayer`

### children

The children GUI elements mapped by name <> element.

**Read type:** Dictionary[`string`, `LuaGuiElement`]

### top

The top part of the GUI. It is a flow element inside a scroll pane element.

**Read type:** `LuaGuiElement`

### left

The left part of the GUI. It is a flow element inside a scroll pane element.

**Read type:** `LuaGuiElement`

### center

The center part of the GUI. It is a flow element.

**Read type:** `LuaGuiElement`

### goal

The flow used in the objectives window. It is a flow element. The objectives window is only visible when the flow is not empty or the objective text is set.

**Read type:** `LuaGuiElement`

### screen

For showing a GUI somewhere on the entire screen. It is an empty-widget element.

**Read type:** `LuaGuiElement`

### relative

For showing a GUI somewhere relative to one of the game GUIs. It is an empty-widget element.

**Read type:** `LuaGuiElement`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

