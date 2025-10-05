# LuaTechnology

One research item.

## Attributes

### force

The force this technology belongs to.

**Read type:** `LuaForce`

### name

Name of this technology.

**Read type:** `string`

### localised_name

Localised name of this technology.

**Read type:** `LocalisedString`

### localised_description

**Read type:** `LocalisedString`

### prototype

The prototype of this technology.

**Read type:** `LuaTechnologyPrototype`

### enabled

Can this technology be researched?

**Read type:** `boolean`

**Write type:** `boolean`

### visible_when_disabled

If this technology will be visible in the research GUI even though it is disabled.

**Read type:** `boolean`

**Write type:** `boolean`

### upgrade

Is this an upgrade-type research?

**Read type:** `boolean`

### researched

Has this technology been researched? Switching from `false` to `true` will trigger the technology advancement perks; switching from `true` to `false` will reverse them.

**Read type:** `boolean`

**Write type:** `boolean`

### prerequisites

Prerequisites of this technology. The result maps technology name to the [LuaTechnology](runtime:LuaTechnology) object.

**Read type:** Dictionary[`string`, `LuaTechnology`]

### successors

Successors of this technology, i.e. technologies which have this technology as a prerequisite.

**Read type:** Dictionary[`string`, `LuaTechnology`]

### research_unit_ingredients

The types of ingredients that labs will require to research this technology.

**Read type:** Array[`ResearchIngredient`]

### research_unit_count

The number of research units required for this technology.

This is multiplied by the current research cost multiplier, unless [LuaTechnologyPrototype::ignore_tech_cost_multiplier](runtime:LuaTechnologyPrototype::ignore_tech_cost_multiplier) is `true`.

**Read type:** `uint32`

### research_unit_energy

Amount of energy required to finish a unit of research.

**Read type:** `double`

### order

The string used to alphabetically sort these prototypes. It is a simple string that has no additional semantic meaning.

**Read type:** `string`

### level

The current level of this technology. For level-based technology writing to this is the same as researching the technology to the previous level. Writing the level will set [LuaTechnology::enabled](runtime:LuaTechnology::enabled) to `true`.

**Read type:** `uint32`

**Write type:** `uint32`

### research_unit_count_formula

The count formula, if this research has any. See [TechnologyUnit::count_formula](prototype:TechnologyUnit::count_formula) for details.

**Read type:** `MathExpression`

**Optional:** Yes

### saved_progress

Saved technology progress fraction as a value in range `[0, 1)`. 0 means there is no saved progress.

**Read type:** `double`

**Write type:** `double`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### reload

Reload this technology from its prototype.

### research_recursive

Research this technology and all of its prerequisites recursively.

