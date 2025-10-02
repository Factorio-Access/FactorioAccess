# BeaconGraphicsSet

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### draw_animation_when_idle

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_light_when_idle

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### random_animation_offset

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### module_icons_suppressed

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### reset_animation_when_frozen

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### base_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### animation_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### top_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### animation_progress

**Type:** `float`

**Optional:** Yes

**Default:** 1

### apply_module_tint

Which tint set in [ModulePrototype::beacon_tint](prototype:ModulePrototype::beacon_tint) should be applied to elements of the `animation_list`, if any.

**Type:** `ModuleTint`

**Optional:** Yes

**Default:** "none"

### no_modules_tint

**Type:** `Color`

**Optional:** Yes

**Default:** "no color"

### animation_list

**Type:** Array[`AnimationElement`]

**Optional:** Yes

### frozen_patch

**Type:** `Sprite`

**Optional:** Yes

### light

**Type:** `LightDefinition`

**Optional:** Yes

### module_visualisations

The visualisations available for displaying the modules in the beacon. The visualisation is chosen based on art style, see [BeaconModuleVisualizations::art_style](prototype:BeaconModuleVisualizations::art_style) and [ModulePrototype::art_style](prototype:ModulePrototype::art_style).

**Type:** Array[`BeaconModuleVisualizations`]

**Optional:** Yes

### module_tint_mode

**Type:** `"single-module"` | `"mix"`

**Optional:** Yes

**Default:** "single-module"

