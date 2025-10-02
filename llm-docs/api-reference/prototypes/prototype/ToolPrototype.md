# ToolPrototype

Items with a "durability". Used for [science packs](https://wiki.factorio.com/Science_pack).

**Parent:** [ItemPrototype](ItemPrototype.md)
**Type name:** `tool`

## Properties

### durability

The durability of this tool. Must be positive. Mandatory if `infinite` is false. Ignored if <code>infinite</code> is true.

**Type:** `double`

**Optional:** Yes

### durability_description_key

May not be longer than 200 characters.

**Type:** `string`

**Optional:** Yes

### durability_description_value

May not be longer than 200 characters.

In-game, the game provides the locale with three [parameters](https://wiki.factorio.com/Tutorial:Localisation#Localising_with_parameters):

`__1__`: remaining durability

`__2__`: total durability

`__3__`: durability as a percentage

So when a locale key that has the following translation

`Remaining durability is __1__ out of __2__ which is __3__ %`

is applied to a tool with 2 remaining durability out of 8 it will be displayed as

`Remaining durability is 2 out of 8 which is 25 %`

**Type:** `string`

**Optional:** Yes

### infinite

Whether this tool has infinite durability. If this is false, `durability` must be specified.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

