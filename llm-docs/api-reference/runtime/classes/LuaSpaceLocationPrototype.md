# LuaSpaceLocationPrototype

Prototype of a space location, such as a planet.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### position

**Read type:** `MapPosition`

### solar_power_in_space

**Read type:** `double`

### asteroid_spawn_influence

**Read type:** `double`

### asteroid_spawn_definitions

**Read type:** Array[`SpaceLocationAsteroidSpawnDefinition`]

**Optional:** Yes

### factoriopedia_alternative

An alternative prototype that will be used to display info about this prototype in Factoriopedia.

**Read type:** `LuaSpaceLocationPrototype`

**Optional:** Yes

### map_seed_offset

**Read type:** `uint`

**Optional:** Yes

**Subclasses:** Planet

### map_gen_settings

**Read type:** `MapGenSettings`

**Optional:** Yes

**Subclasses:** Planet

### entities_require_heating

**Read type:** `boolean`

**Optional:** Yes

**Subclasses:** Planet

### pollutant_type

**Read type:** `LuaAirbornePollutantPrototype`

**Optional:** Yes

**Subclasses:** Planet

### player_effects

**Read type:** Array[`TriggerItem`]

**Optional:** Yes

**Subclasses:** Planet

### ticks_between_player_effects

**Read type:** `uint`

**Optional:** Yes

**Subclasses:** Planet

### surface_properties

A mapping of the surface property name to the value.

**Read type:** Dictionary[`string`, `double`]

**Optional:** Yes

**Subclasses:** Planet

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

