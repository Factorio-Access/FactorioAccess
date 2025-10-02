# AchievementPrototypeWithCondition

**Parent:** [AchievementPrototype](AchievementPrototype.md)
**Abstract:** Yes

## Properties

### objective_condition

The condition that needs to be met to receive the achievement. Required for `"complete-objective-achievement"`, `"dont-build-entity-achievement"`, and `"dont-craft-manually-achievement"`. Not allowed for `"dont-kill-manually-achievement"` and `"dont-research-before-researching-achievement"`. Only allowed for `"dont-use-entity-in-energy-production-achievement"` if `"last_hour_only"` is `false`.

**Type:** `"game-finished"` | `"rocket-launched"` | `"late-research"`

**Optional:** Yes

