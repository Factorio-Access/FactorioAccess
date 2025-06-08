# Migrations - Auxiliary Docs | Factorio

Factorio.com|Forums|Wiki|Mod Portal|API Docs[Prototype](../index-prototype.html)|[Runtime](../index-runtime.html)|Auxiliary

 Factorio Auxiliary DocsVersion 2.0.55 

[Home](../index-auxiliary.html) / [Migrations](migrations.html)><

Migrations
Migrations are a way to fix up a save file which was used in an older version of the game or mod. They have to be either `.lua` or `.json` files in the mod's `"migrations"` folder, depending on their purpose. They are typically used to change the type of a prototype or correct research and recipe states after changes.

The sequence in which migrations are executed is sorted by mod order first, migration file name second (using [lexicographical comparison](http://en.cppreference.com/w/cpp/algorithm/lexicographical_compare)). All JSON migrations are applied before any Lua migrations. Each save file remembers (by name) which migrations from which mods have been applied and will not apply the same migration twice. When adding a mod to an existing save, all migration scripts for that mod will be run.
JSON migrations
JSON migrations allow changing one prototype into another. This is typically used to rename a prototype. Note that when an entity prototype's name is changed, it retains its previous [unit_number](../classes/LuaEntity.html#unit_number) and any references to it saved in [storage](storage.html) stay valid. Changing an entity's type will however result in a new `unit_number` and an invalid reference in `storage`.

Ghost entities are not always able to be migrated, in which case they are removed instead. Reasons for this include a change in the type of the entity, or the entity becoming unbuildable.

JSON migrations are applied as a map is being loaded. Multiple such migrations can be applied at once. All JSON migrations are applied before any Lua migrations.
JSON Example
The `"wall"` entity and item being renamed to `"stone-wall"`:

{
  "entity":
  [
    ["wall", "stone-wall"]
  ],
  "item":
  [
    ["wall", "stone-wall"]
  ]
}

Available for migration
The following prototype types are available for migration:
- "custom-input"
- "equipment-grid"
- "entity"
- "item"
- "tile"
- "decorative"
- "recipe-category"
- "item-group"
- "item-subgroup"
- "recipe"
- "fluid"
- "ammo-category"
- "fuel-category"
- "resource-category"
- "technology"
- "noise-layer"
- "noise-expression"
- "autoplace-control"
- "equipment"
- "damage-type"
- "virtual-signal"
- "achievement"
- "module-category"
- "equipment-category"
- "mod-setting"
- "trivial-smoke"
- "shortcut"

Lua migrations
Lua migrations allow altering the loaded game state before it starts running. The global [game](../classes/LuaGameScript.html) object is available in Lua migrations, which is how the game state can be modified.

The game resets [recipes](../classes/LuaForce.html#reset_recipes) and [technologies](../classes/LuaForce.html#reset_technologies) any time mods, prototypes, or startup settings change, so this does not need to be done by migration scripts anymore.
 

Defines|<

## General Topics
[Data Lifecycle](data-lifecycle.html)[Storage](storage.html)Migrations[Libraries](libraries.html)[Prototype Inheritance Tree](prototype-tree.html)[Noise Expressions](noise-expressions.html)[Instrument Mode](instrument.html)[Item Weight](item-weight.html)
## JSON Docs
[Runtime JSON Format](json-docs-runtime.html)[Prototype JSON Format](json-docs-prototype.html)

[ Defines](../defines.html)[alert_type](../defines.html#defines.alert_type)[behavior_result](../defines.html#defines.behavior_result)[build_check_type](../defines.html#defines.build_check_type)[build_mode](../defines.html#defines.build_mode)[cargo_destination](../defines.html#defines.cargo_destination)[chain_signal_state](../defines.html#defines.chain_signal_state)[chunk_generated_status](../defines.html#defines.chunk_generated_status)[command](../defines.html#defines.command)[compound_command](../defines.html#defines.compound_command)[control_behavior](../defines.html#defines.control_behavior)[controllers](../defines.html#defines.controllers)[deconstruction_item](../defines.html#defines.deconstruction_item)[default_icon_size](../defines.html#defines.default_icon_size)[difficulty](../defines.html#defines.difficulty)[direction](../defines.html#defines.direction)[disconnect_reason](../defines.html#defines.disconnect_reason)[distraction](../defines.html#defines.distraction)[entity_status](../defines.html#defines.entity_status)[entity_status_diode](../defines.html#defines.entity_status_diode)[events](../defines.html#defines.events)[flow_precision_index](../defines.html#defines.flow_precision_index)[game_controller_interaction](../defines.html#defines.game_controller_interaction)[group_state](../defines.html#defines.group_state)[gui_type](../defines.html#defines.gui_type)[input_action](../defines.html#defines.input_action)[input_method](../defines.html#defines.input_method)[inventory](../defines.html#defines.inventory)[logistic_member_index](../defines.html#defines.logistic_member_index)[logistic_mode](../defines.html#defines.logistic_mode)[logistic_section_type](../defines.html#defines.logistic_section_type)[mouse_button_type](../defines.html#defines.mouse_button_type)[moving_state](../defines.html#defines.moving_state)[print_skip](../defines.html#defines.print_skip)[print_sound](../defines.html#defines.print_sound)[prototypes](../defines.html#defines.prototypes)[rail_connection_direction](../defines.html#defines.rail_connection_direction)[rail_direction](../defines.html#defines.rail_direction)[rail_layer](../defines.html#defines.rail_layer)[relative_gui_position](../defines.html#defines.relative_gui_position)[relative_gui_type](../defines.html#defines.relative_gui_type)[render_mode](../defines.html#defines.render_mode)[rich_text_setting](../defines.html#defines.rich_text_setting)[riding](../defines.html#defines.riding)[robot_order_type](../defines.html#defines.robot_order_type)[rocket_silo_status](../defines.html#defines.rocket_silo_status)[selection_mode](../defines.html#defines.selection_mode)[shooting](../defines.html#defines.shooting)[signal_state](../defines.html#defines.signal_state)[space_platform_state](../defines.html#defines.space_platform_state)[target_type](../defines.html#defines.target_type)[train_state](../defines.html#defines.train_state)[transport_line](../defines.html#defines.transport_line)[wire_connector_id](../defines.html#defines.wire_connector_id)[wire_origin](../defines.html#defines.wire_origin)[wire_type](../defines.html#defines.wire_type)

>|

 Copyright © Wube Software |[License](../license.html)|[Download](../static/archive.zip)|Feedback