# LuaSpaceLocationPrototype

Prototype of a space location, such as a planet.

**Parent:** `LuaPrototypeBase`

## Attributes

### asteroid_spawn_definitions

**Type:** ``SpaceLocationAsteroidSpawnDefinition`[]` _(read-only)_



### asteroid_spawn_influence

**Type:** `double` _(read-only)_



### entities_require_heating

**Type:** `boolean` _(read-only)_



### factoriopedia_alternative

**Type:** `LuaSpaceLocationPrototype` _(read-only)_

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

### map_gen_settings

**Type:** `MapGenSettings` _(read-only)_



### map_seed_offset

**Type:** `uint` _(read-only)_



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### player_effects

**Type:** ``TriggerItem`[]` _(read-only)_



### pollutant_type

**Type:** `LuaAirbornePollutantPrototype` _(read-only)_



### position

**Type:** `MapPosition` _(read-only)_



### solar_power_in_space

**Type:** `double` _(read-only)_



### surface_properties

**Type:** `dictionary<`string`, `double`>` _(read-only)_

A mapping of the surface property name to the value.

### ticks_between_player_effects

**Type:** `uint` _(read-only)_



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

