# VirtualSignalPrototype

A [virtual signal](https://wiki.factorio.com/Circuit_network#Virtual_signals).

**Parent:** `Prototype`

## Properties

### Optional Properties

#### icon

**Type:** `FileName`

Path to the icon file that is used to represent this virtual signal.

Mandatory if `icons` is not defined.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

The icon that is used to represent this virtual signal. Can't be an empty array.

