# RepairToolPrototype

A [repair pack](https://wiki.factorio.com/Repair_pack). Using the tool decreases durability to restore entity health.

**Parent:** [ToolPrototype](ToolPrototype.md)
**Type name:** `repair-tool`

## Properties

### speed

Entity health repaired per used [ToolPrototype::durability](prototype:ToolPrototype::durability). E.g. a repair tool with 5 durability and a repair speed of 2 will restore 10 health.

This is then multiplied by the [EntityWithHealthPrototype::repair_speed_modifier](prototype:EntityWithHealthPrototype::repair_speed_modifier) of the entity.

**Type:** `float`

**Required:** Yes

