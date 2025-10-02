# TilePrototype

A [tile](https://wiki.factorio.com/Tile).

**Parent:** [Prototype](Prototype.md)
**Type name:** `tile`
**Instance limit:** 65535

## Properties

### collision_mask

**Type:** `CollisionMaskConnector`

**Required:** Yes

### layer

Specifies transition drawing priority.

**Type:** `uint8`

**Required:** Yes

### build_animations

The build animation used when this tile is built on a space platform.

**Type:** `Animation4Way`

**Optional:** Yes

### build_animations_background

**Type:** `Animation4Way`

**Optional:** Yes

### built_animation_frame

When the build_animations frame reaches this point the tile is built.

Mandatory if `build_animations` is defined.

**Type:** `uint32`

**Optional:** Yes

### variants

Graphics for this tile.

**Type:** `TileTransitionsVariants`

**Required:** Yes

### map_color

**Type:** `Color`

**Required:** Yes

### icons

Can't be an empty array. If this and `icon` is not set, the `material_background` in `variants` is used as the icon.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file. If this and `icons` is not set, the `material_background` in `variants` is used as the icon.

Only loaded if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### lowland_fog

For surfaces that use [fog effect](prototype:SurfaceRenderParameters::fog) of type `gleba`, this property determines whether given tile should contribute to fog intensity on a chunk or not.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### transition_overlay_layer_offset

**Type:** `int8`

**Optional:** Yes

**Default:** 0

### sprite_usage_surface

**Type:** `SpriteUsageSurfaceHint`

**Optional:** Yes

**Default:** "any"

### layer_group

**Type:** `TileRenderLayer`

**Optional:** Yes

**Default:** "ground-natural"

### transition_merges_with_tile

**Type:** `TileID`

**Optional:** Yes

### effect_color

**Type:** `Color`

**Optional:** Yes

**Default:** "`{r=1, g=1, b=1, a=1} (white)`"

### tint

**Type:** `Color`

**Optional:** Yes

**Default:** "`{r=1, g=1, b=1, a=1} (white)`"

### particle_tints

**Type:** `TileBasedParticleTints`

**Optional:** Yes

### walking_sound

**Type:** `Sound`

**Optional:** Yes

### landing_steps_sound

**Type:** `Sound`

**Optional:** Yes

### driving_sound

**Type:** `InterruptibleSound`

**Optional:** Yes

### build_sound

If this is loaded as one Sound, it is loaded as the "small" build sound.

**Type:** `Sound` | `TileBuildSound`

**Optional:** Yes

### mined_sound

**Type:** `Sound`

**Optional:** Yes

### walking_speed_modifier

**Type:** `double`

**Optional:** Yes

**Default:** 1

### vehicle_friction_modifier

**Type:** `double`

**Optional:** Yes

**Default:** 1

### decorative_removal_probability

**Type:** `float`

**Optional:** Yes

**Default:** 0.0

### allowed_neighbors

Array of tile names that are allowed next to this one.

**Type:** Array[`TileID`]

**Optional:** Yes

**Default:** "All tiles"

### needs_correction

Whether the tile needs tile correction logic applied when it's generated in the world, to prevent graphical artifacts. The tile correction logic disallows 1-wide stripes of the tile, see [Friday Facts #346](https://factorio.com/blog/post/fff-346).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### minable

If you want the tile to not be mineable, don't specify the minable property. Only non-mineable tiles become hidden tiles when placing mineable tiles on top of them.

**Type:** `MinableProperties`

**Optional:** Yes

### fluid

**Type:** `FluidID`

**Optional:** Yes

### next_direction

**Type:** `TileID`

**Optional:** Yes

### can_be_part_of_blueprint

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### is_foundation

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### destroys_dropped_items

If items dropped on this tile are destroyed.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### allows_being_covered

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### searchable

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### max_health

Must be equal to or greater than 0.

**Type:** `float`

**Optional:** Yes

**Default:** 0

### weight

**Type:** `Weight`

**Optional:** Yes

**Default:** 0

### dying_explosion

Triggers when a foundation tile is destroyed by an asteroid.

**Type:** `ExplosionDefinition` | Array[`ExplosionDefinition`]

**Optional:** Yes

### absorptions_per_second

**Type:** Dictionary[`AirbornePollutantID`, `double`]

**Optional:** Yes

### default_cover_tile

**Type:** `TileID`

**Optional:** Yes

### frozen_variant

**Type:** `TileID`

**Optional:** Yes

### thawed_variant

**Type:** `TileID`

**Optional:** Yes

### effect

**Type:** `TileEffectDefinitionID`

**Optional:** Yes

### trigger_effect

Called by [InvokeTileEffectTriggerEffectItem](prototype:InvokeTileEffectTriggerEffectItem).

**Type:** `TriggerEffect`

**Optional:** Yes

### default_destroyed_dropped_item_trigger

The effect/trigger that runs when an item is destroyed by being dropped on this tile.

If the item defines [its own trigger](prototype:ItemPrototype::destroyed_by_dropping_trigger) it will override this.

If this is defined, `destroys_dropped_items` must be `true`.

**Type:** `Trigger`

**Optional:** Yes

### scorch_mark_color

**Type:** `Color`

**Optional:** Yes

### check_collision_with_entities

If set to true, the game will check for collisions with entities before building or mining the tile. If entities are in the way it is not possible to mine/build the tile.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### effect_color_secondary

Used by the [pollution](https://wiki.factorio.com/Pollution) shader.

**Type:** `Color`

**Optional:** Yes

### effect_is_opaque

**Type:** `boolean`

**Optional:** Yes

**Default:** "true if `effect_color` alpha equals 1"

### transitions

Extra transitions.

**Type:** Array[`TileTransitionsToTiles`]

**Optional:** Yes

### transitions_between_transitions

**Type:** Array[`TileTransitionsBetweenTransitions`]

**Optional:** Yes

### autoplace

**Type:** `AutoplaceSpecification`

**Optional:** Yes

### placeable_by

**Type:** `ItemToPlace` | Array[`ItemToPlace`]

**Optional:** Yes

### bound_decoratives

**Type:** `DecorativeID` | Array[`DecorativeID`]

**Optional:** Yes

### ambient_sounds_group

**Type:** `TileID`

**Optional:** Yes

### ambient_sounds

**Type:** `WorldAmbientSoundDefinition` | Array[`WorldAmbientSoundDefinition`]

**Optional:** Yes

