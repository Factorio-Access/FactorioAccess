# CharacterCorpsePrototype

The corpse of a [CharacterPrototype](prototype:CharacterPrototype).

**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### time_to_live

**Type:** `uint32`

0 for infinite.

### Optional Properties

#### armor_picture_mapping

**Type:** `dictionary<`ItemID`, `int32`>`

Table of key value pairs, the keys are armor names and the values are numbers. The number is the Animation that is associated with the armor, e.g. using `1` will associate the armor with the first Animation in the pictures table.

#### picture

**Type:** `Animation`

Mandatory if `pictures` is not defined.

#### pictures

**Type:** `AnimationVariations`

Mandatory if `picture` is not defined.

#### render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

