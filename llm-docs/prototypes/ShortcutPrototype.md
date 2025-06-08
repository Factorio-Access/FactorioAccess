# ShortcutPrototype

Definition for a shortcut button in the [shortcut bar](https://wiki.factorio.com/Shortcut_bar).

This is **not** a custom keybinding (keyboard shortcut), for that see [CustomInputPrototype](prototype:CustomInputPrototype).

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### action

**Type:** 

If this is `"lua"`, [on_lua_shortcut](runtime:on_lua_shortcut) is raised when the shortcut is clicked.

### Optional Properties

#### associated_control_input

**Type:** `string`

Name of a custom input or vanilla control. This is **only** used to show the keybind in the tooltip of the shortcut.

**Default:** `{'complex_type': 'literal', 'value': ''}`

#### icon

**Type:** `FileName`

Path to the icon file.

Mandatory if `icons` is not defined.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

The base game uses 32px icons for shortcuts.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

Can't be an empty array.

#### item_to_spawn

**Type:** `ItemID`

The item to create when clicking on a shortcut with the action set to `"spawn-item"`. The item must have the [spawnable](prototype:ItemPrototypeFlags::spawnable) flag set.

#### order

**Type:** `Order`

Used to order the shortcuts in the [quick panel](https://wiki.factorio.com/Quick_panel), which replaces the shortcut bar when using a controller (game pad). It [is recommended](https://forums.factorio.com/106661) to order modded shortcuts after the vanilla shortcuts.

**Default:** `{'complex_type': 'literal', 'value': ''}`

#### small_icon

**Type:** `FileName`

Path to the icon file. Used in the shortcut selection popup.

Mandatory if `small_icons` is not defined.

#### small_icon_size

**Type:** `SpriteSizeType`

The size of the small icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

The base game uses 24px small icons for shortcuts.

Only loaded if `small_icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### small_icons

**Type:** ``IconData`[]`

Can't be an empty array.

#### style

**Type:** 



**Default:** `{'complex_type': 'literal', 'value': 'default'}`

#### technology_to_unlock

**Type:** `TechnologyID`

The technology that must be researched before this shortcut can be used. Once a shortcut is unlocked in one save file, it is unlocked for all future save files.

#### toggleable

**Type:** `boolean`

Must be enabled for the Factorio API to be able to set the toggled state on the shortcut button, see [LuaPlayer::set_shortcut_toggled](runtime:LuaPlayer::set_shortcut_toggled).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### unavailable_until_unlocked

**Type:** `boolean`

If `true`, the shortcut will not be available until its `technology_to_unlock` is researched, even if it was already researched in a different game.

**Default:** `{'complex_type': 'literal', 'value': False}`

