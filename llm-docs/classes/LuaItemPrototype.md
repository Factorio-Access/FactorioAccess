# LuaItemPrototype

Prototype of an item. For example, an item prototype can be obtained from [LuaPrototypes::item](runtime:LuaPrototypes::item) by its name: `prototypes.item["iron-plate"]`.

**Parent:** `LuaPrototypeBase`

## Methods

### get_ammo_type

The type of this ammo prototype.

**Parameters:**

- `ammo_source_type`  _(optional)_: Defaults to `"default"`.

**Returns:**

- `AmmoType`: 

### get_cursor_box_type



**Parameters:**

- `selection_mode` `defines.selection_mode`: 

**Returns:**

- `CursorBoxRenderType`: 

### get_durability

The durability of this tool item prototype.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `double`: 

### get_entity_filter_mode

The entity filter mode used by this selection tool.

**Parameters:**

- `selection_mode` `defines.selection_mode`: 

**Returns:**

- `PrototypeFilterMode`: 

### get_entity_filters

The entity filters used by this selection tool.

**Parameters:**

- `selection_mode` `defines.selection_mode`: 

**Returns:**

- ``LuaEntityPrototype`[]`: 

### get_entity_type_filters

The entity type filters used by this selection tool indexed by entity type.

The boolean value is meaningless and is used to allow easy lookup if a type exists in the dictionary.

**Parameters:**

- `selection_mode` `defines.selection_mode`: 

**Returns:**

- `dictionary<`string`, `True`>`: 

### get_inventory_size_bonus

The inventory size bonus for this armor prototype.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `uint`: 

### get_selection_border_color

The color used when doing normal selection with this selection tool prototype.

**Parameters:**

- `selection_mode` `defines.selection_mode`: 

**Returns:**

- `Color`: 

### get_selection_mode_flags

Flags that affect which entities will be selected.

**Parameters:**

- `selection_mode` `defines.selection_mode`: 

**Returns:**

- `SelectionModeFlags`: 

### get_spoil_ticks

The number of ticks before this item spoils, or `0` if it does not spoil.

**Parameters:**

- `quality` `QualityID` _(optional)_: 

**Returns:**

- `uint`: 

### get_tile_filter_mode

The tile filter mode used by this selection tool.

**Parameters:**

- `selection_mode` `defines.selection_mode`: 

**Returns:**

- `PrototypeFilterMode`: 

### get_tile_filters

The tile filters used by this selection tool.

**Parameters:**

- `selection_mode` `defines.selection_mode`: 

**Returns:**

- ``LuaTilePrototype`[]`: 

### has_flag

Test whether this item prototype has a certain flag set.

**Parameters:**

- `flag` `ItemPrototypeFlag`: The flag to test.

**Returns:**

- `boolean`: 

## Attributes

### always_include_tiles

**Type:** `boolean` _(read-only)_

If tiles area always included when doing selection with this selection tool prototype.

### ammo_category

**Type:** `LuaAmmoCategoryPrototype` _(read-only)_



### attack_parameters

**Type:** `AttackParameters` _(read-only)_

The gun attack parameters.

### beacon_tint

**Type:** ``Color`[]` _(read-only)_



### burnt_result

**Type:** `LuaItemPrototype` _(read-only)_

The result of burning this item as fuel, if any.

### can_be_mod_opened

**Type:** `boolean` _(read-only)_

If this item can be mod-opened.

### capsule_action

**Type:** `CapsuleAction` _(read-only)_

The capsule action for this capsule item prototype.

### category

**Type:** `string` _(read-only)_

The name of a [LuaModuleCategoryPrototype](runtime:LuaModuleCategoryPrototype). Used when upgrading modules: Ctrl + click modules into an entity and it will replace lower tier modules of the same category with higher tier modules.

### collision_box

**Type:** `BoundingBox` _(read-only)_

The collision box used by character entities when wearing this armor.

### default_import_location

**Type:** `LuaSpaceLocationPrototype` _(read-only)_



### default_label_color

**Type:** `Color` _(read-only)_

The default label color used for this item with label, if any.

### destroyed_by_dropping_trigger

**Type:** ``TriggerItem`[]` _(read-only)_



### draw_label_for_cursor_render

**Type:** `boolean` _(read-only)_

If true, and this item with label has a label it is drawn in place of the normal number when held in the cursor.

### drawing_box

**Type:** `BoundingBox` _(read-only)_

The drawing box used by character entities when wearing this armor.

### durability_description_key

**Type:** `string` _(read-only)_

The durability message key used when displaying the durability of this tool.

### durability_description_value

**Type:** `string` _(read-only)_

The durability message value used when displaying the durability of this tool.

### entity_filter_slots

**Type:** `uint` _(read-only)_

The number of entity filters this deconstruction item has.

### equipment_grid

**Type:** `LuaEquipmentGridPrototype` _(read-only)_

The prototype of this armor's equipment grid, if any.

