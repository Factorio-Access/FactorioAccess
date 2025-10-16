# CoverGraphicProcessionLayer

Draws a layer of cloud texture covering the screen. It can fade in an out based on opacity and using the picture mask as gradient of areas which fade in soon or later.

There are two important concepts to understand:

- `mask` refers to something like a depth texture. It is applied across the whole screen and determines how the entire graphic fades in and out.

- `effect` in this context refers to clipping out portion of the cover graphic. It can use an effect_graphic. `is_cloud_effect_advanced` makes the `effect` modify opacity threshold of the `mask` rather than multiplying alpha.

Additionally an area can be masked out by range or effect mask.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"cover-graphic"`

**Required:** Yes

### reference_group

The group this layer belongs to, for inheritance.

**Type:** `ProcessionLayerInheritanceGroupID`

**Optional:** Yes

### inherit_from

Adds the final position value from given layer to this one.

**Type:** `ProcessionLayerInheritanceGroupID`

**Optional:** Yes

### graphic

Main texture of the layer.

**Type:** `ProcessionGraphic`

**Optional:** Yes

### mask_graphic

Opacity gradient of the layer.

**Type:** `ProcessionGraphic`

**Optional:** Yes

### effect_graphic

Used by certain effects.

**Type:** `ProcessionGraphic`

**Optional:** Yes

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### secondary_draw_order

**Type:** `int8`

**Optional:** Yes

**Default:** 0

### is_cloud_effect_advanced

Advanced cloud effect mask modifies the regular mask thresholds instead of being a flat multiplication of the resulting opacity.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### is_quad_texture

The texture and mask are interpreted as four smaller textures that are randomly tiled.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### rotate_with_pod

Add rotation of the pod to the cloud rotation.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### texture_relative_to

Where the tiled texture is centered and rotated.

**Type:** `EffectRelativeTo`

**Optional:** Yes

**Default:** "ground-origin"

### distance_traveled_strength

How much the pod's distance traveled moves the cloud coordinates

**Type:** `Vector`

**Optional:** Yes

**Default:** "{0,0}"

### pod_movement_strength

How much the pod's position moves the cloud coordinates

**Type:** `Vector`

**Optional:** Yes

**Default:** "{1,1}"

### world_size

Size the textures are scaled to in the world.

**Type:** `Vector`

**Optional:** Yes

**Default:** "{512, 512}"

### effect

Clips the graphic.

**Type:** `CoverGraphicEffectData`

**Optional:** Yes

### alt_effect

Clips the graphic.

**Type:** `CoverGraphicEffectData`

**Optional:** Yes

### frames

Default values if unspecified:

- opacity : 1.0

- rotation : 0.0

- effect_scale_min : 0.0

- effect_scale_max : 1.0

- effect_shift : {0, 0}

- alt_effect_scale_min : 0.0

- alt_effect_scale_max : 1.0

- alt_effect_shift : {0, 0}

- offset : {0, 0}

**Type:** Array[`CoverGraphicProcessionLayerBezierControlPoint`]

**Required:** Yes

