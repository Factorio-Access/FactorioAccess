# LuaItemPrototype

Prototype of an item. For example, an item prototype can be obtained from [LuaPrototypes::item](runtime:LuaPrototypes::item) by its name: `prototypes.item["iron-plate"]`.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### place_result

Prototype of the entity that will be created by placing this item, if any.

**Read type:** `LuaEntityPrototype`

**Optional:** Yes

### place_as_equipment_result

Prototype of the equipment that will be created by placing this item in an equipment grid, if any.

**Read type:** `LuaEquipmentPrototype`

**Optional:** Yes

### place_as_tile_result

The place-as-tile result if one is defined, if any.

**Read type:** `PlaceAsTileResult`

**Optional:** Yes

### stackable

Is this item allowed to stack at all?

**Read type:** `boolean`

### stack_size

Maximum stack size of the item specified by this prototype.

**Read type:** `uint`

### fuel_category

The fuel category, if any.

**Read type:** `string`

**Optional:** Yes

### burnt_result

The result of burning this item as fuel, if any.

**Read type:** `LuaItemPrototype`

**Optional:** Yes

### fuel_value

Fuel value when burned.

**Read type:** `float`

### fuel_acceleration_multiplier

The acceleration multiplier when this item is used as fuel in a vehicle.

**Read type:** `double`

### fuel_top_speed_multiplier

The fuel top speed multiplier when this item is used as fuel in a vehicle.

**Read type:** `double`

### fuel_emissions_multiplier

The emissions multiplier if this is used as fuel.

**Read type:** `double`

### fuel_acceleration_multiplier_quality_bonus

Additional fuel acceleration multiplier per quality level.

**Read type:** `double`

### fuel_top_speed_multiplier_quality_bonus

Additional fuel top speed multiplier per quality level.

**Read type:** `double`

### flags

The flags for this item prototype.

**Read type:** `ItemPrototypeFlags`

### rocket_launch_products

The results of launching this item in a rocket.

**Read type:** Array[`Product`]

### send_to_orbit_mode

How this item interacts when being sent to orbit.

**Read type:** `"not-sendable"` | `"manual"` | `"automated"`

### can_be_mod_opened

If this item can be mod-opened.

**Read type:** `boolean`

### spoil_result

The spoil result of this item, if any

**Read type:** `LuaItemPrototype`

**Optional:** Yes

### plant_result

The result entity when planting this item as a seed.

**Read type:** `LuaEntityPrototype`

**Optional:** Yes

### spoil_to_trigger_result

**Read type:** `SpoilToTriggerResult`

**Optional:** Yes

### destroyed_by_dropping_trigger

**Read type:** Array[`TriggerItem`]

**Optional:** Yes

### weight

Weight of this item. More information on how item weight is determined can be found on its [auxiliary page](runtime:item-weight).

**Read type:** `Weight`

### ingredient_to_weight_coefficient

**Read type:** `double`

### fuel_glow_color

**Read type:** `Color`

**Optional:** Yes

### default_import_location

**Read type:** `LuaSpaceLocationPrototype`

### factoriopedia_alternative

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

**Read type:** `LuaItemPrototype`

**Optional:** Yes

### moved_to_hub_when_building

**Read type:** `boolean`

### ammo_category

**Read type:** `LuaAmmoCategoryPrototype`

**Optional:** Yes

**Subclasses:** AmmoItem

### magazine_size

Size of full magazine.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AmmoItem

### reload_time

Amount of extra time (in ticks) it takes to reload the weapon after depleting the magazine.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** AmmoItem

### equipment_grid

The prototype of this armor's equipment grid, if any.

**Read type:** `LuaEquipmentGridPrototype`

**Optional:** Yes

**Subclasses:** Armor

### resistances

Resistances of this armor item, if any, indexed by damage type name.

**Read type:** Dictionary[`string`, `Resistance`]

**Optional:** Yes

**Subclasses:** Armor

