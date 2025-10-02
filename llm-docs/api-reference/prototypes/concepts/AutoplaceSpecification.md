# AutoplaceSpecification

Autoplace specification is used to determine which entities are placed when generating map. Currently it is used for enemy bases, tiles, resources and other entities (trees, fishes, etc.).

Autoplace specification describe conditions for placing tiles, entities, and decoratives during surface generation. Autoplace specification defines probability of placement on any given tile and richness, which has different meaning depending on the thing being placed.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### control

Name of the [AutoplaceControl](prototype:AutoplaceControl) (row in the map generator GUI) that applies to this entity.

**Type:** `AutoplaceControlID`

**Optional:** Yes

### default_enabled

Indicates whether the thing should be placed even if [MapGenSettings](runtime:MapGenSettings) do not provide frequency/size/richness for it. (either for the specific prototype or for the control named by AutoplaceSpecification.control).

If true, normal frequency/size/richness (`value=1`) are used in that case. Otherwise it is treated as if 'none' were selected.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### force

Force of the placed entity. Can be a custom force name. Only relevant for [EntityWithOwnerPrototype](prototype:EntityWithOwnerPrototype).

**Type:** `"enemy"` | `"player"` | `"neutral"` | `string`

**Optional:** Yes

**Default:** "neutral"

### order

Order for placing the entity (has no effect when placing tiles). Entities whose order compares less are placed earlier (this influences placing multiple entities which collide with itself), from entities with equal order string only one with the highest probability is placed.

**Type:** `Order`

**Optional:** Yes

**Default:** ""

### placement_density

For entities and decoratives, how many times to attempt to place on each tile. Probability and collisions are taken into account each attempt.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### tile_restriction

Restricts tiles or tile transitions the entity can appear on.

**Type:** Array[`TileIDRestriction`]

**Optional:** Yes

### probability_expression

Provides a noise expression that will be evaluated at every point on the map to determine probability.

**Type:** `NoiseExpression`

**Required:** Yes

### richness_expression

If specified, provides a noise expression that will be evaluated to determine richness. Otherwise, `probability_expression` will be used instead.

**Type:** `NoiseExpression`

**Optional:** Yes

### local_expressions

A map of expression name to expression. Used by `probability_expression` and `richness_expression`.

Local expressions are meant to store data locally similar to local variables in Lua. Their purpose is to hold noise expressions used multiple times in the named noise expression, or just to tell the reader that the local expression has a specific purpose. Local expressions can access other local definitions and also function parameters, but recursive definitions aren't supported.

**Type:** Dictionary[`string`, `NoiseExpression`]

**Optional:** Yes

### local_functions

A map of function name to function. Used by `probability_expression` and `richness_expression`.

Local functions serve the same purpose as local expressions - they aren't visible outside of the specific prototype and they have access to other local definitions.

**Type:** Dictionary[`string`, `NoiseFunction`]

**Optional:** Yes

