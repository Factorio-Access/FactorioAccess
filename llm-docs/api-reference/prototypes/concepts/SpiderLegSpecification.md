# SpiderLegSpecification

Used by [SpiderEngineSpecification](prototype:SpiderEngineSpecification) for [SpiderVehiclePrototype](prototype:SpiderVehiclePrototype).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### leg

Name of a [SpiderLegPrototype](prototype:SpiderLegPrototype).

**Type:** `EntityID`

**Required:** Yes

### mount_position

Projected offset from the center of the spider's elevated torso to the point where the leg connects to the body of the spider when the spider is facing due north.

This offset should already be projected, meaning that it should apply the camera's 45 degree overhead angle, same as the spider's torso sprites should. If this mount position rotates with the spider's torso and the torso sprite(s) apply projection, the mount position will automatically account for the camera projection when rotating. See [RotatedAnimation::apply_projection](prototype:RotatedAnimation::apply_projection).

If the spider's torso sprites do not apply projection, then this mount_position should not apply projection either.

This value rotates with the spider's orientation, which is rounded to match either the spider torso's [SpiderTorsoGraphicsSet::base_animation](prototype:SpiderTorsoGraphicsSet::base_animation) directions or if not base sprite is defined, its [SpiderTorsoGraphicsSet::animation](prototype:SpiderTorsoGraphicsSet::animation) directions if defined.

**Type:** `Vector`

**Required:** Yes

### ground_position

The unprojected offset from the center of the spider's non-elevated torso to the position where the leg touches the ground when the spider is facing due north.

This value rotates with the spider's orientation, which is rounded to match either the spider torso's [SpiderTorsoGraphicsSet::base_animation](prototype:SpiderTorsoGraphicsSet::base_animation) directions or if not base sprite is defined, its [SpiderTorsoGraphicsSet::animation](prototype:SpiderTorsoGraphicsSet::animation) directions if defined.

**Type:** `Vector`

**Required:** Yes

### leg_hit_the_ground_trigger

Triggers to activate whenever the leg hits the ground, even if the owning spider is actively attacking an entity. For triggers, the source is the leg entity and the target is the leg's current position. Certain effects may not raise as desired, e.g. `"push-back"` does nothing.

**Type:** `TriggerEffect`

**Optional:** Yes

### leg_hit_the_ground_when_attacking_trigger

Triggers to activate whenever the leg hits the ground and the owning spider is actively attacking an entity. These effects will trigger after `leg_hit_the_ground_trigger` have triggered. For triggers, the source is the let entity and the target is the leg's current position. Certain effects may not raise as desired.

**Type:** `TriggerEffect`

**Optional:** Yes

### walking_group

The walking group this leg belongs to. Legs in the same walking group move or stay still at the same time, according to the engine that drives them. Walking groups must start at 1 and increment upward without skipping any numbers. If all legs are part of the same walking_group, they will all move simultaneously.

**Type:** `uint8`

**Required:** Yes

