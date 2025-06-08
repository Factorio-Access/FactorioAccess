# DecorativePrototype

Simple decorative purpose objects on the map, they have no health and some of them are removed when the player builds over. Usually used for grass patches, roots, small plants etc.

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### pictures

**Type:** `SpriteVariations`

Must contain at least 1 picture.

### Optional Properties

#### autoplace

**Type:** `AutoplaceSpecification`



#### collision_box

**Type:** `BoundingBox`

Must contain the [0,0] point. Max radius of the collision box is 8.

#### collision_mask

**Type:** `CollisionMaskConnector`

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by `"decorative"`.

#### decal_overdraw_priority

**Type:** `uint16`

Loaded only if `render_layer` = "decals". When decoratives are being spawned by [EnemySpawnerPrototype::spawn_decoration](prototype:EnemySpawnerPrototype::spawn_decoration) or [TurretPrototype::spawn_decoration](prototype:TurretPrototype::spawn_decoration), decals with `decal_overdraw_priority` greater than 0 will be filtered such that they don't overlap too much. If two or more decals would overlap, only the one with the largest value of `decal_overdraw_priority` is placed.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### grows_through_rail_path

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### minimal_separation

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### opacity_over_water

**Type:** `float`

Loaded only if `render_layer` = "decals". Value lower than 1 enables masking by water for decals with `tile_layer` greater or equal to [UtilityConstants::capture_water_mask_at_layer](prototype:UtilityConstants::capture_water_mask_at_layer). Water tiles must use water `tile-effect` with [WaterTileEffectParameters::lightmap_alpha](prototype:WaterTileEffectParameters::lightmap_alpha) set to 0 or value less than 1. Graphics option `Occlude light sprites` must be enabled, as water mask is captured into terrain lightmap alpha channel. Tiles rendered in layer between [UtilityConstants::capture_water_mask_at_layer](prototype:UtilityConstants::capture_water_mask_at_layer) and decal's `tile_layer` will likely also mask decals in some way, as water mask will likely be 0 at their position, but this is considered undefined behavior.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### placed_effect

**Type:** `TriggerEffect`



#### render_layer

**Type:** `RenderLayer`

When "decals" render layer is used, the decorative is treated as decal. That means it will be rendered within tile layers instead of normal sprite layers.

**Default:** `{'complex_type': 'literal', 'value': 'decorative'}`

#### stateless_visualisation

**Type:** `StatelessVisualisations`

Can be defined only when decorative is not "decal" (see `render_layer`).

#### stateless_visualisation_variations

**Type:** ``StatelessVisualisations`[]`

Only loaded if `stateless_visualisation` is not defined. Can be defined only when decorative is not "decal" (see `render_layer`).

#### target_count

**Type:** `uint16`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### tile_layer

**Type:** `int16`

Mandatory if `render_layer` = "decals". This int16 is converted to a [TileRenderLayer](prototype:TileRenderLayer) internally. It is offset from `ground-natural`.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### trigger_effect

**Type:** `TriggerEffect`

Called by [DestroyDecorativesTriggerEffectItem](prototype:DestroyDecorativesTriggerEffectItem).

#### walking_sound

**Type:** `Sound`



