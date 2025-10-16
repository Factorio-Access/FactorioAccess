# LuaTechnologyPrototype

A Technology prototype.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### enabled

If this technology prototype is enabled by default (enabled at the beginning of a game).

**Read type:** `boolean`

### essential

If this technology prototype is essential, meaning it is shown in the condensed technology graph.

**Read type:** `boolean`

### visible_when_disabled

If this technology will be visible in the research GUI even though it is disabled.

**Read type:** `boolean`

### ignore_tech_cost_multiplier

If this technology ignores the technology cost multiplier setting.

[LuaTechnologyPrototype::research_unit_count](runtime:LuaTechnologyPrototype::research_unit_count) will already take this setting into account.

**Read type:** `boolean`

### upgrade

If the is technology prototype is an upgrade to some other technology.

**Read type:** `boolean`

### prerequisites

Prerequisites of this technology. The result maps technology name to the [LuaTechnologyPrototype](runtime:LuaTechnologyPrototype) object.

**Read type:** Dictionary[`string`, `LuaTechnologyPrototype`]

### successors

Successors of this technology, i.e. technologies which have this technology as a prerequisite.

**Read type:** Dictionary[`string`, `LuaTechnologyPrototype`]

### research_unit_ingredients

The types of ingredients that labs will require to research this technology.

**Read type:** Array[`ResearchIngredient`]

### effects

Effects applied when this technology is researched.

**Read type:** Array[`TechnologyModifier`]

### research_unit_count

The number of research units required for this technology.

This is multiplied by the current research cost multiplier, unless [LuaTechnologyPrototype::ignore_tech_cost_multiplier](runtime:LuaTechnologyPrototype::ignore_tech_cost_multiplier) is `true`.

**Read type:** `uint32`

### research_unit_energy

Amount of energy required to finish a unit of research.

**Read type:** `double`

### level

The level of this research.

**Read type:** `uint32`

### max_level

The max level of this research.

**Read type:** `uint32`

### research_unit_count_formula

The count formula, if this research has any. See [TechnologyUnit::count_formula](prototype:TechnologyUnit::count_formula) for details.

**Read type:** `MathExpression`

**Optional:** Yes

### research_trigger

The trigger that will research this technology if any.

**Read type:** `ResearchTrigger`

**Optional:** Yes

### allows_productivity

**Read type:** `boolean`

### factoriopedia_alternative

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

**Read type:** `LuaTechnologyPrototype`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