### collision_box

The collision box used by character entities when wearing this armor.

**Read type:** `BoundingBox`

**Optional:** Yes

**Subclasses:** ArmorPrototype

### drawing_box

The drawing box used by character entities when wearing this armor.

**Read type:** `BoundingBox`

**Optional:** Yes

**Subclasses:** ArmorPrototype

### provides_flight

If this armor provides flight to character entities when worm.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** ArmorPrototype

### capsule_action

The capsule action for this capsule item prototype.

**Read type:** `CapsuleAction`

**Optional:** Yes

**Subclasses:** Capsule

### radius_color

**Read type:** `Color`

**Optional:** Yes

**Subclasses:** Capsule

### attack_parameters

The gun attack parameters.

**Read type:** `AttackParameters`

**Optional:** Yes

**Subclasses:** Gun

### inventory_size

The main inventory size for item-with-inventory-prototype.

**Read type:** `uint`

**Optional:** Yes

**Subclasses:** ItemWithInventoryPrototype

### item_filters

**Read type:** Array[`LuaItemPrototype`]

**Optional:** Yes

**Subclasses:** ItemWithInventory

### item_group_filters

**Read type:** Array[`LuaGroup`]

**Optional:** Yes

**Subclasses:** ItemWithInventory

### item_subgroup_filters

**Read type:** Array[`LuaGroup`]

**Optional:** Yes

**Subclasses:** ItemWithInventory

### filter_mode

The filter mode used by this item with inventory.

**Read type:** `PrototypeFilterMode`

**Optional:** Yes

**Subclasses:** ItemWithInventory

### localised_filter_message

The localised string used when the player attempts to put items into this item with inventory that aren't allowed.

**Read type:** `LocalisedString`

**Optional:** Yes

**Subclasses:** ItemWithInventory

### default_label_color

The default label color used for this item with label, if any.

**Read type:** `Color`

**Optional:** Yes

**Subclasses:** ItemWithLabel

### draw_label_for_cursor_render

If true, and this item with label has a label it is drawn in place of the normal number when held in the cursor.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** ItemWithLabel

### speed

The repairing speed if this is a repairing tool.

**Read type:** `float`

**Optional:** Yes

**Subclasses:** RepairTool

### module_effects

Effects of this module.

**Read type:** `ModuleEffects`

**Optional:** Yes

**Subclasses:** ModuleItem

### category

The name of a [LuaModuleCategoryPrototype](runtime:LuaModuleCategoryPrototype). Used when upgrading modules: Ctrl + click modules into an entity and it will replace lower tier modules of the same category with higher tier modules.

**Read type:** `string`

**Optional:** Yes

**Subclasses:** ModuleItem

### tier

Tier of the module inside its category. Used when upgrading modules: Ctrl + click modules into an entity and it will replace lower tier modules with higher tier modules if they have the same category.

**Read type:** `uint`

**Optional:** Yes

**Subclasses:** ModuleItem

### requires_beacon_alt_mode

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** ModuleItem

### beacon_tint

**Read type:** Array[`Color`]

**Optional:** Yes

**Subclasses:** ModuleItem

### rails

Prototypes of all rails possible to be used by this rail planner prototype.

**Read type:** Array[`LuaEntityPrototype`]

**Optional:** Yes

**Subclasses:** RailPlanner

### support

The rail support used by this rail planner.

**Read type:** `LuaEntityPrototype`

**Optional:** Yes

**Subclasses:** RailPlanner

### manual_length_limit

**Read type:** `double`

**Optional:** Yes

**Subclasses:** RailPlanner

### always_include_tiles

If tiles area always included when doing selection with this selection tool prototype.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** SelectionTool

### skip_fog_of_war

If this selection tool skips things covered by fog of war.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** SelectionTool

### entity_filter_slots

The number of entity filters this deconstruction item has.

**Read type:** `uint`

**Optional:** Yes

