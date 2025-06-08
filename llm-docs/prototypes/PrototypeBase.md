# PrototypeBase

The abstract base for prototypes. PrototypeBase defines the common features of prototypes, such as localization and order.

## Properties

### Mandatory Properties

#### name

**Type:** `string`

Unique textual identification of the prototype. May only contain alphanumeric characters, dashes and underscores. May not exceed a length of 200 characters.

For a list of all names used in vanilla, see [data.raw](https://wiki.factorio.com/Data.raw).

#### type

**Type:** `string`

Specifies the kind of prototype this is.

For a list of all possible types, see the [prototype overview](prototype:prototypes).

### Optional Properties

#### factoriopedia_description

**Type:** `LocalisedString`

Provides additional description used in factoriopedia.

#### factoriopedia_simulation

**Type:** `SimulationDefinition`

The simulation shown when looking at this prototype in the Factoriopedia GUI.

#### hidden

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### hidden_in_factoriopedia

**Type:** `boolean`



**Default:** `Value of `hidden``

#### localised_description

**Type:** `LocalisedString`

Overwrites the description set in the [locale file](https://wiki.factorio.com/Tutorial:Localisation). The description is usually shown in the tooltip of the prototype.

#### localised_name

**Type:** `LocalisedString`

Overwrites the name set in the [locale file](https://wiki.factorio.com/Tutorial:Localisation). Can be used to easily set a procedurally-generated name because the LocalisedString format allows to insert parameters into the name directly from the Lua script.

#### order

**Type:** `Order`

Used to order prototypes in inventory, recipes and GUIs. May not exceed a length of 200 characters.

**Default:** `{'complex_type': 'literal', 'value': ''}`

#### parameter

**Type:** `boolean`

Whether the prototype is a special type which can be used to parametrize blueprints and doesn't have other function.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### subgroup

**Type:** `ItemSubGroupID`

The name of an [ItemSubGroup](prototype:ItemSubGroup).

