# PrototypeFilter

Types `"signal"` and `"item-group"` do not support filters.

Filters are always used as an array of filters of a specific type. Every filter can only be used with its corresponding event, and different types of event filters can not be mixed.

**Type:** Array[`ModSettingPrototypeFilter` | `SpaceLocationPrototypeFilter` | `DecorativePrototypeFilter` | `TilePrototypeFilter` | `AsteroidChunkPrototypeFilter` | `ItemPrototypeFilter` | `TechnologyPrototypeFilter` | `RecipePrototypeFilter` | `AchievementPrototypeFilter` | `EquipmentPrototypeFilter` | `FluidPrototypeFilter` | `EntityPrototypeFilter`]

