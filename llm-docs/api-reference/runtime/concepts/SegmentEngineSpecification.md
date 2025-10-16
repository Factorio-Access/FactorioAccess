# SegmentEngineSpecification

A runtime representation of [SegmentEngineSpecification](prototype:SegmentEngineSpecification).

**Type:** Table

## Parameters

### max_body_nodes

The maximum number of body nodes that a segmented unit instance can have.

**Type:** `uint32`

**Required:** Yes

### segments

All segments (except for the head segment) that compose the body of the segmented unit.

**Type:** Array[`SegmentSpecification`]

**Required:** Yes

