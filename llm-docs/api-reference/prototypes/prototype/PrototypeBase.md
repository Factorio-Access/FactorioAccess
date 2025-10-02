# PrototypeBase

The abstract base for prototypes. PrototypeBase defines the common features of prototypes, such as localization and order.

**Abstract:** Yes

## Properties

### type

Specifies the kind of prototype this is.

For a list of all possible types, see the [prototype overview](prototype:prototypes).

**Type:** `string`

**Required:** Yes

### name

Unique textual identification of the prototype. May only contain alphanumeric characters, dashes and underscores. May not exceed a length of 200 characters.

For a list of all names used in vanilla, see [data.raw](https://wiki.factorio.com/Data.raw).

**Type:** `string`

**Required:** Yes

### order

Used to order prototypes in inventory, recipes and GUIs. May not exceed a length of 200 characters.

**Type:** `Order`

**Optional:** Yes

**Default:** ""

### localised_name

Overwrites the name set in the [locale file](https://wiki.factorio.com/Tutorial:Localisation). Can be used to easily set a procedurally-generated name because the LocalisedString format allows to insert parameters into the name directly from the Lua script.

**Type:** `LocalisedString`

**Optional:** Yes

### localised_description

Overwrites the description set in the [locale file](https://wiki.factorio.com/Tutorial:Localisation). The description is usually shown in the tooltip of the prototype.

**Type:** `LocalisedString`

**Optional:** Yes

### factoriopedia_description

Provides additional description used in factoriopedia.

**Type:** `LocalisedString`

**Optional:** Yes

### subgroup

The name of an [ItemSubGroup](prototype:ItemSubGroup).

**Type:** `ItemSubGroupID`

**Optional:** Yes

### hidden

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### hidden_in_factoriopedia

**Type:** `boolean`

**Optional:** Yes

**Default:** "Value of `hidden`"

### parameter

Whether the prototype is a special type which can be used to parametrize blueprints and doesn't have other function.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### factoriopedia_simulation

The simulation shown when looking at this prototype in the Factoriopedia GUI.

**Type:** `SimulationDefinition`

**Optional:** Yes

