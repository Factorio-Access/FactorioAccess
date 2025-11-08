# Rail Geometry Reference

Complete documentation of Factorio 2.0 rail piece geometry, patterns, and connection rules.

Generated from extracting all rail pieces at origin and analyzing their connection points, signal locations, and geometric properties.

## Table of Contents

- [Advanced Form](#advanced-form)
- [Quick Reference](#quick-reference)
- [Direction System](#direction-system)
- [The Four Rail Types](#the-four-rail-types)
- [Universal Extension Rule](#universal-extension-rule)
- [End Direction Prediction](#end-direction-prediction)
- [Piece Type Selection](#piece-type-selection)
- [Chirality Patterns](#chirality-patterns)
- [Signal Locations](#signal-locations)
- [Working With Rails](#working-with-rails)
- [Data Tables](#data-tables)


## Advanced Form

This is the "quick reference" of the math, a list of properties for those familiar with bit shifts, chirality, and
parity.  The rest of this document contains conceptually simpler if less elegant and useful ways of holding this in your
head. If you are a user of the mod this entire document is aimed at devs; you don't need to know this to play.

Definitions:

- Chirality of a function f(dir): if f(dir) counterclockwise of dir, 0,else 1.
- parity of a coordinate: (x % 2, y % 2), where % is proper modulus and not the C definition or undefined (e.g. -3 % 2 = 1)

Start by ignoring the 8-way directions (we will come back to that).

Each rail has two endpoints on it.  These endpoints always lie on integer coordinates.  The simplest thing to consider
first is horizontal and vertical rails.  These form a grid of 2x2 size.  The axis lines of that grid go down the middle
of the rails.  These are constrained to be placed with their centers at odd positions.  The endpoints of each rail thus
have mismatching parity.  The centers have parity (1, 1) and you proceed 1 unit in a given direction to reach an end of parity (0, 1) or (1, 0).

Don't be confused, the grid is based off the endpoints not the centers.

Diagonal rails (not half diagonals) form a second grid of endpoints.  These are at parity (1, 1).  This is also a 2x2 grid, but it is offset 1 cell in both x and y from the grid of horizontal and vertical rails.

Curved rails come in two forms, a and b:

- a curves always transition from a cardinal direction to an intermediate direction
- b rails always transition from an intermediate direction to a diagonal direction

They may also be viewed as functions on parity:

- Curved a swaps the parity of the horizontal or vertical end (e, o) to (o, e)
- Curved b shifts the parity of one of the coordinates from even to odd (always the perpendicular one, e.g. north curved b shifts x).

Remember that parity is mod 2.  It is thus not meaningful to say "is it shifting left or right?" because a shift by -1 is the same as a shift by 1.

The form of a 90 degree turn from a cardinal to a cardinal is always a, b, b, a.  There are also a few more rules for rails going into a turn:

- All cardinal ends always extend to a
- All diagonal ends always extend to b

The function of curved rails in other words is to shift parity to get from a grid of h/v to diagonals.  The segment a, bshifts from (1, 0) or (0, 1) to (1, 1).

How this is done is interesting.  The a segment flips, then the b segment shifts.  So, technically a alone ends at the same parity as a, b, b, a, but not with the right orientation to go into a diagonal or cardinal.

Half diagonal rails preserve parity.  If you have the parity of one end of the half diagonal, you have the parity of the other.

Rails are 8 way but we have only been talking about 4 way.  There is a bit trick involved.  If you view the direction of a curved rail as 0bddc0, then c is the chirality bit.

It is easiest to figure out curved rail b starting from a, because a forms an easy to visualize shape.  If you place two
a rails at north (0b0000) and northeast (0b0010) you get an upright y.  This is the chirality bit.  If a train comes in
from the south, it will turn left on the north-facing a, and it will turn right on the northeast facing a.  This can
also be viewed as 0=left and 1=right.  The key is that "northeast" is meaningless.  "northeast" is north with the chirality bit set to clockwise.

To extend a curved rail a facing north, you add a curved rail b facing north, and copy over the chirality bit.  The
problem is that the chirality of a curved rail b is harder to define, because the relationship between the way the
curved rail b faces and the ends of it is not straightforward: they don't form a second y or anything like that.  So,
the best way to conceptualize it is to start with the a-formed y, then put two b rails on it extending the y's outgoing
curves, and visualize it from that.

As a worked example, a turn from north to west is a=0 b=0 b=6 a=6.  Or a=0b0000 b=0b0000, b=0b0110, a=0b0110.  Wh?

First we form the north a-based y: a=0.  We are going left so chirality is 0.  This goes north to north northwest.  We then use the a-b extension rule: a b facing the same direction as the a.  This goes north northwest to northwest.  This has shifted us from parity (1, 0)  to parity (1, 1) and put us on the diagonal grid.

The other half of the turn is east to southeast.  So we form the east-based y: a=4.  But we are turning clockwise, so we set the chirality bit, a=6.  Then we extend our a to get the other half, b=6.  We shifted from parity (0, 1) to parity (1, 1).

let us call the 8 directions primary (cardinal + diagonal).  There is a simpler rule for the chirality bit that works in both cases without having to "form the y".  Visualize the incoming direction as the primary direction endpoint. E.g. our north-facing y is primary direction north.  Then:

- For a curved rail a, left=0, right=1.
- For a curved rail b, left=1, right=0.

This may not seem obvious at first so pretend to be walking it.  You turn north to north northwest.  That's left 22.5 degrees.  You then turn north northwest to northwest for another 22.5 degrees, both left.  Now you turn around 180 degrees to go back.  But going back it is now actually a right turn.

s-bends can be formed a to a or b to b.  In this case, the rule is fortunately very simple: a-a forms s-bends on the
cardinals (sidesteps, if you will), b-b forms s-bends on the diagonals.  The half diagonal s-bends are a-a or b-b, but in the half diagonal case which you need depends on which way you're stepping and is most easily worked out by consulting the table.

So to "sidestep" left of north, is an a going north (because left) and then south (because of 180)

## Quick Reference

**Key Facts:**
- All rails use 16-way directions (22.5° increments)
- Every rail end can extend in exactly 3 directions: same, +1 (right), -1 (left)
- 4 piece types: straight-rail, half-diagonal-rail, curved-rail-a, curved-rail-b
- All patterns have 90° rotational symmetry
- Rails snap to a 2-tile grid

**Most Important Rule:**
From any rail end facing direction D, you can extend to directions D, D+1, or D-1 (mod 16).

## Direction System

Factorio uses 16 compass directions, numbered 0-15:

| Direction Number | Name | Type | Notes |
|-----------------|------|------|-------|
| 0 | north | cardinal | divisible by 4 |
| 1 | northnortheast | intermediate | odd number |
| 2 | northeast | diagonal | = 2 mod 4 |
| 3 | eastnortheast | intermediate | odd number |
| 4 | east | cardinal | divisible by 4 |
| 5 | eastsoutheast | intermediate | odd number |
| 6 | southeast | diagonal | = 2 mod 4 |
| 7 | southsoutheast | intermediate | odd number |
| 8 | south | cardinal | divisible by 4 |
| 9 | southsouthwest | intermediate | odd number |
| 10 | southwest | diagonal | = 2 mod 4 |
| 11 | westsouthwest | intermediate | odd number |
| 12 | west | cardinal | divisible by 4 |
| 13 | westnorthwest | intermediate | odd number |
| 14 | northwest | diagonal | = 2 mod 4 |
| 15 | northnorthwest | intermediate | odd number |

**Direction Classification:**
- **Cardinals**: 0, 4, 8, 12 (N, E, S, W) - direction % 4 == 0
- **Diagonals**: 2, 6, 10, 14 (NE, SE, SW, NW) - direction % 4 == 2
- **Intermediates**: 1, 3, 5, 7, 9, 11, 13, 15 - direction % 2 == 1

Each step is 22.5° (360° / 16).

## The Four Rail Types

### straight-rail

**Purpose:** Connects cardinal directions (N/S or E/W)

**Geometry:**
- 2 tiles long
- Ends 180° apart (8 direction steps)
- Both ends at cardinal directions

**End Formula:**
- Placement direction P → ends at P and (P + 8) mod 16

**Example:** Placed at north (0) → ends face north (0) and south (8)

### half-diagonal-rail

**Purpose:** Connects intermediate diagonal directions (NNE, ENE, ESE, SSE, etc.)

**Geometry:**
- 2 tiles long (on the diagonal)
- Ends 180° apart (8 direction steps)
- Both ends at intermediate directions

**End Formula:**
- Placement direction P → ends at (P + 7) mod 16 and (P + 15) mod 16

**Example:** Placed at northeast (2) → ends face northnortheast (1) and southsouthwest (9)

Note: P + 15 is the same as P - 1 (mod 16)

### curved-rail-a and curved-rail-b

**Purpose:** Create 22.5° turns

**Geometry:**
- Arc length ~157.5° (7/16 of a circle)
- Ends NOT opposite each other (7 direction steps apart)
- Two complementary types to cover all turn cases

**End Formulas:**

curved-rail-a:
- If P is cardinal (P % 4 == 0): ends at (P + 8) and (P + 15)
- If P is diagonal (P % 4 == 2): ends at (P + 6) and (P + 15)

curved-rail-b:
- If P is cardinal (P % 4 == 0): ends at (P + 7) and (P + 14)
- If P is diagonal (P % 4 == 2): ends at P and (P + 7)

All arithmetic is mod 16.

**Why Two Types?**
The 2-tile grid creates different geometric constraints for curves starting from cardinal vs diagonal directions. The two piece types are complementary - together they cover all possible 22.5° turn cases while maintaining grid alignment.

**Closest and Farthest End Patterns:**

Understanding which end is closest to the placement direction provides a simpler mental model:

**curved-rail-a:**
- Closest end: **always** at offset 15 (P - 1), distance 22.5°
- Farthest end: offset 8 for cardinals, offset 6 for diagonals
- Interpretation: One end always "slightly left" of placement

**curved-rail-b:**
- Closest end (cardinals): offset 14 (P - 2), distance 45°
- Closest end (diagonals): offset 0 (same direction!), distance 0°
- Farthest end: **always** offset 7 for both cardinals and diagonals
- Interpretation: On diagonals, one end perfectly aligned with placement

**Complementary Relationship:**
- At any placement, the closest ends of curved-rail-a and curved-rail-b are **exactly 22.5° apart** (1 direction step)
- Together they provide exactly 4 unique end directions
- They don't overlap - they cover adjacent "slices" of directional space
- This is why both pieces are needed: they handle adjacent geometric cases

## Universal Extension Rule

**Verified across all 64 rail ends (4 types × 8 placements × 2 ends):**

From ANY rail end facing direction D, there are exactly 3 possible extensions:
1. Direction D (straight ahead)
2. Direction (D + 1) mod 16 (turn right 22.5°)
3. Direction (D - 1) mod 16 (turn left 22.5°)

This is a geometric constraint - rails can only make gentle 22.5° turns. Sharp 90° turns require multiple pieces.

**Example:** End facing north (0)
- Can extend to: north (0), northnortheast (1), northnorthwest (15)

**Example:** End facing eastsoutheast (5)
- Can extend to: eastsoutheast (5), southeast (6), east (4)

## End Direction Prediction

You can calculate both end directions from placement direction without looking them up:

| Rail Type | Placement | End Offsets | Example |
|-----------|-----------|-------------|---------|
| straight-rail | any P | [0, 8] | P=north(0) → ends: north(0), south(8) |
| half-diagonal-rail | any P | [7, 15] | P=northeast(2) → ends: nne(1), ssw(9) |
| curved-rail-a | cardinal | [8, 15] | P=north(0) → ends: south(8), nnw(15) |
| curved-rail-a | diagonal | [6, 15] | P=northeast(2) → ends: ese(5), nne(1) |
| curved-rail-b | cardinal | [7, 14] | P=north(0) → ends: sse(7), nw(14) |
| curved-rail-b | diagonal | [0, 7] | P=northeast(2) → ends: ne(2), ssw(9) |

**Note:** All patterns have 90° rotational symmetry - what works at north also works at east, south, and west with appropriate rotation.

## Piece Type Selection

When extending from a rail end, which piece type should you use?

**Rule depends on the END DIRECTION TYPE:**

### From Cardinal End (N, E, S, W)

| Extension | Piece Type |
|-----------|------------|
| Straight (offset 0) | straight-rail |
| Right (offset +1) | curved-rail-a |
| Left (offset -1) | curved-rail-a |

**Example:** End facing north
- Extend north → straight-rail
- Extend northeast → curved-rail-a
- Extend northwest → curved-rail-a

### From Diagonal End (NE, SE, SW, NW)

| Extension | Piece Type |
|-----------|------------|
| Straight (offset 0) | straight-rail |
| Right (offset +1) | curved-rail-b |
| Left (offset -1) | curved-rail-b |

**Example:** End facing northeast
- Extend northeast → straight-rail
- Extend east → curved-rail-b
- Extend north → curved-rail-b

### From Intermediate End (NNE, ENE, ESE, SSE, etc.)

| Extension | Piece Type |
|-----------|------------|
| Straight (offset 0) | half-diagonal-rail |
| Right (offset +1) | curved-rail-b |
| Left (offset -1) | curved-rail-a |

**Example:** End facing northnortheast
- Extend northnortheast → half-diagonal-rail
- Extend northeast → curved-rail-b
- Extend north → curved-rail-a

**Mnemonic:**
- Cardinals use curved-rail-a for turns
- Diagonals use curved-rail-b for turns
- Intermediates use half-diagonal straight, curved-b right, curved-a left

## Chirality Patterns

"Chirality" = which way the curve bends (clockwise vs counterclockwise)

When a curved rail is placed, going from the lower-numbered end to the higher-numbered end:
- Increasing direction numbers = clockwise (right turn)
- Decreasing direction numbers = counterclockwise (left turn)

### Chirality by Placement Direction

**curved-rail-a bends counterclockwise (CCW) when placed at:**
- East
- Southwest
- Northwest

All other placements (North, Northeast, Southeast, South, West) are clockwise (CW).

**curved-rail-b bends counterclockwise (CCW) when placed at:**
- East
- South
- Southwest
- Northwest

All other placements (North, Northeast, Southeast, West) are clockwise (CW).

**Simple Rule:** Both pieces bend CCW at East, Southwest, Northwest. curved-rail-b also bends CCW at South.

### Chirality Table

| Placement | curved-rail-a | curved-rail-b |
|-----------|---------------|---------------|
| North (0) | CW | CW |
| Northeast (2) | CW | CW |
| East (4) | CCW | CCW |
| Southeast (6) | CW | CW |
| South (8) | CW | CCW |
| Southwest (10) | CCW | CCW |
| West (12) | CW | CW |
| Northwest (14) | CCW | CCW |

**Pattern observations:**
- 45° rotation (2 direction steps) changes chirality 6/8 times for curved-rail-a, 6/8 times for curved-rail-b
- Chirality is NOT random - it encodes the geometric constraint of fitting the 2-tile grid
- Specific "stays same" transitions occur around north-northeast and other symmetric points

## Signal Locations

Every rail end has signal locations where rail signals can be placed.

### Standard Signals

**All rail ends have:**
- `in_signal`: Signal for trains entering this end
- `out_signal`: Signal for trains exiting this end

Both include:
- `position`: MapPosition {x, y} coordinates
- `direction`: Direction the signal faces

**Signal Direction Pattern (100% Verified):**
- `in_signal` **always** faces the exact same direction as the rail end (64/64 confirmed)
- `out_signal` **always** faces exactly opposite (180°) to the rail end (64/64 confirmed)

This is a perfectly predictable pattern with no exceptions!

### Alternative Signals

**Some rail ends (particularly curved rails) also have:**
- `alt_in_signal`: Alternative position for entry signal
- `alt_out_signal`: Alternative position for exit signal

**When alternatives exist:**
- Curved rail pieces often have alt signals on at least one end
- Straight rails typically do not have alt signals
- Alt signals provide flexibility for signal placement around curves

**Example:** curved-rail-a placed at north
- End northnorthwest: has alt_in_signal
- End south: no alt signals

## Working With Rails

### Building a Rail Path

To extend from an existing rail end:

1. **Know your current end direction** (0-15)
2. **Choose extension direction:** same, +1, or -1
3. **Determine piece type** using end direction type (cardinal/diagonal/intermediate)
4. **Look up in table:** placement direction and position
5. **Place piece** at calculated position and direction
6. **Update state** with new end direction

### Using the Data Table

The full rail table in `railtable.lua` provides:

```lua
railtable[prototype_type][placement_direction] = {
  grid_offset = {x, y},  -- API placement offset from requested origin
  bounding_box = {  -- Collision box (may have orientation for rotated boxes)
    left_top = {x, y},
    right_bottom = {x, y},
    orientation = <number>  -- optional, present if box is rotated
  },
  occupied_tiles = {{x, y}, ...},  -- Integer tile coordinates
  [end_direction] = {
    extensions = {
      [goal_direction] = {
        prototype = "piece-type",
        position = {x, y},
        direction = "placement-dir",
        goal_position = {x, y},
        goal_direction = "goal-dir"
      }
    },
    signal_locations = {
      in_signal = {position, direction},
      out_signal = {position, direction},
      alt_in_signal = {position, direction},  -- optional
      alt_out_signal = {position, direction}  -- optional
    }
  }
}
```

**Note:** All coordinates are relative to the rail piece's actual position after placement, not the requested origin. The `grid_offset` field records the offset that the API applied.

### Grid Offset Patterns

The game applies two types of corrections when placing rails:

1. **Direction Correction**: Straight and half-diagonal rails have their direction corrected using `direction % 8`. Curved rails (a and b) preserve their requested direction.

2. **Position Correction**: Grid offsets depend on rail type, direction, and **position parity**.

The grid offset formulas enforce the parity grid constraints described above. Straight rails snap to ensure their centers land at parity (1, 1). Curved rails implement the parity-shifting behavior needed to transition between grids.

Let `x_parity = abs(request_x) % 2` and `y_parity = abs(request_y) % 2`.

| Rail Type | Direction(s) | Game Grid Offset Formula |
|-----------|--------------|--------------------------|
| `straight-rail` | 0, 4 | `(1 - x_parity, 1 - y_parity)` |
| `straight-rail` | 2, 6 | `(x_parity, y_parity)` |
| `curved-rail-a` | 0, 2, 8, 10 | `(1 - x_parity, y_parity)` |
| `curved-rail-a` | 4, 6, 12, 14 | `(x_parity, 1 - y_parity)` |
| `curved-rail-b` | all | `(1 - x_parity, 1 - y_parity)` |
| `half-diagonal-rail` | all | `(1 - x_parity, 1 - y_parity)` |

**Directions shown after mod 8 correction for straight/half-diagonal rails.*

**Parity Grid Enforcement**:
- Straight rails (dirs 0, 4): Inverted parity `(1 - x_parity, 1 - y_parity)` ensures centers at parity (1, 1), enforcing the H/V grid constraint
- Curved-a: Different formulas per direction implement the parity-swapping behavior `(e,o) → (o,e)`
- Curved-b: Inverted parity implements the coordinate-shifting to transition to diagonal grid
- Half-diagonal: Inverted parity preserves the endpoint parity relationship

**Example**: Requesting `straight-rail` at `(-8, -8)` with direction `0` (north):
1. Direction corrected: already `0` (north)
2. Calculate parity: `x_parity = 8 % 2 = 0`, `y_parity = 8 % 2 = 0`
3. Grid offset formula for N/S straight: `(1 - x_parity, 1 - y_parity) = (1, 1)`
4. Final position: `(-8 + 1, -8 + 1) = (-7, -7)`

**Lookup pattern:**
1. Know: current piece type and placement direction (or just end direction)
2. Find: extensions[desired_goal_direction]
3. Get: which piece to place, where to place it, and where the new end will be

### Example Workflow

Starting: straight-rail at north, want to extend from north end turning right

1. End direction: north (0)
2. Desired goal: northnortheast (1) - that's +1, turning right
3. End type: cardinal → use curved-rail-a for turns
4. Look up: straight-rail["north"]["north"].extensions["northnortheast"]
5. Result: place curved-rail-a at specific position and direction
6. New end: northnortheast (1)

## Data Tables

### End Direction Offsets Summary

| Rail Type | Cardinal Placement | Diagonal Placement |
|-----------|-------------------|-------------------|
| straight-rail | [0, 8] | [0, 8] |
| half-diagonal-rail | [7, 15] | [7, 15] |
| curved-rail-a | [8, 15] | [6, 15] |
| curved-rail-b | [7, 14] | [0, 7] |

### Curved Rail End Offsets (Closest/Farthest)

| Rail Type | Placement Type | Closest End Offset | Farthest End Offset |
|-----------|----------------|-------------------|-------------------|
| curved-rail-a | any | 15 (P - 1) | 8 (cardinals), 6 (diagonals) |
| curved-rail-b | cardinals | 14 (P - 2) | 7 |
| curved-rail-b | diagonals | 0 (P) | 7 |

**Key insight:** curved-rail-a always has one end 22.5° left of placement. curved-rail-b on diagonals has one end perfectly aligned with placement direction.

### Extension Piece Type by End Type

| End Type | Straight | Turn Right | Turn Left |
|----------|----------|------------|-----------|
| Cardinal | straight-rail | curved-rail-a | curved-rail-a |
| Diagonal | straight-rail | curved-rail-b | curved-rail-b |
| Intermediate | half-diagonal-rail | curved-rail-b | curved-rail-a |

### Complete Direction Reference

| # | Name | Type | Is Cardinal | Is Diagonal | Is Intermediate |
|---|------|------|-------------|-------------|-----------------|
| 0 | north | cardinal | yes | no | no |
| 1 | northnortheast | intermediate | no | no | yes |
| 2 | northeast | diagonal | no | yes | no |
| 3 | eastnortheast | intermediate | no | no | yes |
| 4 | east | cardinal | yes | no | no |
| 5 | eastsoutheast | intermediate | no | no | yes |
| 6 | southeast | diagonal | no | yes | no |
| 7 | southsoutheast | intermediate | no | no | yes |
| 8 | south | cardinal | yes | no | no |
| 9 | southsouthwest | intermediate | no | no | yes |
| 10 | southwest | diagonal | no | yes | no |
| 11 | westsouthwest | intermediate | no | no | yes |
| 12 | west | cardinal | yes | no | no |
| 13 | westnorthwest | intermediate | no | no | yes |
| 14 | northwest | diagonal | no | yes | no |
| 15 | northnorthwest | intermediate | no | no | yes |

## Key Insights

1. **Direction-Based Thinking:** Rail connections are fundamentally about directions (0-15), not just coordinates. The 2-tile grid follows from the directional geometry.

2. **Universal Extension Pattern:** The ±1 extension rule is truly universal across all 64 rail ends. This is not arbitrary - it's a geometric constraint.

3. **Predictable Ends:** You can calculate both end directions from placement direction using simple arithmetic. Only 4 unique formulas (one per piece type, adjusted for cardinal vs diagonal).

4. **Piece Selection Logic:** Which piece to use follows clear rules based on end direction type. You don't need to memorize 192 cases.

5. **Symmetry:** All patterns have 90° rotational symmetry. What works at north works at east/south/west with rotation.

6. **Grid Alignment:** The existence of 4 piece types and the cardinal/diagonal distinction all stem from the 2-tile grid alignment constraint. The table stores geometric solutions, not arbitrary data.

7. **Closest End Simplification:** curved-rail-a always has one end 22.5° left of placement. curved-rail-b on diagonals has one end perfectly aligned. This is simpler than memorizing [8,15] vs [6,15] patterns.

8. **Complementary Coverage:** The two curved pieces at any placement are always exactly 22.5° apart and together provide 4 unique end directions. They don't overlap - they're adjacent in directional space.

9. **Perfect Signal Predictability:** Signal directions are 100% deterministic. in_signal always matches the rail end direction, out_signal always faces opposite. No exceptions across all 64 rail ends.

10. **180° Rotational Symmetry:** If you place the same rail type at opposite directions (P and P+8, like north and south), the ends are positioned at the same *relative* offsets from their placement directions. Example: straight-rail at north has ends at offsets [0, 8], and straight-rail at south also has ends at offsets [0, 8] relative to south. The pattern repeats around the compass.

## Mental Model

Think of rail building as navigating a direction graph:
- You're always at a node (rail end) with a direction (0-15)
- You have 3 edges (same, +1, -1)
- Each edge has a label (which piece to place)
- Following an edge takes you to a new node (new end direction)

The coordinate positions follow from the geometry - they're not the primary abstraction. Work in direction space, and coordinates fall into place.

## Verification

All patterns in this document have been verified against the complete rail table:
- ✓ Universal extension rule: 64/64 rail ends confirmed
- ✓ End direction prediction: 32/32 placements confirmed
- ✓ 90° rotational symmetry: 4/4 piece types confirmed
- ✓ 180° rotational symmetry: all piece types confirmed
- ✓ Piece type selection: verified by sampling
- ✓ Signal direction patterns: 64/64 in_signal match end direction, 64/64 out_signal opposite
- ✓ Curved piece complementarity: all 8 placements show 22.5° separation and 4 unique ends
- ✓ Closest end patterns: curved-rail-a always offset 15, curved-rail-b varies by cardinal/diagonal
- ✓ Straight extension availability: all curved rail ends can extend straight

## Data Source

This documentation is based on the complete rail table extracted by:
1. Placing all 4 rail types at origin in all 8 valid directions (0, 2, 4, 6, 8, 10, 12, 14)
2. Recording actual position (API may offset for grid alignment)
3. Extracting bounding box and occupied tiles
4. Extracting both rail ends for each placement
5. Recording all extensions (3 per end)
6. Recording all signal locations
7. Making all coordinates relative to actual entity position
8. Analyzing patterns across the complete dataset

See `scripts/rails/table-extractor.lua` for extraction code.
See `scripts/fa-commands.lua` command `/railtable` for invocation.
See `railtable.lua` for the complete data table.
See `validate_rail_patterns.lua` for systematic verification of patterns.