### factoriopedia_alternative

**Type:** `LuaItemPrototype` _(read-only)_

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

### factoriopedia_durability_description_key

**Type:** `string` _(read-only)_

The durability message key used when displaying the durability of this tool in Factoriopedia.

### filter_mode

**Type:**  _(read-only)_

The filter mode used by this item with inventory.

### flags

**Type:** `ItemPrototypeFlags` _(read-only)_

The flags for this item prototype.

### fuel_acceleration_multiplier

**Type:** `double` _(read-only)_

The acceleration multiplier when this item is used as fuel in a vehicle.

### fuel_acceleration_multiplier_quality_bonus

**Type:** `double` _(read-only)_

Additional fuel acceleration multiplier per quality level.

### fuel_category

**Type:** `string` _(read-only)_

The fuel category, if any.

### fuel_emissions_multiplier

**Type:** `double` _(read-only)_

The emissions multiplier if this is used as fuel.

### fuel_glow_color

**Type:** `Color` _(read-only)_



### fuel_top_speed_multiplier

**Type:** `double` _(read-only)_

The fuel top speed multiplier when this item is used as fuel in a vehicle.

### fuel_top_speed_multiplier_quality_bonus

**Type:** `double` _(read-only)_

Additional fuel top speed multiplier per quality level.

### fuel_value

**Type:** `float` _(read-only)_

Fuel value when burned.

### infinite

**Type:** `boolean` _(read-only)_

If this tool item has infinite durability.

### ingredient_to_weight_coefficient

**Type:** `double` _(read-only)_



### inventory_size

**Type:** `uint` _(read-only)_

The main inventory size for item-with-inventory-prototype.

### item_filters

**Type:** ``LuaItemPrototype`[]` _(read-only)_



### item_group_filters

**Type:** ``LuaGroup`[]` _(read-only)_



### item_subgroup_filters

**Type:** ``LuaGroup`[]` _(read-only)_



### localised_filter_message

**Type:** `LocalisedString` _(read-only)_

The localised string used when the player attempts to put items into this item with inventory that aren't allowed.

### magazine_size

**Type:** `float` _(read-only)_

Size of full magazine.

### manual_length_limit

**Type:** `double` _(read-only)_



### module_effects

**Type:** `ModuleEffects` _(read-only)_

Effects of this module.

### moved_to_hub_when_building

**Type:** `boolean` _(read-only)_



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### place_as_equipment_result

**Type:** `LuaEquipmentPrototype` _(read-only)_

Prototype of the equipment that will be created by placing this item in an equipment grid, if any.

### place_as_tile_result

**Type:** `PlaceAsTileResult` _(read-only)_

The place-as-tile result if one is defined, if any.

### place_result

**Type:** `LuaEntityPrototype` _(read-only)_

Prototype of the entity that will be created by placing this item, if any.

### plant_result

**Type:** `LuaEntityPrototype` _(read-only)_

The result entity when planting this item as a seed.

### provides_flight

**Type:** `boolean` _(read-only)_

If this armor provides flight to character entities when worm.

### radius_color

**Type:** `Color` _(read-only)_



### rails

**Type:** ``LuaEntityPrototype`[]` _(read-only)_

Prototypes of all rails possible to be used by this rail planner prototype.

### reload_time

**Type:** `float` _(read-only)_

Amount of extra time (in ticks) it takes to reload the weapon after depleting the magazine.

### requires_beacon_alt_mode

**Type:** `boolean` _(read-only)_



### resistances

**Type:** `dictionary<`string`, `Resistance`>` _(read-only)_

Resistances of this armor item, if any, indexed by damage type name.

### rocket_launch_products

**Type:** ``Product`[]` _(read-only)_

The results of launching this item in a rocket.

### skip_fog_of_war

**Type:** `boolean` _(read-only)_

If this selection tool skips things covered by fog of war.

### speed

**Type:** `float` _(read-only)_

The repairing speed if this is a repairing tool.

### spoil_result

**Type:** `LuaItemPrototype` _(read-only)_

The spoil result of this item, if any

### spoil_to_trigger_result

**Type:** `SpoilToTriggerResult` _(read-only)_



### stack_size

**Type:** `uint` _(read-only)_

Maximum stack size of the item specified by this prototype.

### stackable

**Type:** `boolean` _(read-only)_

Is this item allowed to stack at all?

### support

**Type:** `LuaEntityPrototype` _(read-only)_

The rail support used by this rail planner.

### tier

**Type:** `uint` _(read-only)_

Tier of the module inside its category. Used when upgrading modules: Ctrl + click modules into an entity and it will replace lower tier modules with higher tier modules if they have the same category.

### tile_filter_slots

**Type:** `uint` _(read-only)_

The number of tile filters this deconstruction item has.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### weight

**Type:** `double` _(read-only)_

Weight of this item. More information on how item weight is determined can be found on its [auxiliary page](runtime:item-weight).

