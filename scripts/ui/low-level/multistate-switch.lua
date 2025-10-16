--[[
A low-level abstraction over a toggle which deals with things like inserter read
modes: "off", or a list of some values.  The toggler itself is stateless, and
toggling it immediately moves the entity through the various states.

Note that the following API isn't exactly stable as such.  This is code which is
being used to partially replace less ideal code as a midpoint on the path to a
proper UI system.  The goal is for this to become a detail inside a declared UI
hierarchy.

These cannot be saved in storage, and are intentionally blocked from doing so.
They are static config.  That restriction will be lifted in future, but we are
not yet at the point of ephemeral state.

First, you declare your UI:

```
local F = require('scripts.field-ref')
local multistate_switch = require('scripts.ui.low-level.multistate-switch')

local switch = multistate_switch.create({
   on_off_field = F.controloler.something_boolean,
   state_field = F.controller.inserter_read_mode_or_something,
   off_label = "Off", -- or "None", whatever, the "off state".
   choices = {
      -- (value, label).  Will be presented in this order, which is why it's
      -- not a standard kv table.
      { defines.thing, "Reading Contents" },
      { defines.other_thing, "reading something else" },
   }
})
```

This gives back a table with 3 methods: `prev`, `current`, and `next`.  Current
has no side effects and figures out the current label; prev/next move
back/forward respectively and return the new label.  They all take exactly one
argument: something with properties matching the two references above on it. So,
for example:

```
local e = get_an_entity_somehow()
local new_label = switch.next(e)
-- new_label == cur_label, if and only if these are in the same tick.
-- Otherwise, something else might have changed the value.
local cur_label = switch.current(e)
```

Note that this abstraction does not care whether the entity is really a factorio
entity.  Tables work, for example.
]]
local circular_list = require("ds.circular-options-list")
local F = require("scripts.field-ref") -- for self-tests
local methods = require("scripts.methods")

local mod = {}

---@alias MultistateSwitchChoices { [1]: any, [2]: string }[]

---@class MultistateSwitchOptions
---@field on_off_field FieldRef A boolean field which will toggle it on or off.
---@field state_field FieldRef The field that contains the state value.
---@field off_label string The label to use for the off state.
---@field choices MultistateSwitchChoices The choices for the on states.

local function get_cur_key(instance, from_what)
   return { instance.on_off_field.get(from_what), instance.state_field.get(from_what) }
end

local function generic_movement(instance, entity, calling, do_set)
   local key = get_cur_key(instance, entity)
   local ret = calling(instance.menu, key)
   assert(ret ~= nil, "Unhandled state in switch. This probably means you missed an entry in choices")
   key = ret.key

   if do_set then
      instance.on_off_field.set(entity, key[1])
      if key[1] then
         -- It's on, also do the choice.
         instance.state_field.set(entity, key[2])
      end
   end

   return ret.value.label
end

-- Our methods are just 3 variations on the above.
---@class MultistateSwitch
local multistate_methods = {}

---@param entity table<any, any>
---@return string
function multistate_methods:prev(entity)
   return generic_movement(self, entity, circular_list.prev, true)
end

---@param entity table<any, any>
---@return string
function multistate_methods:next(entity)
   return generic_movement(self, entity, circular_list.next, true)
end

---@param entity table<any, any>
---@return string
function multistate_methods:current(entity)
   return generic_movement(self, entity, circular_list.current, false)
end

local linker = methods.link("multistate-switch", multistate_methods)

---@param opts MultistateSwitchOptions
---@return MultistateSwitch
function mod.create(opts)
   -- What we are actually going to do is compile to a circular list and save
   -- that.
   local instance = {
      on_off_field = opts.on_off_field,
      state_field = opts.state_field,
      __no_storage = function() end,
   }

   -- Our keys are { onoff, state } and values { label = message }, using the
   -- wildcard to capture all the off states into one entry.

   local choices = {
      { { false, circular_list.ANY }, { label = opts.off_label } },
   }

   for i = 1, #opts.choices do
      table.insert(choices, { { true, opts.choices[i][1] }, { label = opts.choices[i][2] } })
   end
   local choice_list = circular_list.kv_list(choices, circular_list.tuples)

   instance.menu = choice_list
   linker(instance)
   return instance
end

-- here come the self tests.
local fake_entity = { on = false, state = 0 }
local test_switch = mod.create({
   on_off_field = F.on(),
   state_field = F.state(),
   off_label = "is off",
   choices = {
      { 0, "is 0" },
      { 1, "is 1" },
      { 2, "is 2" },
   },
})

assert(test_switch:current(fake_entity) == "is off")

assert(test_switch:next(fake_entity) == "is 0")
assert(fake_entity.on == true)
assert(fake_entity.state == 0)

assert(test_switch:next(fake_entity) == "is 1")
assert(fake_entity.on == true)
assert(fake_entity.state == 1)

assert(test_switch:next(fake_entity) == "is 2")
assert(fake_entity.on == true)
assert(fake_entity.state == 2)

assert(test_switch:next(fake_entity) == "is off")
assert(fake_entity.on == false)
-- When switching to off, the other property is left alone.
assert(fake_entity.state == 2)

assert(test_switch:prev(fake_entity) == "is 2")
assert(test_switch:prev(fake_entity) == "is 1")
assert(fake_entity.on == true)
assert(fake_entity.state == 1)

return mod
