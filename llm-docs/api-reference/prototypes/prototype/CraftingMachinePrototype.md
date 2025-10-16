# CraftingMachinePrototype

The abstract basis of the assembling machines and furnaces. Contains the properties that both of them have.

Note that a crafting machine cannot be rotated unless it has at least one of the following: a fluid box, a heat energy source, a fluid energy source, or a non-square collision box. Crafting machines with non-square collision boxes can only be rotated before placement, not after.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Abstract:** Yes

## Properties

### quality_affects_energy_usage

When set, [QualityPrototype::crafting_machine_energy_usage_multiplier](prototype:QualityPrototype::crafting_machine_energy_usage_multiplier) will be applied to energy_usage.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### energy_usage

Sets how much energy this machine uses while crafting. Energy usage has to be positive.

**Type:** `Energy`

**Required:** Yes

**Examples:**

```
energy_usage = "90kW"
```

### crafting_speed

How fast this crafting machine can craft. 1 means that for example a 1 second long recipe take 1 second to craft. 0.5 means it takes 2 seconds, and 2 means it takes 0.5 seconds.

Crafting speed has to be positive.

**Type:** `double`

**Required:** Yes

### crafting_categories

A list of [recipe categories](prototype:RecipeCategory) this crafting machine can use.

**Type:** Array[`RecipeCategoryID`]

**Required:** Yes

**Examples:**

```
crafting_categories = {"crafting", "smelting"}
```

### energy_source

Defines how the crafting machine is powered.

When using an electric energy source and `drain` is not specified, it will be set to `energy_usage ÷ 30` automatically.

**Type:** `EnergySource`

**Required:** Yes

### fluid_boxes

The crafting machine's fluid boxes. If an assembling machine has fluid boxes *and* [AssemblingMachinePrototype::fluid_boxes_off_when_no_fluid_recipe](prototype:AssemblingMachinePrototype::fluid_boxes_off_when_no_fluid_recipe) is true, the assembling machine can only be rotated when a recipe consuming or producing fluid is set, or if it has one of the other properties listed at the top of this page.

For assembling machines, any [filters](prototype:FluidBox::filter) set on the fluidboxes are ignored.

**Type:** Array[`FluidBox`]

**Optional:** Yes

**Examples:**

```
fluid_boxes =
{
  {
    production_type = "input",
    pipe_picture = assembler2pipepictures(),
    pipe_covers = pipecoverspictures(),
    volume = 1000,
    pipe_connections = {{ flow_direction = "input", direction = defines.direction.north, position = {0, -1} }},
    secondary_draw_orders = { north = -1 }
  },
  {
    production_type = "output",
    pipe_picture = assembler2pipepictures(),
    pipe_covers = pipecoverspictures(),
    volume = 1000,
    pipe_connections = {{ flow_direction = "output", direction = defines.direction.south, position = {0, 1} }},
    secondary_draw_orders = { north = -1 }
  },
}
```

### effect_receiver

**Type:** `EffectReceiver`

**Optional:** Yes

### module_slots

The number of module slots in this machine.

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 0

### quality_affects_module_slots

If set, [QualityPrototype::crafting_machine_module_slots_bonus](prototype:QualityPrototype::crafting_machine_module_slots_bonus) will be added to module slots count.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### allowed_effects

Sets the [modules](prototype:ModulePrototype) and [beacon](prototype:BeaconPrototype) effects that are allowed to be used on this machine.

**Type:** `EffectTypeLimitation`

**Optional:** Yes

**Default:** "No effects are allowed"

### allowed_module_categories

Sets the [module categories](prototype:ModuleCategory) that are allowed to be inserted into this machine.

**Type:** Array[`ModuleCategoryID`]

**Optional:** Yes

**Default:** "All module categories are allowed"

### show_recipe_icon

Whether the "alt-mode icon" should be drawn at all.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### return_ingredients_on_change

Controls whether the ingredients of an in-progress recipe are destroyed when mining the machine/changing the recipe. If set to true, the ingredients do not get destroyed. This affects only the ingredients of the recipe that is currently in progress, so those that visually have already been consumed while their resulting product has not yet been produced.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### draw_entity_info_icon_background

Whether the "alt-mode icon" should have a black background.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### match_animation_speed_to_activity

Whether the speed of the animation and working visualization should be based on the machine's speed (boosted or slowed by modules).

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### show_recipe_icon_on_map

Whether the recipe icon should be shown on the map.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### fast_transfer_modules_into_module_slots_only

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### ignore_output_full

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### graphics_set

**Type:** `CraftingMachineGraphicsSet`

**Optional:** Yes

### graphics_set_flipped

**Type:** `CraftingMachineGraphicsSet`

**Optional:** Yes

### perceived_performance

Affects animation speed.

**Type:** `PerceivedPerformance`

**Optional:** Yes

### production_health_effect

**Type:** `ProductionHealthEffect`

**Optional:** Yes

### trash_inventory_size

**Type:** `ItemStackIndex`

**Optional:** Yes

### vector_to_place_result

**Type:** `Vector`

**Optional:** Yes

### forced_symmetry

**Type:** `Mirroring`

**Optional:** Yes

**Default:** "none"

### crafting_speed_quality_multiplier

Each value must be >= 0.01.

If value is not provided for a quality, then [QualityPrototype::crafting_machine_speed_multiplier](prototype:QualityPrototype::crafting_machine_speed_multiplier) will be used as a speed multiplier instead.

**Type:** Dictionary[`QualityID`, `double`]

**Optional:** Yes

### module_slots_quality_bonus

If value is not provided for a quality, then [QualityPrototype::crafting_machine_module_slots_bonus](prototype:QualityPrototype::crafting_machine_module_slots_bonus) will be used as a module slots bonus instead.

Does nothing if [CraftingMachinePrototype::quality_affects_module_slots](prototype:CraftingMachinePrototype::quality_affects_module_slots) is not set.

**Type:** Dictionary[`QualityID`, `ItemStackIndex`]

**Optional:** Yes

### energy_usage_quality_multiplier

Each value must be >= 0.01.

If value is not provided for a quality, then [QualityPrototype::crafting_machine_energy_usage_multiplier](prototype:QualityPrototype::crafting_machine_energy_usage_multiplier) will be used as an energy usage multiplier instead.

Does nothing if [CraftingMachinePrototype::quality_affects_energy_usage](prototype:CraftingMachinePrototype::quality_affects_energy_usage) is not set.

**Type:** Dictionary[`QualityID`, `double`]

**Optional:** Yes

