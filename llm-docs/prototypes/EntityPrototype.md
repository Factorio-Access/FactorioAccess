# EntityPrototype

Abstract base of all entities in the game. Entity is nearly everything that can be on the map (except tiles).

For in game script access to entity, take a look at [LuaEntity](runtime:LuaEntity).

**Parent:** `Prototype`

## Properties

### Optional Properties

#### additional_pastable_entities

**Type:** ``EntityID`[]`

Names of the entity prototypes this entity prototype can be pasted on to in addition to the standard supported types.

This is used to allow copying between types that aren't compatible on the C++ code side, by allowing mods to receive the [on_entity_settings_pasted](runtime:on_entity_settings_pasted) event for the given entity and do the setting pasting via script.

#### alert_icon_scale

**Type:** `float`



#### alert_icon_shift

**Type:** `Vector`



#### allow_copy_paste

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### ambient_sounds

**Type:** 



#### ambient_sounds_group

**Type:** `EntityID`



#### autoplace

**Type:** `AutoplaceSpecification`

Used to specify the rules for placing this entity during map generation.

**Default:** `nil (entity is not autoplacable)`

#### build_base_evolution_requirement

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### build_grid_size

**Type:** `uint8`

Supported values are 1 (for 1x1 grid) and 2 (for 2x2 grid, like rails).

Internally forced to be `2` for [RailPrototype](prototype:RailPrototype), [RailRemnantsPrototype](prototype:RailRemnantsPrototype) and [TrainStopPrototype](prototype:TrainStopPrototype).

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### build_sound

**Type:** `Sound`



#### close_sound

**Type:** `Sound`



#### collision_box

**Type:** `BoundingBox`

Specification of the entity collision boundaries. Empty collision box means no collision and is used for smoke, projectiles, particles, explosions etc.

The `{0,0}` coordinate in the collision box will match the entity position. It should be near the center of the collision box, to keep correct entity drawing order. The bounding box must include the `{0,0}` coordinate.

Note, that for buildings, it is customary to leave 0.1 wide border between the edge of the tile and the edge of the building, this lets the player move between the building and electric poles/inserters etc.

**Default:** `Empty = `{{0, 0}, {0, 0}}``

#### collision_mask

**Type:** `CollisionMaskConnector`

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by the entity type.

#### created_effect

**Type:** `Trigger`

The effect/trigger that happens when the entity is placed.

#### created_smoke

**Type:** `CreateTrivialSmokeEffectItem`

The smoke that is shown when the entity is placed.

**Default:** `The "smoke-building"-smoke`

#### deconstruction_alternative

**Type:** `EntityID`

Used to merge multiple entities into one entry in the deconstruction planner.

#### diagonal_tile_grid_size

**Type:** `TilePosition`



#### drawing_box_vertical_extension

**Type:** `double`

Specification of extra vertical space needed to see the whole entity in GUIs. This is used to calculate the correct zoom and positioning in the entity info gui, for example in the entity tooltip.

**Default:** `{'complex_type': 'literal', 'value': 0.0}`

#### emissions_per_second

**Type:** `dictionary<`AirbornePollutantID`, `double`>`

Amount of emissions created (positive number) or cleaned (negative number) every second by the entity. This is passive and currently used just for trees and fires. This is independent of the [emissions of energy sources](prototype:BaseEnergySource::emissions_per_minute) used by machines, which are created actively depending on the power consumption.

#### enemy_map_color

**Type:** `Color`



#### fast_replaceable_group

**Type:** `string`

This allows you to replace an entity that's already placed, with a different one in your inventory. For example, replacing a burner inserter with a fast inserter. The replacement entity can be a different rotation to the replaced entity and you can replace an entity with the same type.

This is simply a string, so any string can be used here. The entity that should be replaced simply has to use the same string here.

**Default:** `{'complex_type': 'literal', 'value': ''}`

#### flags

**Type:** `EntityPrototypeFlags`



#### friendly_map_color

**Type:** `Color`



#### heating_energy

**Type:** `Energy`



#### hit_visualization_box

**Type:** `BoundingBox`

Where beams should hit the entity. Useful if the bounding box only covers part of the entity (e.g. feet of the character) and beams only hitting there would look weird.

**Default:** `Empty = `{{0, 0}, {0, 0}}``

#### icon

**Type:** `FileName`

Path to the icon file.

Either this or `icons` is mandatory for entities that have at least one of these flags active: `"placeable-neutral"`, `"placeable-player`", `"placeable-enemy"`.

Only loaded if `icons` is not defined.

#### icon_draw_specification

**Type:** `IconDrawSpecification`

Used to specify where and how should be the alt-mode icons of entities should be drawn.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

This will be used in the electric network statistics, editor building selection, and the bonus gui. Can't be an empty array.

Either this or `icon` is mandatory for entities that have at least one of these flags active: `"placeable-neutral"`, `"placeable-player`", `"placeable-enemy"`.

#### icons_positioning

**Type:** ``IconSequencePositioning`[]`



#### impact_category

**Type:** `string`

