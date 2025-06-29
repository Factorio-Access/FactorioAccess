# Hardcoded Strings Requiring Localization

This document lists all remaining hardcoded strings found in the codebase that should be converted to use the localization system.

## Control.lua

### High Priority User-Facing Strings
1. Line 421: `"This item is temporary"`
2. Line 435: `"Another menu is open."`
3. Line 479: `"This item is temporary"` (duplicate)
4. Line 1127: `"Blank"`
5. Line 1200, 1401, 1598, 1740: `"blank sector"`
6. Line 1340: `"Press left bracket to confirm your selection."`
7. Line 2016: `"Press 'TAB' to begin"`
8. Line 2018: `"Press 'H' to open the tutorial"`
9. Line 2110: `"Driving state changed."`
10. Line 2358: `"observes circuit condition"`
11. Line 2362, 2372: `"Switched on"`
12. Line 2364, 2374: `"Switched off"`
13. Line 2760: `"Cleared trains limit"`
14. Line 2763, 2766, 2814, 2817, 3226, 3229: `"Invalid input"`
15. Line 2794: `"Error: No signals found"`
16. Line 2879: `"Unimplemented for 2.0"`
17. Line 2929: `"Blueprint description changed."`
18. Line 2945: `"Text box closed"`
19. Line 3012: `"This menu or sector does not support slot filters"`
20. Line 3033, 3042, 3051: `"Error: Unable to set the slot filter for this item"`
21. Line 3056: `"Error: No item specified for setting a slot filter"`
22. Line 3205: `"Enter new co-ordinates for the cursor, separated by a space"`
23. Line 3746: `"Menu closed"`
24. Line 3772: `"Remote view closed"`
25. Line 3815: `"Teleport Failed"`
26. Line 3850: `"Tile Occupied"`
27. Line 4594: `"Failed to nudge self"`
28. Line 5148: `"Cleared rulers"`
29. Line 5186: `"No target"`
30. Line 5486: `"Error: Missing building interface"`
31. Line 5497, 5531: `"Error: This combinator is not supported"`
32. Line 5503: `"No control behavior for this building"`
33. Line 5510: `" not connected to a circuit network"`
34. Line 5626: `"Menu closed."`
35. Line 6040, 6046: `"No fluids to flush"`
36. Line 6083: `"Collecting items "`
37. Line 6133: `"This area is out of player reach"`
38. Line 6314: `"To disable this tool empty the hand, by pressing SHIFT + Q"`
39. Line 6353: `"An assembling machine is required to craft this"`
40. Line 6356: `"A centrifuge is required to craft this"`
41. Line 6359: `"A chemical plant is required to craft this"`
42. Line 6362: `"An advanced assembling machine is required to craft this"`
43. Line 6365: `"An oil refinery is required to craft this"`
44. Line 6368: `"A rocket silo is required to craft this"`
45. Line 6371: `"A furnace is required to craft this"`
46. Line 6374: `"This recipe cannot be crafted by hand"`
47. Line 6424: `"Nil entity"`
48. Line 6426: `"Invalid Entity"`
49. Line 6466: `"Filter set."`
50. Line 6490: `" Only one module can be added per module slot "`
51. Line 6494: `" Added"`
52. Line 6509: `" Error: At least two empty player inventory slots needed"`
53. Line 6523, 6533: `" Failed to add module "`
54. Line 6547: `"Empty"`
55. Line 6575: `"Selected"`
56. Line 6602: `"No recipes unlocked for this building yet."`
57. Line 6618: `"Move up and down to select a location."`
58. Line 6624: `"Pump placed."`
59. Line 6650: `"Blank"`
60. Line 6702: `"Cannot build the ghost in hand"`
61. Line 6848: `"Warning, you are in the target area!"`
62. Line 6852: `"Target is out of range"`
63. Line 6977, 7182: `"Not enough materials"`
64. Line 7027, 7038: `"Filter cleared"`
65. Line 7091: `"Canceled deconstruction in selected area"`
66. Line 7118: `"Canceled upgrading in selected area"`
67. Line 7313: `"Rail builder menu cannot use curved rails."`
68. Line 7518: `"Cannot pickup items while in a menu"`
69. Line 7585: `"Error: Flipping horizontal is not supported."`
70. Line 7636: `"Error: Flipping vertical is not supported."`
71. Line 7735: `"Nothing selected, use this key to describe an entity or item that you select."`
72. Line 7759, 7768: `"No description"`
73. Line 7798: `"No description found, menu error"`

### String Building Patterns Needing Attention
- Line 322: `"Empty Slot"`
- Line 326: `" filtered for "` (with concatenation)
- Line 338: `" filtered "`
- Line 340: `" damaged "`
- Line 742, 748: `" mined, "`
- Lines 2832, 2872, 2883, 2891, 2910, 2923, 2936, 2944: `"blank"` and `"unknown"`
- Line 3284: Complex damage message building
- Line 3310: Complex destroyed message building
- Lines 3338-3346: Player death message building
- Lines 4379-4410: Movement result message building
- Lines 4673-4690: Vehicle status message building
- Lines 4822-4866: Recipe ingredient/product listing
- Line 4942: `"At "`
- Line 4975: Character position message
- Line 5824, 5965: `"No ready weapons"`
- Line 6512: `"Collected "` with concatenation
- Line 7222: Complex inventory insertion message
- Line 7225: `"Cannot insert "` with concatenation

## Scripts Directory

### fa-info.lua
- Lines 1412, 1424, 1439: `"No damaged structures within 1000 tiles."`

### building-vehicle-sectors.lua
- Line 368: `", this menu has no options "`
- Line 370: `" has no menu "`
- Line 694: `"0 "` (with concatenation)

### localising.lua
- Line 28: `"localising: pindex is nil error"`

### rail-builder.lua
- Line 75: `"No end rails found nearby"`

### menu-search.lua
- Line 511: `"This menu or building sector does not support backwards searching."`

## Recommendations

1. **Priority 1**: Convert all direct user-facing strings (printout calls with literal strings)
2. **Priority 2**: Convert string building patterns that create user messages
3. **Priority 3**: Convert error messages and status messages
4. **Priority 4**: Review commented-out printouts to see if they should be removed or activated

## Localization Keys Needed

Based on the patterns found, we need locale keys for:
- Blank/empty states
- Error messages (various types)
- Menu instructions
- Status changes (switched on/off, etc.)
- Crafting requirements
- Filter operations
- Movement and teleportation results
- Combat/weapon states
- Item collection/placement results
- Building/entity descriptions

All of these should be added to the appropriate locale files and the code should be updated to use the localization system with either direct locale table references or MessageBuilder for complex messages.