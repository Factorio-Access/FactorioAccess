# TipsAndTricksItem

A tips and tricks entry.

**Parent:** `PrototypeBase`

## Properties

### Optional Properties

#### category

**Type:** `string`

Name of a [TipsAndTricksItemCategory](prototype:TipsAndTricksItemCategory), used for the sorting of this tips and tricks entry. Tips and trick entries are sorted first by category and then by their `order` within that category.

**Default:** `the `name` of this prototype`

#### dependencies

**Type:** ``string`[]`

An array of names of other tips and tricks items. This tips and tricks entry is only shown to the player once they have marked all dependencies as read.

**Default:** `none`

#### icon

**Type:** `FileName`

Path to the icon file.

Only loaded if `icons` is not defined.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

Can't be an empty array.

#### image

**Type:** `FileName`



**Default:** `{'complex_type': 'literal', 'value': ''}`

#### indent

**Type:** `uint8`

The tips and tricks entry is indented by `indent`×6 spaces.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### is_title

**Type:** `boolean`

Whether the tip title on the left in the tips and tricks GUI should use the "title_tip_item" style (semi bold font).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### order

**Type:** `Order`

Used to order prototypes in inventory, recipes and GUIs. May not exceed a length of 200 characters.

**Default:** `Value of `name``

#### player_input_method_filter

**Type:** `PlayerInputMethodFilter`



**Default:** `{'complex_type': 'literal', 'value': 'all'}`

#### simulation

**Type:** `SimulationDefinition`



#### skip_trigger

**Type:** `TipTrigger`

Condition for never showing the tip notification to the player.

#### starting_status

**Type:** `TipStatus`



**Default:** `{'complex_type': 'literal', 'value': 'locked'}`

#### tag

**Type:** `string`

String to add in front of the tips and trick entries name. Can be anything, the base game tends to use [rich text](https://wiki.factorio.com/Rich_text) tags for items, e.g. `[item=wooden-chest]` here.

**Default:** `{'complex_type': 'literal', 'value': ''}`

#### trigger

**Type:** `TipTrigger`

Condition for when the tip notification should be shown to the player.

#### tutorial

**Type:** `string`

Name of a [TutorialDefinition](prototype:TutorialDefinition).

**Default:** `{'complex_type': 'literal', 'value': ''}`