Name of a [ImpactCategory](prototype:ImpactCategory).

**Default:** `{'complex_type': 'literal', 'value': 'default'}`

#### map_color

**Type:** `Color`



#### map_generator_bounding_box

**Type:** `BoundingBox`

Used instead of the collision box during map generation. Allows space entities differently during map generation, for example if the box is bigger, the entities will be placed farther apart.

**Default:** `The value of collision_box.`

#### minable

**Type:** `MinableProperties`

The item given to the player when they mine the entity and other properties relevant to mining this entity.

**Default:** `not minable`

#### mined_sound

**Type:** `Sound`



#### mining_sound

**Type:** `Sound`



#### next_upgrade

**Type:** `EntityID`

Name of the entity that will be automatically selected as the upgrade of this entity when using the [upgrade planner](https://wiki.factorio.com/Upgrade_planner) without configuration.

This entity may not have "not-upgradable" flag set and must be minable. This entity mining result must not contain item product with "hidden" flag set. Mining results with no item products are allowed. This entity may not be a [RollingStockPrototype](prototype:RollingStockPrototype).

The upgrade target entity needs to have the same bounding box, collision mask, and fast replaceable group as this entity. The upgrade target entity must have least 1 item that builds it that isn't hidden.

#### open_sound

**Type:** `Sound`



#### order

**Type:** `Order`

Used to order prototypes in inventory, recipes and GUIs. May not exceed a length of 200 characters.

The order string is taken from the items in `placeable_by` if they exist, or from an item that has its [place_result](prototype:ItemPrototype::place_result) set to this entity.

#### placeable_by

**Type:** 

Item that when placed creates this entity. Determines which item is picked when "Q" (smart pipette) is used on this entity. Determines which item and item amount is needed in a blueprint of this entity and to revive a ghost of this entity.

The item count specified here can't be larger than the stack size of that item.

#### placeable_position_visualization

**Type:** `Sprite`



#### protected_from_tile_building

**Type:** `boolean`

When this is true, this entity prototype should be included during tile collision checks with tiles that have [TilePrototype::check_collision_with_entities](prototype:TilePrototype::check_collision_with_entities) set to true.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### radius_visualisation_specification

**Type:** `RadiusVisualisationSpecification`



#### remains_when_mined

**Type:** 

The entity that remains when this one is mined, deconstructed or fast-replaced. The entity wont actually be spawned if it would collide with the entity that is in the process of being mined.

#### remove_decoratives

**Type:** 

Whether this entity should remove decoratives that collide with it when this entity is built. When set to "automatic", if the entity type is considered [a building](runtime:LuaEntityPrototype::is_building) (e.g. an assembling machine or a wall) it will remove decoratives.

**Default:** `{'complex_type': 'literal', 'value': 'automatic'}`

#### rotated_sound

**Type:** `Sound`



#### selectable_in_game

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### selection_box

**Type:** `BoundingBox`

Specification of the entity selection area. When empty the entity will have no selection area (and thus is not selectable).

The selection box is usually a little bit bigger than the collision box. For tileable entities (like buildings) it should match the tile size of the building.

**Default:** `Empty = `{{0, 0}, {0, 0}}``

#### selection_priority

**Type:** `uint8`

The entity with the higher number is selectable before the entity with the lower number.

**Default:** `{'complex_type': 'literal', 'value': 50}`

#### shooting_cursor_size

**Type:** `double`

The cursor size used when shooting at this entity.

#### stateless_visualisation

**Type:** `StatelessVisualisations`



#### sticker_box

**Type:** `BoundingBox`

Used to set the area of the entity that can have stickers on it, currently only used for units to specify the area where the green slow down stickers can appear.

**Default:** `The value of collision_box.`

#### surface_conditions

**Type:** ``SurfaceCondition`[]`



#### tile_buildability_rules

**Type:** ``TileBuildabilityRule`[]`



#### tile_height

**Type:** `int32`



**Default:** `calculated by the collision box height rounded up.`

#### tile_width

**Type:** `int32`

Used to determine how the center of the entity should be positioned when building (unless the off-grid [flag](prototype:EntityPrototypeFlags) is specified).

When the tile width is odd, the center will be in the center of the tile, when it is even, the center is on the tile transition.

**Default:** `calculated by the collision box width rounded up.`

#### trigger_target_mask

**Type:** `TriggerTargetMask`

Defaults to the mask from [UtilityConstants::default_trigger_target_mask_by_type](prototype:UtilityConstants::default_trigger_target_mask_by_type).

#### water_reflection

**Type:** `WaterReflectionDefinition`

May also be defined inside `graphics_set` instead of directly in the entity prototype. This is useful for entities that use a `graphics_set` property to define their graphics, because then all graphics can be defined in one place.

[Currently only renders](https://forums.factorio.com/100703) for [EntityWithHealthPrototype](prototype:EntityWithHealthPrototype) and [CorpsePrototype](prototype:CorpsePrototype).

#### working_sound

**Type:** `WorkingSound`

Will also work on entities that don't actually do work.

