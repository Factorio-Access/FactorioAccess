# ItemPrototype

Possible configuration for all items.

**Parent:** [Prototype](Prototype.md)
**Type name:** `item`

## Properties

### stack_size

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

**Type:** `ItemCountType`

**Required:** Yes

**Examples:**

```
stack_size = 64
```

### icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file.

Only loaded, and mandatory if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### dark_background_icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### dark_background_icon

If this is set, it is used to show items in alt-mode instead of the normal item icon. This can be useful to increase the contrast of the icon with the dark alt-mode [icon outline](prototype:UtilityConstants::item_outline_color).

Path to the icon file.

Only loaded if `dark_background_icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### dark_background_icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `dark_background_icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### place_result

Name of the [EntityPrototype](prototype:EntityPrototype) that can be built using this item. If this item should be the one that construction bots use to build the specified `place_result`, set the `"primary-place-result"` [item flag](prototype:ItemPrototypeFlags).

The localised name of the entity will be used as the in-game item name. This behavior can be overwritten by specifying `localised_name` on this item, it will be used instead.

**Type:** `EntityID`

**Optional:** Yes

**Default:** ""

**Examples:**

```
place_result = "wooden-chest"
```

### place_as_equipment_result

**Type:** `EquipmentID`

**Optional:** Yes

**Default:** ""

### fuel_category

Must exist when a nonzero fuel_value is defined.

**Type:** `FuelCategoryID`

**Optional:** Yes

**Default:** ""

### burnt_result

The item that is the result when this item gets burned as fuel.

**Type:** `ItemID`

**Optional:** Yes

**Default:** ""

### spoil_result

**Type:** `ItemID`

**Optional:** Yes

### plant_result

**Type:** `EntityID`

**Optional:** Yes

### place_as_tile

**Type:** `PlaceAsTile`

**Optional:** Yes

### pictures

Used to give the item multiple different icons so that they look less uniform on belts. For inventory icons and similar, `icon/icons` will be used. Maximum number of variations is 16.

When using sprites of size `64` (same as base game icons), the `scale` should be set to 0.5.

**Type:** `SpriteVariations`

**Optional:** Yes

### flags

Specifies some properties of the item.

**Type:** `ItemPrototypeFlags`

**Optional:** Yes

**Examples:**

```
flags = { "hide-from-bonus-gui" }
```

### spoil_ticks

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### fuel_value

Amount of energy the item gives when used as fuel.

Mandatory if `fuel_acceleration_multiplier`, `fuel_top_speed_multiplier` or `fuel_emissions_multiplier` or `fuel_glow_color` are used.

**Type:** `Energy`

**Optional:** Yes

**Default:** "0J"

**Examples:**

```
fuel_value = "12MJ"
```

### fuel_acceleration_multiplier

Must be 0 or positive.

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### fuel_top_speed_multiplier

Must be 0 or positive.

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### fuel_emissions_multiplier

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### fuel_acceleration_multiplier_quality_bonus

Additional fuel acceleration multiplier per quality level. Defaults to 30% of `fuel_acceleration_multiplier - 1` if `fuel_acceleration_multiplier` is larger than 1. Otherwise defaults to 0.

Must be 0 or positive.

**Type:** `double`

**Optional:** Yes

### fuel_top_speed_multiplier_quality_bonus

Additional fuel top speed multiplier per quality level. Defaults to 30% of `fuel_top_speed_multiplier - 1` if `fuel_top_speed_multiplier` is larger than 1. Otherwise defaults to 0.

Must be 0 or positive.

**Type:** `double`

**Optional:** Yes

### weight

The default weight is calculated automatically from recipes and falls back to [UtilityConstants::default_item_weight](prototype:UtilityConstants::default_item_weight).

More information on how item weight is determined can be found on its [auxiliary page](runtime:item-weight).

**Type:** `Weight`

**Optional:** Yes

### ingredient_to_weight_coefficient

**Type:** `double`

**Optional:** Yes

**Default:** 0.5

### fuel_glow_color

Colors the glow of the burner energy source when this fuel is burned. Can also be used to color the glow of reactors burning the fuel, see [ReactorPrototype::use_fuel_glow_color](prototype:ReactorPrototype::use_fuel_glow_color).

**Type:** `Color`

**Optional:** Yes

### open_sound

**Type:** `Sound`

**Optional:** Yes

### close_sound

**Type:** `Sound`

**Optional:** Yes

### pick_sound

**Type:** `Sound`

**Optional:** Yes

### drop_sound

**Type:** `Sound`

**Optional:** Yes

### inventory_move_sound

**Type:** `Sound`

**Optional:** Yes

### default_import_location

**Type:** `SpaceLocationID`

**Optional:** Yes

**Default:** "nauvis"

### color_hint

Only used by hidden setting, support may be limited.

**Type:** `ColorHintSpecification`

**Optional:** Yes

### has_random_tint

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### spoil_to_trigger_result

**Type:** `SpoilToTriggerResult`

**Optional:** Yes

### destroyed_by_dropping_trigger

The effect/trigger that happens when an item is destroyed by being dropped on a [TilePrototype](prototype:TilePrototype) marked as destroying dropped items.

This overrides the [TilePrototype::default_destroyed_dropped_item_trigger](prototype:TilePrototype::default_destroyed_dropped_item_trigger) from the tile.

**Type:** `Trigger`

**Optional:** Yes

### rocket_launch_products

**Type:** Array[`ItemProductPrototype`]

**Optional:** Yes

### send_to_orbit_mode

The way this item works when we try to send it to the orbit on its own.

When "manual" is set, it can only be launched by pressing the launch button in the rocket silo.

When "automated" is set, it will force the existence of "launch to orbit automatically" checkbox in the rocket silo which will then force the silo to automatically send the item to orbit when present.

**Type:** `SendToOrbitMode`

**Optional:** Yes

**Default:** "not-sendable"

### moved_to_hub_when_building

Whether this item should be moved to the hub when space platform performs building, upgrade or deconstruction and is left with this item. The following items are considered valuable and moved to hub by default: [Modules](prototype:ModulePrototype), [items that build entities](prototype:ItemPrototype::place_result), [items that build tiles](prototype:ItemPrototype::place_as_tile) and items [not obtainable from asteroid chunks](prototype:AsteroidChunkPrototype::minable) that have [subgroup](prototype:PrototypeBase::subgroup) from a [group](prototype:ItemSubGroup::group) other than `"intermediate-products"`.

**Type:** `boolean`

**Optional:** Yes

### random_tint_color

Randomly tints item instances on belts and in the world. 0 no tinting. 1 full tint.

**Type:** `Color`

**Optional:** Yes

**Default:** "Value of UtilityConstants::item_default_random_tint_strength"

### spoil_level

Used by Inserters with spoil priority. Item with higher spoil level is considered more spoiled than item with lower spoil level regardless of progress of spoiling.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### auto_recycle

Whether the item should be included in the self-recycling recipes automatically generated by the quality mod.

This property is not read by the game engine itself, but the quality mod's data-updates.lua file. This means it is discarded by the game engine after loading finishes.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

