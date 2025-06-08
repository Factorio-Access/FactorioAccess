# LuaTechnology

One research item.

## Methods

### reload

Reload this technology from its prototype.

### research_recursive

Research this technology and all of its prerequisites recursively.

## Attributes

### enabled

**Type:** `boolean`

Can this technology be researched?

### force

**Type:** `LuaForce` _(read-only)_

The force this technology belongs to.

### level

**Type:** `uint`

The current level of this technology. For level-based technology writing to this is the same as researching the technology to the previous level. Writing the level will set [LuaTechnology::enabled](runtime:LuaTechnology::enabled) to `true`.

### localised_description

**Type:** `LocalisedString` _(read-only)_



### localised_name

**Type:** `LocalisedString` _(read-only)_

Localised name of this technology.

### name

**Type:** `string` _(read-only)_

Name of this technology.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### order

**Type:** `string` _(read-only)_

The string used to alphabetically sort these prototypes. It is a simple string that has no additional semantic meaning.

### prerequisites

**Type:** `dictionary<`string`, `LuaTechnology`>` _(read-only)_

Prerequisites of this technology. The result maps technology name to the [LuaTechnology](runtime:LuaTechnology) object.

### prototype

**Type:** `LuaTechnologyPrototype` _(read-only)_

The prototype of this technology.

### research_unit_count

**Type:** `uint` _(read-only)_

The number of research units required for this technology.

This is multiplied by the current research cost multiplier, unless [LuaTechnologyPrototype::ignore_tech_cost_multiplier](runtime:LuaTechnologyPrototype::ignore_tech_cost_multiplier) is `true`.

### research_unit_count_formula

**Type:** `MathExpression` _(read-only)_

The count formula, if this research has any. See [TechnologyUnit::count_formula](prototype:TechnologyUnit::count_formula) for details.

### research_unit_energy

**Type:** `double` _(read-only)_

Amount of energy required to finish a unit of research.

### research_unit_ingredients

**Type:** ``ResearchIngredient`[]` _(read-only)_

The types of ingredients that labs will require to research this technology.

### researched

**Type:** `boolean`

Has this technology been researched? Switching from `false` to `true` will trigger the technology advancement perks; switching from `true` to `false` will reverse them.

### saved_progress

**Type:** `double`

Saved technology progress fraction as a value in range `[0, 1)`. 0 means there is no saved progress.

### successors

**Type:** `dictionary<`string`, `LuaTechnology`>` _(read-only)_

Successors of this technology, i.e. technologies which have this technology as a prerequisite.

### upgrade

**Type:** `boolean` _(read-only)_

Is this an upgrade-type research?

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### visible_when_disabled

**Type:** `boolean`

If this technology will be visible in the research GUI even though it is disabled.

