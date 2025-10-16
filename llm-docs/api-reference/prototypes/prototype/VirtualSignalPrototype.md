# VirtualSignalPrototype

A [virtual signal](https://wiki.factorio.com/Circuit_network#Virtual_signals).

**Parent:** [Prototype](Prototype.md)
**Type name:** `virtual-signal`

## Properties

### icons

The icon that is used to represent this virtual signal. Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file that is used to represent this virtual signal.

Only loaded, and mandatory if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

