# Item Weight - Auxiliary Docs | Factorio

Factorio.com|Forums|Wiki|Mod Portal|API Docs[Prototype](../index-prototype.html)|[Runtime](../index-runtime.html)|Auxiliary

 Factorio Auxiliary DocsVersion 2.0.55 

[Home](../index-auxiliary.html) / Item Weight><

Item Weight
An item's [weight](../prototypes/ItemPrototype.html#weight) is used to determine how many of it will fit on a rocket to supply a space platform. It can either be set manually or be calculated automatically based on its recipe(s). This page describes the algorithm for this automatic calculation.
Algorithm
If an item has the `"only-in-cursor"` and `"spawnable"` [flags](../types/ItemPrototypeFlags.html), its weight will be `0`.

If an item has no recipe to produce it, it'll fall back to the [default item weight](../prototypes/UtilityConstants.html#default_item_weight).

The game starts by calculating the _'recipe weight'_ of the item's recipe. If an item has multiple recipes, it picks the first recipe, according to the sorting described at the [bottom](#recipe-ordering) of this page. The recipe weight is then calculated by iterating over all ingredients:
For each item ingredient, the weight is increased by `item_weight * item_ingredient_count`. Note that to do this, it needs to determine the weight of all ingredients first. If this results in a recipe loop, it will fall back to the [default item weight](../prototypes/UtilityConstants.html#default_item_weight) for that item.For each fluid ingredient, the weight is increased by `fluid_ingredient_amount * 100`.

If the resulting recipe weight is `0`, the item's weight will fall back to the [default item weight](../prototypes/UtilityConstants.html#default_item_weight).

The game then determines the _product count_ of the recipe by iterating all products and adding up the expected (ie. after probabilities) count for all item products. Fluid products are skipped.

If the recipe's product count is `0`, the item's weight will fall back to the [default item weight](../prototypes/UtilityConstants.html#default_item_weight).

Next, an _intermediate result_ will be determined as `(recipe_weight / product_count) * ingredient_to_weight_coefficient` (see [ingredient_to_weight_coefficient](../prototypes/ItemPrototype.html#ingredient_to_weight_coefficient), which defaults to `0.5`).

Following this, if a recipe doesn't support productivity, its _simple result_ is determined as `rocket_lift_weight / stack_size` (see [rocket_lift_weight](../prototypes/UtilityConstants.html#rocket_lift_weight) and [stack_size](../prototypes/ItemPrototype.html#stack_size)). If this simple result is larger than or equal to the intermediate result, it becomes the item's weight.

Otherwise, the game determines the amount of stacks that would result from the intermediate result as `rocket_lift_weight / intermediate_result / stack_size`. If this amount is less than or equal to `1`, the intermediate result becomes the item's weight. Else, the item's weight is set to `rocket_lift_weight / floor(stack_amount) / stack_size`.
Example
This is an example of how the `electronic-circuit` item gets its weight. Note that because this algorithm has many branching paths, this one example doesn't cover all of them.

-- the global default_item_weight is 100
-- the global rocket_lift_weight is 1000000
-- the item has an ingredient_to_weight_coefficient of 0.28

The electronic circuit item has a recipe of the same name, which is thus used for calculating the item weight.

-- electronic circuit recipe ingredients and weights
ingredients = {
    {type = "item", name = "iron-plate", amount = 1},  -- weight of 1000
    {type = "item", name = "copper-cable", amount = 3}  -- weight of 250
}
-- the recipe's weight is thus: 1 * 1000 + 3 * 250 = 1750

-- electronic circuit recipe products
results = { {type="item", name="electronic-circuit", amount=1} }
-- the recipe's product count is thus 1

The recipe weight and product count is more than `0`, so we continue on.

The intermediate result is then determined to be `1750 / 1 * 0.28 = 490`.

The recipe supports productivity, so the simple result branch is skipped.

The stack count is determined to be `1000000 / 490 / 200 = 10.2`. This is bigger than `1`, so we continue on.

The final weight is thus determined to be `1000000 / floor(10.2) / 200 = 500`.
Recipe Ordering
Items can have multiple recipes to produce them. These recipes are ordered in a particular way to determine which one is used for determining item weight.

Note that recipes that are [hidden](../prototypes/PrototypeBase.html#hidden) or don't [allow_decomposition](../prototypes/RecipePrototype.html#allow_decomposition) are not considered for this use case.

The sorting works by considering the following attributes in order, preferring recipes that fulfill them:
- The name of the recipe is identical to the item name.
The recipe is _not_ using the item as a catalyst.The recipe can be used as an [intermediate](../prototypes/RecipePrototype.html#allow_as_intermediate) while hand-crafting.The recipe's [category](../prototypes/RecipePrototype.html#category), [subgroup](../prototypes/PrototypeBase.html#subgroup), then [order](../prototypes/PrototypeBase.html#order).
 

Defines|<

## General Topics
[Data Lifecycle](data-lifecycle.html)[Storage](storage.html)[Migrations](migrations.html)[Libraries](libraries.html)[Prototype Inheritance Tree](prototype-tree.html)[Noise Expressions](noise-expressions.html)[Instrument Mode](instrument.html)Item Weight
## JSON Docs
[Runtime JSON Format](json-docs-runtime.html)[Prototype JSON Format](json-docs-prototype.html)

[ Defines](../defines.html)[alert_type](../defines.html#defines.alert_type)[behavior_result](../defines.html#defines.behavior_result)[build_check_type](../defines.html#defines.build_check_type)[build_mode](../defines.html#defines.build_mode)[cargo_destination](../defines.html#defines.cargo_destination)[chain_signal_state](../defines.html#defines.chain_signal_state)[chunk_generated_status](../defines.html#defines.chunk_generated_status)[command](../defines.html#defines.command)[compound_command](../defines.html#defines.compound_command)[control_behavior](../defines.html#defines.control_behavior)[controllers](../defines.html#defines.controllers)[deconstruction_item](../defines.html#defines.deconstruction_item)[default_icon_size](../defines.html#defines.default_icon_size)[difficulty](../defines.html#defines.difficulty)[direction](../defines.html#defines.direction)[disconnect_reason](../defines.html#defines.disconnect_reason)[distraction](../defines.html#defines.distraction)[entity_status](../defines.html#defines.entity_status)[entity_status_diode](../defines.html#defines.entity_status_diode)[events](../defines.html#defines.events)[flow_precision_index](../defines.html#defines.flow_precision_index)[game_controller_interaction](../defines.html#defines.game_controller_interaction)[group_state](../defines.html#defines.group_state)[gui_type](../defines.html#defines.gui_type)[input_action](../defines.html#defines.input_action)[input_method](../defines.html#defines.input_method)[inventory](../defines.html#defines.inventory)[logistic_member_index](../defines.html#defines.logistic_member_index)[logistic_mode](../defines.html#defines.logistic_mode)[logistic_section_type](../defines.html#defines.logistic_section_type)[mouse_button_type](../defines.html#defines.mouse_button_type)[moving_state](../defines.html#defines.moving_state)[print_skip](../defines.html#defines.print_skip)[print_sound](../defines.html#defines.print_sound)[prototypes](../defines.html#defines.prototypes)[rail_connection_direction](../defines.html#defines.rail_connection_direction)[rail_direction](../defines.html#defines.rail_direction)[rail_layer](../defines.html#defines.rail_layer)[relative_gui_position](../defines.html#defines.relative_gui_position)[relative_gui_type](../defines.html#defines.relative_gui_type)[render_mode](../defines.html#defines.render_mode)[rich_text_setting](../defines.html#defines.rich_text_setting)[riding](../defines.html#defines.riding)[robot_order_type](../defines.html#defines.robot_order_type)[rocket_silo_status](../defines.html#defines.rocket_silo_status)[selection_mode](../defines.html#defines.selection_mode)[shooting](../defines.html#defines.shooting)[signal_state](../defines.html#defines.signal_state)[space_platform_state](../defines.html#defines.space_platform_state)[target_type](../defines.html#defines.target_type)[train_state](../defines.html#defines.train_state)[transport_line](../defines.html#defines.transport_line)[wire_connector_id](../defines.html#defines.wire_connector_id)[wire_origin](../defines.html#defines.wire_origin)[wire_type](../defines.html#defines.wire_type)

>|

 Copyright © Wube Software |[License](../license.html)|[Download](../static/archive.zip)|Feedback