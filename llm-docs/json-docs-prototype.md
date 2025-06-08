# Protoype JSON Format - Auxiliary Docs | Factorio

Factorio.com|Forums|Wiki|Mod Portal|API Docs[Prototype](../index-prototype.html)|[Runtime](../index-runtime.html)|Auxiliary

 Factorio Auxiliary DocsVersion 2.0.55 

[Home](../index-auxiliary.html) / [Prototype JSON Format](json-docs-prototype.html)><

Prototype JSON Format
The prototype API documentation is available in a machine-readable [JSON format](../prototype-api.json). It allows for the creation of developer tools that provide code completion and related functionality. This page documents the structure of this format.

The current `api_version` that these docs reflect is `6`, which was introduced with Factorio `2.0.5`. See [Changelog](#Changelog).
General notes
Some notes that apply to the format in general:
If a member would be `null`, it is omitted from the JSON instead.Descriptions are generally empty (`""`) instead of `null` if they could exist on any given member, but just happen to be empty (ex. an empty attribute description).Every list is sorted alphabetically by name. To replicate the order seen on the website, it can be sorted by the `order` property of its members.Text (descriptions, examples, etc.) is formatted as [Markdown](https://daringfireball.net/projects/markdown/), which includes links, inline code, and code blocks. More on how links work right below.
Link format
All text can contain Markdown-type links. There are two broad categories for these: hyperlinks that link to any external website, and internal links that refer to another part of this documentation. All of them will have a title that should be displayed as the link's text.
External links work like standard Markdown links, meaning they always start with `https://`, and are followed by the URL. Example: `[Factorio](https://factorio.com)`.Internal links are a bit more complex. They aren't valid hyperlinks, but instead use a custom shorthand format to refer to specific parts of the API. This format has three main parts:They always start with either `runtime:` or `prototype:`, indicating the stage that is linked to. The two stages are separate namespaces, as there would be naming conflicts otherwise. So this first part indicates whether to look for the API member among classes, events, etc., or among prototypes and types.The second part is the name of the API member being linked to. What this can be depends on the stage that's indicated beforehand. Examples would be `LuaGuiElement` or `on_player_created` for `runtime:`, and `RecipePrototype` or `EnergySource` for `prototype:`.Note that this can be the name of some stage-specific auxiliary pages instead. Namely, 'classes', 'events', 'concepts', for `runtime:`, and 'prototypes', 'types' for `prototype:`.
The third, optional part of an internal link can specify a certain sub-member to refer to. Its format is `::<name>`, where name is the name of a class method or attribute, or a prototype/type property. It is invalid for any other member type.

Examples:
`[LuaGuiElement](runtime:LuaGuiElement)` links to the `LuaGuiElement` class.`[results](prototype:RecipePrototype::results)` links to the `results` property of the `RecipePrototype` prototype.`[concepts](runtime:concepts)` links to the [Concepts](../concepts.html) overview page.
Top level members
The format has some top level members indicating the context of the format. These are:
`application` :: [string](#string): The application this documentation is for. Will always be `"factorio"`.`application_version` :: [string](#string): The version of the game that this documentation is for. An example would be `"1.1.90"`.`api_version` :: [number](#number): The version of the machine-readable format itself. It is incremented every time the format changes. The version this documentation reflects is stated at the top.`stage` :: [string](#string): Indicates the stage this documentation is for. Will always be `"prototype"` (as opposed to `"runtime"`; see the [data lifecycle](data-lifecycle.html) for more detail).

Then, there are several top level members that contain the API documentation itself, organized by their various types. These are:
`prototypes` :: array[[Prototype](#Protoype)]: The list of prototypes that can be created. Equivalent to the [prototypes](../prototypes.html) page.`types` :: array[[Type](#Concept)]: The list of types (concepts) that the format uses. Equivalent to the [types](../types.html) page.`defines` :: array[[Define](#Define)]: The list of defines that the game uses. Equivalent to the [defines](../defines.html) page.
#### BasicMember

Several API members follow a common format for their basic fields. This is indicated by `inherits from BasicMember` in their title. It includes the following fields:
`name` :: [string](#string): The name of the member.`order` :: [number](#number): The order of the member as shown in the HTML.`description` :: [string](#string): The text description of the member. Can be `''`, but never `null`.`lists` :: array[[string](#string)] (optional): A list of Markdown lists to provide additional information. Usually contained in a spoiler tag.`examples` :: array[[string](#string)] (optional): A list of code-only examples about the member.`images` :: array[[Image](#Image)] (optional): A list of illustrative images shown next to the member.
Top level typesPrototype inherits from BasicMember`visibility` :: array[[string](#string)] (optional): The list of game expansions needed to use this prototype. If not present, no restrictions apply. Possible values: `"space_age"`.`parent` :: [string](#string) (optional): The name of the prototype's parent, if any.`abstract` :: [boolean](#boolean): Whether the prototype is abstract, and thus can't be created directly.`typename` :: [string](#string) (optional): The type name of the prototype, like `"boiler"`. `null` for abstract prototypes.`instance_limit` :: [number](#number) (optional): The maximum number of instances of this prototype that can be created, if any.`deprecated` :: [boolean](#boolean): Whether the prototype is deprecated and shouldn't be used anymore.`properties` :: array[[Property](#Property)]: The list of properties that the prototype has. May be an empty array.`custom_properties` :: [CustomProperties](#CustomProperties) (optional): A special set of properties that the user can add an arbitrary number of. Specifies the type of the key and value of the custom property.
Type / Concept inherits from BasicMember`parent` :: [string](#string) (optional): The name of the type's parent, if any.`abstract` :: [boolean](#boolean): Whether the type is abstract, and thus can't be created directly.`inline` :: [boolean](#boolean): Whether the type is inlined inside another property's description.`type` :: [Type](#Type): The type of the type/concept (Yes, this naming is confusing). Either a proper [Type](#Type), or the string `"builtin"`, indicating a fundamental type like `string` or `number`.`properties` :: array[[Property](#Property)] (optional): The list of properties that the type has, if its type includes a struct. `null` otherwise.
Define inherits from BasicMember
Defines can be recursive in nature, meaning one Define can have multiple sub-Defines that have the same structure. These are singled out as `subkeys` instead of `values`.
`values` :: array[[DefineValue](#DefineValue)] (optional): The members of the define.`subkeys` :: array[[Define](#Define)] (optional): A list of sub-defines.
Common structures
Several data structures are used in different parts of the format, which is why they are documented separately to avoid repetition.
Property inherits from BasicMember`visibility` :: array[[string](#string)] (optional): The list of game expansions needed to use this property. If not present, no restrictions apply. Possible values: `"space_age"`.`alt_name` :: [string](#string) (optional): An alternative name for the property. Either this or `name` can be used to refer to the property.`override` :: [boolean](#boolean): Whether the property overrides a property of the same name in one of its parents.`type` :: [Type](#Type): The type of the property.`optional` :: [boolean](#boolean): Whether the property is optional and can be omitted. If so, it falls back to a default value.`default` :: union[[string](#string), [Literal](#Literal)] (optional): The default value of the property. Either a textual description or a literal value.
#### Type

A type field can be a [string](#string), in which case that string is the simple type. Otherwise, a type is a table:
`complex_type` :: [string](#string): A string denoting the kind of complex type.

Depending on `complex_type`, there are additional members:
`array`:`value` :: [Type](#Type): The type of the elements of the array.
`dictionary`:`key` :: [Type](#Type): The type of the keys of the dictionary.`value` :: [Type](#Type): The type of the values of the dictionary.
`tuple`:`values` :: array[[Type](#Type)]: The types of the members of this tuple in order.
`union`:`options` :: array[[Type](#Type)]: A list of all compatible types for this type.`full_format` :: [boolean](#boolean): Whether the options of this union have a description or not.
`literal`:`value` :: union[[string](#string), [number](#number), [boolean](#boolean)]: The value of the literal.`description` :: [string](#string) (optional): The text description of the literal, if any.
`type`:`value` :: [Type](#Type): The actual type. This format for types is used when they have descriptions attached to them.`description` :: [string](#string): The text description of the type.
`struct`: Special type with no additional members. The `properties` themselves are listed on the API member that uses this type.
#### Literal

A literal has the same format as a [Type](#Type) that is complex and of type `literal`.

Example: `{"complex_type": "literal", "value": 2}`
#### Image
`filename` :: [string](#string): The name of the image file to display. These files are placed into the `/static/images/` directory.`caption` :: [string](#string) (optional): The explanatory text to show attached to the image.
#### Custom Properties
`description` :: [string](#string): The text description of the property.`lists` :: array[[string](#string)] (optional): A list of Markdown lists to provide additional information. Usually contained in a spoiler tag.`examples` :: array[[string](#string)] (optional): A list of code-only examples about the property.`images` :: array[[Image](#Image)] (optional): A list of illustrative images shown next to the property.`key_type` :: [Type](#Type): The type of the key of the custom property.`value_type` :: [Type](#Type): The type of the value of the custom property.
#### DefineValue
`name` :: [string](#string): The name of the define value.`order` :: [number](#number): The order of the member as shown in the HTML.`description` :: [string](#string): The text description of the define value.
Basic types`string`
A string, which can be an identifier for something, or a description-like text formatted in Markdown.
`number`
A number, which could either be an integer or a floating point number, as JSON doesn't distinguish between those two.
`boolean`
A boolean value, which is either `true` or `false`.
### Changelog

Changes for version 6, introduced with Factorio 2.0.5:
Added `defines` as a top level member.

Changes for version 5, introduced with Factorio 1.1.108:
Added the `visibility` field to prototypes and properties. Unused before Factorio 2.0.

Changes for version 4, introduced with Factorio 1.1.89:
- First release

 

Defines|<

## General Topics
[Data Lifecycle](data-lifecycle.html)[Storage](storage.html)[Migrations](migrations.html)[Libraries](libraries.html)[Prototype Inheritance Tree](prototype-tree.html)[Noise Expressions](noise-expressions.html)[Instrument Mode](instrument.html)[Item Weight](item-weight.html)
## JSON Docs
[Runtime JSON Format](json-docs-runtime.html)Prototype JSON Format

[ Defines](../defines.html)[alert_type](../defines.html#defines.alert_type)[behavior_result](../defines.html#defines.behavior_result)[build_check_type](../defines.html#defines.build_check_type)[build_mode](../defines.html#defines.build_mode)[cargo_destination](../defines.html#defines.cargo_destination)[chain_signal_state](../defines.html#defines.chain_signal_state)[chunk_generated_status](../defines.html#defines.chunk_generated_status)[command](../defines.html#defines.command)[compound_command](../defines.html#defines.compound_command)[control_behavior](../defines.html#defines.control_behavior)[controllers](../defines.html#defines.controllers)[deconstruction_item](../defines.html#defines.deconstruction_item)[default_icon_size](../defines.html#defines.default_icon_size)[difficulty](../defines.html#defines.difficulty)[direction](../defines.html#defines.direction)[disconnect_reason](../defines.html#defines.disconnect_reason)[distraction](../defines.html#defines.distraction)[entity_status](../defines.html#defines.entity_status)[entity_status_diode](../defines.html#defines.entity_status_diode)[events](../defines.html#defines.events)[flow_precision_index](../defines.html#defines.flow_precision_index)[game_controller_interaction](../defines.html#defines.game_controller_interaction)[group_state](../defines.html#defines.group_state)[gui_type](../defines.html#defines.gui_type)[input_action](../defines.html#defines.input_action)[input_method](../defines.html#defines.input_method)[inventory](../defines.html#defines.inventory)[logistic_member_index](../defines.html#defines.logistic_member_index)[logistic_mode](../defines.html#defines.logistic_mode)[logistic_section_type](../defines.html#defines.logistic_section_type)[mouse_button_type](../defines.html#defines.mouse_button_type)[moving_state](../defines.html#defines.moving_state)[print_skip](../defines.html#defines.print_skip)[print_sound](../defines.html#defines.print_sound)[prototypes](../defines.html#defines.prototypes)[rail_connection_direction](../defines.html#defines.rail_connection_direction)[rail_direction](../defines.html#defines.rail_direction)[rail_layer](../defines.html#defines.rail_layer)[relative_gui_position](../defines.html#defines.relative_gui_position)[relative_gui_type](../defines.html#defines.relative_gui_type)[render_mode](../defines.html#defines.render_mode)[rich_text_setting](../defines.html#defines.rich_text_setting)[riding](../defines.html#defines.riding)[robot_order_type](../defines.html#defines.robot_order_type)[rocket_silo_status](../defines.html#defines.rocket_silo_status)[selection_mode](../defines.html#defines.selection_mode)[shooting](../defines.html#defines.shooting)[signal_state](../defines.html#defines.signal_state)[space_platform_state](../defines.html#defines.space_platform_state)[target_type](../defines.html#defines.target_type)[train_state](../defines.html#defines.train_state)[transport_line](../defines.html#defines.transport_line)[wire_connector_id](../defines.html#defines.wire_connector_id)[wire_origin](../defines.html#defines.wire_origin)[wire_type](../defines.html#defines.wire_type)

>|

 Copyright © Wube Software |[License](../license.html)|[Download](../static/archive.zip)|Feedback