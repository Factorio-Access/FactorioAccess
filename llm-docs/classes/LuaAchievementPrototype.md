# LuaAchievementPrototype

Prototype of a achievement.

**Parent:** `LuaPrototypeBase`

## Attributes

### allowed_without_fight

**Type:** `boolean` _(read-only)_



### alternative_armor

**Type:** `LuaItemPrototype` _(read-only)_



### ammo_type

**Type:** `LuaItemPrototype` _(read-only)_



### amount

**Type:** `uint` _(read-only)_



### armor

**Type:** `LuaItemPrototype` _(read-only)_



### count

**Type:** `uint` _(read-only)_



### damage_dealer

**Type:** ``LuaEntityPrototype`[]` _(read-only)_



### damage_type

**Type:** `LuaDamagePrototype` _(read-only)_



### dont_build

**Type:** ``LuaEntityPrototype`[]` _(read-only)_



### dont_research

**Type:** ``LuaItemPrototype`[]` _(read-only)_



### excluded

**Type:** ``LuaEntityPrototype`[]` _(read-only)_



### fluid_product

**Type:** `LuaFluidPrototype` _(read-only)_



### in_vehicle

**Type:** `boolean` _(read-only)_



### included

**Type:** ``LuaEntityPrototype`[]` _(read-only)_



### item_product

**Type:** `LuaItemPrototype` _(read-only)_



### last_hour_only

**Type:** `boolean` _(read-only)_



### limit_equip_quality

**Type:** `LuaQualityPrototype` _(read-only)_



### limit_quality

**Type:** `LuaQualityPrototype` _(read-only)_



### limited_to_one_game

**Type:** `boolean` _(read-only)_



### minimum_damage

**Type:** `float` _(read-only)_



### minimum_distance

**Type:** `double` _(read-only)_



### minimum_energy_produced

**Type:** `double` _(read-only)_



### module

**Type:** ``string`[]` _(read-only)_



### more_than_manually

**Type:** `boolean` _(read-only)_



### not_to_kill

**Type:** `LuaEntityPrototype` _(read-only)_



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### objective_condition

**Type:** `string` _(read-only)_



### personally

**Type:** `boolean` _(read-only)_



### quality

**Type:** `LuaQualityPrototype` _(read-only)_



### research_all

**Type:** `boolean` _(read-only)_



### research_with

**Type:** ``LuaItemPrototype`[]` _(read-only)_



### science_pack

**Type:** `LuaItemPrototype` _(read-only)_



### should_survive

**Type:** `boolean` _(read-only)_



### surface

**Type:** `string` _(read-only)_



### technology

**Type:** `LuaTechnologyPrototype` _(read-only)_



### to_build

**Type:** `LuaEntityPrototype` _(read-only)_



### to_kill

**Type:** ``LuaEntityPrototype`[]` _(read-only)_



### to_use

**Type:** `LuaItemPrototype` _(read-only)_



### type_not_to_kill

**Type:** `string` _(read-only)_



### type_of_dealer

**Type:** `string` _(read-only)_



### type_to_kill

**Type:** `string` _(read-only)_



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### within

**Type:** `uint` _(read-only)_



