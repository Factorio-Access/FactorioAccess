# BoundingBox

BoundingBoxes are typically centered around the position of an entity.

BoundingBoxes are usually specified with the short-hand notation of passing an array of exactly 2 or 3 items.

The first tuple item is left_top, the second tuple item is right_bottom. There is an unused third tuple item, a [float](prototype:float) that represents the orientation.

Positive x goes towards east, positive y goes towards south. This means that the upper-left point is the least dimension in x and y, and lower-right is the greatest.

