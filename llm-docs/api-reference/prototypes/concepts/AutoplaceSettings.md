# AutoplaceSettings

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### treat_missing_as_default

Whether missing autoplace names for this type should be default enabled.

**Type:** `boolean`

**Optional:** Yes

### settings

Overrides the FrequencySizeRichness provided to the [AutoplaceSpecification](prototype:AutoplaceSpecification) of the entity/tile/decorative. Takes priority over the FrequencySizeRichness set in the [autoplace control](prototype:AutoplaceSpecification::control).

**Type:** Dictionary[`EntityID` | `TileID` | `DecorativeID`, `FrequencySizeRichness`]

**Optional:** Yes

