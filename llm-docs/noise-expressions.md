# Noise Expressions - Auxiliary Docs | Factorio

Factorio.com|Forums|Wiki|Mod Portal|API Docs[Prototype](../index-prototype.html)|[Runtime](../index-runtime.html)|Auxiliary

 Factorio Auxiliary DocsVersion 2.0.55 

[Home](../index-auxiliary.html) / [Noise Expressions](noise-expressions.html)><

Table of contents[Identifiers](#identifiers)[Built-in variables](#built-in-variables)[Built-in constants](#built-in-constants)[Built-in functions](#built-in-functions)[Performance tips](#performance-tips)
Noise expressions
Noise expressions represent a series of mathematical expressions which are executed for every tile. See the [NoiseExpression Type](../types/NoiseExpression.html) for their syntax and this page for the behaviour of identifiers and built-in functions and variables.

Mods can define their own noise expressions and functions as prototypes and tell the game to use them for map generation. The major entry points for this are [AutoplaceSpecification::probability_expression](../types/AutoplaceSpecification.html#probability_expression), [AutoplaceSpecification::richness_expression](../types/AutoplaceSpecification.html#richness_expression) and [NamedNoiseExpression](../prototypes/NamedNoiseExpression.html).
Identifiers
Identifiers are used to name functions and variables which have their own (return) types: - **Number:** Usually a single-precision floating-point number - **String** - **MapPosition** - **MapPositionList:** An array of MapPosition variables - **Boolean:** Stored as a number; true for positive numbers, false for negative numbers and zero - **NoiseLayerID:** Stored as a number or a string; string is converted to ID using CRC32
Name resolution
The game engine does not restrict naming of noise functions and noise expressions, although some names may be unusable because of the parser. Function parameters are also parsed as identifiers. Therefore, it is recommended to follow [identifier](../types/NoiseExpression.html) format.

If an expression cannot be parsed as an identifier, it can be accessed via a proxy function `var()`. For example, if `my-noise-expression` would be entered into the parser directly, it would be treated as a subtraction of three variables - `my`, `noise` and `expression` instead of one variable name. To use such variable, we can call `var('my-noise-expression')`. Function names and function parameters do not have alternative ways of accessing them.
Name collisions
The parser has some rules to resolve name collisions, applied in order until an expression/function is found: 1. Try to find the most local noise expression/function, taking into account function parameters. 2. Check `property_expression_names` defined in [MapGenSettings](../concepts/MapGenSettings.html). 3. Check global prototype names ([named noise expressions](../prototypes/NamedNoiseExpression.html)/[functions](../prototypes/NamedNoiseFunction.html)). 4. Check built-in constants, variables and functions.
Built-in variables**x** (Number): Current X position on the map.**y** (Number): Current Y position on the map.

Noise expressions of all tiles, entities and decoratives which will be generated on map can also be accessed as variables. By default, noise expressions from prototype autoplace specification are used, but they can be overwritten with [MapGenSettings::property_expression_names](../concepts/MapGenSettings.html#property_expression_names). - **decorative:my-decorative-name:probability** (Number) - **decorative:my-decorative-name:richness** (Number) - **entity:my-entity-name:probability** (Number) - **entity:my-entity-name:richness** (Number) - **tile:my-tile-name:probability** (Number) - **tile:my-tile-name:richness** (Number)
Built-in constants
Constants defined by the parser: - **true** (Number): 1 - **false** (Number): 0 - **e** (Number): Euler's number - **pi** (Number): ~3.14159 - **inf** (Number): infinity

Constants from [MapGenSettings](../concepts/MapGenSettings.html): - **map_seed** (Number): 32-bit unsigned integer - **map_seed_small** (Number): 16 least significant bits from `map_seed` - **map_seed_normalized** (Number): 0-1 normalized value of `map_seed` - **map_width** (Number) - **map_height** (Number) - **starting_area_radius** (Number) - **cliff_elevation_0** (Number) - **cliff_elevation_interval** (Number) - **cliff_smoothing** (Number) - **cliff_richness** (Number) - **starting_positions** (MapPositionList) - **starting_lake_positions** (MapPositionList): calculated from starting positions and map seed - **peaceful_mode** (Boolean) - **no_enemies_mode** (Boolean) - **control:moisture:frequency** (Number) - **control:moisture:bias** (Number) - **control:aux:frequency** (Number) - **control:aux:bias** (Number)

In addition to the hard-coded values, all [autoplace controls](../prototypes/AutoplaceControl.html) are converted to frequency, size and richness constants. Because their name contains '-' character, they have to be accessed via `var()` function. - **control:my-autoplace-name:frequency** (Number) - **control:my-autoplace-name:size** (Number) - **control:my-autoplace-name:richness** (Number)
Built-in functionsabs
Returns absolute value of the given argument; i.e. if the argument is negative, it is inverted.

**Parameters:** - **value** (Number)

**Return type:** Number
atan2
Returns the arc tangent of y/x using the signs of arguments to determine the correct quadrant.

**Parameters:** - **y** (Number) - **x** (Number)

**Return type:** Number
basis_noise
A Factorio single-octave noise implementation.

**Parameters:** - **x** (Number) - **y** (Number) - **seed0** (Number; constant; converted to 32-bit unsigned integer) - **seed1** (NoiseLayerID; constant) - **input_scale** (Number; constant; default = 1): x and y will be multiplied by this before sampling - **output_scale** (Number; constant; default = 1): output will be multiplied by this before being returned - **offset_x** (Number; constant; default = 0): will be added to x before applying input_scale - **offset_y** (Number; constant; default = 0): will be added to y before applying input_scale

**Return type:** Number

Using `input_scale` and `output_scale` is more efficient than multiplying `x` and `y` directly; see the[performance tips](#noise-seed-input-scale-and-output-scale).

**Examples:**`basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 0} basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 0, input_scale = 1/3, output_scale = 3}`
ceil
Rounds a number up to the nearest integer.

**Parameters:** - **value** (Number)

**Return type:** Number
clamp
The first argument is clamped between the second and third.

**Parameters:** - **value** (Number) - **min** (Number) - **max** (Number)

**Return type:** Number
cos
The cosine trigonometric function.

**Parameters:** - **value** (Number)

**Return type:** Number
distance_from_nearest_point
Computes the euclidean distance of the position `{x, y}` from all positions listed in points and returns the shortest distance. The returned distance can be maximum_distance at most.

**Parameters:** - **x** (Number) - **y** (Number) - **points** (MapPositionList) - **maximum_distance** (Number; constant; default = infinity)

**Return type:** Number

**Examples:**`distance_from_nearest_point{x = x, y = y, points = starting_positions} distance_from_nearest_point{x = x, y = y, points = starting_lake_positions}`
distance_from_nearest_point_x
Computes the euclidean distance of the position `{x, y}` from all positions listed in points and returns the X coordinate of the closest point subtracted from current position.

**Parameters:** - **x** (Number) - **y** (Number) - **points** (MapPositionList)

**Return type:** Number
distance_from_nearest_point_y
Computes the euclidean distance of the position `{x, y}` from all positions listed in points and returns the Y coordinate of the closest point subtracted from current position.

**Parameters:** - **x** (Number) - **y** (Number) - **points** (MapPositionList)

**Return type:** Number
floor
Rounds a number down to the nearest integer.

**Parameters:** - **value** (Number)

**Return type:** Number
if
Copies a value from one of the branches depending on the condition. Does not support short-circuit; all branches are fully evaluated.

**Parameters:** - **condition** (Boolean) - **true_branch** (Number) - **false_branch** (Number)

**Return type:** Number
log2
Returns a binary logarithm of the given value.

**Parameters:** - **value** (Number)

**Return type:** Number
multisample
Evaluates the expression in a separate noise program with a larger grid. Sub-grids are copied to the main program. This means that sub-expression results of the given expression are not reused between the main noise program and the multisampling program. Repeated calls of this function with different offsets will be batched together as long as `expression` is the same.

**Parameters:** - **expression** (Number-returning Expression) - **offset_x** (Number; constant 8-bit signed integer) - **offset_y** (Number; constant 8-bit signed integer)

**Return type:** Number
multioctave_noise
A Factorio multi-octave noise implementation.

**Parameters:** - **x** (Number) - **y** (Number) - **persistence** (Number; constant): how strong each layer is compared to the next larger one - **seed0** (Number; constant; converted to 32-bit unsigned integer) - **seed1** (NoiseLayerID; constant) - **octaves** (Number; constant 32-bit unsigned integer): how many layers of noise at different scales to sum - **input_scale** (Number; constant; default = 1): x and y will be multiplied by this before sampling - **output_scale** (Number; constant; default = 1): output will be multiplied by this before being returned - **offset_x** (Number; constant; default = 0): will be added to x before applying input_scale - **offset_y** (Number; constant; default = 0): will be added to y before applying input_scale

**Return type:** Number

Using `input_scale` and `output_scale` is more efficient than multiplying `x` and `y` directly; see the[performance tips](#noise-seed-input-scale-and-output-scale).

**Examples:**`multioctave_noise{x = x, y = y, persistence = 0.75, seed0 = map_seed, seed1 = 0, octaves = 3} multioctave_noise{x = x, y = y, persistence = 0.75, seed0 = map_seed, seed1 = 0, octaves = 4, input_scale = 1/3, output_scale = 3}`
noise_layer_id
Returns the numeric value of the given string to be used as a noise layer ID.

**Parameters:** - **value** (String)

**Return type:** Number
pow
Fast (inaccurate) exponentiation from [fastapprox](https://code.google.com/archive/p/fastapprox/) library. Same as `x ^ y` operator.

**Parameters:** - **value** (Number) - **exponent** (Number)

**Return type:** Number
pow_precise
Precise (but very slow) exponentiation - it is almost always overkill for map generation.

**Parameters:** - **value** (Number) - **exponent** (Number)

**Return type:** Number
quick_multioctave_noise
An alternative Factorio multi-octave noise implementation. If possible, prefer using regular multioctave noise.

**Parameters:** - **x** (Number) - **y** (Number) - **seed0** (Number; constant; converted to 32-bit unsigned integer) - **seed1** (NoiseLayerID; constant) - **octaves** (Number; constant 32-bit unsigned integer): how many layers of noise at different scales to sum - **input_scale** (Number; constant; default = 1): x and y will be multiplied by this before sampling - **output_scale** (Number; constant; default = 1): output will be multiplied by this before being returned - **offset_x** (Number; constant; default = 0): will be added to x before applying input_scale - **offset_y** (Number; constant; default = 0): will be added to y before applying input_scale - **octave_input_scale_multiplier** (Number; constant; default = 0.5) - **octave_output_scale_multiplier** (Number; constant; default = 2) - **octave_seed0_shift** (Number; constant; default = 1)

**Return type:** Number
random_penalty
Subtracts a random value in the [0, amplitude) range from source if source is larger than 0.

**Parameters:** - **x** (Number): a number used to seed the random generator - **y** (Number): a number used to seed the random generator - **source** (Number): a number the penalty is applied to - **seed** (Number; constant; default = 1): a number used to seed the random generator - **amplitude** (Number; constant; default = 1)

**Return type:** Number
ridge
Similar to clamp but the input value is folded back across the upper and lower limits until it lies between them.

**Parameters:** - **value** (Number) - **min** (Number) - **max** (Number)

**Return type:** Number
sin
The sine trigonometric function.

**Parameters:** - **value** (Number)

**Return type:** Number
spot_noise
Generates random conical spots. The map is divided into square regions. Within each region, candidate points are chosen at random, taking into account skip_span. Then, target density, spot quantity, and radius are calculated for each candidate point by configured expressions. Each spot contributes a quantity to a regional target total (which is the average of sampled target densities times the area of the region) until the total has been reached or a maximum spot count is hit. The output value of the function is the maximum height of any spot at a given point.

The quantity of the spot is assumed to be the same as its volume. Since the volume of a cone is `pi * radius^2 * height / 3`, the height ('peak value') of any given spot is calculated as `3 * quantity / (pi * radius^2)`.

The infinite series of candidate points (of which `candidate_point_count` are actually considered) generated by spot noise expressions with the same `seed0`, `seed1`, `region_size` and `suggested_minimum_candidate_point_spacing` will be identical. This allows multiple spot noise expressions (e.g. for different ore patches) to avoid overlap by using different points from the same list, determined by `skip_span` and `skip_offset`.

**Parameters:** - **x** (Number) - **y** (Number) - **density_expression** (Number-returning Expression): an expression which will be evaluated for each candidate spot to calculate density at that point - **spot_quantity_expression** (Number-returning Expression): an expression which will be evaluated for each candidate spot to calculate the spot's quantity - **spot_radius_expression** (Number-returning Expression): an expression which will be evaluated for each candidate spot to calculate the spot's radius (this, together with quantity, will determine the spot's peak value) - **spot_favorability_expression** (Number-returning Expression): an expression which will be evaluated for each candidate spot to calculate the spot's favorability; spots with higher favorability will be considered first when building the final list of spots for a region - **seed0** (Number; constant; converted to 32-bit unsigned integer) - **seed1** (NoiseLayerID; constant) - **basement_value** (Number; constant) - **maximum_spot_basement_radius** (Number; constant) - **region_size** (Number; constant; default = 512) - **skip_offset** (Number; constant; default = 0): offset of the first candidate point to use - **skip_span** (Number; constant; default = 1): number of candidate points to skip over after each one used as a spot including the used one - **hard_region_target_quantity** (Boolean; constant; default = true): whether to place a hard limit on the total quantity in each region by reducing the size of any spot (which will be the last spot chosen) that would put it over the limit - **candidate_point_count** (Number; constant; optional): the number of candidate points to generate - **candidate_spot_count** (Number; constant; optional): the number of spots to generate (an alternative to candidate_point_count); `candidate_spot_count` is equivalent to `candidate_point_count / skip_span` - **suggested_minimum_candidate_point_spacing** (Number; constant; optional): minimum spacing to _try_ to achieve while randomly picking points; spot noise may end up placing spots closer than this in crowded regions

**Return type:** Number
sqrt
Returns the square root of the given parameter.

**Parameters:** - **value** (Number)

**Return type:** Number
terrace
**Parameters:** - **value** (Number) - **strength** (Number) - **offset** (Number; constant) - **width** (Number; constant)

**Return type:** Number
var
Returns the variable specified by the given string. This is useful for variable names with special characters, such as "-" in an expression name.

**Parameters:** - **value** (String)

**Return type:** Variable
variable_persistence_multioctave_noise
Same as multioctave_noise implementation except that it supports variable persistence.

**Parameters:** - **x** (Number) - **y** (Number) - **persistence** (Number): how strong each layer is compared to the next larger one - **seed0** (Number; constant; converted to 32-bit unsigned integer) - **seed1** (NoiseLayerID; constant) - **octaves** (Number; constant 32-bit unsigned integer): how many layers of noise at different scales to sum - **input_scale** (Number; constant; default = 1): x and y will be multiplied by this before sampling - **output_scale** (Number; constant; default = 1): output will be multiplied by this before being returned - **offset_x** (Number; constant; default = 0): will be added to x before applying input_scale - **offset_y** (Number; constant; default = 0): will be added to y before applying input_scale

**Return type:** Number
voronoi_spot_noise
The distance from the current location to the closest point (0 at each point and descending to negative values in a cone around each point).

**Parameters:** - **x** (Number) - **y** (Number) - **seed0** (Number; constant) - **seed1** (NoiseLayerID; constant) - **grid_size** (Number; constant 16-bit unsigned integer): Determines the grid that points are placed into. - **distance_type** (Number or String; enum): The function used for distance computation. - **jitter** (Number; constant 0-1; default = 0.5): 0 = all points in the centre of each cell, 1 = all points randomized within the grid cell.

**Available values for `distance_type`:** - **chebyshev** (0): `max(abs(x), abs(y))` - **manhattan** (1): `abs(x) + abs(y)` - **euclidean** (2): `(x^2 + y^2)^0.5` - **minkowski3** (3): `(x^3 + y^3)^(1/3)`

**Return type:** Number
voronoi_facet_noise
The distance from the 2nd closest point minus the distance to the closest point (0 at a cell boundary, increasing from the edge in facets).

**Parameters:** - **x** (Number) - **y** (Number) - **seed0** (Number; constant) - **seed1** (NoiseLayerID; constant) - **grid_size** (Number; constant 16-bit unsigned integer): Determines the grid that points are placed into. - **distance_type** (Number or String; enum): The function used for distance computation. - **jitter** (Number; constant 0-1; default = 0.5): 0 = all points in the centre of each cell, 1 = all points randomized within the grid cell.

**Available values for `distance_type`:** - **chebyshev** (0): `max(abs(x), abs(y))` - **manhattan** (1): `abs(x) + abs(y)` - **euclidean** (2): `(x^2 + y^2)^0.5` - **minkowski3** (3): `(x^3 + y^3)^(1/3)`

**Return type:** Number
voronoi_pyramid_noise
Like facet noise but the gradient is uniform and represents the distance to the closest edge.

**Parameters:** - **x** (Number) - **y** (Number) - **seed0** (Number; constant) - **seed1** (NoiseLayerID; constant) - **grid_size** (Number; constant 16-bit unsigned integer): Determines the grid that points are placed into. - **distance_type** (Number or String; enum): The function used for distance computation.  - **jitter** (Number; constant 0-1; default = 0.5): 0 = all points in the centre of each cell, 1 = all points randomized within the grid cell.

**Available values for `distance_type`:** - **chebyshev** (0): `max(abs(x), abs(y))` - **manhattan** (1): `abs(x) + abs(y)` - **euclidean** (2): `(x^2 + y^2)^0.5`

**Return type:** Number
voronoi_cell_id
A random value from 0 to 1 assigned per cell that is the same for all points within the cell.

**Parameters:** - **x** (Number) - **y** (Number) - **seed0** (Number; constant) - **seed1** (NoiseLayerID; constant) - **grid_size** (Number; constant 16-bit unsigned integer): Determines the grid that points are placed into. - **distance_type** (Number or String; enum): The function used for distance computation. - **jitter** (Number; constant 0-1; default = 0.5): 0 = all points in the centre of each cell, 1 = all points randomized within the grid cell.

**Available values for `distance_type`:** - **chebyshev** (0): `max(abs(x), abs(y))` - **manhattan** (1): `abs(x) + abs(y)` - **euclidean** (2): `(x^2 + y^2)^0.5` - **minkowski3** (3): `(x^3 + y^3)^(1/3)`

**Return type:** Number
Performance tips
Noise expressions are parsed into AST (abstract syntax tree) following the operator precedence rules. Each AST node is treated separately - the compiler does not see them in a larger context. This is important when it comes to optimization. Expression `x + y + z` is parsed as `(x + y) + z` and `y + z + x` is parsed as `(y + z) + x`. So, `x + y + z` and `y + z + x` are two different expressions despite producing the same result. However, the compiler recognizes commutativity in individual expressions, so `x + y` and `y + x` are identical.

When MapGenSettings change, noise expressions are compiled into a sequence of noise operations. At this point, the compiler tries to optimize them. This section will mostly cover such optimizations.
Constant folding
The compiler implements simple constant folding. If an AST node (function/operator) has all arguments constant, the expression result is computed directly. Therefore, try to place expressions which could be constant first to take advantage of this optimization. - `x + 1 + 2` -> `(x + 1) + 2` (no folding) - `1 + 2 + x` -> `(1 + 2) + x` -> `3 + x` (1 + 2 was folded into 3) - `x ^ 2 ^ 3` -> `x ^ (2 ^ 3)` -> `x ^ 8` (2 ^ 3 was folded into 8) - `2 ^ 3 ^ x` -> `2 ^ (3 ^ x)` (no folding) - `2 * map_width * map_height * x` -> `<constant> * x` (folded at compile time because map_width and map_height are known constants) - `2 + clamp(map_seed, -50, 50) - x` -> `<constant> - x` (folded at compile time because map_seed is a known constant)

If one of them is a constant, the compiler will try to fold it using built-in rules based on arithmetic identities. It can also apply other optimizations. These rules make the compiler to treat left-hand side expressions as identical to right-hand side expressions. - `x + 0` -> `x` (adding 0 doesn't change the result) - `x - 0` -> `x` (subtracting 0 doesn't change the result) - `0 - x` -> `-x` (unary minus is more efficient) - `x * (-1)` -> `-x` (unary minus is more efficient) - `x * 0` -> `0` (multiplying by 0 is always 0) - `x * 1` -> `x` (multiplying by 1 doesn't change the result) - `x / (-1)` -> `-x` (unary minus is more efficient) - `x / 1` -> `x` (dividing by 1 doesn't change the result) - `x ^ 0` -> `1` (anything to the 0 power is 1) - `x ^ 0.5` -> `sqrt(x)` (sqrt is more efficient) - `x ^ 1` -> `x` (exponentiation by 1 doesn't change the result) - `x ^ 2` -> `x * x` (multiplication is more efficient in this case)

In addition, integer powers (such as `x^(-2)`, `x^5`) have their own specialized noise operation for extra optimization.
Compile-time deduplication
The compiler tries to deduplicate noise expressions which are the same. The expressions need to be identical because the compiler is not smart enough to figure out that `x + y + z` and `y + z + x` produce the same result. It is good practice to help the compiler with this process.

Let's say we have these 4 main expressions. How many noise operations will the compiler create after deduplication? Note that constants have their own noise operation and can be deduplicated. - `10 * (x + y)` - `10 * (x - y)` - `10 * (-x + y)` - `20 + 10 * (-x - y)`

The answer is 12. Constant `10` is used 4x, `-x` is used 2x, and none of the other expressions are deduplicated. - `10 * (x + y)`: 3 new operations: `10`, `x + y`, `10 * (x + y)` - `10 * (x - y)`: 2 new operations: `x - y`, `10 * (x - y)` - `10 * (-x + y)`: 3 new operations: `-x`, `-x + y`, `10 * (-x + y)` - `20 + 10 * (-x - y)`: 4 new operations: `-x - y`, `10 * (-x - y)`, `20`, `20 + 10 * (-x - y)`

We can rewrite the expressions in such way that they use less noise operations. - `10 * x + 10 * y`: 4 new operations: `10`, `10 * x`, `10 * y`, `10 * x + 10 * y` - `10 * x - 10 * y`: 1 new operation: `10 * x - 10 * y` - `10 * y - 10 * x`: 1 new operation: `10 * y - 10 * x` - `20 - (10 * x + 10 * y)`: 2 new operations `20`, `20 - (10 * x + 10 * y)`

The rewritten expressions only use 8 noise operations. Mind the brackets in the last expression - they allow us to fully reuse the result from the first one.

Sometimes it's not only about getting less noise operations because some may be more expensive than others. If you enable verbose logging in-game, you will get a report with estimated noise program complexity in the log file after creating a surface or changing MapGenSettings. This is what you should target when doing these optimizations: the smallest possible complexity.

22.290 Verbose CompiledMapGenSettings.cpp:335: "MapGenSettings compilation took 0.031893 seconds."
22.290 Verbose CompiledMapGenSettings.cpp:355:   "Cliff noise program processed 141 expressions (81 unique) and has 54 operations and 13 registers; estimated complexity: 593."
22.291 Verbose CompiledMapGenSettings.cpp:355:   "Entity noise program processed 4241 expressions (1813 unique) and has 1249 operations and 141 registers; estimated complexity: 23391."
22.291 Verbose CompiledMapGenSettings.cpp:355:   "Tile noise program processed 1034 expressions (456 unique) and has 411 operations and 49 registers; estimated complexity: 17616."

Noise seed, scale and offsets
Noise seed usually comes in pair - `seed0` (main seed) and `seed1` (auxiliary seed). Unless you have a good reason not to (e.g. you want a static seed), `seed0` should always be `map_seed` to keep things simple and `seed1` should either be sequential (again, for simplicity) or a string - random values are confusing.

Correct:
  expression = "basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 0}"
  expression = "basis_noise{x = x, y = y, seed0 = map_seed, seed1 = \"my-named-noise\"}"

Incorrect:
  expression = "basis_noise{x = x, y = y, seed0 = map_seed, seed1 = 44869}"
  expression = "basis_noise{x = x, y = y, seed0 = map_seed + 20, seed1 = 0}"

Next, it's more performant to use built-in `input_scale` and `output_scale` parameters to achieve symmetrical scaling than multiplying `x`/`y` variables or the result. This is especially important for `input_scale` because the trivial case of `x = x` and `y = y` is optimized (in general, around 5x faster). The same is true for `offset_x` and `offset_y`.

Correct:
  expression = "basis_noise{x = x, y = y, input_scale = 2, output_scale = 1, seed0 = map_seed, seed1 = 0}"
  expression = "basis_noise{x = x, y = y, input_scale = 1, output_scale = 2, seed0 = map_seed, seed1 = 0}"
  expression = "basis_noise{x = x, y = y, offset_x = 100, offset_y = -50, seed0 = map_seed, seed1 = 0}"

Incorrect:
  expression = "basis_noise{x = x * 2, y = y * 2, input_scale = 1, output_scale = 1, seed0 = map_seed, seed1 = 0}"
  expression = "2 * basis_noise{x = x, y = y, input_scale = 1, output_scale = 1, seed0 = map_seed, seed1 = 0}"
  expression = "basis_noise{x = x + 100, y = y - 50, seed0 = map_seed, seed1 = 0}"

This expression needs asymmetrical input parameters, so you should follow deduplication rules to achieve best performance.

expression = "basis_noise{x = x * 2, y = y * 3, input_scale = 1, output_scale = 1, seed0 = map_seed, seed1 = 0}"
expression = "basis_noise{x = x, y = y * 1.5, input_scale = 2, output_scale = 1, seed0 = map_seed, seed1 = 0}"

Lastly, use regular multi-octave noise instead of quick multi-octave noise if possible. Their performance is very similar.

Defines|<

## General Topics
[Data Lifecycle](data-lifecycle.html)[Storage](storage.html)[Migrations](migrations.html)[Libraries](libraries.html)[Prototype Inheritance Tree](prototype-tree.html)Noise Expressions[Instrument Mode](instrument.html)[Item Weight](item-weight.html)
## JSON Docs
[Runtime JSON Format](json-docs-runtime.html)[Prototype JSON Format](json-docs-prototype.html)

[ Defines](../defines.html)[alert_type](../defines.html#defines.alert_type)[behavior_result](../defines.html#defines.behavior_result)[build_check_type](../defines.html#defines.build_check_type)[build_mode](../defines.html#defines.build_mode)[cargo_destination](../defines.html#defines.cargo_destination)[chain_signal_state](../defines.html#defines.chain_signal_state)[chunk_generated_status](../defines.html#defines.chunk_generated_status)[command](../defines.html#defines.command)[compound_command](../defines.html#defines.compound_command)[control_behavior](../defines.html#defines.control_behavior)[controllers](../defines.html#defines.controllers)[deconstruction_item](../defines.html#defines.deconstruction_item)[default_icon_size](../defines.html#defines.default_icon_size)[difficulty](../defines.html#defines.difficulty)[direction](../defines.html#defines.direction)[disconnect_reason](../defines.html#defines.disconnect_reason)[distraction](../defines.html#defines.distraction)[entity_status](../defines.html#defines.entity_status)[entity_status_diode](../defines.html#defines.entity_status_diode)[events](../defines.html#defines.events)[flow_precision_index](../defines.html#defines.flow_precision_index)[game_controller_interaction](../defines.html#defines.game_controller_interaction)[group_state](../defines.html#defines.group_state)[gui_type](../defines.html#defines.gui_type)[input_action](../defines.html#defines.input_action)[input_method](../defines.html#defines.input_method)[inventory](../defines.html#defines.inventory)[logistic_member_index](../defines.html#defines.logistic_member_index)[logistic_mode](../defines.html#defines.logistic_mode)[logistic_section_type](../defines.html#defines.logistic_section_type)[mouse_button_type](../defines.html#defines.mouse_button_type)[moving_state](../defines.html#defines.moving_state)[print_skip](../defines.html#defines.print_skip)[print_sound](../defines.html#defines.print_sound)[prototypes](../defines.html#defines.prototypes)[rail_connection_direction](../defines.html#defines.rail_connection_direction)[rail_direction](../defines.html#defines.rail_direction)[rail_layer](../defines.html#defines.rail_layer)[relative_gui_position](../defines.html#defines.relative_gui_position)[relative_gui_type](../defines.html#defines.relative_gui_type)[render_mode](../defines.html#defines.render_mode)[rich_text_setting](../defines.html#defines.rich_text_setting)[riding](../defines.html#defines.riding)[robot_order_type](../defines.html#defines.robot_order_type)[rocket_silo_status](../defines.html#defines.rocket_silo_status)[selection_mode](../defines.html#defines.selection_mode)[shooting](../defines.html#defines.shooting)[signal_state](../defines.html#defines.signal_state)[space_platform_state](../defines.html#defines.space_platform_state)[target_type](../defines.html#defines.target_type)[train_state](../defines.html#defines.train_state)[transport_line](../defines.html#defines.transport_line)[wire_connector_id](../defines.html#defines.wire_connector_id)[wire_origin](../defines.html#defines.wire_origin)[wire_type](../defines.html#defines.wire_type)

>|

 Copyright © Wube Software |[License](../license.html)|[Download](../static/archive.zip)|Feedback