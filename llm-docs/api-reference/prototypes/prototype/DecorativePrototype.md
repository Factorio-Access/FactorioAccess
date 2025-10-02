# DecorativePrototype

Simple decorative purpose objects on the map, they have no health and some of them are removed when the player builds over. Usually used for grass patches, roots, small plants etc.

**Parent:** [Prototype](Prototype.md)
**Type name:** `optimized-decorative`
**Instance limit:** 65535

## Properties

### pictures

Must contain at least 1 picture.

**Type:** `SpriteVariations`

**Required:** Yes

### stateless_visualisation

Can be defined only when decorative is not "decal" (see `render_layer`).

**Type:** `StatelessVisualisations`

**Optional:** Yes

### stateless_visualisation_variations

Only loaded if `stateless_visualisation` is not defined. Can be defined only when decorative is not "decal" (see `render_layer`).

**Type:** Array[`StatelessVisualisations`]

**Optional:** Yes

### collision_box

Must contain the [0,0] point. Max radius of the collision box is 8.

**Type:** `BoundingBox`

**Optional:** Yes

### render_layer

When "decals" render layer is used, the decorative is treated as decal. That means it will be rendered within tile layers instead of normal sprite layers.

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "decorative"

### grows_through_rail_path

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### opacity_over_water

Loaded only if `render_layer` = "decals". Value lower than 1 enables masking by water for decals with `tile_layer` greater or equal to [UtilityConstants::capture_water_mask_at_layer](prototype:UtilityConstants::capture_water_mask_at_layer). Water tiles must use water `tile-effect` with [WaterTileEffectParameters::lightmap_alpha](prototype:WaterTileEffectParameters::lightmap_alpha) set to 0 or value less than 1. Graphics option `Occlude light sprites` must be enabled, as water mask is captured into terrain lightmap alpha channel. Tiles rendered in layer between [UtilityConstants::capture_water_mask_at_layer](prototype:UtilityConstants::capture_water_mask_at_layer) and decal's `tile_layer` will likely also mask decals in some way, as water mask will likely be 0 at their position, but this is considered undefined behavior.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### tile_layer

Mandatory if `render_layer` = "decals". This int16 is converted to a [TileRenderLayer](prototype:TileRenderLayer) internally. It is offset from `ground-natural`.

**Type:** `int16`

**Optional:** Yes

**Default:** 0

### decal_overdraw_priority

Loaded only if `render_layer` = "decals". When decoratives are being spawned by [EnemySpawnerPrototype::spawn_decoration](prototype:EnemySpawnerPrototype::spawn_decoration) or [TurretPrototype::spawn_decoration](prototype:TurretPrototype::spawn_decoration), decals with `decal_overdraw_priority` greater than 0 will be filtered such that they don't overlap too much. If two or more decals would overlap, only the one with the largest value of `decal_overdraw_priority` is placed.

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### collision_mask

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"decorative"`.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### walking_sound

**Type:** `Sound`

**Optional:** Yes

### trigger_effect

Called by [DestroyDecorativesTriggerEffectItem](prototype:DestroyDecorativesTriggerEffectItem).

**Type:** `TriggerEffect`

**Optional:** Yes

### minimal_separation

**Type:** `double`

**Optional:** Yes

**Default:** 0.0

### target_count

**Type:** `uint16`

**Optional:** Yes

**Default:** 0

### placed_effect

**Type:** `TriggerEffect`

**Optional:** Yes

### autoplace

**Type:** `AutoplaceSpecification`

**Optional:** Yes

