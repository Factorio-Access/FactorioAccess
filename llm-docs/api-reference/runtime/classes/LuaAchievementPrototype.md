# LuaAchievementPrototype

Prototype of a achievement.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### allowed_without_fight

**Read type:** `boolean`

### objective_condition

**Read type:** `string`

**Optional:** Yes

### amount

**Read type:** `uint32`

**Optional:** Yes

### limited_to_one_game

**Read type:** `boolean`

**Optional:** Yes

### within

**Read type:** `uint32`

**Optional:** Yes

### to_build

**Read type:** `LuaEntityPrototype`

**Optional:** Yes

### surface

**Read type:** `string`

**Optional:** Yes

### count

**Read type:** `uint32`

**Optional:** Yes

### more_than_manually

**Read type:** `boolean`

**Optional:** Yes

### dont_build

**Read type:** Array[`LuaEntityPrototype`]

**Optional:** Yes

### excluded

**Read type:** Array[`LuaEntityPrototype`]

**Optional:** Yes

### included

**Read type:** Array[`LuaEntityPrototype`]

**Optional:** Yes

### dont_research

**Read type:** Array[`LuaItemPrototype`]

**Optional:** Yes

### research_with

**Read type:** Array[`LuaItemPrototype`]

**Optional:** Yes

### last_hour_only

**Read type:** `boolean`

**Optional:** Yes

### minimum_energy_produced

**Read type:** `double`

**Optional:** Yes

### armor

**Read type:** `LuaItemPrototype`

**Optional:** Yes

### alternative_armor

**Read type:** `LuaItemPrototype`

**Optional:** Yes

### limit_quality

**Read type:** `LuaQualityPrototype`

**Optional:** Yes

### damage_type

**Read type:** `LuaDamagePrototype`

**Optional:** Yes

### damage_dealer

**Read type:** Array[`LuaEntityPrototype`]

**Optional:** Yes

### to_kill

**Read type:** Array[`LuaEntityPrototype`]

**Optional:** Yes

### personally

**Read type:** `boolean`

**Optional:** Yes

### in_vehicle

**Read type:** `boolean`

**Optional:** Yes

### type_to_kill

**Read type:** `string`

**Optional:** Yes

### not_to_kill

**Read type:** `LuaEntityPrototype`

**Optional:** Yes

### type_not_to_kill

**Read type:** `string`

**Optional:** Yes

### module

**Read type:** Array[`LuaItemPrototype`]

**Optional:** Yes

### limit_equip_quality

**Read type:** `LuaQualityPrototype`

**Optional:** Yes

### minimum_damage

**Read type:** `float`

**Optional:** Yes

### should_survive

**Read type:** `boolean`

**Optional:** Yes

### type_of_dealer

**Read type:** `string`

**Optional:** Yes

### item_product

**Read type:** `LuaItemPrototype`

**Optional:** Yes

### quality

**Read type:** `LuaQualityPrototype`

**Optional:** Yes

### fluid_product

**Read type:** `LuaFluidPrototype`

**Optional:** Yes

### technology

**Read type:** `LuaTechnologyPrototype`

**Optional:** Yes

### research_all

**Read type:** `boolean`

**Optional:** Yes

### science_pack

**Read type:** `LuaItemPrototype`

**Optional:** Yes

### ammo_type

**Read type:** `LuaItemPrototype`

**Optional:** Yes

### minimum_distance

**Read type:** `double`

**Optional:** Yes

### to_use

**Read type:** `LuaItemPrototype`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

