# CraftingMachinePrototype

The abstract basis of the assembling machines and furnaces. Contains the properties that both of them have.

Note that a crafting machine cannot be rotated unless it has at least one of the following: a fluid box, a heat energy source, a fluid energy source, or a non-square collision box. Crafting machines with non-square collision boxes can only be rotated before placement, not after.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### crafting_categories

**Type:** ``RecipeCategoryID`[]`

A list of [recipe categories](prototype:RecipeCategory) this crafting machine can use.

#### crafting_speed

**Type:** `double`

How fast this crafting machine can craft. 1 means that for example a 1 second long recipe take 1 second to craft. 0.5 means it takes 2 seconds, and 2 means it takes 0.5 seconds.

Crafting speed has to be positive.

#### energy_source

**Type:** `EnergySource`

Defines how the crafting machine is powered.

When using an electric energy source and `drain` is not specified, it will be set to `energy_usage ÷ 30` automatically.

#### energy_usage

**Type:** `Energy`

Sets how much energy this machine uses while crafting. Energy usage has to be positive.

### Optional Properties

#### allowed_effects

**Type:** `EffectTypeLimitation`

Sets the [modules](prototype:ModulePrototype) and [beacon](prototype:BeaconPrototype) effects that are allowed to be used on this machine.

**Default:** `No effects are allowed`

#### allowed_module_categories

**Type:** ``ModuleCategoryID`[]`

Sets the [module categories](prototype:ModuleCategory) that are allowed to be inserted into this machine.

**Default:** `All module categories are allowed`

#### draw_entity_info_icon_background

**Type:** `boolean`

Whether the "alt-mode icon" should have a black background.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### effect_receiver

**Type:** `EffectReceiver`



#### fast_transfer_modules_into_module_slots_only

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### fluid_boxes

**Type:** ``FluidBox`[]`

The crafting machine's fluid boxes. If an assembling machine has fluid boxes *and* [AssemblingMachinePrototype::fluid_boxes_off_when_no_fluid_recipe](prototype:AssemblingMachinePrototype::fluid_boxes_off_when_no_fluid_recipe) is true, the assembling machine can only be rotated when a recipe consuming or producing fluid is set, or if it has one of the other properties listed at the top of this page.

#### forced_symmetry

**Type:** `Mirroring`



**Default:** `none`

#### graphics_set

**Type:** `CraftingMachineGraphicsSet`



#### graphics_set_flipped

**Type:** `CraftingMachineGraphicsSet`



#### ignore_output_full

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### match_animation_speed_to_activity

**Type:** `boolean`

Whether the speed of the animation and working visualization should be based on the machine's speed (boosted or slowed by modules).

**Default:** `{'complex_type': 'literal', 'value': True}`

#### module_slots

**Type:** `ItemStackIndex`

The number of module slots in this machine.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### perceived_performance

**Type:** `PerceivedPerformance`

Affects animation speed.

#### production_health_effect

**Type:** `ProductionHealthEffect`



#### return_ingredients_on_change

**Type:** `boolean`

Controls whether the ingredients of an in-progress recipe are destroyed when mining the machine/changing the recipe. If set to true, the ingredients do not get destroyed. This affects only the ingredients of the recipe that is currently in progress, so those that visually have already been consumed while their resulting product has not yet been produced.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### show_recipe_icon

**Type:** `boolean`

Whether the "alt-mode icon" should be drawn at all.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### show_recipe_icon_on_map

**Type:** `boolean`

Whether the recipe icon should be shown on the map.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### trash_inventory_size

**Type:** `ItemStackIndex`



#### vector_to_place_result

**Type:** `Vector`



