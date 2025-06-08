# TilePrototype

A [tile](https://wiki.factorio.com/Tile).

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### collision_mask

**Type:** `CollisionMaskConnector`



#### layer

**Type:** `uint8`

Specifies transition drawing priority.

#### map_color

**Type:** `Color`



#### variants

**Type:** `TileTransitionsVariants`

Graphics for this tile.

### Optional Properties

#### absorptions_per_second

**Type:** `dictionary<`AirbornePollutantID`, `double`>`



#### allowed_neighbors

**Type:** ``TileID`[]`

Array of tile names that are allowed next to this one.

**Default:** `All tiles`

#### allows_being_covered

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### ambient_sounds

**Type:** 



#### ambient_sounds_group

**Type:** `TileID`



#### autoplace

**Type:** `AutoplaceSpecification`



#### bound_decoratives

**Type:** 



#### build_animations

**Type:** `Animation4Way`

The build animation used when this tile is built on a space platform.

#### build_animations_background

**Type:** `Animation4Way`



#### build_sound

**Type:** 

If this is loaded as one Sound, it is loaded as the "small" build sound.

#### built_animation_frame

**Type:** `uint32`

When the build_animations frame reaches this point the tile is built.

Mandatory if `build_animations` is defined.

#### can_be_part_of_blueprint

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### check_collision_with_entities

**Type:** `boolean`

If set to true, the game will check for collisions with entities before building or mining the tile. If entities are in the way it is not possible to mine/build the tile.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### decorative_removal_probability

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### default_cover_tile

**Type:** `TileID`



#### default_destroyed_dropped_item_trigger

**Type:** `Trigger`

The effect/trigger that runs when an item is destroyed by being dropped on this tile.

If the item defines [its own trigger](prototype:ItemPrototype::destroyed_by_dropping_trigger) it will override this.

If this is defined, `destroys_dropped_items` must be `true`.

#### destroys_dropped_items

**Type:** `boolean`

If items dropped on this tile are destroyed.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### driving_sound

**Type:** `Sound`



#### dying_explosion

**Type:** 

Triggers when a foundation tile is destroyed by an asteroid.

#### effect

**Type:** `TileEffectDefinitionID`



#### effect_color

**Type:** `Color`



**Default:** ``{r=1, g=1, b=1, a=1} (white)``

#### effect_color_secondary

**Type:** `Color`

Used by the [pollution](https://wiki.factorio.com/Pollution) shader.

#### effect_is_opaque

**Type:** `boolean`



**Default:** `true if `effect_color` alpha equals 1`

#### fluid

**Type:** `FluidID`



#### frozen_variant

**Type:** `TileID`



#### icon

**Type:** `FileName`

Path to the icon file. If this and `icons` is not set, the `material_background` in `variants` is used as the icon.

Only loaded if `icons` is not defined.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

Can't be an empty array. If this and `icon` is not set, the `material_background` in `variants` is used as the icon.

#### is_foundation

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### landing_steps_sound

**Type:** `Sound`



#### layer_group

**Type:** `TileRenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'ground-natural'}`

#### lowland_fog

**Type:** `boolean`

For surfaces that use [fog effect](prototype:SurfaceRenderParameters::fog) of type `gleba`, this property determines whether given tile should contribute to fog intensity on a chunk or not.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### max_health

**Type:** `float`

Must be equal to or greater than 0.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### minable

**Type:** `MinableProperties`

If you want the tile to not be mineable, don't specify the minable property. Only non-mineable tiles become hidden tiles when placing mineable tiles on top of them.

#### mined_sound

**Type:** `Sound`



#### needs_correction

**Type:** `boolean`

Whether the tile needs tile correction logic applied when it's generated in the world, to prevent graphical artifacts. The tile correction logic disallows 1-wide stripes of the tile, see [Friday Facts #346](https://factorio.com/blog/post/fff-346).

**Default:** `{'complex_type': 'literal', 'value': False}`

#### next_direction

**Type:** `TileID`



#### particle_tints

**Type:** `TileBasedParticleTints`



#### placeable_by

**Type:** 



#### scorch_mark_color

**Type:** `Color`



#### searchable

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### sprite_usage_surface

**Type:** `SpriteUsageSurfaceHint`



**Default:** `{'complex_type': 'literal', 'value': 'any'}`

#### thawed_variant

**Type:** `TileID`



#### tint

**Type:** `Color`



**Default:** ``{r=1, g=1, b=1, a=1} (white)``

#### transition_merges_with_tile

**Type:** `TileID`



#### transition_overlay_layer_offset

**Type:** `int8`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### transitions

**Type:** ``TileTransitionsToTiles`[]`

Extra transitions.

#### transitions_between_transitions

**Type:** ``TileTransitionsBetweenTransitions`[]`



#### trigger_effect

**Type:** `TriggerEffect`

Called by [InvokeTileEffectTriggerEffectItem](prototype:InvokeTileEffectTriggerEffectItem).

#### vehicle_friction_modifier

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### walking_sound

**Type:** `Sound`



#### walking_speed_modifier

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### weight

**Type:** `Weight`



**Default:** `{'complex_type': 'literal', 'value': 0}`

