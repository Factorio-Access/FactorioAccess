--[[
A work queue takes some number of work items and runs them across some number of
ticks.  This is used to amortize the cost of long-running operations across
ticks so that UPS stays reasonable.

To use it, call declare_work_queue to make a work queue.  This will wire up a
queue which will call a specified function and use a specified key in storage
for the state.  Queues cannot currently be shared or stored in storage by the
user--they're singletons.  This may later be fixed with a migration which kills
the work_queues key of storage, then starts returning a full state.  That's not
hard, as one can use a similar trick to scripts.ds.clusterer, just not worth it
as of this writing (2024-09-05).  Note that such a replacement must also solve
being registered with a central registry, which is a non-obvious problem.
Otherwise they can't advance with this module's on_tick.

Each enqueued item is of whatever form the caller wants and consequently can
carry state or etc.  For more complex patterns the last item enqueued by the
caller will be called last and can be used to update structures external to the
queue model.  These items are stored in storage and cannot contain functions or
closures directly.  Instead, use a key that indexes into a table of your own to
get the function when the item runs.

It is safe to modify (including clearing) the work queue while inside an item's
callback.

For modules which wish to respawn work (e.g. scanner), a function
`idle_function` may be specified. This gets called if there is a tick where the
queue is empty.
]]
local Deque = require("ds.deque")

local mod = {}

---@class fa.WorkQueueHandle
---@field name string
---@field worker_function fun(item: any)
---@field idle_function (fun(fa.WorkQueueHandle))?
---@field per_tick number
local WorkQueueHandle = {}
local work_queue_handle_meta = { __index = WorkQueueHandle }
if script then script.register_metatable("fa.WorkQueue", work_queue_handle_meta) end

-- This state, held outside storage, is reconstituted on imports.  It is used to
-- let this module know about all work queues. -@type fa.WorkQueueHandle[]
local queues = {}

-- This set ensures that no queue is declared more than twice.
---@type table<string, true>
local declared_names = {}

---@class fa.WorkQueueOpts
---@field name string Must be globally unique.
---@field worker_function fun(any)
---@field idle_function (fun(fa.WorkQueueHandle))?
---@field per_tick number how many items to dequeue per tick

---@param opts fa.WorkQueueOpts
---@returns fa.WorkQueueHandle
function mod.declare_work_queue(opts)
   assert(not declared_names[opts.name], "Attempt to declare queues of the same name: name=" .. opts.name)
   declared_names[opts.name] = true

   local qstate = {
      name = opts.name,
      worker_function = opts.worker_function,
      idle_function = opts.idle_function,
      per_tick = opts.per_tick,
   }
   setmetatable(qstate, work_queue_handle_meta)
   table.insert(queues, qstate)
   return qstate
end

-- For dev. Set to true to make work queues reset themselves on game restarts.
local force_clear = false

---@returns { items: fa.ds.Deque }
local function qstate_from_storage(name)
   if force_clear then
      storage.work_queues = {}
      force_clear = false
   end
   storage.work_queues = storage.work_queues or {}
   if not storage.work_queues[name] then storage.work_queues[name] = {
      items = Deque.Deque.new(),
   } end

   return storage.work_queues[name]
end

function WorkQueueHandle:enqueue(item)
   local state = qstate_from_storage(self.name)
   state.items:push_back(item)
end

function WorkQueueHandle:clear()
   local state = qstate_from_storage(self.name)
   state.items:clear()
end

function mod.on_tick()
   for _, q in pairs(queues) do
      local state = qstate_from_storage(q.name)
      local did = 0
      for i = 1, q.per_tick do
         local item = state.items:pop_front()
         if not item then break end
         did = did + 1
         q.worker_function(item)
      end

      if did == 0 and q.idle_function then q.idle_function(q) end
   end
end

return mod
