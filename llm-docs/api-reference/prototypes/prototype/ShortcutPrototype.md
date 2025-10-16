# ShortcutPrototype

Definition for a shortcut button in the [shortcut bar](https://wiki.factorio.com/Shortcut_bar).

This is **not** a custom keybinding (keyboard shortcut), for that see [CustomInputPrototype](prototype:CustomInputPrototype).

**Parent:** [Prototype](Prototype.md)
**Type name:** `shortcut`

## Examples

```
{
  type = "shortcut",
  name = "give-deconstruction-planner",
  order = "b[blueprints]-i[deconstruction-planner]",
  action = "spawn-item",
  localised_name = {"shortcut.make-deconstruction-planner"},
  associated_control_input = "give-deconstruction-planner",
  technology_to_unlock = "construction-robotics",
  item_to_spawn = "deconstruction-planner",
  style = "red",
  icon = "__base__/graphics/icons/shortcut-toolbar/mip/new-deconstruction-planner-x56.png",
  icon_size = 56,
  small_icon = "__base__/graphics/icons/shortcut-toolbar/mip/new-deconstruction-planner-x24.png",
  small_icon_size = 24
}
```

## Properties

### action

If this is `"lua"`, [on_lua_shortcut](runtime:on_lua_shortcut) is raised when the shortcut is clicked.

**Type:** `"toggle-alt-mode"` | `"undo"` | `"redo"` | `"paste"` | `"import-string"` | `"toggle-personal-roboport"` | `"toggle-personal-logistic-requests"` | `"toggle-equipment-movement-bonus"` | `"spawn-item"` | `"lua"`

**Required:** Yes

### icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file.

Only loaded, and mandatory if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

The base game uses 32px icons for shortcuts.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### small_icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### small_icon

Path to the icon file. Used in the shortcut selection popup.

Only loaded, and mandatory if `small_icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### small_icon_size

The size of the small icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

The base game uses 24px small icons for shortcuts.

Only loaded if `small_icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### item_to_spawn

The item to create when clicking on a shortcut with the action set to `"spawn-item"`. The item must have the [spawnable](prototype:ItemPrototypeFlags::spawnable) flag set.

**Type:** `ItemID`

**Optional:** Yes

### technology_to_unlock

The technology that must be researched before this shortcut can be used. Once a shortcut is unlocked in one save file, it is unlocked for all future save files.

**Type:** `TechnologyID`

**Optional:** Yes

### unavailable_until_unlocked

If `true`, the shortcut will not be available until its `technology_to_unlock` is researched, even if it was already researched in a different game.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### toggleable

Must be enabled for the Factorio API to be able to set the toggled state on the shortcut button, see [LuaPlayer::set_shortcut_toggled](runtime:LuaPlayer::set_shortcut_toggled).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### associated_control_input

Name of a custom input or vanilla control. This is **only** used to show the keybind in the tooltip of the shortcut.

**Type:** `string`

**Optional:** Yes

**Default:** ""

### style

**Type:** `"default"` | `"blue"` | `"red"` | `"green"`

**Optional:** Yes

**Default:** "default"

### order

Used to order the shortcuts in the [quick panel](https://wiki.factorio.com/Quick_panel), which replaces the shortcut bar when using a controller (game pad). It [is recommended](https://forums.factorio.com/106661) to order modded shortcuts after the vanilla shortcuts.

**Type:** `Order`

**Optional:** Yes

**Default:** ""

**Overrides parent:** Yes

