# EntityPrototype

Abstract base of all entities in the game. Entity is nearly everything that can be on the map (except tiles).

For in game script access to entity, take a look at [LuaEntity](runtime:LuaEntity).

**Parent:** [Prototype](Prototype.md)
**Abstract:** Yes

## Examples

```
{
  type = "container",
  name = "wooden-chest",
  icon = "__base__/graphics/icons/wooden-chest.png",
  flags = { "placeable-neutral", "player-creation" },
  minable = { mining_time = 1, result = "wooden-chest" },
  max_health = 100,
  corpse = "small-remnants",
  collision_box = { {-0.35, -0.35}, {0.35, 0.35} },
  fast_replaceable_group = "container",
  selection_box = { {-0.5, -0.5}, {0.5, 0.5} },
  inventory_size = 16,
  open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" },
  close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" },
  picture =
  {
    filename = "__base__/graphics/entity/wooden-chest/wooden-chest.png",
    priority = "extra-high",
    width = 46,
    height = 33,
    shift = {0.25, 0.015625}
  }
}
```

## Properties

### icons

This will be used in the electric network statistics, editor building selection, and the bonus gui. Can't be an empty array.

Either this or `icon` is mandatory for entities that have at least one of these flags active: `"placeable-neutral"`, `"placeable-player`", `"placeable-enemy"`.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file.

Either this or `icons` is mandatory for entities that have at least one of these flags active: `"placeable-neutral"`, `"placeable-player`", `"placeable-enemy"`.

Only loaded if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

**Examples:**

```
icon = "__base__/graphics/icons/wooden-chest.png"
```

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### collision_box

Specification of the entity collision boundaries. Empty collision box means no collision and is used for smoke, projectiles, particles, explosions etc.

The `{0,0}` coordinate in the collision box will match the entity position. It should be near the center of the collision box, to keep correct entity drawing order. The bounding box must include the `{0,0}` coordinate.

Note, that for buildings, it is customary to leave 0.1 wide border between the edge of the tile and the edge of the building, this lets the player move between the building and electric poles/inserters etc.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "Empty = `{{0, 0}, {0, 0}}`"

**Examples:**

```
collision_box = {{-0.4, -0.4}, {0.4, 0.4}}
```

### collision_mask

Defaults to the mask from [UtilityConstants::default_collision_masks](prototype:UtilityConstants::default_collision_masks) when indexed by the entity type.

**Type:** `CollisionMaskConnector`

**Optional:** Yes

### map_generator_bounding_box

Used instead of the collision box during map generation. Allows space entities differently during map generation, for example if the box is bigger, the entities will be placed farther apart.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "The value of collision_box."

### selection_box

Specification of the entity selection area. When empty the entity will have no selection area (and thus is not selectable).

The selection box is usually a little bit bigger than the collision box. For tileable entities (like buildings) it should match the tile size of the building.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "Empty = `{{0, 0}, {0, 0}}`"

**Examples:**

```
selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
```

### drawing_box_vertical_extension

Specification of extra vertical space needed to see the whole entity in GUIs. This is used to calculate the correct zoom and positioning in the entity info gui, for example in the entity tooltip.

**Type:** `double`

**Optional:** Yes

**Default:** 0.0

**Examples:**

```
drawing_box_vertical_extension = 0.5
```

### sticker_box

Used to set the area of the entity that can have stickers on it, currently only used for units to specify the area where the green slow down stickers can appear.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "The value of collision_box."

**Examples:**

```
sticker_box = {{-0.5, -0.5}, {0.5, 0.5}}
```

### hit_visualization_box

Where beams should hit the entity. Useful if the bounding box only covers part of the entity (e.g. feet of the character) and beams only hitting there would look weird.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "Empty = `{{0, 0}, {0, 0}}`"

### trigger_target_mask

Defaults to the mask from [UtilityConstants::default_trigger_target_mask_by_type](prototype:UtilityConstants::default_trigger_target_mask_by_type).

**Type:** `TriggerTargetMask`

**Optional:** Yes

### flags

**Type:** `EntityPrototypeFlags`

**Optional:** Yes

### tile_buildability_rules

**Type:** Array[`TileBuildabilityRule`]

**Optional:** Yes

### minable

The item given to the player when they mine the entity and other properties relevant to mining this entity.

**Type:** `MinableProperties`

**Optional:** Yes

**Default:** "not minable"

**Examples:**

```
minable = {mining_time = 0.2, result = "boiler"}
```

### surface_conditions

**Type:** Array[`SurfaceCondition`]

