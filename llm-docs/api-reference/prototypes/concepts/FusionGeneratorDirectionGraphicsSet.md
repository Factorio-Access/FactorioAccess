# FusionGeneratorDirectionGraphicsSet

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### animation

**Type:** `Animation`

**Optional:** Yes

### working_light

**Type:** `Animation`

**Optional:** Yes

### fusion_effect_uv_map

**Type:** `Sprite`

**Optional:** Yes

### fluid_input_graphics

The amount of items in this array has to match the amount of [input fluid connections](prototype:FusionGeneratorPrototype::input_fluid_box). Empty tables can be used as items to fulfill this requirement without defining graphics.

**Type:** Array[`FusionGeneratorFluidInputGraphics`]

**Optional:** Yes