**Subclasses:** DeconstructionItem

### tile_filter_slots

The number of tile filters this deconstruction item has.

**Read type:** `uint`

**Optional:** Yes

**Subclasses:** DeconstructionItem

### durability_description_key

The durability message key used when displaying the durability of this tool.

**Read type:** `string`

**Optional:** Yes

**Subclasses:** ToolItem

### factoriopedia_durability_description_key

The durability message key used when displaying the durability of this tool in Factoriopedia.

**Read type:** `string`

**Optional:** Yes

**Subclasses:** ToolItem

### durability_description_value

The durability message value used when displaying the durability of this tool.

**Read type:** `string`

**Optional:** Yes

**Subclasses:** ToolItem

### infinite

If this tool item has infinite durability.

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** ToolItem

### trigger

**Read type:** `TriggerItem`

**Optional:** Yes

**Subclasses:** SpacePlatformStarterPack

### surface

**Read type:** `LuaSurfacePrototype`

**Optional:** Yes

**Subclasses:** SpacePlatformStarterPack

### create_electric_network

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** SpacePlatformStarterPack

### tiles

**Read type:** Array[`SpacePlatformTileDefinition`]

**Optional:** Yes

**Subclasses:** SpacePlatformStarterPack

### initial_items

**Read type:** Array[`ItemProduct`]

**Optional:** Yes

**Subclasses:** SpacePlatformStarterPack

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### has_flag

Test whether this item prototype has a certain flag set.

**Parameters:**

- `flag` `ItemPrototypeFlag` - The flag to test.

**Returns:**

- `boolean`

### get_spoil_ticks

The number of ticks before this item spoils, or `0` if it does not spoil.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `uint`

### get_ammo_type

The type of this ammo prototype.

**Parameters:**

- `ammo_source_type` `"default"` | `"player"` | `"turret"` | `"vehicle"` *(optional)* - Defaults to `"default"`.

**Returns:**

- `AmmoType` *(optional)*

### get_inventory_size_bonus

The inventory size bonus for this armor prototype.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `uint` *(optional)*

### get_selection_border_color

The color used when doing normal selection with this selection tool prototype.

**Parameters:**

- `selection_mode` `defines.selection_mode`

**Returns:**

- `Color` *(optional)*

### get_selection_mode_flags

Flags that affect which entities will be selected.

**Parameters:**

- `selection_mode` `defines.selection_mode`

**Returns:**

- `SelectionModeFlags` *(optional)*

### get_cursor_box_type

**Parameters:**

- `selection_mode` `defines.selection_mode`

**Returns:**

- `CursorBoxRenderType` *(optional)*

### get_entity_filter_mode

The entity filter mode used by this selection tool.

**Parameters:**

- `selection_mode` `defines.selection_mode`

**Returns:**

- `PrototypeFilterMode` *(optional)*

### get_tile_filter_mode

The tile filter mode used by this selection tool.

**Parameters:**

- `selection_mode` `defines.selection_mode`

**Returns:**

- `PrototypeFilterMode` *(optional)*

### get_entity_filters

The entity filters used by this selection tool.

**Parameters:**

- `selection_mode` `defines.selection_mode`

**Returns:**

- Array[`LuaEntityPrototype`] *(optional)*

### get_entity_type_filters

The entity type filters used by this selection tool indexed by entity type.

The boolean value is meaningless and is used to allow easy lookup if a type exists in the dictionary.

**Parameters:**

- `selection_mode` `defines.selection_mode`

**Returns:**

- Dictionary[`string`, `True`] *(optional)*

### get_tile_filters

The tile filters used by this selection tool.

**Parameters:**

- `selection_mode` `defines.selection_mode`

**Returns:**

- Array[`LuaTilePrototype`] *(optional)*

### get_durability

The durability of this tool item prototype.

**Parameters:**

- `quality` `QualityID` *(optional)*

**Returns:**

- `double` *(optional)*

