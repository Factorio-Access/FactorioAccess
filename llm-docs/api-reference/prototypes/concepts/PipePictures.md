# PipePictures

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### straight_vertical_single

**Type:** `Sprite`

**Optional:** Yes

### straight_vertical

**Type:** `Sprite`

**Optional:** Yes

### straight_vertical_window

**Type:** `Sprite`

**Optional:** Yes

### straight_horizontal

**Type:** `Sprite`

**Optional:** Yes

### straight_horizontal_window

**Type:** `Sprite`

**Optional:** Yes

### corner_up_right

**Type:** `Sprite`

**Optional:** Yes

### corner_up_left

**Type:** `Sprite`

**Optional:** Yes

### corner_down_right

**Type:** `Sprite`

**Optional:** Yes

### corner_down_left

**Type:** `Sprite`

**Optional:** Yes

### t_up

**Type:** `Sprite`

**Optional:** Yes

### t_down

**Type:** `Sprite`

**Optional:** Yes

### t_right

**Type:** `Sprite`

**Optional:** Yes

### t_left

**Type:** `Sprite`

**Optional:** Yes

### cross

**Type:** `Sprite`

**Optional:** Yes

### ending_up

**Type:** `Sprite`

**Optional:** Yes

### ending_down

**Type:** `Sprite`

**Optional:** Yes

### ending_right

**Type:** `Sprite`

**Optional:** Yes

### ending_left

**Type:** `Sprite`

**Optional:** Yes

### straight_vertical_single_frozen

**Type:** `Sprite`

**Optional:** Yes

### straight_vertical_frozen

**Type:** `Sprite`

**Optional:** Yes

### straight_vertical_window_frozen

**Type:** `Sprite`

**Optional:** Yes

### straight_horizontal_frozen

**Type:** `Sprite`

**Optional:** Yes

### straight_horizontal_window_frozen

**Type:** `Sprite`

**Optional:** Yes

### corner_up_right_frozen

**Type:** `Sprite`

**Optional:** Yes

### corner_up_left_frozen

**Type:** `Sprite`

**Optional:** Yes

### corner_down_right_frozen

**Type:** `Sprite`

**Optional:** Yes

### corner_down_left_frozen

**Type:** `Sprite`

**Optional:** Yes

### t_up_frozen

**Type:** `Sprite`

**Optional:** Yes

### t_down_frozen

**Type:** `Sprite`

**Optional:** Yes

### t_right_frozen

**Type:** `Sprite`

**Optional:** Yes

### t_left_frozen

**Type:** `Sprite`

**Optional:** Yes

### cross_frozen

**Type:** `Sprite`

**Optional:** Yes

### ending_up_frozen

**Type:** `Sprite`

**Optional:** Yes

### ending_down_frozen

**Type:** `Sprite`

**Optional:** Yes

### ending_right_frozen

**Type:** `Sprite`

**Optional:** Yes

### ending_left_frozen

**Type:** `Sprite`

**Optional:** Yes

### straight_vertical_single_visualization

**Type:** `Sprite`

**Optional:** Yes

### straight_vertical_visualization

**Type:** `Sprite`

**Optional:** Yes

### straight_vertical_window_visualization

**Type:** `Sprite`

**Optional:** Yes

### straight_horizontal_visualization

**Type:** `Sprite`

**Optional:** Yes

### straight_horizontal_window_visualization

**Type:** `Sprite`

**Optional:** Yes

### corner_up_right_visualization

**Type:** `Sprite`

**Optional:** Yes

### corner_up_left_visualization

**Type:** `Sprite`

**Optional:** Yes

### corner_down_right_visualization

**Type:** `Sprite`

**Optional:** Yes

### corner_down_left_visualization

**Type:** `Sprite`

**Optional:** Yes

### t_up_visualization

**Type:** `Sprite`

**Optional:** Yes

### t_down_visualization

**Type:** `Sprite`

**Optional:** Yes

### t_right_visualization

**Type:** `Sprite`

**Optional:** Yes

### t_left_visualization

**Type:** `Sprite`

**Optional:** Yes

### cross_visualization

**Type:** `Sprite`

**Optional:** Yes

### ending_up_visualization

**Type:** `Sprite`

**Optional:** Yes

### ending_down_visualization

**Type:** `Sprite`

**Optional:** Yes

### ending_right_visualization

**Type:** `Sprite`

**Optional:** Yes

### ending_left_visualization

**Type:** `Sprite`

**Optional:** Yes

### straight_vertical_single_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### straight_vertical_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### straight_vertical_window_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### straight_horizontal_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### straight_horizontal_window_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### corner_up_right_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### corner_up_left_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### corner_down_right_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### corner_down_left_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### t_up_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### t_down_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### t_right_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### t_left_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### cross_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### ending_up_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### ending_down_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### ending_right_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### ending_left_disabled_visualization

**Type:** `Sprite`

**Optional:** Yes

### horizontal_window_background

**Type:** `Sprite`

**Optional:** Yes

### vertical_window_background

**Type:** `Sprite`

**Optional:** Yes

### fluid_background

**Type:** `Sprite`

**Optional:** Yes

### low_temperature_flow

Visualizes the flow of the fluid in the pipe. Drawn when `(fluid_temp - fluid_min_temp) / (fluid_max_temp - fluid_min_temp)` is less than or equal to `1/3` and the fluid's temperature is below [FluidPrototype::gas_temperature](prototype:FluidPrototype::gas_temperature).

**Type:** `Sprite`

**Optional:** Yes

### middle_temperature_flow

Visualizes the flow of the fluid in the pipe. Drawn when `(fluid_temp - fluid_min_temp) / (fluid_max_temp - fluid_min_temp)` is larger than `1/3` and less than or equal to `2/3` and the fluid's temperature is below [FluidPrototype::gas_temperature](prototype:FluidPrototype::gas_temperature).

**Type:** `Sprite`

**Optional:** Yes

### high_temperature_flow

Visualizes the flow of the fluid in the pipe. Drawn when `(fluid_temp - fluid_min_temp) / (fluid_max_temp - fluid_min_temp)` is larger than `2/3` and the fluid's temperature is below [FluidPrototype::gas_temperature](prototype:FluidPrototype::gas_temperature).

**Type:** `Sprite`

**Optional:** Yes

### gas_flow

Visualizes the flow of the fluid in the pipe. Drawn when the fluid's temperature is above [FluidPrototype::gas_temperature](prototype:FluidPrototype::gas_temperature).

**Type:** `Animation`

**Optional:** Yes

