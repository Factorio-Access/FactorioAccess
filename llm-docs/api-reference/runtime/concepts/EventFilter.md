# EventFilter

Used to filter out irrelevant event callbacks in a performant way.

Filters are always used as an array of filters of a specific type. Every filter can only be used with its corresponding event, and different types of event filters can not be mixed.

**Type:** Array[`LuaSegmentedUnitDiedEventFilter` | `LuaScriptRaisedTeleportedEventFilter` | `LuaPreRobotMinedEntityEventFilter` | `LuaScriptRaisedBuiltEventFilter` | `LuaPlatformMinedEntityEventFilter` | `LuaRobotBuiltEntityEventFilter` | `LuaPrePlayerMinedEntityEventFilter` | `LuaEntityDeconstructionCancelledEventFilter` | `LuaPreGhostUpgradedEventFilter` | `LuaPlatformBuiltEntityEventFilter` | `LuaPrePlatformMinedEntityEventFilter` | `LuaEntityClonedEventFilter` | `LuaPlayerRepairedEntityEventFilter` | `LuaPostEntityDiedEventFilter` | `LuaScriptRaisedDestroySegmentedUnitEventFilter` | `LuaSegmentedUnitDamagedEventFilter` | `LuaPreGhostDeconstructedEventFilter` | `LuaPlayerMinedEntityEventFilter` | `LuaSectorScannedEventFilter` | `LuaRobotMinedEntityEventFilter` | `LuaEntityMarkedForDeconstructionEventFilter` | `LuaPostSegmentedUnitDiedEventFilter` | `LuaScriptRaisedReviveEventFilter` | `LuaPlayerBuiltEntityEventFilter` | `LuaUpgradeCancelledEventFilter` | `LuaEntityDamagedEventFilter` | `LuaEntityDiedEventFilter` | `LuaEntityMarkedForUpgradeEventFilter` | `LuaSegmentedUnitCreatedEventFilter` | `LuaScriptRaisedDestroyEventFilter`]