**Optional:** Yes

### deconstruction_alternative

Used to merge multiple entities into one entry in the deconstruction planner.

**Type:** `EntityID`

**Optional:** Yes

### selection_priority

The entity with the higher number is selectable before the entity with the lower number.

The value `0` will be treated the same as `nil`.

**Type:** `uint8`

**Optional:** Yes

**Default:** 50

### build_grid_size

Supported values are 1 (for 1x1 grid) and 2 (for 2x2 grid, like rails).

Internally forced to be `2` for [RailPrototype](prototype:RailPrototype), [RailRemnantsPrototype](prototype:RailRemnantsPrototype), [TrainStopPrototype](prototype:TrainStopPrototype), [RailSupportPrototype](prototype:RailSupportPrototype) and [CargoBayPrototype](prototype:CargoBayPrototype).

Internally forced to be `256` for [SpacePlatformHubPrototype](prototype:SpacePlatformHubPrototype).

**Type:** `uint8`

**Optional:** Yes

**Default:** 1

### remove_decoratives

Whether this entity should remove decoratives that collide with it when this entity is built. When set to "automatic", if the entity type is considered [a building](runtime:LuaEntityPrototype::is_building) (e.g. an assembling machine or a wall) it will remove decoratives.

**Type:** `"automatic"` | `"true"` | `"false"`

**Optional:** Yes

**Default:** "automatic"

### emissions_per_second

Amount of emissions created (positive number) or cleaned (negative number) every second by the entity. This is passive and currently used just for trees and fires. This is independent of the [emissions of energy sources](prototype:BaseEnergySource::emissions_per_minute) used by machines, which are created actively depending on the power consumption.

**Type:** Dictionary[`AirbornePollutantID`, `double`]

**Optional:** Yes

### shooting_cursor_size

The cursor size used when shooting at this entity.

**Type:** `double`

**Optional:** Yes

### created_smoke

The smoke that is shown when the entity is placed.

**Type:** `CreateTrivialSmokeEffectItem`

**Optional:** Yes

**Default:** "The "smoke-building"-smoke"

### working_sound

Will also work on entities that don't actually do work.

**Type:** `WorkingSound`

**Optional:** Yes

### created_effect

The effect/trigger that happens when the entity is placed.

**Type:** `Trigger`

**Optional:** Yes

### build_sound

**Type:** `Sound`

**Optional:** Yes

### mined_sound

**Type:** `Sound`

**Optional:** Yes

### mining_sound

**Type:** `Sound`

**Optional:** Yes

### rotated_sound

**Type:** `Sound`

**Optional:** Yes

### impact_category

Name of a [ImpactCategory](prototype:ImpactCategory).

**Type:** `string`

**Optional:** Yes

**Default:** "default"

### open_sound

**Type:** `Sound`

**Optional:** Yes

### close_sound

**Type:** `Sound`

**Optional:** Yes

### placeable_position_visualization

**Type:** `Sprite`

**Optional:** Yes

### radius_visualisation_specification

**Type:** `RadiusVisualisationSpecification`

**Optional:** Yes

### stateless_visualisation

**Type:** `StatelessVisualisation` | Array[`StatelessVisualisation`]

**Optional:** Yes

### draw_stateless_visualisations_in_ghost

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### build_base_evolution_requirement

**Type:** `double`

**Optional:** Yes

**Default:** 0

### alert_icon_shift

**Type:** `Vector`

**Optional:** Yes

### alert_icon_scale

**Type:** `float`

**Optional:** Yes

### fast_replaceable_group

This allows you to replace an entity that's already placed, with a different one in your inventory. For example, replacing a burner inserter with a fast inserter. The replacement entity can be a different rotation to the replaced entity and you can replace an entity with the same type.

This is simply a string, so any string can be used here. The entity that should be replaced simply has to use the same string here.

