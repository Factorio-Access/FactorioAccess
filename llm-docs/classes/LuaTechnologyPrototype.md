# LuaTechnologyPrototype

A Technology prototype.

**Parent:** `LuaPrototypeBase`

## Attributes

### allows_productivity

**Type:** `boolean` _(read-only)_



### effects

**Type:** ``TechnologyModifier`[]` _(read-only)_

Effects applied when this technology is researched.

### enabled

**Type:** `boolean` _(read-only)_

If this technology prototype is enabled by default (enabled at the beginning of a game).

### essential

**Type:** `boolean` _(read-only)_

If this technology prototype is essential, meaning it is shown in the condensed technology graph.

### factoriopedia_alternative

**Type:** `LuaTechnologyPrototype` _(read-only)_

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

### ignore_tech_cost_multiplier

**Type:** `boolean` _(read-only)_

If this technology ignores the technology cost multiplier setting.

[LuaTechnologyPrototype::research_unit_count](runtime:LuaTechnologyPrototype::research_unit_count) will already take this setting into account.

### level

**Type:** `uint` _(read-only)_

The level of this research.

### max_level

**Type:** `uint` _(read-only)_

The max level of this research.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### prerequisites

**Type:** `dictionary<`string`, `LuaTechnologyPrototype`>` _(read-only)_

Prerequisites of this technology. The result maps technology name to the [LuaTechnologyPrototype](runtime:LuaTechnologyPrototype) object.

### research_trigger

**Type:** `ResearchTrigger` _(read-only)_

The trigger that will research this technology if any.

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

### successors

**Type:** `dictionary<`string`, `LuaTechnologyPrototype`>` _(read-only)_

Successors of this technology, i.e. technologies which have this technology as a prerequisite.

### upgrade

**Type:** `boolean` _(read-only)_

If the is technology prototype is an upgrade to some other technology.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### visible_when_disabled

**Type:** `boolean` _(read-only)_

If this technology will be visible in the research GUI even though it is disabled.

