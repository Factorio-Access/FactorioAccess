--[[
Everything in the mod pretty much is a grid.  Each cell of the grid may either
contain a string or a child control, e.g. a button that pushes another panel on
the stack.  Menus for example are vertical 1xn grids, and the fast travel menu
is a vertical cxn grid where c is the commands one mayh use on it.  There are
two things that must happen in order to make this work: there must be functions
to move around, and there must be a way to control how dimensions work.

To do this, we define some callbacks, then implement higher level things on top
of those callbacks.  Note that { x, y } means table with those fields, not an
array:

- get_dims: should return a table with fields x and y, specifying the
  dimensionhs.  This may change arbitrarily; the implementation here can handle
  it.
- get_value(x, y): return the value at the given coordinates.  If they are out
  of range, return grid.OUT_OF_RANGE.  May return a ControlDef or a
  LocalisedString.  See below about controls, which have special rules.
- move_to(x, y): called when the player moves to something else, and that
  something else is a string.
- click(x, y): if get_value did not return a control, called to try to perform
  an action.  Should return one of the CLICK_RESULT enum members.
- get_pos_announcement({ x, y }, { max_x, max_y }): Return a localised string
  saying the dimensions, or nil.  Optional.  If not provided, the user gets a
  default that does announce dimensions.  If one dimension is 1, then it's "x
  out of y", otherwise it's "x, y"
- has_updated: if present, used to tell us what to drop.  If this never returns
  anything but NOT_CHANGED, parts of the UI will be rebuilt.  Optional.  If not
  present, strings are always out of date and controls are always up to date.

A few dimension announcing functions are in this module that you may plug in.

We also have the following options:

- forward_vertical, forward_horizontal: if true, these forward things to the
  child controls.  This allows nesting, where the child is, e.g., a list of
  commands.  Use them if you must represent jagged menus.
- update_frequency: value in ticks setting how often internal caches live. State
  will not update nor will the above callbacks be called in between periods.

# Controls

Controls require following some rules:

- If you return a control, you will not be called again until and unless the
  control is dropped from the cached state.  By default this happens never.
- When you change dimensions and it's a shrink, all controls you've returned are
  wiped out for those cells.
- When informing us that the thing has changed, via has_updated, all controls
  are optionally wiped out based on the INVALIDATION_ACTION enum.
- To distinguish between localised strings and controls, we check whether or not
  the table is/has an array component: do not use top-level number keys in your
  vtable.
- finally, controls are responsible for understanding evt_focused to announce
  themselves.  We do not do so.  Controls generally already have this
  functionality.
]]
