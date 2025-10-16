# TreeVariation

Tree has number of "dying" stages, which is deduced from frame count of `shadow` if shadow is defined, otherwise from frame count of `trunk`. Frame count of `leaves` has to be one less than deduced number stages, as last stage is always assumed to be leafless.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### trunk

If `shadow` is not specified, this has to have one more frame than `leaves`.

**Type:** `Animation`

**Required:** Yes

### leaves

**Type:** `Animation`

**Required:** Yes

### leaf_generation

**Type:** `CreateParticleTriggerEffectItem`

**Required:** Yes

### branch_generation

**Type:** `CreateParticleTriggerEffectItem`

**Required:** Yes

### shadow

Shadow must have 1 more `frame_count` than `leaves`.

**Type:** `Animation`

**Optional:** Yes

### disable_shadow_distortion_beginning_at_frame

Only loaded if `shadow` is present. Defaults to `shadow.frame_count - 1`.

**Type:** `uint32`

**Optional:** Yes

### normal

Normal must have the same frame_count as `leaves`.

**Type:** `Animation`

**Optional:** Yes

### overlay

Overlay must have the same frame_count as `leaves`. Won't be tinted by the tree color unless `apply_runtime_tint` is set to `true` in the sprite definition. See [here](https://forums.factorio.com/viewtopic.php?p=547758#p547758).

**Type:** `Animation`

**Optional:** Yes

### underwater

**Type:** `Animation`

**Optional:** Yes

### underwater_layer_offset

**Type:** `int8`

**Optional:** Yes

**Default:** 1

### leaves_when_mined_manually

**Type:** `uint8`

**Optional:** Yes

**Default:** 40

### leaves_when_mined_automatically

**Type:** `uint8`

**Optional:** Yes

**Default:** 20

### leaves_when_damaged

This value is multiplied with the percent of health lost.

**Type:** `uint8`

**Optional:** Yes

**Default:** 200

### leaves_when_destroyed

**Type:** `uint8`

**Optional:** Yes

**Default:** 40

### branches_when_mined_manually

**Type:** `uint8`

**Optional:** Yes

**Default:** 15

### branches_when_mined_automatically

**Type:** `uint8`

**Optional:** Yes

**Default:** 8

### branches_when_damaged

This value is multiplied with the percent of health lost.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### branches_when_destroyed

**Type:** `uint8`

**Optional:** Yes

**Default:** 15

### water_reflection

**Type:** `WaterReflectionDefinition`

**Optional:** Yes

