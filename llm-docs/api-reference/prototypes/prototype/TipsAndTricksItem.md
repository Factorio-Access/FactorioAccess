# TipsAndTricksItem

A tips and tricks entry.

**Parent:** [PrototypeBase](PrototypeBase.md)
**Type name:** `tips-and-tricks-item`

## Properties

### image

**Type:** `FileName`

**Optional:** Yes

**Default:** ""

### simulation

**Type:** `SimulationDefinition`

**Optional:** Yes

### tag

String to add in front of the tips and trick entries name. Can be anything, the base game tends to use [rich text](https://wiki.factorio.com/Rich_text) tags for items, e.g. `[item=wooden-chest]` here.

**Type:** `string`

**Optional:** Yes

**Default:** ""

### category

Name of a [TipsAndTricksItemCategory](prototype:TipsAndTricksItemCategory), used for the sorting of this tips and tricks entry. Tips and trick entries are sorted first by category and then by their `order` within that category.

**Type:** `string`

**Optional:** Yes

**Default:** "the `name` of this prototype"

### indent

The tips and tricks entry is indented by `indent`×6 spaces.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### is_title

Whether the tip title on the left in the tips and tricks GUI should use the "title_tip_item" style (semi bold font).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### trigger

Condition for when the tip notification should be shown to the player.

**Type:** `TipTrigger`

**Optional:** Yes

### skip_trigger

Condition for never showing the tip notification to the player.

**Type:** `TipTrigger`

**Optional:** Yes

### tutorial

Name of a [TutorialDefinition](prototype:TutorialDefinition).

**Type:** `string`

**Optional:** Yes

**Default:** ""

### starting_status

**Type:** `TipStatus`

**Optional:** Yes

**Default:** "locked"

### dependencies

An array of names of other tips and tricks items. This tips and tricks entry is only shown to the player once they have marked all dependencies as read.

**Type:** Array[`string`]

**Optional:** Yes

**Default:** "none"

### player_input_method_filter

**Type:** `PlayerInputMethodFilter`

**Optional:** Yes

**Default:** "all"

### icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file.

Only loaded if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### order

Used to order prototypes in inventory, recipes and GUIs. May not exceed a length of 200 characters.

**Type:** `Order`

**Optional:** Yes

**Default:** "Value of `name`"

**Overrides parent:** Yes