Entities with the same fast replaceable group can be configured as upgrades for each other in the upgrade planner. Refer to the [upgrade planner prototype's page](prototype:UpgradeItemPrototype) the full requirements for entities to be shown in the upgrade planner.

**Type:** `string`

**Optional:** Yes

**Default:** ""

### next_upgrade

Name of the entity that will be automatically selected as the upgrade of this entity when using the [upgrade planner](prototype:UpgradeItemPrototype) without configuration.

This entity may not have "not-upgradable" flag set and must be minable. This entity mining result must not contain item product with [hidden](prototype:ItemPrototype::hidden) set to `true`. Mining results with no item products are allowed. This entity may not be a [RollingStockPrototype](prototype:RollingStockPrototype).

The upgrade target entity needs to have the same bounding box, collision mask, and fast replaceable group as this entity. The upgrade target entity must have least 1 item that builds it that isn't hidden.

**Type:** `EntityID`

**Optional:** Yes

**Examples:**

```
next_upgrade = "fast-inserter"
```

### protected_from_tile_building

When this is true, this entity prototype should be included during tile collision checks with tiles that have [TilePrototype::check_collision_with_entities](prototype:TilePrototype::check_collision_with_entities) set to true.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### heating_energy

This entity can freeze if heating_energy is larger than zero.

**Type:** `Energy`

**Optional:** Yes

**Default:** "0W"

### allow_copy_paste

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### selectable_in_game

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### placeable_by

Item that when placed creates this entity. Determines which item is picked when "Q" (smart pipette) is used on this entity. Determines which item and item amount is needed in a blueprint of this entity and to revive a ghost of this entity.

The item count specified here can't be larger than the stack size of that item.

**Type:** `ItemToPlace` | Array[`ItemToPlace`]

**Optional:** Yes

**Examples:**

```
placeable_by = {item = "rail", count = 4}
```

### remains_when_mined

The entity that remains when this one is mined, deconstructed or fast-replaced. The entity wont actually be spawned if it would collide with the entity that is in the process of being mined.

**Type:** `EntityID` | Array[`EntityID`]

**Optional:** Yes

### additional_pastable_entities

Names of the entity prototypes this entity prototype can be pasted on to in addition to the standard supported types.

This is used to allow copying between types that aren't compatible on the C++ code side, by allowing mods to receive the [on_entity_settings_pasted](runtime:on_entity_settings_pasted) event for the given entity and do the setting pasting via script.

**Type:** Array[`EntityID`]

**Optional:** Yes

**Examples:**

```
additional_pastable_entities = {"steel-chest", "iron-chest"}
```

### tile_width

Used to determine how the center of the entity should be positioned when building (unless the off-grid [flag](prototype:EntityPrototypeFlags) is specified).

When the tile width is odd, the center will be in the center of the tile, when it is even, the center is on the tile transition.

**Type:** `int32`

**Optional:** Yes

**Default:** "calculated by the collision box width rounded up."

### tile_height

**Type:** `int32`

**Optional:** Yes

**Default:** "calculated by the collision box height rounded up."

### diagonal_tile_grid_size

**Type:** `TilePosition`

**Optional:** Yes

### autoplace

Used to specify the rules for placing this entity during map generation.

**Type:** `AutoplaceSpecification`

**Optional:** Yes

**Default:** "nil (entity is not autoplacable)"

### map_color

**Type:** `Color`

**Optional:** Yes

### friendly_map_color

**Type:** `Color`

**Optional:** Yes

### enemy_map_color

**Type:** `Color`

**Optional:** Yes

### water_reflection

May also be defined inside `graphics_set` instead of directly in the entity prototype. This is useful for entities that use a `graphics_set` property to define their graphics, because then all graphics can be defined in one place.

[Currently only renders](https://forums.factorio.com/100703) for [EntityWithHealthPrototype](prototype:EntityWithHealthPrototype) and [CorpsePrototype](prototype:CorpsePrototype).

**Type:** `WaterReflectionDefinition`

**Optional:** Yes

### ambient_sounds_group

**Type:** `EntityID`

**Optional:** Yes

### ambient_sounds

**Type:** `WorldAmbientSoundDefinition` | Array[`WorldAmbientSoundDefinition`]

**Optional:** Yes

### icon_draw_specification

Used to specify where and how the alt-mode icons should be drawn.

**Type:** `IconDrawSpecification`

**Optional:** Yes

**Examples:**

```
icon_draw_specification = {shift = {0, 0.5}, scale = 0.75, scale_for_many = 0.5, render_layer = "entity-info-icon"}
```

### icons_positioning

**Type:** Array[`IconSequencePositioning`]

**Optional:** Yes

**Examples:**

```
icons_positioning =
{
  {inventory_index = defines.inventory.lab_modules, shift = {0, 0.9}},
  {inventory_index = defines.inventory.lab_input, shift = {0, 0.0}, max_icons_per_row = 6, separation_multiplier = 0.9}
}
```

### order

Used to order prototypes in inventory, recipes and GUIs. May not exceed a length of 200 characters.

The order string is taken from the items in `placeable_by` if they exist, or from an item that has its [place_result](prototype:ItemPrototype::place_result) set to this entity.

**Type:** `Order`

**Optional:** Yes

**Overrides parent:** Yes

