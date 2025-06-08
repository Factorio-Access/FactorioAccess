# EntityPrototypeFlags

An array containing the following values.

If an entity is a [building](runtime:LuaEntityPrototype::is_building) and has the `"player-creation"` flag set, it is considered for multiple enemy/unit behaviors:

- Autonomous enemy attacks (usually triggered by pollution) can only attack within chunks that contain at least one entity that is both a building and a player-creation.

- Enemy expansion considers entities that are both buildings and player-creations as "enemy" entities that may block expansion.

